---
layout:        post
title:         "誕生日攻撃 (Birthday Attack)"
menutitle:     "誕生日攻撃 (Birthday Attack)"
date:          2019-06-12
tags:          Crypto
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

誕生日攻撃はハッシュ関数の衝突を見つけるときに出てくるものです。
誕生日のパラドックスとは「何人集まれば、その中に誕生日が同一の2人 (以上) がいる確率が、50%を超えるか?」という問題から生じるパラドックスのことです。
何人集まれば...という問題を考える前に、まずサイコロの出た目の衝突確率について考えた後、衝突する確率の一般式を求めます。

### サイコロの例

サイコロは1〜6の目があるので、集合 $$Z = \{1,2,3,4,5,6\}$$、
要素数 $$n = \left| Z \right| = 6$$ となります。
サイコロを1回、2回と振ったときに、それぞれが違う目となる確率は次のように求まります。

| | 衝突しない確率 $p$ | 確率 [%]
|---|---|
| 1回目と2回目が異なる確率 | $\frac{5}{6}$ | $83.3$
| 1回目と2回目と3回目が異なる確率 | $\frac{5}{6} \times \frac{4}{6}$ | $55.6$
| 1回目〜4回目が異なる確率 | $\frac{5}{6} \times \frac{4}{6} \times \frac{3}{6}$ | $27.8$
| 1回目〜5回目が異なる確率 | $\frac{5}{6} \times \frac{4}{6} \times \frac{3}{6} \times \frac{2}{6}$ | $\phantom{0}9.25$
| 1回目〜6回目が異なる確率 | $\frac{5}{6} \times \frac{4}{6} \times \cdots \times \frac{1}{6}$ | $\phantom{0}1.54$

逆に、それぞれの目が衝突する確率は、上の反転なので次のように求まります。

$$
  (\text{衝突する確率}\, \epsilon) = 1 - (\text{衝突しない確率}\, p)
$$

### 一般式

次に一般化した式について考えます。一般に、$i$ 回目に試行した結果を $z_i$、試行回数を $k$、集合 $Z$ の大きさを
$$n = \left| Z \right|$$ とすると、衝突しない確率は次のように書くことができます。

| | 衝突しない確率 $p$
|---|---|
| $z_1$ と $z_2$ が異なる確率 | $(1 - \frac{1}{n})$
| $z_1$ と $z_2$ と $z_3$ が異なる確率 | $(1 - \frac{1}{n})(1 - \frac{2}{n})$
| $z_1$ と ... と $z_k$ が異なる確率 | $(1 - \frac{1}{n})(1 - \frac{2}{n})\cdots(1 - \frac{k-1}{n})$

結局のところ、衝突しない確率 $p$ は次式となります。

$$
p =
(1 - \frac{1}{n})(1 - \frac{2}{n})\cdots(1 - \frac{k-1}{n}) = \prod_{i=1}^{k-1} (1 - \frac{i}{n})
$$

ここで、ネイピア数のテイラー展開を使った式変形を行います。
ネイピア数のテイラー展開は次式で表されます。
もし $x$ が小さい実数なら、一番次数の小さい $x$ を除く全ての次数 ($x^2, x^3, ...$) を無視することができます。つまり、$x$ が小さい実数なら次のように近似して書くことができます。

$$
\begin{align}
e^{-x} &= 1 - x + \dfrac{x^2}{2!} - \dfrac{x^3}{3!} \cdots \\[5pt]
e^{-x} &\approx 1 - x
\end{align}
$$

これを踏まえて、衝突しない確率 $p$ の式を変形します。
$n$ は大きい数[^1]なので $\frac{1}{n}$ は小さくなり、ネイピア数のテイラー展開を当てはめることができます。
さらに、等差数列の和（自然数の和 $\frac{n(n-1)}{2}$）の公式を使えば、総乗の記号を消すことができます。

$$
\begin{align}
p =
\prod_{i=1}^{k-1} (1 - \frac{i}{n})
&\approx \prod_{i=1}^{k-1} e^\frac{-i}{n} \\
&= e^\frac{-k(k-1)}{2n}
\end{align}
$$

ここまでは衝突しない確率 $p$ についてでしたが、逆に衝突する確率 $\epsilon$ は次式となります。

$$
\epsilon = 1 - e^\frac{-k(k-1)}{2n}
$$

試行回数 $k$ についての式に変形すると、次のようになります。

$$
\begin{align}
e^\frac{-k(k-1)}{2n} &\approx 1 - \epsilon \\
\frac{-k(k-1)}{2n} &\approx \ln (1-\epsilon) \\
k^2 - k &\approx -2n \ln (1-\epsilon) \\
k^2 - k &\approx 2n \ln \frac{1}{1-\epsilon} \\
k &\approx \sqrt{2n \ln \frac{1}{1-\epsilon}}
\end{align}
$$

ただし途中で、$k$ は大きい数[^2]と見なして $k^2 - k$ から $-k$ を無視しています。
これで、試行回数 $k$ の近似式を導出することができました。

冒頭の誕生日のパラドックス「何人集まれば、その中に誕生日が同一の2人 (以上) がいる確率が、50%を超えるか?」について考えると、一年は365日あるので集合のサイズ $n=365$、衝突する確率 $\epsilon = 0.5$ として、式を計算すると次のようになります。

$$
\begin{align}
k &\approx \sqrt{2n \ln \frac{1}{1-0.5}} \\
&\approx \sqrt{2n \ln 2} \\
&\approx 1.1774 \sqrt{n} \\
&\approx 22.5
\end{align}
$$

よって、23人を集めれば、誕生日が同じになる人が少なくとも確率 $0.5$ で存在することになります。


### ハッシュ関数の衝突

試行回数の近似式 $k \approx 1.1774 \sqrt{n}$ を簡略化して $k \approx \sqrt{n}$ と書くことにします。

例えば、ハッシュ関数の出力が **40bit** で、ハッシュ関数の写像先の集合の大きさが $n = 2^{40}$ だとします。
このとき、約 $2^{20}$ (約100万) 個のハッシュを生成すれば、確率 $0.5$ で衝突が起こります。

100万個のハッシュを計算するのは不可能な話ではないと思います。
よって、衝突が起きないようにするために、ハッシュ関数の出力は **256bit** 以上のものを使うことが推奨されます（2019/6/12 現在）。

---

[^1]: ハッシュ関数 SHA256 を使えば $n = 2^{256}$ となり、十分大きな数である
[^2]: ハッシュ関数の写像先の集合の要素数 $n$ が多いとき、試行回数 $k$ も十分大きくなると見積もることができる