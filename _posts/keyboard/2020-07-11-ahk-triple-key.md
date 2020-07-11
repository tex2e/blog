---
layout:        post
title:         "AutoHotkeyで3キー同時押し"
date:          2020-07-11
category:      Keyboard
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

3つのキーを同時入力するとき、例えば Ctrl + Shift + N は `^+n` ですが、CapsLock を Ctrl キーとしてF13に割り当てて使うとき `F13 & +n` と書くとコンパイルエラーになるので、これを回避する方法について説明します。

3キー同時押しを取得するには GetKeyState 関数を使います。
GetKeyState は任意のキーボードの状態を取得する関数で、第1引数でキーの名前、第2引数でキーのモード（省略時は論理キーの状態、"P"は物理キーの状態、"T"はOn/Offが切り替わったかを取得）を選択できます。

```code
F13 & n::
  if GetKeyState("Shift") {
    Send ^+n
    return
  }
  Send ^n
  return
```

上の例では、CapsLock(F13) + Shift + N を押したときは Ctrl + Shift + N が入力され、
CapsLock(F13) + N を押したときは Ctrl + N が入力されます。


### 参考

- [GetKeyState - Syntax & Usage \| AutoHotkey](https://www.autohotkey.com/docs/commands/GetKeyState.htm)
- [WindowsでCapsLockをF13に変更する](/blog/keyboard/win-keymap-caps-to-ctrl)
