---
layout:        post
title:         "WindowsでCapsLockをF13に変更する"
date:          2020-07-11
category:      Keyboard
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---


Windows で CapsLock を F13 に変更するには、2通りの方法があります。

1. 直接レジスタを書き換える
2. 専用のソフト（ChangeKeyなど）を使ってレジスタを書き換える

他のキーも編集したい場合は ChangeKey などをインストールするのも手ですが、
CapsLock を Ctrl として使うための変更だけなので、以下のパッチをファイルに保存して実行（ダブルクリック）します。

map\_capslock\_to\_f13.reg

```code
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]
"Scancode Map"=hex:00,00,00,00,00,00,00,00,02,00,00,00,64,00,3a,00,00,00,00,00
```

実行するとレジスタが書き換わり、CapsLockを押すとF13が入力されます。

元に戻したい時は以下のパッチをファイルに保存して実行（ダブルクリック）します。

remove\_key\_mappings.reg

```code
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]
"Scancode Map"=-
```


### 参考

- [Windows registry patch to use CAPSLOCK as F13](https://gist.github.com/zkxs/2d570350489596145d956eeb55fe0562)
- [Push To Talk Fix - Remapping keys to F13](http://www.grismar.net/ventrilocapsfix/)
