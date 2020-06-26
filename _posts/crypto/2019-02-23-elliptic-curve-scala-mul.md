---
layout:        post
title:         "有限体上の楕円曲線上のスカラー倍算"
menutitle:     "有限体上の楕円曲線上のスカラー倍算とsecp256k1の計算"
date:          2019-02-23
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
---

有限体上の楕円曲線上のスカラー倍算のPython実装について。

有限体上の楕円曲線や、曲線上の点を探す方法、点同士の演算などについては同サイトの
[有限体上の楕円曲線の点集合](/blog/crypto/point-of-elliptic-curve-over-GF)
を参照してください。
まず、有限体上の楕円曲線上の点の加算 $(x_3, y_3) = (x_1, y_1) + (x_2, y_2)$ は次の通りです。

$$
\begin{aligned}
  x_3 &= \lambda^2 - x_1 - x_2     \mod{p} \\
  y_3 &= \lambda (x_1 - x_3) - y_1 \mod{p} \\[10pt]
  \lambda &= \begin{cases}
    \cfrac{y_2 - y_1}{x_2 - x_1} \mod{p} & \mathrm{if}\; P \ne Q \\[8pt]
    \cfrac{3 x_1^2 + a}{2 y_1}   \mod{p} & \mathrm{if}\; P = Q
  \end{cases}
\end{aligned}
$$

例えば、有限体 $F_{11}$ 上の楕円曲線 $y^2 = x^3 + x + 6$ とする（$a = 1,\, b = 6$）。曲線上の点 $\alpha = (2,7)$ を選んだとき、$2\alpha = (2,7) + (2,7)$ を計算するには[^DRS]、
楕円曲線上の2倍算の式より、

$$
\begin{aligned}
  \lambda &= (3 \times 2^2 + 1) (2 \times 7)^{-1} \;\mathrm{mod}\; 11  = 8 \\[5pt]
  x_3 &= 8^2 - 2 - 2 \;\mathrm{mod}\; 11 = 5 \\
  y_3 &= 8 (2-5) - 7 \;\mathrm{mod}\; 11 = 2
\end{aligned}
$$

となり、$2\alpha = (5,2)$ となります。
次に $3 \alpha = 2 \alpha + \alpha = (5,2) + (2,7)$ を計算すると、

$$
\begin{aligned}
  \lambda &= (7 - 2) (2 - 5)^{-1} \;\mathrm{mod}\; 11  = 2 \\[5pt]
  x_3 &= 2^2 - 5 - 2 \;\mathrm{mod}\; 11 = 8 \\
  y_3 &= 2 (5-8) - 2 \;\mathrm{mod}\; 11 = 3
\end{aligned}
$$

となり、$3\alpha = (8,3)$ となります。

次に、これを $k \,\alpha$（$k$は任意の整数）のときでも計算できるようにPythonで実装していきます。
楕円曲線を実装する前に、有限体の演算ができるようにする必要があります。
有限体上の足し算と掛け算は簡単ですが、割り算では逆元を求める必要があるので、
拡張ユークリッドの互除法と乗法逆元を求める関数も定義しておきます。

