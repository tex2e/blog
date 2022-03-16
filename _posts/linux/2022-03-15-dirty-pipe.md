---
layout:        post
title:         "Dirty Pipeの脆弱性をSELinuxで緩和する"
date:          2022-03-15
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

Dirty Pipe の脆弱性を SELinux を使って制限されたドメイン下で実行した際に攻撃を緩和する方法について説明します。

Dirty Pipe ([CVE-2022-0847](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-0847)) とは、Linux Kernel 5.8 以降に存在する権限昇格ができる脆弱性です。
より正確には、一般ユーザが書き込みができないファイルに対して書き込みができるようになります。
名前の由来は Dirty Cow (CVE-2016-5195) に似ているところから来ていますが、Dirty Pipe の方がより短い時間で権限昇格ができます。
Dirty Pipe は Linux Kernel 5.16.11, 5.15.25, 5.10.102 以降のバージョンで修正されています。

実験環境は、Ubuntu 20.04 で Linux Kernel 5.11.0 の環境で Dirty Pipe と SELinux の検証をしました。
Ubuntu には事前に SELinux をインストールして有効化しておきます。
詳細は [Ubuntu 20.04でSELinuxを有効化する](../linux/ubuntu-install-selinux) をご覧ください。

```bash
~$ cat /etc/os-release
NAME="Ubuntu"
VERSION="20.04.2 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.2 LTS"
VERSION_ID="20.04"

~$ uname -r
5.11.0-37-generic
```

### PoC

Dirty Pipe の PoC を実行すると権限昇格することができます。
実験環境に `ssh user1@192.168.XX.XX` でログインし、Dirty Pipe のプログラムを実行すると、/tmp/sh という名前のシェルが作成され、そのパーミッションに SUID (Set User ID) が設定されます。
通常ファイルを実行した際の権限は、実行ユーザの権限になりますが、SUIDが設定されたファイルでは、その実行ファイルの所有者の権限で実行されます。

```bash
~$ id
uid=1002(user1) gid=1002(user1) groups=1002(user1) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
~$ gcc dirtypipe.c -o dirtypipe
~$ ./dirtypipe
Usage: ./dirtypipe SUID
~$ ./dirtypipe /usr/bin/su
[+] hijacking suid binary..
[+] dropping suid shell..
[+] restoring suid binary..
[+] popping root shell.. (dont forget to clean up /tmp/sh ;))
~# id
uid=0(root) gid=0(root) groups=0(root),1002(user1) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
~# echo hello > /root/test.txt
~# cat /root/test.txt
hello
```

実行後に、/tmp/sh のパーミッションを確認すると 4755 (rwsr-xr-x) であり、3文字目が「s」であることから SUID が設定されていることを確認できます。
つまり、/tmp/sh は全てのユーザが管理者権限で実行できるシェルとなります。

```bash
~$ ls -l /tmp/sh
-rwsr-xr-x. 1 root user1 186 Mar 12 12:00 /tmp/sh*
```

### SELinuxによる攻撃の緩和

SELinuxユーザをLinuxユーザに割り当てておくことで、システムをエクスプロイトから防御することができます。
以下では、Linuxユーザ user4 に対して SELinuxユーザの管理者権限を持つ sysadm_u を割り当てて、エクスプロイトを user4 で実行してみます。

```bash
~$ sudo semanage login -a -s sysadm_u user4
~$ sudo semanage login -l
Login Name           SELinux User         MLS/MCS Range        Service
__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
user2                user_u               s0                   *
user3                staff_u              s0-s0:c0.c1023       *
user4                sysadm_u             s0-s0:c0.c1023       *
```

SELinux の sysadm_u ユーザは管理者権限が与えられているため、SELinux のデフォルトの設定では ssh ログインできません。
そのため、必要に応じて SELinux の Boolean「ssh_sysadm_login」を On にして、sysadm_u のユーザがログインできるように設定します。
```bash
~$ sudo setsebool ssh_sysadm_login on
```

