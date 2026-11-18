#!/bin/bash
# del_expiration.sh — снимает krbPasswordExpiration у altuser в FreeIPA
set -euo pipefail
export LC_ALL=C                      # фиксим локаль ОДИН раз, префиксы в командах не нужны

LDAP_HOST="alt.freeipa.course"
USER="altuser"

# 1) достаём реальный DN
DN=$(ipa user-show "$USER" --all | sed -n 's/^ *DN: *//p')
[[ -n "$DN" ]] || { echo "ERROR: DN пустой — sed не совпал с выводом ipa"; exit 1; }
echo "DN=[$DN]"

# 2) пишем LDIF в файл (без heredoc → нет ловушки «EOF не в колонке 0»)
printf 'dn: %s\nchangetype: modify\ndelete: krbPasswordExpiration\n' "$DN" > /tmp/del.ldif
cat /tmp/del.ldif

# 3) применяем; перехватываем ошибку, чтобы set -e не убил молча, а подсказал фолбэк
if ! ldapmodify -Y GSSAPI -H "ldap://$LDAP_HOST" -f /tmp/del.ldif; then
    echo "ldapmodify упал (вероятно ACI на krbPasswordExpiration)."
    echo "Фолбэк: ipa pwpolicy-mod global_policy --maxlife=365 && ipa passwd $USER"
    exit 2
fi

# 4) контрольная проверка: expiration должен исчезнуть
if ipa user-show "$USER" --all | grep -qiE 'expir'; then
    echo "WARNING: expiration всё ещё висит — сервер не чист."
    exit 2
fi
echo ">>> expiration снят, сервер чист"