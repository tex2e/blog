---
layout:        post
title:         "[PowerShell] 正規表現で名前付きグループ (Named Group) を使う"
type:          How-To
description:   "PowerShellの正規表現で名前付きグループを使うため、-match演算子ではなくregexクラスのMatchesメソッドで値を抽出する方法を解説します。"
tags:          [powershell, regex, named-group]
status:        stable
stale_after:   2027-08-05T00:00:00Z
generated:
  by:          human:tex2e
  at:          2024-01-26T13:24:11Z
date:          2024-01-26
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

PowerShellの正規表現で名前付きグループを使うときは、-match 演算子では使えません。
代わりに、regexクラスの Matches(str, regex) メソッドを呼び出す必要があります。

名前付きグループとは `(?<グループ名>正規表現)` でマッチした部分を取得するときに、「グループ名」で取り出すことができる仕組みです。
名前付きグループを使うことで、プログラムが読みやすくなるメリットがあります。

使い方は以下の通りです。

```ps1
$result = [regex]::Matches($line, '(?<Id>[0-9]+)\t(?<Name>[a-zA-Z0-9_]+)')
if ($result -ne $null) {
    $matchedId = $result[0].Groups['Id'].Value
    $matchedName = $result[0].Groups['Name'].Value
}
```

（補足）名前付きグループを使わないで、普通の括弧で抽出する場合は、以下のように書くことができます。
-match 演算子の結果は matches というグローバル変数に自動的にセットされます。

```ps1
if ($line -match '^([0-9]+)\t([a-zA-Z0-9_]+)') {
    $matchedId = $matches[1]
    $matchedName = $matches[2]
}
```


以上です。
