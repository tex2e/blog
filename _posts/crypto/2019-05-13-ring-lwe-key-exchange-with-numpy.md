---
layout:        post
title:         "NumPyでRing-LWEによる鍵共有"
menutitle:     "NumPyを使ったRing-LWEによる鍵共有"
date:          2019-05-13
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
---

NumPyを使ったRing-LWE格子暗号による鍵共有について説明します。前回のSageMathを使ったRing-LWE格子暗号による鍵共有の続きです。
SageMathを使ったのは多項式環の演算を簡単にするためでした。

前回：[SageMathでRing-LWEによる鍵共有]({{ site.baseurl }}/crypto/ring-lwe-key-exchange)

### Ring-LWE問題

おさらいですが、**Ring-LWE**（RLWE）問題とは、LWE問題を有限体上の多項式環に限定した問題です。
簡単に説明すると、以下の方程式で多項式 $a(x), b(x)$ が与えられたとき、秘密の多項式 $s(x)$ を求める問題です。

$$
b(x) = a(x) \cdot{} s(x) + e(x)
$$

ただし、多項式の演算は有限体上の多項式環 $R_q = \mathbb{F}_q[x] / (x^n + 1)$ 上で行います。

### 有限体の多項式環上の演算

有限体の多項式環 $R_q$ 上の演算は、次のように行います。

- 加算
  1. 多項式同士で加算を行う
  2. 各係数を $\mathrm{mod}\;q$ する
- 乗算
  1. 多項式同士で乗算を行う
  2. 既約多項式 $x^n+1$ で割った余りの多項式を求める
  3. 各係数を $\mathrm{mod}\;q$ する

Ring-LWEの方程式の計算例を示します。例えば、多項式の項数 $n=2$、各係数の法 $q=101$ とし、各多項式 $a, s, e \in R_q$ を次のようにします。
なお、$a(x)$ の各係数は有限体 $\mathbb{F}_q$ 上の**一様分布**の乱数で決め、$s(x), e(x)$ の各係数は有限体 $\mathbb{F}_q$ 上の**誤差分布**（正規分布 $N(0, \sigma)$ を整数に丸めた上で $\mathbb{mod}\;q$ したもの）の乱数で決めています。

<!--
n = 2
q = 101
Z.<X> = PolynomialRing(GF(q))
R.<x> = Z.quotient(X^n + 1)
a = R(13*x + 99)
s = R(4*x + 6)
e = R(99*x + 99)
a*s + e


n = 2
q = 101
e1 = 13*x + 99
e2 = 4*x + 6
e3 = 99*x + 99
f = x^n + 1
e1e2 = e1 * e2
quo,rem = e1e2.maxima_methods().divide(f)
[Mod(e, q) for e in rem.list()]
-->

$$
\begin{aligned}
  a(x) &= 13x + 99 &\text{(0〜100 の一様分布)} \\
  s(x) &= 4x + 6   &\text{(0を中心とする誤差分布)} \\
  e(x) &= 99x + 99 &\text{(0を中心とする誤差分布)}
\end{aligned}
$$

このときの $b(x) \in R_q$ を計算してみます。

$$
\begin{aligned}
  b(x) &= a(x) \cdot{} s(x) + e(x) \\
    &= (13x + 99) (4x + 6) + (99x + 99) \\
    &= (52x^2 + 474x + 594) + (99x + 99) \\
    &\;\;\;\;\;\;\;\;\;\;\;\; \text{ここで} a(x) \cdot{} s(x) \text{を既約多項式} (x^2 + 1) \text{で割った余りを求める。} \\
    &\;\;\;\;\;\;\;\;\;\;\;\; (52x^2 + 474x + 594) = 52 (x^2 + 1) + (474x + 542) \text{が成立するので、} \\
    &= (474x + 542) + (99x + 99) \\
    &= (573x + 641) \\
    &\;\;\;\;\;\;\;\;\;\;\;\; \text{最後に多項式の各係数を} \mathrm{mod}\;101 \text{すると、} \\
    &= 68x + 35
\end{aligned}
$$

上式 $b(x) = a(x) \cdot{} s(x) + e(x)$ を「SageMath」では次のようにプログラムを書くことで計算することができます。

```python
# SageMath
n = 2
q = 101
Z.<X> = PolynomialRing(GF(q)) # 有限体上の多項式環
R.<x> = Z.quotient(X^n + 1)   # 既約多項式 x^2 + 1
a = R(13*x + 99)
s = R(4*x + 6)
e = R(99*x + 99)
a*s + e
# => 68*x + 35
```

