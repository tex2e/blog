---
layout:        post
title:         "有限体(ガロア体)をPythonで実装する"
menutitle:     "有限体(ガロア体)をPythonで実装する"
date:          2019-02-20
tags:          Crypto
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

**有限体**（finite field）とは、代数学において有限個の元からなる体、つまり四則演算が定義され閉じている有限集合のことです。
主に計算機関連の分野においては、発見者であるエヴァリスト・ガロアにちなんで**ガロア体**（Galois field）などとも呼ばれます。

Pythonで演算子オーバーライドで有限体を実装したのが以下です。
割り算で逆元を求めるために、拡張ユークリッド互除法の `xgcd` とモジュラ逆数を求める `invmod` を使っています。

```python

def xgcd(a, b):
    x0, y0, x1, y1 = 1, 0, 0, 1
    while b != 0:
        q, a, b = a // b, b, a % b
        x0, x1 = x1, x0 - q * x1
        y0, y1 = y1, y0 - q * y1
    return a, x0, y0

def invmod(a, m):
    g, x, y = xgcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m

def GF(p):

    class Fp:
        def __init__(self, val):
            self.val = int(val) % Fp.p

        def __neg__(self):
            return Fp(-self.val)

        def __add__(self, other):
            return Fp(self.val + int(other))

        def __sub__(self, other):
            return Fp(self.val - int(other))

        def __mul__(self, other):
            return Fp(self.val * int(other))

        def __pow__(self, e):
            return Fp(pow(self.val, int(e), Fp.p))

        def __floordiv__(self, other):
            return self * invmod(other.val, Fp.p)

        def __mod__(self, m):
            return self.val % int(m)

        def __eq__(self, other):
            return self.val == other.val

        def __repr__(self):
            return str(self.val)

        def __int__(self):
            return self.val

        __radd__ = __add__
        __rsub__ = __sub__
        __rmul__ = __mul__
        __rfloordiv__ = __floordiv__

    Fp.p = p
    return Fp


F5 = GF(5) # 位数が5の有限体
a = F5(2)
b = F5(4)
print('a =', a) # => 2
print('b =', b) # => 4
print('a + b =', a + b) # => 1
print('a * b =', a * b) # => 3
print('a // b =', a // b) # => 3
```

以上です
