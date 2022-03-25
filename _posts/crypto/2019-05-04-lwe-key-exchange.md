---
layout:        post
title:         "LWE格子暗号による鍵共有"
date:          2019-05-04
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
---

量子コンピュータの進歩に伴い、**耐量子暗号**（Post-Quantum Cryptography; PQC）[^PQC] と呼ばれる量子コンピュータでも解読が難しいとされる暗号が注目されています。
現在使われている暗号には、RSAのように素因数分解問題の困難性を利用した暗号や、ECDHのように離散対数問題の困難性を利用した暗号があります。
しかし、**Shorのアルゴリズム**という、離散フーリエ変換を利用して素因数分解問題や離散対数問題を解くアルゴリズムがあるのですが、量子コンピュータを使うことで離散フーリエ変換を高速に解くことができ、結果として素因数分解や離散対数問題を高速に解けるようになります [^QFT] [^QFT-wiki]。

量子コンピュータはすでにあるのですが、扱える量子ビット数がまだ少ないので現在使われている暗号は解読できません。しかし将来、扱える量子ビット数が増えた時に備えておく必要はあるでしょう。
なお、2019年2月にGoogleが発表した最新の量子プロセッサ「Bristlecone」の量子ビット数は72です。
実際のRSA暗号では2048ビットのモジュロが使われています。
これに加えて、量子ビットはエラーが発生しやすいため、正しい計算結果を得るには数百万量子ビットが必要とされています。なので、量子コンピュータで解読できるようになるまでにはまだ時間がかかりそうというのが現在の状況です。
$$
\gdef\Z{\mathbb{Z}}
\gdef\vec#1{\textbf{#1}}
$$

## 格子とLWE問題

LWE（Learning with Errors）問題とは、誤差を付加した多元連立一次方程式を解く問題です。
簡単に説明すると、$\Z_q$ 上の誤差 $\vec{e}$ を付加した連立方程式について、行列 $\vec{A}, \vec{b}$ が与えられたときに、秘密 $\vec{s}$ を求める問題です。

$$
\vec{A} \vec{s} + \vec{e} \equiv \vec{b} \pmod{q}
$$

具体的な例は、次のようになります [^cryptrec-report2015]。

$$
\begin{cases}
  \begin{array}{rll}
    14s_1 + 15s_2 +  5s_3 +  2s_4 &\approx  8 &\pmod{17} \\
    13s_1 + 14s_2 + 14s_3 +  6s_4 &\approx 16 &\pmod{17} \\
     6s_1 + 10s_2 + 13s_3 +   s_4 &\approx 12 &\pmod{17} \\
    10s_1 +  4s_2 + 12s_3 + 16s_4 &\approx 12 &\pmod{17} \\
     9s_1 +  5s_2 +  9s_3 +  6s_4 &\approx  9 &\pmod{17} \\
     3s_1 +  6s_2 +  4s_3 +  5s_4 &\approx 16 &\pmod{17} \\
                                  &\;\vdots \\
     6s_1 +  7s_2 + 16s_3 +  2s_4 &\approx  3 &\pmod{17} \\
  \end{array}
\end{cases}
$$

各方程式には誤差（例えば $\pm 1$ 程度）が加えられており、誤差の範囲内で正しい式となります。
このとき、上の方程式の列の解 $\vec{s} = (s_1, s_2, s_3, s_4)$ を求めるのがLWE問題です。
なお、上の方程式の例では $\vec{s} = (0, 13, 9, 11)$ が答えになります。
もし誤差が無ければ、ガウスの消去法（Gaussian elimination）を使うことで $\vec{s}$ は簡単に求まります。つまり、与える誤差の度合いによってLWE問題の難易度が決まります。

LWE暗号というと、このLWE問題の計算量困難性に依存した暗号技術のことを指します。
以下の3つの理由からLWE問題は解くことが難しいと信じられています。
その3つ目の一番重要な理由が格子問題を使っているので、LWEは格子暗号に分類されます。

1. 知られている中でもっとも良いLWE問題を解くアルゴリズムの実行時間が指数時間である（量子コンピュータでさえも計算速度を速くできない）
2. LWE問題はLPN問題の一般化であり、LPN問題は解くのが困難な問題と予想されている。さらに、LPN問題はランダム線型バイナリ符号から復号する問題であり、もしLPN問題が簡単に解けるならば、符号理論において画期的で重大な発見になる。
3. 最も重要なこととして、GapSVP（決定版の最短ベクトル問題）やSIVP（最短独立ベクトル問題）などのような標準的な格子問題の最悪ケースでの仮定に基づいてLWE問題は困難だと知られている [^Reg05] [^Pei09]。

