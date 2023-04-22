---
layout:        post
title:         "[PowerShell] 実行時に管理者権限で動作しているか調べる"
date:          2023-04-22
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

PowerShell (.NET Framework) には WindowsPrincipal と呼ばれる Windows ユーザのロールを確認するために使用するクラスがあります。
このクラスを利用することで、現在の PowerShell スクリプトが管理者権限で実行されているかを確認することができます。

WindowsPrincipal を使った管理者権限チェックは以下のようなプログラムになります。

```ps1
# 管理者権限チェック
$wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$prp = new-object System.Security.Principal.WindowsPrincipal($wid)
$admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$isAdmin = $prp.IsInRole($admin)
if (!$isAdmin) {
  "[-] This command prompt is NOT ELEVATED!"
  pause
  exit 1
}
```

このスクリプトが管理者権限で実行されている場合は、変数 $isAdmin が True になります。

以上です。
