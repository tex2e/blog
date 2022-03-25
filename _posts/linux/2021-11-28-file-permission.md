---
layout:        post
title:         "Linuxで重要なファイルの権限を確認する"
menutitle:     "Linuxで重要なファイルの権限を確認する (shadow, ssh_key)"
date:          2021-11-28
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

Linux 環境での passwd や shadow、ssh_key などのファイルは適切に権限が設定されていないと、悪意のあるユーザに読み取り・書き込みされてしまいます。
ここでは、いくつかのLinuxで重要なファイルの権限を確認する方法を説明します。

#### passwd, shadow
passwd ファイルはroot以外書き込みできないようにします。
また、shadow ファイルにはユーザのパスワード情報が書かれているため、誰も閲覧できないようにします。
さらに、標準で生成される末尾に「-」が付いたバックアップファイルの権限も同じように設定します。
以下のコマンドで権限を確認します。
```bash
~]# ls -l /etc/passwd* /etc/shadow* /etc/gshadow*
----------. 1 root root 674  Oct 25 12:00 /etc/gshadow
----------. 1 root root 663  Oct 25 12:00 /etc/gshadow-
-rw-r--r--. 1 root root 2030 Oct 25 12:00 /etc/passwd
-rw-r--r--. 1 root root 1989 Oct 25 12:00 /etc/passwd-
----------. 1 root root 1368 Oct 25 12:00 /etc/shadow
----------. 1 root root 1236 Oct 25 12:00 /etc/shadow-
```
権限を修正するには、以下のコマンドを実行します。
```bash
~]# chown root:root /etc/passwd
~]# chmod u-x,go-wx /etc/passwd
~]# chown root:root /etc/passwd-
~]# chmod u-x,go-wx /etc/passwd-
~]# chown root:root /etc/shadow
~]# chmod 0000 /etc/shadow
~]# chown root:root /etc/shadow-
~]# chmod 0000 /etc/shadow-
```

#### group
group ファイルはroot以外書き込みできないようにします。
以下のコマンドで権限を確認します。
```bash
~]# ls -l /etc/group*
-rw-r--r--. 1 root root 837 Oct 25 12:00 /etc/group
-rw-r--r--. 1 root root 823 Oct 25 12:00 /etc/group-
```
権限を修正するには、以下のコマンドを実行します。
```bash
~]# chown root:root /etc/group
~]# chmod u-x,go-wx /etc/group
~]# chown root:root /etc/group-
~]# chmod u-x,go-wx /etc/group-
```

#### PATH
環境変数 PATH に含まれているパスが誰でも書き込みできると、悪意のあるユーザによく使うコマンド (lsなど) と同じ名前の実行ファイルを配置される可能性があります。
以下のコマンドで権限を確認します。
```bash
~]# ls -ld /usr/local/sbin/ /usr/local/bin/ /usr/sbin/ /usr/bin/
dr-xr-xr-x. 2 root root 36864 Oct 25 12:00 /usr/bin/
drwxr-xr-x. 2 root root     6 Oct 25 12:00 /usr/local/bin/
drwxr-xr-x. 2 root root     6 Oct 25 12:00 /usr/local/sbin/
dr-xr-xr-x. 2 root root 16384 Oct 22 12:00 /usr/sbin/
```
権限を修正するには、以下のコマンドを実行します。
```bash
~]# chown root:root /usr/local/sbin/
~]# chmod go-w /usr/local/sbin/
~]# chown root:root /usr/local/bin/
~]# chmod go-w /usr/local/bin/
~]# chown root:root /usr/sbin/
~]# chmod go-w /usr/sbin/
~]# chown root:root /usr/bin/
~]# chmod go-w /usr/bin/
```

#### /home/*
/home 以下の各ユーザのディレクトリは、各ユーザだけがアクセスできるように制限する必要があります。
以下のコマンドで権限を確認します。
```bash
~]# ls -l /home
drwx------. 2 user1 user1  83 Oct 25 12:00 user1
drwx------. 2 user2 user2  83 Oct 25 12:00 user2
drwx------. 2 user3 user3  62 Oct 25 12:00 user3
```
権限を修正するには、以下のコマンドを実行します。
```bash
~]# chown user1:user1 /home/user1
~]# chmod go-rwx /home/user1
```

#### cron
cronは定期的にコマンドやファイルを実行するための仕組みです。
cronが実行するファイルが誰でも書き込み可能の場合、悪意のあるユーザが対象ファイルを修正することで、悪意のあるファイルが実行されてしまいます。
cronが実行するファイルの権限を修正すべきですが、暫定の回避策としてcronの内容を隠すことで、侵入者による環境調査が困難になります。
cronはroot権限のユーザのみ閲覧可能にするには、以下のコマンドを実行します。
```bash
~]# chown root:root /etc/crontab
~]# chmod og-rwx /etc/crontab
~]# chown root:root /etc/cron.hourly
~]# chmod og-rwx /etc/cron.hourly
~]# chown root:root /etc/cron.daily
~]# chmod og-rwx /etc/cron.daily
~]# chown root:root /etc/cron.weekly
~]# chmod og-rwx /etc/cron.weekly
~]# chown root:root /etc/cron.monthly
~]# chmod og-rwx /etc/cron.monthly
~]# chown root:root /etc/cron.d
~]# chmod og-rwx /etc/cron.d
```

#### ssh秘密鍵
ssh秘密鍵が侵入者に読み取られた場合、sshログインに利用されてしまいます。
通常、秘密鍵は所有者本人しかアクセスできないようにします。
以下のコマンドで秘密鍵の権限が 0600 (-rw-------) であることを確認します。
```bash
~]# find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec ls -l {} \;
```
権限を修正するには、以下のコマンドを実行します。
```bash
~]# find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod u-x,g-wx,o-rwx {} \;
```

以上です。

#### 参考文献
- CIS CentOS Linux 8 Benchmark v1.0.1 - 6.1 System File Permissions

