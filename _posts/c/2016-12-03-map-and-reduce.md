---
layout:        post
title:         "C言語で map と reduce を行う方法"
menutitle:     "C言語で map と reduce"
date:          2016-12-03
tags:          Programming Language C
category:      C
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

とあるシミュレーションの授業で、C言語 を使わないといけなくていろいろ悩んだ挙句、
とりあえず map と reduce くらいは作ろうと思ったので、その話。

実装
------------------

C言語では高階関数を作ることができるので、引数に関数をとるように関数を定義する。
ここでの map と reduce は数値計算用に作っているので、
引数にとる関数は、double を取って double を返す関数にしてある。

それぞれの関数の引数は左から「関数」,「配列」,「配列のサイズ」 となっている。

```c
#define LEN(array) (sizeof(array) / sizeof(array[0]))

// map(lambda, array, len)
void map(double (*func)(double), double *array, size_t len) {
    int i;
    for (i = 0; i < len; i++) {
        array[i] = func(array[i]);
    }
}

// reduce(lambda, array, len) -> double
double reduce(double (*func)(double, double), double *array, size_t len) {
    int i;
    double result = 0;
    for (i = 0; i < len; i++) {
        result = func(result, array[i]);
    }
    return result;
}
```

マクロ LEN は map と reduce の内部では使われないが、
map や reduce を使うときにの3つ目の引数を与えるためのヘルパーとして用意してある。


使い方
------------------

### map

```c
double square(double x) {
    return x * x;
}

int main() {
    int i;
    double ary[] = {1,2,3,4,5,6,7,8,9};

    // map
    map(square, ary, LEN(ary));
    for (i = 0; i < LEN(ary); i++) {
        printf("%f\n", ary[i]);
    }
    // => 1.0
    // => 4.0
    // => 9.0
    // => 16.0
    // => 25.0
    // => 36.0
    // => 49.0
    // => 64.0
    // => 81.0
}
```

### reduce

```c
double add(double x, double y) {
    return x + y;
}

int main() {
    double ary[] = {1,2,3,4,5,6,7,8,9};

    // reduce
    printf("%f\n", reduce(add, ary, LEN(ary)));
    // => 45.0
}
```
