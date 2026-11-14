---
layout:        post
title:         "Parallels 仮想環境のSSHサーバ設定"
type:          How-To
description:   "macOSのParallels上でKali LinuxとFedoraにOpenSSHサーバとsudo権限付きユーザをセットアップする手順をまとめます。"
tags:          [linux, parallels, ssh, kali-linux, fedora]
status:        stable
stale_after:   2025-03-13T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-07-19T14:03:43Z
date:          2021-07-19
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

MacOS の Parallels で Kali Linux と Fedora のセットアップをしたときの備忘録です。

### Kali Linux

- 設定 : ハードウェア > ネットワーク > ソース : Host-Only

```bash
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh

sudo useradd mako
sudo passwd mako
sudo usermod -aG sudo mako
```


### Fedora

- 設定 : ハードウェア > ネットワーク > ソース : Host-Only

```bash
sudo dnf install -y openssh-server
sudo systemctl enable sshd
sudo systemctl restart sshd
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --reload

sudo useradd mako
sudo passwd mako
sudo usermod -aG wheel mako
```