設定したら、`ssh user4@192.168.XX.XX` で検証環境のサーバに SSH ログインします。
ログイン時のセキュリティコンテキストが sysadm_* であることを確認します。
```bash
~$ id
uid=1005(user4) gid=1005(user4) groups=1005(user4),27(sudo) context=sysadm_u:sysadm_r:sysadm_t:s0-s0:c0.c1023
```

次に Dirty Pipe の PoC を用意して実行します。すると、/tmp/sh が見つからずにエラー終了してしまいます。
```bash
~$ gcc dirtypipe.c -o dirtypipe
~$ ./dirtypipe /usr/bin/su
[+] hijacking suid binary..
[+] dropping suid shell..
[+] restoring suid binary..
[+] popping root shell.. (dont forget to clean up /tmp/sh ;))
sh: 1: /tmp/sh: not found
```

PoC が失敗したのは SELinux がアクセスを拒否したためです。
/var/log/audit/audit.log を確認すると、なぜ拒否したのかの原因がわかります。

```
type=AVC msg=audit(1647047714.865:3367): avc:  denied  { search } for  pid=8049 comm="su" name="tmp" dev="sda2" ino=5505025 scontext=sysadm_u:sysadm_r:sysadm_su_t:s0-s0:c0.c1023 tcontext=system_u:object_r:tmp_t:s0 tclass=dir permissive=0
type=AVC msg=audit(1647047714.869:3368): avc:  denied  { search } for  pid=8049 comm="su" name="tmp" dev="sda2" ino=5505025 scontext=sysadm_u:sysadm_r:sysadm_su_t:s0-s0:c0.c1023 tcontext=system_u:object_r:tmp_t:s0 tclass=dir permissive=0
```

拒否の原因は、tmp_t タイプのディレクトリに sysadm_su_t ドメインのプロセスが検索 (ファイルの存在有無を確認) しようと試みたので SELinux が拒否したようです。
もちろん tmp_t タイプのディレクトリとは /tmp のことです。実際のパスを確認したい場合は、iノード番号 ino の値を使って `find / -inum 5505025` で場所を調べることができます。
なお、sysadm_su_t ドメインは sysadm_u が su コマンドで実行した時のドメインのようです。

ここまでで、sysadm_u が Dirty Pipe の PoC を実行しようとしたら、/tmp ディレクトリの検索で拒否されたため、PoC が失敗したことがわかりました。
しかし、もし /tmp 以外のディレクトリで検索 (search) が成功した場合は、どこまで攻撃が成功するでしょうか。
それを調べるために、一旦 SELinux のモードを Permissive (検知するけど拒否しないモード) に変更して動作を確認してみます。

```bash
~$ sudo setenforce 0
~$ getenforce
Permissive
```

Permissive モードにしたら、同じ手順で PoC を実行します。拒否しないモードなので PoC の権限昇格が成功すると思います。

```bash
~$ id
uid=1005(user4) gid=1005(user4) groups=1005(user4),27(sudo) context=sysadm_u:sysadm_r:sysadm_t:s0-s0:c0.c1023
~$ ./dirtypipe /usr/bin/su
[+] hijacking suid binary..
[+] dropping suid shell..
[+] restoring suid binary..
[+] popping root shell.. (dont forget to clean up /tmp/sh ;))
~# id
uid=0(root) gid=0(root) groups=0(root),27(sudo),1005(user4) context=sysadm_u:sysadm_r:sysadm_t:s0-s0:c0.c1023
```

この時の /var/log/audit/audit.log を確認すると、SELinux がどんな種類のアクセスを拒否できたかを知ることができます。
監査ログの内容は以下のようなログが記録されていました。

