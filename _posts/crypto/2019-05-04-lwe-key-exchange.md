---
layout:        post
title:         "LWE格子暗号による鍵共有"
menutitle:     "LWE格子暗号による鍵共有"
date:          2019-05-04
tags:          Crypto
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

量子コンピュータの進歩に伴い、**耐量子暗号**（Post-Quantum Cryptography; PQC）[^PQC] と呼ばれる量子コンピュータでも解読が難しいとされる暗号が注目されています。
現在使われている暗号には、RSAのように素因数分解問題の困難性を利用した暗号や、ECDHのように離散対数問題の困難性を利用した暗号があります。
しかし、**Shorのアルゴリズム**という、離散フーリエ変換を利用して素因数分解問題や離散対数問題を解くアルゴリズムがあるのですが、量子コンピュータを使うことで離散フーリエ変換を高速に解くことができ、結果として素因数分解や離散対数問題を高速に解けるようになります [^QFT] [^QFT-wiki]。

量子コンピュータはすでにあるのですが、扱える量子ビット数がまだ少ないので現在使われている暗号は解読できません。しかし将来、扱える量子ビット数が増えた時に備えておく必要はあるでしょう。
なお、2019年2月にGoogleが発表した最新の量子プロセッサ「Bristlecone」の量子ビット数は72です。
実際のRSA暗号では2048ビットのモジュロが使われています。
これに加えて、量子ビットはエラーが発生しやすいため、正しい計算結果を得るには数百万量子ビットが必要とされています。なので、量子コンピュータで解読できるようになるまでにはまだ時間がかかりそうというのが現在の状況です。
$$\def\Z{ \mathbb{Z} }$$
$$\def\vec#1{ \textbf{#1} }$$

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

1. パラメータ $q, n, \vec{M}, \chi_\alpha$ を事前に共有します。ただし $q$ は3以上の素数で、$n \times n$ の行列 $\vec{M}$ の各要素は一様分布で選んだ乱数にします（$\vec{M} \in \Z_q^{n \times n}$）。$\chi_\alpha$ は誤差分布で、誤差を付加するときに使います。
2. Aliceは誤差分布から秘密ベクトル $\vec{s}_A$ と誤差ベクトル $\vec{e}_A$ を作ります。そして、公開鍵 $\vec{p}_A = \vec{M} \cdot{} \vec{s}_A + 2\vec{e}_A$ を計算し、Bob に送信します。
3. Bobは誤差分布から秘密ベクトル $\vec{s}_B$ と誤差ベクトル $\vec{e}_B$ と誤差 $e'_B$ を作ります。そして、公開鍵 $\vec{p}_B = \vec{M}^T \cdot{} \vec{s}_B + 2 \vec{e}_B$ を計算します。さらに、鍵の元となる値 $K_B = \vec{p}_A^T \cdot{} \vec{s}_B + 2 e'_B \mod{q}$ を計算し、$\sigma \leftarrow S(K_B)$ を求めます。ここでBobは共有鍵 $SK_B = E(K_B, \sigma)$ を得ます。最後に公開鍵 $(\vec{p}_B, \sigma)$ を送信します。
4. Aliceは誤差分布から誤差 $e'_A$ を作ります。そして $K_B = \vec{s}_A^T \cdot{} \vec{p}_B + 2 e'_A \mod{q}$ を計算し、共有鍵 $SK_A = E(K_A, \sigma)$ を得ます。

上の手順をPythonで書くと以下のようになります。


5/12: **プログラムに実装ミスがあることを確認しました。近日中に修正いたします。**

