---
layout:        post
title:         "AutoHotKeyで選択文字をダブルクオーテーションや丸括弧で囲む"
date:          2020-06-19
category:      Keyboard
cover:         /assets/cover1.jpg
redirect_from: /misc/ahk-enclose
comments:      true
published:     true
latex:         false
# sitemap: false
# feed:    false
---

最近のエディタなら範囲選択して「"」を押すとダブルクオーテーションで囲まれたり、「(」を押すと丸括弧で囲まれたりしますが、古いエディタやIDEにはこのような機能がないので、AutoHotKeyでこの機能を作ります。

作成するAutoHotKeyは次の通りです。
F13 + (Shift + ) 2 でダブルクオート、F13 + (Shift + ) 8 で丸括弧で囲む処理が発動します（私の環境では CapsLock を F13 に割り当てています）。


```code
; 選択文字を「"」「'」「()」で囲む処理

F13 & ':: Enclose("'", "'")
F13 & ":: Enclose("""", """")
F13 & (:: Enclose("(", ")")
F13 & ):: Enclose("(", ")")

Enclose(begin, end) {
  oldClipboard = %Clipboard%
  Clipboard =
  Send, ^c
  ClipWait
  If (!ErrorLevel) {
    StringRight, LastChar, Clipboard, 1
    If (LastChar != "`n") {
      WinGetTitle, CurrentWinTitle
      Clipboard = %begin%%Clipboard%%end%
      ClipWait
      WinActivate, %CurrentWinTitle%
      Send, ^v
      Sleep 150
    }
    Clipboard = %oldClipboard%
  }
  Return
}
```

選択範囲を文字で囲む処理の流れを説明すると、

1. クリップボードを使うため、すでにクリップボードにある内容を退避させます。
2. 選択範囲をコピーします（Send ^c）
3. クリップボードにデータが格納されるのを待ちます（ClipWait）
4. クリップボードにデータがないとき（ErrorLevel != 0）、処理を中断します。
5. データの最後の1文字が改行のとき、処理を中断します。
6. データの前後に囲む文字を置いてクリップボードに格納します。
7. ペーストします（Send ^v）
8. 退避させた内容をクリップボードに戻します。

WinGetTitle と WinActivate のところは、アクティブなウィンドが処理中に変更しないことを保証するためのものです。


### 参考

- [Autohotkey to put the selected text in smart quotes - Stack Overflow](https://stackoverflow.com/questions/9909713/autohotkey-to-put-the-selected-text-in-smart-quotes)
- [📇 (autohotkey) - wrap selected text in *symbols*](https://gist.github.com/davebrny/088c48d6678617876b34f53571e92ee6)
- [WindowsでCapsLockをF13に変更する](/blog/keyboard/win-keymap-caps-to-ctrl)
