---
layout:        post
title:         "Docker-composeインストール後のエラー「error while loading shared libraries: libz.so.1」の対処法"
date:          2021-12-04
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from: /linux/docker-compose-error
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

docker-composeインストール後にバージョンを確認しようとしたら、エラー「error while loading shared libraries: libz.so.1」が出たので、そのときの対処法について説明します。

まず、dockerコマンドは問題ないのに、docker-composeコマンドだけエラーになる状態であることが前提です。
```bash
~]# docker --version
Docker version 20.10.10, build b485636
~]# docker-compose --version
docker-compose: error while loading shared libraries: libz.so.1: failed to map segment from shared object
```
セキュリティ対策の一つで /tmp ディレクトリ以下のファイルは実行できないように設定をしていたため、docker-compose コマンドが起動できなかったようです。
そこで、/tmp に設定していた noexec を exec に変更してから再度マウントします。
```bash
~]# mount | grep /tmp
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,noexec,seclabel)

~]# mount /tmp -o remount,exec

~]# mount | grep /tmp
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,seclabel)
```
/tmp を exec にすると docker-compose コマンドが使えるようになりました。
```bash
~]# docker-compose --version
docker-compose version 1.29.2, build 5becea4c
```
systemctl で /tmp 内のファイルを実行不可にするセキュリティ対策の設定をしていたため、今回の事象が発生しました。
docker-compose を使用する場合は /tmp を noexec に設定することはできないようです。

以上です。

#### 参考文献
- [docker-composeインストール時に「docker-compose: error while loading shared libraries: libz.so.1: failed to map segment from shared object: Operation not permitted」が発生した場合の対処法 \| mebee](https://mebee.info/2020/06/26/post-12662/)
