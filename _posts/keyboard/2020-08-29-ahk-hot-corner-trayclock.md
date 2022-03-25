---
layout:        post
title:         "AutoHotkeyで通知領域のカレンダーを表示する"
date:          2020-08-29
category:      Keyboard
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Window 10 + AutoHotkey でマウスが画面右下に来た時に、通知領域のカレンダーを表示する方法について説明します。

基本的には、「[AutoHotkeyでMacのホットコーナーを実装する](./ahk-hot-corners)」
を使いますので、まずはこの記事からコードをコピーします。
ここでは HotCorners.ahk というファイルで保存します。

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
  CornerBottomRight := ((MouseY > Ymax - T and MouseX > Xmax - T) or (OutputVarControl = "TrayShowDesktopButtonWClass1"))  ; 右下判定

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
```

そして、HotCorners.ahk の画面右下に来た時の処理部分で、TrayClockWClass1 をクリックするように処理を修正します。

```ahk
if IsCorner("BottomRight")
{
  ; 通知領域にフォーカスをあてる
  WinActivate, ahk_class Shell_TrayWnd
  ; ESCは2回目のときにカレンダーが閉じるようにするため
  Send {ESC}
  ; 通知領域の時計/カレンダー部分をクリックする
  ControlClick, TrayClockWClass1, ahk_exe explorer.exe ahk_class Shell_TrayWnd

  Loop
  {
    if ! IsCorner("BottomRight")
      break ; マウスが画面右下から離れたときに処理を抜ける
  }
}
```

ポイントは、対象のコントロール(TrayClockWClass1)をクリックする前に、通知領域にフォーカスをあてる点です。
これがないと、ただしく反応しない場合があります。
さらに、画面右下1回目のときはカレンダーを表示して、2回目のときは非表示にするために、ESCを送信しています。

画面上のコントロールの取得には AutoHotkey インストール時に一緒に付いてくる Window Spy を使うのがオススメです。
Windowsの検索 > Window Spy > Follow Mouse のチェックボックスを入れる > 対象のコントロールの上にマウスを移動 > そのときの ahk_class と ClassNN をメモしておく。という流れでコントロール名を取得することができるので、AHK の関数である WinActivate と Control* を使って操作ができます。

以上です。
