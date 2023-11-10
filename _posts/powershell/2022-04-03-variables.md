---
layout:        post
title:         "PowerShellの変数の様々な使い方"
date:          2022-04-03
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

PowerShellの変数には様々な種類が存在します。
ここでは、記号を変数名に含む変数や、変数を使ったファイル読み書き、変数の型付けなどについて説明します。

#### 変数の使用
変数名は、英数字で構成する必要があります。なお、変数名は大文字小文字を区別しないため、注意が必要です。
```ps1
PS> $MYVARIABLE1 = "123"
PS> $myVariable1
123
```

#### 記号を変数名に含む変数の使用
変数名に特殊文字や記号を含める際は `${ }` で囲むだけで、変数名として解釈してくれます。
```ps1
PS> ${myV@r!ab1e} = "123"
PS> ${myV@r!ab1e}
123
```

#### 変数によるファイル読み書き
変数を使って絶対パスで指定したファイルの中身の取得や書き込みをすることもできます。
ファイルの読み書きの場合、変数は必ず `${ドライブ名:パス}` の形式になります。
```ps1
PS> ${c:\test\test.txt}
Hello world
PS> Get-Content "c:\test\test.txt"
Hello world

PS> ${c:\test\test.txt} = "test text"
PS> Get-Content "c:\test\test.txt"
test text
```

#### 変数の型付け
変数宣言時に先頭に型を記述すると、変数宣言時に型付けができるようになり、その変数は常に指定した型であることが保証されます。
指定した型以外の値を代入した場合は自動的にキャストされます。キャストが不可の値のときはエラーになります。
```ps1
PS> [string] $myVariable = 123
PS> $myVariable += 456
PS> $myVariable
123456
```

#### 変数名から変数の取得
Get-Variable コマンドレットを使うことで、変数名を表す文字列から変数の値を取得することができます。
これを使うことで動的に変数を取得することができます。
```ps1
PS> Get-Variable "myVariable"
Name                   Value
----                   -----
myVariable             123456
```

以上です。

### 参考文献
- Lee Holmes (著), 菅野 良二 (訳)『[Windows PowerShellクックブック](https://amzn.to/3QwwEsn)』O'REILLY, 2018/6
