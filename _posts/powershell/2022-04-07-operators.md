---
layout:        post
title:         "PowerShellの演算子の一覧"
date:          2022-04-07
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

PowerShellには他の言語とは異なる演算子がたくさん存在します。
比較演算子、置換演算子、書式設定演算子、型変換演算子、論理演算子、ビット演算子、算術演算子などです。
ここでは、PowerShellの演算子とその使い方について説明します。

### 比較演算子
比較演算子は、値を比較するために使用します。

- **-eq** : 等価演算子。左辺と右辺が等しいとき $true を返します

```powershell
PS> "123" -eq "123"
True
```

- **-ne** : 非等価演算子。左辺と右辺が等しくないとき $true を返します

```powershell
PS> "123" -ne "123"
False
```

- **-ge** : 以上演算子。左辺が右辺以上のとき $true を返します

```powershell
PS> 22 -ge 11
True
```

- **-gt** : 大なり演算子。左辺が右辺より大きいとき $true を返します

```powershell
PS> 22 -gt 11
True
```

- **-lt** : 小なり演算子。左辺が右辺より小さいとき $true を返します

```powershell
PS> 22 -lt 33
True
```

- **-le** : 以下演算子。左辺が右辺以下のとき $true を返します

```powershell
PS> 22 -le 33
True
```

- **-like** : Like演算子。左辺の文字列が右辺の「パターン」にマッチするとき $true を返します。パターンで指定可能なワイルドカード文字は`?` (任意の一文字)、`*` (0個以上の任意の文字)、`[a-b]` (範囲内の任意の文字)、`[ab]` (文字セット内の任意の文字) の4つが使用できます。大文字小文字を区別させるには **-clike** 演算子を使用します。

```powershell
PS> "Hello world" -like "[Hh]ello*world"
True
```

- **-notlike** : Not Like演算子。-like 演算子で $false を返すときに $true を返します

```powershell
PS> "Hello world" -notlike "[Hh]ello*world"
False
```

- **-match** : Match演算子。左辺の文字列が右辺の「正規表現」にマッチするとき $true を返します。正規表現の丸括弧でキャプチャしたマッチ部分は、自動的に $matches 変数に格納されます。大文字小文字を区別させるには **-cmatch** 演算子を使用します。

```powershell
PS> "Hello world" -match "^Hello (.*)"
True
PS> $matches[1]
world
```

- **-notmatch** : Not Match演算子。-match 演算子が $false を返すときに $true を返します

```powershell
PS> "Hello world" -notmatch "^Hello (.*)"
False
```

- **-contains** : Contains演算子。左辺のリストの値に、右辺の値が存在するとき $true を返します

```powershell
PS> @("apple","banana","cherry") -contains "apple"
True
```

- **-notcontains** : Not Contains演算子。-contains 演算子が $false を返すときに $true を返します

```powershell
PS> @("apple","banana","cherry") -notcontains "apple"
False
```

- **-is** : 型演算子(Is)。左辺のインスタンスの型が右辺の型と等しいとき $true を返します

```powershell
PS> 123 -is [int]
True
```

- **-isnot** : 型演算子(IsNot)。-is 演算子が $false を返すとき $true を返します

```powershell
PS> 123 -is [string]
False
```

### 置換演算子
置換演算子は、文字列を置き換えるために使用します。
- **-replace**, **-ireplace** : 正規表現で大文字小文字を「区別しない」で置換します

```powershell
PS> "Hello world" -replace "hello (.*)",'Hello __$1__!'
Hello __world__!
```

- **-creplace** : 正規表現で大文字小文字を「区別して」置換します (Case Sensitive)

```powershell
PS> "Hello world" -creplace "Hello (.*)",'Hello __$1__!'
Hello __world__!
```

### 書式設定演算子
書式設定演算子は、文字列結合を使わずに文字列を作るために使用します。
- **-f** : 書式設定演算子。左辺の書式文字列に右辺の値を入れて、書式設定した文字列を返します

```powershell
PS> "input={0}, output={1}" -f (123, 456)
input=123, output=456
```

### 型変換演算子
型変換演算子は、値のキャストをするために使用します。
- **-as** : 型変換演算子。指定の型にキャストした値を返します。キャスト不可能なら $null を返します

