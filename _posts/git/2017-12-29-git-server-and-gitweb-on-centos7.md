---
layout:        post
title:         "GitサーバとGitWebをCentOS 7で構築する"
menutitle:     "GitサーバとGitWebをCentOS 7で構築する"
date:          2017-12-31
tags:          Git Server
category:      Git
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

主な内容は以下の通り。

- CentOS 7 で Git サーバーを立てて、git push や git clone する方法
- Git サーバーの中身を GitWeb で閲覧できるようにする方法
- git push で Webサイトの更新を行う方法

それでは順に説明していきます。


Git サーバーの設定
-----------------

SSH接続のできるターミナルからWebサーバにアクセスしてベアリポジトリを作成します。
ベアリポジトリとは、作業コピー（HEAD）を持たないリポジトリのことです。
また、今回は全てのGitリポジトリを置くディレクトリ（以下、Gitルートディレクトリ）は
`/var/lib/git` にしました。


```terminal
[server]$ sudo yum install git
[server]$ sudo mkdir -p /var/lib/git         # 全てのGitリポジトリは、この下に作成する
[server]$ cd /var/lib/git
[server]$ sudo mkdir my-repo.git             # リポジトリ名は末尾に .git を付けること
[server]$ cd my-repo.git
[server]$ sudo git init --bare --shared=0777 # 他のユーザもpushできるベアリポジトリの作成
```

git init のオプションで shared の値に 0777 とありますが、これはパーミッションと同じです。
自分以外のユーザもpushできるようにするために、0777 にしておきます。
ただし、0xxx のように 0 を先頭に付けます。
この辺の設定については、パーミッションを変えたくない or
同じグループだけの人にpushを許可したい 等があると思いますので適宜変更してください。

余談ですが、毎回 sudo をGitルートディレクトリ下で使いたくない人は
chown で /var/lib/git の所有者を変えて置くと良いでしょう。

```terminal
[server]$ sudo chown -R ユーザ名:グループ名 /var/lib/git
```

ベアリポジトリが作成できたら、ローカル環境にあるリポジトリをpushします。
ここではリモート名は「my-web-server」としていますが、Gitサーバーであることが分かればなんでも良いです。
URLパスの書き方は「ssh://ユーザ名@ホスト名:ボート番号/リポジトリまでのフルパス」となります。

```terminal
[local]$ git remote add my-web-server ssh://user@hostname:22/var/lib/git/my-repo.git
[local]$ git push my-web-server master
```

git clone などでリポジトリを取ってくるときも同様に書きます。

```terminal
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

```terminal
[server]$ sudo yum install httpd gitweb
```

次に Apache（httpd）の設定をします。
Apache で http の80番ポートを使えるようにするために、CentOS 7 では firewall-cmd を使います。
CentOS 6 では iptables を使ってください（ここでは説明しません）。

```terminal
[server]$ sudo systemctl start httpd.service
[server]$ sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
[server]$ sudo firewall-cmd --reload
```

GitWebはデフォルトで `/var/lib/git` をGitルートディレクトリにしますが、
自分の好きな場所にGitルートディレクトリを配置したい場合は、/etc/gitweb.conf を編集します。
ちなみに、この設定ファイルは perl コードです。

```terminal
[server]$ sudo yum install vim
[server]$ sudo vim /etc/gitweb.conf

# 以下の内容を追加する

our $projectroot = "/home/username/path/to/git";  # Gitルートディレクトリを指定する
```

ここまでできたら http://hostname/git にアクセスすると git リポジトリの一覧が表示されます。


git push した時に Web サイトの更新もする
-----------------------------------

Web サイトの更新を git push したタイミングで行うには、
ベアリポジトリとは別にサイト公開用のベアではないリポジトリを配置する必要があります。
Apache は /var/www/html 以下を表示するので、サイト公開用のリポジトリはそこに配置します。

```terminal
[server]$ cd /var/www/html
[server]$ sudo git clone /var/lib/git/my-repo.git
[server]$ sudo chmod 777 my-repo
[server]$ sudo chmod -R 777 my-repo/.git
```

次に、ベアリポジトリの方に push されたら、
サイト公開用のベアではないリポジトリから、ベアリポジトリを pull する hook スクリプトを、
ベアリポジトリの hooks/post-update に書きます。

```terminal
[server]$ cd /var/lib/git/my-repo.git
[server]$ cp post-update.sample post-update
[server]$ vim post-update
```

hooks/post-update の中身は次のように編集します。

```bash
#!/bin/sh
#
# An example hook script to prepare a packed repository for use over
# dumb transports.
#
# To enable this hook, rename this file to "post-update".

