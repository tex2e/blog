---
layout:        post
title:         "微分積分II 公式一覧"
date:          2019-01-02
category:      Math
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

高専3年の数学の教科書として使用した「新 微分積分 II」(大日本図書) の公式などを備忘録としてまとめたものです。

## 1 関数の展開

#### 多項式による近似

関数 $f(x)$ が定数 $a$ を含む区間で $n$ 回微分可能なとき

$$
f(x) = f(a) + f'(a)(x - a) + \frac{f''(a)}{2!}(x - a)^2 + \cdots{}
+ \frac{f^{(n)}(a)}{n!}(x - a)^n + \mathcal{O}((x-a)^n) \\[3pt]
(\mathcal{O} \text{はランダウの記号})
$$

#### 級数の収束

級数 $\sum_{n=1}^\infty a_n$ が収束すれば、$\lim_{n\to\infty} a_n = 0$

初項 $a$、公比 $r$ の等比級数は $\lvert r\rvert < 1$ のとき収束して、その和は

$$
a + ar + ar^2 + \cdots{} + ar^{n-1} + \cdots = \frac{a}{1 - r}
$$

#### マクローリン展開とテイラー展開

関数 $f(x)$ のマクローリン展開は

$$
f(x) = f(0) + f'(0)x + \frac{f''(0)}{2!}x^2 + \cdots{} + \frac{f^{(n)}(0)}{n!}x^n + \cdots{}
$$

$x = a$ における関数 $f(x)$ のテイラー展開は

$$
f(x) = f(a) + f'(a)(x-a) + \frac{f''(a)}{2!}(x-a)^2 + \cdots{} + \frac{f^{(n)}(a)}{n!}(x-a)^n + \cdots{}
$$

#### オイラーの公式

$$
e^{ix} = \cos x + i \sin x
$$

<br>
## 2 偏微分

### 2.1 偏微分法

#### 偏微分係数

$$
f_x(a,b) = \lim_{x \to a}\frac{f(x,b) - f(a,b)}{x-a} = \lim_{h \to 0}\frac{f(a+h,b) - f(a,b)}{h} \\[3pt]
f_y(a,b) = \lim_{x \to b}\frac{f(a,y) - f(a,b)}{y-a} = \lim_{h \to 0}\frac{f(a,b+k) - f(a,b)}{k}
$$

#### 偏導関数

$$
f_x(a,b) = \lim_{X \to x}\frac{f(X,y) - f(x,y)}{X-x} = \lim_{\Delta x \to 0}\frac{f(x + \Delta x, y) - f(x,y)}{\Delta x} \\[3pt]
f_y(a,b) = \lim_{Y \to y}\frac{f(x,Y) - f(x,y)}{Y-y} = \lim_{\Delta y \to 0}\frac{f(x, y + \Delta y) - f(x,y)}{\Delta y}
$$

#### 全微分

$z = f(x, y)$ のとき

$$
\begin{align}
dz &= f_x dx + f_y dy \\
dz &= \frac{\partial z}{\partial x} dx + \frac{\partial z}{\partial y} dy
\end{align}
$$

#### 接平面の方程式

曲面 $z = f(x,y)$ 上の点 $(a, b, f(a,b))$ における接平面の方程式は

$$
z - f(a,b) = f_x(a,b)(x - a) + f_y(a,b)(y - b)
$$

#### 合成関数の微分法

$z = f(x,y), x = x(t), y = y(t)$ のとき

$$
\frac{dz}{dt} = \frac{\partial z}{\partial x}\frac{dx}{dt} + \frac{\partial z}{\partial y}\frac{dy}{dt}
$$

$z = f(x,y), x = x(u,v), y = y(u,v)$ のとき

$$
\frac{dz}{du} = \frac{\partial z}{\partial x}\frac{\partial x}{\partial u} + \frac{\partial z}{\partial y}\frac{\partial y}{\partial u}, \;\;
\frac{dz}{dv} = \frac{\partial z}{\partial x}\frac{\partial x}{\partial v} + \frac{\partial z}{\partial y}\frac{\partial y}{\partial v}
$$

