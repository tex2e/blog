---
layout:        post
title:         "[Python] FlaskでHTTPSサーバを立てる方法"
date:          2022-10-22
category:      Python
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

証明書と秘密鍵を使ってFlaskでHTTPSサーバを起動させる方法について説明します。
まず、証明書の作成は [サーバ名がIPアドレスの場合の証明書作成 \| 晴耕雨読](http://localhost:4000/blog/protocol/certificate-with-ip-addr) などを参考に作成してください。
以下ではWebサーバにIPアドレスでアクセスすることを前提に説明します。

まず、テスト用FlaskサーバをPythonで書き、main.pyに保存します。
例では、トップにアクセスすると「Hello World!」と返すだけのWebサイトです。
実行時に app.run() の引数で port=443 (HTTPSのデフォルトポート番号)、ssl_context=(証明書のパス, 秘密鍵のパス) を指定します。
また、ローカル以外からアクセスできるように、host='0.0.0.0' も指定して実行します。

```python
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"

if __name__ == "__main__":
    app.run(debug=True, port=443, ssl_context=('.\certs\server.crt', '.\certs\server.key'), host='0.0.0.0')
```

Pythonを書いたら、`python3 main.py` で実行します。
Webサーバ起動中に curl で HTTPS アクセスできるか確認してみます。

```console
% curl -v --cacert server.crt https://192.168.11.2/
*   Trying 192.168.11.2:443...
* TCP_NODELAY set
* Connected to 192.168.11.2 (192.168.11.2) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: server.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN, server did not agree to a protocol
* Server certificate:
*  subject: C=JP; ST=Tokyo; L=Minato City; O=TeX2e; CN=mytest.example.com
*  start date: Oct 18 10:23:22 2022 GMT
*  expire date: Oct 18 10:23:22 2023 GMT
*  subjectAltName: host "192.168.11.2" matched cert's IP address!
*  issuer: C=JP; ST=Tokyo; L=Minato City; O=TeX2e; CN=mytest.example.com
*  SSL certificate verify ok.
> GET / HTTP/1.1
> Host: 192.168.11.2
> User-Agent: curl/7.68.0
> Accept: */*
>
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Server: Werkzeug/2.1.2 Python/3.9.6
< Content-Type: text/html; charset=utf-8
< Content-Length: 12
< Connection: close
<
* Closing connection 0
* TLSv1.3 (OUT), TLS alert, close notify (256):
Hello World!

```

TLS 1.3 で HTTPS 通信ができたことが確認できます。

以上です。
