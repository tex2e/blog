---
layout:        post
title:         "Ubuntu 20.04でSELinuxを有効化する"
date:          2022-03-12
category:      Linux
cover:         /assets/cover6.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Ubuntuには標準で AppArmor という SELinux に似たMACのアクセス制御システムがあります。
AppArmor と SELinux はどちらもプロセスの動作を制御する仕組みです。
AppArmor の方が簡単で導入しやすいですが、本記事ではより広範囲を守れる SELinux を導入する方法を説明します。

今回の導入環境は Ubuntu 20.04 です。
```bash
$ cat /etc/os-release
NAME="Ubuntu"
VERSION="20.04.2 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.2 LTS"
VERSION_ID="20.04"
```

まず、SELinux を入れる前に AppArmor を無効化します。AppArmor と SELinux の競合を避けるためです。
```bash
$ sudo systemctl stop apparmor
$ sudo apt remove apparmor
```

SELinux に必要なパッケージと、auditd サービスをインストールします。
終わったら、SELinux が正しくインストールされたことを確認するために sestatus コマンドを実行します。
```bash
$ sudo apt-get install selinux-utils selinux-basics auditd audispd-plugins
$ sudo sestatus
SELinux status:   disabled
```

次に、SELinuxを有効化するためのコマンド selinux-activate を実行します。
```bash
$ sudo selinux-activate
Activating SE Linux
Sourcing file '/etc/default/grub'
Sourcing file '/etc/default/grub.d/init-select.cfg'
Generating grub configuration file ...
Linux イメージを見つけました: /boot/vmlinuz-5.11.0-37-generic
Found initrd image: /boot/initrd.img-5.11.0-37-generic
Linux イメージを見つけました: /boot/vmlinuz-5.11.0-36-generic
Found initrd image: /boot/initrd.img-5.11.0-36-generic
Linux イメージを見つけました: /boot/vmlinuz-5.8.0-48-generic
Found initrd image: /boot/initrd.img-5.8.0-48-generic
Adding boot menu entry for UEFI Firmware Settings
完了
SE Linux is activated.  You may need to reboot now.
```

完了したら、サーバを再起動します。
```bash
$ sudo reboot
```

再起動後に再度 sestatus コマンドを実行して、enabled になっていれば SELinux が有効になっています。
デフォルトでは permissive モードで動いているので、有効化されていますがアクセス拒否はしないモードで動いている点に注意です。
```bash
$ sudo sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             default
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     requested (insecure)
Max kernel policy version:      33
```

まず、`sudo setenforce 1` で問題なく動作することを確認したら、/etc/seinux/config を編集して `SELINUX=enforcing` に書き換えて再起動すると、強制モード (Enforcing) になります。

以上です。

### 参考文献
- [How to Install SELinux on Debian 10 \| Linode](https://www.linode.com/docs/guides/how-to-install-selinux-on-debian-10/)
