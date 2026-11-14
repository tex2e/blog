---
layout:        post
title:         "[Docker] コンテナにマウントしているパスの一覧を表示する"
type:          How-To
description:   "起動中のDockerコンテナにマウントされているホスト側・コンテナ側のディレクトリパスをdocker inspectで確認する方法。"
tags:          [infra, docker, cli]
status:        stable
stale_after:   2027-07-21T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-18T12:44:35Z
date:          2021-12-03
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from: /linux/docker-inspect-mount
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

起動しているDockerコンテナがホストのディレクトリをマウントしているかや、どのディレクトリがマウントされているかは「docker inspect」コマンドで調べることができます。
```bash
~]$ docker ps -a
~]$ docker inspect コンテナID
```
以下はコンテナ起動時に -v /var/mnt:/var/mnt を指定したときの結果です。
Sourceがホスト側のディレクトリ、Destinationがコンテナ側のディレクトリです。
```bash
~]$ docker inspect コンテナID | grep -A9 Mounts
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/var/mnt",
                "Destination": "/var/mnt",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],
```
以上です。
