---
layout:        post
title:         "有限体上の楕円曲線の点集合"
menutitle:     "有限体上の楕円曲線の点集合"
date:          2019-02-22
tags:          Crypto
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

有限体上の楕円曲線の点集合を求める方法について説明します。
さらに点集合を求めるプログラムをPythonで実装します。

注意書きとして、ここで扱うのは<u>有限体上</u>の楕円曲線であることに留意してください。
楕円曲線の本などを読むと、始めに楕円曲線の有理点群の演算について説明した後に、有限体上の楕円曲線について説明しますが、暗号系では離散対数問題を利用するために後者の有限体上のほうを使います。
有限体はつまり離散なので、楕円曲線上の点は連続していない（飛び飛び）です[^1]。


### 有限体の楕円曲線

まず始めに、有限体上の楕円曲線について説明します[^DRS]。

- **有限体上の楕円曲線**

    $p > 3$ を素数とする。有限体 $F_p$ 上の楕円曲線 $y^2 = x^3 + ax + b$ とは合同式

    $$
    y^2 \equiv x^3 + ax + b \pmod{p}
    \tag{1}\label{ec1}
    $$

    の解 $(x,y) \in \mathbb{Z}_p \times \mathbb{Z}_p$ 全体の集合である。
    ここで、$a,b \in \mathbb{Z}_p$ は $4a^3 + 27b^2 \not\equiv 0 \pmod{p}$ を満たす整数である。
    また、群の単位元として**無限遠点**（point at infinity）と呼ばれる特別な点 $O$ がある。
    楕円曲線 $E$ は各点に対する演算を加算で表現し、次のように定義される。

    $P = (x_1, y_1), Q = (x_2, y_2)$ を $E$ 上の点とする。
    もし $x_2 = x_1$ かつ $y_2 = -y_1$ ならば $P + Q = O$ とする。
    そうでないなら $P + Q = (x_3, y_3)$ とする。ただし：

    $$
    \begin{align}
      x_3 &= \lambda^2 - x_1 - x_2     \mod{p} \tag{2}\\
      y_3 &= \lambda (x_1 - x_3) - y_1 \mod{p} \tag{3}\\[10pt]
      \lambda &= \begin{cases}
        \cfrac{y_2 - y_1}{x_2 - x_1} \mod{p} & \mathrm{if}\; P \ne Q \\[3pt]
        \cfrac{3 x_1^2 + a}{2 y_1}   \mod{p} & \mathrm{if}\; P = Q
      \end{cases}
      \tag{4}
    \end{align}
    $$

    最後に全ての $P \in E$ について $P + O = O + P = P$ と定義する。
    また、全ての $(x,y) \in E$ について逆元を $(x,-y)$ とする。


### オイラーの規準

ここまでで有限体上の楕円曲線の演算はできますが、どの点が楕円曲線上にあるのか調べる必要があります。
つまり、適当な座標 $(1,2)$ を選んでもそれが楕円曲線上の点でなければ意味がないのです。
任意の座標 $(x, y) \in \mathbb{Z}_p \times \mathbb{Z}_p$ について一つずつ式($\ref{ec1}$)の合同式を満たすかを調べるのは非常に時間がかかるので、ここでは合同式の右辺が平方剰余かどうかを調べるというアプローチについて説明します[^IPUSIRON]。

まず平方剰余を調べるために必要なオイラーの規準について説明します。

- **オイラーの規準**

    $p$ を奇素数とすると、
    合同式 $x^2 \equiv a \pmod{p}$ の整数 $a$ が $p$ を法とする平方剰余（quadratic residue）であるときの必要十分条件は次の式で表される。

    $$
    a^{\frac{p-1}{2}} \equiv 1 \pmod{p}
    \tag{5}\label{eulers_criterion1}
    $$

- **オイラーの規準** ($p \equiv 3 \pmod{4}$ のとき)

    素数 $p \equiv 3 \pmod{4}$ のとき、$p+1$ は 4 で割り切れるので、
    $a$ の $p$ を法とする平方剰余を求めるとき、式($\ref{eulers_criterion2}$)と変形できる[^3mod4]。

    $$
    \left( \pm a^{\frac{p + 1}{4}} \right)^2
    \equiv a^{\frac{p + 1}{2}}
    \equiv a^{\frac{p - 1}{2} + 1}
    \equiv a^{\frac{p - 1}{2}} \cdot a \pmod{p}
    \tag{6}\label{eulers_criterion2}
    $$

    $a$ は平方剰余で $a^{\frac{p - 1}{2}} \equiv 1 \pmod{p}$ を満たすので、
    式($\ref{eulers_criterion2}$)は $1 \cdot a \pmod{p}$ となる。
    よって $a$ の $p$ を法とする平方剰余は $\pm a^{\frac{p + 1}{4}}$ と求まる。


### 有限体上の楕円曲線の点集合を求める

