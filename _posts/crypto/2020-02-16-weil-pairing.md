---
layout:        post
title:         "ヴェイユペアリングと3者間DH鍵共有"
menutitle:     "ヴェイユペアリング (Weil pairing) と3者間DH鍵共有"
date:          2020-02-16
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
# sitemap: false
# draft:   true
---

SageMath を使ってヴェイユペアリング (Weil pairing) を超特異楕円曲線上で作り、ペアリング計算ができることを確認した上で、3者間DH鍵共有を SageMath コードで実際に動かしてみたいと思います。

まずはじめに、$n$ねじれ群について説明します。

- **$n$ねじれ群**

    体 $K$ 上の楕円曲線 $E/K$ 上の各点 $P$ について、$n$ 倍すると無限遠点 $\mathcal{O}$ になる点の集合を $n$ ねじれ群 (n-torsion group) といい、$E[n]$ で表される。また、$n$ ねじれ群の元を $n$ ねじれ点 (n-torsion point) [^n-torsion-point]といい、これらの点は全部で $n^2$ 個存在する。

    $$E[n] = \{ P \in E(\overline{K}) \,|\, nP = \mathcal{O} \}$$

[^n-torsion-point]: $n$ねじれ点 (n-torsion point) は、$n$等分点 (n-division point) ともいいます。

体 $K$ ではなく、その代数的閉包 $\overline{K}$ を使うことで、全ての点が確実に位数 $n$ になります。

また、有限体 $\mathbb{F_q}$ の代数的閉包 $\mathbb{\overline{F}}_q$ には次のような関係があります。

$$\mathbb{\overline{F}}_q = \bigcup_{k \gt 1} \mathbb{F}_{q^k}$$

次にヴェイユペアリングについて説明します。

- **ヴェイユペアリング $e_n$**

    楕円曲線 $E/K$ について、$n$ を正整数、$\mu_n$ を $1$ の $n$ 乗根からなる集合とする。
    また、$\mu_n$ の元の位数は $n$ である。
    体 $K$ (つまり $\mathbb{F}_{p^k}$) の標数 $p$ は $n$ を割り切らない ($p \nmid n$) とき、次のペアリングが存在する。

    $$
    \begin{aligned}
    e_n : E[n] \times E[n] &\rightarrow \mu_n \subset \overline{K} \\[5pt]
    (P,Q) &\mapsto e_n(P,Q)
    \end{aligned}
    $$

- **ヴェイユペアリングの性質**

    ヴェイユペアリングは $P, P_1, P_2, Q, Q_1, Q_2 \in E[n]$ に対して次の性質を持つ。

    1. 双線型性 (bilinearity)

        - $e_n(P_1 + P_2, Q) = e_n(P_1, Q) \, e_n(P_2, Q)$
        - $e_n(P, Q_1 + Q_2) = e_n(P, Q_1) \, e_n(P, Q_2)$

    2. 非退化性 (non-degeneracy)

        - 任意の $Q \in E[n]$ に対して $e_n(P,Q)=1$ であるならば、$P = \mathcal{O}$
        - 任意の $P \in E[n]$ に対して $e_n(P,Q)=1$ であるならば、$Q = \mathcal{O}$

    3. 交代性 (alternating)

        - 任意の $P \in E[n]$ に対して $e_n(P, P)=1$

    4. 歪対称性 (skew symmetry)

        - 任意の $P,Q \in E[n]$ に対して $e_n(P,Q) = e_n(Q,P)^{-1}$

    5. ガロア作用 (Galois action)

        - 任意の $\sigma \in Gal(\overline{K}/K)$ に対して $e_n(\sigma P, \sigma Q) = \sigma(e_n(P, Q))$


注意として、$Q = kP$ (線型従属) となる $Q, P \in E[n]$ を選んだときは、$e_n(P,Q) = 1$ になります。
双線型性と交代性より $e_n(P, kP) = \underbrace{e_n(P,P)\cdots{}e_n(P,P)}_{k} = 1$ となるからです。
ペアリングにおいて $P, Q$ が線型従属のとき、この2つの点をトリビアルなペア (trivial pairings) といいます。

また、ペアリングの「双線型性」からは、暗号で利用する場合に特に重要な関係として、ある整数 $a$ に対して次の式で表される楕円曲線上の点の $a$ 倍点と有限体上の $a$ 乗を結び付ける式があります。

$$e_n(aP, Q) = e_n(P, aQ) = e_n(P, Q)^a$$


<br>
### ヴェイユペアリングの例