unset GIT_DIR
cd "/var/www/html/my-repo" || exit
git pull origin master

exec git update-server-info
```

ここまで出来たら、試しにローカル環境で index.html を作成して、push してみましょう。

```terminal
[local]$ echo "hello, world" > index.html
[local]$ git add index.html
[local]$ git commit -m 'create index.html'
[local]$ git push
Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 284 bytes | 284.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote: From /var/lib/git/my-repo
remote:  * branch            master     -> FETCH_HEAD
remote: Updating 926019b..7c6cb53
remote: Fast-forward
remote:  index.html | 1 +
remote:  1 file changed, 1 insertion(+)
remote:  create mode 100644 index.html
To ssh://hostname/var/lib/git/my-repo.git
   926019b..7c6cb53  master -> master
```

最後に http://hostname/my-repo/index.html にアクセスして「hello, world」と表示されたら成功です。

### .git 以下のファイルを非表示にする

何もしないと /var/www/html 以下に置いた全てのファイルが閲覧できてしまうので、
http://hostname/my-repo/.git/ にアクセスすると .git の中身が公開されてしまいます。
今回は Apache を使っているので、まず .htaccess によるアクセス権の上書きを有効にするために、
/etc/httpd/conf/httpd.conf を編集します。

```conf
<Directory "/var/www/html">
    # ...
    Options Indexes FollowSymLinks

    #
    # AllowOverride controls what directives may be placed in .htaccess files.
    # It can be "All", "None", or any combination of the keywords:
    #   Options FileInfo AuthConfig Limit
    #
    AllowOverride All  # <= None から All に変更する

    # ...
    Require all granted
</Directory>
```

編集し終えたら、Apache を再起動しておきます。

```terminal
[server]$ sudo systemctl restart httpd.service
```

次に、ドキュメントルート（/var/www/html）の直下に .htaccess を以下の内容で作成します。

```conf
RedirectMatch 404 /\.git
```

このようにすることで、ドキュメントルート以下にある全てのGitリポジトリの
.git ディレクトリにアクセスしようとすると 404 になります。
同じように .gitignore や .gitmodules も 404 になります。


URL まとめ
----------

- Gitサーバーで git push や git clone をするときは
    - ssh://ユーザ名@ホスト名:ボート番号/リポジトリまでのフルパス
- gitweb でリポジトリを見るときは
    - http://ホスト名/git
- /var/www/html 下にサイト公開用のリポジトリを配置したときは
    - http://ホスト名/リポジトリ名



FAQ
----------

#### Q. /var/lib/git のディレクトリがないと言われる

A. なければ自分で作ります。
Gitルートディレクトリは自分の好きな場所に作れるので、
ディレクトリの場所とかは自分が分かればどこでも良いです。

#### Q. 他の人が push すると失敗する

A. ディレクトリの権限を 777 にして、他の人も書き換え可能にします。
```terminal
[server]$ cd /var/lib/git/my-repo.git
[server]$ sudo chmod -R 777 branches hooks info objects refs
```

#### Q. GitWebを設定して http://hostname/git にアクセスしてもページが表示されない

A. http://hostname/ にアクセスしても何も表示されない場合は、次のことを試してみてください。

1. Apache が動いているかを `systemctl status httpd` で確認する
2. 80番ポートが開いているかを `sudo firewall-cmd --list-all` で確認する（ports に 80/tcp があれば ok）
3. SELinux を無効化する（/etc/sysconfig/selinux を編集して `SELINUX=disabled` にする）
