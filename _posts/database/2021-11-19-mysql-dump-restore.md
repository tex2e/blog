---
layout:        post
title:         "[MySQL] DBのダンプの作成とリストアの方法"
type:          How-To
description:   "mysqldumpとmysqlコマンドを用いて、MySQLの全データベース・指定データベース・指定テーブルをそれぞれバックアップ(ダンプ)しリストアする方法を紹介します。"
tags:          [database, mysql, mysqldump, backup, restore]
status:        stable
stale_after:   2027-07-21T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-18T12:42:34Z
date:          2021-11-19
category:      Database
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

MySQLでDBをダンプするには mysqldump コマンドを使用します。
このコマンドを利用すると、DBを0から作るための create 文や insert 文が作成されます。
リストアする際は、mysql コマンドでDBに接続してから、ダンプしたファイルを流し込むだけです。

全データベースのダンプとリストア：
```bash
~]$ mysqldump -u root -p -x --all-databases > db.dump
~]$ mysql -u root -p < db.dump
```

指定したデータベースのダンプとリストア：
```bash
~]$ mysqldump -u root -p -x DB名 > db.dump
~]$ mysql -u root -p DB名 < db.dump
```

指定したテーブルのダンプとリストア：
```bash
~]$ mysqldump -u root -p -x DB名 テーブル名 > db.dump
~]$ mysql -u root -p DB名 < db.dump
```

以上です。
