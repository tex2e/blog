---
layout:        post
title:         "GitサーバとGitWebをCentOS 7で構築"
menutitle:     "GitサーバとGitWebをCentOS 7で構築"
date:          2017-12-29
tags:          Git Server
category:      Git
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

CentOS 7 で Git サーバーを立てて、さらに GitWeb で閲覧できるようにする方法。

Git サーバーの設定
-----------------

SSH接続のできるターミナルからWebサーバにアクセスしてベアリポジトリを作成します。
ベアリポジトリとは、作業コピー（HEAD）を持たないリポジトリのことです。
また、今回は全てのGitリポジトリを置くディレクトリ（以下、Gitルートディレクトリ）は
`/var/lib/git` にしました。


```
[server]$ sudo yum install git
[server]$ sudo mkdir -p /var/lib/git         # 全てのGitリポジトリは、この下に作成する
[server]$ cd /var/lib/git
[server]$ sudo mkdir my-repo.git             # リポジトリ名は末尾に .git を付けること
[server]$ cd my-repo.git
[server]$ sudo git init --bare --shared=0777 # 他のユーザもpushできるベアリポジトリの作成
```

毎回 sudo をGitルートディレクトリ下で使いたくない人は
chown などで /var/lib/git の所有者を変えて置くと良いでしょう。

git init のオプションで shared の値に 0777 とありますが、これはパーミッションと同じです。
自分以外のユーザもpushできるようにするために、0777 にしておきます。
ただし、0xxx のように 0 を先頭に付けます。
この辺の設定については、パーミッションを変えたくない or
同じグループだけの人にpushを許可したい 等があると思いますので適宜変更してください。

ベアリポジトリが作成できたら、ローカル環境にあるリポジトリをpushします。
ここではリモート名は「my-web-server」としていますが、Gitサーバーであることが分かればなんでも良いです。
URLパスの書き方は「ssh://ユーザ名@ホスト名:ボート番号/リポジトリまでのフルパス」となります。

```
[local]$ git remote add my-web-server ssh://user@hostname:22/var/lib/git/my-repo.git
[local]$ git push my-web-server master
```

git clone などでリポジトリを取ってくるときも同様に書きます。

```
[local]$ git clone ssh://user@hostname:22/var/lib/git/my-repo.git
```

URLパスについて補足すると、ユーザ名はCentOSで作成したユーザ名です。
ホスト名にはベアリポジトリのあるサーバーのホスト名を書きます。
同じLANの中にGitサーバーがある場合は 192.168.xxx.xxx のような ip アドレスで指定します。
ボート番号は ssh が 22 番を使用するので、何もしてなければ 22 になります。
ポートフォワーディングなどを使用している場合はポート番号が変わるので、適宜変更してください。


GitWeb の設定
-----------------

GitWeb とはサーバにある Git サーバーの中身を web で閲覧できるようにするためのものです。
gitweb は yum を使って簡単にインストールすることができます。
また、gitweb を使うためには Apache もインストールしておく必要があります。

```
[server]$ sudo yum install httpd gitweb
```

次に Apache（httpd）の設定をします。
Apache で http の80番ポートを使えるようにするために、CentOS 7 では firewall-cmd を使います。
CentOS 6 では iptables を使ってください（ここでは説明しません）。

```
[server]$ sudo systemctl start httpd.service
[server]$ sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
[server]$ sudo firewall-cmd --reload
```

GitWebはデフォルトで `/var/lib/git` をGitルートディレクトリにしますが、
自分の好きな場所にGitルートディレクトリを配置したい場合は、/etc/gitweb.conf を編集します。
ちなみに、この設定ファイルは perl コードです。

```
[server]$ sudo yum install vim
[server]$ sudo vim /etc/gitweb.conf

# 以下の内容を追加する

our $projectroot = "/home/username/path/to/git";  # Gitルートディレクトリを指定する
```

ここまでできたら http://hostname/git にアクセスすると git リポジトリの一覧が表示されます。


FAQ
----------

#### Q. /var/lib/git のディレクトリがないと言われる

A. なければ自分で作ってください。
Gitルートディレクトリは自分の好きな場所に作れるので、
ディレクトリの場所とかは自分が分かればどこでも良いです。

#### Q. 他の人が push すると失敗する

A. ディレクトリの権限を 777 にして、他の人も書き換え可能にします。
```
[server]$ cd /var/lib/git/repo
[server]$ sudo chmod -R 777 branches hooks info objects refs
```

#### Q. GitWebを設定して http://hostname/git にアクセスしてもページが表示されない

A. http://hostname/ にアクセスしても何も表示されない場合は、次のことを試してみてください。

1. Apache が動いているかを `systemctl status httpd` で確認する
2. 80番ポートが開いているかを `sudo firewall-cmd --list-all` で確認する（ports に 80/tcp があれば ok）
3. SELinux を無効化する（/etc/sysconfig/selinux を編集して `SELINUX=disabled` にする）
