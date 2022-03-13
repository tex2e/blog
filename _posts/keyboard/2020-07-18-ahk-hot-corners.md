---
layout:        post
title:         "AutoHotkeyでMacのホットコーナーを実装する"
date:          2020-07-18
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

Macのホットコーナーは非常に便利ですがWindowsにはありません。そこでAutoHotkeyを使ってホットコーナー機能を実現させたいと思います。AutoHotkeyを使っている人向けの説明となります。

まず、以下のスクリプトを HotCorners.ahk などの名前で保存します（すでにあるAutoHotKey用のスクリプトとは別のファイルに保存してください）。

```ahk
#Persistent  ; スクリプトを常駐させる
SetTimer, HotCorners, 0  ; タイマーを使ってサブルーチンを0秒ごとに実行する
return
HotCorners:
CoordMode, Mouse, Screen  ; スクリーン上のマウス座標を取得する

IsCorner(cornerID)
{
  WinGetPos, X, Y, Xmax, Ymax, Program Manager  ; スクリーンのサイズを取得
  MouseGetPos, MouseX, MouseY  ; マウス座標の取得
  T = 5  ; マウス座標の許容範囲
  CornerTopLeft := (MouseY < T and MouseX < T)  ; 左上判定
  CornerTopRight := (MouseY < T and MouseX > Xmax - T)  ; 右上判定
  CornerBottomLeft := (MouseY > Ymax - T and MouseX < T)  ; 左下判定
  CornerBottomRight := (MouseY > Ymax - T and MouseX > Xmax - T)  ; 右下判定

  if (cornerID = "TopLeft"){
    return CornerTopLeft
  }
  else if (cornerID = "TopRight"){
    return CornerTopRight
  }
  else if (cornerID = "BottomLeft"){
    return CornerBottomLeft
  }
  else if  (cornerID = "BottomRight") {
    return CornerBottomRight
  }
}

; 右上はタスクビュー
if IsCorner("TopRight")
{
  Send, {LWin down}{tab down}
  Send, {LWin up}{tab up}
  Loop
  {
    if ! IsCorner("TopRight")
      break  ; マウスが画面角から離れたときに処理を抜ける
  }
}

; 右下はアクションセンター
if IsCorner("BottomRight")
{
  Send, {LWin down}{a down}
  Send, {LWin up}{a up}
  Loop
  {
    if ! IsCorner("BottomRight")
      break  ; マウスが画面角から離れたときに処理を抜ける
  }
}

; 左下はスタートメニュー
if IsCorner("BottomLeft")
{
  Send, {LWin down}
  Send, {LWin up}
  Loop
  {
    if ! IsCorner("BottomLeft")
      break  ; マウスが画面角から離れたときに処理を抜ける
  }
}
```

次に保存したスクリプトを実行します。
このときの注意点ですが、HotCorners.ahk は単体で実行してください。
つまり、上記のコードを既存のAutoHotkeyのスクリプトに付け加えたり、`#Include`で呼び出してはいけません。
タスクバーには、キーマップをカスタマイズしている既存のAutoHotkey.exeと、本記事で新規作成したHotCorners.exeの2つのプロセスが常駐しているのが正しい状態です。

実行したらマウスを画面の左下や右下に移動して、スタートメニューやアクションセンターが表示されれば成功です。
スタートアップに、HotCorners.exe を配置するのも忘れずに。


### ディスプレイが複数ある場合

ディスプレイが複数ある場合は、上記のやりかたではホットコーナーを実現できません。
なぜなら、WinGetPos はメインのディスプレイの幅・高さを取得しますが、
MouseGetPos は全てのディスプレイを包含する最小包囲長方形 (Minimum Bounding Rectangle; MBR) での位置を取得するので、
座標の原点がそもそも異なってしまうためです。

解決方法は見つけられなかったのですが、複数ディスプレイの環境でも、画面右下の部分だけはAutoHotKeyで検出することが可能です。
具体的には、上記コードのコーナー判定部分を以下のように修正します。

```ahk
IsCorner(cornerID)
{
  ...

  CornerBottomRight := (OutputVarControl = "TrayShowDesktopButtonWClass1")  ; 右下判定

  ...
}
```

`TrayShowDesktopButtonWClass1` はタスクバーの一番右にある細い縦線の部分です。
このコントロールの上にマウスが乗ったときに、マウスが画面右下にあると判断します。


以上です。


### おまけ

- [AutoHotKeyで通知領域のカレンダーを表示する](./ahk-hot-corner-trayclock)
