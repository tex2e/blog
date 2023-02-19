---
layout:        post
title:         "正規表現でダブルクオート内の文字列を抽出する"
date:          2016-09-23
category:      Regex
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---

正規表現でダブルクオート内の文字列を抽出する方法について説明します。

例えば、`title: "任意の文字列"` から `任意の文字列` を取り出す方法についてです。


### (1) エスケープされたダブルクオートがない場合

この場合は非常に簡単で、「控えめな量指定子」である `.*?` などを使います。多くの言語では、この正規表現が使えます。
ただし、古い言語や古い正規表現エンジンを使っている場合は、この指定子は存在しません。

```js
let text = 'title: "任意の文字列"';
let m = text.match(/"(.*?)"/);
let result = m && m[1];
```

控えめな量指定子を使う代わりに、否定の文字集合 `[^ ]` を使って中の文字列を抽出することもできます。

```js
let text = 'title: "任意の文字列"';
let m = text.match(/"([^"]*)"/);
let result = m && m[1];
```


### (2) エスケープされたダブルクオートがある場合

例えば `title: "今日の \"本のタイトル\" の感想"` から `今日の \"本のタイトル\" の感想` を取り出す方法について説明します。
結論から言うと、正規表現 `"([^\\"]+|\\.)*"` を使用します。

```js
let text = 'title: "今日の \\"本のタイトル\\" の感想"';
let m = text.match(/"((?:[^\\"]+|\\.)*)"/);
let result = m && m[1];
```

以上です。

### 参考文献

<!-- http://www.oreilly.co.jp/books/9784873113593/ -->

- [詳説 正規表現 第3版 - O'Reilly Japan](https://amzn.to/3IxSBV4)

<a href="https://www.amazon.co.jp/%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE-%E7%AC%AC3%E7%89%88-Jeffrey-F-Friedl/dp/4873113598?__mk_ja_JP=%E3%82%AB%E3%82%BF%E3%82%AB%E3%83%8A&crid=JVX7BNB30DDO&keywords=%E8%A9%B3%E8%AA%AC+%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE&qid=1676777838&s=books&sprefix=%E8%A9%B3%E8%AA%AC+%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE%2Cstripbooks%2C172&sr=1-1&linkCode=li3&tag=tex2e-22&linkId=5ac3b33eff776e2785aa0de8ede06be0&language=ja_JP&ref_=as_li_ss_il" target="_blank"><img border="0" src="//ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=4873113598&Format=_SL250_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=tex2e-22&language=ja_JP" ></a><!--<img src="https://ir-jp.amazon-adsystem.com/e/ir?t=tex2e-22&language=ja_JP&l=li3&o=9&a=4873113598" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />-->