### 2.2 偏微分の応用

#### 高次偏導関数

$$
\frac{\partial f_x}{\partial x} = f_{xx},\;\;
\frac{\partial f_x}{\partial y} = f_{xy},\;\;
\frac{\partial f_y}{\partial x} = f_{yx},\;\;
\frac{\partial f_y}{\partial y} = f_{yy}
$$

$$
f_{xy} \;と\; f_{yx} \;が存在して共に連続\; \Longrightarrow \; f_{xy} = f_{yx}
$$

#### 極大・極小

点 $(a,b)$ で極値をとるための必要条件は $f_x(a,b)=0,\; f_y(a,b)=0$

このとき $$H = f_{xx}(a,b)f_{yy}(a,b) - \{f_{xy}(a,b)\}^2$$ とおく。

- $H > 0$ のとき

    $f_{xx}(a,b) > 0 \;\Longrightarrow\;$ 点 $(a,b)$ で極小

    $f_{xx}(a,b) < 0 \;\Longrightarrow\;$ 点 $(a,b)$ で極大

- $H < 0$ のとき

    点 $(a,b)$ で極値をとらない

#### 陰関数の微分法

$f(x,y) = 0$ のとき

$$
\frac{dy}{dx} = -\frac{f_x}{f_y} \;\;\;(f_y \ne 0)
$$

$f(x,y,z) = 0$ のとき

$$
\frac{\partial z}{\partial x} = -\frac{f_x}{f_z},\;\;\;
\frac{\partial z}{\partial y} = -\frac{f_y}{f_z} \;\;\;(f_z \ne 0)
$$

#### 接線と接平面

曲線 $f(x,y) = 0$ 上の点 $(a,b)$ における接線の方程式は

$$
f_x(a,b)(x-a) + f_y(a,b)(y-b) = 0
$$

曲線 $f(x,y,z) = 0$ 上の点 $(a,b,c)$ における接平面の方程式は

$$
f_x(a,b,c)(x-a) + f_y(a,b,c)(y-b) + f_z(a,b,c)(z-c) = 0
$$

#### 条件付き極値

条件 $\varphi(x,y) = 0$ のもとで、$z = f(x,y)$ の極値をとる点において

$$
\frac{f_x}{\varphi_x} = \frac{f_y}{\varphi_y}
$$

$$
f_x = \lambda \varphi_x,\;\; f_y = \lambda \varphi_y \;\;\;(\lambda は定数)
$$

#### 包絡線

$\alpha$ をパラメータとする曲線群 $f(x,y,\alpha) = 0$ の包絡線上の点において

$$
f(x,y,\alpha) = 0, \;\; f_\alpha(x,y,\alpha) = 0
$$

<br>
## 3. 重積分

### 3.1. 2重積分

#### 2重積分の定義

$$
\iint_D f(x,y) \;dxdy =
\lim_{\Delta x_i \to 0 \\ \Delta y_j \to 0} \sum_{j=1}^n\sum_{i=1}^m f(\xi_{ij}, \eta_{ij}) \Delta x_i \Delta y_j
$$

#### 2重積分の性質

$$
\left\lvert \iint_D f(x,y) \;dxdy \right\rvert \le \iint_D \lvert f(x,y) \rvert \;dxdy
$$

$a, b$ は定数

$$
\iint_D (af + bg) \;dxdy = a \iint_D f \;dxdy + b \iint_D g \;dxdy
$$

$D$ を2つの領域 $D_1, D_2$ に分けるとき

$$
\iint_D f \;dxdy = \iint_{D_1} f \;dxdy + \iint_{D_2} f \;dxdy
$$

#### 2重積分の計算 (累次積分)

