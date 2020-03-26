---
layout:        post
title:         "化学反応速度 (1次反応・2次反応)"
date:          2019-06-11
category:      Misc
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         true
---

反応速度式とは、温度、圧力などを一定にして濃度を変えた場合の反応速度の変化を濃度の関数として表した式のことです。
ここでは、1次反応と2次反応についての微分方程式の解 (積分形速度則) と半減期の導出方法について説明します。
$$\gdef\A{\mathrm{[A]}}$$

### 1次反応

1次反応 $A \xrightarrow{k} P$ における反応速度は次のように書くことができます。
ただし、$\A$ は反応物の濃度、$\A_0$は初期状態の濃度、$k$は反応速度定数を表します。

$$
V = -\dfrac{d\A}{dt} = k\A
$$

微分方程式を解くと、次のようになります。

$$
\begin{aligned}
  -\dfrac{d\A}{dt} &= k\A \\
  \dfrac{d\A}{\A} &= -k\,dt \\
  \int_{\A_0}^{\A} \dfrac{1}{\A} d\A &= - k \int_0^t dt \\
  \ln\A - \ln\A_0 &= -kt \\
  \ln\A &= \ln\A_0 - kt
\end{aligned}
$$

また、半減期は $\A = \frac{1}{2}\A_0$ として計算すると次のようになります。

$$
\begin{aligned}
  \ln \dfrac{1}{2} \A_0 &= \ln \A_0 - kt \\
  kt &= \ln \A_0 - \ln \dfrac{1}{2} \A_0 \\
  kt &= \ln \dfrac{\A_0}{\dfrac{1}{2} \A_0} \\
  kt &= \ln 2 \\
  t  &= \dfrac{\ln 2}{k}
\end{aligned}
$$

よって、1次反応では次のことが言えます。

- 積分形速度則 : $\ln\A = \ln\A_0 - kt$
- 半減期 : $t = \dfrac{\ln 2}{k}$

<br>

### 2次反応

2次反応 $A + A \xrightarrow{k} P$ における反応速度は次のように書くことができます。
ただし、$\A$ は反応物の濃度、$\A_0$は初期状態の濃度、$k$は反応速度定数を表します。

$$
V = -\dfrac{d\A}{dt} = k\A^2
$$

微分方程式を解くと、次のようになります。

$$
\begin{aligned}
  -\dfrac{d\A}{dt} &= k\A^2 \\
  -\dfrac{d\A}{\A^2} &= k\,dt \\
  -\int_{\A_0}^{\A} \dfrac{1}{\A^2} d\A &= k \int_0^t dt \\
  \dfrac{1}{\A} - \dfrac{1}{\A_0} &= kt \\
  \dfrac{1}{\A} &= kt + \dfrac{1}{\A_0} \\
  \A &= \dfrac{1}{kt + \frac{1}{\A_0}} \\
  \A &= \dfrac{\A_0}{kt\A_0 + 1}
\end{aligned}
$$

また、半減期は $\A = \frac{1}{2}\A_0$ として計算すると次のようになります。

$$
\begin{aligned}
  \frac{1}{2} \A_0 &= \dfrac{\A_0}{kt\A_0 + 1} \\
  kt\A_0 + 1 &= 2 \\
  kt\A_0 &= 1 \\
  t &= \dfrac{1}{k \A_0}
\end{aligned}
$$

よって、2次反応では次のことが言えます。

- 積分形速度則 : $\A = \dfrac{\A_0}{kt\A_0 + 1}$
- 半減期 : $t = \dfrac{1}{k \A_0}$


補足ですが、1次反応の半減期は初濃度 $\A_0$ に依存しませんが、2次反応の半減期は初濃度 $\A_0$ に依存することが上式から確認できます。
