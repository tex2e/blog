---
layout:        post
title:         "SageMathでRing-LWEによる鍵共有"
menutitle:     "SageMathを使ったRing-LWEによる鍵共有"
date:          2019-05-05
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
---

Ring-LWE格子暗号による鍵共有について説明します。前回のLWEによる鍵共有の続きです。
$$
\gdef\Z{\mathbb{Z}}
\gdef\vec#1{\textbf{#1}}
$$

前回：[LWE格子暗号による鍵共有]({{ site.baseurl }}/crypto/lwe-key-exchange)

おさらいですが、LWE（Learning with Errors）問題とは、誤差を付加した多元連立一次方程式を解く問題です。
簡単に説明すると、$\Z_q$ 上の誤差 $\vec{e}$ を付加した連立方程式について、行列 $\vec{A}, \vec{b}$ が与えられたときに、秘密 $\vec{s}$ を求める問題です。
そしてこの問題は困難であると予想されています。

$$
\vec{A} \vec{s} + \vec{e} \equiv \vec{b} \pmod{q}
$$

しかし、LWEは送信する鍵のサイズ $n$ が大きくなるほど、事前に共有する行列 $\vec{A}$ のサイズが $O(n^2)$ で大きくなるので、送信量を減らす方法を考える必要があります [^LWE-matrix-byte-size]。そこでRing-LWEが登場します。


### Ring-LWE問題

**Ring-LWE**（RLWE）問題とは、LWE問題を有限体上の多項式環に限定した問題です。
簡単に説明すると、以下の方程式で多項式 $a(x), b(x)$ が与えられたとき、秘密の多項式 $s(x)$ を求める問題です。

$$
b(x) = a(x) \cdot{} s(x) + e(x)
$$

ただし、多項式の演算は有限体上の多項式環 $R_q = \mathbb{F}_q[x] / (x^n + 1)$ 上で行います [^R_q]。

多項式 $f(x) = a_n x^n + ... + a_0$ から係数だけを並べると $(a_0, ..., a_n)$ となり、格子上のベクトルを表していることから、Ring-LWEも格子暗号に分類されます。


### RLWE-KEX の実装

次にRing-LWE格子暗号を使った鍵共有（**RLWE-KEX**）について説明します。
AliceとBobの2人が鍵共有をします。ただし、$E$ を符号化関数、$S$ をシグナル関数とします [^Ding2012]。

$$
\begin{aligned}
  S(v) &=
  \begin{cases}
    0 & \text{if}\; -\! \lfloor \frac{q}{4} \rfloor \le v \le \lfloor \frac{q}{4} \rceil \\
    1 & \text{otherwise}
  \end{cases} \\[10pt]
  E(v, w) &= \left(v + w \cdot{}\frac{q-1}{2} \right) \;\mathrm{mod}\; q \;\mathrm{mod}\; 2
\end{aligned}
$$

1. パラメータ $q, n, \chi, R = \Z[x] / f(x), m$ を事前に共有します。
  - 素数 $q$ ... 各係数の法として使います
  - 多項式の項数 $n$
  - 誤差分布 $\chi$
  - 多項式環 $R = \Z[x] / f(x)$ : ただし、$f(x) = x^n + 1$ とし、$n$ は$2$のべき乗とします。
  - 多項式 $m$ : 各係数は $\Z_q$ 上の一様分布の乱数で決めます
2. Aliceは誤差分布から秘密多項式 $s_A$ と誤差多項式 $e_A$ を作ります。そして、公開鍵 $p_A = m \cdot{} s_A + 2e_A$ を計算し、Bob に送信します（実際には多項式に代わりに、多項式の各係数のリストを送信します）。
3. Bobは誤差分布から秘密多項式 $s_B$ と誤差多項式 $e_B, e'_B$ を作ります。そして、公開鍵 $p_B = m \cdot{} s_B + 2 e_B$ を計算します。さらに、鍵の元となる値 $K_B = p_A \cdot{} s_B + 2 e'_B \mod{q}$ を計算し、$\sigma \leftarrow S(K_B)$ を求めます。ここでBobは共有鍵 $SK_B = E(K_B, \sigma)$ を得ます。最後に公開鍵 $(p_B, \sigma)$ を送信します。
4. Aliceは誤差分布から誤差多項式 $e'_A$ を作ります。そして $K_B = s_A \cdot{} p_B + 2 e'_A \mod{q}$ を計算し、共有鍵 $SK_A = E(K_A, \sigma)$ を得ます。

