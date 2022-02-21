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
6. ランダムな文字列やゼロで内容を上書きする
   - 方法1 : `shred -v -n 0 -z デバイス名` はゼロ塗りする
   - 方法2 : `shred -v -n 3 -z デバイス名` は3回ランダム文字列で書き込んだ後にゼロ塗りする
7. 非常に時間がかかるのでしばらく待つ
8. 全てのデバイスをゼロ塗りしたらシャットダウンする

#### 注意点
- HDDの書き込み機能が壊れている場合、ランダムな文字列を書き込むことができないです
- SSDの場合、ウェアレベリング機能によって上書きしてもデータが残留する可能性があります

#### 推奨事項
- PCは、常にBitLockerやFireVaultなどでディスクを暗号化して使用しましょう
- iPhoneの場合は、パスコードの入力に10回失敗するとデータが削除されるようにしましょう
- デバイスの中にある情報の機密レベルが高い場合は、物理破壊を検討しましょう

以上です。


### 参考文献

- [Linuxを利用したHDDの完全消去 - Linux解説 - 碧色工房](https://www.mm2d.net/main/tech/linux/hdd_clear-01.html)
