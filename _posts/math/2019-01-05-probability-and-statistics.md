---
layout:        post
title:         "確率統計 公式一覧"
date:          2019-01-05
category:      Math
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

高専4年の数学の教科書として使用した「新 確率統計」(大日本図書) の公式などを備忘録としてまとめたものです。

## 1. 確率

##### 条件付き確率 (ベイズの定理)

$A$が起こったという条件のもとで$B$の起こる条件つき確率

$$
P_A(B) = \frac{P(A \cap B)}{P(A)}
$$

$$
P(B|A) = \frac{P(A|B)P(B)}{P(A)}
$$

##### 反復試行の確率

試行 $T$ を1回行うとき、$A$ の起こる確率を $p$ とする。この試行を独立に $n$ 回行うとき、$A$ が $k$ 回起こる確率は次式で求まる。

$$
{}_nC_k p^k q^{n-k} \;\;(q = 1 - p,\, k = 0,1,2,...,n)
$$

<br>
## 2. データの整理

### 1次元のデータ

##### 平均

$$
\overline{x} = \frac{1}{n} \sum_{i=1}^n x_i
$$

##### 分散

$$
\begin{align}
v_x &= \frac{1}{n} \sum_{i=1}^n (x_i - \overline{x})^2 \\
    &= \overline{x^2} - \overline{x}^2
\end{align}
$$

##### 標準偏差

$$
s_x = \sqrt{v_x}
$$

### 2次元のデータ

##### 共分散

$$
\begin{align}
s_{xy} &= \frac{1}{n} \sum_{i=1}^n (x_i - \overline{x}) (y_i - \overline{y}) \\
       &= \overline{xy} - \overline{x}\,\overline{y}
\end{align}
$$

##### 相関係数

$$
r = \frac{s_{xy}}{s_x s_y}
  = \dfrac{ \displaystyle\sum_{i=1}^n (x_i - \overline{x}) (y_i - \overline{y}) }{ \sqrt{\displaystyle\sum_{i=1}^n (x_i - \overline{x})^2} \sqrt{\displaystyle\sum_{i=1}^n (y_i - \overline{y})^2} }
$$

##### 回帰直線

($y = ax + b$)

$$
a = \frac{s_{xy}}{s_x{}^2} ,\;\; b = \overline{y} - a\overline{x}
$$

<br>
## 3. 確率分布

### 確率変数と確率分布

確率変数と確率分布

| | 離散型 | 連続型
|:--|---|---|
| 確率分布 | $P(X=x_i) = p_i$ | $P(a \le X \le b) = \displaystyle\int_a^b f(x)\,dx$
| 平均 $\mu = E[X]$ | $\displaystyle\sum_{i=1}^n x_i p_i$ | $\displaystyle\int_{-\infty}^{\infty} xf(x)\,dx$
| 分散 $\sigma^2 = V[X]$ | $\displaystyle\sum_{i=1}^n (x_i - \mu)^2 p_i$ | $\displaystyle\int_{-\infty}^{\infty} (x - \mu)^2 f(x)\,dx$

##### 平均と分散の性質

$$
E[aX + b] = aE[x] + b,\;\; V[aX + b] = a^2 V[X]
$$

$$
V[X] = E[X^2] - (E[X])^2
$$

##### 主な離散型確率分布

$$
\begin{array}{lll}
二項分布 B(n,p) & P(X=k) = {}_nC_k p^k q^{n-k} & 平均\; np, 分散\; npq \\
ポアソン分布 P_o(\lambda) & P(X=k) = e^{-\lambda} \dfrac{\lambda^k}{k!} & 平均\; \lambda, 分散\; \lambda
\end{array}
$$

##### 確率密度関数と分布関数

$$
\int_{-\infty}^{\infty} f(x)\,dx = 1
$$

$$
F(x) = \int_{-\infty}^x f(x)\,dx = P(X \le x) \;\;\;\text{... 分布関数}
$$

