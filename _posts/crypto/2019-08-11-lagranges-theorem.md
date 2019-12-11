---
layout:        post
title:         "ラグランジュの定理と群の位数"
date:          2019-08-11
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

群論において、ラグランジュの定理とは次のような定理のことです。
なお、群 $G$ の部分群 $H$ によって類別したときの類の数を**指数** (index) といい、$\|G:H\|$ と書きます。

- **ラグランジュの定理**

    $G$ を有限群とし、$H$ を $G$ の部分群とする。
    このとき部分群 $H$ の位数 $\|H\|$ は群 $G$ の位数 $\|G\|$ の約数になる。

    $$
    |G| = |G:H| \cdot{} |H|
    $$


このとき、有限群の任意の元 $g \in G$ により生成される巡回群 $$\langle g\rangle = \{ng \;|\; n \in \mathbb{Z}\}$$ は $G$ の部分群となり、巡回群の位数は $\|\langle g\rangle\| = \|G\|$ となります。
さらに、ラグランジュの定理には次のような系 (同時に成立する関係性) があります。

- **ラグランジュの定理**

    有限群 $G$ の任意の元の位数は群 $G$ の位数の約数になる。


ここで有限群 $\mathbb{Z}_q$ について、$q$ が素数の場合、部分群の位数は $q$ の約数である $1$ もしくは $q$ しかありえません。
単位元以外の任意の元 $a$ を選んだとき、巡回群は少なくとも単位元 $e$ と元 $a$ の2つ以上の元を持ちます。よって、元 $a$ の位数は $q$ になります。
よって、有限群 $\mathbb{Z}_q$ について、単位元以外の任意の元の位数は $q$ になります。

<br>

### 有限群の位数

例えば $\mathbb{Z}_6$ は位数が非素数なので、単位元以外の任意の元が作る巡回群の位数は $1,2,3,6$ のどれかになります。

$$
\begin{align}
1 + 1 + 1 + 1 + 1 + 1 &\equiv 0 \pmod{6} \\
2 + 2 + 2 &\equiv 0 \pmod{6} \\
3 + 3 &\equiv 0 \pmod{6} \\
4 + 4 + 4 &\equiv 0 \pmod{6} \\
5 + 5 + 5 + 5 + 5 + 5 &\equiv 0 \pmod{6}
\end{align}
$$

一方で、$\mathbb{Z}_7$ は位数が素数なので、単位元以外の任意の元が作る巡回群の位数は必ず $7$ になります。

$$
\begin{align}
1 + 1 + 1 + 1 + 1 + 1 + 1 &\equiv 0 \pmod{7} \\
2 + 2 + 2 + 2 + 2 + 2 + 2 &\equiv 0 \pmod{7} \\
3 + 3 + 3 + 3 + 3 + 3 + 3 &\equiv 0 \pmod{7} \\
4 + 4 + 4 + 4 + 4 + 4 + 4 &\equiv 0 \pmod{7} \\
5 + 5 + 5 + 5 + 5 + 5 + 5 &\equiv 0 \pmod{7} \\
6 + 6 + 6 + 6 + 6 + 6 + 6 &\equiv 0 \pmod{7}
\end{align}
$$

<br>

### 楕円曲線上の点集合が成す群の位数

例えば、有限体 $\mathbb{F}_{11}$ 上の楕円曲線 $y^2 \equiv x^3 + x - 3 \pmod{11}$ の位数は $6$ で非素数です
(楕円曲線の位数の求め方は [ルジャンドル記号による楕円曲線の位数計算]({{ site.baseurl }}/crypto/order-of-elliptic-curve) を参照してください)。
Sage で楕円曲線上にある全ての点について、その元の位数をプログラムで出力させると $6$ の約数である $1,2,3,6$ のどれかになります。

```python
$ sage
sage: EC = EllipticCurve(GF(11), [1, -3])
sage: EC.order()
6
sage: for a in EC: print("Point: %s, Order: %s" % (a, a.order()))
Point: (0 : 1 : 0), Order: 1
Point: (3 : 4 : 1), Order: 6
Point: (3 : 7 : 1), Order: 6
Point: (8 : 0 : 1), Order: 2
Point: (9 : 3 : 1), Order: 3
Point: (9 : 8 : 1), Order: 3
```

一方で、有限体 $\mathbb{F}_{11}$ 上の楕円曲線 $y^2 \equiv x^3 - x + 8 \pmod{11}$ の位数は $7$ で素数です。
なので、Sage で楕円曲線上にある全ての点について、その元の位数をプログラムで出力させると、単位元 (無限遠点) 以外の元では位数が必ず $7$ になります。

```python
$ sage
sage: EC = EllipticCurve(GF(11), [-1, 8])
sage: EC.order()
7
sage: for a in EC: print("Point: %s, Order: %s" % (a, a.order()))
Point: (0 : 1 : 0), Order: 1
Point: (2 : 5 : 1), Order: 7
Point: (2 : 6 : 1), Order: 7
Point: (6 : 3 : 1), Order: 7
Point: (6 : 8 : 1), Order: 7
Point: (7 : 5 : 1), Order: 7
Point: (7 : 6 : 1), Order: 7
```

以上の理由から、暗号技術で使われている楕円曲線のドメインパラメータは、位数が素数になるように設定されています。
