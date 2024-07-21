---
layout:        post
title:         "[JavaScript] Rubyの .times .upto .downto メソッドを作る"
date:          2016-04-03
category:      JavaScript
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---

JavaScriptでRubyのIntegerクラスのメソッド `times`, `upto`, `downto` を作る方法について説明します。


Integer#times
--------------

### Ruby

Integer#times はブロックの処理をself回繰り返します。

```ruby
5.times do |i|
  puts i
end
```

出力

```
0
1
2
3
4
```

### JavaScript

timesメソッドをJavaScriptで実装すると次のようになります。

```js
Number.prototype.times = function (block) {
  for (var i = 0; i < this; i++) {
    block.call(null, i);
  }
  return +this;
}
```

使用例

```js
(5).times(function (i) {
  console.log(i);
});
```

Rubyで `5.` とだけ書くとSyntax Errorとなるが、
JavaScriptでは `5.` は整数の5と解釈されます。
それが影響しているかどうかはわからないですが、JavaScriptのNumberのインスタンスメソッドを呼び出すときは
値をパーレン`()`で囲む必要があります。

変数に代入して使う分にはパーレンを付けなくても問題ないです。

```js
var n = 5;
n.times(function (i) {
  console.log(i);
});
```


Integer#upto
-------------

### Ruby

Integer#upto はブロックの処理をselfからlimitまで1ずつ増やしながら繰り返します。

```ruby
1.upto(5) do |i|
  puts i
end
```

出力

```
1
2
3
4
5
```

### JavaScript

uptoメソッドをJavaScriptで実装すると次のようになります。

```js
Number.prototype.upto = function (limit, block) {
  if (limit < this) return +this;

  for (var i = +this; i <= limit; i++) {
    block.call(null, i);
  }
  return +this;
};
```

使用例

```js
(1).upto(5, function(i) {
  console.log(i);
});
```


Integer#downto
---------------

### Ruby

Integer#downto はブロックの処理をselfからlimitまで1ずつ減らしながら繰り返します。

```ruby
15.downto(10) do |i|
  puts i
end
```

出力

```
15
14
13
12
11
10
```

### JavaScript

downtoメソッドをJavaScriptで実装すると次のようになります。

```js
Number.prototype.downto = function (limit, block) {
  if (limit > this) return +this;

  for (var i = +this; i >= limit; i--) {
    block.call(null, i);
  }
  return +this;
};
```

使用例

```js
(15).downto(10, function (i) {
  console.log(i);
});
```

以上です。
