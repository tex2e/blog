---
layout:        post
title:         "[PowerShell] 演算子の使い方の一覧"
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

### 比較
比較演算子は、2つの値を比較するために使用します。

#### -eq (等しい)
-eq は等価演算子で、左辺と右辺が等しいとき $true を返します。

```powershell
PS> "123" -eq "123"
True
```

#### -ne (等しくない)
-ne は非等価演算子で、左辺と右辺が等しくないとき $true を返します。

```powershell
PS> "123" -ne "123"
False
```

#### -ge (以上)
-ge は以上演算子 (a ≧ b) で、左辺が右辺以上のとき $true を返します。

```powershell
PS> 22 -ge 11
True
```

#### -gt (より大きい)
-gt は大なり演算子 (a > b) で、左辺が右辺より大きいとき $true を返します。

```powershell
PS> 22 -gt 11
True
```

#### -lt (より小さい)
-lt は小なり演算子 (a < b) で、左辺が右辺より小さいとき $true を返します。

```powershell
PS> 22 -lt 33
True
```

#### -le (以下)
-le は以下演算子 (a ≦ b) で、左辺が右辺以下のとき $true を返します。

```powershell
PS> 22 -le 33
True
```

#### -like (パターンマッチ)
-like 演算子は、左辺の文字列が右辺の「パターン」にマッチするとき $true を返します。パターンで指定可能なワイルドカード文字は`?` (任意の一文字)、`*` (0個以上の任意の文字)、`[a-b]` (範囲内の任意の文字)、`[ab]` (文字セット内の任意の文字) の4つが使用できます。大文字小文字を区別させるには **-clike** 演算子を使用します。

```powershell
PS> "Hello world" -like "[Hh]ello*world"
True
```

#### -notlike (否定パターンマッチ)
-notlike 演算子は、-like 演算子の逆で $false を返すときに $true を返します。

```powershell
PS> "Hello world" -notlike "[Hh]ello*world"
False
```

#### -match (正規表現マッチ)
-match 演算子は、左辺の文字列が右辺の「正規表現」にマッチするとき $true を返します。正規表現の丸括弧でキャプチャしたマッチ部分は、自動的に $matches 変数に格納されます。大文字小文字を区別させるには **-cmatch** 演算子を使用します。

```powershell
PS> "Hello world" -match "^Hello (.*)"
True
PS> $matches[1]
world
```

#### -notmatch (否定正規表現マッチ)
-notmatch 演算子は、-match 演算子の逆で $false を返すときに $true を返します。

```powershell
PS> "Hello world" -notmatch "^Hello (.*)"
False
```

#### -contains (含まれる)
-contains 演算子は、左辺のリストの値に、右辺の値が存在するとき $true を返します。

```powershell
PS> @("apple","banana","cherry") -contains "apple"
True
```

#### -notcontains (含まれない)
-notcontains 演算子は、-contains 演算子が $false を返すときに $true を返します。

```powershell
PS> @("apple","banana","cherry") -notcontains "apple"
False
```

### 型
演算子を使うことで、型の比較や型のキャストを行うことができます。

#### -is (型比較)
-is 演算子は型を比較して、左辺のインスタンスの型が右辺の型と等しいとき $true を返します。

```powershell
PS> 123 -is [int]
True
```

#### -isnot (否定型比較)
-isnot 演算子は、-is 演算子の逆で $false を返すとき $true を返します

```powershell
PS> 123 -is [string]
False
```

#### -as (型変換)
-as 演算子は、値のキャストをするために使用します。
指定の型にキャストした値を返し、キャストに失敗したときは $null を返します。
`left -as Right` と書く代わりに、`[Rigth]left` でキャストすることもできます。

```powershell
PS> "123" -as [int]
123
PS> [int]"123"
123
```

### 文字列

#### -replace (文字列置換)
-replace 演算子は、文字列を置き換えるために使用します。
正規表現で大文字小文字を「区別して」置換するには **-creplace** を使用します。

```powershell
PS> "Hello world" -replace "hello (.*)",'Hello __$1__!'
Hello __world__!
```

