---
layout:        post
title:         "SELinuxを有効化する"
date:          2021-10-19
category:      SELinux
cover:         /assets/cover6.jpg
redirect_from: /linux/enable-selinux
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

SELinuxを有効化する方法について説明します。
設定ファイルを SELINUX=enforcing に修正して再起動する方法と、setenforce で一時的に有効化する方法があります。

### ブートローダーの設定でSELinuxが有効
まず、以下のコマンドで出力がないことを確認します。
```bash
~]# grep -E 'kernelopts=(\S+\s+)*(selinux=0|enforcing=0)+\b' /boot/grub2/grubenv
```
もし出力がある場合は、ブートローダーの設定でSELinuxが無効化されているので、SELinuxの設定ファイルである /etc/selinux/config を編集しても無駄になります。
修正するには /etc/default/grub ファイルの変数 GRUB_CMDLINE_LINUX_DEFAULT や GRUB_CMDLINE_LINUX から `selinux=0` と `enforcing=0` の文字列を削除した後、以下のコマンドを実行します。
```bash
~]# grub2-mkconfig -o /boot/grub2/grub.cfg
```
そして、システムを再起動します。

### DisabledモードからSELinuxを有効化
Disabledモード（SELinux無効化）から、有効化するには /etc/selinux/config を修正して、SELINUX=enforcing にしてから再起動する必要があります。
setenforce コマンドはDisabledモードのときは使用できません。
```bash
~]# getenforce
Disabled
~]# setenforce 0
setenforce: SELinux is disabled
~]# setenforce 1
setenforce: SELinux is disabled
```
設定ファイルで SELINUX=enforcing を指定します。

/etc/selinux/config
```
#SELINUX=disabled
SELINUX=enforcing
SELINUXTYPE=targeted
```
サーバを再起動します。
```bash
~]# reboot
```
DisableからPermissiveまたはEnforcingモードにする際は、Relabelingが発生するので再起動するのに時間がかかります。

再起動時のSELinuxを有効化中のログ：
```
selinux-autorelabel[796]: *** Warning -- SELinux targeted policy relabel is required.
selinux-autorelabel[796]: *** Relabeling could take a very long time, depending on file system size and speed of hard drivers
```

### PermissiveモードからSELinuxを有効化
Permissive（SELinuxのアクセス拒否ログのみ記録するモード）では、setenforce コマンドでSELinuxを有効化することができます。
```bash
~]# getenforce
Permissive
~]# setenforce 1
~]# getenforce
Enforcing
```
setenforceでは再起動すると元の状態に戻るので、永続的にSELinuxを有効化したい場合は、Disabledモードのときと同様に設定を修正して再起動する必要があります。
ラベリングはすでに行われているので、再起動時にRelabelingは発生しないので、特別時間がかかることはないです。

Permissiveの場合は、アクセス拒否ログの記録に permissive=1 と出力されます。
```bash
~]# getenforce
Permissive
~]# systemctl restart httpd
~]# tail /var/log/audit/audit.log | grep denied
```
監査ログ出力結果：
```
type=AVC msg=audit(0000000000.641:141): avc:  denied  { name_bind } for  pid=1592 comm="httpd" src=3131 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=1
```

Enforcingにした場合は、アクセス拒否ログの記録に permissive=0 と出力され、実際にアクセス拒否が行われます。
```bash
~]# setenforce 1
~]# getenforce
Enforcing
~]# systemctl restart httpd
Job for httpd.service failed because the control process exited with error code.
See "systemctl status httpd.service" and "journalctl -xe" for details.
~]# tail /var/log/audit/audit.log | grep denied
```
監査ログ出力結果：
```
type=AVC msg=audit(0000000000.747:146): avc:  denied  { name_bind } for  pid=1841 comm="httpd" src=3131 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
```

### Enforcingモード
EnforcingはSELinuxが有効でアクセス拒否も実施するモードです。
setenforce コマンドで一時的にSELinuxを無効化（監査ログのみ記録）することもできますが、再起動するとEnforcingモードに戻ります。

```bash
~]# getenforce
Enforcing
~]# setenforce 0
~]# getenforce
Permissive
~]# setenforce 1
~]# getenforce
Enforcing
```

以上です。
