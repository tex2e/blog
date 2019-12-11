---
layout:        post
title:         "数論変換(NTT)による有限体上の多項式環の乗算"
date:          2019-05-31
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

RingLWE問題を使った鍵交換の方法としてNewHopeがあります。
そのNewHopeの論文を読んでいると多項式環の乗算のところで数論変換(NTT)を利用した高速化をしているので、数論変換による有限体上の多項式環の乗算について調べたことをまとめます。
$$\def\Z{ \mathbb{Z} }$$
$$\def\vec#1{ \textbf{#1} }$$

### 多項式環の乗算

多項式 $a(x), b(x)$ があるとき、多項式環 $R_q = \Z_q/f(x)$ の乗算は次のようになります（ただし$f(x)$は$n$次の既約多項式）。

$$
a(x) \cdot{} b(x) = \sum_{i=0}^{n-1} \sum_{j=0}^{n-1} a_i b_j x^{i+j} \;\mathrm{mod}\; f(x)
$$

この計算量は $O(n^2)$ です。


### 高速フーリエ変換を用いた多項式環の乗算

まず始めに、以下のように、多項式はベクトルに変換することができることを前提とします。

$$
\begin{align}
  a(x)    &= a_0 + a_1 x^1 + a_2 x^2 + \cdots + a_{n-1} x^{n-1} \\
          &\Updownarrow \\
  \vec{a} &= (a_0, a_1, ..., a_{n-1})
\end{align}
$$

多項式 $a(x), b(x)$ があるとき、次の手順で有限体上の多項式環の乗算を計算します。

1. $\omega^n \equiv 1 \;\mathrm{mod}\; p$ を満たす $\omega$ を求めます（$\omega$ は有限体 $\Z_p$ 上の原始$n$乗根です）
2. $\phi^2 \equiv \omega \;\mathrm{mod}\; p$ を満たす $\phi$ を求めます
3. $i = 0,1,...,n-1$ のときの $w^i$ と $\phi^i$ を計算して、それぞれを配列に保存します
5. $$\overline{a}_i \leftarrow a_i \phi^i \;\mathrm{mod}\; p$$ を計算して $$\vec{a} = (a_0,...,a_{n-1})$$ を求めます
5. $$\overline{b}_i \leftarrow b_i \phi^i \;\mathrm{mod}\; p$$ を計算して $$\vec{b} = (b_0,...,b_{n-1})$$ を求めます
6. $\overline{\vec{A}} \leftarrow \mathrm{FFT}(\overline{\vec{a}})$ を計算します
6. $\overline{\vec{B}} \leftarrow \mathrm{FFT}(\overline{\vec{b}})$ を計算します
7. $\overline{C}_i \leftarrow \overline{A}_i\overline{B}_i \;\mathrm{mod}\; p$ を計算して $\overline{\vec{C}}$ を求めます
8. $\overline{\vec{c}} \leftarrow \mathrm{IFFT}(\vec{C})$ を計算します
9. $$\overline{c}_i \leftarrow c_i \phi^i \;\mathrm{mod}\; p$$ を計算して $$\vec{c} = (c_0,...,c_{n-1})$$ を求めます
10. $\vec{c}$ を多項式に戻した $c(x)$ が多項式環の乗算の結果となります

FFTの計算量より、この計算量は $O(n \log(n))$ です。


### Pythonでの実装

FFTを用いた有限体上の多項式環の乗算をPythonで実装したものを以下に示します。

```python
import numpy as np

p = 337
n = 8

w = 85
domain = [1, 85, 148, 111, 336, 252, 189, 226]

phi = 146
phi_domain = [ pow(phi, i, p) for i in range(n) ]

phi_inv = 307
phi_inv_domain = [ pow(phi_inv, i, p) for i in range(n) ]

p1 = np.array([19,  112, 123,  72, 283, 335, 180, 334])
p2 = np.array([272, 191,  83, 127,  76, 135, 304, 325])

def fft(vals, modulus, domain):
    if len(vals) == 1:
        return vals
    L = fft(vals[::2], modulus, domain[::2])
    R = fft(vals[1::2], modulus, domain[::2])
    o = [0 for i in vals]
    for i, (x, y) in enumerate(zip(L, R)):
        y_times_root = y*domain[i]
        o[i] = (x+y_times_root) % modulus
        o[i+len(L)] = (x-y_times_root) % modulus
    return o

def modular_inverse(x, n):
    return pow(x, n - 2, n)

def inverse_fft(vals, modulus, domain):
    vals = fft(vals, modulus, domain)
    return [x * modular_inverse(len(vals), modulus) % modulus for x in [vals[0]] + vals[1:][::-1]]


p1 = (p1 * phi_domain) % p
p2 = (p2 * phi_domain) % p
p1_hat = fft(p1, p, domain)
p2_hat = fft(p2, p, domain)
tmp = (np.array(p1_hat) * np.array(p2_hat)) % p
p3 = inverse_fft(tmp, p, domain)
p3 = np.array(p3)
p3 = (p3 * phi_inv_domain) % p

print(p3)
# => [278 197  16   7 258 287 209 209]
```

最後に、検証のために、普通に多項式環の乗算を NumPy の polymul, polydiv で計算させるPythonプログラムを以下に示します。

```python
import numpy as np

p = 337

f = np.poly1d([1,0,0,0,0,0,0,0,1])
p1 = np.array([19,  112, 123,  72, 283, 335, 180, 334])
p2 = np.array([272, 191,  83, 127,  76, 135, 304, 325])
p1 = np.poly1d(np.flip(p1))
p2 = np.poly1d(np.flip(p2))

q, r = np.polydiv(np.polymul(p1, p2), f)

p3 = np.array(r.coeffs % p, dtype=int)
p3 = np.flip(p3)
print(p3)
# => [278 197  16   7 258 287 209 209]
```

どちらも同じ結果になるので、正しく実装できたと思います。


---

### 参照

- [Fast Fourier Transforms -- Vitalik Buterin's website](https://vitalik.ca/general/2019/05/12/fft.html) では、FFTによる整数同士の乗算についてPythonコードを交えながら説明されています。
- [High-speed Polynomial Multiplication Architecture for Ring-LWE and SHE Cryptosystems](https://eprint.iacr.org/2014/646.pdf) では、有限体上の多項式環の乗算を数論変換（具体的には高速フーリエ変換）を使って計算するアルゴリズムについて書かれています (Algorithm 2. Polynomial multipolication using FFT)。
