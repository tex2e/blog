---
layout:        post
title:         "SSHで公開鍵認証 (~/.ssh/configの設定)"
date:          2019-01-19
category:      Linux
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from: /shell/ssh-pub-key-auth
comments:      true
published:     true
---

CentOS に ssh で公開鍵認証できるように設定する方法について説明します。

### .ssh/config の設定

自環境の仮想環境に対する ssh 接続の設定をします。
`ssh ユーザ名@ホスト名` の代わりに `ssh centos` のように、
自分のつけた名前で ssh 接続できるようになります。

```command
$ vim ~/.ssh/config

Host centos
  HostName 127.0.0.1
  User myname
  IdentityFile ~/.ssh/id_ed25519
```

### 秘密鍵と公開鍵を生成する

`ssh-keygen` コマンドで秘密鍵と公開鍵の生成します。
鍵の種類を楕円曲線暗号 ed25519 に変えると安全性が上がりますが、
古い環境でも使う必要があるかたは rsa を指定します。

```command
$ ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
```

### サーバに公開鍵を登録する

ssh-copy-id という便利なコマンドがあります。
生成した公開鍵をリモートの ~/.ssh/authorized_keys に追加して、
ディレクトリの作成や権限の設定なども行います [^1]。

[^1]: ssh-copy-id コマンドがない場合は、以下のように直打ちします。
    ```command
    $ cat ~/.ssh/id_ed25519.pub | ssh ホスト名 'mkdir -p ~/.ssh; chmod 700 ~/.ssh; cat >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys'
    ```
    最近の環境なら ssh-keygen と一緒に入っていると思います。


#### ssh-copy-idコマンド

ssh-copy-idコマンドでローカルにある鍵を指定すると、
リモートで ~/.ssh/authorized_keys の作成や権限を適切に設定してくれます。
権限の設定は特に忘れやすいので、このコマンドを使うのがおすすめです。

```command
$ ssh-copy-id -i ~/.ssh/id_ed25519 centos

/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "~/.ssh/id_ed25519.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@127.0.0.1's password:

Number of key(s) added:        1

Now try logging into the machine, with:   "ssh 'centos'"
and check to make sure that only the key(s) you wanted were added.


パスワードを聞かれずにログインできることを確認する
$ ssh centos
```

### CentOS でパスワード認証を無効にする

公開鍵認証が使えるようになればパスワード認証は不要なので、無効にすることもできます。
CentOS の /etc/ssh/sshd_config にはsshサーバの設定があるのでこれを編集します。

```command
# vi /etc/ssh/sshd_config

パスワード認証を無効にする
PasswordAuthentication no

# systemctl restart sshd
```

注意ですが、似たような設定ファイル /etc/ssh/ssh_config がありますが、こちらはsshクライアントの設定です。間違えないようにしましょう。

以上です。

---