上の手順をSageMathで書くと以下のようになります（多項式環の演算を実装するのが大変なのでSageMathを使いました）。
なお、事前に共有するパラメータは $n=1024, q=40961$ としました [^RLWE-parameter-choices]。


```python
#!/usr/local/bin/sage
# -*- coding: utf-8 -*-

from sage.stats.distributions.discrete_gaussian_polynomial \
    import DiscreteGaussianDistributionPolynomialSampler

n = 1024  # 多項式の次数
q = 40961 # 法とする素数
sigma = 8 / sqrt(2*pi) # 正規分布のパラメータ

# 一変数多項式環 Rq = Fq[x]/(x^n + 1)
F.<X> = PolynomialRing(GF(q))
R.<x> = F.quotient(X^n + 1)

# 一様分布の乱数で多項式の各係数を決め、その多項式を返す関数
def uniform_distribution():
    return R.random_element()

# 誤差分布（正規分布）で多項式の各係数を決め、その多項式を返す関数
def normal_distribution():
    return DiscreteGaussianDistributionPolynomialSampler(R, n, sigma)()

# シグナル関数
def Signal(poly):
    coefficients = poly.list()
    signal = []

    for coefficient in coefficients:
        if coefficient in range(-floor(q/4), round(q/4) + 1):
            signal.append(0)
        else:
            signal.append(1)

    return signal

# 符号化関数
def Encode(poly, w):
    coefficients = poly.list()
    key = []
    F2 = GF(2)

    for coefficient, bit in zip(coefficients, w):
        coefficient = RR(coefficient)
        rec = F2(((coefficient + bit * (q - 1) / 2) % q) % 2)
        key.append(rec)

    return "".join(map(str, key))


def main():
    # Shared
    m = uniform_distribution()
    print('m:\n%s' % m)

    # Alice
    sA = normal_distribution()
    eA = normal_distribution()
    pA = m * sA + 2 * eA
    print('sA:\n%s' % sA)
    print('eA:\n%s' % eA)
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
    kB = pA * sB + 2 * eB_prime
    w = Signal(kB)
    skB = Encode(kB, w)
    print('kB:\n%s' % kB)
    print('skB:\n%s' % skB)

    # Alice key
    eA_prime = normal_distribution()
    kA = pB * sA + 2 * eA_prime
    skA = Encode(kA, w)
    print('kA:\n%s' % kA)
    print('skA:\n%s' % skA)

    is_same = (skA == skB)
    print('skA == skB: %s' % is_same)
    if is_same:
        print('key is %s' % hex(int(skA, 2)))
    return is_same

main()
```

実行してみると、次のようになります（多項式の一部は省略しています）。

