---
layout:        post
title:         "コマンドラインでVSSからファイル取得"
date:          2021-01-30
category:      WindowsBatch
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

VSS (Visual SourceSafe) にはssコマンドがあり、ss getするとファイルの取得を自動化することができます。
ssはPATHに追加すると実行できるようになります。

### 設定

ssコマンドを実行する前に環境変数（Windowsバッチの変数）に以下の3つを設定します。

- SSUSER : VSSデータベースのユーザ名
- SSPWD : VSSデータベースのパスワード
- SSDIR : VSSデータベースのパス

### コマンド

ssコマンドでファイルを取得する方法は次の手順です。

1. ss CP "$/プロジェクトパス"
2. ss GET "$/プロジェクトパス/ファイル名" -GL 保存先フォルダ

ss CP はカレントプロジェクトを変更します。VSSではフォルダのことをプロジェクトと呼ぶようです。
ss GET はカレントプロジェクト内のファイルを取得します。現在のフォルダに保存したくない場合は `-GL` オプションで保存先を指定します。

ss GET には他にもオプションがあります。
`-I` (Ignore) はVSSとローカルの2つのファイルの比較をしません。
`-W` (read/Write) は書き込み可能なファイルで保存します（デフォルトは読み取り専用）。

### バッチファイル

Windowsバッチファイルでssコマンドを使って取得する例：

```batch
SET SSUSER=ユーザ名
SET SSPWD=パスワード
SET SSDIR=\\hostname\path\to\vssdb
SET PATH=%PATH%;C:\Program Files (x86)\Microsoft Visual SourceSafe

ss CP "$/Path/to/folder"
ss GET "$/Path/to/folder/filename.cpp" -GL"C:\latest" -I -W
```

### PowerShell

PowerShellでssコマンドを呼ぶときは、環境変数 $env:変数名 に設定をしてから実行します。

PowerShellでssコマンドを使って取得する例：

```powershell
$env:SSUSER = "ユーザ名"
$env:SSPWD = "パスワード"
$env:SSDIR = "\\hostname\path\to\vssdb"
$env:PATH += ";C:\Program Files (x86)\Microsoft Visual SourceSafe"

ss CP "$/Path/to/folder"
ss GET "$/Path/to/folder/filename.cpp" -GL"$workingDir\$outputDir" -I -W
```

今もVSSでソース管理してるのかよGit使えよ、という気持ちですが、仕事でそういうのが多いので、コマンドからVSSを呼び出せる知識があると少し楽になる部分があります。
(私にとっては) Git使ったほうが100倍楽なのですが...


### 参考文献

- [Command Line Commands \| Microsoft Docs](https://docs.microsoft.com/en-us/previous-versions/003ssz4z%28v=vs.80%29)
- [Command Options \| Microsoft Docs](https://docs.microsoft.com/en-us/previous-versions/hsxzf2az%28v=vs.80%29)
