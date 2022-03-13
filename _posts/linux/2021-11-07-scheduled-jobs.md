---
layout:        post
title:         "Linuxでスケジュールされたジョブを確認する"
menutitle:     "Linuxでスケジュールされたジョブを確認する (cron, at)"
date:          2021-11-07
category:      Linux
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Linuxのシステムに意図しないスケジュールされたジョブが存在すると、時限爆弾のように予期しない動作が発生する可能性があります。
ここでは、スケジュールされたジョブを確認するときに見るべき場所について説明します。

#### 定期的に実行されるファイルの確認
ファイルを/etc/cron.hourly/などの下に配置すると定期的に実行されます。
```bash
~]# ls -alR /etc/cron* /var/spool/cron/crontabs /var/spool/anacron
```
- /etc/cron.hourly/: 毎時実行するファイルを置くディレクトリ
- /etc/cron.daily/: 毎日実行するファイルを置くディレクトリ (logrotateなど)
- /etc/cron.monthly/: 毎月実行するファイルを置くディレクトリ
- /etc/cron.weekly/: 毎週実行するファイルを置くディレクトリ
- /etc/cron.d/: 上記以外の自動実行に関する設定ファイル
- /var/spool/anacron/: anacron関連のファイル
- /var/spool/cron/crontabs/: anacron関連のファイル

#### 定期的に実行されるコマンドの確認
crontabの設定ファイルで指定したコマンドも確認する必要があります。
```bash
~]# cat /etc/cron* /etc/at* /etc/anacrontab /var/spool/cron/crontabs/* /etc/incron.d/* /var/spool/incron/* 2>/dev/null
```
- /etc/crontab : 詳細な実行時間の指定ができる設定ファイル

#### 各ユーザのcrontabで実行されるコマンドの確認
crontabは各ユーザ毎に分離されているので、全てのユーザでcrontabの登録内容を確認する必要があります。
`crontab -u ユーザ名 -l` で対象ユーザのcrontabを確認できるので、全ユーザを for 文で回してチェックします。
```bash
~]# for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l; done
```

root権限を持っている場合は、/var/spool/cron の中のファイルを確認しても良いです。
```bash
~]# ls /var/spool/cron
~]# cat /var/spool/cron/*
```

#### atでスケジュールされているジョブの確認
atコマンドには実行が一度切りのジョブが登録されています。
root権限で確認すれば全てのユーザのatでスケジュールされたジョブ一覧を確認することができます。
```bash
~]# atq
4       Thu Oct 30 10:59:00 2021 a tex2e
5       Thu Oct 30 11:00:00 2021 a root
```

root権限を持っている場合は、/var/spool/at の中のファイルを確認しても良いです。
/var/spool/at/* のファイルに実際に実行されるコマンドが書かれています。
```bash
~]# ls /var/spool/at
~]# cat /var/spool/at/*
```

---

#### atでスケジュールされたジョブの中身を確認する

atコマンドでスケジュールされたジョブの内容で、どんなコマンドが実行されるのかを確認する方法について説明します。

まずは、サンプルでジョブをスケジュールに登録します。
```bash
~]$ cat /home/tex2e/test.sh
#!/bin/bash

echo ok > /home/tex2e/test.txt

~]$ at 11:00 10302021 -f /home/tex2e/test.sh
~]$ atq
8       Sat Oct 30 11:00:00 2021 a tex2e
```
登録すると /var/spool/at の下に a000... ファイルが作成されます。
```bash
~]# ls /var/spool/at
a00006019fe678  spool
```
a000... ファイルの中身を確認すると、上で登録したジョブの内容がBashスクリプトとして保存されています。
時間になると、このスクリプトが実行されます。
```bash
~]# cat /var/spool/at/a00006019fe678
#!/bin/sh
umask 2
...省略...
SSH_CONNECTION=192.168.56.1\ 64710\ 192.168.56.102\ 22; export SSH_CONNECTION
LANG=C; export LANG
HISTCONTROL=ignoredups; export HISTCONTROL
HOSTNAME=localhost.localdomain; export HOSTNAME
XDG_SESSION_ID=3; export XDG_SESSION_ID
USER=tex2e; export USER
SELINUX_ROLE_REQUESTED=; export SELINUX_ROLE_REQUESTED
PWD=/home/tex2e; export PWD
HOME=/home/tex2e; export HOME
SSH_CLIENT=192.168.56.1\ 64710\ 22; export SSH_CLIENT
SELINUX_LEVEL_REQUESTED=; export SELINUX_LEVEL_REQUESTED
SSH_TTY=/dev/pts/1; export SSH_TTY
MAIL=/var/spool/mail/tex2e; export MAIL
SHELL=/bin/bash; export SHELL
SELINUX_USE_CURRENT_RANGE=; export SELINUX_USE_CURRENT_RANGE
SHLVL=1; export SHLVL
LOGNAME=tex2e; export LOGNAME
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus; export DBUS_SESSION_BUS_ADDRESS
XDG_RUNTIME_DIR=/run/user/1000; export XDG_RUNTIME_DIR
PATH=/home/tex2e/.local/bin:/home/tex2e/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin; export PATH
HISTSIZE=1000; export HISTSIZE
LESSOPEN=\|\|/usr/bin/lesspipe.sh\ %s; export LESSOPEN
cd /home/tex2e || {
         echo 'Execution directory inaccessible' >&2
         exit 1
}
${SHELL:-/bin/sh} << 'marcinDELIMITER02870cea'
#!/bin/bash

echo ok > /home/tex2e/test.txt

marcinDELIMITER02870cea
```
各種環境変数を設定した後に、`${SHELL:-/bin/sh}` の部分にヒアドキュメントで実行したいコマンドを入力しています。
上の例では `marcinDELIMITER02870cea` の間にある文字列が実行されます。

削除したい場合は、atq または at -l で番号を確認した後に、atrm または at -r で対象番号のジョブを削除します。
```bash
~]$ atq
8       Sat Oct 30 11:00:00 2021 a tex2e

~]$ atrm 8
~]$ atq
~]$
```

以上です。