```python
import numpy as np

# 一様分布の乱数
def uniform_distribution(q, n):
    return np.random.randint(0, q, size=n)

# 誤差分布（正規分布）
def normal_distribution(n):
    a = np.random.normal(loc=0, scale=1.0, size=n)
    return np.round(a).astype(int)

# シグナル関数
def Signal(x):
    if x in range(-math.floor(q/4), round(q/4)+1):
        return 0
    else:
        return 1

Signal = np.frompyfunc(Signal, 1, 1)

# 符号化関数
def Encode(x, s):
    return ((x + s * (q-1)//2) % q) % 2


n = 8 # 1024 # 格子の次元
q = 40961    # 法とする素数

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
[[25308 21194 28988 40345 10925 39374 16960 32739]
 [15257 10006 24059  5104 20106 33364 28102  8494]
 [16100  3325 29047  3770 28748 14588 15391 12711]
 [13657  5557 40271 23202 25791  9715 15330 12437]
 [ 9869 16480 27247 26115 33556 32756 32603 36213]
 [37422  1212 22440  2902 35047 31692 11382  9646]
 [20903 19111 27757  3015   196  5245 18342  3362]
 [ 8356  7648 34681 37089 13756 35705 19430 32863]]
sA:（Aliceの秘密鍵）
[[ 1]
 [-1]
 [ 1]
 [ 1]
 [ 0]
 [-2]
 [ 1]
 [ 0]]
eA:（Aliceの誤差ベクトル）
[[ 0]
 [ 2]
 [-2]
 [ 0]
 [ 3]
 [-1]
 [-1]
 [ 2]]
pA:（Aliceの公開鍵）
[[11659]
 [36753]
 [31803]
 [26512]
 [13848]
 [ 9548]
 [40414]
 [20502]]
sB: (Bobの秘密鍵)
[[-2]
 [-1]
 [-1]
 [ 0]
 [ 1]
 [-1]
 [ 1]
 [-1]]
eB:（Bobの誤差ベクトル）
[[ 0]
 [ 0]
 [ 1]
 [ 0]
 [-1]
 [ 0]
 [ 1]
 [ 0]]
pB:（Bobの公開鍵）
[[25904]
 [11973]
 [ 9686]
 [22458]
 [37126]
 [ 7748]
 [24644]
 [33266]]
kB: [[14260]]
skB: [[0]]（Bobが得た共有鍵）
kA: [[14262]]
skA: [[0]]（Aliceが得た共有鍵）
skA == skB: True
```

何回か繰り返して実行してみると、ほとんどの場合において共有鍵（0 or 1）を共有することができています。（注意：私の実装がいけないのかわかりませんが、0.1%の確率で失敗するようなので、そのまま使うことはせず、LWE鍵共有の概念だけ掴んでいただけたらと思います。）

## LWE格子暗号による複数bitの鍵共有

1ビットの共有鍵を作っても 1/2 の確率で解読できるので、実用的ではありません。
そこで複数ビットの共有鍵を作ります。
ビットの数を増やすのは簡単で、上記の手順で使っていた秘密ベクトル $\vec{s}_A, \vec{s}_B \in \Z_q^n$ の代わりに、秘密行列 $\vec{S}_A, \vec{S}_B \in \Z_q^{n \times n}$ を作ります。

```python
#（関数定義などは1bitのときと同じ）

n = 8 # 1024 # 格子の次元
q = 40961    # 法とする素数
m = 10       # 共有鍵のビット数 = m^2 bit

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
        key = int(''.join(np.array(skA).flatten().astype(str)), 2)
        print('key is', hex(key))
    return is_same

main()
```

実行してみると、次のようになります。