```
type=AVC msg=audit(1647049368.591:3643): avc:  denied  { search } for  pid=9284 comm="su" name="tmp" dev="sda2" ino=5505025 scontext=sysadm_u:sysadm_r:sysadm_su_t:s0-s0:c0.c1023 tcontext=system_u:object_r:tmp_t:s0 tclass=dir permissive=1
type=AVC msg=audit(1647049368.591:3643): avc:  denied  { write } for  pid=9284 comm="su" name="tmp" dev="sda2" ino=5505025 scontext=sysadm_u:sysadm_r:sysadm_su_t:s0-s0:c0.c1023 tcontext=system_u:object_r:tmp_t:s0 tclass=dir permissive=1
type=AVC msg=audit(1647049368.591:3643): avc:  denied  { add_name } for  pid=9284 comm="su" name="sh" scontext=sysadm_u:sysadm_r:sysadm_su_t:s0-s0:c0.c1023 tcontext=system_u:object_r:tmp_t:s0 tclass=dir permissive=1
```

ログから読み取れる PoC が実行している内容は、次の通りです。

1. sysadm_su_t ドメインで動く su コマンドが、/tmp ディレクトリへ検索した
2. sysadm_su_t ドメインで動く su コマンドが、/tmp ディレクトリへ書き込みした (更新時間の修正)
3. sysadm_su_t ドメインで動く su コマンドが、/tmp ディレクトリへ名前が「sh」の新規ファイルを作成した

以上から、sysadm_su_t ドメインが /tmp/sh にファイルを作成し、/tmp/sh を実行することで、管理者権限のシェルを奪取していることがわかります。

もし、SELinux の環境下でも PoC を成功させたいと考えるとき、ポリシーの許可ルールの隙間を通って、どこのディレクトリなら書き込むことができ、どのタイプのファイルなら実行することができ、どうすれば最終的に PoC を成功させることができるでしょうか。
まずは、SELinux のポリシールールを検索するコマンド sesearch を使って、sysadm_su_t ドメインが書き込めるディレクトリを調べてみます。
アクセス元 (-s) が sysadm_su_t、オブジェクトクラス (-c) が dir、権限 (-p) が write (書き込み) で検索すると、user_home_dir_t にのみ書き込むことができることがわかります。

```bash
~$ sesearch -A -s sysadm_su_t -c dir -p write
allow sysadm_su_t user_home_dir_t:dir { add_name getattr ioctl lock open read remove_name search write };
```
続いて、sysadm_su_t ドメインはどのタイプのファイルなら実行できるのかを sesearch を使って調べてみます。
アクセス元 (-s) が sysadm_su_t、オブジェクトクラス (-c) が file、権限 (-p) が execute (実行) で検索すると、
shell_exec_t や su_exec_t タイプのファイルなら実行できることがわかります。

```bash
~$ sesearch -A -s sysadm_su_t -c file -p execute
allow domain ld_so_t:file { execute getattr ioctl map open read };
allow domain lib_t:file { execute getattr ioctl map open read };
allow domain textrel_shlib_t:file { execmod execute getattr ioctl map open read };
allow sysadm_su_t chkpwd_exec_t:file { execute getattr ioctl map open read };
allow sysadm_su_t shell_exec_t:file { execute getattr ioctl map open read };
allow sysadm_su_t su_exec_t:file { entrypoint execute getattr ioctl lock map open read };
allow sysadm_su_t xauth_exec_t:file { execute getattr ioctl map open read };
```

つまり、SELinux の環境下で PoC を成功させたいなら、sysadm_su_t の場合、PoC が出力する SUID が設定された「sh」というファイルを自分のホームディレクトリに保存し、ファイルのタイプを su_exec_t などにラベル付けしてから実行する、という手順になります。
しかし、この手順を組み込むためには攻撃ツールを改修する必要があり、スクリプトキディなどの他人の開発した攻撃ツールを入手して使用するだけの攻撃者は PoC を改修できるほどの技術力がないため、ある程度の自動化された攻撃は防ぐことが可能です。

### まとめ

SELinux は全ての攻撃からシステムを守ることはできません。
技術力や専門知識のある攻撃者からの攻撃は避けられない場合があります。
しかし、多くの自動化されたエクスプロイトを防御し、資産と脆弱性を特定してパッチを適用するまでの遅延策として、SELinuxを使った対策は有効です。
SELinux を無効化せず、攻撃を緩和するための遅延策として導入することが、パッチ管理の助けになり、より安全な環境を維持できるようになるでしょう。


