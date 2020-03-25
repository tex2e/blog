---
layout:        post
title:         "修正ElGamal暗号の加法準同型性"
date:          2020-02-23
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
# sitemap: false
# draft:   true
---

ElGamal暗号は乗法準同型暗号ですが、若干の修正を加えると、加法に関して準同型性を有する公開鍵暗号となります。
これを修正ElGamal暗号といいます。

まず、ElGamal暗号を数式で確認すると $m_1, m_2$ に対する暗号文は次のようになります。

$$
\begin{aligned}
  \text{Enc}(m_1) = (c_{11}, c_{12}) = (g^{r_1}, m_1 y^{r_1}) \\
  \text{Enc}(m_2) = (c_{21}, c_{22}) = (g^{r_2}, m_2 y^{r_2})
\end{aligned}
$$

この2つの暗号文をかけ合わせると、次のようになります。

$$
\begin{aligned}
  \text{Enc}(m_1) \times \text{Enc}(m_2)
  &= (c_{11} \times c_{21}, c_{12} \times c_{22}) \\
  &= (g^{r_1 + r_2}, m_1 m_2 y^{r_1 + r_2})
\end{aligned}
$$

この結果を復号すると、平文として $m_1 m_2$ が現れるので、乗法準同型性を有することが確認できます。

これを**加法準同型性**を有するように修正するには、$g^a \times g^b = g^{a+b}$ という指数の法則に注目して、暗号化アルゴリズムを次のように修正します。

$$
\begin{aligned}
  \text{Enc}(m_1) = (c_{11}, c_{12}) = (g^{r_1}, g^{m_1} y^{r_1}) \\
  \text{Enc}(m_2) = (c_{21}, c_{22}) = (g^{r_2}, g^{m_2} y^{r_2})
\end{aligned}
$$

この2つの暗号文をかけ合わせると、次のようになります。

$$
\begin{aligned}
  \text{Enc}(m_1) \times \text{Enc}(m_2)
  &= (c_{11} \times c_{21}, c_{12} \times c_{22}) \\
  &= (g^{r_1 + r_2}, g^{m_1 + m_2} y^{r_1 + r_2})
\end{aligned}
$$

この結果を復号すると、平文として $g^{m_1 + m_2}$ が現れるので、加法準同型性を有することが確認できます。

しかし、修正ElGamal暗号の欠点は、平文 $m$ を得るために $g^m \mod p$ を解く（離散対数問題を解く）必要があります。
メッセージ空間が小さければなんとか計算できますが、空間が大きくなるほどこれは困難になります。
今回は離散対数問題を解くアルゴリズムとして、Baby-step Giant-step法を使います。

修正ElGamal暗号をPythonで実装したものは以下の通りです。

```python
# pip install pycryptodome
from Crypto.Util import number

# 鍵生成アルゴリズム
def elgamal_gen_key(bits):
    # 素数p
    while True:
        q = number.getPrime(bits-1)
        p = 2*q + 1
        if number.isPrime(p):
            break
    # 原始元g
    while True:
        g = number.getRandomRange(3, p)
        # 原始元判定
        if pow(g, 2, p) == 1:
            continue
        if pow(g, q, p) == 1:
            continue
        break
    # 秘密値x
    x = number.getRandomRange(2, p-1)
    # 公開値y
    y = pow(g, x, p)
    return (p, g, y), x

# 暗号化アルゴリズム
def elgamal_encrypt(m, pk):
    p, g, y = pk
    assert(0 <= m < p)
    r = number.getRandomRange(2, p-1)
    c1 = pow(g, r, p)
    c2 = (pow(g, m, p) * pow(y, r, p)) % p
    return (c1, c2)

# 復号アルゴリズム
def elgamal_decrypt(c, pk, sk):
    p, g, y = pk
    c1, c2 = c
    r = (c2 * pow(c1, p - 1 - sk, p)) % p
    return baby_step_giant_step(g, r, p)

# Baby-step Giant-step法
# X^K ≡ Y (mod M) となるような K を求める
def baby_step_giant_step(X, Y, M):
    D = {1: 0} # {g^i: i}
    m = int(M**0.5) + 1

    # Baby-step
    Z = 1
    for i in range(m):
        Z = (Z * X) % M
        D[Z] = i+1
    if Y in D:
        return D[Y]

    # Giant-step
    R = pow(Z, M-2, M) # R = X^{-m}
    for i in range(1, m+1):
        Y = (Y * R) % M
        if Y in D:
            return D[Y] + i*m
    return -1

pk, sk = elgamal_gen_key(bits=20)
p, _, _ = pk
print('pk:', pk)
print('sk:', sk)
print()

m1 = 3
c1 = elgamal_encrypt(m1, pk)
m2 = 7
c2 = elgamal_encrypt(m2, pk)
print('m1:', m1)
print('m2:', m2)
print('c1:', c1)
print('c2:', c2)

c = [ (a * b) % p for a, b in zip(c1, c2) ]
print('c1*c2:', tuple(c))

d = elgamal_decrypt(c, pk, sk)
print('d:', d)
```

プログラムでは加法準同型性の確認をしています。
実行してみると以下のようになります（公開鍵、秘密鍵、暗号文は毎回ランダムです）。
2つの平文 $3$ と $7$ の暗号文を掛け合わせ、復号すると、その加算の結果である $3 + 7 = 10$ となります。

```
pk: (622367, 457409, 127246)
sk: 116929

m1: 3
m2: 7
c1: (120418, 537471)
c2: (152933, 398352)
c1*c2: (46464, 309021)
d: 10
```

修正ElGamal暗号にすることで、離散対数問題を解かないといけない欠点がありますが、加法準同型性を有するようになりました。


- 前回：[ElGamal暗号と乗法準同型性](/blog/crypto/elgamal-encryption)
- 次回：[Paillier暗号と準同型性](/blog/crypto/paillier-cryptosystem)

### 参考文献

- [準同型暗号 - Wikipedia](https://ja.wikipedia.org/wiki/%E6%BA%96%E5%90%8C%E5%9E%8B%E6%9A%97%E5%8F%B7)
- [Homomorphic encryption - Wikipedia](https://en.wikipedia.org/wiki/Homomorphic_encryption)
- [離散対数問題 (Baby-step giant-step) - yaketake08's 実装メモ](https://tjkendev.github.io/procon-library/python/math/baby-step-giant-step.html)
- [Baby-step giant-step - Wikipedia](https://en.wikipedia.org/wiki/Baby-step_giant-step)
- [離散対数 - Wikipedia](https://ja.wikipedia.org/wiki/%E9%9B%A2%E6%95%A3%E5%AF%BE%E6%95%B0)
