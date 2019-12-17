---
layout:        post
title:         "ラプラス変換 公式一覧"
menutitle:     "応用数学 ラプラス変換 公式一覧"
date:          2019-01-04
category:      Math
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

高専4年の数学の教科書として使用した「新 応用数学」(大日本図書) のラプラス変換についての公式などを備忘録としてまとめたものです。

### 2.1 ラプラス変換の定義と性質

#### 定義

$$
F(s) = \mathcal{L}[f(t)] = \int_0^\infty e^{-st} f(t) \;dt
$$

#### いろいろな関数のラプラス変換

| 原関数 | 像関数 |
|:-----:|:-----:|
| $1$ | $\dfrac{1}{s}$
| $t$ | $\dfrac{1}{s^2}$
| $t^n$ | $\dfrac{n!}{s^{n+1}}$
| $e^{\alpha t}$ | $\dfrac{1}{s-\alpha}$
| $t^n e^{\alpha t}$ | $\dfrac{n!}{(s-\alpha)^{n+1}}$
| $\sin \omega t$ | $\dfrac{\omega}{s^2 + \omega^2}$
| $\cos \omega t$ | $\dfrac{s}{s^2 + \omega^2}$
| $e^{\alpha t} \sin \beta t$ | $\dfrac{\beta}{(s-\alpha)^2 + \beta^2}$
| $e^{\alpha t} \cos \beta t$ | $\dfrac{s-\alpha}{(s-\alpha)^2 + \beta^2}$
| $t \sin \omega t$ | $\dfrac{2 \omega s}{(s^2 + \omega^2)^2}$
| $t \cos \omega t$ | $\dfrac{s^2 - \omega^2}{(s^2 + \omega^2)^2}$
| $\sinh \omega t$ | $\dfrac{\omega}{s^2 - \omega^2}$
| $\cosh \omega t$ | $\dfrac{s}{s^2 - \omega^2}$

#### 単位ステップ関数

$$
U(t-a) =
\begin{cases}
0 & (t \le a) \\
1 & (t > a) \\
\end{cases}
$$

$$
\mathcal{L}[U(t-a)] = \frac{e^{-as}}{s} \;\;\; (a \ge 0)
$$

#### ラプラス変換の線形性、相似性、移動法則

| 原関数 | 像関数 |
|:-----:|:-----:|
| $\alpha f(t) + \beta g(t)$ | $\alpha F(s) + \beta G(s)$
| $f(at)$ | $\dfrac{1}{a} F\left(\dfrac{s}{a}\right) \;\;\; (a > 0)$
| $e^{\alpha t} f(t)$ | $F(s - \alpha)$
| $f(t - \mu) U(t - \mu)$ | $e^{-\mu s} F(s) \;\;\; (\mu > 0)$

#### 微分法則と積分法則

| 原関数 | 像関数 |
|:-----:|:-----:|
| $f'(t)$ | $sF(s) - f(0)$
| $f''(t)$ | $s^2F(s) - f(0)s - f'(0)$
| $f^{(n)}(t)$ | $s^nF(s) - f(0)s^{n-1} - f'(0)s^{n-2} - \cdots{} - f^{(n-1)}(0)$
| $t f(t)$ | $-F'(s)$
| $t^n f(t)$ | $(-1)^n F^{(n)}(s)$
| $\displaystyle\int_0^t f(\tau) \;d\tau$ | $\dfrac{1}{s} F(s)$
| $\dfrac{f(t)}{t}$ | $\displaystyle\int_s^\infty F(\sigma) \;d\sigma$


<br>
### 2.2 ラプラス変換の応用

#### 微分方程式への応用

微分方程式と初期条件 --> ラプラス変換 --> 代数方程式 --> 代数方程式の解 --> 逆ラプラス変換 --> 求める解

#### 畳み込み

$f * g$

$$
(f * g)(t) = f(t) * g(t)
= \int_0^t f(\tau) g(t-\tau) \;d\tau
= \int_0^t f(t-\tau) g(\tau) \;d\tau
$$

$$
f(t) * g(t) = g(t) * f(t)
$$

$$
\mathcal{L}[f(t) * g(t)] = \mathcal{L}[f(t)] \mathcal{L}[g(t)]
$$

#### 線形システム

$$
y'' + ay' + by = x(t),\;\; y(0) = 0,\;\; y'(0) = 0
$$

において、入力 $x(t)$ から出力 $y(t)$ への対応を線形システムという。

$$
H(s) = \dfrac{1}{s^2 + as + b}
$$
を伝達関数といい、
$$
h(t) = \mathcal{L}^{-1}[H(s)]
$$
として

$$
y(t) = h(t) * x(t)
= \int_0^t h(\tau) x(t - \tau) \;d\tau
= \int_0^t h(t - \tau) x(\tau) \;d\tau
$$

#### デルタ関数

$$
\delta(t) = \lim_{\varepsilon \to +0} \varphi_\varepsilon(t)
$$

$$
\mathcal{L}[ \delta(t) ] = 1 \\
\int_0^\infty \delta(t) \;dt = 1 \\
t > 0 のとき \delta(t) = 0 \\
f(t) * \delta(t) = \delta(t) * f(t) = f(t)
$$

$$
h(t) = \mathcal{L}^{-1}\left[ \dfrac{1}{s^2 + as + b} \right]
$$
は微分方程式

$$
y'' + ay' + by = \delta(t),\;\; y(0) = 0,\;\; y'(0) = 0
$$

の解である。
