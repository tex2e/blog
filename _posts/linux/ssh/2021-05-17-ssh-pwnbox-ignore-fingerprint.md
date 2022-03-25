---
layout:        post
title:         "PwnBoxへのSSH接続時にフィンガープリントの警告をなくす"
date:          2021-05-17
category:      Linux
cover:         /assets/cover14.jpg
redirect_from: /security/ssh-pwnbox-ignore-fingerprint
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

PwnBox は Hack The Box の Machine へ接続するための踏み台となる仮想マシンですが、
インスタンスを立ち上げるごとにドメイン名が変わるため、SSH接続時に毎回フィンガープリントの確認が入ります。
毎回警告がでるのは煩わしいので、設定で `*.htb-cloud.com` へ接続するときは無条件に受け入れるようにします。

SSHのオプションで次の2つを指定すると、警告メッセージが表示されなくなります。

- `-o StrictHostKeyChecking=no` : no にするとフィンガープリントの確認をしません。デフォルト値はaskで known_hosts に存在しないときはユーザに確認を求めます。
- `-o UserKnownHostsFile=/dev/null` : known_hostsファイルの場所を指定します。デフォルトは ~/.ssh/known_hosts ですが、/dev/null を指定することで追加の書き込みが行われなくなります。

sshコマンド実行時に上記オプションを追加するのは面倒なので、~/.ssh/config に設定を追加します。

```bash
vim ~/.ssh/config
```

~/.ssh/configに以下を追加します。
htb-cloud.com のサブドメインに対するsshにオプションを適用するための設定です。

```
Host *.htb-cloud.com
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

これで、sshコマンド実行時にフィンガープリントの警告がでなくなります。

```
$ ssh htb-USERNAME@htb-RANDOMSTR.htb-cloud.com
Warning: Permanently added 'htb-RANDOMSTR.htb-cloud.com,178.128.XX.XX' (ECDSA) to the list of known hosts.
htb-USERNAME@htb-RANDOMSTR.htb-cloud.com's password:

┌─[htb-USERNAME@htb-RANDOMSTR]─[~]
└──╼ $
```

以上です。

Happy Hacking!