```python

# 拡張ユークリッドの互除法
def xgcd(a, b):
    x0, y0, x1, y1 = 1, 0, 0, 1
    while b != 0:
        q, a, b = a // b, b, a % b
        x0, x1 = x1, x0 - q * x1
        y0, y1 = y1, y0 - q * y1
    return a, x0, y0

# 有限体の乗法逆元（モジュラ逆数）を求める
def modinv(a, m):
    g, x, y = xgcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m

# 有限体 (ただしpは素数)
def GF(p):

    class Fp:
        def __init__(self, val):
            self.val = int(val) % Fp.p
        def __neg__(self):
            return Fp(-self.val)
        def __add__(self, other):
            return Fp(self.val + int(other))
        def __sub__(self, other):
            return Fp(self.val - int(other))
        def __mul__(self, other):
            return Fp(self.val * int(other))
        def __pow__(self, e):
            return Fp(pow(self.val, int(e), Fp.p))
        def __floordiv__(self, other):
            return self * modinv(other.val, Fp.p)
        def __mod__(self, m):
            return self.val % int(m)
        def __eq__(self, other):
            return self.val == other.val
        def __repr__(self):
            return str(self.val)
        def __int__(self):
            return self.val

        __radd__ = __add__
        __rsub__ = __sub__
        __rmul__ = __mul__
        __rfloordiv__ = __floordiv__

    Fp.p = p
    return Fp


# 有限体上の楕円曲線
class EllipticCurveOverFp:
    """
    y**2 = x**3 + a*x + b (mod p)
    """

    def __init__(self, a, b, p):
        self.p = p
        self.Fp = GF(p)
        self.a = self.Fp(a)
        self.b = self.Fp(b)


# 楕円曲線の点
class PointOverEC:

    def __init__(self, curve, x, y, infinity=False):
        self.curve = curve
        self.Fp = curve.Fp
        self.x = x
        self.y = y
        self.infinity = infinity
        if self.Fp(y**2) != self.Fp(x**3 + curve.a * x + curve.b):
            raise Exception('(%d, %d) is not on curve!' % (x, y))

    @staticmethod
    def get_infinity():
        dummy_curve = EllipticCurveOverFp(0,0,1)
        return PointOverEC(curve=dummy_curve, x=0, y=0, infinity=True)

    def is_infinity(self):
        return self.infinity

    def get_point(self):
        return self.Fp(self.x), self.Fp(self.y)

    def __str__(self):
        if self.infinity:
            return "(∞,∞)"
        return "({},{})".format(self.x, self.y)

    # 楕円曲線上の点の加算
    def __add__(self, other):
        x1, y1 = self.get_point()
        x2, y2 = other.get_point()

        if x1 == x2 and y2 == -y1:
            return PointOverEC.get_infinity()
        if self.is_infinity():
            return other
        if other.is_infinity():
            return self

        if x1 == x2 and y1 == y2:
            l = (3 * x1**2 + self.curve.a) // (2 * y1)
        else:
            l = (y2 - y1) // (x2 - x1)

        x3 = l**2 - x1 - x2
        y3 = l * (x1 - x3) - y1

        return PointOverEC(self.curve, x3, y3)

    # 楕円曲線上の点のスカラー倍算
    def __rmul__(self, n):
        # O(log2(n))
        tmp = self
        point = PointOverEC.get_infinity()
        while n > 0:
            if n & 1 == 1:
                point += tmp
            n >>= 1
            tmp += tmp
        return point


curve = EllipticCurveOverFp(a=1, b=6, p=11)
a = PointOverEC(curve, x=2, y=7)

# 点の位数を求める（無限遠点になるまでスカラー倍する）
for k in range(1, 20):
    ka = k * a
    print('%2d: %s' % (k, ka))
    if ka.is_infinity():
        break
```

実行結果は以下のようになります。
よって、今回例として使った有限体上の楕円曲線上の点 $P = (2,7)$ の位数$|P|$は $13$ ということがわかります。

```
 1: (2,7)
 2: (5,2)
 3: (8,3)
 4: (10,2)
 5: (3,6)
 6: (7,9)
 7: (7,2)
 8: (3,5)
 9: (10,9)
10: (8,8)
11: (5,9)
12: (2,4)
13: (∞,∞)
```

楕円曲線の位数 $\|E\|$ が素数の場合は、無限遠点 $O$ を除く曲線上の全ての点 $P$ の位数 $\|P\|$ は $\|E\|$ と同じになります。

### パラメータを変更してみる

上の例では「元の位数 $\|P\|$」が「群の位数 $\|E\|$」と等しくなりましたが、楕円曲線の位数 $\|E\|$ が非素数の場合は、等しくならない場合があります。
例えば有限体 $F_{11}$ 上の楕円曲線を $y^2 = x^3 + x + 2$ として、曲線上の点 $(2,1)$ を選ぶと、Pythonのプログラムは

```python
curve = EllipticCurveOverFp(a=1, b=2, p=11)
a = PointOverEC(curve, x=2, y=1)
```

となり、実行すると以下のようになります。よって、点 $(2,1)$ の位数は $8$ ということがわかり、「元の位数」が「群の位数」にならないことが確認できます。

```
 1: (2,1)
 2: (8,4)
 3: (4,9)
 4: (10,0)
 5: (4,2)
 6: (8,7)
 7: (2,10)
 8: (∞,∞)
```

安全な楕円曲線は位数が大きくなるようにパラメータが決められているので、
楕円曲線暗号を実装する場合はガイドラインで決められているパラメータを使用するようにしましょう。
例えば楕円曲線暗号として secp256k1 を使いたい場合は次のようになっています[^secp256k1] [^sec2]。

$$
p = 2^{256} - 2^{32} - 2^9 - 2^8 - 2^7 - 2^6 - 2^4 - 1,\;\; a = 0,\;\; b = 7
$$

また、ベースポイントと呼ばれる点 $G$ の座標も示されていて、それを上のプログラムで書き換えると次のようになります。

```python
curve = EllipticCurveOverFp(
    a=0x0000000000000000000000000000000000000000000000000000000000000000,
    b=0x0000000000000000000000000000000000000000000000000000000000000007,
    p=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
a = PointOverEC(curve,
    x=0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
    y=0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
```

secp256k1 の Test Vectors を書いてくれている方の記事を参考に secp256k1 のテストをしました[^testvectors]。
k < 20 までは計算結果が合っているのを確認しています。

