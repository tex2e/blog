---
layout:        post
title:         "Webコンテンツの所有者・書き込み権限を確認する"
type:          How-To
description:   "DocumentRoot配下のファイル所有者をrootへ統一し、その他ユーザに書き込み権限があるディレクトリをfindで検出・修正する方法を説明します。"
tags:          [linux, web-security, permissions, hardening]
status:        stable
stale_after:   2025-03-13T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-18T12:44:12Z
date:          2021-11-29
category:      Linux
cover:         /assets/cover14.jpg
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
