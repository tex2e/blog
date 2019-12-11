---
layout:        post
title:         "剰余の逆元 (modinv) の手計算"
date:          2019-12-04
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

剰余演算の**逆元**を手計算で求める方法についての備忘録です。
例えば $16$ を法とする $3$ の逆元 $x$ を求める例を考えてみます。

$$3x \equiv 1 \pmod{16}$$

まず、与式と $16$ を法とする式 $16x \equiv 0$ で一次合同式を立てます。

$$
\begin{eqnarray}
  \begin{cases}
    3x  &\equiv 1 \pmod{16} \;\;\;\;\;\;\;\;\;\;(1) \\
    16x &\equiv 0 \pmod{16} \;\;\;\;\;\;\;\;\;\;(2)
  \end{cases}
\end{eqnarray}
$$

次に、式変形をして左辺の $x$ の係数が $1$ になるようにします。

$$
\begin{eqnarray}
  \begin{cases}
    15x &\equiv 5 \pmod{16} \;\;\;\;\;\;\;\;\;\;(1)' \\
    16x &\equiv 0 \pmod{16} \;\;\;\;\;\;\;\;\;\;(2)
  \end{cases}
\end{eqnarray}
$$

$$
\begin{align}
\;\;\;\;
x &\equiv -5 \pmod{16} \;\;\;\;\;\;\;\;(2) - (1)' \\
x &\equiv 11 \pmod{16}
\end{align}
$$

よって、$16$ を法とする $3$ の逆元 $x$ は $11$ となります。
