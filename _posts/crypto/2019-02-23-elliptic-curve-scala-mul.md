---
layout:        post
title:         "有限体上の楕円曲線上のスカラー倍算"
menutitle:     "有限体上の楕円曲線上のスカラー倍算"
date:          2019-02-23
tags:          Crypto
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

有限体上の楕円曲線上のスカラー倍算のPython実装について。

有限体上の楕円曲線や、曲線上の点を探す方法、点同士の演算などについては同サイトの
[有限体上の楕円曲線の点集合](/blog/crypto/point-of-elliptic-curve-over-GF)
を参照してください。
まず、有限体上の楕円曲線上の点の加算 $(x_3, y_3) = (x_1, y_1) + (x_2, y_2)$ は次の通りです。

$$
\begin{align}
  x_3 &= \lambda^2 - x_1 - x_2     \mod{p} \\
  y_3 &= \lambda (x_1 - x_3) - y_1 \mod{p} \\[10pt]
  \lambda &= \begin{cases}
    \cfrac{y_2 - y_1}{x_2 - x_1} \mod{p} & \mathrm{if}\; P \ne Q \\[3pt]
    \cfrac{3 x_1^2 + a}{2 y_1}   \mod{p} & \mathrm{if}\; P = Q
  \end{cases}
\end{align}
$$

例えば、有限体 $F_11$ 上の楕円曲線 $y^2 = x^3 + x + 6$ とする（$a = 1,\, b = 6$）。曲線上の点 $\alpha = (2,7)$ を選んだとき、$2\alpha = (2,7) + (2,7)$ を計算するには[^DRS]、
楕円曲線上の2倍算の式より、

$$
\begin{align}
  \lambda &= (3 \times 2^2 + 1) (2 \times 7)^{-1} \;\mathrm{mod}\; 11  = 8 \\[5pt]
  x_3 &= 8^2 - 2 - 2 \;\mathrm{mod}\; 11 = 5 \\
  y_3 &= 8 (2-5) - 7 \;\mathrm{mod}\; 11 = 2
\end{align}
$$

よって $2\alpha = (5,2)$ となります。
次に $3 \alpha = 2 \alpha + \alpha = (5,2) + (2,7)$ を計算すると、

$$
\begin{align}
  \lambda &= (7 - 2) (2 - 5)^{-1} \;\mathrm{mod}\; 11  = 2 \\[5pt]
  x_3 &= 2^2 - 5 - 2 \;\mathrm{mod}\; 11 = 8 \\
  y_3 &= 2 (5-8) - 2 \;\mathrm{mod}\; 11 = 3
\end{align}
$$

よって $3\alpha = (8,3)$ となります。

次に、これを $k \,\alpha$（$k$は任意の整数）のときでも計算できるようにPythonで実装していきます。
楕円曲線を実装する前に、有限体の演算ができるようにする必要があります。
有限体上の足し算と掛け算は簡単だが、割り算では逆元を求める必要があるので、
拡張ユークリッドの互除法と乗法逆元を求める関数も定義しておきます。

