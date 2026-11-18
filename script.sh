DN=$(LC_ALL=C ipa user-show altuser --all | sed -n 's/^ *DN: *//p')
echo "DN=[$DN]"
printf 'dn: %s\nchangetype: modify\ndelete: krbPasswordExpiration\n' "$DN" > /tmp/del.ldif
cat /tmp/del.ldif
ldapmodify -Y GSSAPI -H ldap://alt.freeipa.course -f /tmp/del.ldif
LC_ALL=C ipa user-show altuser --all | grep -iE 'expir|must' || echo ">>> expiration снят, сервер чист"