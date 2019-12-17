---
layout:        post
title:         "微分積分I 公式一覧"
date:          2019-01-01
category:      Math
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

高専2年の数学の教科書として使用した「新 微分積分 I」(大日本図書) の公式などを備忘録としてまとめたものです。

## 1 微分法

### 1.1 関数の極限と導関数

#### 三角関数・指数関数の極限値

$$
\lim_{\theta \to 0}\frac{\sin \theta}{\theta} = 1
$$

$$
\lim_{h \to 0}\frac{e^h - 1}{h} = 1
$$

$$
\lim_{t \to 0}\left(1 + t\right)^{\frac{1}{t}} = \lim_{x \to \pm \infty} \left(1 + \frac{1}{x}\right)^x = e
$$

#### 微分係数

$$
f'(a) = \lim_{x \to a}\frac{f(x) - f(a)}{x - a} = \lim_{h \to 0}\frac{f(x+h)-f(h)}{h}
$$

#### 導関数

$$
f'(x) = \lim_{\Delta x \to 0} \frac{\Delta y}{\Delta x} = \lim_{\Delta \to 0}\frac{f(x + \Delta x) - f(x)}{\Delta x}
$$

#### 導関数の性質

$a, b, c$ は定数とする

$$
\begin{align}
(c)' &= 0 \\[3pt]
(cf)' &= cf' \\[3pt]
(f \pm g)' &= f' \pm g' \\[3pt]
(fg)' &= f'g + fg' \\[3pt]
\left(\frac{f}{g}\right)' &= \frac{f'g - fg'}{g^2} \\[3pt]
\{f(ax + b)\}' &= a f'(ax + b)
\end{align}
$$

#### 導関数の公式

$$
\begin{align}
(x^r)' &= r x^{r-1}\\[3pt]
(\sin x)' &= \cos x \\[3pt]
(\cos x)' &= -\sin x \\[3pt]
(\tan x)' &= \frac{1}{\cos^2 x} \\[3pt]
(e^x)' &= e^x \\[3pt]
(a^x)' &= a^x \log a \;\;\;(a > 0, a \ne 1)
\end{align}
$$

<br>
### 1.2 いろいろな関数の導関数

#### 合成関数の導関数

$$
\frac{dy}{dx} = \frac{dy}{du}\frac{du}{dx} = f'(u)g'(x) = f'(g(x))g'(x)
$$

#### 逆関数の導関数

