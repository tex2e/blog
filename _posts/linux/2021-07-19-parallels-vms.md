---
layout:        post
title:         "Parallels 仮想環境のSSHサーバ設定"
date:          2021-07-19
category:      Linux
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


