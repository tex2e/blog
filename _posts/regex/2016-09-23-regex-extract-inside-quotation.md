---
layout:        post
title:         "[Regex] 正規表現でダブルクオート内の文字列を抽出する"
date:          2016-09-23
category:      Programming
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
    - /regex/extract-inside-quotation
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
