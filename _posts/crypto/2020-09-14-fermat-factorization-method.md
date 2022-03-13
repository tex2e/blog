---
layout:        post
title:         "フェルマーの素因数分解"
date:          2020-09-14
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
photoswipe:    false
# sitemap: false
# feed:    false
---

素因数分解をするとき、$N$の素因数が$\sqrt{N}$に近い場合は、次に紹介するフェルマーの素因数分解アルゴリズムが有効な手法となります。

与えられた数 $N$ は奇数であると仮定し、$N = a \times b$ の形で因数の積に分解できるとき、$x, y$ を次のようにおきます（$a, b$ は奇数なので、$x, y$ は整数になります）。

$$
\begin{aligned}
  x &= (a + b) / 2 \\
  y &= (a - b) / 2
\end{aligned}
$$

上の2つの式の和と差を計算することによって、次の結果が得られます。

$$
\begin{aligned}
  a &= x + y \\
  b &= x - y
\end{aligned}
$$

これを元の式 $N = a \times b$ に当てはめると、次のようになります。

$$
\begin{aligned}
  N = a \times b
    &= (x + y)(x - y) \\
    &= x^2 - y^2 \\
    &= \left(\frac{a + b}{2}\right)^2 - \left(\frac{a - b}{2}\right)^2
\end{aligned}
$$

この式を満たす$x,y$を見つけることができれば、因数$a,b$がわかるので、素因数分解ができます。

因数分解を使った素因数分解の例：

$$
\begin{aligned}
  N = 8051 = 8100 - 49 = 90^2 - 7^2 = (90+7)(90-7) = 97 \times 83 \\
\end{aligned}
$$

$$
\begin{aligned}
  x &= 90 &= (97 + 83) / 2 \\
  y &= 7  &= (97 - 83) / 2
\end{aligned}
$$

式 $N=x^2-y^2$ を満たす $x,y$ を見つけることができれば、$N=ab$ の素因数分解ができます。

式を $x^2 - N = y^2$ に書き換えて、$x^2 - N$ が完全平方 (他の整数の2乗になっている整数：1,4,9,16,...) になっているかを調べていくことで、式を満たす $x,y$ を探し、素因数分解をする方法を「フェルマーの素因数分解」と呼びます。

Pythonでのフェルマーの素因数分解の実装例：

```python
import gmpy2  # pip install gmpy2

def fermat_factors(n):
    assert n % 2 != 0
    x = gmpy2.isqrt(n)
    y2 = x**2 - n
    while not gmpy2.is_square(y2):
        x += 1
        y2 = x**2 - n
    factor1 = x + gmpy2.isqrt(y2)  # a = x + y
    factor2 = x - gmpy2.isqrt(y2)  # b = x - y
    return int(factor1), int(factor2)

p, q = fermat_factors(n)
```

素因数分解をするとき、$N$の素因数が$\sqrt{N}$に近い場合は、速く素因数を見つけることができますが、$\sqrt{N}$に近くない場合は、見つけるまでに時間がかかるので注意が必要です。



### 参考

- [Fermat's factorization method - Wikipedia](https://en.wikipedia.org/wiki/Fermat%27s_factorization_method#Fermat's_and_trial_division)
- [数値演算法 (11) 素因数分解 -1-](http://fussy.web.fc2.com/algo/math11_factorization1.htm)
