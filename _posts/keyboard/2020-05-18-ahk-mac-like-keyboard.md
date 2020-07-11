---
layout:        post
title:         "AutoHotKeyでMacOS風のキーボード"
date:          2020-05-18
category:      Keyboard
cover:         /assets/cover1.jpg
redirect_from: /misc/ahk-mac-like-keyboard
comments:      true
published:     true
latex:         false
# sitemap: false
# feed:    false
---

MacOS使用者がWindowsでも快適にキーボードを使えるようにするためのAutoHotKeyの設定一覧

### 変換・無変換でIME On/Off

Mac ではスペースキーの左右にある「かな」と「英数」で半角全角を切り替えますが、
Windows ではスペースキーの左右にある「変換」キーと「無変換」キーでIMEのOnとOffを切り替えるようにします。

AutoHotKey.ahk

```code
; 無変換を押したときは、半角(IME off)
vk1C::
imeoff:
  Gosub, IMEGetstate
  If (vimestate=0) {
    Send, {vkf3}
  }
  return

; 変換を押したときは、全角(IME on)
vk1D::
imeon:
  Gosub, IMEGetstate
  If (vimestate=1) {
    Send, {vkf3}
  }
  return

IMEGetstate:
  WinGet, vcurrentwindow, ID, A
  vimestate := DllCall("user32.dll\SendMessageA", "UInt", DllCall("imm32.dll\ImmGetDefaultIMEWnd", "Uint", vcurrentwindow), "UInt", 0x0283, "Int", 0x0005, "Int", 0)
  return
```

### カーソル移動

Mac では control + N で下移動ができます。
Windows では control キーのところに CapsLock がありますが、Mac風キーボードに設定するために、これを F13（物理キーでは存在しない）キーに割り当てます。

CapsLock を F13 にするには、レジスタを書き換える必要があります。
以下のファイルを保存して実行するか、ChangeKey などのソフトを使用して変更してください。

map\_capslock\_to\_f13.reg

```code
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]
"Scancode Map"=hex:00,00,00,00,00,00,00,00,02,00,00,00,64,00,3a,00,00,00,00,00
```

CapsLock を F13 にしたら、次のAutoHotKeyの設定をします。

AutoHotKey.ahk

```code
F13 & f::Right     ; forward char
F13 & p::Up        ; previous line
F13 & n::Down      ; next line
F13 & b::Left      ; backward char
F13 & a::HOME      ; move beginning of line
F13 & e::END       ; move end of line
F13 & d::Del       ; delete char
F13 & h::BS        ; delete backward char
F13 & m::Enter     ; newline
```

Windows10 では CapsLock で半角/全角変換ができるので、MacOS風キーボードと共存させたいという人は次の設定を追加します。

```code
F13 Up::Send {vkF3}  ; CapsLockを離したときに全角半角が切り替わる
```

### アンダースコアをShiftなしで入力

プログラマーならよく使うアンダースコア「_」です。場所は右シフトの隣のキーです。
Mac だとキーを押すだけでアンダースコアが入力できますが、
Windows では Shift を押しながらでないとアンダースコアを入力できません。
普通、エンマーク「￥」を入力したいときは右上のキーを押すと思うので、アンダースコアを上書きして、Shiftなしで入力できるように設定します。

AutoHotKey.ahk

```code
vkE2::_
```

### カタカナ変換

Mac では入力した日本語をカタカナに変換したいときは Control + K を使います。
Windows では F7 でカタカナに変換しますが、手を大きく動かすのが大変なので、F13(CapsLock) + K でできるようにします。
ついでに、ひらがな変換も F13(CapsLock) + J でできるようにします。

AutoHotKey.ahk

```code
F13 & k::F7     ; Control-Kでカタカナに変換
F13 & j::F6     ; Control-Jでひらがなに変換
```

### Spotlight検索

Mac では Command + Space でSpotlight検索を開きますが、私個人の設定で Control + Space にしています。
Windows ではSpotlight検索の代わりに検索ボックスを開き、Winキー + S で検索ボックスが開きます。

AutoHotKey.ahk

```code
F13 & Space::#s  ; Control-SpaceでWindowsの検索ボックスを開く
```

### その他

他のキーボードの設定として、スクリーンショットや仮想デスクトップ切り替えなどがありますが、この辺は個人の好みがあると思うので、自分が使いたいように設定するのがいいと思います。

以上です。