##### 正規分布 $N(\mu, \sigma^2)$

$$
f(x) = \frac{1}{\sqrt{2\pi} \sigma} \exp\left( -\frac{(x-\mu)^2}{2\sigma^2} \right)
$$

$X$ は $N(\mu,\sigma^2)$ に従う $\Longrightarrow$ $X$ の標準化 $Z = \frac{X-\mu}{\sigma}$ は標準正規分布 $N(0,1)$ に従う

##### 二項分布の正規分布による近似

$X$ は $B(n,p)$、$Z$ は $N(0,1)$ に従うとき、$n$が十分に大きいならば

$$
P(a \le X \le b) \simeq P\left( \frac{a - 0.5 - np}{\sqrt{npq}} \le Z \le \frac{b + 0.5 - np}{\sqrt{npq}} \right)
$$

### 統計量の標本分布

##### 統計量

無作為標本 $X_1, X_2, ..., X_n$ の関数

標本平均

$$
\overline{X} = \frac{1}{n} \sum_{i=1}^n X_i
$$

標本分布

$$
S^2 = \frac{1}{n} \sum_{i=1}^n (X_i - \overline{X})^2
$$

不偏分散

$$
U^2 = \frac{1}{n-1} \sum_{i=1}^n (X_i - \overline{X})^2 = \frac{n}{n-1} S^2
$$

##### 標本平均の平均と分散

$$
E[\overline{X}] = \mu, \;\;\; V[\overline{X}] = \frac{\sigma^2}{n}
$$

##### 正規母集団 $N(\mu,\sigma^2)$ の標本分布

大きさ$n$の無作為標本の標本平均 $\overline{X}$ は $N(\mu,\frac{\sigma^2}{n})$ に従う

##### 中心極限定理

母平均 $\mu$、母分散 $\sigma^2$ の母集団から大きさ $n$ の無作為標本を抽出

$\Longrightarrow$ $n$ が大きいとき、$\overline{X}$ は近似的に正規表現 $N(\mu,\frac{\sigma^2}{n})$ に従う

##### $\chi^2$ 分布

上限 $\alpha$ 点 $\chi_n^2(\alpha)$ $\iff$ $P(X \ge \chi_n^2(\alpha)) = \alpha$

正規母集団 $N(\mu,\sigma^2)$ から大きさ $n$ の無作為標本を抽出

$\Longrightarrow$ $\dfrac{(n-1)U^2}{\sigma^2}$ は自由度 $n-1$ の $\chi^2$ 分布に従う

##### $t$ 分布

上限 $\alpha$ 点 $t_n(\alpha)$ $\iff$ $P(X \ge t_n(\alpha)) = \alpha$

正規母集団 $N(\mu,\sigma^2)$ から大きさ $n$ の無作為標本を抽出

$\Longrightarrow$ $\dfrac{\overline{X}-\mu}{\sqrt{U^2/n}}$ は自由度 $n-1$ の $t$ 分布に従う

##### $F$ 分布

上限 $\alpha$ 点 $F_{m,n}(\alpha)$ $\iff$ $P(X \ge F_{m,n}(\alpha)) = \alpha$

$N(\mu_1,\sigma^2),\, N(\mu_2,\sigma^2)$ から大きさ $n$ の無作為標本を抽出

$\Longrightarrow$ $\dfrac{U_1^2}{U_2^2}$ は自由度 $(n_1-1, n_2-1)$ の $F$ 分布に従う


<br>
## 4. 推定と検定

##### 母平均の区間推定

正規母集団で母分散 $\sigma^2$ が既知のとき（ただし，$z_{\alpha/2}$ は標準正規分布の上側 $\alpha / 2$ 点）（正規母集団でなくても $n$ が大きければ、$\sigma^2$ に不偏分散 $u^2$ を代入しても良い）

$$
\overline{x} - z_{\alpha/2} \sqrt{\frac{\sigma^2}{n}} \le \overline{x} \le
\overline{x} + z_{\alpha/2} \sqrt{\frac{\sigma^2}{n}}
$$

