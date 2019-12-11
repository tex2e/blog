---
layout:        post
title:         "Pythonでモジュラ逆数を求める"
date:          2019-02-19
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

モジュラ逆数（Modular multiplicative inverse）を求めるPythonプログラムについて説明します。
剰余演算において逆数を求めるときにモジュラ逆数が出てきます。
モジュラ逆数を求めるアルゴリズムをPythonで書くと次の通りです。

```python
def xgcd(a, b):
    x0, y0, x1, y1 = 1, 0, 0, 1
    while b != 0:
        q, a, b = a // b, b, a % b
        x0, x1 = x1, x0 - q * x1
        y0, y1 = y1, y0 - q * y1
    return a, x0, y0

def modinv(a, m):
    g, x, y = xgcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m
```

拡張ユークリッドの互除法とは $a,b$ を正の整数とすると、
以下のベズーの等式を満たす適当な整数 $x,y$ が存在するので、この $x,y$ を求めるアルゴリズムです。

$$
ax + by = \gcd(a,b)
$$

モジュラ逆数は拡張ユークリッドの互除法を使って求めます。
もし $a$ には法 $m$ の乗法逆元が存在するなら、二つの整数 $a, m$ の最大公約数 $\gcd(a,m)$ は $1$ になります。すなわち、拡張ユークリッドの互除法で出てきたベズーの等式を使うと、次式が成り立ちます。

$$
\begin{align}
ax + my &= \gcd(a,m) = 1 \\
ax &= 1 + (-y)m \\
ax &\equiv 1 \pmod{m}
\end{align}
$$

つまり、拡張ユークリッドの互除法を計算することで $a$ の乗法逆元 $x$ を求めることができます。
