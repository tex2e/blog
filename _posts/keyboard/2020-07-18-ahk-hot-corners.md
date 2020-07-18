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
syntaxhighlight: true
# sitemap: false
# feed:    false
---

Macのホットコーナーは非常に便利ですがWindowsにはありません。そこでAutoHotkeyを使ってホットコーナー機能を実現させたいと思います。AutoHotkeyを使っている人向けの説明となります。

まず、以下のスクリプトを HotCorners.ahk などの名前で保存します。

```code
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
      break ; exits loop when mouse is no longer in the corner
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
      break ; exits loop when mouse is no longer in the corner
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
      break ; exits loop when mouse is no longer in the corner
  }
}
```

次に保存したスクリプトを実行します。
このときの注意点ですが、HotCorners.ahk は単体で実行してください。
つまり、既存のAutoHotkeyのスクリプトに付け加えたり、`#Include`で呼び出してはいけません。
タスクバーには、既存のAutoHotkey.exeと新規作成したHotCorners.exeの2つのプロセスが常駐しているのが正しい状態です。

実行したらマウスを画面の左下や右下に移動して、スタートメニューやアクションセンターが表示されれば成功です。

スタートアップに、HotCorners.exe を配置するのも忘れずに。

以上です。
