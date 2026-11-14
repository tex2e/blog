---
layout:        post
title:         "[Regex] 正規表現でHTMLのコメントを抽出する"
type:          How-To
description:   "改行を含むHTMLコメントを抽出する正規表現について、控えめな量指定子を使う記法と使えない環境向けの基本記法を解説。"
tags:          [regex, html, programming]
status:        stable
stale_after:   2026-02-19T00:00:00Z
generated:
  by:          human:tex2e
  at:          2023-01-29T06:23:44Z
sources:
  - id:        ref-1
    resource:  https://amzn.to/3IxSBV4
    title:     "詳説 正規表現 第3版 - O'Reilly Japan"
date:          2023-01-29
category:      Programming
cover:         /assets/cover14.jpg
redirect_from:
    - /regex/extract-html-comment
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

正規表現でHTMLのコメントを抽出する方法について説明します。

HTMLのコメントとは `<!--` から始まり、`-->` で終わる改行などの空白を含めた文字列です。
HTMLのコメントを抽出するための正規表現は、`<!--([^-]*|-(?=[^-])|--(?=[^>]))-->` となります。
プログラミング言語の正規表現エンジンにて、控えめな量指定子が使える場合は、`<!--(.*?)-->` となります。

```js
let text = `
<!-- ここにはタイトルを追加すること -->
<div>テストテキスト</div>
<!-- ここに説明を追加する。
     図を用意できれば良い
-->
<div>テストテキスト</div>
`;
let comments = text.matchAll(/<!--([^-]*|-(?=[^-])|--(?=[^>]))-->/g);
for (let comment of comments) {
    console.log(comment[0])
}
```

出力結果：

```output
<!-- ここにはタイトルを追加すること -->
<!-- ここに説明を追加する。
     図を用意できれば良い
-->
```

以上です。

### 参考文献

<!-- http://www.oreilly.co.jp/books/9784873113593/ -->

- [詳説 正規表現 第3版 - O'Reilly Japan](https://amzn.to/3IxSBV4)
