---
layout:        post
title:         "ナップザック暗号"
date:          2020-03-23
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
# sitemap: false
# draft:   true
---

ナップザック暗号 (Merkle-Hellman暗号) はNP完全問題のナップザック問題を利用した公開鍵暗号の一つです。
ナップザック暗号は発表後にShamirによって解読手法が発見されたので、現代暗号として用いられることはありませんが、公開鍵暗号の構成を理解するのに上で示唆するところが多い暗号です。

- **ナップザック問題**

    $n$ 個の物があるとき、それぞれの物の重さ $w_i$, 価値 $v_i$ として、ナップザックの上限 $S$ とすると、条件を満たす $$X = \{x_1, ..., x_n\} \subset \{0,1\}^n$$ の組み合わせを求める

    $$\max\; \sum_{i=1}^n v_i x_i \;\;\;\; \text{s.t.}\; \sum_{i=1}^n w_i x_i \le S$$

- **部分和問題** (ナップサック問題の特別なインスタンス)

    与えられた $n$ 個の整数 $w_1$,...,$w_n$ から部分集合をうまく選んで、その集合内の数の和が与えられた数 $S$ に等しくなるようにできるかどうかを判定する問題

    $$\sum_{i=1}^n w_i = S$$

例）荷物の集合 $W$ と、荷物に入れる(1)入れない(0)を表す集合 $X$ とするとき、部分和 $C$ は次のように計算できます。

$$
\begin{aligned}
W &= \{5, 3, 8, 7, 10, 13\} \\
X &= \{0, 1, 0, 1, 1, 0\} \\[5pt]
C &= 5 \cdot{} 0 + 3 \cdot{} 1 + 8 \cdot{} 0 + 7 \cdot{} 1 + 10 \cdot{} 1 + 13 \cdot{} 0 \\
  &= 20
\end{aligned}
$$

なお、$C=20$ になる組み合わせには $$X = \{0, 0, 0, 1, 1, 1\}$$ もあり、$X$ が一意に求まらないため、簡単に解くことができず、暗号に適さないです。
そこで、適切な $W$ を生成するアルゴリズムが必要となります。

- **やさしいナップザック問題**

    超増加数列 (自身の数字が、自身より前にある全要素の合計よりも大きくなる数列) とした荷物の集合 $W'$ を使った、部分和問題 (ナップザック問題) のこと。

    $$\sum_{i=1}^n w_i = S \;\;\;\; \left(w_i > \sum_{j=1}^{i-1} w_j'\right)$$

例）超増加数列である荷物の集合 $W'$ の例には次のものがあります。

$$
W' = \{1, 3, 6, 12, 23\}
$$

超増加数列を使うことで、荷物の組み合わせを表す $X$ は一意に求まるため、簡単に解くことができ、暗号として利用できるようになります。

- **ナップザック暗号**

    超増加数列を荷物の集合 $$W' = \{w_1', ..., w_n'\}$$ とするやさしいナップザック問題を元に、見かけ上難しいナップザック問題に変換することで、公開鍵を作る方法です。

    1. $$\displaystyle u > \sum_{i=1}^n w_i'$$ となる $u$ をランダムに選ぶ。
    2. $u$ と互いに素となる $v$ をランダムに選ぶ
    3. $u$ を法とする $v$ の逆元 $v^{-1}$ を求める（これは、復号するための**落とし戸(Trapdoor)**であり、秘密鍵になる）
    4. $w_i = v \cdot{} w_i' \pmod{u}$ を求める。つまり、超増加数列 $W'$ から、非超増加数列 $W$ に変換する。
    5. 平文 $$X \subset \{0,1\}^n$$ から暗号文 $C = \sum_{i_1}^n w_i x_i$ を求める。

        - 公開鍵 : $W$
        - 秘密鍵 : $v^{-1}, u, A'$

    6. 非超増加数列 $W$ からは、部分和問題 (ナップザック問題) を解くのが難しいので、平文を求められない (注 : 解読方法はすでに存在する)
    7. 秘密鍵 $v^{-1}$ を知っている人は、$w_i' = v^{-1} \cdot{} w_i \pmod{u}$ を計算することで、非超増加数列 $W$ から、超増加数列 $W'$ に変換する。
    8. やさしいナップザック問題より、平文 $X$ は一意にもとまるため、復号できる。

### 安全性

ナップザック暗号 (1978) はNP完全問題のナップザック問題を利用しているにもかかわらず、Shamir によって解読されました (1984)。
一見するとNP完全問題を使えば強そうですが、実際には特殊なナップザックベクトル（つまり、超増加数列）を用いているために、NP完全問題にはなっていません[^1]。
また、NP完全性は「最悪時」の困難性に関する概念であり、暗号として利用する場合は「平均時」や「ほとんどすべて」の困難性が必要となります[^2]。
ナップザック問題は「平均時」に簡単な問題のようであるため、現代暗号には適さないのです。

- 正しい：現代暗号はある種の問題が計算複雑性の意味で難しいという仮定に依拠している
- 誤り　：現代暗号はNP完全問題を元にして作られている

---

[^1]: 岡本英司『暗号理論入門 第2版』共立出版株式会社, 2002
[^2]: 岡本吉央『[計算複雑性にまつわる 10 の誤解](http://dopal.cs.uec.ac.jp/okamotoy/PDF/2013/complexity10confusions.pdf)』2013