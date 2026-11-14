---
layout:        post
title:         "[Windows] バッチ実行時に管理者権限で動作しているか調べる"
type:          How-To
description:   "Windowsバッチで管理者権限が必要なopenfilesコマンドを実行し、%ERRORLEVEL%の値で管理者権限の有無を判定する処理を解説。"
tags:          [windows-batch, cmd, permissions, administration]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2023-04-22T10:38:07Z
date:          2023-04-22
category:      WindowsBatch
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windows には openfiles と呼ばれる管理者権限が必要なコマンドがあります。
このコマンドを実行した際のエラーレベルで、現在のコマンドプロンプトが管理者権限で実行されているかを確認することができます。

openfiles を使った管理者権限チェックは以下のようなプログラムになります。

```batch
rem 管理者権限チェック
openfiles > nul 2>&1
if not %ERRORLEVEL% == 0 (
  echo [-] This command prompt is NOT ELEVATED!
  goto L_end
)

rem ここに管理者権限で実行したコマンドを記載
type ctf_flag.txt

:L_end
pause
exit /b
```

openfiles の結果は出力させないで（NULにリダイレクトさせて）、その結果のステータスが 0 のときは管理者権限、それ以外のときは一般ユーザであることがわかります。
それを if 文で判定することで、管理者権限のときだけ実行したいコマンドを呼び出すことができます。

以上です。
