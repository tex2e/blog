---
layout:        post
title:         "SSHで公開鍵認証 (~/.ssh/configの設定とssh-copy-idコマンドによる配布)"
date:          2024-11-28
category:      Linux
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from: /shell/ssh-pub-key-auth
comments:      true
published:     true
---

CentOS に ssh で公開鍵認証できるように設定する方法について説明します。

### 秘密鍵と公開鍵の生成

`ssh-keygen` コマンドで秘密鍵と公開鍵の生成します。
鍵の種類を楕円曲線暗号 ed25519 に変えると安全性が上がります。
必要に応じて、古い環境でも使う可能性がある場合は rsa を指定します。

```bash
$ ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
```

上記コマンドを実行すると、秘密鍵と公開鍵が以下のパスに作成されます。
- 秘密鍵 : ~/.ssh/id_ed25519
- 公開鍵 : ~/.ssh/id_ed25519.pub

### .ssh/config の設定

リモートへ接続するための ssh 接続の設定をします。
以下の設定をすることで `ssh ユーザ名@ホスト名` の代わりに `ssh rockylinux` のように、自分のつけた名前で ssh 接続できるようになります。

```bash
$ vim ~/.ssh/config
```

```config
Host rockylinux
  HostName 127.0.0.1
  User myname
  IdentityFile ~/.ssh/id_ed25519
```


### ssh-copy-idコマンドでサーバに公開鍵を登録する

サーバに公開鍵を登録する際は ssh-copy-id コマンドを使用します (ssh-copy-id がない場合は補足を参照)。
生成した公開鍵をリモートの ~/.ssh/authorized_keys に追加して、ディレクトリの作成や権限の設定なども行います。

ssh-copy-idコマンドでローカルにある秘密鍵を指定すると、
リモートへ公開鍵を送信し、~/.ssh/authorized_keys の作成や権限を適切に設定してくれます。
権限の設定は特に間違えやすいので、このコマンドを使うのがおすすめです。

```bash
$ ssh-copy-id -i ~/.ssh/id_ed25519 rockylinux
```

```command
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "~/.ssh/id_ed25519.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@127.0.0.1's password: (ログイン時のパスワードを入力)

Number of key(s) added:        1

Now try logging into the machine, with:   "ssh 'rockylinux'"
and check to make sure that only the key(s) you wanted were added.
```

最後に、パスワードを聞かれずに公開鍵認証でログインできることを確認しましょう。

```bash
$ ssh rockylinux
```

### ssh-copy-idコマンドが存在しないとき

自分のローカル環境に ssh-copy-id コマンドがないときは、代わりに以下のコマンドを実行する方法もあります。

```bash
cat ~/.ssh/id_ed25519.pub | ssh ユーザ名@ホスト名 'mkdir -p ~/.ssh; chmod 700 ~/.ssh; cat >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys'
```

上記を1行ずつ実行する場合は以下のようになります。

```bash
cat ~/.ssh/id_ed25519.pub       # 出力はクリップボードにコピーしておく
ssh ユーザ名@ホスト名
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat >> ~/.ssh/authorized_keys   # 貼り付けてCtrl+Cで抜ける
chmod 600 ~/.ssh/authorized_keys
```

最近のLinux環境であれば ssh-copy-id コマンドは、ssh-keygen と一緒に入っています。
ただし、Windowsの環境では ssh-copy-id は存在しないので、上記のコマンド群で対応するしかありません。



<!--
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
-->

以上です。

---
