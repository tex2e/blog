---
layout:        post
title:         "PowerShellでGet-ChildItem(findコマンド)を使う"
date:          2022-03-05
category:      PowerShell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

PowerShell の Get-ChildItem コマンドレットと -Recurse オプションを使うことで、Linuxのfindコマンドに相当する処理を行うことができます。

#### find . -name
拡張子が txt のファイルの一覧を再帰的に探す `find . -name '*.txt'` に相当するPowerShellは、Get-ChildItem と `-Filter` オプションを使用します。
```powershell
Get-ChildItem -Recurse -Filter "*.txt"
```

#### find . -type d
ディレクトリのみを再帰的に探す `find . -type d` に相当するPowerShellは、Get-ChildItem と `-Directory` オプションを使用します。
```powershell
Get-ChildItem -Recurse -Directory
```

#### find . -print
見つけたファイルをパスだけを表示する `find . -print` に相当するPowerShellは、Get-ChildItem と `-Name` オプションを使用します。
```powershell
Get-ChildItem -Recurse -Name
```

#### find . -maxdepth
再帰する最大の深さのレベルを指定する `find . -maxdepth 3` に相当するPowerShellは、Get-ChildItem と `-Depth` オプションを使用します。
```powershell
Get-ChildItem -Recurse -Depth 3
```

#### find . -mmin -5
5分以内に修正されたファイルを見つける `find . -mmin -5` に相当するPowerShellは、Get-ChildItem と Where-Object を組み合わせて使用します。
Where-Object は入力に対するフィルター処理をしてくれます。
```powershell
Get-ChildItem -Recurse | where { $_.LastWriteTime -gt (Get-Date).AddMinutes(-5) }
```

#### find . -exec
見つけたファイルに対して処理を行う `find . -exec echo {} \;` に相当するPowerShellは、Get-ChildItem と ForEach-Object を組み合わせて使用します。
ForEach-Object は入力に対する繰り返し処理をしてくれます。
以下は、見つけたファイルのフルパスを表示するためのコマンド例です。
```powershell
Get-ChildItem -Recurse | foreach { Write-Output $_.FullName }
```

#### find . \| grep -E
見つけたファイルを正規表現でフィルタリングする `find . | grep -E` に相当するPowerShellは、where の中で正規表現マッチをすることで実現します。
以下は、拡張子が .txt か .png のファイル かつ パス中に dest フォルダを含まない場合、そのファイルのフルパスを表示する例です。

```powershell
Get-ChildItem -Recurse |
    where {
        $_.Name -match "\.(txt|png)$" -and
        $_.FullName -notmatch "\\dest\\"
    } |
    foreach {
        Write-Output $_.FullName
    }
```

以上です。

### 参考文献
- [Get-ChildItem (Microsoft.PowerShell.Management) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.management/get-childitem)
