---
layout:        post
title:         "ルジャンドル記号による楕円曲線の位数計算"
date:          2019-08-10
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

有限体上 $\mathbb{F}_q$ の楕円曲線 $E(\mathbb{F}_q)$ の位数 (曲線上にある全ての点の個数) を計算する最も簡単な方法として、ルジャンドル記号を用いるものがあります[^tsuji]。

### ルジャンドル記号

ルジャンドル記号 (Legendre symbol) は、$a \ge 0$ が奇素数 $p$ を法として平方剰余であれば $1$、そうでなければ $-1$、$a$ が $p$ で割り切れる場合は $0$ を返します。

$$
\left(\frac{a}{p}\right) =
\begin{cases}
\phantom{-}0 & \text{if} \; \mathrm{gcd}(a,p) \ne 1 \\
\phantom{-}1 & \text{if} \; \mathrm{QR}(a,p) \\
          -1 & \text{if} \; \mathrm{QNR}(a,p)
\end{cases}
$$

Pythonで書くとルジャンドル記号を求める関数 `legendre_symbol` は以下のようになります（平方剰余判定をする関数 `QR` も定義しました）。

```python
import math

def QR(a, p):
    return pow(a, (p - 1) // 2, p) == 1

def legendre_symbol(a, p):
    if math.gcd(a, p) != 1:
        return 0
    if QR(a, p):
        return 1
    else:
        return -1
```

### 楕円曲線の位数計算

簡単化のため、楕円曲線を $Y^2 = f(X)$ とします。
$\mathbb{F}_p$ の元 $x$ を代入して、$f(x)$ が平方剰余を持たないときは**0点**が楕円曲線上にあり（存在しない）、$f(x) = 0$ のときは $(x,0)$ の**1点**が楕円曲線上にあり、$f(x)$ が $p$ を法とする平方剰余を持つ場合は $(x, \pm y)$ の**2点**が楕円曲線上にあります。平方剰余であれば $1$ 、そうでなければ $-1$ を返すルジャンドル記号を用いて、任意の $x$ にある楕円曲線上の点の数を数式で表すと、次のように書くことができます。

$$
1 + \bigg( \frac{f(x)}{p} \bigg) \;\;\;\text{...  0, 1, 2 のどれかになる}
$$

楕円曲線の全ての点の数は無限遠点に全ての $x \in \mathbb{F}_p$ にある楕円曲線上の点を加えた形となります。
よって、楕円曲線の位数を式で表すと次のようになります。

$$
\begin{align}
\text{#}E(\mathbb{F}_p) &= 1 + \sum_{x \in \mathbb{F}_p} \left( 1 + \bigg(\frac{f(x)}{p}\bigg) \right) \\
  &= p + 1 + \sum_{x \in \mathbb{F}_p} \bigg(\frac{f(x)}{p}\bigg)
\end{align}
$$

ルジャンドル記号を用いた楕円曲線の位数計算をPythonで書くと以下のようになります。
ここでは例として、有限体 $\mathbb{F}_{11}$ 上の楕円曲線 $y^2 \equiv x^3 + x + 6 \pmod{11}$ の位数を計算しています。

```python
p = 11       # Fp
A, B = 1, 6  # y^2 = x^3 + Ax + B

def f(x):
    return (pow(x, 3, p) + A * x + B) % p

total = 0
for x in range(p):
    total += legendre_symbol(f(x), p)

print(p + 1 + total)
# => 13
```

楕円曲線 $y^2 \equiv x^3 + x + 6 \pmod{11}$ の位数は $13$ になりました。
答えの確認のために Sage でも計算してみます。

```python
$ sage
sage: F = GF(11)
sage: EC = EllipticCurve(F, [1, 6])
sage: EC.order()
13
```

適当に楕円曲線のパラメータを変えても2つの出力が一致するので、正しくプログラムが書けたと思います。

しかし、この方法は計算時間が $p$ の指数時間を必要とするので、実際の位数計算では、より高速な**スクーフ (Schoof) アルゴリズム**などを使います。



-----

[^tsuji]: [辻井 重男, 笠原 正雄, 有田 正剛, 境 隆一, 只木 孝太郎, 趙 晋輝, 松尾 和人: 暗号理論と楕円曲線. 森北出版, 2008](https://www.morikita.co.jp/books/book/2213)
