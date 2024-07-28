---
layout:        post
title:         "[PowerShell] 文字列展開・リストの評価"
date:          2022-04-01
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

PowerShellは、入力された行をトークンに分割し、各トークンをコマンドまたは式（ステートメント）として評価します。
PowerShellで式を評価する際に、評価方法を制御する方法があります。
`()` (優先順位の制御)、`$()` (式のサブパース)、`@()` (リストの評価) の3種類です。

#### 優先順位の制御 `(expr)`
コマンドまたは式の評価を強制します。
数式で評価順を変えるために括弧を使うのと同様です。
```ps1
PS> (dir).Count
36
PS> 3 * (7/2 -as [int])
12
```

#### 式のサブパース (文字列展開) `$(expr)`
式のサブパースは、ダブルクオート「"」で囲まれた文字列の中で括弧内の式を評価するために使用できます (シングルクオート「'」で囲んだ文字列の場合は評価しません)。
また、式のサブパースは、サブプログラム（引数のない無名関数）のように使うこともできます。
```ps1
PS> "result=$(3 * 4)"
result=12

PS> "path=$($pwd.Path)"
path=C:\test

PS> $result = $(
>>    if (($env:PATH).Length -gt 100) { $true }
>>    else { $false }
>> )
PS> $result
True
```

#### リストの評価 `@(expr)`
式をリストとして評価します。
対象の式がリストの場合、引き続きリストの状態を保持します。
対象の式がリストではない場合、一時的にその対象をリストと見なして評価します。
```ps1
PS> ("hello") + ("world")
helloworld
PS> @("hello") + @("world")
hello
world
```

以上です。

### 参考文献
- Lee Holmes (著), 菅野 良二 (訳)『[Windows PowerShellクックブック](https://amzn.to/3QwwEsn)』O'REILLY, 2018/6
