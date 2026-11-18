# 1. Извлекаем номер запроса (ReqID) из HTML-ответа
REQ_ID=$(grep -oP 'ReqID=\K[0-9]+' /tmp/cert_response.html | head -1)
echo "Найден ReqID: $REQ_ID"

# 2. Скачиваем сертификат пользователя в формате Base64 (параметр &Enc=b64 обязателен!)
curl --ntlm -u 'user:Q12345qq' \
  "http://10.10.4.131/certsrv/certnew.cer?ReqID=${REQ_ID}&Enc=b64" \
  -o /home/administrator/Загрузки/certnew.cer

# 3. Проверяем, что скачался именно сертификат ПОЛЬЗОВАТЕЛЯ, а не корневой сертификат CA
echo "--- Проверка сертификата ---"
openssl x509 -in /home/administrator/Загрузки/certnew.cer -noout -subject -issuer