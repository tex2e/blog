---
layout:        post
title:         "AutoHotKeyで結合セルに1行ずつペースト"
date:          2020-06-18
category:      Keyboard
cover:         /assets/cover14.jpg
redirect_from: /misc/ahk-paste-to-excel-merged-cell
comments:      true
published:     true
latex:         false
# sitemap: false
# feed:    false
---

横に結合しているセルが複数行にわたってある状況で、複数行の文字列をペーストしたときに、それぞれの行をそれぞれの結合セルに貼り付けたいので、これをAutoHotKeyでできるようにします。

ちなみに、普通に貼り付けると「貼り付けようとしているデータと選択した領域のサイズと異なります。貼り付けますか？」とダイアログがでて、続行しようとすると「この操作は結合したセルには行えません。」となります（どうせ失敗するならダイアログで聞かないで欲しいのですが）。

Excelの複数行の結合セルに貼り付けるためのAutoHotKeyは次の通りです。
Alt + Shift + V で発動します。

```code
; Excelの複数行の結合セルに貼り付ける
!+v::
  Critical
  SetKeyDelay, 0
  Loop, parse, clipboard, `n, `r
  {
    line := StrReplace(A_LoopField, "`t")
    Send {F2}%line%{Enter}
  }
  Return
```

Critical は途中で他のキーが割り込んでこないようにするためです。
SetKeyDelay, 0 は、キータイプをより高速にします。
Loop ではクリップボードにあるテキストを1行ずつ処理します。
``StrReplace(A_LoopField, "`t")`` はクリップボード内のタブ文字を除去します。
これは、複数のセルや結合セルをコピーしたときに含まれるタブを除去するためのものです。
タブはアクティブなセルを右に移動させてしまうので、除去する必要があります。
各行の入力ではまずF2を押すとセルが編集状態になるので、行の内容を書き込み、最後にEnterを押して次の行に移動します。

本当は、結合セルにすること自体が間違っていて、結合セルはもはや諸悪の根源ですが、Excelを表計算としてではなく文書作成として使っている文化もあり、業務のプロセス上どうしても避けては通れない場合もあると思います（お察しください）。
