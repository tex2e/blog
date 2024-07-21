---
layout:        post
title:         "[JavaScript] node.js の EventEmitter をブラウザでも使う"
date:          2016-09-25
category:      JavaScript
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---

node.js の標準ライブラリの1つである EventEmitter をブラウザで使う方法。


結論
----------------

EventEmitter のソースコードを CDN として利用できるようにしておきました。
手っ取り早く使いたいという方はこちらを使ってください。

### 使い方

```html
<script src="https://cdn.rawgit.com/tex2e/86991945ee5cd982c9827c75b52eebe9/raw/EventEmitter.min.js"></script>
<script>
  class MyEmitter extends EventEmitter {};

  const myEmitter = new MyEmitter();
  myEmitter.on('event', () => {
    console.log('an event occurred!');
  });
  myEmitter.emit('event');
</script>
```


自分で用意する方法
----------------

### EventEmitter のコードの取り出し

Github の node レポジトリから EventEmitter だけを持ってくるのもいいですが大変なので、
ここでは browserify を使います。

```bash
$ browserify <(echo "require('events').EventEmitter") > EventEmitter.js
```

browserify は複数のファイルをまとめて、ブラウザでも実行できるようにしてくれますが、
今回は EventEmitter の機能だけを取り出したいので、出力されたファイルの先頭行と末尾の数行を変更します。

変更前

```js
(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
// ...
// EventEmitter のコード
// ...

},{}],2:[function(require,module,exports){
require('events').EventEmitter

},{"events":1}]},{},[2]);
```

変更後

```js
var EventEmitter = (function () {
// ...
// EventEmitter のコード
// ...

return EventEmitter;
});
```

あとは、コード内で `module.exports = ...` という部分をコメントアウトすれば、ブラウザで使える EventEmitter.js の完成です。


### EventEmitter のコードの圧縮

EventEmitter.js から空白やコメントなどを除いて、ファイルサイズを減らすには uglifyjs を使います。

```js
$ uglifyjs EventEmitter.js > EventEmitter.min.js
```

以上です。