$$D = \{ (x,y) \;\vert\; a \le x \le b, \varphi_1(x) \le y \le \varphi_2(x) \}$$ のとき

$$
\iint_D f(x,y) \;dxdy = \int_a^b \left\{ \int_{\varphi_1(x)}^{\varphi_2(x)} f(x,y) \;dy \right\} \;dx
$$

$$D = \{ (x,y) \;\vert\; c \le y \le d, \psi_1(y) \le y \le \psi_2(y) \}$$ のとき

$$
\iint_D f(x,y) \;dxdy = \int_c^d \left\{ \int_{\psi_1(y)}^{\psi_2(y)} f(x,y) \;dx \right\} \;dy
$$

### 3.2 変数の変換と重積分

#### 極座標による2重積分

$x = r\cos\theta,\; y = r\sin\theta$ とすると

$$
\iint_D f(x,y) \;dxdy = \iint_D f(r\cos\theta, r\sin\theta) r \;drd\theta
$$

#### 2重積分の変数変換

$x = \varphi(u,v),\; y = \psi(u,v)$ のとき

$$
\iint_D f(x,y) \;dxdy = \iint_D f(\varphi(u,v), \psi(u,v)) \left\lvert \frac{\partial (x,y)}{\partial (u,v)} \right\lvert \;dudv \\[4pt]
ここで\; \frac{\partial (x,y)}{\partial (u,v)} = J(u,v) =
\begin{vmatrix}
\varphi_u & \varphi_v \\
\psi_u    & \psi_v \\
\end{vmatrix}
\;はヤコビアン
$$

#### 広義積分の例

$\varepsilon \to +0$ のとき、領域 $D_\varepsilon$ が領域 $D$ に限りなく近くならば

$$
\iint_D f(x,y) \;dxdy = \lim_{\varepsilon \to +0} \iint_{D_\varepsilon} f(x,y) \;dxdy
$$

$a \to \infty$ のとき、領域 $D_a$ が領域 $D$ に限りなく近くならば

$$
\iint_D f(x,y) \;dxdy = \lim_{a \to \infty} \iint_{D_a} f(x,y) \;dxdy
$$

範囲が無限大までの例

$$
\int_0^\infty e^{-x^2} \;dx = \frac{\sqrt{\pi}}{2}
$$

#### 曲面積

曲面 $z = f(x,y)$ の領域 $D$ に対応する部分の面積は

$$
\iint_D \sqrt{
\left( \frac{\partial z}{\partial x} \right)^2 +
\left( \frac{\partial z}{\partial y} \right)^2 + 1} \;dxdy
$$

#### 平均と重心

領域 $D$ における $f(x,y)$ の平均は

$$
\dfrac{\iint_D f(x,y)\;dxdy}{\iint_D \;dxdy}
$$

図形 $D$ の重心 $\mathrm{G}(\bar{x}, \bar{y})$ の各座標は

$$
\bar{x} = \dfrac{\iint_D x \;dxdy}{\iint_D \;dxdy},\;\;\; \bar{y} = \dfrac{\iint_D y \;dxdy}{\iint_D \;dxdy}
$$

<br>
## 4. 微分方程式

### 4.1. 1階微分方程式

#### 微分方程式の解

- 解 : 微分方程式を満たす関数
- 解曲線 : 微分方程式の解が表す曲線
- 一般解 : 微分方程式の階数と同じ個数の任意定数を含む解
- 特殊解 : 一般解における任意定数に特別の値を代入して得られる解
- 特異解 : 一般解における任意定数にどんな値を代入しても得られない解

#### 変数分離形

$$
\frac{dx}{dt} = f(t)g(t)
$$

$\dfrac{1}{g(x)} \frac{dx}{dt} = f(t)$ の両辺を $t$ について積分すると

$$
\int \frac{1}{g(x)} \;dx = \int f(t) dt
$$

#### 同次形

$$
\frac{dx}{dt} = f\left(\frac{x}{t}\right)
$$

