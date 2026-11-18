#!/bin/bash
# устойчивое извлечение DN (регистронезависимо, без ловушки пустого sed)
DN=$(LC_ALL=C ipa user-show altuser --all | grep -iE '^[[:space:]]*dn[[:space:]]*:' | head -n1 | sed -E 's/^[[:space:]]*dn[[:space:]]*:[[:space:]]*//I')
[[ -n "$DN" ]] || { echo "DN пустой — стоп"; exit 1; }
echo "DN=[$DN]"

# будущая дата в GeneralizedTime (UTC, суффикс Z) = now + 700 суток
EXP=$(date -u -d '+700 days' +%Y%m%d%H%M%SZ)
echo "EXP=$EXP"

printf 'dn: %s\nchangetype: modify\nreplace: krbPasswordExpiration\nkrbPasswordExpiration: %s\n' "$DN" "$EXP" > /tmp/set.ldif
cat /tmp/set.ldif

ldapmodify -Y GSSAPI -H ldap://alt.freeipa.course -f /tmp/set.ldif
LC_ALL=C ipa user-show altuser --all | grep -iE 'expir|must'