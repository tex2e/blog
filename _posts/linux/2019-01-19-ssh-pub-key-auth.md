---
layout:        post
title:         "SSHで公開鍵認証"
menutitle:     "SSHで公開鍵認証"
date:          2019-01-19
tags:          Linux
category:      Linux
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from: /shell/ssh-pub-key-auth
comments:      true
published:     true
---

仮想環境の CentOS 7 on Virtual Box に MacOS から ssh で公開鍵認証するやり方について説明します。
ただし、自分の仮想環境を作るためのメモ書き程度なので悪しからず。

### .ssh/config の設定

自宅には仮想環境が3つあるので、3つの仮想環境に対する ssh 接続の設定をします。
`ssh ユーザ名@ホスト名` の代わりに `ssh local1` のように、
自分のつけた名前で ssh 接続できるようになります。

```command
$ vi ~/.ssh/config

Host local?
  HostName 127.0.0.1
  User root
  IdentityFile ~/.ssh/local_rsa
Host local1
  Port 22
Host local2
  Port 1122
Host local3
  Port 2222
```

### 秘密鍵と公開鍵を生成する

`ssh-keygen` コマンドで秘密鍵と公開鍵の生成します。
必要に応じて rsa を楕円曲線暗号の ed25519 に変えると安全性が上がります。

```command
$ ssh-keygen -t rsa -f ~/.ssh/local_rsa
```

### サーバに公開鍵を登録する

生成した公開鍵をリモートの ~/.ssh/authorized_keys に追加します。
ディレクトリの作成やパーミッションの設定なども行います。

#### 選択肢A）コマンド直打ち

```command
$ cat ~/.ssh/local_rsa.pub | ssh ホスト名 'mkdir -p ~/.ssh; chmod 700 ~/.ssh; cat >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys'
```

#### 選択肢B) ssh-copy-idコマンド

ローカルにある鍵を指定すると、
リモートで ~/.ssh/authorized_keys の作成やパーミッションを適切に設定してくれます。
パーミッションの設定は特に忘れやすいので、このコマンドを使うのがおすすめです。

```command
$ ssh-copy-id -i .ssh/local_rsa local2

/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: ".ssh/local_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@127.0.0.1's password:

Number of key(s) added:        1

Now try logging into the machine, with:   "ssh 'local2'"
and check to make sure that only the key(s) you wanted were added.


パスワードを聞かれずにログインできることを確認する
$ ssh local2
```

### CentOS 7 でパスワード認証を無効にする

公開鍵認証が使えるようになればパスワード認証は不要なので、無効にすることもできます。
CentOS では /etc/ssh/ 以下に設定ファイルがありますが ssh_config と sshd_config という
似ているファイルがあるので注意。前者はsshクライアントの設定で、後者はsshサーバの設定です。

```command
# vi /etc/ssh/sshd_config

パスワード認証を無効にする
PasswordAuthentication no

# systemctl restart sshd
```

以上です。
