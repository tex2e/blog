---
layout:        post
title:         "SELinuxのアクセス拒否の監査ログ(audit.log)の読み方"
date:          2021-11-24
category:      Linux
cover:         /assets/cover6.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

SELinuxがアクセス拒否した際の監査ログ (audit.log) の出力形式は以下のような形になっています。

```
avc:  denied  { operation } for pid=pid comm=comm path=opath dev=devno:ptno ino=ino scontext=scontext tcontext=tcontext tclass=tclass
```

それぞれの項目は以下の意味を持ちます。特に重要な部分は太字で強調しています。
- **operation** : 実行しようとした操作 (readやwriteなど)。以下は代表的な操作：
  - add_name : ディレクトリ内にファイルを追加する
  - append : ファイル末尾に追加して記述する (編集は不可)
  - getattr : ファイルなどに付与されている属性情報の取得ができる
  - link : ファイルのハードリンクを作成できる
  - name_bind : デーモンがポートを使用する
  - name_connect : デーモンが外部と通信する
  - read : ファイル内容を読みだす
  - remove_name : ディレクトリ内のファイル名を削除する
  - rename : ファイル名を変更する
  - rmdir : ディレクトリを削除する
  - search : ディレクトリ内を検索できる
  - transition : 新しいタイプ・ドメインに遷移する
  - write : ファイルに内容を書き込む
- pid : 操作を実行しようとしたプロセスのプロセスID
- **comm** : 操作を実行しようとしたコマンド名
- **path** : 操作の対象となるオブジェクトの絶対パス
- **name** : 操作の対象となるオブジェクトのファイル名
- devno : 操作の対象となるオブジェクトに対応するデバイスのブロックデバイス番号
- ptno : 操作の対象となるオブジェクトに対応するデバイスのパーティション番号 (基本的に省略)
- **ino** : 操作の対象となるオブジェクトのiノード番号 (find / -inum \<番号> でパス検索)
- **scontext** : 操作しようとしたプロセスのセキュリティコンテキスト
- **tcontext** : 操作の対象となるオブジェクトのセキュリティコンテキスト
- **tclass** : オブジェクトのクラス (fileやtcp_socketなど)。以下は代表的なクラス：
  - dir : ディレクトリ
  - file : ファイル
  - lnk_file : シンボリックリンク
  - tcp_socket : TCPソケット
  - udp_socket : UDPソケット

以上です。
