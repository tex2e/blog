---
layout:        post
title:         "[Bash] /dev/tcpを使用してサーバのポートが開いているか確認する"
date:          2025-05-12
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

/dev/tcpの仮想デバイスファイルを使うことで、ファイルを読み書きする感覚で、ネットワーク上に任意の文字列を送信したり受信したりすることができます。
telnetなどインストールできない環境で、ポートスキャンするときなどに/dev/tcpは便利です。

以下は、指定したサーバIPとポートに対して一定秒数間隔でTCP通信を行い、ポートが開いているかを確認するためのシェルスクリプトです。

```bash
echo "[*] Webサーバが起動するまで待機..."
for i in {1..100}; do
  if `(echo test > /dev/tcp/192.168.11.22/80) &>/dev/null`; then
    echo "[+] Webサーバが起動しました。"
    break
  fi
  if [ $i -eq 100 ]; then
    echo "[!] Webサーバは起動しませんでした。"
    exit 1
  fi
  echo "[-] Webサーバが未起動のため、3秒後にリトライします..."
  sleep 3
done
```

ifの中で実行しているコマンド `echo test > /dev/tcp/192.168.11.22/80` の部分で、対象のサーバIP「192.168.11.22」のポート「80」に対して、文字列「test」を送信しています。

文字列「test」は、通信相手にとって不正な受信値になる可能性があるため、エラー文字列が返ってくる可能性がありますが、その場合は通信の接続は成功したことになるため、echoコマンド自体は正常終了となります。
もし、通信できなかったときは異常終了となり、正常終了になるまでfor文のループが繰り返されます。

以上です。
