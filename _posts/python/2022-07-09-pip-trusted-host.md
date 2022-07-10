---
layout:        post
title:         "SSLインスペクション環境下でpip installする"
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

通常は以下のコマンドでpipインストールできます。

```bash
pip install <ライブラリ名...>
```

証明書エラーが出る場合は、pypi.python.org, files.pythonhosted.org, pypi.org の3個のドメインを信頼済みにしてからpipインストールします。
具体的には、pipのオプションに `--trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org` を追加します。

```bash
pip --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org install <ライブラリ名...>
```

以上です。
