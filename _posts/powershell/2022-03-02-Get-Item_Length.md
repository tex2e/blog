---
layout:        post
title:         "[PowerShell] Get-Itemでファイルサイズを取得する"
type:          How-To
description:   "PowerShellのGet-ItemとLengthプロパティでファイルサイズを取得し、再帰的に空ファイルを検索する方法を解説します。"
tags:          [powershell, get-item, file-system]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2022-03-05T23:43:48Z
sources:
  - id:        ref-1
    resource:  https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.management/get-item
    title:     "Get-Item (Microsoft.PowerShell.Management) - PowerShell \\| Microsoft Docs"
date:          2022-03-02
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

PowerShell でファイルサイズを取得するには Get-Item コマンドレットと Length プロパティを組み合わせることで、ファイルサイズを取得することができます。

```powershell
(Get-Item sample.txt).Length
```

対象ファイルのサイズが 0 byte かを確認したい場合は、if の条件文の中で `-eq` 演算子で 0 と等しいか確認することで、ファイルサイズが 0 byte のときの処理を書くことができます。

```powershell
if ((Get-Item sample.txt).Length -eq 0) {
  Write-Output "Hello, world!" >> sample.txt
}
```

### 再帰的にフォルダ内の空ファイルを全て表示する

Linuxのfindコマンドのように、再帰的にフォルダ内にあるファイルを調べるには、Get-ChildItem コマンドレットに -Recurse オプションを追加して実行し、その結果を where (Where-Object) コマンドレットでフィルタリングし、foreach (ForEach-Object) コマンドレットで回すことで、ファイルサイズが 0 byte のファイル一覧を表示することができます。

```powershell
Get-ChildItem -Recurse |
  where { (Get-Item $_.FullName).Length -eq 0 } |
  foreach {
    Write-Output "Empty File: $_.Name"
  }
```

以上です。

### 参考文献
- [Get-Item (Microsoft.PowerShell.Management) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.management/get-item)
