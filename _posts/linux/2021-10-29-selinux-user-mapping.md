---
layout:        post
title:         "SELinuxユーザのデフォルトマッピングを変更する"
menutitle:     "SELinuxユーザのデフォルトマッピングを変更する (semanage login -m)"
date:          2021-10-29
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

Linuxユーザを新規追加したとき、デフォルトではSELinuxの unconfined_u ユーザが割り当てられます。
unconfined_u は SELinux の制限を受けないため、権限昇格の攻撃の危険があります。
ここでは、ユーザ新規追加時のデフォルトSELinuxユーザを変更する方法について説明します。

なお、unconfined_u は SELinux の制限を受けないユーザのため、脆弱性を使った権限昇格によるシステム全体の権限が奪われる可能性があります。
SELinuxユーザのデフォルトマッピングの変更することは、システムを守るために重要な作業です。

#### デフォルトマッピングを user_u に変更
SEユーザ「user_u」は sudo や su が実行できない (setuidができない) ユーザです。
一般ユーザの新規作成時は、user_u に割り当てるのが妥当です。
semanage login コマンドを使って、オプション -m (修正：Modify)、-s (SEユーザ指定)、-r (範囲：Range) を指定して、`__default__` を user_u にマッピングします。
```bash
~]# semanage login -m -S targeted -s "user_u" -r s0 __default__
~]# semanage login -l

Login Name           SELinux User         MLS/MCS Range        Service

__default__          user_u               s0                   *
root                 unconfined_u         s0-s0:c0.c1023       *
```
※設定後の注意ですが、上の状態で root のSSHログインを無効化していると、SSHによるリモート経由では誰もroot権限の操作ができなくなります。修復するにはサーバが存在する端末から直接rootログインしないといけなくなります。
なので、管理者のユーザだけは特別にroot権限で作業できるようにマッピングを追加しておく必要があります。
例えば、tex2e というLinuxユーザに対して管理者ユーザとして unconfined_u にマッピングしておくなどの対策が必要です。
```bash
~]# semanage login -a -s unconfined_u tex2e
~]# semanage login -l

Login Name           SELinux User         MLS/MCS Range        Service

__default__          user_u               s0                   *
tex2e                unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
```

#### デフォルトマッピングを unconfined_u に変更（元に戻す）
デフォルトマッピングをSELinux設定時のデフォルトに戻す場合は、以下のコマンドを入力します。
```bash
~]# semanage login -m -S targeted -s "unconfined_u" -r s0-s0:c0.c1023 __default__
~]# semanage login -l

Login Name           SELinux User         MLS/MCS Range        Service

__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
```
以上です。
