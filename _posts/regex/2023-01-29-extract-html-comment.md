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

<!-- http://www.oreilly.co.jp/books/9784873113593/ -->

- [詳説 正規表現 第3版 - O'Reilly Japan](https://amzn.to/3IxSBV4)

<a href="https://www.amazon.co.jp/%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE-%E7%AC%AC3%E7%89%88-Jeffrey-F-Friedl/dp/4873113598?__mk_ja_JP=%E3%82%AB%E3%82%BF%E3%82%AB%E3%83%8A&crid=JVX7BNB30DDO&keywords=%E8%A9%B3%E8%AA%AC+%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE&qid=1676777838&s=books&sprefix=%E8%A9%B3%E8%AA%AC+%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE%2Cstripbooks%2C172&sr=1-1&linkCode=li3&tag=tex2e-22&linkId=5ac3b33eff776e2785aa0de8ede06be0&language=ja_JP&ref_=as_li_ss_il" target="_blank"><img border="0" src="//ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=4873113598&Format=_SL250_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=tex2e-22&language=ja_JP" ></a><img src="https://ir-jp.amazon-adsystem.com/e/ir?t=tex2e-22&language=ja_JP&l=li3&o=9&a=4873113598" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
