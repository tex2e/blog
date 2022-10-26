---
layout:        post
title:         "pip installでCERTIFICATE_VERIFY_FAILEDが出る時の対処法"
date:          2022-07-09
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

社内LANなどのSSLインスペクションが有効になっている環境で、全てのHTTPS通信が傍受されている場合、pip install が証明書エラーで失敗する場合があります。
その場合、接続先を信頼する（証明書エラーを無視する）ことで、pipインストールできるようになります。

証明書エラーが出る場合は、pypi.python.org, files.pythonhosted.org, pypi.org の3個のドメインを信頼済みにしてからpipインストールします。
具体的には、pipのオプションに `--trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org` を追加します。

```bash
pip --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org install <ライブラリ名...>
```

なお、SSLインスペクションがない通常の環境では `pip install ライブラリ名` でインストールできます。


<br>

#### (補足) 実行時のエラー「CERTIFICATE_VERIFY_FAILED」

pipでインストールしようとすると after connection broken by SSLError(SSLCertVerificationError(1, [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate と表示されます。

```
$ pip install PACKAGENAME
WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1108)'))': /simple/PACKAGENAME/
WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1108)'))': /simple/PACKAGENAME/
WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1108)'))': /simple/PACKAGENAME/
WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1108)'))': /simple/PACKAGENAME/
WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1108)'))': /simple/PACKAGENAME/
Could not fetch URL https://pypi.org/simple/PACKAGENAME/: There was a problem confirming the ssl certificate: HTTPSConnectionPool(host='pypi.org', port=443): Max retries exceeded with url: /simple/PACKAGENAME/ (Caused by SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1108)'))) - skipping
ERROR: Could not find a version that satisfies the requirement PACKAGENAME (from versions: none)
ERROR: No matching distribution found for PACKAGENAME
Could not fetch URL https://pypi.org/simple/pip/: There was a problem confirming the ssl certificate: HTTPSConnectionPool(host='pypi.org', port=443): Max retries exceeded with url: /simple/pip/ (Caused by SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1108)'))) - skipping
```

以上です。