```
M:（事前に共有した行列）
[[ 2373 25747 39534 21671 14618  2641  4041 18704]
 [18043   679 10248 12047 19550 28217 36456 18770]
 [ 1917 33440 10379 13318  1291 14754 35509 12692]
 [33311  6666 39289 28798 22602 11594 15601 32818]
 [20239 22706 38566 23770  7893 34661  7503 23925]
 [16805 31461  9728 29540 16938 24117  4867 13388]
 [ 1676 13855 23923  1074 15134 38984 17399  4579]
 [ 4632 40710 24796 18814 34160 19268 32242  2315]]
sA:（Aliceの秘密鍵）
[[ 0  0  0  0 -1  0 -2 -1  1 -1]
 [-2  1 -1 -1  1  0  0  1 -1  1]
 [ 0  0 -1 -1 -1  0  0  0  0  0]
 [ 0  1  0  0 -1  1 -1  0  0  0]
 [ 0  0 -1  1  0  0  2  1  1  0]
 [ 1  0  1  1 -1  0  2 -2 -1 -1]
 [ 0  0  0  0  1  2  1 -1  2  0]
 [ 1  0  1  1  1  1 -1  1  1  1]]
eA:（Aliceの誤差ベクトル）
[[ 1 -1  1 -2 -1  0 -1 -1  1  1]
 [-1  0  0  0 -1  1  0  0  2  1]
 [ 0  1 -1 -1 -1  0  0 -1  1 -1]
 [ 0 -1 -1  0  0  0  0  0  0  2]
 [ 0  2 -1  0 -1 -1  0  0  0  0]
 [-1 -1  0  1 -2 -2  0  1  0  0]
 [-1 -3  1  0 -1  0  2  0 -1  0]
 [ 1  0  1  0  1  1  2  0  2 -1]]
pA:（Aliceの公開鍵）
[[10814  6455 23370 11639 23232  7496 34397  6410 15391 39439]
 [ 4666 12726 16510 14649 28309 21809 24126  9988 18461 14152]
 [ 1527  5799 23295 25877   310 15106 37755 21448 38726 29459]
 [31080 35462 16814 21059 24015 10896 37677 30947 19751 35544]
 [13174  5519 30380  5207 18818 21738  4438 39382  9696 32692]
 [15542 20038 20339 13256 10483 11697 10439 32844  1287  3927]
 [15851 14923 31614 20919 11135 40451 34712 18447  3346 18735]
 [22087 18563  3841 31198  7759  3693 26787  1775  4656 19123]]
sB: (Bobの秘密鍵)
[[ 1  1  1  0  0  0 -1  1 -1  1]
 [ 1  0  2 -1  0  0  0  0 -1 -2]
 [ 0  1 -1  1  1  0  0  0  0  0]
 [ 0  1  0 -1  1  0  1  1  0 -1]
 [ 0  1  1  1  0  0 -1 -1  1  1]
 [ 0  0  0 -1  0 -1  0  1  0  0]
 [ 0  1 -1  0 -1 -1 -1 -1 -1  1]
 [ 0  0  0  0  2  0 -1  0  0 -1]]
eB:（Bobの誤差ベクトル）
[[ 1  0 -1 -1  2 -1 -1  1  0  1]
 [ 0  0  1 -1  0 -1  1 -2  1  1]
 [ 1  0  1  3  0  0  1 -1  1  1]
 [ 1  1  0  0  1  0  1 -1  0  0]
 [ 2 -1  0  0 -1  0 -1  0  0  0]
 [-1  2  0  0  2  0 -1  0  0 -2]
 [ 0  0  1 -1  0 -2  0  0  1  1]
 [ 1  1  0  0  0 -1  0  1  1  2]]
pB:（Bobの公開鍵）
[[20418 18555 14142 35917  1859 22478  4389 30576 39108 32183]
 [26426 20492  2518 17338 25749 36604 26533 27309 23388 13576]
 [ 8823 28808 23335 30647 34376  7310 35355 26060  5824 17444]
 [33720  6711 14182  7664 37711 10347  4432 14202 29939 15770]
 [34172 20575  4225 32016 36116  8889 32717 31131 40513 23705]
 [30856 20716 39998 26448 25904 18821 38921  5668  5780 29947]
 [40497 39092 31550 27047 16273 18691 36338 40568 31531 31073]
 [37476 10798 21937 12602  4600 22992 24256 36408 22835 15500]]
kB:
[[15480 31485 15938  4374 19967  9568 10117 28409 22804 18303]
 [19181 27201 16704 25014 22499  5998 30963   550 12374 29340]
 [39882  2592 31863    10 16175 29967  9531 39494 40810 31687]
 [26290  2775 40311 23081  6489  6782 34018 19828 39922 38132]
 [10578 36551  5305 38241 28710 19345  4032 27779 38066  5756]
 [29305 13767 17293 33405 33896 29774 19440  8859 33906 11476]
 [17562 26096 14622 10916 12374 36769 19263  2402 34086  1790]
 [16396 34712 25875 28012 37498 30629  5896 12372  4539 11543]
 [33852  4990 19935  8923 23482 36324 27621 23387 13461  8065]
 [12630 32982 11278  8530  2592 18301  7477 27479  1327  7895]]
skB:（Bobが得た共有鍵）
[[0 1 0 0 1 0 1 0 1 1]
 [1 0 0 1 0 0 1 0 0 1]
 [0 0 1 0 1 0 1 0 0 1]
 [1 1 1 0 1 0 0 0 0 0]
 [0 1 1 1 1 1 0 0 0 0]
 [0 1 1 1 0 1 0 1 0 0]
 [0 1 0 0 0 1 1 0 0 0]
 [0 0 0 1 0 0 0 0 1 1]
 [0 0 1 1 1 0 0 0 1 1]
 [0 0 0 0 0 1 1 0 1 1]]
kA:
[[15480 31493 15944  4376 19965  9564 10109 28417 22802 18297]
 [19185 27199 16700 25004 22497  5988 30963   550 12368 29346]
 [39870  2600 31857     8 16187 29973  9531 39500 40812 31681]
 [26296  2789 40307 23079  6491  6786 34004 19842 39914 38130]
 [10582 36551  5309 38233 28694 19333  4030 27783 38062  5766]
 [29309 13771 17295 33399 33894 29758 19440  8865 33916 11492]
 [17558 26094 14632 10916 12362 36777 19265  2404 34086  1784]
 [16408 34708 25875 28018 37486 30633  5898 12366  4535 11555]
 [33854  4984 19929  8923 23466 36314 27623 23389 13465  8093]
 [12628 32980 11280  8538  2586 18293  7481 27473  1339  7907]]
skA:（Aliceが得た共有鍵）
[[0 1 0 0 1 0 1 0 1 1]
 [1 0 0 1 0 0 1 0 0 1]
 [0 0 1 0 1 0 1 0 0 1]
 [1 1 1 0 1 0 0 0 0 0]
 [0 1 1 1 1 1 0 0 0 0]
 [0 1 1 1 0 1 0 1 0 0]
 [0 1 0 0 0 1 1 0 0 0]
 [0 0 0 1 0 0 0 0 1 1]
 [0 0 1 1 1 0 0 0 1 1]
 [0 0 0 0 0 1 1 0 1 1]]
skA == skB: True
key is 0x4ae492a7a07c1d44604338c1b
```

