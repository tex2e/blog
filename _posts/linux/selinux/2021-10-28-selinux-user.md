---
layout:        post
title:         "SELinuxユーザによる権限昇格対策"
menutitle:     "SELinuxユーザによる権限昇格対策 (unconfined_u, staff_u, user_u)"
date:          2021-10-28
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

SELinux環境下では、任意のユーザがrootに権限昇格しても、期待通りにコマンドが実行できません。
この記事では、SELinuxユーザの割り当て方法と、それぞれのアクセス制限について説明します。

用語の定義ですが、「ユーザ」はLinuxユーザを表しています。一方、SELinuxで定義されているユーザは「SELinuxユーザ」と表しています。

### 割り当てるSELinuxユーザの一覧

ユーザに割り当てることができるSELinuxユーザには以下のものがあります。
SELinuxユーザ毎にできること・できないことが存在します。

| ユーザ | ロール | ドメイン | X Window System | su, sudo | /home/ や /tmp での実行 | ネットワーク
|--|--|--|--|
| sysadm_u | sysadm_r | sysadm_t | はい   | suとsudo | はい | はい
| staff_u  | staff_r  | staff_t  | はい   | sudoのみ | はい | はい
| user_u   | user_r   | user_t   | はい   | いいえ   | はい | はい
| guest_u  | guest_r  | guest_t  | いいえ | いいえ   | はい | いいえ
| xguest_u | xguest_r | xguest_t | はい   | いいえ   | はい | Firefox のみ

これらのSELinuxユーザを適切にユーザに割り当てることで、権限昇格に強いLinux環境を構築することができます。

### suとsudoの制限

以下では、SELinuxユーザの unconfined_u と staff_u と user_u の su や sudo コマンドの制限について比較します。

#### unconfined_u

unconfined_u ユーザはSELinuxの制限を受けない特別なユーザです。
デフォルトでは、ユーザを新規作成すると unconfined_u に割り当てられます（危険な状態です）。

実験のために、まず、testユーザの作成します。デフォルトではSELinuxの unconfined_u ユーザが割り当てられ、unconfined_t タイプでラベル付けされます。
```bash
~]# useradd test
~]# passwd test
~]# usermod -aG wheel test

~]# su test
~]$ id
uid=1001(test) gid=1001(test) groups=1001(test),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```
testユーザは wheel グループに入っているので、sudoが実行できます。
```bash
~]$ sudo cat /etc/sudoers
## Sudoers allows particular users to run various commands as
## the root user, without needing the root password.
...(省略)...
```
もちろん、sudo suでrootになることも可能です。
root権限に昇格した際のSELinuxコンテキストは、**ログイン前ユーザのSELinuxコンテキストを継承する**ため unconfined_u:unconfined_r:unconfined_t となっています。
```bash
~]$ sudo su -
[sudo] password for test:
~]#
~]# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

#### staff_u

SELinuxの staff_u ユーザは sudo のみ実行できるユーザです。
一般的には sudoers に sudo で実行できるコマンドを定義し、それ以外のコマンドは sudo できないように制限をかけます。
しかし、世の中には sudo で実行できると root 権限に昇格できるコマンドがたくさんあります ([GTFOBins 
](https://gtfobins.github.io/) 参照)。
SELinuxのユーザを使うことで、この手の攻撃が困難になるように対策することができます。

まず、testユーザをSELinuxの staff_u ユーザに割り当てます。
semanage login コマンドで -a オプション (SELinuxユーザ追加) と -s オプション (割り当てるSELinuxユーザを指定) を組み合わせて、LinuxユーザとSELinuxユーザの対応関係を定義します。
```bash
~]# semanage login -d test               # <= もし登録済みの割り当てがあれば削除する
~]# semanage login -a -s staff_u test    # <= testユーザにSELinuxのstaff_uユーザを割り当てる
~]# semanage login -l

Login Name           SELinux User         MLS/MCS Range        Service

__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
test                 staff_u              s0-s0:c0.c1023       *
```
一度ログアウトしてから再度ログインすると、testユーザのコンテキストが staff_u:staff_r:staff_t になります。

staff_u ユーザは sudo は実行できますが su はできません (su で正しいパスワードを入れても Authentication failure とエラーになります)。
しかし、該当ユーザが sudo su を使用可能な場合は、su が実行できます。
つまりroot権限に昇格することが可能になります。

しかし、sudo su して root に権限昇格できた場合でも、**ユーザのSELinuxコンテキストはログイン前ユーザのものを継承**します。
そして、たとえ test ユーザが root ユーザに昇格してもSELinuxコンテキストに基づくアクセス制御が実施されるため、SELinuxの staff_u ユーザのタイプ staff_t では、/root 内のファイル (admin_home_t タイプ) の中身を閲覧できません（タイプが異なるため）。
```bash
~]$ id
uid=1001(test) gid=1001(test) groups=1001(test),10(wheel) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023

~]$ sudo su
[sudo] password for test:
bash: /root/.bashrc: Permission denied
bash-4.4#
bash-4.4# id
uid=0(root) gid=0(root) groups=0(root) context=staff_u:staff_r:staff_t:s0-s0:c0.c1023
bash-4.4# ls -l /root/example.txt
-rw-r--r--. 1 root root 0 Oct 22 20:45 /root/example.txt
bash-4.4# cat example.txt
cat: example.txt: Permission denied
```

root権限になっても、SELinuxによって staff_t タイプのユーザが admin_home_t タイプのファイルを閲覧を拒否し、攻撃から環境を守ることに成功しましたが、その成果はデフォルトでは audit.log に書き込まれません。
よく報告されるログはあえてログに書き込まない、**サイレント拒否**がデフォルトで有効になっているためです。
デバッグ時に動かない原因を探る際はサイレント拒否を無効化しておきましょう。

```bash
~]# semodule -DB     # サイレント拒否を無効化する
~]# semodule -B      # サイレント拒否を有効化する
```

再度 /root 内のファイルにアクセスすると、auditのログに staff_t で admin_home_t のファイル example.txt へのアクセスを拒否したログが書き込まれます。

/var/log/audit/audit.log
```
type=AVC msg=audit(0000000000.942:819): avc:  denied  { read } for  pid=4827 comm="cat" name="example.txt" dev="dm-0" ino=33575049 scontext=staff_u:staff_r:staff_t:s0-s0:c0.c1023 tcontext=unconfined_u:object_r:admin_home_t:s0 tclass=file permissive=0
```
実験が終わったら、サイレント拒否を有効化にしておきましょう。

#### user_u

user_u ユーザは su や sudo が実行できないユーザです。

```bash
~]# semanage login -d test               # <= もし登録済みの割り当てがあれば削除する
~]# semanage login -a -s user_u test     # <= testユーザにSELinuxのuser_uユーザを割り当てる
~]# semanage login -l

Login Name           SELinux User         MLS/MCS Range        Service

__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
test                 user_u               s0                   *
```
一度ログアウトしてから再度ログインすると、testユーザのコンテキストが user_u:user_r:user_t になります。

実際にSELinuxの user_u ユーザで sudo コマンドを実行すると、wheel グループに属していても、sudo (setuid) が拒否される様子が確認できます。
```bash
~]$ id
uid=1001(test) gid=1001(test) groups=1001(test),10(wheel) context=user_u:user_r:user_t:s0

~]$ sudo cat /etc/sudoers
sudo: PERM_SUDOERS: setresuid(-1, 1, -1): Operation not permitted
sudo: no valid sudoers sources found, quitting
sudo: setresuid() [0, 0, 0] -> [1001, -1, -1]: Operation not permitted
sudo: unable to initialize policy plugin
```
以上です。


