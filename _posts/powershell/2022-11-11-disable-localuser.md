---
layout:        post
title:         "[PowerShell] ローカルユーザを無効化する"
type:          How-To
description:   "PowerShellのDisable-LocalUserおよびEnable-LocalUserコマンドレットを使い、ローカルユーザを無効化・有効化する方法を説明します。"
tags:          [powershell, windows, local-user]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2022-11-12T09:12:41Z
sources:
  - id:        ref-1
    resource:  https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.localaccounts/disable-localuser?view=powershell-5.1
    title:     "Disable-LocalUser (Microsoft.PowerShell.LocalAccounts) - PowerShell \\| Microsoft Learn"
  - id:        ref-2
    resource:  https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.localaccounts/enable-localuser?view=powershell-5.1
    title:     "Enable-LocalUser (Microsoft.PowerShell.LocalAccounts) - PowerShell \\| Microsoft Learn"
date:          2022-11-11
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

PowerShellでローカルユーザを無効化 (Disabled) する方法について説明します。

## Disable-LocalUser 

PowerShellでユーザをロックや無効化するには Disable-LocalUser を使用します。
逆にアンロックや有効化するには Enable-LocalUser を使用します。

```powershell
PS> Disable-LocalUser -Name "tex2e"
PS> Enable-LocalUser -Name "tex2e"
```

以上です。

### 参考文献

- [Disable-LocalUser (Microsoft.PowerShell.LocalAccounts) - PowerShell \| Microsoft Learn](https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.localaccounts/disable-localuser?view=powershell-5.1)
- [Enable-LocalUser (Microsoft.PowerShell.LocalAccounts) - PowerShell \| Microsoft Learn](https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.localaccounts/enable-localuser?view=powershell-5.1)
