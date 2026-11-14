---
layout:        post
title:         "AWS EC2のWindows Serverでタイムゾーンを東京/日本時刻にする"
type:          How-To
description:   "AWS EC2上のWindows ServerでUTC時刻を日本時間に変更するため、tzutilとreg addでTokyo Standard Timeを永続化する方法。"
tags:          [windows, aws-ec2, windows-server, timezone]
status:        stable
stale_after:   2023-10-05T00:00:00Z
generated:
  by:          human:tex2e
  at:          2022-10-05T14:23:25Z
sources:
  - id:        ref-1
    resource:  https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/WindowsGuide/windows-set-time.html
    title:     "https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/WindowsGuide/windows-set-time.html"
date:          2022-10-05
category:      Windows
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

AWS EC2 で Windows Server のAMIを使ってインスタンスを起動すると時刻表記が UTC になってしまう場合、以下のバッチコマンドを実行すると、タイムゾーンが東京に設定されて時刻が日本時間になります。

```batch
tzutil /s "Tokyo Standard Time"
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
```

- `tzutil` : 現在のタイムゾーンを変更するコマンドです。再起動すると元の設定に戻ります。
- `reg add` : レジストリキーを追加するコマンドです。再起動しても設定が戻らないようにできます。

以上です。

### 参考文献
- [https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/WindowsGuide/windows-set-time.html](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/WindowsGuide/windows-set-time.html)
