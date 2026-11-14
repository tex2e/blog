---
layout:        post
title:         "AutoHotKeyでアンダースコアをShiftなしで入力する"
type:          How-To
description:   "Windows上でAutoHotkeyを使いShiftキーを押さずにアンダースコアを入力するためのキー割り当て設定とバージョン別の記述法。"
tags:          [keyboard, autohotkey, windows]
status:        stable
stale_after:   2023-05-17T00:00:00Z
generated:
  by:          human:tex2e
  at:          2020-05-17T06:49:46Z
sources:
  - id:        ref-1
    resource:  https://qiita.com/totto357/items/5d86ee80a654dd9ec95f
    title:     "AutoHotKeyの1.1.27.07にしたらInvalid hotkeyエラー - Qiita"
  - id:        ref-2
    resource:  "https://www.autohotkey.com/docs/AHKL_ChangeLog.htm#v1.1.27.00"
    title:     "Changes & New Features \\| AutoHotkey"
date:          2020-05-16
category:      Keyboard
cover:         /assets/cover14.jpg
redirect_from: /misc/ahk-type-underscore-without-shift
comments:      true
published:     true
latex:         false
# sitemap: false
# feed:    false
---

プログラミングなどではアンダースコアを入力することが多いですが、
Macのキーボードのように、Windowsでアンダースコア `_` をShiftなしで入力するための AutoHotKey の設定について説明します。

AutoHotKey v1.1.27 以降の最近の環境では以下のように書きます：

```code
vkE2::_
```

AutoHotKey v1.1.26 以前の環境では以下のように書きます：

```code
vkE2sc073::_
```

AutoHotKey v1.1.27 以降では、キーの名前が vkNNscNNN から vkNN に変更された (scNNN を削除するだけでよい) ので、古い文献を見るときは注意が必要です。

### 参考文献

- [AutoHotKeyの1.1.27.07にしたらInvalid hotkeyエラー - Qiita](https://qiita.com/totto357/items/5d86ee80a654dd9ec95f)
- [Changes & New Features \| AutoHotkey](https://www.autohotkey.com/docs/AHKL_ChangeLog.htm#v1.1.27.00)
