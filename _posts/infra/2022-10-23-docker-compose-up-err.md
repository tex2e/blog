---
layout:        post
title:         "[Docker] compose up時のエラー「Couldn't connect to Docker daemon at http+docker://localhost - is it running?」の対処法"
date:          2022-10-23
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from: /infrastructure/docker-compose-up-error
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

docker-compose up を実行した際に systemctl status docker でデーモンは動いているのに接続できない際の対処法について説明します。
```
Couldn't connect to Docker daemon at http+docker://localhost - is it running?
```

### 原因

dockerコマンドは管理者権限 (sudo) で実行する必要があるためです。


### 対処法

sudo を付けて実行するか、実行ユーザを docker グループに所属させてから docker コマンドを実行する必要があります。
以下では jenkins ユーザを docker グループに所属してから実行する例です。

dockerグループが存在するか確認します。
```bash
$ cat /etc/group | grep docker
docker:x:999:
```

jenkinsユーザをdockerグループに所属させます。
```bash
$ sudo usermod -aG docker jenkins
```

SSHで接続中のユーザの場合は再度SSH接続し、デーモンが使用するユーザの場合はサービス再起動します。
その後で、id で正しくグループに所属されたことを確認します。
```bash
$ id jenkins
uid=108(jenkins) gid=112(jenkins) groups=112(jenkins),999(docker)
```

dockerグループに所属していれば sudo なしで実行できるようになります。
```bash
$ docker-compose up -d
```

### 注意点

ユーザを docker グループに所属させた場合、そのユーザはOSの管理者権限を得ることができます。
詳細は [DockerやLXDを利用した権限昇格](../infrastructure/docker-privilege-escalation) をご確認ください。

以上です。

### 参考文献
- [【エラー】Docker使用時「Couldn't connect to Docker daemon at http+docker://localhost - is it running?」の対処 \| offlo.in（オフロイン）](https://offlo.in/blog/error-docker-daemon.html)
