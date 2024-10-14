---
layout:        post
title:         "[Regex] Perlでマッチした文字列を式や関数を使って変換する"
date:          2021-08-26
category:      Programming
cover:         /assets/cover14.jpg
redirect_from:
    - /regex/perl-replace-matched-text
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Perlでは置換するときに正規表現の「e」オプションを使うことで、自分の好きな関数を呼び出して文字列を置換することができます。
以下は料金の部分を税額を加算した料金に置換する例です。

```perl
$text = "りんご300円、バナナ200円、さくらんぼ400円";

sub addTax {
  my ($price) = @_;
  return $price * 1.1;
}

$text =~ s/(\d+)円/addTax($1)."円(税込)"/eg;

print $text, "\n";
# => りんご330円(税込)、バナナ220円(税込)、さくらんぼ440円(税込)
```

重要な点は、正規表現の置換をする `s///` の末尾に「e」があることです。
これにより置換後の文字列を記述する部分が式として評価されます。
マッチした文字列を抽出する `(...)` と、それを取得する `$N` と組み合わせて使うことで、より柔軟な置換処理が実現できるようになります。

以上です。

### 参考文献

<!-- http://www.oreilly.co.jp/books/9784873113593/ -->

- [詳説 正規表現 第3版 - O'Reilly Japan](https://amzn.to/3IxSBV4)