<!--

```bash
~$ sudo semanage login -a -s user_u user2
~$ sudo semanage login -l
Login Name           SELinux User         MLS/MCS Range        Service
__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
user2                user_u               s0                   *
```

```bash
~$ sudo setenforce 1
~$ getenforce
Enforcing
```

ssh user2@192.168.XX.XX
```bash
~$ id
uid=1003(user2) gid=1003(user2) groups=1003(user2) context=user_u:user_r:user_t:s0
~$ ./dirtypipe /usr/bin/su
-sh: 5: ./dirtypipe: Permission denied

~$ ls /tmp/sh
ls: cannot access '/tmp/sh': No such file or directory
```

```bash
~# tail -f /var/log/audit/audit.log | grep denied
type=AVC msg=audit(1647045338.697:918): avc:  denied  { execute } for  pid=7316 comm="sh" name="dirtypipe" dev="sda2" ino=5505067 scontext=user_u:user_r:user_t:s0 tcontext=unconfined_u:object_r:user_tmp_t:s0 tclass=file permissive=0
```

```bash
~$ sudo setenforce 0
~$ getenforce
Permissive
```
-->

### おまけ

Linuxユーザの user2 にSELinuxユーザの user_u を割り当てて、Permissiveモードの時に Dirty Pipe の PoC を実行してみました。
```bash
~$ id
uid=1003(user2) gid=1003(user2) groups=1003(user2) context=user_u:user_r:user_t:s0
~$ getenforce
Permissive
~$ ./dirtypipe /usr/bin/su
[+] hijacking suid binary..
[+] dropping suid shell..
[+] restoring suid binary..
[+] popping root shell.. (dont forget to clean up /tmp/sh ;))
~# id
uid=0(root) gid=0(root) groups=0(root),1003(user2) context=user_u:user_r:user_t:s0
```
PoCを実行した時の監査ログは以下のようになりました。これを見れば PoC が何をしているのかの概要がわかるかと思います。
```
type=AVC msg=audit(1647049552.639:3730): avc:  denied  { execute } for  pid=9542 comm="sh" name="dirtypipe" dev="sda2" ino=5505067 scontext=user_u:user_r:user_t:s0 tcontext=unconfined_u:object_r:user_tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.639:3730): avc:  denied  { read open } for  pid=9542 comm="sh" path="/tmp/dirtypipe" dev="sda2" ino=5505067 scontext=user_u:user_r:user_t:s0 tcontext=unconfined_u:object_r:user_tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.639:3730): avc:  denied  { execute_no_trans } for  pid=9542 comm="sh" path="/tmp/dirtypipe" dev="sda2" ino=5505067 scontext=user_u:user_r:user_t:s0 tcontext=unconfined_u:object_r:user_tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.639:3730): avc:  denied  { map } for  pid=9542 comm="dirtypipe" path="/tmp/dirtypipe" dev="sda2" ino=5505067 scontext=user_u:user_r:user_t:s0 tcontext=unconfined_u:object_r:user_tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.643:3731): avc:  denied  { search } for  pid=9544 comm="su" name="tmp" dev="sda2" ino=5505025 scontext=user_u:user_r:user_su_t:s0 tcontext=system_u:object_r:tmp_t:s0 tclass=dir permissive=1
type=AVC msg=audit(1647049552.643:3731): avc:  denied  { write } for  pid=9544 comm="su" name="tmp" dev="sda2" ino=5505025 scontext=user_u:user_r:user_su_t:s0 tcontext=system_u:object_r:tmp_t:s0 tclass=dir permissive=1
type=AVC msg=audit(1647049552.643:3731): avc:  denied  { add_name } for  pid=9544 comm="su" name="sh" scontext=user_u:user_r:user_su_t:s0 tcontext=system_u:object_r:tmp_t:s0 tclass=dir permissive=1
type=AVC msg=audit(1647049552.643:3731): avc:  denied  { create } for  pid=9544 comm="su" name="sh" scontext=user_u:user_r:user_su_t:s0 tcontext=user_u:object_r:tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.643:3731): avc:  denied  { write open } for  pid=9544 comm="su" path="/tmp/sh" dev="sda2" ino=5505059 scontext=user_u:user_r:user_su_t:s0 tcontext=user_u:object_r:tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.643:3732): avc:  denied  { setattr } for  pid=9544 comm="su" name="sh" dev="sda2" ino=5505059 scontext=user_u:user_r:user_su_t:s0 tcontext=user_u:object_r:tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.647:3733): avc:  denied  { execute } for  pid=9546 comm="sh" name="sh" dev="sda2" ino=5505059 scontext=user_u:user_r:user_t:s0 tcontext=user_u:object_r:tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.647:3733): avc:  denied  { read open } for  pid=9546 comm="sh" path="/tmp/sh" dev="sda2" ino=5505059 scontext=user_u:user_r:user_t:s0 tcontext=user_u:object_r:tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.647:3733): avc:  denied  { execute_no_trans } for  pid=9546 comm="sh" path="/tmp/sh" dev="sda2" ino=5505059 scontext=user_u:user_r:user_t:s0 tcontext=user_u:object_r:tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.647:3733): avc:  denied  { map } for  pid=9546 comm="sh" path="/tmp/sh" dev="sda2" ino=5505059 scontext=user_u:user_r:user_t:s0 tcontext=user_u:object_r:tmp_t:s0 tclass=file permissive=1
type=AVC msg=audit(1647049552.647:3734): avc:  denied  { setuid } for  pid=9546 comm="sh" capability=7  scontext=user_u:user_r:user_t:s0 tcontext=user_u:user_r:user_t:s0 tclass=capability permissive=1
```

