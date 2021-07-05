---
layout:        post
title:         "Bashのif文でANDやOR条件、&&や||演算子を使う"
date:          2021-07-03
category:      Shell
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

testコマンドの引数で -a (AND条件) と -o (OR条件) を使います。
[ ] はtestコマンドの糖衣構文なので、if [ 条件1 -a 条件2 ] のように書くことができます。
また、Bashで使える演算子には && (AND演算子) と || (OR演算子) があります。
使い方は if [ ... ] && [ ... ] です。
まとめると以下のようになります。

- testコマンドの引数
  - `-a` (AND条件) : `if [ 条件1 -a 条件2 ]`
  - `-o` (OR条件) : `if [ 条件1 -o 条件2 ]`
- 演算子
  - `&&` (AND演算子) : `if [ 条件1 ] && [ 条件2 ]`
  - `||` (OR条件) : `if [ 条件1 ] || [ 条件2 ]`


上記の引数と演算子を組み合わせることで複雑な条件文を書くことができるようになります。

```bash
if [ "$1" = "-h" -o "$1" = "--help" ]; then
    # 引数が -h または --help のとき
fi

if [ "$1" = "run" -a "$2" != "" ] \
    || [ "$1" = "setup" -o "$1" = "init" ]; then
    # 引数が run PARAM または setup または init のとき
fi
```

以上です。
