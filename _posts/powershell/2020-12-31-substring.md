---
layout:        post
title:         "[PowerShell] 部分文字列を抽出する"
date:          2020-12-31
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

PowerShell では SubString を使って部分文字列を取ることができますが、範囲が文字列長を超えるとエラーになるので、Join演算子を使った部分文字列抽出について説明します。

まず一般的な部分文字列抽出 SubString(開始位置, 文字列長) は次の通りです。

```powershell
$str = "Hello"
$str.SubString(1, 3)  # => "ell"
```

しかし、長さを超えてしまうとエラーになります。

```powershell
$str.SubString(1, 8)
# "2" 個の引数を指定して "Substring" を呼び出し中に例外が発生しました: 
# "インデックスおよび長さは文字列内の場所を参照しなければなりません。
# パラメーター名:length"
```

エラーにならない方法で部分文字列を抽出するには、配列の範囲指定と Join 演算子を使います。
配列の範囲指定は array[開始位置..終了位置] と書きます。
文字列は「char型の配列」なので、部分配列を取得してから Join で結合させることで、長さを超えてもエラーになりません。

```powershell
$str = "Hello"
$str[1..3] -Join ''  # => "ell"
$str[0..7] -Join ''  # => "Hello"
```

また、配列の範囲指定に負数を使うと、後ろからの位置を指定することもできます。

```powershell
$str = 'Hello, world'
$str[-5..-1] -Join ''  # => "world"
```

以上です。
