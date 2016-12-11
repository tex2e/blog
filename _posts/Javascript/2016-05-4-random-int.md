---
layout:        post
title:         "Javascriptで整数の乱数を得る"
menutitle:     "Javascriptで整数の乱数を得る"
date:          2016-05-04
tags:          Programming Language Javascript
category:      Javascript
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

Javascriptにおいて、浮動小数型ではなくて整数型の乱数を得る方法について。


0 以上 *max* 以下の乱整数を得る関数
-------------------------------------

```js
function getRandomInt(max) {
  return Math.floor(Math.random() * (max + 1));
}
```


*min* 以上 *max* 以下の乱整数を得る関数
-------------------------------------

```js
function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
```

上の2つをまとめた関数
-------------------------------------

```js
// return random int
//
//   rand(max)      // => int where is [0, max)
//   rand(min, max) // => int where is [min, max)
//
function rand(min, max) {
  if (max === undefined) {
    max = min; min = 0;
  }
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
```
