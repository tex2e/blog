---
layout:        post
title:         "Webコンテンツの所有者・書き込み権限を確認する"
date:          2021-11-29
category:      Linux
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ドキュメントルート (DocumentRoot) 以下のファイルの所有者がrootになっているか確認します。
所有者をrootにしておけば、rootに権限昇格されない限り、改ざんされることはありません。
また、WebShellなどのバックドアも配置できなくなります。
ただし、Webのシステムによってはアップロードフォルダの権限は意図的に緩くする必要があります。
```bash
~]# find -L /var/www -not -user root -ls
```
権限を修正するには、以下のコマンドを実行します。
```bash
~]# chown root 対象パス
~]# chown -R root 対象パス
```

さらに、誰でも書き込むことができるディレクトリが存在するか確認します。
一般ユーザによる、WebShellなどのバックドアの配置を困難にする目的です。
```bash
~]# find -L /var/www -type d -perm /o=w -ls
```
権限を修正するには、以下のコマンドを実行します。
```bash
~]# chmod o-w 対象ディレクトリ
```

以上です。
