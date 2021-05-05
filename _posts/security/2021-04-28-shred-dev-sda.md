---
layout:        post
title:         "shredコマンドでHDD完全消去"
date:          2021-04-28
category:      Security
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

HDDを処分する前に行う完全消去手順のメモです。

1. Ubuntuのブータブルメディア(CD/DVD or USBメモリ)を作成する
2. USBメモリでブータブルメディアを作成した場合は、BIOSのブート画面で起動の優先順位でUSBを上げる。
3. CD/DVD or USBメモリを差し込んだ状態でPCの電源を入れ、Ubuntuにログインする
4. rootに昇格する
5. `fdisk -l` でデバイス名を確認する (/dev/sda, /dev/sdb, ...)
6. `shred -v -n 0 -z デバイス名` でゼロ塗りする
   - 3回乱数で書き込んだ後にゼロ塗りする場合はオプションを `-n 3` にする。HDDは媒体面の残留磁気などの痕跡による元の値を推測される可能性があるため。SSDの場合は `-n 0` でOK。
7. 非常に時間がかかるのでしばらく待つ
8. 全てのデバイスをゼロ塗りしたらシャットダウンする

以上です。


### 参考文献

- [Linuxを利用したHDDの完全消去 - Linux解説 - 碧色工房](https://www.mm2d.net/main/tech/linux/hdd_clear-01.html)