正規母集団で母分散 $\sigma^2$ が未知のとき

$$
\overline{x} - t_{n-1}(\alpha/2) \sqrt{\frac{u^2}{n}} \le \overline{x} \le
\overline{x} + t_{n-1}(\alpha/2) \sqrt{\frac{u^2}{n}}
$$

##### 母分散の区間推定

正規母集団のとき

$$
\frac{(n-1)u^2}{\chi_{n-1}^2(\alpha/2)} \le \sigma^2 \le \frac{(n-1)u^2}{\chi_{n-1}^2(1-\alpha/2)}
$$

##### 母比率の区間推定

二項母集団で $n$ は大きいとき

$$
\hat{p} - z_{\alpha/2} \sqrt{\frac{\hat{p}(1-\hat{p})}{n}} \le p \le
\hat{p} + z_{\alpha/2} \sqrt{\frac{\hat{p}(1-\hat{p})}{n}}
$$

### 統計的検定

##### 仮説と検定

1. 有意水準（危険率）$\alpha$ を定める。
2. 帰無仮説 $H_0$ と対立仮説 $H_1$ を設定する。
   - $H_0$ : $\theta = \theta_0$
   - $H_1$ : $\theta \ne \theta_0$ (両側検定)　$\theta > \theta_0$ (右側検定)　$\theta < \theta_0$ (左側検定)
3. $H_0$ を仮定して、検定統計量 $X$ の実現値 $x$ を求める。
4. $p$ 値または棄却域の方法により、$H_0$ を棄却するかどうかを判断する。
    - $p$ 値 ... $X$ が $x$ より外れる確率（$\alpha$ より小さければ棄却）
    - 棄却域 ... 棄却域に入る確率が $\alpha$ となる $X$ の範囲

|    | $H_0$ が真 | $H_0$ が偽 ($H_1$ が真)
|----|----|----|
| $H_0$ を受容 | 正しい判断 | 第2種の誤り
| $H_0$ を棄却 | 第1種の誤り | 正しい判断

##### 色々な検定

| 検定 | 前提条件 | 検定統計量 | 確率分布
|-----|---------|----------|--------
| 母平均 | 正規母集団で<br>母分散が既知 | $$Z = \dfrac{\overline{X}-\mu}{\sqrt{\sigma^2/n}}$$ | 標準正規分布
| 母平均 | 正規母集団で<br>母分散が未知 | $$T = \dfrac{\overline{X}-\mu}{\sqrt{U^2/n}}$$ | 自由度 $n-1$ の $t$ 分布
| 母平均 | $n$ が大きい | $$Z = \dfrac{\overline{X}-\mu}{\sqrt{U^2/n}}$$ | 近似的に標準正規分布
| 母分散 | 正規母集団 | $$X = \dfrac{(n-1)U^2}{\sigma_0^2}$$ | 自由度 $n-1$ の $\chi^2$ 分布
| 等分散 | 正規母集団 | $$F = \dfrac{U_1^2}{U_2^2},\;F' = \dfrac{U_2^2}{U_1^2}$$ | 自由度 $(n_1 - 1, n_2 - 1)$ <br>の $F$ 分布
| 母平均の差 | 正規母集団で<br>母分散が既知 | $$Z = \dfrac{\overline{X} - \overline{Y}}{\sqrt{\sigma_1^2/n_1 + \sigma_2^2/n_2}}$$ | 標準正規分布
| 母平均の差 | $n_1, n_2$ が大きい | $$Z = \dfrac{\overline{X} - \overline{Y}}{\sqrt{U_1^2/n_1 + U_2^2/n_2}}$$ | 近似的に標準正規分布
| 母比率 | 二項母集団で<br> $n$ が大きい | $$Z = \dfrac{\hat{P} - p_0}{\sqrt{p_0 q_0 / n}}$$ | 近似的に標準正規分布
