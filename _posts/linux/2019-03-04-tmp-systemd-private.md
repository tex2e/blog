---
layout:        post
title:         "/tmp/systemd-private-* の意味について"
menutitle:     "/tmp/systemd-private-* の意味について (PrivateTmp)"
date:          2019-03-04
category:      Linux
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from: /shell/tmp-systemd-private
comments:      true
published:     true
---

CentOS を起動すると作られている /tmp/systemd-private-* というディレクトリについて説明します。
まず始めに、CentOS を立ち上げると /tmp の下に必ず長い名前のディレクトリが作成されています。

```bash
~]$ ls /tmp
systemd-private-3ef14b74b7b8486284b8b9e93065c94b-chronyd.service-Fsznwt
systemd-private-3ef14b74b7b8486284b8b9e93065c94b-httpd.service-3a0L9f
```

これは systemctl enable されているサービスの PrivateTmp が有効になっている場合に作成されます。
サービスの設定で PrivateTmp=true となっていると、
プロセスが使う一時ディレクトリをそのプロセスにしか見えないように隠すことができます。
Linuxカーネルが提供する namespace（名前空間）という機能を使って、
マウントを分離して作成したファイルがそのプロセスにしか見れないように隠蔽できるようになっています。

例えば、httpd のサービスファイルを見ると PrivateTmp が有効になっているのが確認できます。

```bash
~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   ...

~]# cat /usr/lib/systemd/system/httpd.service | grep PrivateTmp
PrivateTmp=yes
```

### systemd の PrivateTmp=true の検証

実際に /tmp にファイルを作成するサービスを作成して、
PrivateTmp=true 環境下でどのような挙動をするか確認してみたいと思います。

/usr/lib/systemd/system/ はパッケージが提供するサービスのファイルを配置する場所で、
/etc/systemd/system/ はシステム管理者がサービスのファイルを配置する場所です。
同名のファイルがある場合は後者の方が優先されます。
なので、今回は /etc/systemd/system/ にファイルを配置していきます。

まず、一時ファイルを作成する実験用のサービスファイルを作ります。

```bash
~]# cd /etc/systemd/system/multi-user.target.wants/
~]# vim private-tmp-test.service
```

作成するファイル private-tmp-test.service の内容は以下の通りです。

```conf
[Unit]
Description = PrivateTmp test

[Service]
Type = simple
ExecStart = /usr/local/bin/private-tmp-test.sh
PrivateTmp = true

[Install]
WantedBy = multi-user.target
```

サービス起動時に実行するスクリプト private-tmp-test.sh も作成します。

```bash
~]# cd /usr/local/bin/
~]# vim private-tmp-test.sh
```

作成するファイル private-tmp-test.sh の内容は以下の通りです。

```bash
#!/bin/bash
touch /tmp/test1
touch /var/tmp/test2
while true; do sleep 1; done
```

スクリプトに実行権限を与えて、サービスを起動します。

```bash
~]# chmod +x private-tmp-test.sh
~]# systemctl daemon-reload
~]# systemctl start private-tmp-test
```

この後に、root で /tmp を確認するとディレクトリが作成されています。
/var/tmp も同様です。

```bash
~]# ls /tmp
systemd-private-3ef14b74b7b8486284b8b9e93065c94b-chronyd.service-Fsznwt/
systemd-private-3ef14b74b7b8486284b8b9e93065c94b-httpd.service-3a0L9f/
systemd-private-3ef14b74b7b8486284b8b9e93065c94b-private-tmp-test.service-G57QEZ/
```

よって、PrivateTmp=true にしてサービスを起動した場合、サービス foobar が /tmp の下にファイルを作るときは、実際には /tmp/systemd-private-*-foobar/tmp の下に作られることが確認できます。
これにより、/tmp にアクセスしてもプロセス foobar は他のプロセスが作成した一時ファイルを見つけることができず、一時ファイルを利用したTOC/TOU攻撃を緩和することができるため、セキュリティ的に安全になると言えます。

以上です。