```
m:（事前に共有した多項式）
19313*x^1023 + 30943*x^1022 + ... + 35342*x + 15237
sA:（Aliceの秘密多項式）
40960*x^1023 + 40960*x^1022 + ... + 40960*x^2 + 4
eA:（Aliceの誤差多項式）
40959*x^1022 + 40960*x^1021 + ... + x + 2
pA:（Aliceの公開鍵）
8734*x^1023 + 19425*x^1022 + ... + 16396*x + 22209
sB:（Bobの秘密多項式）
x^1023 + 40958*x^1022 + ... + 40959*x + 40958
eB:（Bobの誤差多項式）
3*x^1023 + 40958*x^1022 + ... + 40960*x^3 + 4*x^2
pB:（Bobの公開鍵）
2961*x^1023 + 28563*x^1022 + ... + 7774*x + 9301
kB:
8619*x^1023 + 30440*x^1022 + ... + 16864*x + 28322
skB:（Bobが得た共有鍵）
1111000001100001100010101011100000010001011101011010010110001100011011001010010000110001011000110101111101101001010010000111010010110011100011010100001010100110101011100000011111001111011100000011011111001000100110111100011110011000101000001110000110101101110000001111111100111011111101011010110101000011000010101001110101110111010000111000100011100101011111011001010101000101110000011110011011011101111111001000100001001000111010110111000010100001111000100100111111101100011100111101010100101101101100001110010110110010001011101111100100001100010010100010011110110101011010011101110010000001000000100010101100000110100101011100101000111100111001100101111010101100010010110011101100000101010000011101100110010010010001011010001111110001111010010101001011101110111011100001101101010101000111101000011101001101111101110011010010110101011101011101111110001000010000001000100010011100100010010101010001111101011010011100101101000101111011000010110000001000000110101000001010100110101000101110110010100001111100011000011111110011
kA:
8187*x^1023 + 30222*x^1022 + ... + 15866*x + 28300
skA:（Aliceが得た共有鍵）
1111000001100001100010101011100000010001011101011010010110001100011011001010010000110001011000110101111101101001010010000111010010110011100011010100001010100110101011100000011111001111011100000011011111001000100110111100011110011000101000001110000110101101110000001111111100111011111101011010110101000011000010101001110101110111010000111000100011100101011111011001010101000101110000011110011011011101111111001000100001001000111010110111000010100001111000100100111111101100011100111101010100101101101100001110010110110010001011101111100100001100010010100010011110110101011010011101110010000001000000100010101100000110100101011100101000111100111001100101111010101100010010110011101100000101010000011101100110010010010001011010001111110001111010010101001011101110111011100001101101010101000111101000011101001101111101110011010010110101011101011101111110001000010000001000100010011100100010010101010001111101011010011100101101000101111011000010110000001000000110101000001010100110101000101110110010100001111100011000011111110011
skA == skB: True
key is 0xf0618ab81175a58c6ca431635f694874b38d42a6ae07cf7037c89bc798a0e1adc0ff3bf5ad430a9d774388e57d9545c1e6ddfc8848eb70a1e24fec73d52db0e5b22ef90c4a27b569dc81022b0695ca3ce65eac4b3b0541d99245a3f1e952eeee1b551e874df734b575df8840889c89547d69cb45ec2c081a82a6a2eca1f187f3L
```

このようにして、共有鍵を共有することができます。
実装は J. Ding "[A Simple Provably Secure Key Exchange Scheme Based on the Learning with Errors Problem](https://eprint.iacr.org/2012/688.pdf)" や [amir734jj/LWE-KEX: LWE-KEX implementations all using SageMath -- GitHub](https://github.com/amir734jj/LWE-KEX) を読みながらPython (SageMath) で実装していきました。正確性や安全性の証明などはこちらを参照してください。

次回：[NumPyでRing-LWEによる鍵共有]({{ site.baseurl }}/crypto/ring-lwe-key-exchange-with-numpy)

---

[^LWE-matrix-byte-size]: LWEにおいて行列 $\vec{A}$ が $1024 \times 1024$ で各要素が 32-bit の整数だとすると、$4\mathrm{bytes} \times 1024^2 = 4194304 \approx 4\mathrm{MB}$ となり、鍵共有だけでこれほどのデータを送るのは、送信量と通信速度の点から理想と相反する
[^R_q]: 有限体上の多項式環 $R_q = \mathbb{F}_q[x] / (x^n + 1)$ には様々な書き方がある。イデアルの部分は既約多項式(irreducible polynomial) $\Phi(x)$ であることを示すために $R_q = \mathbb{F}_q[x] / \Phi(x)$ と書いたり、有限体であることを強調しないために $\mathbb{F}_q$ の代わりに $\Z_q$ を使って $R_q = \mathbb{Z}_q[x] / (x^n + 1)$ と書く人も多い
[^Ding2012]: J. Ding, Xiang Xie, Xiaodong Lin. "[A Simple Provably Secure Key Exchange Scheme Based on the Learning with Errors Problem](https://eprint.iacr.org/2012/688.pdf)," pp. 11-12
[^cryptrec-report2015]: [格子問題等の困難性に関する調査 - 暗号技術調査 (暗号解析評価) ワーキンググループ](https://www.cryptrec.go.jp/exreport/cryptrec-ex-2404-2014.pdf)
[^RLWE-parameter-choices]: [Parameter choices -- Ring learning with errors key exchange (Wikipedia)](https://en.wikipedia.org/wiki/Ring_learning_with_errors_key_exchange#Parameter_choices)
