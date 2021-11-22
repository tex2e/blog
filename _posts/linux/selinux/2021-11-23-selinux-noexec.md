---
layout:        post
title:         "SELinuxでユーザのファイル実行を制限する"
date:          2021-11-23
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

SELinuxでユーザのファイル実行権限を制限するには、以下のブール値のOn/Offを設定することで、簡単にファイル実行の制限ができます。

- **sysadm_exec_content** : SELinuxユーザ sysadm_u がファイルを実行する権限
- **staff_exec_content** : SELinuxユーザ staff_u がファイルを実行する権限
- **user_exec_content** : SELinuxユーザ user_u がファイルを実行する権限
- **guest_exec_content** : SELinuxユーザ guest_u がファイルを実行する権限

実際に、SELinuxユーザがファイルを実行できないようにするには、setsebool を使って以下のコマンドで設定します。
```bash
~]# setsebool -P sysadm_exec_content 0
~]# setsebool -P staff_exec_content 0
~]# setsebool -P user_exec_content 0
~]# setsebool -P guest_exec_content 0
```

以上です。

---

### 補足：検証作業

以下検証作業の記録です。

おさらいですが、管理者が設定できるSELinuxユーザには主に以下の4つがあります。
デフォルトでは、以下の全ユーザで/home/*や/tmp以下のファイルを実行することが可能です。

| ユーザ   | ロール   | ドメイン | su, sudo | /home/*や/tmpでの実行 | ネットワーク
|----------|----------|----------|----------|------|--------
| sysadm_u | sysadm_r | sysadm_t | suとsudo | はい | はい
| staff_u  | staff_r  | staff_t  | sudoのみ | はい | はい
| user_u   | user_r   | user_t   | いいえ   | はい | はい
| guest_u  | guest_r  | guest_t  | いいえ   | はい | いいえ

検証では4ユーザにそれぞれ sysadm_u, staff_u, user_u, guest_u を割り当てます。

```bash
~]# useradd user1
~]# useradd user2
~]# useradd user3
~]# useradd user4
~]# echo user1:Password123 | chpasswd
~]# echo user2:Password123 | chpasswd
~]# echo user3:Password123 | chpasswd
~]# echo user4:Password123 | chpasswd
~]# semanage login -a -s sysadm_u user1
~]# semanage login -a -s staff_u  user2
~]# semanage login -a -s user_u   user3
~]# semanage login -a -s guest_u  user4
~]# semanage login -l

Login Name           SELinux User         MLS/MCS Range        Service

__default__          user_u               s0                   *
mako                 unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
user1                sysadm_u             s0-s0:c0.c1023       *
user2                staff_u              s0-s0:c0.c1023       *
user3                user_u               s0                   *
user4                guest_u              s0                   *
```

以下は各ユーザで検証した結果です。

### sysadm_u (user1)
SELinuxユーザ sysadm_u が割り当てられたLinuxユーザは、デフォルトでは ssh ログインができません。
```cmd
PS> ssh user1@192.168.56.102
user1@192.168.56.102's password:
client_loop: send disconnect: Connection reset
```
ログを確認すると、sshd が SELinux でアクセス拒否されています。
```bash
~]# tail -f /var/log/messages | grep 'SELinux is preventing'
```
```
localhost setroubleshoot[14926]: SELinux is preventing /usr/sbin/sshd from using the dyntransition access on a process.#012#012*****  Plugin catchall_boolean (89.3 confidence) suggests   ******************#012#012If you want to allow ssh to sysadm login#012Then you must tell SELinux about this by enabling the 'ssh_sysadm_login' boolean.#012#012Do#012setsebool -P ssh_sysadm_login 1#012#012***** 
```
デフォルトではSELinuxユーザの sysadm はsshログインが拒否されます。
許可したい場合は ssh_sysadm_login のブール値をOnにします。
```bash
~]# setsebool -P ssh_sysadm_login 1
```
上記コマンドを実行すると、SELinuxで拒否されずにログインできるようになります。
```cmd
PS> ssh user1@192.168.56.102
user1@192.168.56.102's password:

~]$ id
uid=1004(user1) gid=1004(user1) groups=1004(user1) context=sysadm_u:sysadm_r:sysadm_t:s0-s0:c0.c1023
```

##### suコマンド＞成功
sysadm_u は su コマンドを使用することができます。
```bash
~]$ su - user2
Password:
~]$ id
uid=1005(user2) gid=1005(user2) groups=1005(user2) context=sysadm_u:sysadm_r:sysadm_t:s0-s0:c0.c1023
```

##### sudoコマンド＞成功
sysadm_u は sudo コマンドも使用することができます。
root権限の別ユーザでwheelグループに所属させて、対象ユーザがsudoできることを確認します。
```bash
~]# usermod -aG wheel user1
```
sudo su で管理者権限に昇格します。
```bash
~]$ id
uid=1004(user1) gid=1004(user1) groups=1004(user1),10(wheel) context=sysadm_u:sysadm_r:sysadm_t:s0-s0:c0.c1023
~]$ sudo su -
[sudo] password for user1:
~]# id
uid=0(root) gid=0(root) groups=0(root) context=sysadm_u:sysadm_r:sysadm_t:s0-s0:c0.c1023
```

##### /home/*や/tmpのファイル実行＞成功
デフォルトではファイルの実行が可能です。
```bash
~]$ /tmp/test.sh
hello!
```
sysadm_exec_content を Off にするとファイルを実行できなくなります。
```bash
~]# setsebool -P sysadm_exec_content 0
```
ファイル実行拒否を設定した後：
```bash
~]$ /tmp/test.sh
-bash: /tmp/test.sh: Permission denied
```

##### ネットワーク接続＞成功
sysadm_u はネットワーク接続することができます。
```bash
~]# curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```


### staff_u (user2)
staff_u のSELinuxコンテキストは「staff_u:staff_r:staff_t」です。
```bash
~]$ id
uid=1005(user2) gid=1005(user2) groups=1005(user2),10(wheel) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023
```

##### suコマンド＞失敗
staff_u は su コマンドを使用できません。
```bash
~]$ su - user3
Password:
su: Authentication failure
```

##### sudoコマンド＞成功
staff_u は sudo コマンドを使用することができます。
```bash
~]$ sudo systemctl restart httpd
System has not been booted with systemd as init system (PID 1). Cannot operate.
Failed to connect to bus: Host is down
~]$ sudo su -
-bash: /root/.bash_profile: Permission denied
~]# id
uid=0(root) gid=0(root) groups=0(root) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023
~]# systemctl restart httpd
```

##### /home/*や/tmpのファイル実行＞成功
デフォルトではファイルの実行が可能です。
```bash
~]$ /tmp/test.sh
hello!
```
staff_exec_content を Off にするとファイルを実行できなくなります。
```bash
~]# setsebool -P staff_exec_content 0
```
ファイル実行拒否を設定した後：
```bash
~]$ /tmp/test.sh
-bash: /tmp/test.sh: Permission denied
```

##### ネットワーク接続＞成功
staff_u はネットワーク接続することができます。
```bash
~]# curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```


#### user_u (user3)
user_u のSELinuxコンテキストは「user_u:user_r:user_t」です。
```bash
~]$ id
uid=1006(user3) gid=1006(user3) groups=1006(user3) context=user_u:user_r:user_t:s0
```

##### suコマンド＞失敗
user_u は su コマンドを使用することができません。
```bash
~]$ su - user4
Password:
su: Authentication failure
```

##### sudoコマンド＞失敗
user_u は sudo コマンドも使用することができません。
```bash
~]$ sudo su -
sudo: PERM_SUDOERS: setresuid(-1, 1, -1): Operation not permitted
sudo: no valid sudoers sources found, quitting
sudo: setresuid() [0, 0, 0] -> [1006, -1, -1]: Operation not permitted
sudo: unable to initialize policy plugin
```

##### /home/*や/tmpのファイル実行＞成功
デフォルトではファイルの実行が可能です。
```bash
~]$ /tmp/test.sh
hello!
```
user_exec_content を Off にするとファイルを実行できなくなります。
```bash
~]# setsebool -P user_exec_content 0
```
ファイル実行拒否を設定した後：
```bash
~]$ /tmp/test.sh
-bash: /tmp/test.sh: Permission denied
```

#### ネットワーク接続＞成功
user_u はネットワーク接続することができます。
```bash
~]$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

### guest_u (user4)
guest_u のSELinuxコンテキストは「guest_u:guest_r:guest_t」です。
```bash
~]$ id
uid=1007(user4) gid=1007(user4) groups=1007(user4) context=guest_u:guest_r:guest_t:s0
```

##### suコマンド＞失敗
guest_u は su コマンドを使用できません。
```bash
~]$ su - user3
Password:
su: Authentication failure
```

##### sudoコマンド＞失敗
guest_u は sudo コマンドも使用できません。
```bash
~]$ sudo su -
sudo: unable to change to root gid: Operation not permitted
sudo: unable to initialize policy plugin
```

##### /home/*や/tmpのファイル実行＞成功
デフォルトではファイルの実行が可能です。
```bash
~]$ /tmp/test.sh
hello!
```
guest_exec_content を Off にするとファイルを実行できなくなります。
```bash
~]# setsebool -P guest_exec_content 0
```
ファイル実行拒否を設定した後：
```bash
~]$ /tmp/test.sh
-bash: /tmp/test.sh: Permission denied
```

##### ネットワーク接続＞失敗
guest_u はネットワーク接続が拒否されます。
```bash
~]$ curl google.com
curl: (6) Could not resolve host: google.com

~]$ ping 8.8.8.8
ping: socket: Permission denied
```

以上です。

