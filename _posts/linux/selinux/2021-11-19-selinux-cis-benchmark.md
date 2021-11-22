---
layout:        post
title:         "CIS Benchmarkを元にSELinuxの設定をする"
date:          2021-11-19
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

CIS BenchmarkとはCISが開発した情報システムを安全に構成するためのベストプラクティス集です。
ここでは CIS_CentOS_Linux_8_Benchmark_v1.0.1.pdf を参考に、SELinuxの設定の確認と修正について説明します。

PDFは [CIS Benchmark Downloads](https://downloads.cisecurity.org/#/) からダウンロードできます。

以下、SELinuxの設定についてです。

#### SELinuxがインストール済み
確認方法：以下のコマンドでバージョンが出力されること
```bash
~]# rpm -q libselinux
libselinux-<version>
```
修正方法：
```bash
~]# dnf install libselinux
```

#### ブートローダーの設定でSELinuxが有効 (CentOS7)
確認方法：以下のコマンドで出力がないこと
```bash
~]# grep -E 'kernelopts=(\S+\s+)*(selinux=0|enforcing=0)+\b' /boot/grub2/grubenv
```
修正方法：/etc/default/grubファイルの変数 GRUB_CMDLINE_LINUX_DEFAULT や GRUB_CMDLINE_LINUX から `selinux=0` と `enforcing=0` の文字列を削除した後、以下のコマンドを実行する。
```bash
~]# grub2-mkconfig -o /boot/grub2/grub.cfg
```

#### ブートローダーの設定でSELinuxが有効 (CentOS6)
確認方法：以下のコマンドで出力がないこと
```bash
~]# [ -f /boot/efi/EFI/*/grub.conf ] && grep '^\s*kernel' /boot/efi/EFI/*/grub.conf | grep -E '(selinux=0|enforcing=0)' || grep '^\s*kernel' /boot/grub/grub.conf | grep -E '(selinux=0|enforcing=0)'
```
修正方法：/boot/efi/EFI/*/grub.confファイルから `selinux=0` と `enforcing=0` の文字列を削除した後、システムの再起動をします。

#### SELinuxポリシーが設定済み
確認方法：以下のコマンドで出力されること
```bash
~]# grep -E '^\s*SELINUXTYPE=(targeted|mls)\b' /etc/selinux/config
```
修正方法：/etc/selinux/configファイルを編集して `SELINUXTYPE=targeted` を設定する（再起動が必要）。

#### Enforceモードで有効
確認方法：以下のコマンドで出力されること
```bash
~]# grep -E '^\s*SELINUX=enforcing' /etc/selinux/config
```
修正方法：/etc/selinux/configファイルを編集して `SELINUX=enforcing` を設定する（再起動が必要）。


#### 制限のないサービスが未稼働
確認方法：以下のコマンドで出力がないこと
```bash
~]# ps -eZ | grep unconfined_service_t
```
修正方法：実行するファイルにSELinuxコンテキストの bin_t が割り当てられないように chcon や semanage fcontext で実行ファイルのタイプを修正する。

bin_t や unconfined_service_t については、[SELinuxによるコマンドに対する制限を完全に無くす](http://localhost:4000/blog/linux/selinux-unrestricted-process) を参照してください。

#### SETroubleshootが未インストール
SELinuxのトラブルシューティング機能。

確認方法：以下のコマンドでバージョンが出力されないこと
```bash
~]# rpm -q setroubleshoot
package setroubleshoot is not installed
```
修正方法：
```bash
~]# dnf remove setroubleshoot
```

#### MCS Translation Service (mcstrans) が未インストール
SELinux において MCS (Multi Category Security) をユーザ向けに分かりやすく表示する機能。

確認方法：以下のコマンドでバージョンが出力されないこと
```bash
~]# rpm -q mcstrans
package mcstrans is not installed
```
修正方法：
```bash
~]# dnf remove mcstrans
```

以上です。


#### 参考文献

- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [CIS Downloads > CentOS](https://downloads.cisecurity.org/#/)
