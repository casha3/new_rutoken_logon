curl --ntlm -u 'user:Q12345qq' \
  --data-urlencode "Mode=newreq" \
  --data-urlencode "CertRequest=$(cat windows.csr)" \
  --data-urlencode "CertAttrib=CertificateTemplate:User" \
  --data-urlencode "TargetStoreFlags=0" \
  --data-urlencode "SaveCert=yes" \
  --data-urlencode "ThumbPrint=" \
  'http://10.10.4.131/certsrv/certfnsh.asp' \
  -o /tmp/cert_response.html \
  -w "\nHTTP_CODE=%{http_code}\n"