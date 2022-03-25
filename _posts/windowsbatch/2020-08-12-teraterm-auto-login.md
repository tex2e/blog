---
layout:        post
title:         "TeraTermマクロでリモートログイン自動化"
date:          2020-08-12
category:      WindowsBatch
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

TeraTermマクロ（Tera Term Language: TTL）を使うことでSSHのリモートログインを自動化することができます。
以下の例は、リモートサーバにSSHで接続するときのパスワード入力を自動化する例です（ただし、パスワードは平文で保存されます）。

login.ttl

```ttl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
host = 'IPアドレス'
user = 'ユーザ名'
pass = 'パスワード'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

COMMAND = host
strconcat COMMAND ':22 /ssh /2 /auth=password /user='
strconcat COMMAND user
strconcat COMMAND ' /passwd="'
strconcat COMMAND pass
strconcat COMMAND '"'
connect COMMAND

wait '$' '#'
end
```

作成したマクロ login.ttl をダブルクリックして実行すると、自動でログインされます。
ダブルクリックで起動できない場合は .ttl を C:\Program Files (x86)\teraterm\ttpmacro.exe に関連付けしておくと、ダブルクリックだけでマクロを実行できるようになります。

TTLコマンドについて説明：

- `変数名 = 値` : ユーザ変数を定義します。
- `;` : コメントアウトします。
- `strconcat 文字列変数 文字列` : 文字列変数の値の末尾に、文字列を付け足します。
- `connect '接続パラメータ'` : 指定したサーバにSSHまたはTELNETで接続します。以下パラメータについての説明：
  - `ホスト名:ポート番号` : 第一引数。接続先のホスト名とポート番号を指定します。
  - `/ssh /2` : SSH2 で接続します。
  - `/auth=password` : 認証方法。パラメータは変えることができ、passwordはパスワード認証、publickeyは公開鍵認証、challengeはチャレンジレスポンス認証、pageantはPageantを使用した認証を使うことを表します。
- `wait 文字列1 [文字列2 ...]` : パラメータの文字列のうち、一つがホストから送られてくるか、タイムアウトするまでマクロを停止させます。
- `end` : マクロの実行そのものを終了します (`exit` は呼び出し元マクロファイルに戻るが、`end` は全ての後続のマクロ実行を終了する)

以上です。



### 参考

- [TTL コマンドリファレンス](https://ttssh2.osdn.jp/manual/4/ja/macro/command/index.html)
- [マクロ言語 "Tera Term Language (TTL)"](https://ttssh2.osdn.jp/manual/4/ja/macro/syntax/index.html)
