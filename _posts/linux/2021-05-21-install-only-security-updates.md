---
layout:        post
title:         "apt upgradeでセキュリティアップデートのみ適用する"
date:          2021-05-21
category:      Linux
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ubuntuにsshでログインするとセキュリティアップデートの有無が確認できます。
以下の例では6件あります。

```output
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-72-generic x86_64)

25 updates can be installed immediately.
6 of these updates are security updates.
To see these additional updates run: apt list --upgradable

myname@host:~$
```

apt upgradeだと全てのアップデートを適用してしまいますが、
本番環境などでは実行できなくなるリスクを最小限にするためにセキュリティアップデートのみを入れたいときがあります。
そこで、セキュリティアップデートだけを入れる場合は unattended-upgrade コマンドを使います。
何がインストールされるか、正しくインストールされるか確認するために --dry-run オプションを加えて実行すると良いでしょう。

```bash
sudo unattended-upgrade --dry-run
sudo unattended-upgrade
```

実行例：

```output
$ sudo unattended-upgrade --dry-run
/usr/bin/dpkg --status-fd 10 --no-triggers --unpack --auto-deconfigure /var/cache/apt/archives/bind9-host_1%3a9.16.1-0ubuntu2.8_amd64.deb
/usr/bin/dpkg --status-fd 10 --configure --pending
/usr/bin/dpkg --status-fd 10 --no-triggers --unpack --auto-deconfigure /var/cache/apt/archives/libunbound8_1.9.4-2ubuntu1.2_amd64.deb
/usr/bin/dpkg --status-fd 10 --configure --pending
/usr/bin/dpkg --status-fd 10 --no-triggers --unpack --auto-deconfigure /var/cache/apt/archives/unbound-anchor_1.9.4-2ubuntu1.2_amd64.deb
/usr/bin/dpkg --status-fd 10 --configure --pending
/usr/bin/dpkg --status-fd 10 --no-triggers --unpack --auto-deconfigure /var/cache/apt/archives/bind9-dnsutils_1%3a9.16.1-0ubuntu2.8_amd64.deb /var/cache/apt/archives/bind9-libs_1%3a9.16.1-0ubuntu2.8_amd64.deb
/usr/bin/dpkg --status-fd 10 --configure --pending
/usr/bin/dpkg --status-fd 10 --no-triggers --unpack --auto-deconfigure /var/cache/apt/archives/unbound_1.9.4-2ubuntu1.2_amd64.deb
/usr/bin/dpkg --status-fd 10 --configure --pending

$ sudo unattended-upgrade

$
```

以上です。

### 参考文献

- [package management - How can I install just security updates from the command line? - Ask Ubuntu](https://askubuntu.com/questions/194/how-can-i-install-just-security-updates-from-the-command-line)

