---
layout:        post
title:         "[Podman] Rocky LinuxにDocker/Podman Composeをインストールする"
date:          2024-11-26
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Docker ComposeをPodmanで実行するには、`podman compose` コマンドを使いますが、内部的には podman-compose または docker-compose コマンドに依存しています。ここでは、podman-compose または docker-composeコマンドのみをインストールする方法について説明します。

### （選択肢1） Podman Compose のインストール

podman-compose コマンドをpip経由でインストールすることで、Podman Compose を利用できるようになります。

```bash
$ sudo dnf install python
$ pip install podman-compose
```

以下のコマンドで動作確認できます。

```command
$ podman compose --version
>>>> Executing external compose provider "/home/mako/.local/bin/podman-compose". Please see podman-compose(1) for how to disable this message. <<<<

podman-compose version 1.2.0
podman version 5.2.2
```


### (選択肢2) Docker Compose のインストール

docker/compose のリリースページ [Releases · docker/compose](https://github.com/docker/compose/releases) から最新のバージョンを確認し、curlでダウンロードします。

```bash
$ sudo curl -L "https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```

以下のコマンドで動作確認できます。

```command
$ podman compose --version

>>>> Executing external compose provider "/usr/local/bin/docker-compose". Please see podman-compose(1) for how to disable this message. <<<<

Docker Compose version v2.30.3
```


### （補足）Docker Composeが存在しないとき

docker-composeコマンドをインストールしないで、`podman compose` を実行しようとすると以下のエラーが出力されます。

```console
Error: looking up compose provider failed
7 errors occurred:
    * exec: "docker-compose": executable file not found in $PATH
    * exec: "/home/<username>/.docker/cli-plugins/docker-compose": stat /home/<username>/.docker/cli-plugins/docker-compose: no such file or directory
    * exec: "/usr/local/lib/docker/cli-plugins/docker-compose": stat /usr/local/lib/docker/cli-plugins/docker-compose: no such file or directory
    * exec: "/usr/local/libexec/docker/cli-plugins/docker-compose": stat /usr/local/libexec/docker/cli-plugins/docker-compose: no such file or directory
    * exec: "/usr/lib/docker/cli-plugins/docker-compose": stat /usr/lib/docker/cli-plugins/docker-compose: no such file or directory
    * exec: "/usr/libexec/docker/cli-plugins/docker-compose": stat /usr/libexec/docker/cli-plugins/docker-compose: no such file or directory
    * exec: "podman-compose": executable file not found in $PATH
```

必ず、環境変数 PATH にパスが通っているところにインストールしてください。


以上です。


### 参考資料

- [Releases · docker/compose](https://github.com/docker/compose/releases)
