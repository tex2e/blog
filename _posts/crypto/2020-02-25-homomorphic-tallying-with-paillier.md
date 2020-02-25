---
layout:        post
title:         "Paillier暗号(加法準同型暗号)と電子投票"
date:          2020-02-25
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

Paillier暗号には加法準同型性があり、電子投票において匿名性を保ちながら集計するシステムに利用することができます。

### 準同型暗号

暗号化アルゴリズム $\mathrm{Enc}$ について、暗号文 $\mathrm{Enc}(x), \mathrm{Enc}(y)$ を復号せずに $\mathrm{Enc}(x * y)$ ($*$ は任意の演算) を求めることができるとき、この暗号化アルゴリズムは準同型暗号といいます。

### Paillier暗号

Paillier暗号 (Paillier cryptosystem) とは、Pascal Paillier（パスカルペイエ）が1999年に提案した公開鍵暗号方式で、加法準同型性を持ちます。
つまり、暗号文同士を掛け合わせ、復号すると、元の平文同士の足し算ができる性質を持っています。

アルゴリズムやPythonプログラムについては、前回の記事「[Paillier暗号と準同型性](/blog/crypto/paillier-cryptosystem)」で説明しています。

### Paillier暗号による電子投票

電子投票をするにあたって、以下の変数を使います。

- $N_v$ -- 投票者の人数
- $N_c$ -- 候補者の人数
- $b$ -- 投票先を区別するための基数 ($b > N_v$)

投票者が $k$ 番目の候補者に投票するときは、$b^{k-1}$ が投票内容 (平文) になります。

例えば投票者の人数が 9 人以下、候補者の人数が 4 人、基数が 10 として、
ある投票者が 3 番目の候補者に投票したいとき、投票内容は $m_3 = 10^2$ になります。

次に、Paillier暗号の鍵生成アルゴリズムで公開鍵と秘密鍵を作成し、全ての投票者の投票内容 $m_i$ は、この公開鍵を使って暗号化します。
以下、暗号化した内容を $c_i$ とします。

$$c_i = \mathrm{Enc}(m_i)$$

票の集計では、全ての投票者の暗号化した投票内容 $c_i$ の総乗を求めます。

$$T = \prod_{i=1}^{N_v} c_i \;\mathrm{mod}\; n^2$$

最後に復号すると、集計結果 $r_i$ ($i$ は候補者の番号) が得られます。

$$
\begin{align}
\mathrm{result} &= \mathrm{Dec}(T) \\
&= r_1 b^0 + r_2 b^1 + \cdots{} + r_{N_c} b^{N_c-1}
\end{align}
$$

<br>
### 例

例えば、候補者が Alice, Bob, Carol, Eve の4人いて、投票者の投票先が以下のようになっているとき、投票先が同じであっても、Paillier暗号の暗号アルゴリズムの中では乱数を用いているので、毎回異なる暗号文が生成されます。

|  | Alice | Bob | Carol | Eve | 投票内容 | 暗号化
|--|:--:|:--:|:--:|:--:|:--:|--|
| 投票者1 | | ✓ | | | $10^1$ | 352383349525077262449525
| 投票者2 | | | ✓ | | $10^2$ | 13837526067913389032491
| 投票者3 | | | | ✓ | $10^3$ | 75001838130591097800131
| 投票者4 | ✓ | | | | $10^0$ | 141162745945657568291949
| 投票者5 | | ✓ | | | $10^1$ | 12075320347866366856066
| 投票者6 | | | ✓ | | $10^2$ | 172369554558408991837683
| 投票者7 | | ✓ | | | $10^1$ | 217595884868785666016989
| 投票者8 | | ✓ | | | $10^1$ | 43538715940098383104990

暗号化した投票内容の総乗を求めると、次のようになります（公開鍵の $n$ は 40bit 長の整数で、この例では $n = 615188791981$ です）。

$$T = \prod_{i=1}^{N_v} c_i \;\mathrm{mod}\; n^2 = 272575810252445626267672$$

$T$ を秘密鍵で復号すると $1241$ となり、「Alice 1票、Bob 4票、Carol 2票、Eve 1票」であることがわかります。

### プログラム

以上の電子投票の内容はPythonで計算したものです。

