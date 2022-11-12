---
layout:        post
title:         "PowerShellでローカルユーザを無効化する"
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
