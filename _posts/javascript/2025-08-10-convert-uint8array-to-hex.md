---
layout:        post
title:         "[JavaScript] Uint8ArrayをHex形式（16進数）に変換する"
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

Uint8ArrayをHex形式（16進数）に変換するには、以下のメソッドをJavaScriptで定義するだけで変換できるようになります。

```js
function buf2hex(buffer) {
    return [...new Uint8Array(buffer)]
        .map(x => x.toString(16).padStart(2, '0'))
        .join('');
}
```

buf2hexの使い方は以下の通りです。

```js
const buffer = new Uint8Array([30,31,32,33])
const hex = buf2hex(buffer);
// => '1e1f2021'
```

以上です。
