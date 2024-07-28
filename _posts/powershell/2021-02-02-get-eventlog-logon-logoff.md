---
layout:        post
title:         "[PowerShell] ログイン・ログアウトのイベントログを取得する"
date:          2021-02-02
category:      PowerShell
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windowsパソコンのログイン・ログアウトの時間を調査したいときに、毎回コンピュータの管理からWindowsログのシステムでイベントIDが7001と7002をフィルターするのは面倒なので、PowerShellでログイン・ログアウト時刻の取得を自動化します。

ログイン・ログアウト時間を取得するPowerShellは次のようになります。

```powershell
Get-EventLog System -After (Get-Date).AddDays(-7) | `
where { $_.InstanceId -in (6001,6002,7001,7002) } | `
select InstanceId, `
       @{n='Message'; `
         e={if (($_ | select -ExpandProperty InstanceId) % 2 -eq 1) {"Logon"} else {"Logoff"} }}, `
       TimeGenerated
```

- システムのログは Get-EventLog System で取得できます。現在から一週間前までのログを取得するときは -After オプションを使って、7日前の日付を指定します。
- ログを取得したら、イベントIDが 6001, 6002, 7001, 7002 のログだけを抽出します。6001, 7001 はログイン、6002, 7002 はログアウトを意味します。
- 最後にイベントID（InstanceId）、イベント名、時刻（TimeGenerated）を出力させます。イベント名にはイベントIDが奇数のときは「Logon」、偶数のときは「Logoff」と表示するように、Hashオブジェクト`@{n=..., e=...}`を追加します。nにはカラム名、eには評価したい式を入れます。

PowerShellコンソールで実行すると以下のような感じになります（出力されている時刻は自宅PCのログイン・ログアウトの時刻です）。

```
> Get-EventLog System -After (Get-Date).AddDays(-7) | ? { $_.InstanceId -in (6001,6002,7001,7002) } | select InstanceId,@{n='Message'; e={if (($_ | select -ExpandProperty InstanceId) % 2 -eq 1) {"Logon"} else {"Logoff"} }},TimeGenerated

InstanceId Message TimeGenerated
---------- ------- -------------
      7001 Logon   2021/01/31 8:02:58
      7002 Logoff  2021/01/31 0:07:54
      7001 Logon   2021/01/30 8:59:44
      7002 Logoff  2021/01/29 23:50:54
      7001 Logon   2021/01/29 23:35:49
      7002 Logoff  2021/01/28 23:37:05
      7001 Logon   2021/01/28 21:30:41
      7002 Logoff  2021/01/27 23:49:28
      7001 Logon   2021/01/27 21:57:55
      7002 Logoff  2021/01/27 0:00:09
      7001 Logon   2021/01/26 22:09:24
      7002 Logoff  2021/01/25 23:40:47
      7001 Logon   2021/01/25 21:43:07
      7002 Logoff  2021/01/24 23:40:17
```

このスクリプトを使えば、会社の出退勤の時刻入力するときに役立つかなと思っています。

以上です。


### 参考文献

- [PowerShell: Building Objects with Custom Properties with Select-Object – SID-500.COM](https://sid-500.com/2018/04/30/powershell-building-objects-with-custom-properties/)
