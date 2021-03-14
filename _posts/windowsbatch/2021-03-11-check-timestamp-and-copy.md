---
layout:        post
title:         "batchで更新時間が違うときだけコピーする"
date:          2021-03-12
category:      WindowsBatch
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

Windowsのバッチでコピーするときに更新時間を比較して一致していればコピーしない方法について説明します。
まず、更新時間を比較する方法ですが、次のようにチルダを使って更新時間を取得します。

- batchの引数 `%1` の更新時間は `%~t1%`
- for文の繰り返し変数 `%%i` のときは `%%~ti`

変数内のファイル名からは直接更新時間を取得できないので、その場合、一回 for 文を経由してから取得します。

from.dll と to.dll の更新時間が異なるときに、from から to にコピーするバッチコマンドは以下のようになります。

```batch
set from=from.dll
set to=to.dll
for %%i in (%from%) do set DATE1=%%~ti
for %%i in (%to%)   do set DATE2=%%~ti
if not "%DATE1%"=="%DATE2%" (
  echo F | xcopy /Y %from% %to%
  rem コピー後に更新時間が一致するか確認
  for %%i in (%from%) do set DATE1=%%~ti
  for %%i in (%to%)   do set DATE2=%%~ti
  if not "%DATE1%"=="%DATE2%" (
    echo [-] コピー失敗！
  ) else (
    echo [+] コピー成功
  )
)
```

from と to が複数あるときはforループで処理することができます。
遅延環境変数にすることを忘れずに。

```batch
setlocal enabledelayedexpansion

for %%d in (AAA.dll BBB.dll) do (
  set from=from\%%d
  set to=to\%%d
  for %%i in (!from!) do set DATE1=%%~ti
  for %%i in (!to!)   do set DATE2=%%~ti
  if not "!DATE1!"=="!DATE2!" (
    echo F | xcopy /Y !from! !to!
    rem コピー後に更新時間が一致するか確認
    for %%i in (!from!) do set DATE1=%%~ti
    for %%i in (!to!)   do set DATE2=%%~ti
    if not "!DATE1!"=="!DATE2!" (
      echo [-] コピー失敗！
    ) else (
      echo [+] コピー成功
    )
  )
)
```

以上です。
