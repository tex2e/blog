---
layout:        post
title:         "sleep関数"
menutitle:     "sleep関数"
date:          2016-06-16
tags:          Programming Language Javascript
category:      Javascript
author:        tex2e
cover:         /assets/mountain-alternative-cover.jpg
redirect_from:
comments:      false
published:     true
---

Promiseの復習も兼ねて、Promiseを使ってsleep関数を作る方法の説明。

Promiseを使ったsleep関数
----------------------

sleep関数とその使い方

```js
function sleep(time) {
    return new Promise((resolve, reject) => setTimeout(resolve, time));
}

sleep(1000).then(() => {
    // sleepの後に実行される
});
```

Promiseはコンストラクタに渡された引数の関数に、`resolve`と`reject`という二つの関数を渡します。
resolveが実行されたら、状態（status）を「resolved」にします。
rejectが実行されたら、状態を「rejected」にします。
一度決定した状態は変更することができません。

sleep関数の返り値は、Promiseのインスタンスです。
Promiseのインスタンスの状態（status）が「resolved」になった時に実行したい処理を、
関数（無名関数）にして`then`の引数に渡してあげます。

ちなみに `setTimeout` は指定した秒数（ms）後に、第一引数の関数を実行します。
なので、指定した秒数の後に `resolve` を実行すれば、Promiseを使ってsleep関数を作ることができました。


Promiseを使わないsleep関数
------------------------

もちろんPromiseを使わないでも作ることができます。

```js
function sleep(time, func) {
    return setTimeout(func, time);
}

sleep(1000, () => {
    // sleepの後に実行される
});
```

この例ではPromiseを作らず、sleepの引数に、時間になったら実行したい処理を無名関数にして渡してあげます。
そして、setTimeoutを使って、時間になったら関数を実行させます。

-----

sleep関数だけについて言えば、Promiseを使わない方が短く済むわけですが、
Promiseを使った方が`then`という関数が使えて、英語としても読みやすくなるのではないでしょうか。


### 補足

Promiseの力を最大限利用するには、`Promise#then`と`Promise#catch` や `Promise.all`と`Promise.race`
について調べておくと良いかと思います。