```python
for k in range(1, 20):
    ka = k * a
    res = '(%x, %x)' % (int(ka.x), int(ka.y))  # 座標を16進数で表示
    print('%2d: %s' % (k, res))
    if ka.is_infinity():
        break
```

```
 1: (79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)
 2: (c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5, 1ae168fea63dc339a3c58419466ceaeef7f632653266d0e1236431a950cfe52a)
 3: (f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9, 388f7b0f632de8140fe337e62a37f3566500a99934c2231b6cb9fd7584b8e672)
 4: (e493dbf1c10d80f3581e4904930b1404cc6c13900ee0758474fa94abe8c4cd13, 51ed993ea0d455b75642e2098ea51448d967ae33bfbdfe40cfe97bdc47739922)
 5: (2f8bde4d1a07209355b4a7250a5c5128e88b84bddc619ab7cba8d569b240efe4, d8ac222636e5e3d6d4dba9dda6c9c426f788271bab0d6840dca87d3aa6ac62d6)
 6: (fff97bd5755eeea420453a14355235d382f6472f8568a18b2f057a1460297556, ae12777aacfbb620f3be96017f45c560de80f0f6518fe4a03c870c36b075f297)
 7: (5cbdf0646e5db4eaa398f365f2ea7a0e3d419b7e0330e39ce92bddedcac4f9bc, 6aebca40ba255960a3178d6d861a54dba813d0b813fde7b5a5082628087264da)
 8: (2f01e5e15cca351daff3843fb70f3c2f0a1bdd05e5af888a67784ef3e10a2a01, 5c4da8a741539949293d082a132d13b4c2e213d6ba5b7617b5da2cb76cbde904)
 9: (acd484e2f0c7f65309ad178a9f559abde09796974c57e714c35f110dfc27ccbe, cc338921b0a7d9fd64380971763b61e9add888a4375f8e0f05cc262ac64f9c37)
10: (a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e247c7, 893aba425419bc27a3b6c7e693a24c696f794c2ed877a1593cbee53b037368d7)
11: (774ae7f858a9411e5ef4246b70c65aac5649980be5c17891bbec17895da008cb, d984a032eb6b5e190243dd56d7b7b365372db1e2dff9d6a8301d74c9c953c61b)
12: (d01115d548e7561b15c38f004d734633687cf4419620095bc5b0f47070afe85a, a9f34ffdc815e0d7a8b64537e17bd81579238c5dd9a86d526b051b13f4062327)
13: (f28773c2d975288bc7d1d205c3748651b075fbc6610e58cddeeddf8f19405aa8, ab0902e8d880a89758212eb65cdaf473a1a06da521fa91f29b5cb52db03ed81)
14: (499fdf9e895e719cfd64e67f07d38e3226aa7b63678949e6e49b241a60e823e4, cac2f6c4b54e855190f044e4a7b3d464464279c27a3f95bcc65f40d403a13f5b)
15: (d7924d4f7d43ea965a465ae3095ff41131e5946f3c85f79e44adbcf8e27e080e, 581e2872a86c72a683842ec228cc6defea40af2bd896d3a5c504dc9ff6a26b58)
16: (e60fce93b59e9ec53011aabc21c23e97b2a31369b87a5ae9c44ee89e2a6dec0a, f7e3507399e595929db99f34f57937101296891e44d23f0be1f32cce69616821)
17: (defdea4cdb677750a420fee807eacf21eb9898ae79b9768766e4faa04a2d4a34, 4211ab0694635168e997b0ead2a93daeced1f4a04a95c0f6cfb199f69e56eb77)
18: (5601570cb47f238d2b0286db4a990fa0f3ba28d1a319f5e7cf55c2a2444da7cc, c136c1dc0cbeb930e9e298043589351d81d8e0bc736ae2a1f5192e5e8b061d58)
19: (2b4ea0a797a443d293ef5cff444f4979f06acfebd7e86d277475656138385b6c, 85e89bc037945d93b343083b5a1c86131a01f60c50269763b570c854e5c09b7a)
```


### 余談

実装したプログラムの確認には「[Elliptic Curve Calculator](http://www.christelbach.com/ECCalculator.aspx)」も使いました。
ちょっと計算してみたいけどプログラム書くのが面倒なときに重宝すると思います。


-----

[^DRS]: Douglas R. Stinson 著, 櫻井幸一 訳『暗号理論の基礎』共立出版 1996
[^secp256k1]: [Secp256k1 - Bitcoin Wiki](https://en.bitcoin.it/wiki/Secp256k1)
[^sec2]: [SEC 2: Recommended Elliptic Curve Domain Parameters (pdf)](http://www.secg.org/sec2-v2.pdf)
[^testvectors]: [secp256k1 Test Vectors - Chuck Batson](https://chuckbatson.wordpress.com/2014/11/26/secp256k1-test-vectors/)
