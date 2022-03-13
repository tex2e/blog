---
layout:        post
title:         "素数位数となる楕円曲線のパラメータ生成"
date:          2020-11-23
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
photoswipe:    false
# sitemap: false
# feed:    false
---

有限体上の楕円曲線の位数が素数となるようにパラメータを選ぶことは、Pohlig–Hellman法による攻撃への対策として重要なことです。
しかし適当にパラメータ a, b, p を選ぶと、大体の場合は位数が合成数になってしまいます。
そこで、SageMathを使って素数位数となるパラメータを生成する方法を紹介します。

ここでは、$y^2 = x^3 + ax + b$ の形式の楕円曲線について考えます。
楕円曲線の位数 $$\#E$$ が素数となるようなパラメータは以下のSageで求めることができます。

```python
p = random_prime(100000000)
a = random_prime(10)
F = GF(p)
for b in range(1, p):
    E = EllipticCurve(F, [a, b])
    if is_prime(E.order()):
        print(E)
        break
    E = EllipticCurve(F, [a, -b])
    if is_prime(E.order()):
        print(E)
        break

print('p =', p)
print('a =', a)
print('b =', b)
print('#E =', E.order())
```

以下はSageMath起動したくないけど、素数位数となる適当でいい感じのパラメータがほしい人向けのパラメータ集です。

```
Elliptic Curve defined by y^2 = x^3 + 5*x + 4 over Finite Field of size 37
p = 37
a = 5
b = 4
#E = 41


Elliptic Curve defined by y^2 = x^3 + 7*x + 9 over Finite Field of size 673
p = 673
a = 7
b = 9
#E = 661


Elliptic Curve defined by y^2 = x^3 + 7*x + 3 over Finite Field of size 9923
p = 9923
a = 7
b = 3
#E = 10007


Elliptic Curve defined by y^2 = x^3 + 5*x + 50 over Finite Field of size 39929
p = 39929
a = 5
b = 50
#E = 39727


Elliptic Curve defined by y^2 = x^3 + 3*x + 22 over Finite Field of size 225689
p = 225689
a = 3
b = 22
#E = 226001


Elliptic Curve defined by y^2 = x^3 + 3*x + 70 over Finite Field of size 8164441
p = 8164441
a = 3
b = 70
#E = 8161333


Elliptic Curve defined by y^2 = x^3 + 7*x + 73 over Finite Field of size 79206053
p = 79206053
a = 7
b = 73
#E = 79209367


Elliptic Curve defined by y^2 = x^3 + 2*x + 20 over Finite Field of size 764397169
p = 764397169
a = 2
b = 20
#E = 764359027


Elliptic Curve defined by y^2 = x^3 + 13*x + 15 over Finite Field of size 5424129199
p = 5424129199
a = 13
b = 15
#E = 5424100369


Elliptic Curve defined by y^2 = x^3 + 2*x + 23 over Finite Field of size 9416099093
p = 9416099093
a = 2
b = 23
#E = 9416217143


Elliptic Curve defined by y^2 = x^3 + 19*x + 884540762062 over Finite Field of size 884540762291
p = 884540762291
a = 19
b = 229
#E = 884539929947
```

以上です。
