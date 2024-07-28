---
layout:        post
title:         "[PowerShell] 文字列を日付に変換して時間差を求める (New-TimeSpan)"
date:          2022-04-21
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

PowerShellで文字列を日付に変換するには [DateTime]::ParseExact を使用し、2つの日時の時間差を求めるには New-ItmeSpan を使用します。

PowerShellで文字列から日付に変換する場合は、DateTimeクラスの**ParseExact**メソッドを使います。
第一引数に変換したい文字列、第二引数に[カスタム日時形式文字列](https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/custom-date-and-time-format-strings?redirectedfrom=MSDN)、第三引数にロケール情報 (nullでも可) を渡します。

また、日時の比較は **New-ItmeSpan** コマンドレットを使います。
第一引数と第二引数の日時の差を求めて、以下のメンバを持つオブジェクトを返します。
- Days : 日数の差
- Hours : 時の差
- Minutes : 分の差
- Seconds : 秒の差
- Milliseconds : ミリ秒の差

入力した文字列が今日の日付かを確認するプログラムの例を以下に示します。

```ps1
$datetime_str = "2022/04/21"
# 文字列を日付に変換する
$datetime = [DateTime]::ParseExact($datetime_str, "yyyy/MM/dd", $null)
# 日付と現在時刻の差を求める
$diff = New-TimeSpan $datetime (Get-Date)
if ($diff.Days -ne 0) {
    "入力文字列は、今日の日付ではありません。"
}
```

以上です。

### 参考文献
- [カスタム日時形式文字列 \| Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/custom-date-and-time-format-strings?redirectedfrom=MSDN)
- [\[Powershell\]文字列を日付に変換する – エンジニ屋](https://sevenb.jp/wordpress/ura/2015/08/06/powershell%E6%96%87%E5%AD%97%E5%88%97%E3%82%92%E6%97%A5%E4%BB%98%E3%81%AB%E5%A4%89%E6%8F%9B%E3%81%99%E3%82%8B/)
- [Powershellの時間計算すごい - "Diary" インターネットさんへの恩返し](https://azwoo.hatenablog.com/entry/2014/09/11/093359)
