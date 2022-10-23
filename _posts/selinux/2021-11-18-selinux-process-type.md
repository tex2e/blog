---
layout:        post
title:         "Webやメールサーバのプロセスのドメイン"
date:          2021-11-18
category:      SELinux
cover:         /assets/cover6.jpg
redirect_from: /linux/selinux-process-type
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

各プロセスのSELinuxのタイプ (ドメイン) の一覧を以下に示します。
対象は sshd, httpd, named, postfix, dovecot, mysqld, docker です。

```bash
~]# ps -eZ | grep sshd
system_u:system_r:sshd_t:s0-s0:c0.c1023 893 ?    00:00:00 sshd

~]# ps -eZ | grep httpd
system_u:system_r:httpd_t:s0       1591 ?        00:00:03 php-fpm
system_u:system_r:httpd_t:s0       1975 ?        00:00:04 httpd

~]# ps -eZ | grep named
system_u:system_r:named_t:s0       2751 ?        00:00:00 named

~]# ps -eZ | grep postfix
system_u:system_r:postfix_master_t:s0 6972 ?     00:00:00 master
system_u:system_r:postfix_pickup_t:s0 6973 ?     00:00:00 pickup
system_u:system_r:postfix_qmgr_t:s0 6974 ?       00:00:00 qmgr

~]# ps -eZ | grep dovecot
system_u:system_r:dovecot_t:s0     7237 ?        00:00:00 dovecot
system_u:system_r:dovecot_t:s0     7239 ?        00:00:00 anvil
system_u:system_r:dovecot_t:s0     7240 ?        00:00:00 log
system_u:system_r:dovecot_t:s0     7241 ?        00:00:00 config

~]# ps -eZ | grep mysqld
system_u:system_r:mysqld_safe_t:s0 1178 ?        00:00:00 mysqld_safe
system_u:system_r:mysqld_t:s0      1280 ?        00:00:02 mysqld

~]# ps -eZ | grep docker
system_u:system_r:container_runtime_t:s0 78488 ? 00:00:03 dockerd
```

以上です。
