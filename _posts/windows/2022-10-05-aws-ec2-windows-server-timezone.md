---
layout:        post
title:         "AWS EC2のWindows Serverでタイムゾーンを東京/日本時刻にする"
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
