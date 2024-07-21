---
layout:        post
title:         "[Docker] インターネット通信できない環境でDockerをインストールする"
date:          2024-06-02
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from: /linux/docker-install-local-network
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

この記事では、Rocky Linux でDockerのRPMパッケージを手動インストールする方法と、Dockerイメージファイルを転送する方法について説明します。

## 1. DockerのRPMパッケージの取得

dnf install コマンドではインターネットから直接 RPM パッケージを取得しようとします。
しかし、今回のようなインターネットと通信できない環境（プライベート環境）では、実行しても失敗してしまいます。
そこで、インターネットと通信可能な環境で RPM パッケージファイルだけダウンロードしておき、それをプライベート環境に持ち込む、という作業を行います。

### 1.1. インターネット通信可な環境

以下の公式の手順に従って、RPMパッケージをダウンロードしていきます。

- [Docker CE の入手（CentOS 向け） — Docker-docs-ja 20.10 ドキュメント](https://docs.docker.jp/engine/installation/linux/docker-ce/centos.html)

まず、dnf コマンドでDockerレポジトリのURLを追加します。
合わせて、後で必要になるDockerのPRMパッケージ検証鍵（GPG公開鍵）もダウンロードしておきます。

```bash
$ sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
$ curl https://download.docker.com/linux/centos/gpg -o docker.gpg.key
```

次に、Dockerをインストールするために必要なRPMをダウンロードします。
dnf download コマンドに `--resolve` オプションをつけることで、依存関係のRPMパッケージも全てダウンロードするようになります。

```bash
$ mkdir -p /tmp/docker-rpm
$ cd /tmp/docker-rpm
$ sudo dnf download --resolve docker-ce docker-ce-cli containerd.io docker-compose-plugin
$ ls
container-selinux-2.229.0-1.el9.noarch.rpm
containerd.io-1.6.32-3.1.el9.x86_64.rpm
docker-buildx-plugin-0.14.0-1.el9.x86_64.rpm
docker-ce-26.1.3-1.el9.x86_64.rpm
docker-ce-cli-26.1.3-1.el9.x86_64.rpm
docker-ce-rootless-extras-26.1.3-1.el9.x86_64.rpm
docker-compose-plugin-2.27.0-1.el9.x86_64.rpm
fuse-overlayfs-1.13-1.el9.x86_64.rpm
fuse3-3.10.2-8.el9.x86_64.rpm
fuse3-libs-3.10.2-8.el9.x86_64.rpm
libslirp-4.4.0-7.el9.x86_64.rpm
selinux-policy-38.1.35-2.el9_4.0.2.noarch.rpm
selinux-policy-targeted-38.1.35-2.el9_4.0.2.noarch.rpm
slirp4netns-1.2.3-1.el9.x86_64.rpm
```

### 1.2. プライベート環境

先ほどダウンロードした以下のファイルを scp コマンドでインターネット通信不可な環境（プライベート環境）転送します。

- DockerのRPMパッケージのファイル（複数）
- DockerのPRMパッケージ検証鍵

scpで転送したら、RPMパッケージ検証鍵（GPG公開鍵）をインポートして dnf install でRPMパッケージをインストールします。

```bash
$ sudo rpm --import docker.gpg.key
$ sudo dnf install *.rpm
```

インストールが完了したら、dockerデーモンが起動するように設定しておきましょう。
以下のコマンドで systemctl enable + systemctl start ができます。

```bash
$ sudo systemctl enable --now docker
```

<br>

## 2. Dockerイメージの取得

dockerでコンテナを起動するとき、ローカルにDockerイメージが存在しないときはインターネットから取得しようとします。
しかし、今回のプライベート環境では、Dockerイメージの取得に失敗してしまいます。
そこで、まずインターネットに接続できる環境でコンテナを取得し、そのイメージをtarファイル化してプライベート環境に持ち込む、という作業を行います。

### 2.1. インターネット通信可な環境

Dockerイメージを取得するには、Dockerがインストールされていないとできないので、まずはDockerをインストールします。

```bash
~]$ sudo dnf install *.rpm
```

次に、Dockerのイメージを取得します。今回は Redmine サーバを構築するのに必要なイメージを取得します。
以下のRedmineの公式に書かれているdocker-compose.ymlを書いて、RedmineとMySQLのイメージを取得しておきます。

- [redmine - Official Image \| Docker Hub](https://hub.docker.com/_/redmine/)

```bash
$ mkdir redmine
$ cd redmine
$ cat <<EOS > docker-compose.yml
version: '3.1'

services:

  redmine:
    image: redmine
    restart: always
    ports:
      - 3000:3000
    environment:
      REDMINE_DB_MYSQL: db
      REDMINE_DB_PASSWORD: Password
      REDMINE_SECRET_KEY_BASE: supersecretkey

  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: Password
      MYSQL_DATABASE: redmine
EOS
$ docker compose up -d
$ docker compose ps
```

次に、現在のコンテナの状態を docker commit コマンドでコミットします。

```bash
docker commit redmine-redmine-1 redmine
docker commit redmine-db-1 mysql:8.0
```

コミットしたら、そのDockerイメージの内容を docker save コマンドで tar ファイルに保存します。

```bash
docker save -o redmine-redmine.tar redmine
docker save -o redmine-db.tar mysql:8.0
```

### 2.2. プライベート環境

先ほど保存したDockerイメージのファイルを scp コマンドでインターネット通信不可な環境（プライベート環境）転送します。
まず、インターネット通信可な環境と同じようにdocker-compose.ymlを書き、全体のコンテナ構成を定義します。

```bash
$ cat <<EOS > docker-compose.yml
...(同じ内容のため省略)...
EOS
```

次に、scp で転送しておいた、tar形式になっているDockerイメージファイルを、docker load コマンドで読み込みます。
正しく読み込めると、docker images コマンドで一覧に redmine と mysql:8.0 が表示されるようになります。

```bash
$ docker load -i redmine-redmine.tar
$ docker load -i redmine-db.tar
$ docker images
```

docker images コマンドの一覧にDockerイメージが存在するときは、Dockerイメージをインターネットから取得する代わりに、ローカルから取得するようになります。
この状態で docker compose up で起動することで、コンテナを起動することができるようになります。

```bash
$ docker compose up -d
```

以上です。


## 参考資料

- [docker-compose save/load images to another host - Stack Overflow](https://stackoverflow.com/questions/47855990/docker-compose-save-load-images-to-another-host)


