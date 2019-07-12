---
layout:        post
title:         "技術検証用にCentOS7を仮想環境にインストールする"
menutitle:     "技術検証用にCentOS7を仮想環境にインストールする"
date:          2019-07-12
tags:          Linux
category:      Linux
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

技術検証用にVirtualBoxの仮想環境でCentOS7をインストールして、3つのサーバを用意し、それぞれに公開鍵を登録してSSH公開鍵認証ができるようにするまでの環境構築メモです。


### OSインストール

1. [CentOSのミラーサイト一覧](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso)にアクセスして、住んでいる場所から一番近いミラーサイトからCentOSをダウンロードする (私は ftp.jaist.ca.jp にしました)

2. VirtualBoxの「新規」から新しい仮想環境を作る。HDDは**可変**で**8GB**のままで良い

3. 「設定」のシステムで、メモリは最低**2GB**、プロセッサは**2CPU**にする

4. 「設定」のネットワークで、アダプター2を有効化し、**ホストオンリーアダプター**にする

5. ストレージで、光学ドライブにダウンロードしたisoファイルを選択する

6. 仮想環境を起動する

7. OSインストールする。終わったら再起動する

8. **スナップショットを作成する** (名前は「インストール直後」などにする)

### IPアドレスの設定

#### enp0s3 の設定 (仮想環境とホストとの通信)

まず、ネットワークに繋がるように設定する。
`ping 8.8.8.8` と叩いて繋がる場合はこの作業は必要ない。
ネットに繋がらない場合は、以下の設定ファイルを編集する。

```bash
$ cd /etc/sysconfig/network-scripts/
$ cp ifcfg-enp0s3 ifcfg-enp0s3.bak
$ vi ifcfg-enp0s3
```

編集内容

```diff
 TYPE=Ethernet
 PROXY_METHOD=none
 BROWSER_ONLY=no
 BOOTPROTO=dhcp
 DEFROUTE=yes
 IPV4_FAILURE_FATAL=no
 IPV6INIT=yes
 IPV6_AUTOCONF=yes
 IPV6_DEFROUTE=yes
 IPV6_FAILURE_FATAL=no
 IPV6_ADDR_GEN_MODE=stable-privacy
 NAME=enp0s3
 UUID=d163ddae-e9af-465f-ba3c-778a0fe84a47
 DEVICE=enp0s3
-ONBOOT=no
+ONBOOT=yes
```

再起動後に `ping 8.8.8.8` と叩いて繋がったらOK


#### enp0s8 の設定 (仮想環境同士の通信)

次に、仮想環境同士で通信時に使用するIPアドレスを固定する。

```bash
$ cd /etc/sysconfig/network-scripts/
$ cp ifcfg-enp0s3 ifcfg-enp0s8
$ vi ifcfg-enp0s8
```

編集内容

```txt
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
NAME=enp0s8
DEVICE=enp0s8
ONBOOT=yes
ZONE=public
IPADDR=192.168.1.2
PREFIX=24
```

再起動後に `ip a` で確認して、enp0s8 に 192.168.1.2 と書かれてあればOK。


### SSHの設定

仮装環境が起動している場合は一旦終了する。そして、

1. 設定のネットワークを開いて、アダプター1のポートフォーワーディングの設定を行う。
2. 右上の追加ボタンを押し、名前「ssh」、ホストポート「2222」、ゲストポート「22」とする。



### 仮装環境のクローン

検証用サーバを3つ作るために、初期状態の仮想環境を3つ用意する。それぞれの名前は CentOS7-1, CentOS7-2, CentOS7-3 とする。
クローンしたら、設定のネットワークを開いて、アダプター1のポートフォーワーディングの設定を行う。

| Name      | SSH Port | HTTP Port | IP Address (enp0s8) |
|-----------|----------|-----------|---------------------|
| CentOS7-1 | 2222     | 8800      | 192.168.1.2         |
| CentOS7-2 | 2223     | 8801      | 192.168.1.3         |
| CentOS7-3 | 2224     | 8802      | 192.168.1.4         |

それぞれのサーバで設定をしたら、別の仮装環境から ping 192.168.1.2 などと叩いて繋がればOK

CentOS7-1の仮想環境を起動していると 127.0.0.1:2222 にSSHサーバが起動するので、.ssh/config には次のように設定する。
秘密鍵・公開鍵を作っていない場合は、`ssh-keygen -t ed25519` で作っておく。

.ssh/config

```txt
Host local?
  HostName 127.0.0.1
  User root
  IdentityFile ~/.ssh/id_25519
Host local1
  Port 2222
Host local2
  Port 2223
Host local3
  Port 2224
```

公開鍵認証でSSHログインできるようにする (公開鍵をそれぞれのサーバに登録する)。

```bash
$ ssh-copy-id -i .ssh/id_ed25519 local1
$ ssh-copy-id -i .ssh/id_ed25519 local2
$ ssh-copy-id -i .ssh/id_ed25519 local3

$ ssh local1
$ ssh local2
$ ssh local3
```

ここまでできたら、必ず**スナップショット**をとる。
技術検証をしたら、ここでとったスナップショットに戻ることで何回もこの仮想サーバを利用することができる。


### 設定のまとめ

- ホストから仮想環境にアクセスするには 127.0.0.1:xxx (ポートフォーワーディングする必要がある)
- 仮想環境同士の通信は 192.168.1.x で行う。
- ホストのターミナルからSSH接続するには `ssh localX` (Xは整数)
- 技術検証をし終わったら、スナップショットしたところに復元する。
