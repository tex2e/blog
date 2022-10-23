---
layout:        post
title:         "CentOSでsemanageコマンドをインストールする"
date:          2021-12-13
category:      SELinux
cover:         /assets/cover6.jpg
redirect_from: /linux/install-semanage
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

policycoreutils-pythonパッケージには、semanageコマンドやaudit2allowコマンドなどのSELinuxの拒否ルールを修正するためによく使うコマンドが含まれています。
CentOSを最小インストールすると、コマンドが使えないので、yum / dnf でインストールします。

CentOS 7 でsemanageコマンドをインストールする場合：
```bash
~]# yum install policycoreutils-python
```
CentOS 8 や CentOS Stream 9 でsemanageコマンドをインストールする場合：
```bash
~]# dnf install policycoreutils-python-utils
```
以上です。

#### 参考文献
- [とほほのSELinux入門 - とほほのWWW入門](https://www.tohoho-web.com/ex/selinux.html)
