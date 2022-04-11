---
layout:        post
title:         "PowerShellでMap, Filter, Reduceをする"
date:          2022-04-11
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

PowerShellでMap, Filter, Reduceをする方法について説明します。

#### Map
Map は foreach を使って実現することができます。foreach の代わりに `%` や ForEach-Object と書いても同じです。
以下は、1〜5の数列を2倍する例です。
```ps1
PS> 1..5 | foreach { $_ * 2 }
2
4
6
8
10
```

#### Filter
Filter は where を使って実現することができます。where の代わりに `?` や Where-Object と書いても同じです。
以下は、1〜10の数列から偶数の数字だけを抽出する例です。
```ps1
PS> 1..10 | where { $_ % 2 == 0 }
2
4
6
8
10
```

#### Reduce
Reduce は関数を使って実現することができます。スクリプトブロック（無名関数）などの関数では、begin, process, end のキーワードを使用して開始時、各行処理時、終了時の処理を定義することができます。
なお、スクリプトブロックは `&` で実行します。
以下は、1〜10の合計値を求める例です。
```ps1
PS> 1..10 | & {
>>     begin { $total = 0 }
>>     process { $total += $_ }
>>     end { $total }
>> }
55
```
foreach を使うことで、もっと短く書くことができます。
```ps1
PS> 1..10 | foreach { $total = 0 } { $total += $_ } { $total }
55
```

以上です。
