---
layout:        post
title:         "[PowerShell] Windowsイベントログを収集する"
date:          2024-06-05
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

WindowsイベントログをPowerShellで収集する方法について説明します。

### イベントログをXML形式で出力

WindowsイベントログをXML形式で出力するには、Get-Eventlog と Export-Clixml を組み合わせて使用します。
以下の例では、Windowsイベントのアプリケーション (Application) とシステム (System) の両方をXML形式で出力するためのコマンドです。

```ps1
Get-Eventlog -LogName Application -EntryType Error,Warning | Export-Clixml LogApplication.xml
Get-Eventlog -LogName System -EntryType Error,Warning | Export-Clixml LogSystem.xml
```

上記コマンドを実行後、フォルダに作成された LogApplication.xml と LogSystem.xml を回収することで、ログを収集することができます。

### (補足) イベントログの種類一覧

取得できるイベント種類の一覧は `-List` オプションで確認することができます。

```ps1
Get-EventLog -List
```

出力結果

```output
  Max(K) Retain OverflowAction        Entries Log
  ------ ------ --------------        ------- ---
  20,480      0 OverwriteAsNeeded      26,455 Application
  20,480      0 OverwriteAsNeeded           0 HardwareEvents
     512      7 OverwriteOlder              0 Internet Explorer
  20,480      0 OverwriteAsNeeded           0 Key Management Service
                                              Security
  20,480      0 OverwriteAsNeeded      14,956 System
  15,360      0 OverwriteAsNeeded       4,236 Windows PowerShell
```

以上です。

### 参考資料

- [Get-EventLog (Microsoft.PowerShell.Management) - PowerShell \| Microsoft Learn](https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.management/get-eventlog?view=powershell-5.1)
