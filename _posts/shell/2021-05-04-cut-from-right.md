---
layout:        post
title:         "Bashで文字列の右からN文字分を削除する"
date:          2021-05-05
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Bashで文字列の右からN文字分を削除する方法について説明します。
まず、cutコマンドは左からN文字分を削除することができますが、右からを指定することができません。
なので、revコマンドで左右反転させてからcutして再度revすると、右からN文字分を削除できるようになります。

```bash
INDENT_LEVEL=2
echo "TEST_TEXT" | rev | cut -c $((INDENT_LEVEL+1))- | rev
# => TEST_TE
```

Git Bash のような rev コマンドが存在しない一部の環境では、代わりに awk を使うことで上と同じことを実現できます。

```bash
echo "TEST_TEXT" | awk -v indentlevel=$INDENT_LEVEL '{print substr($0, 0, length($0)-indentlevel)}'
# => TEST_TE
```

以上です。


### 参考文献

- [Linux/UNIXで文字列から特定部分(右から・左から何個、〇〇\~〇〇まで)を抜き出すコマンド \| 俺的備忘録 〜なんかいろいろ〜](https://orebibou.com/ja/home/201602/20160228_001/)
