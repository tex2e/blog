---
layout:        post
title:         "SELinuxとauditdでハニーポットもどきを作る"
date:          2021-12-17
category:      Linux
cover:         /assets/cover6.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

SSHログインはできるがSELinuxで権限昇格できないように制限したユーザを作る方法と、auditdでそのユーザがログイン中にどんなコマンドを実行したのかログを収集する方法について説明します。

（この記事は私個人の想像に基づく設計なので安全性は保証しません。実環境で試すようなことはしないでください。）

まず、ユーザの作成とグループの割り当てをします。
今回は、ユーザ名が「user4」、Linuxの所属グループは「wheel」、SELinuxのユーザは「staff_u」とします。
staff_u はSELinux上で sudo や su が禁止されているユーザなので、権限昇格の行為はできないです。
```bash
~]# useradd user4
~]# passwd user4
~]# usermod -Z staff_u -aG wheel user4
```

セキュリティレベルを上げるために、SELinuxのブール値でファイル実行できないようにするなどの対策はしておきましょう。
```bash
~]# setsebool -P staff_exec_content off 
```

user4ユーザでログインして、所属グループとSELinuxコンテキストを確認します。
```bash
PS> ssh user4@192.168.56.104
user4@192.168.56.104's password:
~]$
~]$ id
uid=1006(user4) gid=1006(user4) groups=1006(user4),10(wheel) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023
```
監視したい対象ユーザのUIDが「1006」なので、auid (ログインユーザのID) に1006を指定して監査をします。

一時的に（システム再起動時に消える）監査ルールを追加する場合は以下のコマンドを実行します。
```bash
~]# auditctl -a exit,always -F auid=1006 -F arch=b64 -S execve
~]# auditctl -l   # 監査ルールの一覧を表示
~]# auditctl -D   # 監査ルールを一時的に削除する場合
```

永続的に（システム再起動時に消えない）監査ルールを追加する場合は、/etc/audit/audit.rules 以下に自分のルールを書いたファイルを配置します。
具体的には以下のコマンドを実行します。
```bash
~]# cat <<EOS > /etc/audit/rules.d/70-user4.rules
-a exit,always -F auid=1006 -F arch=b64 -S execve
EOS
~]# augenrules --load
~]# auditctl -l
```

補足：監査用のサンプルルール一覧は「/usr/share/audit/sample-rules/」にあるので、参考にすると良いです。

最後に、監査ログを監視対象のユーザに限定して検索するときは ausearch コマンドの --uid-all オプションで対象ユーザの UID を指定します。
監査ログは「sudo su -」で権限昇格しても auid=1006 が操作したというログが記録されるためです。
```bash
~]# ausearch -i --uid-all 1006
```

<br>

### 制限＆監視されているユーザで検証

仮にSSHログインで攻撃者が侵入したとして、以下のコマンドを実行したときに監査ログ (audit.log) にはどんなログが記録されるか確認します。

コマンド例：
```
id
ls -l /tmp
cat /etc/passwd
curl _example.com || wget -O - example.com
ping -c 1 1.1.1.1
echo >/dev/tcp/1.1.1.1/80 && echo ok
python -m SimpleHTTPServer
sudo su -
```

#### 実行コマンドの監査ログ

以下、tail -f /var/log/audit/audit.log で監視しながらuser4ユーザでコマンドを実行した時のログの様子です。

コマンド：`id`
```log
type=SYSCALL msg=audit(XXXXXXXXXX.428:235): arch=c000003e syscall=59 success=yes exit=0 a0=1b0ab00 a1=1afea90 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1828 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="id" exe="/usr/bin/id" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.428:235): argc=1 a0="id"
type=CWD msg=audit(XXXXXXXXXX.428:235):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.428:235): item=0 name="/usr/bin/id" inode=50490537 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.428:235): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.428:235): proctitle="id"
```

コマンド：`ls -a -l -Z -d /tmp`
```log
type=SYSCALL msg=audit(XXXXXXXXXX.538:243): arch=c000003e syscall=59 success=yes exit=0 a0=1b0b7f0 a1=1b0b040 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1859 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="ls" exe="/usr/bin/ls" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.538:243): argc=7 a0="ls" a1="--color=auto" a2="-a" a3="-l" a4="-Z" a5="-d" a6="/tmp"
type=CWD msg=audit(XXXXXXXXXX.538:243):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.538:243): item=0 name="/usr/bin/ls" inode=50490543 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.538:243): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.538:243): proctitle=6C73002D2D636F6C6F723D6175746F002D61002D6C002D5A002D64002F746D70
```

コマンド：`cat /etc/passwd`
```log
type=SYSCALL msg=audit(XXXXXXXXXX.235:237): arch=c000003e syscall=59 success=yes exit=0 a0=1afc910 a1=1afc0b0 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1831 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="cat" exe="/usr/bin/cat" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.235:237): argc=2 a0="cat" a1="/etc/passwd"
type=CWD msg=audit(XXXXXXXXXX.235:237):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.235:237): item=0 name="/usr/bin/cat" inode=50490509 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.235:237): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.235:237): proctitle=636174002F6574632F706173737764
```

コマンド：`curl _example.com || wget -O - example.com`
```log
type=SYSCALL msg=audit(XXXXXXXXXX.440:241): arch=c000003e syscall=59 success=yes exit=0 a0=1b0bc10 a1=1afc050 a2=1b05c30 a3=7ffd69fd6260 items=2 ppid=1808 pid=1856 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="curl" exe="/usr/bin/curl" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.440:241): argc=2 a0="curl" a1="_example.com"
type=CWD msg=audit(XXXXXXXXXX.440:241):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.440:241): item=0 name="/usr/bin/curl" inode=50535077 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.440:241): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.440:241): proctitle=6375726C005F6578616D706C652E636F6D
type=SYSCALL msg=audit(XXXXXXXXXX.706:242): arch=c000003e syscall=59 success=yes exit=0 a0=1b00080 a1=1b0a950 a2=1b05c30 a3=7ffd69fd6260 items=2 ppid=1808 pid=1858 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="wget" exe="/usr/bin/wget" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.706:242): argc=4 a0="wget" a1="-O" a2="-" a3="example.com"
type=CWD msg=audit(XXXXXXXXXX.706:242):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.706:242): item=0 name="/usr/bin/wget" inode=50702616 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.706:242): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.706:242): proctitle=77676574002D4F002D006578616D706C652E636F6D
```

コマンド：`ping -c 1 1.1.1.1`
```log
type=SYSCALL msg=audit(XXXXXXXXXX.195:244): arch=c000003e syscall=59 success=yes exit=0 a0=1afaab0 a1=1b0ab50 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1860 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="ping" exe="/usr/bin/ping" subj=staff_u:staff_r:ping_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.195:244): argc=4 a0="ping" a1="-c" a2="1" a3="1.1.1.1"
type=CWD msg=audit(XXXXXXXXXX.195:244):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.195:244): item=0 name="/usr/bin/ping" inode=50614866 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ping_exec_t:s0 objtype=NORMAL cap_fp=0000000000003000 cap_fi=0000000000000000 cap_fe=0 cap_fver=2
type=PATH msg=audit(XXXXXXXXXX.195:244): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.195:244): proctitle=70696E67002D63003100312E312E312E31
```

