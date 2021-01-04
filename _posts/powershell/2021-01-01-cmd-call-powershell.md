---
layout:        post
title:         "バッチファイルからPowerShellを呼び出す"
date:          2021-01-01
category:      PowerShell
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

PowerShellファイルをバッチファイルから実行する方法について説明します。
バッチファイルを作ることでcmdをダブルクリックするだけでPowerShellが実行できるようになります。

例として、必須引数1つと任意引数2つを取るPowerShellスクリプトを用意して、
これをバッチファイルから実行する例を示します。

PowerShell側 (test.ps1)：

```powershell
param(
  [parameter(Mandatory = $true)] [string] $filename,
  [string] $option1,
  [string] $option2
)

Write-Host $filename
Write-Host "opt1: $option1"
Write-Host "opt2: $option2"
```

バッチファイル側 (test.cmd、普通に引数に渡す場合)：

```batch
@echo off
powershell .\test.ps1 SampleFile 123
pause
```

実行結果：

```
SampleFile
opt1: 123
opt2:
```

バッチファイル側 (test.cmd : 名前付き引数で渡す場合)：

```batch
@echo off
powershell .\test.ps1 -option1 123 -option2 456 -filename SampleFile
pause
```

実行結果

```
SampleFile
opt1: 123
opt2: 456
```

#### 補足

もし、実行時にセキュリティエラーが発生する場合は、システムでスクリプトを実行が無効になっている可能性があるので、次のコマンドを管理者権限のPowerShellコマンドプロンプトで入力してから実行してください。

```PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```


以上です。
