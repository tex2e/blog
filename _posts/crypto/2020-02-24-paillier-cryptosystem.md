---
layout:        post
title:         "Paillier暗号と準同型性"
date:          2020-02-24
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
# sitemap: false
# draft:   true
---

Paillier暗号 (Paillier cryptosystem) とは、Pascal Paillier（パスカルペイエ）が1999年に提案した公開鍵暗号方式です。素因数分解を安全性の根拠としている暗号で、加法準同型性を持ちます。つまり、暗号文同士を掛け合わせ、復号すると、元の平文同士の足し算ができる性質を持っています。
ここでは、Paillier暗号をPythonで実装していき、加法準同型性を確認します。

まず、Paillier暗号は鍵生成、暗号化、復号の3つのアルゴリズムから構成されています。

- **鍵生成アルゴリズム**

    $k$ はセキュリティパラメータとする。

    1. 2つの素数 $p, q$ をランダムに選ぶ。
    2. $n = pq$ を計算する。
    3. $\lambda = \text{lcm}(p-1,q-1)$ で最小公倍数を計算する。
    4. $\mu = (L(g^\lambda \;\text{mod}\; n^2))^{-1} \;\text{mod}\; n$ を計算する。逆元が存在しない場合は、逆元が存在するまで $g$ を新たにランダムに選ぶ。関数 $L$ は $L(x) = (x-1) / n$ と定義される（$/$ は整数の割り算）。
    5. $(n, g)$ を公開鍵、$(\lambda, \mu)$ を秘密鍵とする。

- **暗号化アルゴリズム**

    平文 $m$ は $0 \le m < p$ とする。

    1. $0 < r < n$ となる整数 $r$ をランダムに選ぶ。
    2. $c = g^m \cdot{} r^n \;\text{mod}\; n^2$ を計算し、暗号文とする。

- **復号アルゴリズム**

    暗号文 $c$ は $0 \le c < n^2$ とする。

    1. $m = L(c^\lambda \;\text{mod}\; n^2) \cdot{} \mu \;\text{mod}\; n$ を計算し、平文とする。

Paillier暗号をPythonで実装すると以下のようになります。

```python
import math

# pip install pycryptodome
from Crypto.Util import number

def lcm(a, b):
    return (a * b) // math.gcd(a, b)

def xgcd(a, b):
    x0, y0, x1, y1 = 1, 0, 0, 1
    while b != 0:
        q, a, b = a // b, b, a % b
        x0, x1 = x1, x0 - q * x1
        y0, y1 = y1, y0 - q * y1
    return a, x0, y0

def modinv(a, m):
    g, x, y = xgcd(a, m)
    if g != 1:
        return None
    else:
        return x % m

def L(x, n):
    return (x - 1) // n

# 鍵生成アルゴリズム
def paillier_key_gen(bits):
    # 素数p, 素数q
    p = number.getPrime(bits // 2)
    while True:
        q = number.getPrime(bits // 2)
        if p != q:
            break
    n = p * q
    λ = lcm(p-1, q-1)
    # 原始元g
    while True:
        g = number.getRandomRange(2, n*n)
        μ = modinv(L(pow(g, λ, n*n), n) % n, n)
        if μ is not None:
            break
    return (n, g), (λ, μ)

# 暗号化アルゴリズム
def paillier_encrypt(m, pk):
    n, g = pk
    nn = n * n
    assert(0 <= m < n)
    while True:
        r = number.getRandomRange(2, n)
        if math.gcd(r, n) == 1:
            break
    return (pow(g, m, nn) * pow(r, n, nn)) % nn

# 復号アルゴリズム
def paillier_decrypt(c, pk, sk):
    n, g = pk
    λ, μ = sk
    assert(0 <= c < n*n)
    return (L(pow(c, λ, n*n), n) * μ) % n


# 鍵ペアの生成
pk, sk = paillier_key_gen(bits=40)
n, _ = pk
print('pk:', pk)
print('sk:', sk)
print()

m = 3141592
print('m:', m)
c = paillier_encrypt(m, pk)
print('c:', c)
d = paillier_decrypt(c, pk, sk)
print('d:', d) # => 3141592
```

Paillier暗号で平文 3141592 を暗号化して復号した結果は次のようになります（公開鍵、秘密鍵、暗号文は毎回ランダムです）。

```
pk: (510647658509, 178078158177740834599086)
sk: (127661556120, 174418647983)

m: 3141592
c: 216114299821214446764128
d: 3141592
```

元の平文に戻り、正しく暗号化・復号ができています。

### 加法準同型性

Paillier暗号は加法準同型性を持ちます。

$$
\text{Dec}(\text{Enc}(m_1, r_1) \times \text{Enc}(m_2, r_2) \;\text{mod}\; n^2) = m_1 + m_2 \;\text{mod}\; n
$$

次のプログラムで実験してみます。

```python
m1 = 3
c1 = paillier_encrypt(m1, pk)
m2 = 7
c2 = paillier_encrypt(m2, pk)
print('m1:', m1)
print('m2:', m2)
print('c1:', c1)
print('c2:', c2)
c = (c1 * c2) % (n*n)
print('c1*c2:', c)
d = paillier_decrypt(c, pk, sk)
print('d:', d)
```

実行結果は次のようになり、2つの平文 $3$ と $7$ の暗号文を掛け合わせ、その結果を復号したものが $3 + 7 = 10$ となっていることが確認できます。

```
pk: (408437390201, 127697803716201990527853)
sk: (40843610610, 301635633414)

m1: 3
m2: 7
c1: 93507550774052941427646
c2: 144355422576338758561287
c1*c2: 152843155739826997997363
d: 10
```

### 乗法準同型性

正確には準同型ではないのですが、Paillier暗号では暗号化したまま乗算をすることができます。

$$
\text{Dec}(\text{Enc}(m_1, r_1)^{m_2} \;\text{mod}\; n^2) = m_1 \times m_2 \;\text{mod}\; n
$$

次のプログラムで実験してみます。

```python
m1 = 5
c1 = paillier_encrypt(m1, pk)
m2 = 9
print('m1:', m1)
print('m2:', m2)
print('c1:', c1)
c = pow(c1, m2, n*n)
print('c1*c2:', c)
d = paillier_decrypt(c, pk, sk)
print('d:', d)
```

実行結果は次のようになり、2つの平文 $5$ と $9$ の暗号文を掛け合わせ、その結果を復号したものが $5 \times 9 = 45$ となっていることが確認できます。

```
pk: (350392165687, 69194248187097964231957)
sk: (175195490888, 170396536861)

m1: 5
m2: 9
c1: 91369552538125172084141
c1*c2: 33233824602878182680429
d: 45
```

- 前回：[修正ElGamal暗号の加法準同型性](./modified-elgamal-encryption)
- 次回：[Paillier暗号と電子投票](./homomorphic-tallying-with-paillier)

### 参考文献

- [Paillier cryptosystem - Wikipedia](https://en.wikipedia.org/wiki/Paillier_cryptosystem)
- [Paillier暗号(Paillier cryptosystem) - Qiita](https://qiita.com/tnakagawa/items/b1e55e66ae017b0c9d78)
- [公開鍵暗号 - Paillier暗号 - ₍₍ (ง ˘ω˘ )ว ⁾⁾ < 暗号楽しいです](http://elliptic-shiho.hatenablog.com/entry/2015/12/14/213328)
