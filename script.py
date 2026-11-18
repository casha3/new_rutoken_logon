python3 << 'EOF'
import urllib.request
import urllib.parse

# Читаем CSR
with open('windows.csr', 'r') as f:
    csr = f.read()

# Кодируем данные для POST
data = {
    'Mode': 'newreq',
    'CertRequest': csr,
    'CertAttrib': 'CertificateTemplate:User',
    'TargetStoreFlags': '0',
    'SaveCert': 'yes',
    'ThumbPrint': ''
}

encoded_data = urllib.parse.urlencode(data).encode('utf-8')

# Создаём запрос
req = urllib.request.Request(
    'http://10.10.4.131/certsrv/certfnsh.asp',
    data=encoded_data,
    method='POST'
)

# NTLM-аутентификация (базовая, без библиотеки requests-ntlm)
import base64
auth = base64.b64encode(b'user:Q12345qq').decode()
req.add_header('Authorization', f'Basic {auth}')
req.add_header('Content-Type', 'application/x-www-form-urlencoded')

try:
    resp = urllib.request.urlopen(req, timeout=30)
    html = resp.read().decode('utf-8', errors='ignore')
    
    with open('/tmp/cert_response.html', 'w') as f:
        f.write(html)
    
    print('OK! Ответ сохранён в /tmp/cert_response.html')
    print('HTTP код:', resp.status)
    print('Первые 500 символов:')
    print(html[:500])
except Exception as e:
    print('Ошибка:', e)
EOF