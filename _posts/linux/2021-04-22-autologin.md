---
layout:        post
title:         "Kali 2021.1 で起動時に自動ログイン"
date:          2021-04-22
category:      Linux
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

Kali 2021.1 (Ubuntu) で起動時にパスワードを入力するのが面倒なので、自動でログインできるようにします。

まず、Display Managerを確認します。

```bash
$ cat /etc/X11/default-display-manager
/usr/sbin/lightdm
```

lightdmを使っているので、/etc/lightdm/lightdm.conf の設定を以下のように修正します（ユーザ名は自分の使っているものを指定してください）。

```
[Seat:*]
autologin-user=kali
```

変更を適用するために再起動します。

```bash
reboot
```

起動時にログインパスワードを聞かれなければ成功です。

