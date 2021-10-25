---
layout:        post
title:         "ptrace を SELinux で無効化する"
menutitle:     "ptrace を SELinux で無効化する (deny_ptrace)"
date:          2021-10-26
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

ptrace はデバッグ時は有用ですが、侵入した攻撃者にとってはリアルタイムにメモリを改ざんできる便利なツールです。
この記事では全てのユーザが SELinux で ptrace の使用を禁止する設定について説明します。

ptrace() システムコールを使うと、プロセスの実行を監視・制御して、メモリーやレジスタを変更できるようになります。
ptrace は主に strace コマンドなどでデバッグ時に使用されます。
デバッグ時には有益ですが、メモリーやレジスタが変更できる点は攻撃者にとって都合の良いツールになります。
Linux環境をより安全にするために、ptrace() を使う必要ない場合は、これを無効にすることができます。
```bash
~]# semanage boolean -l | grep deny_ptrace
deny_ptrace             (off  ,  off)  Allow deny to ptrace
```
以下のコマンドでSELinuxによるptrace無効化の設定することができます。
```bash
~]# setsebool -P deny_ptrace on
```

### 技術検証

本当に無効化されるのか検証していきます。
まず、SELinux で ptrace を無効化する前に strace が実行できることを確認します。
ps auxwf で他のコンソールで動いているbashにアタッチして監視できることを確認します。
```
~]# strace -p 1490
strace: Process 1490 attached
...他のコンソールでcatコマンドを実行...
stat(".", {st_mode=S_IFDIR|0550, st_size=220, ...}) = 0
stat("/usr/local/sbin/cat", 0x7ffe6c493820) = -1 ENOENT (No such file or directory)
stat("/usr/local/bin/cat", 0x7ffe6c493820) = -1 ENOENT (No such file or directory)
stat("/usr/sbin/cat", 0x7ffe6c493820)   = -1 ENOENT (No such file or directory)
stat("/usr/bin/cat", {st_mode=S_IFREG|0755, st_size=38504, ...}) = 0
stat("/usr/bin/cat", {st_mode=S_IFREG|0755, st_size=38504, ...}) = 0
geteuid()                               = 0
getegid()                               = 0
getuid()                                = 0
getgid()                                = 0
access("/usr/bin/cat", X_OK)            = 0
stat("/usr/bin/cat", {st_mode=S_IFREG|0755, st_size=38504, ...}) = 0
```
次に、SELinuxでptraceを無効化するブール値「deny_ptrace」をonにします。
```bash
~]# setsebool -P deny_ptrace on
```
再度、straceを実行しようとすると権限エラーになります。
straceコマンドをrootユーザで実行しようとしましたが、deny_ptrace ブール値は unconfined_t ドメイン (デフォルトでアクセス可能となる強いドメイン) であっても ptrace の呼び出しを拒否することが可能になります。
```bash
~]# strace -p 1490
strace: test_ptrace_get_syscall_info: PTRACE_TRACEME: Permission denied
strace: attach: ptrace(PTRACE_ATTACH, 1490): Permission denied
```

以上です。


### 参考文献

- [4.15. ptrace() の無効化 Red Hat Enterprise Linux 7 \| Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-disable_ptrace)
