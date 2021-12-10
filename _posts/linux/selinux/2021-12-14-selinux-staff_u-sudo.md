---
layout:        post
title:         "SELinuxのstaff_uがsudoできるコマンドを限定する"
date:          2021-12-14
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

staff_u に割り当てられたユーザは sudo が実行できますが、デフォルトでは sudo 付きでコマンド実行してもSELinuxに拒否されます。
/etc/sudoersを編集し、SELinuxのstaff_uでsudoできるコマンドを限定する方法について説明します。

まず、実験用に user1 アカウントを作成し、管理者ユーザで user1 を SELinux の staff_u ユーザに割り当てます。
```bash
~]# usermod -Z staff_u user1
```
続いて、user1でSSHログインをし、wheelグループに所属していてもsudoコマンドによる管理者の操作ができないことを確認します。
```bash
~]$ id
uid=1005(user1) gid=1005(user1) groups=1005(user1),10(wheel) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023

~]$ sudo systemctl status httpd
Failed to get D-Bus connection: Operation not permitted
~]$ sudo systemctl restart httpd
Failed to get D-Bus connection: Operation not permitted
```
監査ログを確認すると、SELinuxによってアクセス拒否されていることがわかります。
```bash
~]# tail -f /var/log/audit/audit.log | grep denied
type=AVC msg=audit(0000000000.130:1371): avc:  denied  { search } for  pid=11009 comm="systemctl" name="1" dev="proc" ino=7192 scontext=staff_u:staff_r:staff_sudo_t:s0-s0:c0.c1023 tcontext=system_u:system_r:init_t:s0 tclass=dir permissive=0
```
staff_u ユーザが sudo でコマンドを実行できるようにするには、/etc/sudoers を編集して、以下の形式で実行できるコマンドを記載していきます。
```
USERNAME ALL=(ALL) ROLE=sysadm_r TYPE=sysadm_t COMMAND
```

/etc/sudoersは管理者ユーザで編集します。編集時は visudo コマンドを使うと保存時の構文エラーを検知できるので安全です。
ここでは user1 ユーザが sysadm_r ロールの権限で systemctl restart httpd を実行できるようにします。
```bash
~]# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
~]# visudo  # 以下の行を追加する
user1 ALL=(ALL) ROLE=sysadm_r TYPE=sysadm_t /usr/bin/systemctl status httpd
user1 ALL=(ALL) ROLE=sysadm_r TYPE=sysadm_t /usr/bin/systemctl restart httpd
```
/etc/sudoersの編集が完了すると、すぐに反映され、user1ユーザで当該コマンドを sudo で実行できるようになります。
```bash
~]$ sudo systemctl restart httpd
~]$ sudo systemctl status httpd
* httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-11-30 16:07:30 JST; 5s ago
```
もちろん、ここで指定したコマンド以外でsudoが必要なコマンドは実行できません。

<br>

### 補足：staff_u のロールの確認・修正

デフォルトでSELinuxのstaff_uユーザが持つロールは staff_r, sysadm_r, system_r, unconfined_r の4つです。
```bash
~]# semanage user -l

                Labeling   MLS/       MLS/
SELinux User    Prefix     MCS Level  MCS Range          SELinux Roles

guest_u         user       s0         s0                 guest_r
root            user       s0         s0-s0:c0.c1023     staff_r sysadm_r system_r unconfined_r
staff_u         user       s0         s0-s0:c0.c1023     staff_r sysadm_r system_r unconfined_r
sysadm_u        user       s0         s0-s0:c0.c1023     sysadm_r
system_u        user       s0         s0-s0:c0.c1023     system_r unconfined_r
unconfined_u    user       s0         s0-s0:c0.c1023     system_r unconfined_r
user_u          user       s0         s0                 user_r
xguest_u        user       s0         s0                 xguest_r
```

staff_u に全てのSELinuxロールを追加には、semanage user でロール (-R) を修正 (-m) します。
```bash
~]# semanage user -m -R 'staff_r webadm_r unconfined_r sysadm_r secadm_r logadm_r dbadm_r auditadm_r' staff_u
```
ロールを修正・追加することで、staff_uに割り当てられたユーザがsudoでコマンドを実行するときのロール(ROLE)とタイプ(TYPE)を指定することができるようになります。
例えば、logadm_r を追加すると以下のように logadm_t タイプでコマンドを実行するようになります。
```
USERNAME ALL=(ALL) ROLE=logadm_r TYPE=logadm_t COMMAND
```
修正後は staff_u のロールに反映されたことを確認します。
```bash
~]# semanage user -l

                Labeling   MLS/       MLS/
SELinux User    Prefix     MCS Level  MCS Range          SELinux Roles

guest_u         user       s0         s0                 guest_r
root            user       s0         s0-s0:c0.c1023     staff_r sysadm_r system_r unconfined_r
staff_u         user       s0         s0-s0:c0.c1023     auditadm_r secadm_r staff_r sysadm_r unconfined_r dbadm_r logadm_r webadm_r
sysadm_u        user       s0         s0-s0:c0.c1023     sysadm_r
system_u        user       s0         s0-s0:c0.c1023     system_r unconfined_r
unconfined_u    user       s0         s0-s0:c0.c1023     system_r unconfined_r
user_u          user       s0         s0                 user_r
xguest_u        user       s0         s0                 xguest_r
```
staff_u のロールを初期値に戻す場合は、以下のコマンドを実行します。
```bash
~]# semanage user -m -R 'staff_r sysadm_r system_r unconfined_r' staff_u
```
以上です。

