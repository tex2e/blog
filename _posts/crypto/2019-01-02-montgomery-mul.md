---
layout:        post
title:         "Pythonでモンゴメリ乗算"
date:          2019-01-02
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---


モンゴメリ乗算（Montgomery modular multiplication）とは、乗算剰余計算 $a \times b \mod{N}$ において剰余を求めるときの除算の回数を減らして処理の速度を早くしようというアルゴリズムで[^montgomery]、サイドチャネル攻撃に対しても強いので暗号理論の分野でも重要なアルゴリズムです[^side_channel_attacks]。
$$
\def\mod{ {\;\mathrm{mod}\;} }
$$

[^montgomery]: [モンゴメリ乗算 (Wikipedia)](https://ja.wikipedia.org/wiki/%E3%83%A2%E3%83%B3%E3%82%B4%E3%83%A1%E3%83%AA%E4%B9%97%E7%AE%97)
[^side_channel_attacks]: [Side channel attacks -- Montgomery modular multiplication (Wikipedia)](https://en.wikipedia.org/wiki/Montgomery_modular_multiplication#Side_channel_attacks)

モンゴメリ乗算の基本的な考え方は、まず2つの整数をモンゴメリ表現（Montgomery form）に変換して乗算をした後に、整数の表現に戻すことで除算の回数を少なくすることです。整数 $a,b$ の乗算剰余の結果 $ab \mod N$ を求める図を以下に示します。ただし、$R$ は $R > N$ と $\mathrm{gcd}(R, N) = 1$ を満たす定数とします。
モンゴメリ表現に変換するための定数 $R$ を適切に選ぶこと、例えば 2 のべき数にすることで、ビット演算（右ビットシフト、左ビットシフト、ビット単位AND）だけで除算・剰余を求めることができます。

```
              Integer                          Montgomery form

                              * R mod N
               a, b       ----------------->  aR mod N, bR mod N
                 |                                   |
         * mod N |                                   | * mod N
                 |                                   |
                 V                MR                 V
             a * b mod N  <-----------------     ab R^2 mod N
```

なお、モンゴメリ表現（図の右）から整数の表現（図の左）に戻すアルゴリズムをモンゴメリリダクション（Montgomery reduction）と呼びます。

### モンゴメリリダクション

モンゴメリリダクション（$\mathrm{MR}$）の計算は次のように定義されます。
ただし、$N'$ は $NN' = -1 \mod R$ を満たす値で、拡張ユークリッドの互除法で $xR + yN = 1$ を計算し、$N' = -y$ とすれば求まります。

$$
\begin{align}
  & t \leftarrow (T + (T N' \mod R) N ) / R \\
  & \text{if}\; t \gt N \;\text{then}\;\text{return}\; t - N \;\text{else}\;\text{return}\; t
\end{align}
$$

具体的な実装について言及すると $R$ は2の冪で $2^n$（$n$ は任意の整数）なので、剰余 $A \mod R$ はビット演算で `A & (R-1)` となり、除算 $A / R$ はビット演算で `A >> n` と書き換えることができます[^project_nayuki]。
なお、if節とelse節で処理が違うのでサイドチャネル攻撃の余地があるのでは？と思う方もいると思いますが、else節で $\text{return}\; t - 0$ とすることで処理時間をif節と同じにすることができます（ただし最適化されないことが前提ですが）[^side_channel_attacks]。

[^project_nayuki]: [Source code -- Montgomery reduction algorithm](https://www.nayuki.io/page/montgomery-reduction-algorithm)

### 乗算剰余演算

乗算剰余 $c \leftarrow a \times b$ はモンゴメリリダクションを使って次のように定義されます。
ただし、$R_2 = R^2 \mod N$ を事前に計算しておきます。

$$
 c \leftarrow \mathrm{MR}(\mathrm{MR(ab) R_2})
$$

詳しい説明は
[アルゴリズム -- モンゴメリ乗算（Wikipedia）](https://ja.wikipedia.org/wiki/%E3%83%A2%E3%83%B3%E3%82%B4%E3%83%A1%E3%83%AA%E4%B9%97%E7%AE%97#%E3%82%A2%E3%83%AB%E3%82%B4%E3%83%AA%E3%82%BA%E3%83%A0)
に詳しく書かれています。

### Python3での実装

Python3でモンゴメリ乗算による計算を実装して、モンゴメリ乗算と普通の計算で $a \times b \mod N$ を求めたときにどちらが速いか測定してみました。

```python
import math

class Montgomery:
    def __init__(self, mod, nbit=None):
        self.N = mod
        self.nbit = nbit if nbit else mod.bit_length()
        self.R = (1 << self.nbit)
        self.R2 = (self.R * self.R) % self.N
        g, a, b = Montgomery.__xgcd(self.R, self.N)
        self.R_inv = a
        self.N_dash = -b
        assert self.R > self.N and math.gcd(self.R, self.N) == 1

    def MR(self, T):
        t = (T + ((T * self.N_dash) & (self.R - 1)) * self.N) >> self.nbit
        return (t - self.N) if t >= self.N else (t - 0)

    def mul(self, a, b):
        return self.MR(self.MR(a * b) * self.R2)

    @staticmethod
    def __xgcd(a, b):
        x0, y0, x1, y1 = 1, 0, 0, 1
        while b != 0:
            q, a, b = a // b, b, a % b
            x0, x1 = x1, x0 - q * x1
            y0, y1 = y1, y0 - q * y1
        return a, x0, y0


if __name__ == '__main__':
    from datetime import datetime

    class Timer(object):
        def __enter__(self):
            self.start = datetime.now()
        def __exit__(self, *exc):
            diff = (datetime.now() - self.start).microseconds / 1000
            print("time: {}ms".format(diff))

    N = 7337488745629403488410174275830423641502142554560856136484326749638755396267050319392266204256751706077766067020335998122952792559058552724477442839630133
    a = 7866740167593846871725862646742594555435501859012590216351651260431131858865591312030037924525294849521618094581
    b = 5955442980786932364112398010391457189776910235916081036999618654431748490263235796535834039163225118090615818501

    print("--- Montgomery ---")
    with Timer():
        monty = Montgomery(mod=N)
        for i in range(100000):
            res = monty.mul(a, b)
    print(res)

    print("--- Python ---")
    with Timer():
        for i in range(100000):
            res = (a * b) % N
    print(res)
```

実行結果：

```
--- Montgomery ---
time: 517.564ms
5168589600225447600241927327463383441144656924030874498539387807356437874009044420324606634917532081215396404061564162200854757731712513530297703564316705
--- Python ---
time: 87.222ms
5168589600225447600241927327463383441144656924030874498539387807356437874009044420324606634917532081215396404061564162200854757731712513530297703564316705
```

答えは一致していますが、モンゴメリ乗算の方が遅くなってしまいました。
おそらく Python の方が色々な諸々でオーバヘッドが大きくなるので、真の結果を測定したい場合はC言語で実装してみないといけないと思いました。

### 結論

Pythonでモンゴメリ乗算を実装しても逆に遅くなるので、C言語で実装するのが正しい[^mont_mult]。

[^mont_mult]: [montgomery.c -- Legrandin/pycryptodome](https://github.com/Legrandin/pycryptodome/blob/d13e46b02d/src/montgomery.c#L202-L258)