有限体上の楕円曲線の点集合を求める例として、
例えば素数 $p = 11$ とする有限体 $F_{11}$ 上の楕円曲線 $y^2 = x^3 + x + 6$ について考えてみます。
素数は $p \equiv 3 \pmod{4}$ を満たしているので、楕円曲線上の点を決めるにはまず、可能性のある $x \in F_{11}$ をとって $y^2 = x^3 + x + 6$ を計算し、$y$ についての方程式 ($\ref{ec1}$) を解くことで求めることができます。
解く手順について簡単に述べると以下のようになります。

1. 整数 $x \in \mathbb{Z}_{11}$ を選ぶ
2. $z = x^3 + x + 6 \mod{11}$ を求める
3. $z$ が平方剰余であるかオイラーの規準を使って判断する
4. もし $z$ が平方剰余であれば、
    1. 平方剰余 $z$ の平方根 $y$ を次のように求める：
        $y = \pm z^{\frac{11 + 1}{4}} \;\mathrm{mod}\; 11 = \pm z^3 \;\mathrm{mod}\; 11$
    2. 有限体上の楕円曲線上の2つの点 $(x, y)$ が求まる
4. もし $z$ が平方非剰余であれば、その $x$ を含む点は楕円曲線上にないことがわかる

これをPythonで書くと下のようになります。

```python
def quadratic_residue(a, p):
    return pow(a, (p - 1) // 2, p) == 1

def f(x, p):
    return (x**3 + x + 6) % p

def calc_y(z, p):
    res = z**3 % p
    return res % p, -res % p

p = 11
for x in range(p):
    z = f(x, p)
    if quadratic_residue(z, p):
        y = calc_y(z, p)
        print('x = %2d, z = %d, QR(%2d, 11)? = True, y = %s' % (x, z, x, y))
    else:
        print('x = %2d, z = %d, QR(%2d, 11)? = False' % (x, z, x))
```

結果は以下のようになりました。

```
x =  0, z = 6, QR( 0, 11)? = False
x =  1, z = 8, QR( 1, 11)? = False
x =  2, z = 5, QR( 2, 11)? = True, y = (4, 7)
x =  3, z = 3, QR( 3, 11)? = True, y = (5, 6)
x =  4, z = 8, QR( 4, 11)? = False
x =  5, z = 4, QR( 5, 11)? = True, y = (9, 2)
x =  6, z = 8, QR( 6, 11)? = False
x =  7, z = 4, QR( 7, 11)? = True, y = (9, 2)
x =  8, z = 9, QR( 8, 11)? = True, y = (3, 8)
x =  9, z = 7, QR( 9, 11)? = False
x = 10, z = 4, QR(10, 11)? = True, y = (9, 2)
```

これにより点集合は無限遠点 $O = \infty$ を加えて、次のようになります。

$$
E(F_{11}) = \{(2,4), (2,7), (3,5), (3,6), (5,2), (5,9), (7,2), (7,9), (8,3), (8,8), (10,2), (10,9), \infty\}
$$

したがって、有限体上の楕円曲線の点集合を求めることができました。


### 楕円曲線上の点の加算

適当に $E(F_{11})$ から元を2つ選んで加算をした結果が $E(F_{11})$ に含まれていれば、
正しいかを確認することができます。
例えば、$\alpha = (2,4),\, \beta = (10,9)$ とすると
$x_1 = 2,\, y_1 = 4,\, x_2 = 10,\, y_2 = 9$ なので、楕円曲線上の加算の式に当てはめると、

$$
\begin{align}
  \lambda &= (9 - 4)(10 - 2)^{-1} \mod 11 \\
          &= 5 \times 8^{-1} \mod 11 \\
          &= 5 \times 7 \mod 11 \\
          &= 2 \\[10pt]
  x_3 &= \lambda^2 - 2 - 10 \mod 11 \\
      &= -8 \mod 11 \\
      &= 3 \\[5pt]
  y_3 &= \lambda (2 - 3) - 4 \mod 11 \\
      &= -6 \mod 11 \\
      &= 5
\end{align}
$$

よって、$\alpha + \beta = (x_3, y_3) = (3, 5) \in E(F_{11})$ となり、
$(3,5)$ は点集合 $E(F_{11})$ に含まれているので、この例においては正しいことが確認できます。

以上です。

-----

[^1]: 各点が連続していれば中間値の定理より、適切にとった区間内に少なくとも1つの解を持つので、ニュートン法や2分法で求めることができる。故に暗号系では計算困難のために離散であることが重要である。
[^DRS]: Douglas R. Stinson 著, 櫻井幸一 訳『暗号理論の基礎』共立出版 1996
[^IPUSIRON]: IPUSIRON『暗号技術のすべて』翔泳社 2018
[^Legendre]: [Legendre symbol -- Wikipedia](https://en.wikipedia.org/wiki/Legendre_symbol)
[^3mod4]: [Significance of 3mod4 in squares and square roots mod n? -- StackExchange](https://crypto.stackexchange.com/questions/20993/significance-of-3mod4-in-squares-and-square-roots-mod-n)
