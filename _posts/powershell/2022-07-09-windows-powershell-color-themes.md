---
layout:        post
title:         "[PowerShell] PowerShellコンソールの配色を設定する"
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
