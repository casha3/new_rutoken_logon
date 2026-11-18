DN=$(LC_ALL=C ipa user-show altuser --all | sed -n 's/^ *DN: *//p')
echo "DN=$DN"
ldapmodify -Y GSSAPI -H ldap://alt.freeipa.course <<EOF
dn: $DN
changetype: modify
delete: krbPasswordExpiration
EOF