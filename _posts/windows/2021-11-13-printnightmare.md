---
layout:        post
title:         "PrintNightmare攻撃を回避するための対策"
date:          2021-11-13
category:      Windows
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

印刷スプーラーサービスを無効化して、PrintNightmareの攻撃を回避する方法について説明します。

まず、管理者権限でPowerShellを起動し、印刷スプーラーサービスが動作しているかどうかを確認します。

```ps1
PS> Get-Service -Name Spooler

Status   Name               DisplayName
------   ----               -----------
Running  Spooler            Print Spooler
```

起動 (Running) であれば、以下のコマンドで停止＆無効化します。
```ps1
PS> Stop-Service -Name Spooler -Force
PS> Set-Service -Name Spooler -StartupType Disabled
```

再度、印刷スプーラーサービスの状態を確認して、停止 (Stopped) になっていることを確認します。
```ps1
PS> Get-Service -Name Spooler

Status   Name               DisplayName
------   ----               -----------
Stopped  Spooler            Print Spooler
```

このように印刷スプーラーサービスを無効化し、ローカル/リモートの両方で印刷機能が無効にすることで、攻撃の回避をすることができます。
ただし、この方法は印刷機能を使用しないPCやサーバにのみ使える方法です。

普段のPCで印刷をしたい場合は、最新のセキュリティパッチを適用してください。

以上です。

#### 参考文献

- [CVE-2021-34527 - セキュリティ更新プログラム ガイド - Microsoft - Windows 印刷スプーラーのリモートでコードが実行される脆弱性](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-34527)
- [PrintNightmareへの効率的な対処方法 - ManageEngine ブログ ManageEngine ブログ](https://blogs.manageengine.jp/printnightmare/)
