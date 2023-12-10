---
layout:        post
title:         "πに関するガウス=ルジャンドルのアルゴリズム"
date:          2018-05-01
category:      Math
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         true
photoswipe:    false
# sitemap: false
# feed:    false
---


円周率の計算では、ガウス=ルジャンドルのアルゴリズムと呼ばれるアルゴリズムを使うことができます。このアルゴリズムは反復計算をすることで精度を上げていくタイプのアルゴリズムで、非常に収束が速いことで知られています。まず、次のようにパラメータの初期値を設定します。ここで使う $\sqrt{2}$ は、得ようとしている $\pi$ よりも十分大きな桁数で計算できていなければいけないです。

$$
\begin{aligned}
a_0 &= 1 \\
b_0 &= 1/\sqrt{2} \\
t_0 &= 1/4 \\
p_0 &= 1
\end{aligned}
$$

次の計算式に従って、$a_n$ と $b_n$ が希望の桁数になるまで以下の反復を繰り返します。

$$
\begin{aligned}
a_{n+1} &= (a_n + b_n) / 2 \\
b_{n+1} &= \sqrt{a_n b_n} \\
t_{n+1} &= t_n - p_n (a_n - a_{n+1})^2 \\
p_{n+1} &= 2 p_n
\end{aligned}
$$

その時点での $a_n$ と $b_n$ と $t_n$ を使って $\pi$ は次の式で近似することができます。

$$
\pi ~= (a_n + b_n)^2 / 4 t_n
$$

求めたい円周率の桁数まで計算できたら反復処理を終了します。

以上です
