---
layout:        post
title:         "エラーメッセージ表示用の関数"
menutitle:     "エラーメッセージ表示用の関数"
date:          2016-04-14
tags:          Programming Language Bash
category:      Shell
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

shellscriptのエラーメッセージなどを装飾する関数は、それなりに使用頻度が高いのでここにまとめておきます。

それぞれの関数について
------------------

メッセージを出力するためのそれぞれのシェル関数は、メッセージの先頭に色付きの文字を付け加えます。

- 警告を出力するための`warn`は 黄色の`Warning:`
- エラーを出力するための`error`は 赤色の`Error:`
- 成功したことを出力するための`success`は 緑色の`✔ `
- 失敗したことを出力するための`failed`は 赤色の`✘ `

```shell
function warn {
  echo -e "\033[33mWarning:\033[m" "$*"
}
```

```shell
function error {
  echo -e "\033[31mError:\033[m" "$*"
}
```

```shell
function success {
  printf " \033[32m✔ \033[m%s\n" "$*"
}
```

```shell
function failed {
  printf " \033[31m✘ \033[m%s\n" "$*"
}
```

使い方
------

使い方は、引数にメッセージを渡すだけです。

```shell
warn "任意の警告メッセージ"
```

```shell
error "任意のエラーメッセージ"
```

```shell
success "成功したこと（もの）"
```

```shell
failed "失敗したこと（もの）"
```