```python

# 拡張ユークリッドの互除法
def xgcd(a, b):
    x0, y0, x1, y1 = 1, 0, 0, 1
    while b != 0:
        q, a, b = a // b, b, a % b
        x0, x1 = x1, x0 - q * x1
        y0, y1 = y1, y0 - q * y1
    return a, x0, y0

# 有限体の乗法逆元（モジュラ逆数）を求める
def invmod(a, m):
    g, x, y = xgcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m

# 有限体 (ただしpは素数)
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


# 有限体上の楕円曲線
class EllipticCurveOverFp:
    """
    y**2 = x**3 + a*x + b (mod p)
    """

    def __init__(self, a, b, p):
        self.p = p
        self.Fp = GF(p)
        self.a = self.Fp(a)
        self.b = self.Fp(b)


# 楕円曲線の点
class PointOverEC:

    def __init__(self, curve, x, y, infinity=False):
        self.curve = curve
        self.Fp = curve.Fp
        self.x = x
        self.y = y
        self.infinity = infinity
        if self.Fp(y**2) != self.Fp(x**3 + curve.a * x + curve.b):
            raise Exception('(%d, %d) is not on curve!' % (x, y))

    @staticmethod
    def get_infinity():
        dummy_curve = EllipticCurveOverFp(0,0,1)
        return PointOverEC(curve=dummy_curve, x=0, y=0, infinity=True)

    def is_infinity(self):
        return self.infinity

    def get_point(self):
        return self.Fp(self.x), self.Fp(self.y)

    def __str__(self):
        if self.infinity:
            return "(∞,∞)"
        return "({},{})".format(self.x, self.y)

    # 楕円曲線上の点の加算
    def __add__(self, other):
        x1, y1 = self.get_point()
        x2, y2 = other.get_point()

        if x1 == x2 and y2 == -y1:
            return PointOverEC.get_infinity()
        if self.is_infinity():
            return other
        if other.is_infinity():
            return self

        if x1 == x2 and y1 == y2:
            l = (3 * x1**2 + self.curve.a) // (2 * y1)
        else:
            l = (y2 - y1) // (x2 - x1)

        x3 = l**2 - x1 - x2
        y3 = l * (x1 - x3) - y1

        return PointOverEC(self.curve, x3, y3)

    # 楕円曲線上の点のスカラー倍算
    def __rmul__(self, n):
        # O(log2(n))
        tmp = self
        point = PointOverEC.get_infinity()
        while n > 0:
            if n & 1 == 1:
                point += tmp
            n >>= 1
            tmp += tmp
        return point


curve = EllipticCurveOverFp(a=1, b=6, p=11)
a = PointOverEC(curve, x=2, y=7)

# 点の位数を求める（無限遠点になるまでスカラー倍する）
for k in range(1, 20):
    ka = k * a
    print('%2d: %s' % (k, ka))
    if ka.is_infinity():
        break
```

実行結果は以下のようになります。
よって、今回例として使った有限体上の楕円曲線上の点 $(2,7)$ の位数（元の位数）は $12$ ということがわかります。

```
 1: (2,7)
 2: (5,2)
 3: (8,3)
 4: (10,2)
 5: (3,6)
 6: (7,9)
 7: (7,2)
 8: (3,5)
 9: (10,9)
10: (8,8)
11: (5,9)
12: (2,4)
13: (∞,∞)
```

### パラメータを変更してみる

上の例では「元の位数」が「群の位数${} - 1$」と等しくなりましたが、そうならない楕円曲線や点もあります。
例えば有限体 $F_{11}$ 上の楕円曲線を $y^2 = x^3 + x + 2$ として、曲線上の点 $(2,1)$ を選ぶと、
Pythonのプログラムは

```python
curve = EllipticCurveOverFp(a=1, b=2, p=11)
a = PointOverEC(curve, x=2, y=1)
```

となり、実行すると以下のようになります。よって、点 $(2,1)$ の位数は $8$ ということがわかり、「元の位数」が「群の位数${} - 1$」にならないことが確認できます。

```
 1: (2,1)
 2: (8,4)
 3: (4,9)
 4: (10,0)
 5: (4,2)
 6: (8,7)
 7: (2,10)
 8: (∞,∞)
```

安全な楕円曲線は位数が大きくなるようにパラメータが決められているので、
楕円曲線暗号を実装する場合はガイドラインで決められているパラメータを使用するようにしましょう。
例えば楕円曲線暗号として secp256k1 を使いたい場合は次のようになっています[^secp256k1]。

$$
p = 2^{256} - 2^{32} - 2^9 - 2^8 - 2^7 - 2^6 - 2^4 - 1,\;\; a = 0,\;\; b = 7
$$


### 余談

実装したプログラムの確認には「[Elliptic Curve Calculator](http://www.christelbach.com/ECCalculator.aspx)」を使いました。
ちょっと計算してみたいけどプログラム書くのが面倒なときに重宝すると思います。


-----

[^DRS]: Douglas R. Stinson 著, 櫻井幸一 訳『暗号理論の基礎』共立出版 1996
[^secp256k1]: [Secp256k1 - Bitcoin Wiki](https://en.bitcoin.it/wiki/Secp256k1)