#### -f (書式設定)
-f は書式設定演算子で、文字列結合を使わずに文字列を作るために使用します。
左辺の書式文字列に右辺の値を入れて、書式設定した文字列を返します。

```powershell
PS> "input={0}, output={1}" -f (123, 456)
input=123, output=456
```

#### -join (文字列結合)
-join 演算子は、左辺の文字列配列を右辺の文字列を用いて結合します。

```powershell
PS> @("Apple","Banana","Cherry") -join ", "
Apple, Banana, Cherry
```

#### -split (文字列分割)
-split 演算子は、左辺の文字列を右辺の文字列 (正規表現) で分割して配列にします。

```powershell
PS> "Apple  Banana`n  Cherry" -split "\s+"
Apple
Banana
Cherry
```

### 論理演算子
論理演算子は、ブール値を求めるために使用します。

#### -not (論理否定)
-not は論理否定 (NOT) した値を求めます。`-not` の代わりに `!` でも論理否定することができます。

```powershell
PS> -not ($true -and $true)
False
PS> !$true
False
```

#### -and (論理積)
-and は論理積 (AND) した値を求めます。ショートサーキット (短絡) の振る舞いをするので、左辺が $false の場合は、右辺を評価しません。

```powershell
PS> $false -and $true -and $true
False
```

#### -or (論理和)
-or は論理和 (OR) を求めます。ショートサーキット (短絡) の振る舞いをするので、左辺が $true の場合は、右辺を評価しません。

```powershell
PS> $true -or $false -or $false
True
```

#### -xor (排他的論理和)
-xor は排他的論理和 (XOR) を求めます。

```powershell
PS> $true -xor $true
False
```

### ビット演算子
ビット演算子は、ブール論理演算子をビットごとに適用するために使用します。

#### -bnot (ビット論理否定)
-bnot はビットごとの論理否定。引数の値のビットを反転した数字を返します。

```powershell
PS> $int1 = [Convert]::ToInt32("111000111000", 2)
PS> $result = -bnot $int1
PS> [Convert]::ToString($result, 2)
11111111111111111111000111000111
```

#### -band (ビット論理積)
-band はビットごとの論理積。左辺と右辺の各ビットの論理積を求めた数字を返します。

```powershell
PS> $int1 = [Convert]::ToInt32("111000111000", 2)
PS> $int2 = [Convert]::ToInt32("111111000000", 2)
PS> $result = $int1 -band $int2
PS> [Convert]::ToString($result, 2)
111000000000
```

#### -bor (ビット論理和)
-bor はビットごとの論理和。左辺と右辺の各ビットの論理和を求めた数字を返します。

```powershell
PS> $int1 = [Convert]::ToInt32("111000111000", 2)
PS> $int2 = [Convert]::ToInt32("111111000000", 2)
PS> $result = $int1 -bor $int2
PS> [Convert]::ToString($result, 2)
111111111000
```

#### -bxor (ビット排他的論理和)
-bxor はビットごとの排他的論理和。左辺と右辺の各ビットの排他的論理和を求めた数字を返します。

```powershell
PS> $int1 = [Convert]::ToInt32("111000111000", 2)
PS> $int2 = [Convert]::ToInt32("111111000000", 2)
PS> $result = $int1 -bxor $int2
PS> [Convert]::ToString($result, 2)
111111000
```

### 算術演算子
算術演算子は、データに対して算術演算を実行するために使用します。

- `+`, `-`, `*`, `/`, `%` : 加減乗除・剰余演算子。左辺と右辺の数字で計算した結果を返します。
- 加算の両辺が文字列のときは、2つを連結した文字列を返します。
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
- `+=`, `-=`, `*=`, `/=`, `%=` : 代入演算子。A = A + B を省略すると A += B と書けます。
- `++` : インクリメント
- `--` : デクリメント

以上です。

### 参考文献
- Lee Holmes (著), 菅野 良二 (訳)『[Windows PowerShellクックブック](https://amzn.to/42fi9yD)』O'REILLY, 2018/6
