---
layout:        post
title:         "SELinuxのマニュアル(manページ)をインストールする"
menutitle:     "SELinuxのマニュアル(manページ)をインストールする"
date:          2022-01-22
category:      SELinux
cover:         /assets/cover6.jpg
redirect_from: /linux/selinux-manpage
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

httpd_selinuxのマニュアルを読むためには selinux-policy-doc パッケージをインストールします。
```bash
~]# yum install selinux-policy-doc
```

SELinuxのmanページは「対象の名前_selinux」で閲覧することができます。
例えば httpd に関する SELinux の内容を読みたい場合は「httpd_selinux」です。
```bash
~]$ man httpd_selinux
```

他にも、postgresql に関する SELinux のマニュアルは `man postgresql_selinux`、
SELinuxユーザ sysadm に関するマニュアルは `man sysadm_selinux` で読むことができます。

以上です。
