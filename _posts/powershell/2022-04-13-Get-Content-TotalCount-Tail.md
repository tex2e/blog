---
layout:        post
title:         "PowerShellでhead, tail (Get-Content) を使う"
type:          Reference
description:   "Linuxのheadやtailコマンド相当の先頭行・末尾行取得をPowerShellのGet-Contentの-TotalCountと-Tailで行う方法を説明します。"
tags:          [powershell, get-content, head, tail]
status:        stable
stale_after:   2025-04-13T00:00:00Z
generated:
  by:          human:tex2e
  at:          2022-04-13T12:39:01Z
sources:
  - id:        ref-1
    resource:  https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.management/get-content?view=powershell-7.2
    title:     "Get-Content (Microsoft.PowerShell.Management) - PowerShell \\| Microsoft Docs"
date:          2022-04-13
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

PowerShellで head や tail をするには、Get-Content (cat) コマンドレットのオプション -TotalCount や -Tail を使います。

#### head (先頭の10行だけ表示する)
Linux の head コマンドのように、PowerShellで先頭の数行だけを表示したい場合は、Get-Content コマンドレットの -TotalCount オプションを使用します。
```ps1
Get-Content test.txt -TotalCount 10
```

#### tail (末尾の10行だけ表示する)
Linux の tail コマンドのように、PowerShellで末尾の数行だけを表示したい場合は、Get-Content コマンドレットの -Tail オプションを使用します。
```ps1
Get-Content test.txt -Tail 10
```

以上です。

#### 参考文献
- [Get-Content (Microsoft.PowerShell.Management) - PowerShell \| Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.management/get-content?view=powershell-7.2)
