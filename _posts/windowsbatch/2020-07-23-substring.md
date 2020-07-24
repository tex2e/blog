---
layout:        post
title:         "バッチファイルで固定長・可変長の文字列切り取り"
date:          2020-07-23
category:      WindowsBatch
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

Windowsのバッチファイルでは文字列変数から一部の文字列を切り取るための構文 `:~` があります。

### Syntax

固定長の文字列切取り (`:~`)

```batch
set result=%変数:~開始位置%
set result=%変数:~開始位置,切取り長%
```

可変長の文字列切取り（`call` + `:~`）

```batch
set start=開始位置
set length=切取り長
call set result=%%変数:~%start%,%length%%%
```

### Examples

3文字目以降を切り取る：

```batch
set input=abcdef
set result=%input:~2%
echo %result%             & rem => cdef
```

3文字目から2文字切り取る：

```batch
set input=abcdef
set result=%input:~2,2%
echo %result%             & rem => cd
```

開始位置にマイナスの値を入れると、文字列の後ろから数えた位置から開始します。

後ろの3文字を切り取る：

```batch
set input=abcdef
set result=%input:~-3%
echo %result%             & rem => def
```

callを使うことで、開始位置と切取り長を変数にすることができます。

```batch
set input=abcdef
set start=1
set length=3
call set result=%%input:~%start%,%length%%%
echo %result%             & rem => bcd
```

for文と組み合わせることで、文字列の指定桁目から1文字ずつ取得することができます（for文内で遅延評価する必要があるため`%`の代わりに`!`を使います）。

```batch
set input=abcdef

setlocal enabledelayedexpansion

for /l %%i in (0,1,5) do (
  call set result=!!input:~%%i,1!!
  echo !result!
)

endlocal
```

出力結果：

```output
a
b
c
d
e
f
```

### 参考

- [variable substring - Windows CMD - SS64.com](https://ss64.com/nt/syntax-substring.html)
- [バッチファイルでの試行錯誤を回避するためのメモ - Qiita](https://qiita.com/yz2cm/items/8058d503a1b84688af09#%E6%96%87%E5%AD%97%E5%88%97%E3%81%AE%E5%88%87%E5%87%BA%E3%81%97)