コマンド：`python -m SimpleHTTPServer`
```log
type=SYSCALL msg=audit(XXXXXXXXXX.176:247): arch=c000003e syscall=59 success=yes exit=0 a0=1afeb10 a1=1afd520 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1883 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="python" exe="/usr/bin/python2.7" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.176:247): argc=3 a0="python" a1="-m" a2="SimpleHTTPServer"
type=CWD msg=audit(XXXXXXXXXX.176:247):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.176:247): item=0 name="/usr/bin/python" inode=50518868 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.176:247): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.176:247): proctitle=707974686F6E002D6D0053696D706C6548545450536572766572
type=AVC msg=audit(XXXXXXXXXX.302:248): avc:  denied  { name_bind } for  pid=1883 comm="python" src=8000 scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=system_u:object_r:soundd_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(XXXXXXXXXX.302:248): arch=c000003e syscall=49 success=no exit=-13 a0=3 a1=7fff27c0e6a0 a2=10 a3=5 items=0 ppid=1808 pid=1883 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="python" exe="/usr/bin/python2.7" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=SOCKADDR msg=audit(XXXXXXXXXX.302:248): saddr=02001F40000000000000000000000000
type=PROCTITLE msg=audit(XXXXXXXXXX.302:248): proctitle=707974686F6E002D6D0053696D706C6548545450536572766572
```

コマンド：`chmod +x test.sh`
```log
type=SYSCALL msg=audit(XXXXXXXXXX.880:252): arch=c000003e syscall=59 success=yes exit=0 a0=1b0ba80 a1=1afab70 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1887 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="chmod" exe="/usr/bin/chmod" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.880:252): argc=3 a0="chmod" a1="+x" a2="test.sh"
type=CWD msg=audit(XXXXXXXXXX.880:252):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.880:252): item=0 name="/usr/bin/chmod" inode=50490512 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.880:252): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.880:252): proctitle=63686D6F64002B7800746573742E7368
```

ファイルの内容：
```bash
#!/bin/bash
touch hello.txt
```

コマンド：`./test.sh`
```log
type=SYSCALL msg=audit(XXXXXXXXXX.827:257): arch=c000003e syscall=59 success=yes exit=0 a0=1afcbc0 a1=1afc0b0 a2=1b05c30 a3=7ffd69fd63a0 items=3 ppid=1808 pid=1912 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="test.sh" exe="/usr/bin/bash" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.827:257): argc=2 a0="/bin/bash" a1="./test.sh"
type=CWD msg=audit(XXXXXXXXXX.827:257):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.827:257): item=0 name="./test.sh" inode=33580073 dev=fd:00 mode=0100775 ouid=1006 ogid=1006 rdev=00:00 obj=staff_u:object_r:user_home_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.827:257): item=1 name="/bin/bash" inode=50548532 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:shell_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.827:257): item=2 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.827:257): proctitle=2F62696E2F62617368002E2F746573742E7368
type=SYSCALL msg=audit(XXXXXXXXXX.832:258): arch=c000003e syscall=59 success=yes exit=0 a0=1a7a3d0 a1=1a7a6b0 a2=1a785c0 a3=7ffc7fc13c60 items=2 ppid=1912 pid=1913 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="touch" exe="/usr/bin/touch" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.832:258): argc=2 a0="touch" a1="hello.txt"
type=CWD msg=audit(XXXXXXXXXX.832:258):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.832:258): item=0 name="/usr/bin/touch" inode=50490590 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.832:258): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.832:258): proctitle=746F7563680068656C6C6F2E747874
```


SELinuxで拒否ルール `setsebool -P staff_exec_content off` を追加してからコマンド：`./test.sh`
```log
type=AVC msg=audit(XXXXXXXXXX.599:266): avc:  denied  { execute } for  pid=1949 comm="bash" name="test.sh" dev="dm-0" ino=33580073 scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=staff_u:object_r:user_home_t:s0 tclass=file permissive=0
type=SYSCALL msg=audit(XXXXXXXXXX.599:266): arch=c000003e syscall=59 success=no exit=-13 a0=1b02670 a1=1afbbd0 a2=1b05c30 a3=7ffd69fd63a0 items=1 ppid=1808 pid=1949 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="bash" exe="/usr/bin/bash" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=CWD msg=audit(XXXXXXXXXX.599:266):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.599:266): item=0 name="./test.sh" inode=33580073 dev=fd:00 mode=0100775 ouid=1006 ogid=1006 rdev=00:00 obj=staff_u:object_r:user_home_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.599:266): proctitle="-bash"
```

コマンド：`echo >/dev/tcp/1.1.1.1/80 && echo ok`
```log
auditログなし
```