ここからは具体的な数字を使いながら説明していきます。
この例では、楕円曲線 $E(\mathbb{F}_{2^7})$ を使い、楕円曲線の式は次の**超特異曲線**を使います。
超特異曲線はペアリング計算に使いやすい利点がありますが、曲線選択の自由度や拡大次数の選択の自由度、安全性などの観点から、超特異ではない通常曲線を使う場合も多いです。

$$
E : y^2 + y = x^2 + x + 1
$$

まずは、この超特異曲線の位数をSageMathで計算します。
SageMathのおさらいですが、ワイエルシュトラス方程式 $y^2 + a_1 xy + a_3 y = x^3 + a_2 x^2 + a_4 x + a_6$ の係数 $a_1$ 〜 $a_6$ から、楕円曲線を `EllipticCurve([a1,a2,a3,a4,a6])` のように宣言します。また、集合論において cardinality（濃度）とは、有限集合における「元の個数」を一般の集合に拡張したものですので、ここでは集合の位数と同じ意味です。

```python
# SageMath で楕円曲線 E(F_{2^7})
q = 2^7
F1.<a> = GF(q)
E1 = EllipticCurve(F1, [0, 0, 1, 1, 1]) # y^2 + y = x^3 + x + 1 over GF(2^7)
print(E1.cardinality()) # 位数を計算する
# => 113
```

$E$ の位数は $113$ で素数なので、$$E(\mathbb{F}_{2^7})$$ は巡回群であり、全ての点は互いに線型従属となり、全ての点の組み合わせがトリビアルなペアになります。
線型従属にならないようにするためには、拡大次数を $k$ 倍した $E(\mathbb{F}_{2^{7k}})$ を使い、$k$ を Balasubramanian-Koblitz の定理を使って求めます。

- **Balasubramanian-Koblitz の定理**

    有限体 $$\mathbb{F}_q$$ 上の楕円曲線 $E$ について、$n$ は素数で、$$n \mid \#E(\mathbb{F}_q),\; n \nmid (q - 1)$$ を満たす。このとき $n \mid (q^k - 1)$ であれば、拡大次数 $k$ の $E(\mathbb{F}_{q^k})$ は、位数が $n$ の点を $n^2$ 個持つ。

つまり、$k$ は $n \mid (q^k - 1) = 113 \mid (2^{7k} - 1)$ を満たす最小の $k$ を見つける必要があります。SageMathで計算すると次のようになり、$k = 4$ だとわかりました。

```python
# SageMath で n | (q^k - 1) を満たす最小の k > 1 を求める
n = 113
q = 2^7
for k in range(2, 1000):
    if (q^k - 1) % 113 == 0: # n が q^k - 1 を割り切るかを調べる
        break
print(k)
# => 4
```

$k = 4$ だと $$\mathbb{F}_{2^{28}}$$ なので、改めて有限体 $$\mathbb{F}_{2^{28}}$$ 上の楕円曲線を定義します。

```python
# SageMath で楕円曲線 E(F_{2^28})
q = 2^7
k = 4
F2.<b> = GF(q^k)
E2 = EllipticCurve(F2, [0, 0, 1, 1, 1]) # y^2 + y = x^3 + x + 1 over GF(2^28)
print(factor(E2.cardinality())) # 位数を計算する
# => 5^2 * 29^2 * 113^2
```

よって、任意の $$Q, P \in E(\mathbb{F}_{2^{28}})$$ に対して、トリビアルではないペア、つまり線型独立な2つの点のペアを作ることができます。

次に、楕円曲線 $$E(\mathbb{F}_{2^{28}})$$ の $n$ ねじれ群 $E(\mathbb{F}_{2^{28}})[n]$ を求めます。
SageMath では楕円曲線上の点の $n$ ねじれ群は `division_points(n)` というメソッドで求めることができます。
$E$ の位数は $5^2 \times 29^2 \times 113^2$ なので、ラグランジュの定理から位数が $113$ となる元が含まれることが確認できます。ここでは、$113$ねじれ群（位数が$113$となる点の集合）を求めます。

```python
torsion113 = E(0).division_points(113)
print(len(torsion113) == n^2)
# => True ... Balasubramanian-Koblitzの定理より、nねじれ点はn^2個ある
```

SageMath にはヴェイユペアリングをするためのメソッド `P.weil_pairing(Q, n)` があります。
ヴェイユペアリングは $e_n : E[n] \times E[n] \rightarrow \mu_n$ で表せて、2個の$n$ねじれ点 $P, Q$ から1の$n$乗根への写像 $e_n(P, Q)$ です。
なので、まずは2個の$n$ねじれ点 $P, Q$ を適当に選びます。
$n$ねじれ群はすでに求めたので、あとは random.choice で選ぶのが簡単で早いと思います。

