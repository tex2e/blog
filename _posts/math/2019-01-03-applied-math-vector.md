---
layout:        post
title:         "ベクトル解析 公式一覧"
menutitle:     "応用数学 ベクトル解析 公式一覧"
date:          2019-01-03
category:      Math
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         true
syntaxhighlight: false
# sitemap: false
# draft:   true
---

高専4年の数学の教科書として使用した「新 応用数学」(大日本図書) のベクトル解析についての公式などを備忘録としてまとめたものです。

### 1.1 ベクトル関数

#### 空間ベクトル

$$
\begin{aligned}
\vec{a} \pm \vec{b} &= (a_x \pm b_x, a_y \pm b_y, a_z \pm b_z) \\[3pt]
m\vec{a} &= (ma_x, ma_y, ma_z) \\[3pt]
\lvert \vec{a} \rvert &= \sqrt{a_x^2 + a_y^2 + a_z^2}
\end{aligned}
$$

#### 内積

$$
\begin{aligned}
\vec{a}\cdot{}\vec{b}
&= \lvert \vec{a} \rvert \lvert \vec{b} \rvert \cos\theta \\
&= a_x b_x + a_y b_y + a_z b_z \;\;\;(\theta \;\text{は}\; \vec{a} \;\text{と}\; \vec{b} \;\text{がなす角})
\end{aligned}
$$

$$
\vec{a}\cdot{}\vec{a} = \lvert \vec{a} \rvert^2
$$

$$
\vec{a} \perp \vec{b} \;\iff\; \vec{a} \cdot{} \vec{b} = 0
\;\;\;(\vec{a} \ne \vec{0}, \vec{b} \ne \vec{0})
$$

#### 外積

$$
\begin{aligned}
\vec{a} \times \vec{b}
&= (a_y b_z - a_z b_y)\vec{i} + (a_z b_x - a_x b_z)\vec{j} + (a_x b_y - a_y b_x)\vec{k} \\[2pt]
&=
\begin{vmatrix}
\vec{i} & \vec{j} & \vec{k} \\
a_x & a_y & a_z \\
b_x & b_y & b_z
\end{vmatrix}
\end{aligned}
$$

$$
|\vec{a} \times \vec{b}| = |\vec{a}| |\vec{b}| \sin\theta \;\;\;(0 \le \theta \le \pi)
$$

$$
\vec{b} \times \vec{a} = -(\vec{a} \times \vec{b})
$$

$$
\vec{a} \parallel \vec{b} \;\iff\; \vec{a} \times \vec{b} = \vec{0}
\;\;\;(\vec{a} \ne \vec{0}, \vec{b} \ne \vec{0})
$$

#### ベクトル関数

$\vec{a}(t), \vec{b}(t)$ は $t$ のベクトル関数、$u(t)$ は $t$ の関数とするとき

$$
\vec{a}'(t) = \frac{d\vec{a}}{dt}
= \lim_{\Delta t \to 0} \frac{\vec{a}(t + \Delta t) - \vec{a}(t)}{\Delta t}
$$

$$
\begin{aligned}
(\vec{a} \cdot{} \vec{b})' &= \vec{a}' \cdot \vec{b} + \vec{a} \cdot \vec{b}' \\
(\vec{a} \times \vec{b})' &= \vec{a}' \times \vec{b} + \vec{a} \times \vec{b}'
\end{aligned}
$$

#### 曲線

$$
\vec{r} = \vec{r}(t) = (x(t), y(t), z(t))
$$

単位接線ベクトルは

$$
\vec{t} = \frac{\dfrac{d\vec{r}}{dt}}{\left|\dfrac{d\vec{r}}{dt}\right|}
$$

曲線上の点 $P(a)$ から $P(b)$ までの曲線の長さ $s$ は $a < b$ のとき

$$
s = \int_a^b \left| \frac{d\vec{r}}{dt} \right| dt
= \int_a^b \sqrt{\left(\frac{dx}{dt}\right)^2 + \left(\frac{dy}{dt}\right)^2 + \left(\frac{dz}{dt}\right)^2} \;dt
$$

