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

Bashで使える演算子には && (AND演算子) と || (OR演算子) があります。
使い方は if [ ... ] && [ ... ] です。
また、testコマンドの引数では -a (AND条件) と -o (OR条件) が使えます。
[ ] はtestコマンドの糖衣構文なので、if [ 条件1 -a 条件2 ] のように書くことができます。
まとめると以下のようになります。

- 演算子
  - `&&` (AND演算子) : `if [ 条件1 ] && [ 条件2 ]`
  - `||` (OR条件) : `if [ 条件1 ] || [ 条件2 ]`
- testコマンドの引数
  - `-a` (AND条件) : `if [ 条件1 -a 条件2 ]`
  - `-o` (OR条件) : `if [ 条件1 -o 条件2 ]`

上記の引数と演算子を組み合わせることで複雑な条件文を書くことができるようになります。

```bash
if [ "$1" = "-h" -o "$1" = "--help" ]; then
    # 引数が -h または --help のとき
fi

if [ -e from.txt ] && [ ! -e to.txt ]; then
    # from.txtは存在するが、to.txtが存在しないとき
fi

if [ "$1" = "run" -a "$2" != "" ] || [ "$1" = "setup" -o "$1" = "init" ]; then
    # 引数が run PARAM または setup または init のとき
fi
```

### 追記 (-a と -o は非推奨)

「[シェルスクリプトの \[ -a (AND) と -o (OR) \] は非推奨だかんね - Qiita](https://qiita.com/ko1nksm/items/6201b2ce47f4d6126521)」によると、-a と -o は非推奨らしいです。
複雑な条件文を使いたい場合は `{ }` を使って優先順位を指定しましょう。

```bash
if { [ "$1" = "run" ] && [ "$2" != "" ] } || { [ "$1" = "setup" ] || [ "$1" = "init" ] }; then
    # 引数が run PARAM または setup または init のとき
fi
```


以上です。
