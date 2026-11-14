---
layout:        post
menutitle:     "ログインシェルを /sbin/nologin にしたユーザにログインする (su --shell=/bin/bash)"
title:         "ログインシェルを /sbin/nologin にしたユーザにログインする"
type:          How-To
description:   "ログインシェルが/sbin/nologinに設定されたユーザに対し、suコマンドの--shell=/bin/bashオプションでログインする方法を説明します。"
tags:          [linux, su, nologin, user-management]
status:        stable
stale_after:   2025-07-16T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-11T14:44:49Z
sources:
  - id:        ref-1
    resource:  https://qiita.com/riekure/items/27e07258a5a3ac4bd3fa
    title:     "ログインできないユーザでコマンドを実行する方法＋おまけ - Qiita"
  - id:        ref-2
    resource:  https://web.archive.org/web/20210125190926/https://www.kangetsu121.work/entry/2020/06/30/014759
    title:     "ユーザーのログインシェル: nologin と false 指定時の違い - 寒月記"
date:          2021-11-15
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

「usermod -s /sbin/nologin ユーザ名」を実行すると対象ユーザへの ssh や su によるログインができなくなります。

```bash
~]# cat /etc/passwd | grep postgres
postgres:x:26:26:PostgreSQL Server:/var/lib/pgsql:/bin/bash

~]# usermod -s /sbin/nologin postgres

~]# cat /etc/passwd | grep postgres
postgres:x:26:26:PostgreSQL Server:/var/lib/pgsql:/sbin/nologin

~]# su - postgres
This account is currently not available
```

ただし、場合によってはログインを禁止したユーザでコマンドを実行したい場合もあります。
そのときは su コマンドにオプション --shell=/bin/bash を追加して実行することでログインすることができます。

```bash
~]# su - postgres --shell=/bin/bash
-bash-4.1$ id
uid=26(postgres) gid=26(postgres) groups=26(postgres)
```

#### 参考文献
- [ログインできないユーザでコマンドを実行する方法＋おまけ - Qiita](https://qiita.com/riekure/items/27e07258a5a3ac4bd3fa)
- [ユーザーのログインシェル: nologin と false 指定時の違い - 寒月記](https://web.archive.org/web/20210125190926/https://www.kangetsu121.work/entry/2020/06/30/014759)
