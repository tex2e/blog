---
layout:        post
title:         "ElGamal暗号と乗法準同型性"
date:          2020-02-22
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

ElGamal暗号をPythonで実装します。
ElGamal暗号 (ElGamal encryption) は乗法準同型性を有する暗号でもあるので、ElGamalの実装を示した後に、準同型暗号として実行した例を示します。

まず、ElGamal暗号は鍵生成、暗号化、復号の3つのアルゴリズムから構成されています。

- **鍵生成アルゴリズム**

    $k$ はセキュリティパラメータとする。

    1. $k$ ビットのランダムな素数 $p$ と原始元 $g \; (2 < g < p)$ [^Bleichenbacher-attack]を選ぶ。
    2. $2 \le x \le p-2$ となる整数 $x$ をランダムに選ぶ。
    3. $y = g^x \mod p$ を計算する。
    4. $(p, g, y)$ を公開鍵とし、$x$ を秘密鍵とする。

- **暗号化アルゴリズム**

    平文 $m$ は $0 \le m < p$ とする。

    1. $0 \le r \le p-2$ となる整数 $r$ をランダムに選ぶ。
    2. $c_1 = g^r \mod p$ と $c_2 = my^r \mod p$ を計算する。
    3. $(c_1, c_2)$ を暗号文とする。

- **復号アルゴリズム**

    1. $m = c_2 (c_1^{x})^{-1} \mod p$ を計算する（またはフェルマーの小定理より $m = c_2 c_1^{p-1-x} \mod p$ を計算しても同じ結果になる）。

ElGamal暗号をPythonで実装すると以下のようになります。

```python
# ElGamal暗号

# pip install pycryptodome
from Crypto.Util import number

# 鍵生成アルゴリズム
def elgamal_gen_key(bits):
    p = number.getPrime(bits)         # 素数p
    g = number.getRandomRange(3, p)   # 原始元g
    x = number.getRandomRange(2, p-1) # 秘密値x
    y = pow(g, x, p)                  # 公開値y
    return (p, g, y), x

# 暗号化アルゴリズム
def elgamal_encrypt(m, pk):
    p, g, y = pk
    assert(0 <= m < p)
    r = number.getRandomRange(2, p-1)
    c1 = pow(g, r, p)
    c2 = (m * pow(y, r, p)) % p
    return (c1, c2)

# 復号アルゴリズム
def elgamal_decrypt(c, pk, sk):
    p, g, y = pk
    c1, c2 = c
    return (c2 * pow(c1, p - 1 - sk, p)) % p

pk, sk = elgamal_gen_key(bits=20)
print('pk:', pk) # 公開鍵
print('sk:', sk) # 秘密鍵
print()

m = 314159 # 平文
print('m:', m)
c = elgamal_encrypt(m, pk) # 暗号化
print('c:', c)
d = elgamal_decrypt(c, pk, sk) # 復号
print('d:', d)
```

実行結果は次のようになります（公開鍵、秘密鍵、暗号文は毎回ランダムです）。

```
pk: (983243, 51092, 334017)
sk: 82452

m: 314159
c: (278864, 285129)
d: 314159
```

<br>
### 準同型暗号

ElGamal暗号は乗法準同型性を持つ暗号としても知られています。
例えば、平文 3 と 7 を暗号化し、暗号文のまま乗算をして、その結果を復号すると 21 になることを確認してみたいと思います。

```python
pk, sk = elgamal_gen_key(20)
p, _, _ = pk
print('pk:', pk) # 公開鍵
print('sk:', sk) # 秘密鍵
print()

m1 = 3
c1 = elgamal_encrypt(m1, pk)
m2 = 7
c2 = elgamal_encrypt(m2, pk)
print('m1:', m1)
print('m2:', m2)
print('c1:', c1)
print('c2:', c2)

c = [ (a * b) % p for a, b in zip(c1, c2) ]
print('c1*c2:', tuple(c))

d = elgamal_decrypt(c, pk, sk)
print('d:', d)
# => 21
```

実行結果は次のようになります（公開鍵、秘密鍵、暗号文は毎回ランダムです）。

```
pk: (867121, 227569, 303875)
sk: 159766

m1: 3
m2: 7
c1: (84634, 589353)
c2: (41442, 843260)
c1*c2: (764904, 416445)
d: 21
```

$3 \times 7 = 21$ となったので、ElGamal暗号は乗法準同型暗号であることをPythonで確認することができました。



### 参考文献

- [ElGamal暗号 - Wikipedia](https://ja.wikipedia.org/wiki/ElGamal%E6%9A%97%E5%8F%B7)
- [準同型暗号 - Wikipedia](https://ja.wikipedia.org/wiki/%E6%BA%96%E5%90%8C%E5%9E%8B%E6%9A%97%E5%8F%B7)
- [pycrypto/ElGamal.py at master · dlitz/pycrypto](https://github.com/dlitz/pycrypto/blob/master/lib/Crypto/PublicKey/ElGamal.py#L120)


-----

[^Bleichenbacher-attack]: ElGamal暗号では原始元を $g=2$ にしてはいけません。ElGamalに関するBleichenbacher攻撃（論文は『Generating ElGamal signatures without knowning the secret key』）があるからです。また、論文『[Insecure primitive elements in an ElGamal signature protocol](https://arxiv.org/pdf/1509.01504.pdf)』はBleichenbacherの論文からの系 (Corollary) として、$g=2$ を含むいくつかの条件が重なったときにデジタル署名を捏造することが可能になると書かれています。