```python
import random
P = random.choice(torsion113)
Q = random.choice(torsion113)

P
# => (b^27 + b^19 + b^18 + b^16 + b^15 + b^13 + b^12 + b^10 + b^7 + b^6 + b^4 +
#     b^2 : b^26 + b^24 + b^19 + b^18 + b^17 + b^11 + b^7 + b^6 + b^5 + b^4 +
#     b^3 + b : 1)
P * 113
# => (0 : 1 : 0) ... 無限遠点(単位元)になるので、位数は113であることが確認できる

Q
# => (b^27 + b^26 + b^24 + b^22 + b^21 + b^18 + b^17 + b^16 + b^15 + b^14 +
#     b^13 + b^12 + b^11 + b^10 + b^7 + b^5 + b^4 + b^3 + 1 : b^24 + b^23 +
#     b^22 + b^21 + b^20 + b^19 + b^18 + b^15 + b^12 + b^11 + b^9 + b^4 + b^3
#     : 1)
Q * 113
# => (0 : 1 : 0) ... 無限遠点(単位元)になるので、位数は113であることが確認できる
```

2個の$n$ねじれ点 $P, Q$ を選んだら、ヴェイユペアリングを適用させます ($n=113$)。
また、この結果 $e_n(P, Q)$ の位数は 113 であることも確認できます。

```python
P.weil_pairing(Q, n)
# => b^27 + b^26 + b^25 + b^24 + b^22 + b^21 + b^20 + b^16 + b^15 + b^13 +
#    b^12 + b^11 + b^8 + b^7 + b^5 + b^4 + b^3 + 1
P.weil_pairing(Q, n)^n
# => 1
```

最後に、ペアリングを暗号技術として使うときに最も重要な関係である次の式が成り立つことを確認します。

$$e_n(aP, Q) = e_n(P, aQ) = e_n(P, Q)^a$$

例えば $a=17$ としてペアリング計算をすると、楕円曲線上の点の $a$ 倍点と有限体上の $a$ 乗が同じになることが確認できます。

```python
(17*P).weil_pairing(Q, n)
# => b^25 + b^17 + b^14 + b^11 + b^10 + b^4
(P).weil_pairing(17*Q, n)
# => b^25 + b^17 + b^14 + b^11 + b^10 + b^4
(P).weil_pairing(Q, n)^17
# => b^25 + b^17 + b^14 + b^11 + b^10 + b^4
```

<br>
### 3者間DH鍵共有

3者間DH鍵共有 (Tripartite Diffie-Hellma; 3者間ディフィー・ヘルマン) という、
ペアリングを Diffie-Hellman 鍵共有に応用し、1ラウンド（1回のデータ送受信）で3者間の鍵共有をする方法があります。
これは Joux[^Joux] が 2000 年 1 月に提案したものです。

A と B と C の3人が鍵共有をするとき、鍵共有は次の手順で行います。

- 準備
  1. 公開情報として、2個の$n$ねじれ点 $P,Q \in E[n]$ を用意する。
- 鍵共有
  1. A は乱数 $a$ を生成し $(aP, aQ)$ を、B は乱数 $b$ を生成し $(bP, bQ)$ を、C は乱数 $c$ を生成し $(cP, cQ)$ を、公開鍵として公開する。
  2. A は自身の秘密鍵$a$と、BとCの公開鍵 $bP, cQ$ を使って $e_n(bP, cQ)^a$ を計算する。
  3. B は自身の秘密鍵$b$と、AとCの公開鍵 $aP, cQ$ を使って $e_n(aP, cQ)^b$ を計算する。
  4. C は自身の秘密鍵$c$と、AとBの公開鍵 $aP, bQ$ を使って $e_n(aP, bQ)^c$ を計算する。
  5. $e_n(bP, cQ)^a = e_n(aP, cQ)^b = e_n(aP, bQ)^c = e_n(P, Q)^{abc}$ より、同じ鍵を共有することができる。

上の手順を SageMath で書くと、次のようになります (E2 や F2 は上のプログラムで定義したものを使用しています)。