コマンド：`sudo su -` (bash_profile や bashrc の内容なども実行されていると思われる)
```log
type=SYSCALL msg=audit(XXXXXXXXXX.954:304): arch=c000003e syscall=59 success=yes exit=0 a0=1afc0e0 a1=1afbff0 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=2089 auid=1006 uid=1006 gid=1006 euid=0 suid=0 fsuid=0 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="sudo" exe="/usr/bin/sudo" subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.954:304): argc=3 a0="sudo" a1="su" a2="-"
type=CWD msg=audit(XXXXXXXXXX.954:304):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.954:304): item=0 name="/usr/bin/sudo" inode=50740985 dev=fd:00 mode=0104111 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:sudo_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.954:304): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.954:304): proctitle=7375646F007375002D
type=SYSCALL msg=audit(XXXXXXXXXX.973:305): arch=c000003e syscall=59 success=yes exit=0 a0=7fd5dfd8b3ad a1=7ffda07ae3e0 a2=7fd5dff8e388 a3=2 items=2 ppid=2089 pid=2090 auid=1006 uid=0 gid=1006 euid=0 suid=0 fsuid=0 egid=1006 sgid=1006 fsgid=1006 tty=(none) ses=4 comm="unix_chkpwd" exe="/usr/sbin/unix_chkpwd" subj=staff_u:staff_r:chkpwd_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.973:305): argc=3 a0="/usr/sbin/unix_chkpwd" a1="user4" a2="chkexpiry"
type=CWD msg=audit(XXXXXXXXXX.973:305):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.973:305): item=0 name="/usr/sbin/unix_chkpwd" inode=205358 dev=fd:00 mode=0104755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:chkpwd_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.973:305): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.973:305): proctitle=2F7573722F7362696E2F756E69785F63686B7077640075736572340063686B657870697279
type=USER_ACCT msg=audit(XXXXXXXXXX.976:306): pid=2089 uid=1006 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:accounting grantors=pam_unix,pam_localuser acct="user4" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
type=USER_CMD msg=audit(XXXXXXXXXX.976:307): pid=2089 uid=1006 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='cwd="/home/user4" cmd=7375202D terminal=pts/1 res=success'
type=CRED_REFR msg=audit(XXXXXXXXXX.976:308): pid=2089 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_env,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
type=USER_START msg=audit(XXXXXXXXXX.981:309): pid=2089 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
type=SYSCALL msg=audit(XXXXXXXXXX.984:310): arch=c000003e syscall=59 success=yes exit=0 a0=564409b8a258 a1=564409b8b228 a2=564409b9f330 a3=0 items=2 ppid=2089 pid=2091 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="su" exe="/usr/bin/su" subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.984:310): argc=2 a0="su" a1="-"
type=CWD msg=audit(XXXXXXXXXX.984:310):  cwd="/home/user4"
type=PATH msg=audit(XXXXXXXXXX.984:310): item=0 name="/bin/su" inode=50613494 dev=fd:00 mode=0104755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:su_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.984:310): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.984:310): proctitle=7375002D
type=USER_AUTH msg=audit(XXXXXXXXXX.992:311): pid=2091 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:authentication grantors=pam_rootok acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/1 res=success'
type=USER_ACCT msg=audit(XXXXXXXXXX.993:312): pid=2091 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:accounting grantors=pam_succeed_if acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/1 res=success'
type=CRED_ACQ msg=audit(XXXXXXXXXX.993:313): pid=2091 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_rootok acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/1 res=success'
type=USER_START msg=audit(XXXXXXXXXY.002:314): pid=2091 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix,pam_xauth acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/1 res=success'
type=SYSCALL msg=audit(XXXXXXXXXY.006:315): arch=c000003e syscall=59 success=yes exit=0 a0=55ae507e6a40 a1=55ae507e7f70 a2=55ae507e7f20 a3=2 items=2 ppid=2091 pid=2092 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="bash" exe="/usr/bin/bash" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXY.006:315): argc=1 a0="-bash"
type=CWD msg=audit(XXXXXXXXXY.006:315):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXY.006:315): item=0 name="/bin/bash" inode=50548532 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:shell_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.006:315): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXY.006:315): proctitle="-bash"
type=SYSCALL msg=audit(XXXXXXXXXY.019:316): arch=c000003e syscall=59 success=yes exit=0 a0=b44ee0 a1=b453d0 a2=b420d0 a3=7ffc5fe42f20 items=2 ppid=2093 pid=2094 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="id" exe="/usr/bin/id" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXY.019:316): argc=2 a0="/usr/bin/id" a1="-un"
type=CWD msg=audit(XXXXXXXXXY.019:316):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXY.019:316): item=0 name="/usr/bin/id" inode=50490537 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.019:316): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXY.019:316): proctitle=2F7573722F62696E2F6964002D756E
type=SYSCALL msg=audit(XXXXXXXXXY.025:317): arch=c000003e syscall=59 success=yes exit=0 a0=b43700 a1=b43590 a2=b45760 a3=7ffc5fe434e0 items=2 ppid=2095 pid=2096 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="hostname" exe="/usr/bin/hostname" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXY.025:317): argc=1 a0="/usr/bin/hostname"
type=CWD msg=audit(XXXXXXXXXY.025:317):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXY.025:317): item=0 name="/usr/bin/hostname" inode=50341315 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:hostname_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.025:317): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXY.025:317): proctitle="/usr/bin/hostname"
type=SYSCALL msg=audit(XXXXXXXXXY.030:318): arch=c000003e syscall=59 success=yes exit=0 a0=b474a0 a1=b45510 a2=b45e20 a3=7ffc5fe43160 items=3 ppid=2092 pid=2097 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="grepconf.sh" exe="/usr/bin/bash" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXY.030:318): argc=3 a0="/bin/sh" a1="/usr/libexec/grepconf.sh" a2="-c"
type=CWD msg=audit(XXXXXXXXXY.030:318):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXY.030:318): item=0 name="/usr/libexec/grepconf.sh" inode=33686597 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.030:318): item=1 name="/bin/sh" inode=50548532 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:shell_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.030:318): item=2 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXY.030:318): proctitle=2F62696E2F7368002F7573722F6C6962657865632F67726570636F6E662E7368002D63
type=SYSCALL msg=audit(XXXXXXXXXY.035:319): arch=c000003e syscall=59 success=yes exit=0 a0=77dba0 a1=77c140 a2=77bc50 a3=7fffb327e2e0 items=2 ppid=2097 pid=2098 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="grep" exe="/usr/bin/grep" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXY.035:319): argc=4 a0="grep" a1="-qsi" a2="^COLOR.*none" a3="/etc/GREP_COLORS"
type=CWD msg=audit(XXXXXXXXXY.035:319):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXY.035:319): item=0 name="/bin/grep" inode=50340995 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.035:319): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXY.035:319): proctitle=67726570002D717369005E434F4C4F522E2A6E6F6E65002F6574632F475245505F434F4C4F5253
type=SYSCALL msg=audit(XXXXXXXXXY.039:320): arch=c000003e syscall=59 success=yes exit=0 a0=b4c190 a1=b4c370 a2=b45e20 a3=7ffc5fe420e0 items=2 ppid=2099 pid=2100 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="tty" exe="/usr/bin/tty" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXY.039:320): argc=2 a0="/usr/bin/tty" a1="-s"
type=CWD msg=audit(XXXXXXXXXY.039:320):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXY.039:320): item=0 name="/usr/bin/tty" inode=50490595 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.039:320): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXY.039:320): proctitle=2F7573722F62696E2F747479002D73
type=SYSCALL msg=audit(XXXXXXXXXY.045:321): arch=c000003e syscall=59 success=yes exit=0 a0=b4c290 a1=b4c330 a2=b45e20 a3=7ffc5fe420e0 items=2 ppid=2099 pid=2101 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="tput" exe="/usr/bin/tput" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXY.045:321): argc=2 a0="/usr/bin/tput" a1="colors"
type=CWD msg=audit(XXXXXXXXXY.045:321):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXY.045:321): item=0 name="/usr/bin/tput" inode=50490480 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.045:321): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXY.045:321): proctitle=2F7573722F62696E2F7470757400636F6C6F7273
type=SYSCALL msg=audit(XXXXXXXXXY.049:322): arch=c000003e syscall=59 success=yes exit=0 a0=b4b540 a1=b4b6f0 a2=b45e20 a3=7ffc5fe426e0 items=2 ppid=2102 pid=2103 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="dircolors" exe="/usr/bin/dircolors" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXY.049:322): argc=3 a0="/usr/bin/dircolors" a1="--sh" a2="/etc/DIR_COLORS.256color"
type=CWD msg=audit(XXXXXXXXXY.049:322):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXY.049:322): item=0 name="/usr/bin/dircolors" inode=50490523 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.049:322): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXY.049:322): proctitle=2F7573722F62696E2F646972636F6C6F7273002D2D7368002F6574632F4449525F434F4C4F52532E323536636F6C6F72
type=SYSCALL msg=audit(XXXXXXXXXY.053:323): arch=c000003e syscall=59 success=yes exit=0 a0=b4ae90 a1=b4b4e0 a2=b431b0 a3=7ffc5fe42f20 items=2 ppid=2092 pid=2104 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="grep" exe="/usr/bin/grep" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXY.053:323): argc=4 a0="/usr/bin/grep" a1="-qi" a2="^COLOR.*none" a3="/etc/DIR_COLORS.256color"
type=CWD msg=audit(XXXXXXXXXY.053:323):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXY.053:323): item=0 name="/usr/bin/grep" inode=50340995 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.053:323): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXY.053:323): proctitle=2F7573722F62696E2F67726570002D7169005E434F4C4F522E2A6E6F6E65002F6574632F4449525F434F4C4F52532E323536636F6C6F72
type=SYSCALL msg=audit(XXXXXXXXXY.060:324): arch=c000003e syscall=59 success=yes exit=0 a0=b43250 a1=b43300 a2=b4e120 a3=7ffc5fe425a0 items=2 ppid=2105 pid=2106 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="consoletype" exe="/usr/sbin/consoletype" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXY.060:324): argc=2 a0="/sbin/consoletype" a1="stdout"
type=CWD msg=audit(XXXXXXXXXY.060:324):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXY.060:324): item=0 name="/sbin/consoletype" inode=362246 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXY.060:324): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXY.060:324): proctitle=2F7362696E2F636F6E736F6C6574797065007374646F7574
```

user4 から root に権限昇格した後に、コマンド：`ls`
```log
type=SYSCALL msg=audit(XXXXXXXXXX.427:325): arch=c000003e syscall=59 success=yes exit=0 a0=b47090 a1=b43cb0 a2=b4e120 a3=7ffc5fe43d20 items=2 ppid=2092 pid=2108 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="ls" exe="/usr/bin/ls" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.427:325): argc=2 a0="ls" a1="--color=auto"
type=CWD msg=audit(XXXXXXXXXX.427:325):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXX.427:325): item=0 name="/bin/ls" inode=50490543 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.427:325): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.427:325): proctitle=6C73002D2D636F6C6F723D6175746F
```