$$
\{f^{-1}(x)\}' = \frac{1}{f'(y)} \;\;\;\text{(ただし $f'(y) \ne 0$)}
$$

#### 導関数の公式

$$
(x^a)' = ax^{a-1}
$$

$$
(\log x)' = \frac{1}{x} \\
(\log \lvert x\rvert)' = \frac{1}{x} \\
(\log_a x)' = \frac{1}{x\log a} \;\;\;(a > 0, a \ne 1)
$$

$$
\begin{align}
(\sin^{-1} x)' &= \frac{1}{\sqrt{1 - x^2}} \\
(\cos^{-1} x)' &= -\frac{1}{\sqrt{1 - x^2}} \\
(\tan^{-1} x)' &= \frac{1}{1 + x^2}
\end{align}
$$

#### 対数微分法

$y = f(x)$ の導関数を次の手順で求める

$$
\begin{align}
\log\lvert y\rvert &= \log\lvert f(x)\rvert
\;\;\;\text{... 両辺の絶対値の自然対数をとる} \\
\frac{1}{y} y' &= (\log\lvert f(x)\rvert)'
\;\;\;\text{... 両辺を $x$ について微分する} \\
y' &= y (\log\lvert f(x)\rvert)'
\;\;\;\text{... 両辺に $y$ をかける}
\end{align}
$$

#### 中間値の定理

関数 $f(x)$ が閉区間 $[a, b]$ で連続で $f(a) \ne f(b)$ のとき、$f(a)$ と $f(b)$ の間にある任意の値 $k$ に対して

$$
f(c) = k \;\;\;(a < c < b)
$$

を満たす点 $c$ が少なくとも1つ存在する。

<br>
## 2 微分の応用

### 2.1 関数の変動

#### 接線と法線

曲線 $y = f(x)$ 上の点 $(a, f(a))$ において

- 接線の方程式：$y - f(a) = f'(a)(x-a)$
- 法線の方程式：$y - f(a) = -\frac{1}{f'(a)}(x-a) \;\;\;(f'(a) \ne 0)$

#### 関数の増減・極限

関数 $f(x)$ が区間 $I$ で微分可能であるとき、$I$ において

- $f'(x) > 0 \;\Longrightarrow\; f(x)$ は単調増加
- $f'(x) < 0 \;\Longrightarrow\; f(x)$ は単調減少
- 関数 $f(x)$ が $x = a$ で極値をとるならば $f'(a) = 0$

#### 不定形の極限 (ロピタルの定理)

極限値が $\frac{0}{0}, \frac{\infty}{\infty}$ の不定形となるとき

$$
\lim_{x \to a}\frac{f(x)}{g(x)} = \lim_{x \to a}\frac{f'(x)}{g'(x)}
$$

### 2.2 いろいろな応用

#### 高次導関数

$$
y^{(n)} = f^{(n)}(x) = \frac{d^n y}{dx^n} = \frac{d^n}{dx^n}f(x)
$$

ライプニッツの公式 ($f, g$ は $n$ 回微分可能とする)

$$
\begin{align}
(fg)^{(n)}
&= \sum_{k=0}^{n} {}_nC_k f^{(n-k)}g^{(k)} \\
&= f^{(n)} g + {}_nC_1 f^{(n-1)}g' + \cdots + {}_nC_{n-1} f' g^{(n-1)} + f g^{(n)}
\end{align}
$$

#### 曲線の凹凸

関数 $y = f(x)$ が区間 $I$ で2回微分可能であるとき

- $I$ で $f''(x) > 0 \;\Longrightarrow\; y = f(x)$ は $I$ で下に凸
- $I$ で $f''(x) < 0 \;\Longrightarrow\; y = f(x)$ は $I$ で上に凸
- $f''(a) = 0$ となる $a$ に対し、$x < a$ と $x > a$ とで $f''(x)$ の符号が変わるならば、点 $(a, f(a))$ は変曲点

#### 媒介変数表示と微分法

$$
\begin{cases}
x = f(t) \\
y = g(t)
\end{cases}
$$

のとき

$$
\frac{dy}{dx} = \frac{\dfrac{dy}{dt}}{\dfrac{dx}{dt}} = \frac{g'(t)}{f'(t)}
\;\;\;(f'(x) \ne 0)
$$

#### 速度と加速度

$$
\begin{align}
v(t) &= \frac{dx}{dt} = x'(t) \\
\alpha(t) &= \frac{dv}{dt} = x''(t)
\end{align}
$$

<br>
## 3 積分法

### 3.1 不定積分と定積分

#### 不定積分

$$
F(x) = \int f(x) \;dx + C \;\iff\; F'(x) = f(x)
$$

#### 不定積分の公式

$$
\begin{align}
\int k \;dx &= kx + C \\[3pt]
\int x^a \;dx &= \frac{1}{a + 1} x^{a+1} + C \;\;\;(a \ne -1) \\[3pt]
\int \frac{1}{x} \;dx &= \log\lvert x\rvert + C \\[3pt]
\int e^x \;dx &= e^x + C \\[3pt]
\int \sin x \;dx &= -\cos x + C \\[3pt]
\int \cos x \;dx &=  \sin x + C \\[3pt]
\int \frac{1}{\cos^2 x} \;dx &= \tan x + C \\[3pt]
\int \frac{1}{\sin^2 x} \;dx &= -\cot x + C \\[3pt]
\int \frac{1}{\sqrt{a^2 - x^2}} \;dx &= \sin^{-1} \frac{x}{a} + C \\[3pt]
\int \frac{1}{a^2 + x^2} \;dx &= \frac{1}{a} \tan^{-1} \frac{x}{a} + C \\[3pt]
\int \frac{1}{\sqrt{x^2 + A}} \;dx &= \log\lvert x + \sqrt{x^2 + A}\rvert + C \;\;\;(A \ne 0)
\end{align}
$$

#### 積分の性質

$$
\begin{align}
\int kf(x) \;dx &= k \int f(x) \;dx \\[3pt]
\int \{f(x) \pm g(x)\} \;dx &= \int f(x)\;dx \pm \int g(x)\;dx \\[3pt]
\int f(ax + b) \;dx &= \frac{1}{a} F(ax + b) + C \;\;\;(a \ne 0) \\[3pt]
\int_a^b f(x)\;dx &= \int_a^c f(x)\;dx + \int_c^b f(x)\;dx
\end{align}
$$

#### 定積分の計算方法

$$
\int_a^b f(x) \;dx = \Big[ F(x) \Big]_a^b = F(b) - F(a)
$$

#### 偶関数・奇関数の定積分

$f(x)$ が偶関数のとき

$$
\int_{-a}^a f(x) \;dx = 2 \int_0^a f(x) \;dx
$$

$f(x)$ が奇関数のとき

$$
\int_{-a}^a f(x) \;dx = 0
$$

### 3.2 積分の計算

#### 置換積分法

不定積分

$$
\int f(\varphi(x)) \varphi'(x) \;dx = \int f(t) \;dt
\;\;\;\;\;(\varphi(x) = t,\; \varphi(x) dx = dt)
$$

定積分 ($\varphi(a) = \alpha,\; \varphi(b) = \beta$ とおく)

$$
\int_a^b f(\varphi(x)) \varphi'(x) \;dx = \int_\alpha^\beta f(t) \;dt
\;\;\;\;\;(\varphi(x) = t,\; \varphi(x) dx = dt)
$$

#### 部分積分法

不定積分

$$
\int f(x)g(x) dx = f(x)G(x) - \int f'(x) G(x) dx
$$

定積分

$$
\int_a^b f(x)g(x) dx = \Big[ f(x)G(x) \Big]_a^b - \int f'(x) G(x) dx
$$

#### 不定積分の公式

$$
\begin{align}
\int \frac{f'(x)}{f(x)} \;dx &= \log\lvert f(x)\rvert \\[3pt]
\int e^{ax} \cos bx \;dx &= \frac{e^{ax}}{a^2 + b^2} (a \cos bx + b \sin bx) \\[3pt]
\int e^{ax} \sin bx \;dx &= \frac{e^{ax}}{a^2 + b^2} (a \sin bx - b \cos bx) \\[3pt]
\int \frac{1}{x^2 - a^2} \;dx &= \frac{1}{2a} \log \left\lvert \frac{x-a}{x+a} \right\rvert \\[3pt]
\int \sqrt{a^2 - x^2} \;dx &= \frac{1}{2} \left( x\sqrt{a^2 - x^2} + a^2 \sin^{-1} \frac{x}{a} \right) \\[3pt]
\int \sqrt{x^2 + A} \;dx &= \frac{1}{2} \left( x\sqrt{x^2 + A} + A \log \left\lvert x + \sqrt{x^2 + A} \right\rvert \right) \\[3pt]
\end{align}
$$

#### 定積分の公式

$$
\int_0^{\frac{\pi}{2}} \sin^n x \;dx =
\begin{cases}
\frac{n-1}{n}\cdot{}\frac{n-3}{n-2}\cdots{}\frac{3}{4}\cdot{}\frac{1}{2}\cdot{}\frac{\pi}{2} &\;\;\;(n \text{が偶数のとき}) \\[3pt]
\frac{n-1}{n}\cdot{}\frac{n-3}{n-2}\cdots{}\frac{4}{5}\cdot{}\frac{2}{3} &\;\;\;(n \text{が奇数のとき}) \\

\end{cases}
$$

<br>
## 4 積分の応用

### 4.1 面積・曲線の長さ・体積

#### 平面図形の面積

2曲線 $y = f(x), y = g(x)$ と2直線 $x = a, x = b$ で囲まれた図形の面積は

$$
S = \int_a^b \{f(x) - g(x)\} \;dx
$$

#### 曲線の長さ

曲線 $y = f(x) \;(a \le x \le b)$ の長さ $l$ は

$$
l = \int_a^b \sqrt{1 + \{f'(x)\}^2} \;dx = \int_a^b \sqrt{1 + (y')^2} \;dx
$$

#### 立体の体積

$x$ 軸上の点 $x$ を通り、$x$ 軸に垂直な平面の切り口の面積を $S(x)$ とするとき、この立体の2平面 $x = a, x = b$ の間の部分の体積は

$$
V = \int_a^b S(x) \;dx
$$

曲線 $y = f(x)$ と $x$ 軸および2直線 $x = a, x = b$ で囲まれた図形を $x$ 軸の周りに回転してできる回転体の体積は

$$
V = \pi \int_a^b \{f(x)\}^2 \;dx = \pi \int_a^b y^2 \;dx
$$

### 4.2 いろいろな応用

#### 媒介変数表示による図形

曲線 $x = f(t), y = g(t)$ と $x$ 軸および2直線 $x = a, x = b$ で囲まれた図形の面積は

$$
S = \int_\alpha^\beta \lvert g(t)f'(t) \rvert \;dt
= \int_\alpha^\beta \left\lvert y\frac{dx}{dt} \right\rvert \;dt
\;\;\;\;\;(a = f(\alpha),\; b = f(\beta))
$$

曲線 $x = f(t), y = g(t)$ の長さ $l$ は

$$
l = \int_\alpha^\beta \sqrt{\{f'(t)\}^2 + \{g'(t)\}^2} \;dt
= \int_\alpha^\beta \sqrt{\left(\frac{dx}{dt}\right)^2 + \left(\frac{dy}{dt}\right)^2} \;dt
$$

曲線 $x = f(t), y = g(t)$ を $x$ 軸の周りに回転してできる回転体の体積 $V$ は

$$
V = \pi \int_\alpha^\beta y^2 \left\lvert \frac{dx}{dt} \right\rvert \;dt
= \pi \int_\alpha^\beta \{g(t)\}^2 \lvert f'(t) \rvert \;dt
$$

#### 極座標による図形

極座標 $(r, \theta)$ と直交座標 $(x, y)$ の関係

$$
\begin{cases}
x = r \cos \theta \\
y = r \sin \theta
\end{cases}
$$

$$
\begin{cases}
r = \sqrt{x^2 + y^2} \\
\cos\theta = \dfrac{x}{\sqrt{x^2 + y^2}},\;\; \sin\theta = \dfrac{y}{\sqrt{x^2 + y^2}}
\end{cases}
$$

曲線 $r = f(\theta)$ と2つの半直線 $\theta = \alpha, \theta = \beta$ で囲まれた図形の面積は

$$
S = \frac{1}{2} \int_\alpha^\beta \{f(\theta)\}^2 \;d\theta
= \frac{1}{2} \int_\alpha^\beta r^2 \;d\theta
$$

曲線 $r = f(\theta)$ の長さ $l$ は

$$
l = \int_\alpha^\beta \sqrt{r^2 + (r')^2} \;d\theta = \int_\alpha^\beta \sqrt{\{f(\theta)\}^2 + \{f'(\theta)\}^2} \;d\theta
$$
