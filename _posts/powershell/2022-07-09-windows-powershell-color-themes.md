---
layout:        post
title:         "[PowerShell] PowerShellコンソールの配色を設定する"
type:          How-To
description:   "Microsoft製のColorTool.exeを使い、Windows PowerShellコンソールの配色テーマを設定・変更する手順を説明します。"
tags:          [powershell, windows, colortool, terminal]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2022-07-09T08:00:33Z
sources:
  - id:        ref-1
    resource:  https://github.com/microsoft/terminal/tree/main/src/tools/ColorTool
    title:     "terminal/src/tools/ColorTool at main · microsoft/terminal"
  - id:        ref-2
    resource:  https://github.com/microsoft/terminal/releases/tag/1904.29002
    title:     "Release Color Tool April 2019 · microsoft/terminal"
date:          2022-07-09
category:      PowerShell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windows PowerShellコンソールの配色を設定する方法について説明します。
Microsoft が作成した ColorTool.exe というツールを使って設定します。

まず、MicrosoftのGitHubレポジトリから、ColorToolのダウンロードをします：
[terminal/src/tools/ColorTool at main · microsoft/terminal](https://github.com/microsoft/terminal/tree/main/src/tools/ColorTool)

ダウンロードリンク：
[Release Color Tool April 2019 · microsoft/terminal](https://github.com/microsoft/terminal/releases/tag/1904.29002)

ColorTool.zip をダウンロードして、フォルダ内にある ColorTool.exe を実行します。


### Windows PowerShell の配色設定

ColorTool.exe で使用可能なカラーテーマ (schemes) の一覧を表示するには、-s オプションを使用します。
```ps1
PS> ./ColorTool.exe -s
deuteranopia.itermcolors
OneHalfDark.itermcolors
OneHalfLight.itermcolors
solarized_dark.itermcolors
solarized_light.itermcolors
```

現在のコンソールとデフォルトの両方 (both) にカラーテーマを適用するには、-b オプションを使用します。
```ps1
PS> ./ColorTool.exe -b カラーテーマ名.itermcolors
```

以下は入力例です。好きな1行をコピペして使用してください。
```ps1
./ColorTool.exe -b deuteranopia.itermcolors
./ColorTool.exe -b OneHalfDark.itermcolors
./ColorTool.exe -b OneHalfLight.itermcolors
./ColorTool.exe -b solarized_dark.itermcolors
./ColorTool.exe -b solarized_light.itermcolors     <--- おすすめ
```

新規PowerShellコンソールを起動してみて文字色などが変化することを確認したら、カラーテーマ適用完了です。

以上です。