#### 曲面

曲線 $\vec{r} = \vec{r}(u, v)$ について、曲線上の点における単位法線ベクトルは

$$
\vec{n} = \pm\frac{
  \dfrac{\partial \vec{r}}{\partial u} \times \dfrac{\partial \vec{r}}{\partial v}
}{
  \left|
  \dfrac{\partial \vec{r}}{\partial u} \times \dfrac{\partial \vec{r}}{\partial v}
  \right|
}
$$

$uv$ 平面上の範囲 $D$ に対応する曲面の面積は

$$
S = \iint_D \left| \dfrac{\partial \vec{r}}{\partial u} \times \dfrac{\partial \vec{r}}{\partial v} \right| \;du\,dv
$$

<br>
### 1.2 スカラー場とベクトル場

#### 勾配

$\nabla\varphi,\; \mathrm{grad}\;\varphi$

ハミルトンの演算子 $\nabla$ (記号はナブラと読む)

$$
\nabla \varphi = \left( \frac{\partial \varphi}{\partial x}, \frac{\partial \varphi}{\partial y}, \frac{\partial \varphi}{\partial z} \right)
= \frac{\partial \varphi}{\partial x} \vec{i} + \frac{\partial \varphi}{\partial y} \vec{j} + \frac{\partial \varphi}{\partial z} \vec{k}
$$

$\varphi, \psi$ をスカラー場、$f$ を1変数の関数とするとき

$$
\begin{aligned}
\nabla(\varphi + \psi) &= \nabla\varphi + \nabla\psi \\[3pt]
\nabla(\varphi \psi) &= (\nabla\varphi)\psi + \varphi(\nabla\psi) \\[3pt]
\nabla(f(\varphi)) &= f'(\varphi) \nabla \varphi
\end{aligned}
$$

任意の単位ベクトル $\vec{e}$ 方向への方向微分係数は $\nabla \varphi \cdot{} \vec{e}$

#### 発散

$\nabla\cdot{}\vec{a},\; \mathrm{div}\;\vec{a}$

$$
\nabla \cdot{} \vec{a} = \frac{\partial a_x}{\partial x} + \frac{\partial a_y}{\partial y} + \frac{\partial a_z}{\partial z}
$$

#### 回転

$\nabla\times\vec{a},\; \mathrm{rot}\;\vec{a},\; \mathrm{curl}\;\vec{a}$

$$
\nabla\times\vec{a} =
\begin{vmatrix}
\vec{i} & \vec{j} & \vec{k} \\
\dfrac{\partial}{\partial x} & \dfrac{\partial}{\partial y} & \dfrac{\partial}{\partial z} \\
a_x & a_y & a_z
\end{vmatrix}
$$

#### 発散と回転の性質

$\vec{a}, \vec{b}$ をベクトル場、$\varphi$ をスカラー場とするとき

$$
\begin{aligned}
\nabla \cdot{} (\vec{a} + \vec{b}) &= \nabla \cdot{} \vec{a} + \nabla \cdot{} \vec{b} \\
\nabla \cdot{} (\varphi \vec{a}) &= (\nabla \varphi ) \cdot{} \vec{a} + \varphi (\nabla \cdot{} \vec{b}) \\
\nabla \times (\nabla \varphi) &= 0
\end{aligned}
$$

$$
\begin{aligned}
\nabla \times (\vec{a} + \vec{b}) &= \nabla \times \vec{a} + \nabla \times \vec{b} \\
\nabla \times (\varphi \vec{a}) &= (\nabla \varphi ) \times \vec{a} + \varphi (\nabla \times \vec{b}) \\
\nabla \cdot{} (\nabla \times \vec{a}) &= 0
\end{aligned}
$$

#### 位置ベクトルに関する性質

$\vec{r} = (x,y,z),\; r = \lvert\vec{r}\rvert$ とするとき

$$
\nabla r = \frac{\vec{r}}{r},\;\;\;\;\;\;
\nabla \cdot{} \vec{r} = 3,\;\;\;\;\;\;
\nabla \times \vec{r} = 0
$$

#### ラプラシアン

