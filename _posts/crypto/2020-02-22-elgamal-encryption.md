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


原始元を生成する部分は注意が必要です。
$g$ が原始元[^generator-count]であれば、素数 $p$ を法としたとき、$p-1$ 乗して初めて $1$ になります。
つまり、$1 \le i \le p-2$ について次の式が成り立てば、$g$ は原始元になります。

$$g^i \ne 1 \mod p$$

しかし、もっと効率よく原始元を判定する方法があります。
位数は $p - 1$ を割り切ることを利用して、$p - 1 = q_0^{e_0}\cdots{}q_s^{e_s}$ のように素因数分解したとき、$0 \le i \le s$ において次の式が成り立てば、$g$ が法 $p$ の原始元になります。

$$g^{(p-1)/q_i} \ne 1 \mod p$$

この方法では素因数分解をする必要がありますが、素数 $p$ が $p = 2q + 1$ (素数 $q$) の形で表せるときは、$p-1$ の素因数は $2$ と $q$ だけです。
よって、次の原始元判定アルゴリズムを使うことができます。

- **原始元判定アルゴリズム**

    $g$ を原始元かを判定したい整数、$p$ を $2q + 1$ (素数 $q$) の形式の素数とする。

    1. $g = 1 \mod p$ が成り立てば「$g$ は原始元ではない」と判定する。
    2. $g^2 = 1 \mod p$ が成り立てば「$g$ は原始元ではない」と判定する。
    3. $g^q = 1 \mod p$ が成り立てば「$g$ は原始元ではない」と判定する。
    4. それ以外であれば、「$g$ は原始元である」と判定する。

[^generator-count]: 素数 $p$ を選んだとき、原始元は $\varphi(p-1)$ 個存在することが知られています。

ElGamal暗号をPythonで実装すると以下のようになります。

```python
# ElGamal暗号

# pip install pycryptodome
from Crypto.Util import number

# 鍵生成アルゴリズム
def elgamal_gen_key(bits):
    # 素数p
    while True:
        q = number.getPrime(bits-1)
        p = 2*q + 1
        if number.isPrime(p):
            break
    # 原始元g
    while True:
        g = number.getRandomRange(3, p)
        # 原始元判定
        if pow(g, 2, p) == 1:
            continue
        if pow(g, q, p) == 1:
            continue
        break
    # 秘密値x
    x = number.getRandomRange(2, p-1)
    # 公開値y
    y = pow(g, x, p)
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
pk: (814829, 722592, 149977)
sk: 109984

m: 314159
c: (299442, 126502)
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
pk: (722027, 286579, 294883)
sk: 56582

m1: 3
m2: 7
c1: (358570, 110955)
c2: (544625, 262346)
c1*c2: (265587, 81925)
d: 21
```

$3 \times 7 = 21$ となったので、ElGamal暗号は乗法準同型暗号であることをPythonで確認することができました。



### 参考文献

- [ElGamal暗号 - Wikipedia](https://ja.wikipedia.org/wiki/ElGamal%E6%9A%97%E5%8F%B7)
- [準同型暗号 - Wikipedia](https://ja.wikipedia.org/wiki/%E6%BA%96%E5%90%8C%E5%9E%8B%E6%9A%97%E5%8F%B7)
- [pycrypto/ElGamal.py at master · dlitz/pycrypto](https://github.com/dlitz/pycrypto/blob/master/lib/Crypto/PublicKey/ElGamal.py#L120)


-----

[^Bleichenbacher-attack]: ElGamal暗号では原始元を $g=2$ にしてはいけません。ElGamalに関するBleichenbacher攻撃（論文は『Generating ElGamal signatures without knowning the secret key』）があるからです。また、論文『[Insecure primitive elements in an ElGamal signature protocol](https://arxiv.org/pdf/1509.01504.pdf)』はBleichenbacherの論文からの系 (Corollary) として、$g=2$ を含むいくつかの条件が重なったときにデジタル署名を捏造することが可能になると書かれています。