$u = \dfrac{x}{t}$ とおくと $x = tu,\; \dfrac{dx}{dt} = u + t\dfrac{du}{dt}$ だから、以下の変数分離形となる

$$
t\frac{du}{dt} = f(u) - u
$$

#### 1階線形微分方程式

$$
\frac{dx}{dt} + P(t)x = Q(t)
$$

1. $\dfrac{dx}{dt} + P(t)x = 0$ の一般解 $x = Cx_1$ ($C$ は任意定数) を求める
2. $x = ux_1$ ($u$ は $t$ の関数) が $\dfrac{dx}{dt} + P(t)x = Q(t)$ を満たすように関数 $u$ を定める (定数変化法)

### 4.2. 2階微分方程式

#### 線形独立

2つの関数 $u(t), v(t)$ と定数 $c_1, c_2$ について

$$
c_1 u(t) + c_2 v(t) \; が恒等的に 0 である \;\iff\; c_1 = c_2 = 0
$$

が成り立つとき、$u(t)$ と $v(t)$ は線形独立である。

$W(u,v)$ が恒等的には $0$ でない $\;\Longrightarrow\; u(t), v(t)$ は線形独立

$$
W(u,v) =
\begin{vmatrix}
u & v \\[2pt]
\dfrac{du}{dt} & \dfrac{dv}{dt}
\end{vmatrix}
\;\;\;(ロンスキアン)
$$

#### 2階斉次線形微分方程式

$$
\frac{d^2 x}{dt^2} + P(t)\frac{dx}{dt} + Q(t)x = 0
$$

$u_1, u_2$ が線型独立な解のとき、一般解は $C_1 u_1 + C_2 u_2$ である。

#### 2階非斉次線形微分方程式

$$
L(x) = \frac{d^2 x}{dt^2} + P(t)\frac{dx}{dt} + Q(t)x = R(t)
$$

$x_1$ が1つの解、$u$ が $L(x) = 0$ の一般解のとき、一般解は $x_1 + u$ である。

#### 定数係数斉次線形微分方程式

$a, b$ は定数

$$
\frac{d^2 x}{dt^2} + a\frac{dx}{dt} + bx = 0
$$

特性方程式 $\lambda^2 + a\lambda + b = 0$ の解に対応して、一般解は次のようになる。

- 異なる2つの実数解 $\alpha, \beta$ をもつとき

    $$x = C_1 e^{\alpha t} + C_2 e^{\beta t}$$

- 2重解 $\alpha$ をもつとき

    $$x = (C_1 + C_2t) e^{\alpha t}$$

- 異なる2つの虚数解 $p\pm qi$ をもつとき

    $$x = e^{pt} (C_1 \cos qt + C_2 \sin qt)$$

#### 定数係数非斉次線形微分方程式

$$
\frac{d^2 x}{dt^2} + a\frac{dx}{dt} + bx = R(t)
$$

1つの解を見つけるために、次の表のように解を予想する。

| $R(t)$ | 斉次の場合の一般解 | 予想する解の形
|--------|-------|-------|
| $n$次多項式 | -- | $n$次多項式 ($b \ne 0$ のとき)
| $n$次多項式 | -- | $n+1$次多項式 ($a \ne 0, b = 0$ のとき)
| 指数関数 $e^{\alpha t}$ | $e^{\alpha t}$ を含まない | $x = A\,e^{\alpha t}$
| 指数関数 $e^{\alpha t}$ | $e^{\alpha t}$ を含む | $x = A\,t\,e^{\alpha t}$
| 三角関数 $\cos \alpha t$ または $\sin \alpha t$ | $R(t)$ を含まない | $x = A\cos\alpha t + B\sin\alpha t$
| 三角関数 $\cos \alpha t$ または $\sin \alpha t$ | $R(t)$ を含まない | $x = t(A\cos\alpha t + B\sin\alpha t)$