このようにして、複数ビット（$m^2$ bit）のランダムな共有鍵を共有することができます。（注意：1ビットの共有が0.1%の確率で失敗するようなので、100ビットを共有する場合 $0.999^{100} \sim 0.9$ より 10%の確率で鍵共有が失敗してしまいます。繰り返しになりますが、プログラムをそのまま使うことはせず、LWE鍵共有の概念だけ掴んでいただけたらと思います。）

実装は J. Ding "[A Simple Provably Secure Key Exchange Scheme Based on the Learning with Errors Problem](https://eprint.iacr.org/2012/688.pdf)" を読みながらPythonで実装していきました。正確性や安全性の証明などはこちらを参照してください。


次回：[Ring-LWEによる鍵共有]({{ site.baseurl }}/crypto/ring-lwe-key-exchange)

---

[^PQC]: 耐量子暗号は「耐量子計算機暗号」や「ポスト量子暗号」とも呼ばれる
[^QFT]: 量子コンピュータで離散フーリエ変換することを量子フーリエ変換という
[^QFT-wiki]: [Quantum Fourier transform - Wikipedia](https://en.wikipedia.org/wiki/Quantum_Fourier_transform)
[^Reg05]: O. Regev, "[On lattices, learning with errors, random linear codes, and cryptography](https://cims.nyu.edu/~regev/papers/qcrypto.pdf)," J. ACM, 56(6) (2009), pp. 1–40 (Preliminary version was presented at STOC 2005), 2009.
[^Pei09]: C. Peikert, "[Public-key cryptosystems from the worst-case shortest vector problems: extended abstract](https://web.eecs.umich.edu/~cpeikert/pubs/svpcrypto.pdf)," In Proc. 41st ACM Symp. on Theory of Computing–STOC 2009, ACM, pp. 333–342, 2009.
[^Ding12]: J. Ding, X. Xie, X. Lin "[A Simple Provably Secure Key Exchange Scheme Based on the Learning with Errors Problem](https://eprint.iacr.org/2012/688.pdf)," University of Cincinnati Chinese Academy of Sciences Rutgers University, 2014.
[^cryptrec-report2015]: [格子問題等の困難性に関する調査 - 暗号技術調査 (暗号解析評価) ワーキンググループ](https://www.cryptrec.go.jp/exreport/cryptrec-ex-2404-2014.pdf)