```python
import os
import binascii

a = int(binascii.hexlify(os.urandom(1)), 16)
b = int(binascii.hexlify(os.urandom(1)), 16)
c = int(binascii.hexlify(os.urandom(1)), 16)
print(a, b, c)
# => (83, 176, 172)

# 公開鍵
def to_ints(pub_points): # 点を整数に変換する（公開鍵を送信するときは整数などにしてから送る）
    return (pub_points[0].xy()[0].integer_representation(),
            pub_points[0].xy()[1].integer_representation(),
            pub_points[1].xy()[0].integer_representation(),
            pub_points[1].xy()[1].integer_representation())

a_pub_ints = to_ints((a*P, a*Q))
b_pub_ints = to_ints((b*P, b*Q))
c_pub_ints = to_ints((c*P, c*Q))
print(a_pub_ints, b_pub_ints, c_pub_ints)
# => ((37645391,  93769717,  97705989,  220743243),
#     (57203223,  227920824, 177740053, 72632626),
#     (251474895, 118501631, 231919568, 116637055))

# 鍵共有
def from_ints(pub_ints): # 整数を点に変換する（受信した整数から楕円曲線上の点に戻す）
    return (E2((F2.fetch_int(pub_ints[0]), F2.fetch_int(pub_ints[1]))),
            E2((F2.fetch_int(pub_ints[2]), F2.fetch_int(pub_ints[3]))))

a_pub = from_ints(a_pub_ints)
b_pub = from_ints(b_pub_ints)
c_pub = from_ints(c_pub_ints)
print(a_pub)
# => ((b^25 + b^21 + b^20 + b^19 + b^18 + b^17 + b^14 + b^13 + b^11 + b^10 +
#      b^6 + b^3 + b^2 + b + 1 : b^26 + b^24 + b^23 + b^20 + b^18 + b^17 + b^15 +
#      b^14 + b^11 + b^10 + b^9 + b^8 + b^7 + b^6 + b^5 + b^4 + b^2 + 1 : 1),
#     (b^26 + b^24 + b^23 + b^22 + b^20 + b^17 + b^15 + b^14 + b^13 + b^2 + 1 :
#      b^27 + b^26 + b^24 + b^21 + b^19 + b^14 + b^10 + b^9 + b^6 + b^3 + b + 1 :
#      1))
print(b_pub)
# => ((b^25 + b^24 + b^22 + b^21 + b^19 + b^15 + b^14 + b^12 + b^11 + b^9 + b^4 +
#      b^2 + b + 1 : b^27 + b^26 + b^24 + b^23 + b^20 + b^18 + b^16 + b^15 +
#      b^14 + b^11 + b^9 + b^8 + b^7 + b^5 + b^4 + b^3 : 1),
#     (b^27 + b^25 + b^23 + b^20 + b^19 + b^12 + b^11 + b^8 + b^4 + b^2 + 1 :
#      b^26 + b^22 + b^20 + b^18 + b^14 + b^11 + b^8 + b^5 + b^4 + b : 1))
print(c_pub)
# => ((b^27 + b^26 + b^25 + b^23 + b^22 + b^21 + b^20 + b^19 + b^18 + b^16 +
#      b^13 + b^12 + b^9 + b^8 + b^7 + b^6 + b^3 + b^2 + b + 1 : b^26 + b^25 +
#      b^24 + b^20 + b^13 + b^12 + b^7 + b^6 + b^5 + b^4 + b^3 + b^2 + b + 1 : 1),
#     (b^27 + b^26 + b^24 + b^23 + b^22 + b^20 + b^17 + b^15 + b^14 + b^11 +
#      b^10 + b^9 + b^8 + b^7 + b^6 + b^4 : b^26 + b^25 + b^23 + b^22 + b^21 +
#      b^20 + b^17 + b^16 + b^15 + b^13 + b^12 + b^11 + b^10 + b^8 + b^6 + b^5 +
#      b^4 + b^3 + b^2 + b + 1 : 1))

def e(P, Q, n=113): # ペアリング計算
    return P.weil_pairing(Q, n)

a_key = e(b_pub[0], c_pub[1])^a
b_key = e(a_pub[0], c_pub[1])^b
c_key = e(a_pub[0], b_pub[1])^c
print(a_key == b_key == c_key)
# => True
print(a_key)
# => b^25 + b^24 + b^23 + b^21 + b^18 + b^16 + b^13 + b^11 + b^9 + b^8 +
#    b^4 + b^3 + b
print(a_key.integer_representation())
# => 61156122
```

以上より、ヴェイユペアリングを使って3者間で正しく鍵を共有することができました。


<br>
#### 参考文献

- [Pairing-based Cryptography -- A short signature scheme using the Weil pairing](http://www.sagemath.org/files/thesis/hansen-thesis-2009.pdf)
- 辻井 重男, 笠原 正雄, 有田 正剛, 境 隆一, 只木 孝太郎, 趙 晋輝, 松尾 和人『暗号理論と楕円曲線』森北出版, 第一版, 2008年, pp. 138-155
- 岡本 龍明『現代暗号の誕生と発展：ポスト量子暗号・仮想通貨・新しい暗号』近代科学社, 2019年, p. 143
- 光成 滋生『クラウドを支えるこれからの暗号技術』秀和システム, 2015年, p. 82


-----

[^Joux]: Joux, Antoine. (2000). A One Round Protocol for Tripartite Diffie-Hellman. 385-394.