## LWE格子暗号による1bitの鍵共有

この記事の類似記事に [LWE格子暗号による暗号化をやってみる - ももいろテクノロジー](http://inaz2.hatenablog.com/entry/2017/05/27/003343) があり、そこでは1ビットの「暗号化」について書かれています。一方でこの記事では1ビットの「鍵共有」について説明したあとに、複数ビットへの拡張について説明していきます。

AliceとBobの2人が鍵共有をします。ただし、$E$ を符号化関数、$S$ をシグナル関数とします [^Ding12]。

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

1. パラメータ $q, n, \vec{M} \in \Z_q^{n \times n}, \chi_\alpha$ を事前に共有します。ただし $q$ は3以上の素数で、$n \times n$ の行列 $\vec{M}$ の各要素は一様分布で選んだ乱数にします。$\chi_\alpha$ は誤差分布で、誤差を付加するときに使います。
2. Aliceは誤差分布を使って秘密ベクトル $\vec{s}_A \in \Z_q^{n \times 1}$ と誤差ベクトル $\vec{e}_A \in \Z_q^{n \times 1}$ を作ります。そして、公開鍵 $\Z_q^{n \times 1} \ni \vec{p}_A = \vec{M} \cdot{} \vec{s}_A + 2\vec{e}_A$ を計算し、Bob に送信します。
3. Bobは誤差分布を使って秘密ベクトル $\vec{s}_B \in \Z_q^{n \times 1}$ と誤差ベクトル $\vec{e}_B \in \Z_q^{n \times 1}$ と誤差 $e'_B \in \Z_q$ を作ります。そして、公開鍵 $\Z_q^{n \times 1} \ni \vec{p}_B = \vec{M}^T \cdot{} \vec{s}_B + 2 \vec{e}_B$ を計算します。さらに、鍵の元となる値 $\Z_q \ni K_B = \vec{p}_A^T \cdot{} \vec{s}_B + 2 e'_B \mod{q}$ を計算し、$$\sigma \leftarrow S(K_B) \in \{0,1\}$$ を求めます。ここで Bob は共有鍵 $$SK_B = E(K_B, \sigma) \in \{0,1\}$$ を得ます。最後に公開鍵 $\vec{p}_B$ と $\sigma$ を Alice に送信します。
4. Aliceは誤差分布を使って誤差 $e'_A \in \Z_q$ を作ります。そして $\Z_q \ni K_A = \vec{s}_A^T \cdot{} \vec{p}_B + 2 e'_A \mod{q}$ を計算し、共有鍵 $$SK_A = E(K_A, \sigma) \in \{0,1\}$$ を得ます。

行列の形を意識しながら、計算していく必要があります。
上の手順をPythonで書くと以下のようになります。

```python
import math
import numpy as np

# 一様分布の乱数
def uniform_distribution(q, n):
    return np.random.randint(0, q, size=n)

# 誤差分布（正規分布）
def normal_distribution(n):
    a = np.random.normal(0, sigma, size=n)
    return np.round(a).astype(int)

# シグナル関数
def Signal(x):
    if balanced(x) in range(-math.floor(q/4), round(q/4)+1):
        return 0
    else:
        return 1

Signal = np.frompyfunc(Signal, 1, 1)

# 符号化関数
def Encode(x, s):
    return balanced((x + s * (q-1)//2) % q) % 2

# {0, ..., q-1} から {-q//2, ..., q//2} への写像
def balanced(x):
    if 0 <= x <= q // 2:
        return x
    else:
        return x - q


n = 1024  # 格子の次元
q = 40961 # 法とする素数
sigma = 8 / math.sqrt(2 * math.pi) # 正規分布のパラメータ

def main():
    # shared
    M = uniform_distribution(q, (n,n))                   # (n,n)-ary
    print('M:'); print(M)

    # Alice
    sA = np.matrix(normal_distribution(n)).transpose()   # (n,1)-ary
    eA = np.matrix(normal_distribution(n)).transpose()   # (n,1)-ary
    pA = np.matrix((M.dot(sA) + 2 * eA) % q)             # (n,1)-ary
    print('sA:'); print(sA)
    print('eA:'); print(eA)
    print('pA:'); print(pA)

    # Bob
    sB = np.matrix(normal_distribution(n)).transpose()   # (n,1)-ary
    eB = np.matrix(normal_distribution(n)).transpose()   # (n,1)-ary
    pB = np.matrix((M.transpose().dot(sB) + 2 * eB) % q) # (n,1)-ary
    print('sB:'); print(sB)
    print('eB:'); print(eB)
    print('pB:'); print(pB)

    # Bob key
    eB_prime = normal_distribution(1)                    # 1bit
    kB = ((pA.transpose()).dot(sB) + 2 * eB_prime) % q   # 1bit
    print('kB:', kB)
    s = Signal(kB).astype(int)                           # 1bit
    skB = Encode(kB, s)                                  # 1bit
    print('skB:', skB)

    # Alice key
    eA_prime = normal_distribution(1)                    # 1bit
    kA = ((sA.transpose()).dot(pB) + 2 * eA_prime) % q   # 1bit
    print('kA:', kA)
    skA = Encode(kA, s)                                  # 1bit
    print('skA:', skA)

    is_same = (skA.tolist() == skB.tolist())
    print('skA == skB:', is_same)
    return is_same

main()
```

実行してみると、次のようになります。

```
M:（事前に共有した行列）
[[18298   256 26974 ... 17162 30733 35874]
 [34867  1091  2692 ... 12267 38385 39662]
 [10642 23491 18618 ... 22108 25749  5266]
 ...
 [30250 30023 35292 ... 18981  9196 36362]
 [16253 27689 12790 ...  4981  5826 10187]
 [14648 10957 40477 ... 15955 21723    43]]
sA:（Aliceの秘密鍵）
[[-2]
 [-2]
 [-2]
 ...
 [ 2]
 [-2]
 [-5]]
eA:（Aliceの誤差ベクトル）
[[ 0]
 [ 2]
 [ 1]
 ...
 [ 0]
 [-1]
 [ 1]]
pA:（Aliceの公開鍵）
[[16980]
 [14127]
 [11237]
 ...
 [ 6470]
 [16624]
 [25453]]
sB: (Bobの秘密鍵)
[[ 2]
 [-1]
 [ 0]
 ...
 [ 4]
 [-2]
 [ 0]]
eB:（Bobの誤差ベクトル）
[[-1]
 [-3]
 [-3]
 ...
 [ 0]
 [-4]
 [-3]]
pB:（Bobの公開鍵）
[[25541]
 [39356]
 [39009]
 ...
 [ 2327]
 [27100]
 [ 2725]]
kB: [[12818]]
skB: [[1]]（Bobが得た共有鍵）
kA: [[11860]]
skA: [[1]]（Aliceが得た共有鍵）
skA == skB: True
```

何回か繰り返して実行してみると、共有鍵（0 or 1）を共有していることが確認できます。

共有鍵が一致することを式で確認すると、以下のようになります。

$$
\begin{aligned}
K_A &= \vec{s}_A^T \cdot{} \vec{p}_B + 2e_A' \\
    &= \vec{s}_A^T \cdot{} \left( \vec{M}^T \cdot{} \vec{s}_B + 2\vec{e}_B \right) + 2e_A' \\
    &= \vec{s}_A^T \vec{M}^T \vec{s}_B + 2\,\vec{s}_A^T \vec{e}_B + 2e_A' \\
    &= \vec{s}_A^T \vec{M}^T \vec{s}_B \\
    &= \left( \vec{M} \,\vec{s}_A \right)^T \vec{s}_B \\[6pt]
K_B &= \vec{p}_A^T \cdot{} \vec{s}_B + 2e_B' \\
    &= \vec{s}_B^T \cdot{} \vec{p}_A + 2e_B' \\
    &= \vec{s}_B^T \cdot{} \left( \vec{M} \cdot{} \vec{s}_A + 2\vec{e}_A \right) + 2e_B' \\
    &= \vec{s}_B^T \vec{M} \,\vec{s}_A + 2\,\vec{s}_B^T \vec{e}_A + 2e_B' \\
    &= \vec{s}_B^T \vec{M} \,\vec{s}_A \\
    &= \left(\vec{M} \,\vec{s}_A\right)^T \vec{s}_B
\end{aligned}
$$

ただし、途中で誤差 $\vec{e}$ と $e'$ を無視したり、積の転置行列 $(AB)^T = B^TA^T$ の操作をしています。
誤差を無視できるのはシグナル関数 $S$ によって誤差が丸め込まれているからということらしいですが、詳細はよくわからないので、元の論文読んでください。

## LWE格子暗号による複数bitの鍵共有

1ビットの共有鍵を作っても 1/2 の確率で解読できるので、実用的ではありません。
そこで複数ビットの共有鍵を作ります。
ビットの数を増やすのは簡単で、上記の手順で使っていた秘密ベクトル $\vec{s}_A, \vec{s}_B \in \Z_q^n$ の代わりに、秘密行列 $\vec{S}_A, \vec{S}_B \in \Z_q^{n \times n}$ を作り、誤差ベクトル $\vec{e}_A, \vec{e}_B \in \Z_q^n$ の代わりに、誤差行列 $\vec{E}_A, \vec{E}_B \in \Z_q^{n \times n}$ を作ります。

1. パラメータ $q, n, \vec{M} \in \Z_q^{n \times n}, \chi_\alpha$ を事前に共有します。ただし $q$ は3以上の素数で、$n \times n$ の行列 $\vec{M}$ の各要素は一様分布で選んだ乱数にします。$\chi_\alpha$ は誤差分布で、誤差を付加するときに使います。
2. Aliceは誤差分布を使って秘密行列 $\vec{S}_A \in \Z_q^{n \times n}$ と誤差行列 $\vec{E}_A \in \Z_q^{n \times n}$ を作ります。そして、公開鍵 $\Z_q^{n \times n} \ni \vec{P}_A = \vec{M} \cdot{} \vec{S}_A + 2\vec{E}_A$ を計算し、Bob に送信します。
3. Bobは誤差分布を使って秘密行列 $\vec{S}_B \in \Z_q^{n \times n}$ と誤差行列 $\vec{E}_B \in \Z_q^{n \times n}$ と誤差 $\vec{E}'_B \in \Z_q^{n \times n}$ を作ります。そして、公開鍵 $\Z_q^{n \times n} \ni \vec{P}_B = \vec{M}^T \cdot{} \vec{S}_B + 2 \vec{E}_B$ を計算します。さらに、鍵の元となる値 $\Z_q^{n \times n} \ni \vec{K}_B = \vec{P}_A^T \cdot{} \vec{S}_B + 2 \vec{E}'_B \mod{q}$ を計算し、$$\mathbf{\sigma} \leftarrow S(\vec{K}_B) \in \{0,1\}^{n \times n}$$ を求めます。ここで Bob は共有鍵 $$\vec{SK}_B = E(\vec{K}_B, \mathbf{\sigma}) \in \{0,1\}^{n \times n}$$ を得ます。最後に公開鍵 $\vec{P}_B$ と $\mathbf{\sigma}$ を Alice 送信します。
4. Aliceは誤差分布を使って誤差 $\vec{E}'_A \in \Z_q^{n \times n}$ を作ります。そして $\Z_q^{n \times n} \ni \vec{K}_A = \vec{S}_A^T \cdot{} \vec{P}_B + 2 \vec{E}'_A \mod{q}$ を計算し、共有鍵 $$\vec{SK}_A = E(\vec{K}_A, \mathbf{\sigma}) \in \{0,1\}^{n \times n}$$ を得ます。

```python
import math
import numpy as np

# 一様分布の乱数
def uniform_distribution(q, n):
    return np.random.randint(0, q, size=n)

# 誤差分布（正規分布）
def normal_distribution(n):
    a = np.random.normal(0, sigma, size=n)
    return np.round(a).astype(int)

# シグナル関数
def Signal(x):
    if balanced(x) in range(-math.floor(q/4), round(q/4)+1):
        return 0
    else:
        return 1

Signal = np.frompyfunc(Signal, 1, 1)

# 符号化関数
def Encode(x, s):
    return balanced((x + s * (q-1)//2) % q) % 2

# {0, ..., q-1} から {-q//2, ..., q//2} への写像
def balanced(x):
    if 0 <= x <= q // 2:
        return x
    else:
        return x - q

balanced = np.frompyfunc(balanced, 1, 1)


n = 1024  # 格子の次元
q = 40961 # 法とする素数
m = 32    # 共有鍵のビット数 = m^2 bit
sigma = 8 / math.sqrt(2 * math.pi) # 正規分布のパラメータ

def main():
    # shared
    M = uniform_distribution(q, (n,n))                   # (n,n)-ary
    print('M:'); print(M)

    # Alice
    sA = np.matrix(normal_distribution((n,m)))           # (n,m)-ary
    eA = np.matrix(normal_distribution((n,m)))           # (n,m)-ary
    pA = np.matrix((M.dot(sA) + 2 * eA) % q)             # (n,m)-ary
    print('sA:'); print(sA)
    print('eA:'); print(eA)
    print('pA:'); print(pA)

    # Bob
    sB = np.matrix(normal_distribution((n,m)))           # (n,m)-ary
    eB = np.matrix(normal_distribution((n,m)))           # (n,m)-ary
    pB = np.matrix((M.transpose().dot(sB) + 2 * eB) % q) # (n,m)-ary
    print('sB:'); print(sB)
    print('eB:'); print(eB)
    print('pB:'); print(pB)

    # Bob key
    eB_prime = normal_distribution((m,m))                # (m,m)-ary
    kB = ((pA.transpose()).dot(sB) + 2 * eB_prime) % q   # (m,m)-ary
    print('kB:'); print(kB)
    s = Signal(kB).astype(int)                           # (m,m)-ary
    skB = Encode(kB, s)                                  # (m,m)-ary
    print('skB:'); print(skB)

    # Alice key
    eA_prime = normal_distribution((m,m))                # (m,m)-ary
    kA = ((sA.transpose()).dot(pB) + 2 * eA_prime) % q   # (m,m)-ary
    print('kA:'); print(kA)
    skA = Encode(kA, s)                                  # (m,m)-ary
    print('skA:'); print(skA)

    is_same = (skA.tolist() == skB.tolist())
    print('skA == skB:', is_same)
    if is_same:
        key = int(''.join(str(x) for x in np.array(skA).flatten()), 2)
        print('key is', hex(key))
    return is_same

main()
```

実行してみると、次のようになります。

```
M:（事前に共有した行列）
[[35761 30285 11790 ... 15363 21793 17646]
 [ 2055 34481 14807 ... 19251 30720  7966]
 [23475  8374 31248 ... 35394 24505 11884]
 ...
 [38814 12322 16615 ... 25610 17289  3952]
 [ 7867  2832 17910 ... 27952 39213 16256]
 [28831 34868 18169 ... 11022 32252 39136]]
sA:（Aliceの秘密鍵）
[[-3  5 -4 ... -6  0 -4]
 [-2 -1  5 ... -4  8 -1]
 [-1  3  0 ... -3  1 -5]
 ...
 [-4  0  3 ... -4  2  0]
 [-1  5  3 ... -1  5  2]
 [ 2 -1  1 ...  4  0  1]]
eA:（Aliceの誤差ベクトル）
[[ 4 -9  1 ... -4 -4  0]
 [-3  3 -4 ... -3 -4 -1]
 [ 4  2  1 ...  3  2  5]
 ...
 [-1  6  2 ...  2  1 -3]
 [-2 -2 -5 ...  1 -1 -5]
 [ 0 -1  3 ...  7  1 -2]]
pA:（Aliceの公開鍵）
[[ 8514  6398 14953 ...  5710 21104 37260]
 [ 2335 21413 12547 ... 32121 22870 22541]
 [10853 40247  9512 ...  2181 12427 19174]
 ...
 [20787 18593 21871 ... 23888 15149 16384]
 [20760  9186 27423 ...  9561 14684 24255]
 [33143 19358 26615 ... 11319 13778 11182]]
sB: (Bobの秘密鍵)
[[-1  2  0 ...  0  1  1]
 [ 0 -2  4 ... -4  2  1]
 [ 0  6 -5 ...  1 -4  4]
 ...
 [ 4  5 -5 ...  1  2 -3]
 [-5 -1  0 ... -4  3 -4]
 [ 4  4  2 ...  2  6 -3]]
eB:（Bobの誤差ベクトル）
[[-4  5 -9 ... -1  2 -1]
 [-2  3  3 ...  2 -1  0]
 [-1  0 -1 ...  4  3  3]
 ...
 [-5  3  3 ... -3  0  3]
 [ 4  6  0 ...  2  5  0]
 [ 1 -1  4 ... -4 -1  2]]
pB:（Bobの公開鍵）
[[36063  7151 34374 ... 29286 21365 29397]
 [12552 40770 18882 ... 19521 34314 23309]
 [22401 22836 35098 ... 22843 33414  9481]
 ...
 [14987  2637   550 ... 15024 36124 12091]
 [ 7357 13777 30979 ... 16216 13851 29759]
 [29949 32058  9951 ... 28677  7431 37993]]
kB:
[[36240 12367 27901 ... 29723 34067  9755]
 [12667 10398  4496 ... 40536 31607 39179]
 [28491 33432  2916 ... 35739  8450  7134]
 ...
 [29701 33672 10534 ...  6868  1081  1995]
 [37990 40149 24340 ... 20009 37114 36089]
 [  222 17421 37327 ... 35922  1408 13578]]
skB:（Bobが得た共有鍵）
[[1 0 0 ... 0 0 1]
 [0 1 0 ... 1 0 0]
 [0 1 0 ... 0 0 0]
 ...
 [0 1 1 ... 0 1 1]
 [1 0 1 ... 0 1 0]
 [0 0 0 ... 1 0 1]]
kA:
[[37240 12237 28601 ... 28979 35375  8369]
 [12087 10426  3734 ... 40944 32379 40397]
 [26857 32438  2846 ... 36651  8596  7084]
 ...
 [30175 32634 10724 ...  7024  1263  1343]
 [38196 40695 26058 ... 19703 36366 37623]
 [ 1584 17081 37035 ... 36136   474 14876]]
skA:（Aliceが得た共有鍵）
[[1 0 0 ... 0 0 1]
 [0 1 0 ... 1 0 0]
 [0 1 0 ... 0 0 0]
 ...
 [0 1 1 ... 0 1 1]
 [1 0 1 ... 0 1 0]
 [0 0 0 ... 1 0 1]]
skA == skB: True
key is 0x9ac8fe314c6e41d442452b98d6f6ea8803182311a9b6aadedee89bb30029fa1084bc64a7ffee75a80baf6e9702cb16a5d3ca73376730ca84a65931ad2fcb8f1434379d473eb48ea90c668265f7b5b3f08b80e92af89df80947cdb725db6a9163dcb67088558d5d8137d04017167a81b01de839717bd1b84ba26a8ee20c1227d5
```

このようにして、複数ビット（$m^2$ bit）のランダムな共有鍵を共有することができます。

実装は J. Ding "[A Simple Provably Secure Key Exchange Scheme Based on the Learning with Errors Problem](https://eprint.iacr.org/2012/688.pdf)" を読みながらPythonで実装していきました。正確性や安全性の証明などはこちらを参照してください。


次回：[SageMathでRing-LWEによる鍵共有]({{ site.baseurl }}/crypto/ring-lwe-key-exchange)

#### 参考文献
- [格子問題等の困難性に関する調査 (pdf) - 暗号技術調査 (暗号解析評価) ワーキンググループ](https://www.cryptrec.go.jp/exreport/cryptrec-ex-2404-2014.pdf)
- [耐量子計算機暗号の研究動向調査報告書 (pdf) - CRYPTREC 暗号技術調査 WG (暗号解析評価)](https://www.cryptrec.go.jp/report/cryptrec-tr-2001-2018.pdf)

---

[^PQC]: 耐量子暗号は「耐量子計算機暗号」や「ポスト量子暗号」とも呼ばれる .
[^QFT]: 量子コンピュータで離散フーリエ変換することを量子フーリエ変換という .
[^QFT-wiki]: [Quantum Fourier transform - Wikipedia](https://en.wikipedia.org/wiki/Quantum_Fourier_transform)
[^Reg05]: O. Regev, "[On lattices, learning with errors, random linear codes, and cryptography](https://cims.nyu.edu/~regev/papers/qcrypto.pdf)," J. ACM, 56(6) (2009), pp. 1–40 (Preliminary version was presented at STOC 2005), 2009.
[^Pei09]: C. Peikert, "[Public-key cryptosystems from the worst-case shortest vector problems: extended abstract](https://web.eecs.umich.edu/~cpeikert/pubs/svpcrypto.pdf)," In Proc. 41st ACM Symp. on Theory of Computing–STOC 2009, ACM, pp. 333–342, 2009.
[^Ding12]: J. Ding, X. Xie, X. Lin "[A Simple Provably Secure Key Exchange Scheme Based on the Learning with Errors Problem](https://eprint.iacr.org/2012/688.pdf)," University of Cincinnati Chinese Academy of Sciences Rutgers University, 2014.
[^cryptrec-report2015]: [格子問題等の困難性に関する調査 - 暗号技術調査 (暗号解析評価) ワーキンググループ](https://www.cryptrec.go.jp/exreport/cryptrec-ex-2404-2014.pdf)
