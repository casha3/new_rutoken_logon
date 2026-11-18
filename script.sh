#!/bin/bash
# del_expiration.sh — снимает krbPasswordExpiration у altuser в FreeIPA
set -eu
export LC_ALL=C                      # локаль фиксируем ОДИН раз

LDAP_HOST="alt.freeipa.course"
USER="altuser"

# 1) вызываем ipa ОТДЕЛЬНО (вне пайплайна), чтобы поймать отказ билета
out=$(ipa user-show "$USER" --all) || {
    echo "ERROR: ipa user-show упал — проверь 'kinit admin' и билет (klist)"
    exit 1
}

# 2) устойчивое извлечение DN: регистр и пробелы вокруг двоеточия не важны
DN=$(printf '%s\n' "$out" | grep -iE '^[[:space:]]*dn[[:space:]]*:' | head -n1 \
     | sed -E 's/^[[:space:]]*dn[[:space:]]*:[[:space:]]*//I')

# 3) если DN всё ещё пуст — скрипт сам покажет, как реально выглядит метка
[[ -n "$DN" ]] || {
    echo "ERROR: DN не найден в выводе ipa. Сырые строки, содержащие 'dn':"
    printf '%s\n' "$out" | grep -in 'dn' || echo "(ни одной строки с dn — точно отказ ipa/билета)"
    exit 1
}
echo "DN=[$DN]"

# 4) LDIF в файл (без heredoc → нет ловушки «EOF не в колонке 0»)
printf 'dn: %s\nchangetype: modify\ndelete: krbPasswordExpiration\n' "$DN" > /tmp/del.ldif
cat /tmp/del.ldif

# 5) применяем; перехват отказа, чтобы set -e не убил молча, а подсказал фолбэк
if ! ldapmodify -Y GSSAPI -H "ldap://$LDAP_HOST" -f /tmp/del.ldif; then
    echo "ldapmodify упал (вероятно ACI на krbPasswordExpiration)."
    echo "Фолбэк: ipa pwpolicy-mod global_policy --maxlife=365 && ipa passwd $USER"
    exit 2
fi

# 6) контроль: expiration должен исчезнуть
if printf '%s\n' "$(ipa user-show "$USER" --all)" | grep -qiE 'expir'; then
    echo "WARNING: expiration всё ещё висит — сервер не чист."
    exit 2
fi
echo ">>> expiration снят, сервер чист"