SageMath は便利ですが、プロトコルの一部で利用するには不便です (SageMathを入れるだけで空き容量が1.5GBくらい必要になるため)。
そこで NumPy で計算することを考えます。
NumPy には多項式演算のためのメソッド（`numpy.polymul` など）が使えるので、これを利用していきます。

上式 $b(x) = a(x) \cdot{} s(x) + e(x)$ を「NumPy」では次のようにプログラムを書くことで計算することができます。

```python
# Python
import numpy as np
n = 2
q = 101
f = np.poly1d([1, 0, 1]) # 既約多項式 x^2 + 1
a = np.poly1d([13, 99])
s = np.poly1d([4, 6])
e = np.poly1d([99, 99])
quo, rem = np.polydiv(np.polymul(a, s), f) # 多項式環上の乗算
a_s = np.poly1d(rem.coeffs % q)            # 有限体上の係数
a_s_e = np.polyadd(a_s, e)                 # 多項式環上の加算
res = np.poly1d(a_s_e.coeffs % q)          # 有限体上の係数
print(res)
# => 68 x + 35
```

コードの量は増えましたが、NumPy でも有限体上の多項式環上の演算ができることが確認できます。
ここからは NumPy で Ring-LWE を実装することをしていきたいと思います。


### RLWE-KEX の実装

Ring-LWEを使った鍵共有（**RLWE-KEX**）を NumPy で実装すると以下のようになります。
有限体上の多項式環 `R_q` の初期設定をする `init_R_q` などを自前で実装しましたが、その他は RLWE-KEX などとやっていることは同じです。

```python
import math
import numpy as np

n = 1024  # 多項式の次数
q = 40961 # 法とする素数
sigma = 8 / math.sqrt(2 * math.pi) # 正規分布のパラメータ

def init_R_q(n, q):
    # 既約多項式 f(x) = x^n + 1
    f = np.zeros((n+1), dtype=int)
    f[-1] = 1
    f[0] = 1
    f = np.poly1d(f)

    # 多項式環 R_q = Z_q[x] / f(x)
    class R_q:
        def __init__(self, array):
            self.poly = np.poly1d(np.array(array, dtype=int))

        def __add__(self, other):
            res = np.polyadd(self.poly, other.poly)
            return R_q(res.coeffs % R_q.q)

        def __mul__(self, other):
            q, r = np.polydiv(np.polymul(self.poly, other.poly), R_q.f)
            return R_q(r.coeffs % R_q.q)

        def __rmul__(self, integer):
            return R_q((self.poly.coeffs * integer) % R_q.q)

        def __repr__(self):
            return "R_q: {}".format(self.poly.__repr__())

    R_q.f = f
    R_q.q = q
    return R_q

# 一様分布の乱数で多項式の各係数を決め、その多項式を返す関数
def uniform_distribution():
    return R_q(np.random.randint(0, q, n))

# 誤差分布（正規分布）で多項式の各係数を決め、その多項式を返す関数
def normal_distribution():
    return R_q(np.round(sigma * np.random.randn(n)) % q)

# シグナル関数
def Signal(k):
    signal = []
    for coefficient in reversed(k.poly.coeffs):
        if balanced(coefficient) in range(-math.floor(q/4), round(q/4) + 1):
            signal.append(0)
        else:
            signal.append(1)

    return signal

# 符号化関数
def Encode(k, w):
    key = []
    for coefficient, bit in zip(reversed(k.poly.coeffs), w):
        rec = int(balanced((coefficient + bit * (q - 1) / 2) % q) % 2)
        key.append(rec)
    return "".join(map(str, key))

# {0, ..., q-1} から {-q//2, ..., q//2} への写像
def balanced(x):
    if 0 <= x <= q // 2:
        return x
    else:
        return x - q


R_q = init_R_q(n, q)

def main():
    # Shared
    m = uniform_distribution()
    print('m:\n%s' % m)

    # Alice
    sA = normal_distribution()
    eA = normal_distribution()
    print('sA:\n%s' % sA)
    print('eA:\n%s' % eA)
    pA = m * sA + 2 * eA
    print('pA:\n%s' % pA)
    # Bob
    sB = normal_distribution()
    eB = normal_distribution()
    pB = m * sB + 2 * eB
    print('sB:\n%s' % sB)
    print('eB:\n%s' % eB)
    print('pB:\n%s' % pB)

    # Bob key
    eB_prime = normal_distribution()
    print('eB_prime:\n%s' % eB_prime)
    kB = pA * sB + 2 * eB_prime
    print('kB:\n%s' % kB)
    w = Signal(kB)
    # print('w: \n%s' % w)
    skB = Encode(kB, w)
    print('skB:\n%s' % skB)

    # Alice key
    eA_prime = normal_distribution()
    print('eA_prime:\n%s' % eA_prime)
    kA = pB * sA + 2 * eA_prime
    print('kA:\n%s' % kA)
    skA = Encode(kA, w)
    print('skA:\n%s' % skA)

    is_same = (skA == skB)
    print('skA == skB: %s' % is_same)
    if is_same:
        print('key is %s' % hex(int(skA, 2)))
    return is_same

main()
```

