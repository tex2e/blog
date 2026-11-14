---
layout:        post
title:         "[JavaScript] 整数の乱数を取得する方法"
type:          How-To
description:   "JavaScriptのMath.randomとMath.floorを組み合わせて任意の範囲の整数乱数を生成する関数の書き方を解説。"
tags:          [javascript, random, math]
status:        stable
stale_after:   2027-07-21T00:00:00Z
generated:
  by:          human:tex2e
  at:          2016-12-05T14:01:50Z
date:          2016-05-04
category:      JavaScript
author:        tex2e
cover:         /assets/cover14.jpg
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
