---
layout:        post
title:         "高速冪剰余計算とモンゴメリ冪乗法"
menutitle:     "高速冪剰余計算とモンゴメリ冪乗法"
date:          2018-12-31
tags:          Crypto
category:      Crypto
author:        tex2e
cover:         /assets/cover7.jpg
redirect_from:
comments:      true
published:     true
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]},
    "HTML-CSS": {
      fonts: ["TeX", "Gyre-Pagella"]
    },
  });
</script>

サイドチャネル攻撃に強くて高速冪剰余計算ができる、モンゴメリの冪乗法（Montgomery Powering Ladder）について、と Python の pow 関数の使用に対する注意喚起。
$$\def\mod{ {\;\mathrm{mod}\;} }$$

RSAなどの公開鍵暗号では暗号化・復号アルゴリズムにおいて、冪剰余（Modular exponentiation）計算が発生します。
冪剰余（べき乗剰余）計算とは $a^x \mod{n}$ を求める計算のことです。
現実の暗号では巨大な素数や乱数を使うので、律儀に $a$ を $x$ 回掛け算した後に $n$ で割った余りを求めるのはとても大変です。

### Binary Exponentiation

そこで、冪剰余を効率よく計算するための方法として
**バイナリ法**（Binary Exponentiation）があります[^1] [^squaring1] [^IPUSIRON]。
例えば、$3^4$ を求めるときに、$3 \times 3 \times 3 \times 3$ と計算するよりも、
$(3^2)^2$ を計算する方が乗算の回数を少なくすることができます。
$a^4$ 以降は以下の式にすることで乗算回数を減らしていきます。

$$
\begin{align}
  a^4 &= (a^2)^2 \\
  a^5 &= a(a^2)^2 \\
  a^6 &= (a \cdot a^2)^2 \\
  a^7 &= a(a \cdot a^2)^2 \\
  a^8 &= ((a^2)^2)^2 \\
      &\;\;\vdots
\end{align}
$$

2進数にしたべきの数の i 番目の値が偶数か奇数かによって処理が変わるので、バイナリ法と呼ばれています。
以下は $a^x \mod{n}$ をバイナリ法によって計算するプログラムです。

[^1]: [Modular exponentiation (Wikipedia)](https://en.wikipedia.org/wiki/Modular_exponentiation)
[^squaring1]: [Basic method -- Exponentiation by squaring](https://en.wikipedia.org/wiki/Exponentiation_by_squaring#Basic_method)
[^IPUSIRON]: IPUSIRON『暗号技術のすべて』翔泳社 2018, p278 高速べき乗剰余計算

```python
def binary(n):
    return bin(n)[2:]

# バイナリ法
def pow_by_binary_exponentiation(a, x, n): # a^x mod n
    x = [int(b) for b in binary(x)[::-1]]
    k = len(x)
    i = k - 2
    y = a
    for i in range(k - 2, -1, -1):
        y = (y**2) % n
        if x[i] == 1:
            y = (y * a) % n
    return y
```

しかし、バイナリ法はサイドチャネル攻撃に対して弱いです。
なぜなら、プログラム内には $x$ の i 番目のビットが 1 のときだけ発生する処理があるので終了までの処理時間が変わります。
$x$ の値によって出力までの処理時間が変わるということは、サイドチャネル攻撃のタイミング攻撃によって $x$ の値が露呈する恐れがあります。
特にRSAの場合、$a^x \mod{n}$ の $x$ には秘密鍵が使われるので、バイナリ法はなおさら危険です。

### Montgomery Powering Ladder

そこで、**モンゴメリ冪乗法**（Montgomery Powering Ladder）
を使って冪剰余を計算します[^squaring2] [^2] [^3]。
モンゴメリ法はサイドチャネル攻撃に強いので、暗号化・復号アルゴリズムの一部として使えます。
以下は $a^x \mod{n}$ をモンゴメリ冪乗法によって計算するプログラムです。

[^squaring2]: [Montgomery's ladder technique -- Exponentiation by squaring](https://en.wikipedia.org/wiki/Exponentiation_by_squaring#Montgomery's_ladder_technique)
[^2]: [モンゴメリ乗算 (Wikipedia)](https://ja.wikipedia.org/wiki/%E3%83%A2%E3%83%B3%E3%82%B4%E3%83%A1%E3%83%AA%E4%B9%97%E7%AE%97)
[^3]: [The Montgomery Powering Ladder](https://cr.yp.to/bib/2003/joye-ladder.pdf)

```python
def binary(n):
    return bin(n)[2:]

# モンゴメリ冪乗法
def pow_by_montgomery_ladder(a, x, n): # a^x mod n
    x = [int(b) for b in binary(x)[::-1]]
    k = len(x)
    a1 = a
    a2 = a**2
    for i in range(k - 2, -1, -1):
        if x[i] == 0:
            a2 = (a1 * a2) % n
            a1 = (a1**2) % n
        else:
            a1 = (a1 * a2) % n
            a2 = (a2**2) % n
    return a1
```

バイナリ法とモンゴメリ冪乗法を比較するとバイナリ法の方が効率的ですが、暗号アルゴリズムにおいては $x$ の値によって処理時間が変わらないようにしているモンゴメリ冪乗法を使うべきでしょう。

### Python build-in pow() は注意が必要

Pythonのpow（冪剰余）の実装はどうなっているのか確認したくて、一応Python3のソースコードを調べて見ましたが pow(a, x, n) の具体的な実装を見つけることはできませんでした。
代わりに、Pythonの暗号ライブラリ「pycryptodome」がビルドイン関数 pow を使っているか調べたところ、ビルドイン関数 pow を使う代わりに、C言語でモンゴメリ乗算を実装してその上でモンゴメリ冪剰余を実装しているので[^monty_pow]、おそらくビルドイン関数 pow はバイナリ法か何かのサイドチャネル攻撃に弱いアルゴリズムで実装されている可能性が高いと思われます。
なので、暗号の本番環境でPythonのpow関数を使うのは、サイドチャネル攻撃の危険があると思われるので注意が必要です。

[^monty_pow]: [monty_pow -- Legrandin/pycryptodome](https://github.com/Legrandin/pycryptodome/blob/d13e46b02d/src/montgomery.c#L412-L510)
