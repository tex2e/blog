---
layout:        post
title:         "JavaScriptでGETパラメータの取得"
date:          2016-09-23
category:      JavaScript
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---

JavaScriptでGETパラメータを取得する関数を定義します


問題
----------

次のことをする関数を作ります。

- JavaScriptでGETに渡されたパラメータを名前で取得する
- 取得した値がURLエンコードされていれば、デコードする


解決方法
----------

某JSライブラリの中を調べていたら簡潔な実装を見つけたので、以下に書きます。

```js
var getParameterByName = function(name) {
    var match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
    return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
}
```

この関数の動作確認は、例えばURLに `title` パラメータを含ませて、

http://適当なホスト名?title=Vim%20%26%20Emacs%20%E6%B4%BB%E7%94%A8%E8%A1%93

としてから、

```
var title = getParameterByName("title");
```

とするとデコードされた文字列を取得することができます（この場合は「Vim & Emacs 活用術」）。
