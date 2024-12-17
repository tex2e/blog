---
layout:        post
title:         "[systemd] SSH接続を止めるとPodmanのルートレスコンテナが停止してしまうときの対処法"
date:          2024-12-17
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

SSH接続を止めるとPodmanのルートレスコンテナが停止してしまうときの対処法について説明します。

ここではPodmanと呼ばれるコンテナを動かすためのデーモンの話をしますが、Linuxのすべてのユーザ空間で動作するsystemdのプロセスも同様です。
まず、Podmanがルートレスコンテナを稼働させるときは、systemctl --user コマンドを使ってサービスを有効化します。

```bash
$ systemctl --user enable --now podman-restart
```

しかし、これだけでは、ユーザがSSH接続を止めると自動的にサービスも停止してしまいます。
そのため、Podmanがユーザ空間で動作するコンテナやPodを常に稼働させるためには、loginctlコマンドを使ってユーザのログイン設定を変更する必要があります。
linger とはセッションが終わった後もプロセスを稼働させ続けるための機能です。

```bash
$ sudo loginctl enable-linger USERNAME
```

このコマンドで指定したユーザの空間で動作するsystemdによって起動したプロセスは、ユーザのSSHセッションが切れた後も、サービスとして稼働し続けることができます。

以上です。
