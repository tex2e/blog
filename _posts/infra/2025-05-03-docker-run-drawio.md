---
layout:        post
title:         "[Docker] drawioコンテナを起動する"
type:          How-To
description:   "DockerやPodmanコマンドを用いてdraw.ioの公式コンテナをローカルポート18080で起動する手順。"
tags:          [infra, docker, podman, drawio]
status:        stable
stale_after:   2028-05-03T00:00:00Z
generated:
  by:          human:tex2e
  at:          2025-05-03T01:58:49Z
sources:
  - id:        ref-1
    resource:  https://www.drawio.com/blog/diagrams-docker-app
    title:     "Blog - Run your own draw.io server with Docker"
date:          2025-05-03
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

dockerでdrawioコンテナを起動する方法について説明します。

dockerコマンドで起動するとき：

```bash
docker run -it -d --rm --name="draw" -p 18080:8080 -p 18443:8443 jgraph/drawio
```

podmanコマンドで起動するとき：

```bash
podman run -it -d --rm --name="draw" -p 18080:8080 -p 18443:8443 jgraph/drawio
```

localhost:18080 にアクセスして、drawioのページが表示されるか確認してください。


### 参考資料

- [Blog - Run your own draw.io server with Docker](https://www.drawio.com/blog/diagrams-docker-app)