```powershell
PS> "123" -as [int]
123
```

### 配列演算子
配列演算子は、文字列配列を操作するために使用します。
- **-join** : 左辺の文字列配列を右辺の文字列を用いて結合します。

```powershell
PS> @("Apple","Banana","Cherry") -join ", "
Apple, Banana, Cherry
```

- **-split** : 左辺の文字列を右辺の文字列 (正規表現) で分割して配列にします。

```powershell
PS> "Apple  Banana`n  Cherry" -split "\s+"
Apple
Banana
Cherry
```

### 論理演算子
論理演算子は、ブール値を求めるために使用します。
- **-not**, **!** : 論理否定 (NOT) を求めます。

```powershell
PS> -not ($true -and $true)
False
PS> !$true
False
```

- **-and** : 論理積 (AND) を求めます。ショートサーキット (短絡) の振る舞いをするので、左辺が $false の場合は、右辺を評価しません。

```powershell
PS> $false -and $true -and $true
False
```

- **-or** : 論理和 (OR) を求めます。ショートサーキット (短絡) の振る舞いをするので、左辺が $true の場合は、右辺を評価しません。

```powershell
PS> $true -or $false -or $false
True
```

- **-xor** : 排他的論理和 (XOR) を求めます。

```powershell
PS> $true -xor $true
False
```

### ビット演算子
ビット演算子は、ブール論理演算子をビットごとに適用するために使用します。
- **-bnot** : ビットごとの論理否定。引数の値のビットを反転した数字を返します

```powershell
PS> $int1 = [Convert]::ToInt32("111000111000", 2)
PS> $result = -bnot $int1
PS> [Convert]::ToString($result, 2)
11111111111111111111000111000111
```

- **-band** : ビットごとの論理積。左辺と右辺の各ビットの論理積を求めた数字を返します

```powershell
PS> $int1 = [Convert]::ToInt32("111000111000", 2)
PS> $int2 = [Convert]::ToInt32("111111000000", 2)
PS> $result = $int1 -band $int2
PS> [Convert]::ToString($result, 2)
111000000000
```

- **-bor** : ビットごとの論理和。左辺と右辺の各ビットの論理和を求めた数字を返します

```powershell
PS> $int1 = [Convert]::ToInt32("111000111000", 2)
PS> $int2 = [Convert]::ToInt32("111111000000", 2)
PS> $result = $int1 -bor $int2
PS> [Convert]::ToString($result, 2)
111111111000
```

- **-bxor** : ビットごとの排他的論理和。左辺と右辺の各ビットの排他的論理和を求めた数字を返します

```powershell
PS> $int1 = [Convert]::ToInt32("111000111000", 2)
PS> $int2 = [Convert]::ToInt32("111111000000", 2)
PS> $result = $int1 -bxor $int2
PS> [Convert]::ToString($result, 2)
111111000
```

### 算術演算子
算術演算子は、データに対して算術演算を実行するために使用します。
- `+`, `-`, `*`, `/`, `%` : 加減乗除・剰余演算子。左辺と右辺の数字で計算した結果を返します
- 加算の両辺が文字列のときは、2つを連結した文字列を返します

```powershell
PS> "Hello" + " " + "world"
Hello world
```

- 加算の両辺が集合 (Collections) のときは、2つの和集合を返します

```powershell
PS> @{name="Apple"} + @{price=200}
Name             Value
----             -----
price            200
name             Apple
```

- 乗算の左辺が文字列、右辺が整数のときは、文字列を指定回数繰り返した新しい文字列を返します

```powershell
PS> "=" * 20
====================
```

- 乗算の左辺が配列、右辺が整数のときは、配列を指定回数繰り返した新しい配列を返します。

```powershell
PS> @(1,2) * 3
1
2
1
2
1
2
```

- `+=`, `-=`, `*=`, `/=`, `%=` : 代入演算子。A = A + B を省略すると A += B と書けます
- `++` : インクリメント
- `--` : デクリメント

以上です。

### 参考文献
- Lee Holmes (著), 菅野 良二 (訳)『Windows PowerShellクックブック』O'REILLY, 2018/6