<!--
```bash
~$ find / -inum 5505067 2>/dev/null
/tmp/dirtypipe
~$ find / -inum 5505025 2>/dev/null
/tmp
~$ find / -inum 5505059 2>/dev/null
/tmp/sh
```


```bash
~$ sudo semanage login -a -s staff_u user3
~$ sudo semanage login -l
Login Name           SELinux User         MLS/MCS Range        Service
__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
user2                user_u               s0                   *
user3                staff_u              s0-s0:c0.c1023       *
```

```bash
~$ id
uid=1004(user3) gid=1004(user3) groups=1004(user3) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023
~$ cd /tmp
~$ ./dirtypipe /usr/bin/su
-sh: 4: ./dirtypipe: Permission denied
```

```bash
~# tail -f /var/log/audit/audit.log | grep denied
type=AVC msg=audit(1647047046.559:1849): avc:  denied  { execute } for  pid=7741 comm="sh" name="dirtypipe" dev="sda2" ino=5505067 scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=unconfined_u:object_r:user_tmp_t:s0 tclass=file permissive=0
```
-->



### 参考文献
- PoC :
    - [The Dirty Pipe Vulnerability — The Dirty Pipe Vulnerability documentation](https://dirtypipe.cm4all.com/)
    - [Linux Kernel 5.8 < 5.16.11 - Local Privilege Escalation (DirtyPipe) - Linux local Exploit](https://www.exploit-db.com/exploits/50808)
- 読み物 :
    - [20分で分かるDirty Pipe（CVE-2022-0847） - knqyf263's blog](https://knqyf263.hatenablog.com/entry/2022/03/11/105130)
    - [Linux Kernelの脆弱性(Important: CVE-2022-0847 (Dirty Pipe)) - security.sios.com](https://security.sios.com/vulnerability/kernel-security-vulnerability-20220309.html)
    - [RHSB-2022-002 Dirty Pipe - kernel arbitrary file manipulation - (CVE-2022-0847) - Red Hat Customer Portal](https://access.redhat.com/security/vulnerabilities/RHSB-2022-002)
- 公開情報 :
    - [Dirty Pipe Privilege Escalation Vulnerability in Linux \| CISA](https://www.cisa.gov/uscert/ncas/current-activity/2022/03/10/dirty-pipe-privilege-escalation-vulnerability-linux)
    - [CVE - CVE-2022-0847](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-0847)
