---
layout:        post
title:         "ログインシェルが存在するユーザ一覧を表示する"
type:          How-To
description:   "/etc/passwdからログインシェルが有効なユーザをgrepで抽出し、不要アカウントをusermod -sで無効化する方法を説明します。"
tags:          [linux, user-management, hardening, ssh]
status:        stable
stale_after:   2025-03-13T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-25T13:04:38Z
date:          2021-12-06
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

ユーザのログインシェルが設定されているとSSHログインが可能になります。
サーバの堅牢化をするときは、これらのユーザが必要かどうかを精査し、SSHログインが不要なユーザやサービスアカウントはログインシェルを無効化する必要があります。

ログインシェルが設定されているユーザの一覧は以下のコマンドで表示できます。

```bash
~]# cat /etc/passwd | grep -v -e '/sbin/nologin$' -e '/bin/false$' -e '/s\?bin/sync$' -e '/sbin/shutdown$' -e '/sbin/halt$'

root:x:0:0:root:/root:/bin/bash
user01:x:1000:1000:user01:/home/user01:/bin/bash
test:x:1001:1001::/home/test:/bin/bash
```

出力を確認して、SSHログインが不要なユーザは usermod -s でログインシェルを無効化します。

```bash
~]# usermod -s /sbin/nologin ユーザ名
```

以上です。
