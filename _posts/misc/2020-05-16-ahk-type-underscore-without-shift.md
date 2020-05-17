---
layout:        post
title:         "AutoHotKeyでアンダースコアをShiftなしで入力する"
date:          2020-05-16
category:      Misc
cover:         /assets/cover1.jpg
redirect_from:
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
