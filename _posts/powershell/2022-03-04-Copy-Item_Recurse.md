---
layout:        post
title:         "PowerShellでフォルダをコピーする"
date:          2022-03-04
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

PowerShellでフォルダをコピーするには Copy-Item コマンドレットに -Recurse オプションを追加して実行します。

```powershell
Copy-Item -Recurse "fromFolder" "toFolder"
```

ただし、コピー先がフォルダなので、複数回コピーを連続して実行するとコピー先に ./toFolder/fromFolder というフォルダが作成されてしまいます。
そのため、コピーする前にコピー先が存在しないことを確認してからコピーすると意図通りのコピー先が作成されます。

```powershell
$FromPath = "fromFolder"
$ToPath   = "toFolder"
if (!(Test-Path $ToPath)) {
    Copy-Item -Recurse $FromPath $ToPath
}
```

また稀に、フォルダのコピーに失敗する場合もあるので、コピーの処理をtry-catchで囲むとより安全にフローを制御することができます。

```powershell
$ErrorActionPreference = "Stop"

$FromPath = "fromFolder"
$ToPath   = "toFolder"
if (!(Test-Path $ToPath)) {
    try {
        Copy-Item -Recurse $FromPath $ToPath
    } catch {
        Write-Output "[!] $ToPath の作成に失敗しました。"
    }
}
```

以上です。

### 参考文献
- [Copy-Item (Microsoft.PowerShell.Management) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.management/copy-item)
