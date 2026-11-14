---
layout:        post
title:         "[JavaScript] Uint8ArrayとBase64形式の相互変換"
type:          How-To
description:   "JavaScriptのbtoaとatobを利用してUint8ArrayのバイナリデータとBase64形式の文字列を相互変換する関数の実装方法。"
tags:          [javascript, base64, uint8array]
status:        stable
stale_after:   2028-08-10T00:00:00Z
generated:
  by:          human:tex2e
  at:          2025-08-10T07:58:53Z
date:          2025-08-10
category:      JavaScript
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Uint8ArrayからBase64形式の文字列への変換と、Base64からUint8Arrayへの変換は、以下のメソッドをJavaScriptで定義するだけで変換できるようになります。

```js
function base64encode(uint8arrayData) {
    return btoa([...uint8arrayData].map(n => String.fromCharCode(n)).join(""));
}

function base64decode(stringData) {
    return new Uint8Array([...atob(stringData)].map(s => s.charCodeAt(0)));
}
```

base64encodeとbase64decodeのメソッドの使い方は以下の通りです。

```js
const buffer = new Uint8Array([30,31,32,33]);
const base64data = base64encode(buffer);
// => 'Hh8gIQ=='
const byteData = base64decode('Hh8gIQ==');
// => Uint8Array(4) [30, 31, 32, 33]
```

以上です。