user4 から root に権限昇格した後に、コマンド：`cat /etc/shadow`
```log
type=SYSCALL msg=audit(XXXXXXXXXX.193:330): arch=c000003e syscall=59 success=yes exit=0 a0=b43cb0 a1=b4a920 a2=b4e120 a3=7ffc5fe43d20 items=2 ppid=2092 pid=2132 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="cat" exe="/usr/bin/cat" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=EXECVE msg=audit(XXXXXXXXXX.193:330): argc=2 a0="cat" a1="/etc/shadow"
type=CWD msg=audit(XXXXXXXXXX.193:330):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXX.193:330): item=0 name="/bin/cat" inode=50490509 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.193:330): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.193:330): proctitle=636174002F6574632F736861646F77
type=AVC msg=audit(XXXXXXXXXX.194:331): avc:  denied  { dac_override } for  pid=2132 comm="cat" capability=1  scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tclass=capability permissive=0
type=AVC msg=audit(XXXXXXXXXX.194:331): avc:  denied  { dac_read_search } for  pid=2132 comm="cat" capability=2  scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tclass=capability permissive=0
type=SYSCALL msg=audit(XXXXXXXXXX.194:331): arch=c000003e syscall=2 success=no exit=-13 a0=7ffce19167e3 a1=0 a2=1fffffffffff0000 a3=7ffce1914260 items=1 ppid=2092 pid=2132 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="cat" exe="/usr/bin/cat" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=CWD msg=audit(XXXXXXXXXX.194:331):  cwd="/root"
type=PATH msg=audit(XXXXXXXXXX.194:331): item=0 name="/etc/shadow" inode=16778370 dev=fd:00 mode=0100000 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:shadow_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PROCTITLE msg=audit(XXXXXXXXXX.194:331): proctitle=636174002F6574632F736861646F77
```

#### 監査ログの検索

ausearchコマンドを使って、auidを指定して監査ログを検索するコマンド：
```bash
~]# ausearch --uid-all 1006
```

