---
layout:        post
title:         "findで特定パスを除外してファイル名を検索する方法"
date:          2023-08-20
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

findコマンドで特定のパスやディレクトリを検索対象から除外する方法について説明します。

### find + grep -v
findで検索してgrepで必要ないパスを除外する (-v オプションを使う) 方法が一番シンプルです。
```bash
find /path/to/dir/ -type f | grep -E -v "^/path/to/dir/(backup|error)/"
```

### find -not -path
findには -path で検索対象に特定のパスを指定することができます（ワイルドカード `*` の指定が必要です）。
これを、-not と組み合わせることで、特定のパスを除外することができます。
```bash
find /path/to/dir/ -type f -not -path '/path/to/dir/backup/*'
```
対象のパスが複数存在する場合は、-o (OR演算子) でつなげて指定することもできます。その際は丸括弧 `\( \)` で囲まないといけない点に注意が必要です。
```bash
find /path/to/dir/ -type f -not \( -path '/path/to/dir/backup/*' -o -path '/path/to/dir/error/*' \)
```

### find -regex
複数のパスを除外する際に -o (OR演算子) で繋げると長くなりますが、正規表現でパスを指定できるとより簡潔にパスを除外できるようになります。
-regex も -path と同様にパスを指定できますが、-regex は正規表現でパスを指定します。
ただし、-regex を使うときは追加で -regextype で正規表現の種類を指定しないと意図しない正規表現になる可能性があります。
```bash
find /path/to/dir/ -type f -regextype egrep -not -regex '^/path/to/dir/(backup|error)/.*'
```

以上です。