実行してみると、次のようになります

```
m:（事前に共有した多項式）
R_q: poly1d([39506, 15505, 36704, ...,  7906, 32166, 27113])
sA:（Aliceの秘密多項式）
R_q: poly1d([40956, 40960, 40960, ...,     3, 40959,     1])
eA:（Aliceの誤差多項式）
R_q: poly1d([    2,     6, 40959, ...,     3,     0,     4])
pA:（Aliceの公開鍵）
R_q: poly1d([35128, 20373, 23243, ..., 32201, 11794, 11738])
sB:（Bobの秘密多項式）
R_q: poly1d([40959, 40959,     0, ...,     5,     4,     1])
eB:（Bobの誤差多項式）
R_q: poly1d([    5,     3, 40960, ..., 40959,     0, 40958])
pB:（Bobの公開鍵）
R_q: poly1d([ 7137, 12009, 17860, ..., 36004, 26547, 37433])
eB_prime:
R_q: poly1d([    2,     1,     2, ..., 40957,     2, 40959])
kB:
R_q: poly1d([ 1923, 11153, 22577, ..., 29188, 14104, 30377])
skB:（Bobが得た共有鍵）
0111100011101110010111110011110110100110100010100001111100100010111011111011111001100110010100111010011101001101001010111101010100110101100100010101110110010111001100111011111100011111110110111000110000101011010110100100101000111110111010100000111111100010101100111000101010101110111100101001100010100100101000011010000111101010010010101110001001111000000001011111111001010101111011110000111010110010011000110011111100011100011100000000100101101000101110111101000010100000111010010010111010001000001001001000000011101101110010111111101001000111011010101001111001100011011101001110000111000010001010000110111001101110010010001001111100010101000011111000010100100011010011111000010111000111011000000101101100111001000001011010111110111011010100101010101111010011100111001011000011000111001100001101000111000110111010101100011001001001010101101000110001010111011100110110000110110111101100100010000101011011110111101011100001111001001101110000010010111100111000100111000001010010111101100000010100101010010001001011110010101001
eA_prime:
R_q: poly1d([40957,     0, 40954, ...,     1,     0, 40957])
kA:
R_q: poly1d([  587, 10279, 21059, ..., 29058, 15604, 30395])
skA:（Aliceが得た共有鍵）
0111100011101110010111110011110110100110100010100001111100100010111011111011111001100110010100111010011101001101001010111101010100110101100100010101110110010111001100111011111100011111110110111000110000101011010110100100101000111110111010100000111111100010101100111000101010101110111100101001100010100100101000011010000111101010010010101110001001111000000001011111111001010101111011110000111010110010011000110011111100011100011100000000100101101000101110111101000010100000111010010010111010001000001001001000000011101101110010111111101001000111011010101001111001100011011101001110000111000010001010000110111001101110010010001001111100010101000011111000010100100011010011111000010111000111011000000101101100111001000001011010111110111011010100101010101111010011100111001011000011000111001100001101000111000110111010101100011001001001010101101000110001010111011100110110000110110111101100100010000101011011110111101011100001111001001101110000010010111100111000100111000001010010111101100000010100101010010001001011110010101001
skA == skB: True
key is 0x78ee5f3da68a1f22efbe6653a74d2bd535915d9733bf1fdb8c2b5a4a3eea0fe2b38aaef298a4a1a1ea4ae27805fe55ef0eb2633f1c700968bbd0a0e92e882480edcbfa476a9e6374e1c2286e6e489f150f85234f85c7605b3905afbb52abd39cb0c730d1c6eac649568c577361b7b2215bdeb8793704bce27052f6052a44bca9
```

このようにして SageMath を使わなくても NumPy だけで RLWE-KEX を実装することができました。
