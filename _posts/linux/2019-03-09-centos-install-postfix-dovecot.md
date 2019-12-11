---
layout:        post
title:         "Postfix & Dovecot サーバ構築"
menutitle:     "Postfix & Dovecot サーバ構築"
date:          2019-03-09
tags:          Linux
category:      Linux
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from: /shell/centos-install-postfix-dovecot
comments:      true
published:     true
---

CentOS で Postfix と Dovecot を使って smtp と pop3 サーバを構築する方法について。


### Postfix で SMTP サーバ

まずは smtp サーバを構築する方法について。
はじめに  Postfix のインストールをします。

```
# yum install postfix
```

設定ファイルは /etc/postfix/ にあるので、バックアップを取っておいて main.cf 編集します。

```
# cd /etc/postfix
# cp main.cf main.cf.bak
# vim main.cf
```

/etc/postfix/main.cf の編集

```conf
myhostname = example.co.jp   # メールサーバのホスト名
inet_interfaces = all        # 全てのメールを受け取る（外部・内部からのメール）
mynetworks = 127.0.0.0/8     # ローカルからのメールのみ転送
home_mailbox = Maildir/      # メールの保存場所と保存形式（「/」は必須）
```

メールの保存形式には2つあり、全てのメールを1つのファイルに保存する形式と、1メール毎に1つのファイルに保存する形式があります。
1メール毎に1つのファイルに保存する方がメールの管理がしやすい（古いメールから削除することができる）ので、home_mailbox = Maildir/ とするのが一般的です。

最後に Postfix を起動します。

```
# systemctl start postfix
```

メールの送信は telnet で確認できます。
筆者の環境は MacOS の VirtualBox で CentOS を起動しているので、
ポートフォーワーディングでホストポートの 25 番をゲストポートの 25 番にしてから、
MacOS上のターミナルで telnet で接続後、helo, mail from, ... と入力していきます。

```
# telnet localhost 25
helo a
mail from: test@example.com
rcpt to: root@example.co.jp
data
subject: test
hello!
.
quit
```

送信後に、サーバ側の /root/Maildir/new/ にメールが入っていれば成功です。

上手く送信できない場合は、次の項目を確認してください。

- `netstat -tap` コマンドで smtp（プログラム名は master）が LISTEN しているか
- Firewall で tcp/25 が開いているか
- メールサーバの /var/log/maillog にエラーは表示されていないか
- SELinux で拒否されていないか（拒否のログは ausearch -m avc で見れる）


<br>

### Dovecot で POP3 サーバ

次に pop3 サーバを構築する方法について。
はじめに Dovecot のインストールをします。
dovecot の他に clucene-core もインストールされます。

```
# yum install dovecot
```

設定ファイルは /etc/dovecot/ にあるので、バックアップを取っておいて編集していきます。

/etc/dovecot/conf.d/10-mail.conf

```conf
mail_location = maildir:~/Maildir   # メールの保存場所
```

/etc/dovecot/conf.d/10-auth.conf

```conf
disable_plaintext_auth = no         # 平文認証を無効化しない
```

/etc/dovecot/conf.d/10-ssl.conf

```conf
ssl = no                            # SSL/TLSを使用しない
```

安全性ガン無視ですので、安全な通信がしたい場合は

- 証明書 : /etc/pki/dovecot/certs/dovecot.pem
- 秘密鍵 : /etc/pki/dovecot/private/dovecot.pem

をそれぞれ配置してから設定を変更する必要があります。

最後に dovecot を起動します。

```
# systemctl start dovecot
```

dovecot は root でのログインができないので、適当に test ユーザを作っておきます。

```
# useradd test
# passwd test
```

まずは test ユーザ宛てにメールを送信

```
$ telnet localhost 25
helo a
mail from: a@a.a
rcpt to: test@example.co.jp
data
subject: foobar
hello, foobar
.
quit
```

続いて、pop3 は 100 番を使うので同様にポートフォーワードして、ホスト側から telnet を使って受信します。
pass では test ユーザのパスワードを入力します（平文認証が許可されているので、パスワードは平文になります）。

```
$ telnet localhost 110
user test
pass test
list
```

`list` でメールの一覧が番号と共に表示されます。
メッセージの取り出しは `retr <番号>` です。

```
retr 1
+OK 284 octets
Return-Path: <a@a.a>
X-Original-To: test@example.co.jp
Delivered-To: test@example.co.jp
Received: from a (gateway [10.0.2.2])
	by example.co.jp (Postfix) with SMTP id 1D5898BED15
	for <test@example.co.jp>; Thu,  7 Mar 2019 19:14:12 +0900 (JST)
subject: foobar

hello, foobar
.
```

読み終わったら `quit` で終了します。


### 参考文献

- [SMTPサーバとPOPサーバの実験を交えた詳解](https://qiita.com/d-ebi/items/0809dd1aaed763b7eb66)