$\nabla \cdot{} \nabla,\; \nabla^2,\; \Delta$

$$
\nabla \cdot{} \nabla\,\varphi
= \left(\frac{\partial}{\partial x}, \frac{\partial}{\partial y}, \frac{\partial}{\partial z}\right) \cdot{} \left(\frac{\partial\varphi}{\partial x}, \frac{\partial\varphi}{\partial y}, \frac{\partial\varphi}{\partial z}\right)
= \frac{\partial^2\varphi}{\partial x^2} + \frac{\partial^2\varphi}{\partial y^2} + \frac{\partial^2\varphi}{\partial z^2}
$$

<br>
### 1.3 線積分・面積分

#### 線積分

スカラー場 $\varphi$、ベクトル場 $\vec{a}$ について

$\vec{r}(t) = (x(t), y(t), z(t))$ の表す曲線 $C$ に沿う線積分は

$$
\begin{aligned}
\int_C \varphi \;ds &= \int_a^b \varphi(x(t), y(t), z(t)) \frac{ds}{dt}\;dt
\;\;\;\left( \frac{ds}{dt} = \left| \frac{d\vec{r}}{dt} \right| \right) \\[3pt]
\int_C \varphi \;dx &= \int_a^b \varphi(x(t), y(t), z(t)) \frac{dx}{dt}\;dt
\;\;\;(y, z \;\text{成分についても同様}) \\[3pt]
\int_{C_1 + C_2} \vec{a} \cdot{} d\vec{r} &= \int_a^b \vec{a} \cdot{} \frac{d\vec{r}}{dt} dt
\end{aligned}
$$

$C_1, C_2$ をつなぐ曲線を $C_1 + C_2$、$C$ と逆向きの曲線を $-C$ とするとき

$$
\int_{C_1+C_2} \vec{a}\cdot{}d\vec{r} =
\int_{C_1} \vec{a}\cdot{}d\vec{r} + \int_{C_1} \vec{a}\cdot{}d\vec{r}
$$

$$
\int_{C} \vec{a}\cdot{}d\vec{r} = -\int_{C} \vec{a}\cdot{}d\vec{r}
$$

#### グリーンの定理

関数 $F(x,y),\; G(x,y)$ について

$$
\int_C (F\;dx + G\;dy) = \iint_D \left( \frac{\partial G}{\partial x} - \frac{\partial F}{\partial y} \right) \;dx\,dy
$$

#### 面積分

領域 $D$ で定義された $\vec{r}(u, v)$ の表す曲面 $S$ について

スカラー場 $\varphi$ の $S$ 上の面積分は

$$
\int_S \varphi \;dS = \iint_D \varphi\left(x(u,v), y(u,v), z(u,v)\right)
  \left| \frac{\partial \vec{r}}{\partial u} \times \frac{\partial \vec{r}}{\partial v} \right| \;du\,dv
$$

特に、$\varphi = 1$ のとき、上の積分は $S$ の面積である。

$S$ 上の点 $P$ における単位法線ベクトルを $\vec{n}$ とするとき

$$
\int_S \vec{a} \cdot{} \vec{n} \;dS =
\iint_D \vec{a} \cdot{} \vec{n} \left| \frac{\partial \vec{r}}{\partial u} \times \frac{\partial \vec{r}}{\partial v} \right| \;du\,dv
$$

#### 体積分

スカラー場 $\varphi$ の立体 $V$ についての体積分

$$
\int_V \varphi \;dV = \iiint_V \varphi \;dx\,dy\,dz
$$

#### 発散定理

閉曲面 $S$ で囲まれた立体を $V$ とし、$\vec{n}$ が $S$ の外側を向くとき

$$
\int_V \nabla \cdot{} \vec{a} \;dV = \int_S \vec{a} \cdot{} \vec{n} \;dS
$$

#### ストークスの定理

空間内に $S, C, \vec{n}$ をとるとき、ベクトル場 $\vec{a}$ について

$$
\int_S (\nabla \times \vec{a}) \cdot{} \vec{n} \;dS = \int_C \vec{a} \cdot{} d\vec{r}
$$