```log
----
time->Sat Dec  4 12:00:00 2021
type=LOGIN msg=audit(XXXXXXXXXX.309:2255): pid=7599 uid=0 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 old-auid=4294967295 auid=1006 tty=(none) old-ses=4294967295 ses=54 res=1
----
time->Sat Dec  4 12:00:00 2021
type=USER_ROLE_CHANGE msg=audit(XXXXXXXXXX.556:2256): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='pam: default-context=staff_u:staff_r:staff_t:s0-s0:c0.c1023 selected-context=staff_u:staff_r:staff_t:s0-s0:c0.c1023 exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=ssh res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_START msg=audit(XXXXXXXXXX.605:2257): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_selinux,pam_loginuid,pam_selinux,pam_namespace,pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix,pam_lastlog acct="user4" exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=ssh res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXX.608:2258): pid=7605 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:4f:19:3f:aa:68:e4:c1:e0:8e:db:3a:b4:54:69:86:09:55:bd:ae:fe:e3:7b:62:1e:64:03:3a:3e:6c:56:17:96 direction=? spid=7605 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXX.609:2259): pid=7605 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:10:4b:37:d3:53:e7:79:4b:6f:34:b5:21:27:bb:0e:e7:07:45:c3:7c:bf:dc:9b:89:c5:91:db:95:59:0f:22:b2 direction=? spid=7605 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXX.609:2260): pid=7605 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:4a:cc:58:05:d4:a0:2f:f8:f0:95:19:85:01:39:0c:d5:a8:15:01:d6:a1:20:cc:3a:6c:58:d5:bc:e6:39:57:44 direction=? spid=7605 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRED_ACQ msg=audit(XXXXXXXXXX.610:2261): pid=7605 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_unix acct="user4" exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=ssh res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_LOGIN msg=audit(XXXXXXXXXX.660:2262): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=1006 exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=/dev/pts/0 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_START msg=audit(XXXXXXXXXX.661:2263): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=1006 exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=/dev/pts/0 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXX.676:2264): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:4a:cc:58:05:d4:a0:2f:f8:f0:95:19:85:01:39:0c:d5:a8:15:01:d6:a1:20:cc:3a:6c:58:d5:bc:e6:39:57:44 direction=? spid=7606 suid=1006  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_END msg=audit(XXXXXXXXXY.576:2339): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=PAM:session_close grantors=pam_selinux,pam_loginuid,pam_selinux,pam_namespace,pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix,pam_lastlog acct="user4" exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=ssh res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRED_DISP msg=audit(XXXXXXXXXY.576:2340): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_unix acct="user4" exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=ssh res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_END msg=audit(XXXXXXXXXY.578:2341): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=1006 exe="/usr/sbin/sshd" hostname=? addr=? terminal=/dev/pts/0 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_LOGOUT msg=audit(XXXXXXXXXY.578:2342): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=1006 exe="/usr/sbin/sshd" hostname=? addr=? terminal=/dev/pts/0 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXY.578:2343): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:4f:19:3f:aa:68:e4:c1:e0:8e:db:3a:b4:54:69:86:09:55:bd:ae:fe:e3:7b:62:1e:64:03:3a:3e:6c:56:17:96 direction=? spid=7599 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXY.578:2344): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:10:4b:37:d3:53:e7:79:4b:6f:34:b5:21:27:bb:0e:e7:07:45:c3:7c:bf:dc:9b:89:c5:91:db:95:59:0f:22:b2 direction=? spid=7599 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXY.578:2345): pid=7599 uid=0 auid=1006 ses=54 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:4a:cc:58:05:d4:a0:2f:f8:f0:95:19:85:01:39:0c:d5:a8:15:01:d6:a1:20:cc:3a:6c:58:d5:bc:e6:39:57:44 direction=? spid=7599 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=LOGIN msg=audit(XXXXXXXXXZ.509:212): pid=1803 uid=0 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 old-auid=4294967295 auid=1006 tty=(none) old-ses=4294967295 ses=4 res=1
----
time->Sat Dec  4 12:00:00 2021
type=USER_ROLE_CHANGE msg=audit(XXXXXXXXXZ.802:213): pid=1803 uid=0 auid=1006 ses=4 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='pam: default-context=staff_u:staff_r:staff_t:s0-s0:c0.c1023 selected-context=staff_u:staff_r:staff_t:s0-s0:c0.c1023 exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=ssh res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_START msg=audit(XXXXXXXXXZ.859:214): pid=1803 uid=0 auid=1006 ses=4 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_selinux,pam_loginuid,pam_selinux,pam_namespace,pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix,pam_lastlog acct="user4" exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=ssh res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXZ.864:215): pid=1807 uid=0 auid=1006 ses=4 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:4f:19:3f:aa:68:e4:c1:e0:8e:db:3a:b4:54:69:86:09:55:bd:ae:fe:e3:7b:62:1e:64:03:3a:3e:6c:56:17:96 direction=? spid=1807 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXZ.864:216): pid=1807 uid=0 auid=1006 ses=4 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:10:4b:37:d3:53:e7:79:4b:6f:34:b5:21:27:bb:0e:e7:07:45:c3:7c:bf:dc:9b:89:c5:91:db:95:59:0f:22:b2 direction=? spid=1807 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXZ.864:217): pid=1807 uid=0 auid=1006 ses=4 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:4a:cc:58:05:d4:a0:2f:f8:f0:95:19:85:01:39:0c:d5:a8:15:01:d6:a1:20:cc:3a:6c:58:d5:bc:e6:39:57:44 direction=? spid=1807 suid=0  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRED_ACQ msg=audit(XXXXXXXXXZ.866:218): pid=1807 uid=0 auid=1006 ses=4 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_unix acct="user4" exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=ssh res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_LOGIN msg=audit(XXXXXXXXXZ.914:219): pid=1803 uid=0 auid=1006 ses=4 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=1006 exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_START msg=audit(XXXXXXXXXZ.915:220): pid=1803 uid=0 auid=1006 ses=4 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=1006 exe="/usr/sbin/sshd" hostname=192.168.56.1 addr=192.168.56.1 terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXZ.923:221): proctitle="-bash"
type=PATH msg=audit(XXXXXXXXXZ.923:221): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXZ.923:221): item=0 name="/bin/bash" inode=50548532 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:shell_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXZ.923:221):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXZ.923:221): argc=1 a0="-bash"
type=SYSCALL msg=audit(XXXXXXXXXZ.923:221): arch=c000003e syscall=59 success=yes exit=0 a0=557863c5c5e0 a1=7ffe4811c2c0 a2=557863c61240 a3=8 items=2 ppid=1807 pid=1808 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="bash" exe="/usr/bin/bash" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=CRYPTO_KEY_USER msg=audit(XXXXXXXXXZ.931:222): pid=1803 uid=0 auid=1006 ses=4 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=destroy kind=server fp=SHA256:4a:cc:58:05:d4:a0:2f:f8:f0:95:19:85:01:39:0c:d5:a8:15:01:d6:a1:20:cc:3a:6c:58:d5:bc:e6:39:57:44 direction=? spid=1808 suid=1006  exe="/usr/sbin/sshd" hostname=? addr=? terminal=? res=success'
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.936:223): proctitle=2F7573722F62696E2F6964002D756E
type=PATH msg=audit(XXXXXXXXXX.936:223): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.936:223): item=0 name="/usr/bin/id" inode=50490537 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.936:223):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.936:223): argc=2 a0="/usr/bin/id" a1="-un"
type=SYSCALL msg=audit(XXXXXXXXXX.936:223): arch=c000003e syscall=59 success=yes exit=0 a0=1afc820 a1=1afcd10 a2=1af98a0 a3=7ffd69fd55a0 items=2 ppid=1809 pid=1810 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="id" exe="/usr/bin/id" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.047:234): proctitle=6C73002D2D636F6C6F723D6175746F
type=PATH msg=audit(XXXXXXXXXX.047:234): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.047:234): item=0 name="/usr/bin/ls" inode=50490543 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.047:234):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.047:234): argc=2 a0="ls" a1="--color=auto"
type=SYSCALL msg=audit(XXXXXXXXXX.047:234): arch=c000003e syscall=59 success=yes exit=0 a0=1b003a0 a1=1af9ec0 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1827 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="ls" exe="/usr/bin/ls" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.235:237): proctitle=636174002F6574632F706173737764
type=PATH msg=audit(XXXXXXXXXX.235:237): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.235:237): item=0 name="/usr/bin/cat" inode=50490509 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.235:237):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.235:237): argc=2 a0="cat" a1="/etc/passwd"
type=SYSCALL msg=audit(XXXXXXXXXX.235:237): arch=c000003e syscall=59 success=yes exit=0 a0=1afc910 a1=1afc0b0 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1831 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="cat" exe="/usr/bin/cat" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.270:240): proctitle=6375726C006578616D706C652E636F6D
type=PATH msg=audit(XXXXXXXXXX.270:240): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.270:240): item=0 name="/usr/bin/curl" inode=50535077 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.270:240):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.270:240): argc=2 a0="curl" a1="example.com"
type=SYSCALL msg=audit(XXXXXXXXXX.270:240): arch=c000003e syscall=59 success=yes exit=0 a0=1b00000 a1=1af9ec0 a2=1b05c30 a3=7ffd69fd6260 items=2 ppid=1808 pid=1854 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="curl" exe="/usr/bin/curl" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.440:241): proctitle=6375726C005F6578616D706C652E636F6D
type=PATH msg=audit(XXXXXXXXXX.440:241): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.440:241): item=0 name="/usr/bin/curl" inode=50535077 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.440:241):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.440:241): argc=2 a0="curl" a1="_example.com"
type=SYSCALL msg=audit(XXXXXXXXXX.440:241): arch=c000003e syscall=59 success=yes exit=0 a0=1b0bc10 a1=1afc050 a2=1b05c30 a3=7ffd69fd6260 items=2 ppid=1808 pid=1856 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="curl" exe="/usr/bin/curl" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.195:244): proctitle=70696E67002D63003100312E312E312E31
type=PATH msg=audit(XXXXXXXXXX.195:244): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.195:244): item=0 name="/usr/bin/ping" inode=50614866 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ping_exec_t:s0 objtype=NORMAL cap_fp=0000000000003000 cap_fi=0000000000000000 cap_fe=0 cap_fver=2
type=CWD msg=audit(XXXXXXXXXX.195:244):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.195:244): argc=4 a0="ping" a1="-c" a2="1" a3="1.1.1.1"
type=SYSCALL msg=audit(XXXXXXXXXX.195:244): arch=c000003e syscall=59 success=yes exit=0 a0=1afaab0 a1=1b0ab50 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1860 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="ping" exe="/usr/bin/ping" subj=staff_u:staff_r:ping_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.176:247): proctitle=707974686F6E002D6D0053696D706C6548545450536572766572
type=PATH msg=audit(XXXXXXXXXX.176:247): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.176:247): item=0 name="/usr/bin/python" inode=50518868 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.176:247):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.176:247): argc=3 a0="python" a1="-m" a2="SimpleHTTPServer"
type=SYSCALL msg=audit(XXXXXXXXXX.176:247): arch=c000003e syscall=59 success=yes exit=0 a0=1afeb10 a1=1afd520 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1883 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="python" exe="/usr/bin/python2.7" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.302:248): proctitle=707974686F6E002D6D0053696D706C6548545450536572766572
type=SOCKADDR msg=audit(XXXXXXXXXX.302:248): saddr=02001F40000000000000000000000000
type=SYSCALL msg=audit(XXXXXXXXXX.302:248): arch=c000003e syscall=49 success=no exit=-13 a0=3 a1=7fff27c0e6a0 a2=10 a3=5 items=0 ppid=1808 pid=1883 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="python" exe="/usr/bin/python2.7" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=AVC msg=audit(XXXXXXXXXX.302:248): avc:  denied  { name_bind } for  pid=1883 comm="python" src=8000 scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=system_u:object_r:soundd_port_t:s0 tclass=tcp_socket permissive=0
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.104:250): proctitle="cat"
type=PATH msg=audit(XXXXXXXXXX.104:250): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.104:250): item=0 name="/usr/bin/cat" inode=50490509 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.104:250):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.104:250): argc=1 a0="cat"
type=SYSCALL msg=audit(XXXXXXXXXX.104:250): arch=c000003e syscall=59 success=yes exit=0 a0=1b0ba40 a1=1afaaf0 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1885 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="cat" exe="/usr/bin/cat" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.639:251): proctitle=63617400746573742E7368
type=PATH msg=audit(XXXXXXXXXX.639:251): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.639:251): item=0 name="/usr/bin/cat" inode=50490509 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.639:251):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.639:251): argc=2 a0="cat" a1="test.sh"
type=SYSCALL msg=audit(XXXXXXXXXX.639:251): arch=c000003e syscall=59 success=yes exit=0 a0=1b0ba60 a1=1af9a50 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1886 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="cat" exe="/usr/bin/cat" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.880:252): proctitle=63686D6F64002B7800746573742E7368
type=PATH msg=audit(XXXXXXXXXX.880:252): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.880:252): item=0 name="/usr/bin/chmod" inode=50490512 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.880:252):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.880:252): argc=3 a0="chmod" a1="+x" a2="test.sh"
type=SYSCALL msg=audit(XXXXXXXXXX.880:252): arch=c000003e syscall=59 success=yes exit=0 a0=1b0ba80 a1=1afab70 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=1887 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="chmod" exe="/usr/bin/chmod" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.300:253): proctitle=2F62696E2F62617368002E2F746573742E7368
type=PATH msg=audit(XXXXXXXXXX.300:253): item=2 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.300:253): item=1 name="/bin/bash" inode=50548532 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:shell_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.300:253): item=0 name="./test.sh" inode=33580073 dev=fd:00 mode=0100775 ouid=1006 ogid=1006 rdev=00:00 obj=staff_u:object_r:user_home_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.300:253):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.300:253): argc=2 a0="/bin/bash" a1="./test.sh"
type=SYSCALL msg=audit(XXXXXXXXXX.300:253): arch=c000003e syscall=59 success=yes exit=0 a0=1afb310 a1=1afbe50 a2=1b05c30 a3=7ffd69fd63a0 items=3 ppid=1808 pid=1888 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="test.sh" exe="/usr/bin/bash" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.832:258): proctitle=746F7563680068656C6C6F2E747874
type=PATH msg=audit(XXXXXXXXXX.832:258): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.832:258): item=0 name="/usr/bin/touch" inode=50490590 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.832:258):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.832:258): argc=2 a0="touch" a1="hello.txt"
type=SYSCALL msg=audit(XXXXXXXXXX.832:258): arch=c000003e syscall=59 success=yes exit=0 a0=1a7a3d0 a1=1a7a6b0 a2=1a785c0 a3=7ffc7fc13c60 items=2 ppid=1912 pid=1913 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="touch" exe="/usr/bin/touch" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.892:264): proctitle="-bash"
type=PATH msg=audit(XXXXXXXXXX.892:264): item=0 name="./test.sh" inode=33580073 dev=fd:00 mode=0100775 ouid=1006 ogid=1006 rdev=00:00 obj=staff_u:object_r:user_home_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.892:264):  cwd="/home/user4"
type=SYSCALL msg=audit(XXXXXXXXXX.892:264): arch=c000003e syscall=59 success=no exit=-13 a0=1b0b210 a1=1afc0e0 a2=1b05c30 a3=7ffd69fd63a0 items=1 ppid=1808 pid=1946 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="bash" exe="/usr/bin/bash" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=AVC msg=audit(XXXXXXXXXX.892:264): avc:  denied  { execute } for  pid=1946 comm="bash" name="test.sh" dev="dm-0" ino=33580073 scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=staff_u:object_r:user_home_t:s0 tclass=file permissive=0
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.599:266): proctitle="-bash"
type=PATH msg=audit(XXXXXXXXXX.599:266): item=0 name="./test.sh" inode=33580073 dev=fd:00 mode=0100775 ouid=1006 ogid=1006 rdev=00:00 obj=staff_u:object_r:user_home_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.599:266):  cwd="/home/user4"
type=SYSCALL msg=audit(XXXXXXXXXX.599:266): arch=c000003e syscall=59 success=no exit=-13 a0=1b02670 a1=1afbbd0 a2=1b05c30 a3=7ffd69fd63a0 items=1 ppid=1808 pid=1949 auid=1006 uid=1006 gid=1006 euid=1006 suid=1006 fsuid=1006 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="bash" exe="/usr/bin/bash" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=AVC msg=audit(XXXXXXXXXX.599:266): avc:  denied  { execute } for  pid=1949 comm="bash" name="test.sh" dev="dm-0" ino=33580073 scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=staff_u:object_r:user_home_t:s0 tclass=file permissive=0
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.007:275): proctitle=7375646F0073797374656D63746C00737461747573006874747064
type=PATH msg=audit(XXXXXXXXXX.007:275): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.007:275): item=0 name="/usr/bin/sudo" inode=50740985 dev=fd:00 mode=0104111 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:sudo_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.007:275):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.007:275): argc=4 a0="sudo" a1="systemctl" a2="status" a3="httpd"
type=SYSCALL msg=audit(XXXXXXXXXX.007:275): arch=c000003e syscall=59 success=yes exit=0 a0=1afd760 a1=1af9c50 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=2059 auid=1006 uid=1006 gid=1006 euid=0 suid=0 fsuid=0 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="sudo" exe="/usr/bin/sudo" subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.048:276): proctitle=2F7573722F7362696E2F756E69785F63686B707764007573657234006E756C6C6F6B
type=PATH msg=audit(XXXXXXXXXX.048:276): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.048:276): item=0 name="/usr/sbin/unix_chkpwd" inode=205358 dev=fd:00 mode=0104755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:chkpwd_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.048:276):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.048:276): argc=3 a0="/usr/sbin/unix_chkpwd" a1="user4" a2="nullok"
type=SYSCALL msg=audit(XXXXXXXXXX.048:276): arch=c000003e syscall=59 success=yes exit=0 a0=7f9919a843ad a1=7ffeee5c2a50 a2=7f9919c8b3c0 a3=2 items=2 ppid=2059 pid=2060 auid=1006 uid=0 gid=1006 euid=0 suid=0 fsuid=0 egid=1006 sgid=1006 fsgid=1006 tty=(none) ses=4 comm="unix_chkpwd" exe="/usr/sbin/unix_chkpwd" subj=staff_u:staff_r:chkpwd_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.658:277): proctitle=2F7573722F7362696E2F756E69785F63686B707764007573657234006E756C6C6F6B
type=PATH msg=audit(XXXXXXXXXX.658:277): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.658:277): item=0 name="/usr/sbin/unix_chkpwd" inode=205358 dev=fd:00 mode=0104755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:chkpwd_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.658:277):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.658:277): argc=3 a0="/usr/sbin/unix_chkpwd" a1="user4" a2="nullok"
type=SYSCALL msg=audit(XXXXXXXXXX.658:277): arch=c000003e syscall=59 success=yes exit=0 a0=7f9919a843ad a1=7ffeee5c29f0 a2=7f9919c8b3c0 a3=2 items=2 ppid=2059 pid=2061 auid=1006 uid=0 gid=1006 euid=0 suid=0 fsuid=0 egid=1006 sgid=1006 fsgid=1006 tty=(none) ses=4 comm="unix_chkpwd" exe="/usr/sbin/unix_chkpwd" subj=staff_u:staff_r:chkpwd_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=USER_AUTH msg=audit(XXXXXXXXXX.689:278): pid=2059 uid=1006 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:authentication grantors=pam_unix acct="user4" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.694:279): proctitle=2F7573722F7362696E2F756E69785F63686B7077640075736572340063686B657870697279
type=PATH msg=audit(XXXXXXXXXX.694:279): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.694:279): item=0 name="/usr/sbin/unix_chkpwd" inode=205358 dev=fd:00 mode=0104755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:chkpwd_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.694:279):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.694:279): argc=3 a0="/usr/sbin/unix_chkpwd" a1="user4" a2="chkexpiry"
type=SYSCALL msg=audit(XXXXXXXXXX.694:279): arch=c000003e syscall=59 success=yes exit=0 a0=7f9919a843ad a1=7ffeee5c2be0 a2=7f9919c87388 a3=2 items=2 ppid=2059 pid=2062 auid=1006 uid=0 gid=1006 euid=0 suid=0 fsuid=0 egid=1006 sgid=1006 fsgid=1006 tty=(none) ses=4 comm="unix_chkpwd" exe="/usr/sbin/unix_chkpwd" subj=staff_u:staff_r:chkpwd_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=USER_ACCT msg=audit(XXXXXXXXXX.698:280): pid=2059 uid=1006 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:accounting grantors=pam_unix,pam_localuser acct="user4" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_CMD msg=audit(XXXXXXXXXX.699:281): pid=2059 uid=1006 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='cwd="/home/user4" cmd=73797374656D63746C20737461747573206874747064 terminal=pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRED_REFR msg=audit(XXXXXXXXXX.700:282): pid=2059 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_START msg=audit(XXXXXXXXXX.719:283): pid=2059 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.722:284): proctitle=73797374656D63746C00737461747573006874747064
type=PATH msg=audit(XXXXXXXXXX.722:284): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.722:284): item=0 name="/bin/systemctl" inode=50613653 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:systemd_systemctl_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.722:284):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.722:284): argc=3 a0="systemctl" a1="status" a2="httpd"
type=SYSCALL msg=audit(XXXXXXXXXX.722:284): arch=c000003e syscall=59 success=yes exit=0 a0=5578a35a3258 a1=5578a35a4228 a2=5578a35b8cd0 a3=0 items=2 ppid=2059 pid=2063 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="systemctl" exe="/usr/bin/systemctl" subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.726:285): proctitle=73797374656D63746C00737461747573006874747064
type=PATH msg=audit(XXXXXXXXXX.726:285): item=0 name="/proc/1/root" objtype=UNKNOWN cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.726:285):  cwd="/home/user4"
type=SYSCALL msg=audit(XXXXXXXXXX.726:285): arch=c000003e syscall=4 success=no exit=-13 a0=556f1aa97b9d a1=7fff7d169020 a2=7fff7d169020 a3=1 items=1 ppid=2059 pid=2063 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="systemctl" exe="/usr/bin/systemctl" subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 key=(null)
type=AVC msg=audit(XXXXXXXXXX.726:285): avc:  denied  { search } for  pid=2063 comm="systemctl" name="1" dev="proc" ino=7192 scontext=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 tcontext=system_u:system_r:init_t:s0 tclass=dir permissive=0
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.727:286): proctitle=73797374656D63746C00737461747573006874747064
type=PATH msg=audit(XXXXXXXXXX.727:286): item=0 name="/proc/1/root" objtype=UNKNOWN cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.727:286):  cwd="/home/user4"
type=SYSCALL msg=audit(XXXXXXXXXX.727:286): arch=c000003e syscall=4 success=no exit=-13 a0=556f1aa97b9d a1=7fff7d169010 a2=7fff7d169010 a3=1 items=1 ppid=2059 pid=2063 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="systemctl" exe="/usr/bin/systemctl" subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 key=(null)
type=AVC msg=audit(XXXXXXXXXX.727:286): avc:  denied  { search } for  pid=2063 comm="systemctl" name="1" dev="proc" ino=7192 scontext=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 tcontext=system_u:system_r:init_t:s0 tclass=dir permissive=0
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.727:287): proctitle=73797374656D63746C00737461747573006874747064
type=PATH msg=audit(XXXXXXXXXX.727:287): item=0 name="/proc/1/root" objtype=UNKNOWN cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.727:287):  cwd="/home/user4"
type=SYSCALL msg=audit(XXXXXXXXXX.727:287): arch=c000003e syscall=4 success=no exit=-13 a0=556f1aa97b9d a1=7fff7d169020 a2=7fff7d169020 a3=7f2066eca9d0 items=1 ppid=2059 pid=2063 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="systemctl" exe="/usr/bin/systemctl" subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 key=(null)
type=AVC msg=audit(XXXXXXXXXX.727:287): avc:  denied  { search } for  pid=2063 comm="systemctl" name="1" dev="proc" ino=7192 scontext=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 tcontext=system_u:system_r:init_t:s0 tclass=dir permissive=0
----
time->Sat Dec  4 12:00:00 2021
type=USER_END msg=audit(XXXXXXXXXX.728:288): pid=2059 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:session_close grantors=pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_END msg=audit(XXXXXXXXXX.723:302): pid=2086 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:session_close grantors=pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRED_DISP msg=audit(XXXXXXXXXX.723:303): pid=2086 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_env,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.954:304): proctitle=7375646F007375002D
type=PATH msg=audit(XXXXXXXXXX.954:304): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.954:304): item=0 name="/usr/bin/sudo" inode=50740985 dev=fd:00 mode=0104111 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:sudo_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.954:304):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.954:304): argc=3 a0="sudo" a1="su" a2="-"
type=SYSCALL msg=audit(XXXXXXXXXX.954:304): arch=c000003e syscall=59 success=yes exit=0 a0=1afc0e0 a1=1afbff0 a2=1b05c30 a3=7ffd69fd63a0 items=2 ppid=1808 pid=2089 auid=1006 uid=1006 gid=1006 euid=0 suid=0 fsuid=0 egid=1006 sgid=1006 fsgid=1006 tty=pts1 ses=4 comm="sudo" exe="/usr/bin/sudo" subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.973:305): proctitle=2F7573722F7362696E2F756E69785F63686B7077640075736572340063686B657870697279
type=PATH msg=audit(XXXXXXXXXX.973:305): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.973:305): item=0 name="/usr/sbin/unix_chkpwd" inode=205358 dev=fd:00 mode=0104755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:chkpwd_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.973:305):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.973:305): argc=3 a0="/usr/sbin/unix_chkpwd" a1="user4" a2="chkexpiry"
type=SYSCALL msg=audit(XXXXXXXXXX.973:305): arch=c000003e syscall=59 success=yes exit=0 a0=7fd5dfd8b3ad a1=7ffda07ae3e0 a2=7fd5dff8e388 a3=2 items=2 ppid=2089 pid=2090 auid=1006 uid=0 gid=1006 euid=0 suid=0 fsuid=0 egid=1006 sgid=1006 fsgid=1006 tty=(none) ses=4 comm="unix_chkpwd" exe="/usr/sbin/unix_chkpwd" subj=staff_u:staff_r:chkpwd_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=USER_ACCT msg=audit(XXXXXXXXXX.976:306): pid=2089 uid=1006 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:accounting grantors=pam_unix,pam_localuser acct="user4" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_CMD msg=audit(XXXXXXXXXX.976:307): pid=2089 uid=1006 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='cwd="/home/user4" cmd=7375202D terminal=pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRED_REFR msg=audit(XXXXXXXXXX.976:308): pid=2089 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_env,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_START msg=audit(XXXXXXXXXX.981:309): pid=2089 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.984:310): proctitle=7375002D
type=PATH msg=audit(XXXXXXXXXX.984:310): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.984:310): item=0 name="/bin/su" inode=50613494 dev=fd:00 mode=0104755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:su_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.984:310):  cwd="/home/user4"
type=EXECVE msg=audit(XXXXXXXXXX.984:310): argc=2 a0="su" a1="-"
type=SYSCALL msg=audit(XXXXXXXXXX.984:310): arch=c000003e syscall=59 success=yes exit=0 a0=564409b8a258 a1=564409b8b228 a2=564409b9f330 a3=0 items=2 ppid=2089 pid=2091 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="su" exe="/usr/bin/su" subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=USER_AUTH msg=audit(XXXXXXXXXX.992:311): pid=2091 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:authentication grantors=pam_rootok acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_ACCT msg=audit(XXXXXXXXXX.993:312): pid=2091 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:accounting grantors=pam_succeed_if acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=CRED_ACQ msg=audit(XXXXXXXXXX.993:313): pid=2091 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_rootok acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=USER_START msg=audit(XXXXXXXXXX.002:314): pid=2091 uid=0 auid=1006 ses=4 subj=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix,pam_xauth acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/1 res=success'
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.006:315): proctitle="-bash"
type=PATH msg=audit(XXXXXXXXXX.006:315): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.006:315): item=0 name="/bin/bash" inode=50548532 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:shell_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.006:315):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.006:315): argc=1 a0="-bash"
type=SYSCALL msg=audit(XXXXXXXXXX.006:315): arch=c000003e syscall=59 success=yes exit=0 a0=55ae507e6a40 a1=55ae507e7f70 a2=55ae507e7f20 a3=2 items=2 ppid=2091 pid=2092 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="bash" exe="/usr/bin/bash" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.019:316): proctitle=2F7573722F62696E2F6964002D756E
type=PATH msg=audit(XXXXXXXXXX.019:316): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.019:316): item=0 name="/usr/bin/id" inode=50490537 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.019:316):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.019:316): argc=2 a0="/usr/bin/id" a1="-un"
type=SYSCALL msg=audit(XXXXXXXXXX.019:316): arch=c000003e syscall=59 success=yes exit=0 a0=b44ee0 a1=b453d0 a2=b420d0 a3=7ffc5fe42f20 items=2 ppid=2093 pid=2094 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="id" exe="/usr/bin/id" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.025:317): proctitle="/usr/bin/hostname"
type=PATH msg=audit(XXXXXXXXXX.025:317): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.025:317): item=0 name="/usr/bin/hostname" inode=50341315 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:hostname_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.025:317):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.025:317): argc=1 a0="/usr/bin/hostname"
type=SYSCALL msg=audit(XXXXXXXXXX.025:317): arch=c000003e syscall=59 success=yes exit=0 a0=b43700 a1=b43590 a2=b45760 a3=7ffc5fe434e0 items=2 ppid=2095 pid=2096 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="hostname" exe="/usr/bin/hostname" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.030:318): proctitle=2F62696E2F7368002F7573722F6C6962657865632F67726570636F6E662E7368002D63
type=PATH msg=audit(XXXXXXXXXX.030:318): item=2 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.030:318): item=1 name="/bin/sh" inode=50548532 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:shell_exec_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.030:318): item=0 name="/usr/libexec/grepconf.sh" inode=33686597 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.030:318):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.030:318): argc=3 a0="/bin/sh" a1="/usr/libexec/grepconf.sh" a2="-c"
type=SYSCALL msg=audit(XXXXXXXXXX.030:318): arch=c000003e syscall=59 success=yes exit=0 a0=b474a0 a1=b45510 a2=b45e20 a3=7ffc5fe43160 items=3 ppid=2092 pid=2097 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="grepconf.sh" exe="/usr/bin/bash" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.035:319): proctitle=67726570002D717369005E434F4C4F522E2A6E6F6E65002F6574632F475245505F434F4C4F5253
type=PATH msg=audit(XXXXXXXXXX.035:319): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.035:319): item=0 name="/bin/grep" inode=50340995 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.035:319):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.035:319): argc=4 a0="grep" a1="-qsi" a2="^COLOR.*none" a3="/etc/GREP_COLORS"
type=SYSCALL msg=audit(XXXXXXXXXX.035:319): arch=c000003e syscall=59 success=yes exit=0 a0=77dba0 a1=77c140 a2=77bc50 a3=7fffb327e2e0 items=2 ppid=2097 pid=2098 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="grep" exe="/usr/bin/grep" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.039:320): proctitle=2F7573722F62696E2F747479002D73
type=PATH msg=audit(XXXXXXXXXX.039:320): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.039:320): item=0 name="/usr/bin/tty" inode=50490595 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.039:320):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.039:320): argc=2 a0="/usr/bin/tty" a1="-s"
type=SYSCALL msg=audit(XXXXXXXXXX.039:320): arch=c000003e syscall=59 success=yes exit=0 a0=b4c190 a1=b4c370 a2=b45e20 a3=7ffc5fe420e0 items=2 ppid=2099 pid=2100 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="tty" exe="/usr/bin/tty" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.045:321): proctitle=2F7573722F62696E2F7470757400636F6C6F7273
type=PATH msg=audit(XXXXXXXXXX.045:321): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.045:321): item=0 name="/usr/bin/tput" inode=50490480 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.045:321):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.045:321): argc=2 a0="/usr/bin/tput" a1="colors"
type=SYSCALL msg=audit(XXXXXXXXXX.045:321): arch=c000003e syscall=59 success=yes exit=0 a0=b4c290 a1=b4c330 a2=b45e20 a3=7ffc5fe420e0 items=2 ppid=2099 pid=2101 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="tput" exe="/usr/bin/tput" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.049:322): proctitle=2F7573722F62696E2F646972636F6C6F7273002D2D7368002F6574632F4449525F434F4C4F52532E323536636F6C6F72
type=PATH msg=audit(XXXXXXXXXX.049:322): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.049:322): item=0 name="/usr/bin/dircolors" inode=50490523 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.049:322):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.049:322): argc=3 a0="/usr/bin/dircolors" a1="--sh" a2="/etc/DIR_COLORS.256color"
type=SYSCALL msg=audit(XXXXXXXXXX.049:322): arch=c000003e syscall=59 success=yes exit=0 a0=b4b540 a1=b4b6f0 a2=b45e20 a3=7ffc5fe426e0 items=2 ppid=2102 pid=2103 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="dircolors" exe="/usr/bin/dircolors" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.053:323): proctitle=2F7573722F62696E2F67726570002D7169005E434F4C4F522E2A6E6F6E65002F6574632F4449525F434F4C4F52532E323536636F6C6F72
type=PATH msg=audit(XXXXXXXXXX.053:323): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.053:323): item=0 name="/usr/bin/grep" inode=50340995 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.053:323):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.053:323): argc=4 a0="/usr/bin/grep" a1="-qi" a2="^COLOR.*none" a3="/etc/DIR_COLORS.256color"
type=SYSCALL msg=audit(XXXXXXXXXX.053:323): arch=c000003e syscall=59 success=yes exit=0 a0=b4ae90 a1=b4b4e0 a2=b431b0 a3=7ffc5fe42f20 items=2 ppid=2092 pid=2104 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="grep" exe="/usr/bin/grep" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.060:324): proctitle=2F7362696E2F636F6E736F6C6574797065007374646F7574
type=PATH msg=audit(XXXXXXXXXX.060:324): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.060:324): item=0 name="/sbin/consoletype" inode=362246 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.060:324):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.060:324): argc=2 a0="/sbin/consoletype" a1="stdout"
type=SYSCALL msg=audit(XXXXXXXXXX.060:324): arch=c000003e syscall=59 success=yes exit=0 a0=b43250 a1=b43300 a2=b4e120 a3=7ffc5fe425a0 items=2 ppid=2105 pid=2106 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="consoletype" exe="/usr/sbin/consoletype" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.427:325): proctitle=6C73002D2D636F6C6F723D6175746F
type=PATH msg=audit(XXXXXXXXXX.427:325): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.427:325): item=0 name="/bin/ls" inode=50490543 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.427:325):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.427:325): argc=2 a0="ls" a1="--color=auto"
type=SYSCALL msg=audit(XXXXXXXXXX.427:325): arch=c000003e syscall=59 success=yes exit=0 a0=b47090 a1=b43cb0 a2=b4e120 a3=7ffc5fe43d20 items=2 ppid=2092 pid=2108 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="ls" exe="/usr/bin/ls" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.453:328): proctitle=636174002F6574632F736861646F77
type=PATH msg=audit(XXXXXXXXXX.453:328): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=15666 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(XXXXXXXXXX.453:328): item=0 name="/bin/cat" inode=50490509 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.453:328):  cwd="/root"
type=EXECVE msg=audit(XXXXXXXXXX.453:328): argc=2 a0="cat" a1="/etc/shadow"
type=SYSCALL msg=audit(XXXXXXXXXX.453:328): arch=c000003e syscall=59 success=yes exit=0 a0=b43cd0 a1=b43f40 a2=b4e120 a3=7ffc5fe43d20 items=2 ppid=2092 pid=2131 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="cat" exe="/usr/bin/cat" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
----
time->Sat Dec  4 12:00:00 2021
type=PROCTITLE msg=audit(XXXXXXXXXX.454:329): proctitle=636174002F6574632F736861646F77
type=PATH msg=audit(XXXXXXXXXX.454:329): item=0 name="/etc/shadow" inode=16778370 dev=fd:00 mode=0100000 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:shadow_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(XXXXXXXXXX.454:329):  cwd="/root"
type=SYSCALL msg=audit(XXXXXXXXXX.454:329): arch=c000003e syscall=2 success=no exit=-13 a0=7ffd6b2a67e3 a1=0 a2=1fffffffffff0000 a3=7ffd6b2a4b60 items=1 ppid=2092 pid=2131 auid=1006 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=4 comm="cat" exe="/usr/bin/cat" subj=staff_u:staff_r:staff_t:s0-s0:c0.c1023 key=(null)
type=AVC msg=audit(XXXXXXXXXX.454:329): avc:  denied  { dac_read_search } for  pid=2131 comm="cat" capability=2  scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tclass=capability permissive=0
type=AVC msg=audit(XXXXXXXXXX.454:329): avc:  denied  { dac_override } for  pid=2131 comm="cat" capability=1  scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tclass=capability permissive=0
----
```

以上です。

### 参考文献

- [セキュリティーの強化 Red Hat Enterprise Linux 8 - 第12章 システムの監査](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html-single/security_hardening/index#auditing-the-system_security-hardening)
