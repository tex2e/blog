---
layout:        post
title:         "正規表現でHTMLのコメントを抽出する"
date:          2023-01-29
category:      Regex
cover:         /assets/cover14.jpg
redirect_from:
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
- [詳説 正規表現 第3版](http://www.oreilly.co.jp/books/9784873113593/)