```python
import math
from functools import reduce

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
print('n:', n)

# 各投票者の暗号化した投票内容
voter1_enc = paillier_encrypt(10**1, pk)
print('voter1_enc:', voter1_enc)
voter2_enc = paillier_encrypt(10**2, pk)
print('voter2_enc:', voter2_enc)
voter3_enc = paillier_encrypt(10**3, pk)
print('voter3_enc:', voter3_enc)
voter4_enc = paillier_encrypt(10**0, pk)
print('voter4_enc:', voter4_enc)
voter5_enc = paillier_encrypt(10**1, pk)
print('voter5_enc:', voter5_enc)
voter6_enc = paillier_encrypt(10**2, pk)
print('voter6_enc:', voter6_enc)
voter7_enc = paillier_encrypt(10**1, pk)
print('voter7_enc:', voter7_enc)
voter8_enc = paillier_encrypt(10**1, pk)
print('voter8_enc:', voter8_enc)

# 集計（暗号化した投票内容の総乗）
T = [voter1_enc, voter2_enc, voter3_enc, voter4_enc,
     voter5_enc, voter6_enc, voter7_enc, voter8_enc]
tallying = reduce(lambda x,y: (x * y) % (n * n), T)
print(tallying)

# 集計結果
d = paillier_decrypt(tallying, pk, sk)
print('tallying result:', d)
```

実行結果は以下のようになります（公開鍵、秘密鍵、暗号化したデータは毎回ランダムです）。

```
pk: (615188791981, 337126140628163909244135)
sk: (21970971904, 250606002456)
n: 615188791981
voter1_enc: 352383349525077262449525
voter2_enc: 13837526067913389032491
voter3_enc: 75001838130591097800131
voter4_enc: 141162745945657568291949
voter5_enc: 12075320347866366856066
voter6_enc: 172369554558408991837683
voter7_enc: 217595884868785666016989
voter8_enc: 43538715940098383104990
272575810252445626267672
tallying result: 1241
```

復号結果は 1241 となり、「Alice 1票、Bob 4票、Carol 2票、Eve 1票」であることがわかります。

<br>
### 欠点

電子投票において匿名性を保ちながら票を集計するには、加法準同型性が役に立ちますが、システムとして実運用するにはいくつかの課題があります。

- **不正投票の防止** : 投票内容が正当か（$b^k$ の形以外の内容が送信されていないか。正当性を確認するためには復号する必要があるが、開票前に見るのは公平性に反する）
- **二重投票の防止** : 投票者が投票済みであることをどう調べるか（匿名化された票からは知ることができない）
- **公平性** : 選挙の途中結果を利用した不正ができない（秘密鍵を持っている開票者は信頼できるのか）
- **自由意志** : 誰にも強制されず、自由な意思で投票しているか (電子投票全般にいえる課題)

これらの課題を解決するまでは、電子投票のシステムはまだ世に浸透していかないと思っているので、なんとか技術で解決していきたいのが所感です。



- 前回：[Paillier暗号と準同型性](/blog/crypto/paillier-cryptosystem)

### 参考文献

- [Homomorphic Tallying with Paillier Cryptosystem](http://security.hsr.ch/msevote/seminar-papers/HS09_Homomorphic_Tallying_with_Paillier.pdf)
- [A Homomorphic Crypto System for Electronic Election Schemes](https://file.scirp.org/pdf/CS_2016082314213901.pdf)
- [homomorphic encryption - Anonymity of Paillier cryptosystem in e-voting system - Cryptography Stack Exchange](https://crypto.stackexchange.com/questions/60493/anonymity-of-paillier-cryptosystem-in-e-voting-system)
- [電子投票 - Wikipedia](https://nlp.cs.nyu.edu/meyers/controversial-wikipedia-corpus/japanese-html/main/main_0219.xml.html)
- [ozsaygin/elgamal-evoting： ElGamal E-Voting Scheme Implementation](https://github.com/ozsaygin/elgamal-evoting)
- [data61/python-paillier： A library for Partially Homomorphic Encryption in Python](https://github.com/data61/python-paillier)
- [Cryptography - Electronic Voting](https://crypto.stanford.edu/pbc/notes/crypto/voting.html)
