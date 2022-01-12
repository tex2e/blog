---
layout:        post
title:         "aptでdebのダウンロードと配置先の確認方法"
menutitle:     "aptでdebのダウンロードと配置先の確認方法 (apt --download-only, dpkg-deb -c)"
date:          2022-01-12
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

aptでdebファイルがインストール時にどこにファイルが配置されるかを確認するには、dpkg-deb コマンドを使います。
また、debファイルのみをダウンロードするには apt コマンドで --download-only オプションを指定します。
もし、既にインストール済みのパッケージのdebファイルを取得する場合は --reinstall オプションも指定します。

```bash
$ sudo apt install --reinstall --download-only apparmor-profiles
$ sudo dpkg-deb -c /var/cache/apt/archives/apparmor-profiles_*.deb

$ sudo apt install --reinstall --download-only apparmor-profiles-extra
$ sudo dpkg-deb -c /var/cache/apt/archives/apparmor-profiles-extra_*.deb
```

deb ファイルの中に含まれるファイルと配置先は、dpkg-deb -c コマンドで確認することができます。

```bash
$ sudo dpkg-deb -c /var/cache/apt/archives/apparmor-profiles-extra_*.deb
drwxr-xr-x root/root         0 2019-07-18 05:06 ./
drwxr-xr-x root/root         0 2019-07-18 05:06 ./etc/
drwxr-xr-x root/root         0 2019-07-18 05:06 ./etc/apparmor.d/
drwxr-xr-x root/root         0 2019-07-18 05:06 ./etc/apparmor.d/abstractions/
-rw-r--r-- root/root      1314 2019-07-18 05:06 ./etc/apparmor.d/abstractions/gstreamer
-rw-r--r-- root/root      2073 2019-07-18 05:06 ./etc/apparmor.d/abstractions/totem
drwxr-xr-x root/root         0 2019-07-18 05:06 ./etc/apparmor.d/local/
-rw-r--r-- root/root      1346 2019-07-18 05:06 ./etc/apparmor.d/usr.bin.irssi
-rw-r--r-- root/root      2613 2019-07-18 05:06 ./etc/apparmor.d/usr.bin.pidgin
-rw-r--r-- root/root      1483 2019-07-18 05:06 ./etc/apparmor.d/usr.bin.totem
-rw-r--r-- root/root      1220 2019-07-18 05:06 ./etc/apparmor.d/usr.bin.totem-previewers
-rw-r--r-- root/root       813 2019-07-18 05:06 ./etc/apparmor.d/usr.sbin.apt-cacher-ng
drwxr-xr-x root/root         0 2019-07-18 05:06 ./usr/
drwxr-xr-x root/root         0 2019-07-18 05:06 ./usr/share/
drwxr-xr-x root/root         0 2019-07-18 05:06 ./usr/share/doc/
drwxr-xr-x root/root         0 2019-07-18 05:06 ./usr/share/doc/apparmor-profiles-extra/
-rw-r--r-- root/root       618 2019-07-18 05:06 ./usr/share/doc/apparmor-profiles-extra/README.Debian
-rw-r--r-- root/root      1482 2019-07-18 05:06 ./usr/share/doc/apparmor-profiles-extra/changelog.gz
-rw-r--r-- root/root      1610 2019-07-18 05:06 ./usr/share/doc/apparmor-profiles-extra/copyright
```

以上です。
