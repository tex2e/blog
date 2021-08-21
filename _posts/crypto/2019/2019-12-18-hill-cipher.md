---
layout:        post
title:         "ヒル暗号をPythonで実装する"
date:          2019-12-18
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
# sitemap: false
# draft:   true
---

ヒル暗号 (Hill Cipher) は、1929年に Lester S. Hill によって作られた暗号で換字式暗号の一つです。
ヒル暗号は線形代数に基づいているので、行列の基本的な知識があればわかります。
ヒル暗号自体は古典暗号に分類されますが、AESの内部処理でヒル暗号と似た構造があるので、ヒル暗号を勉強する価値はあると思います。

### ヒル暗号の定義

$m$ はある固定された正の整数とし、$P = C = (\mathbb{Z}_{26})^m$ とします (つまり平文と暗号文の型とサイズは同じです)。
さらに $$K = \{\mathbb{Z}_{26} \;\text{上の}\; m \times m \;\text{の可逆行列} \}$$ とします。
鍵 $K$ に対して、暗号化と復号を次のように定義します。

$$
\begin{aligned}
\mathrm{enc}_K(x) &= xK \\
\mathrm{dec}_K(y) &= yK^{-1} \\
\end{aligned}
$$

ただし、全ての演算は $\mathbb{Z}_{26}$ 上で行われます。


### 例

$m = 2$ として、暗号化鍵 $K$ を次のようにします ($ad - bc \ne 0$ なので可逆行列です)。

$$
K =
\begin{pmatrix}
5 & 3 \\
3 & 4
\end{pmatrix}
$$

このとき復号鍵 $K^{-1}$ は次のように求めることができます。
ただし、要素の演算は $\mathbb{Z}_{26}$ 上で行われます。
つまり全ての演算が法 26 の下で行われます。

$$
\begin{aligned}
K^{-1} &=
(ad - bc)^{-1}
\begin{pmatrix}
d & -b \\
-c & a
\end{pmatrix} \\
&\equiv
11^{-1}
\begin{pmatrix}
4 & -3 \\
-3 & 5
\end{pmatrix}
\equiv
19
\begin{pmatrix}
4 & -3 \\
-3 & 5
\end{pmatrix}
\pmod{26} \\
&\equiv
\begin{pmatrix}
76 & -57 \\
-57 & 95
\end{pmatrix}
\pmod{26} \\
&=
\begin{pmatrix}
24 & 21 \\
21 & 17
\end{pmatrix}
\end{aligned}
$$

プログラムによるモジュラ逆数の求め方は [Pythonでモジュラ逆数を求める](https://tex2e.github.io/blog/crypto/modular-mul-inverse) を参照してください。

例えば平文を「OK」とすると、Oは14番目、Kは10番目のアルファベットなので、平文 $P$ は次のようになります。

$$
P =
\begin{pmatrix}
14 & 10
\end{pmatrix}
$$

平文 $P$ を暗号化した暗号文 $C$ は次のようになります。

$$
\begin{aligned}
C &\equiv
\begin{pmatrix}
14 & 10
\end{pmatrix}
\begin{pmatrix}
5 & 3 \\
3 & 4
\end{pmatrix}
\pmod{26} \\
&\equiv
\begin{pmatrix}
100 & 82
\end{pmatrix}
\pmod{26} \\
&=
\begin{pmatrix}
22 & 4
\end{pmatrix}
\end{aligned}
$$

暗号文 $C$ を復号した平文 $P'$ は次のようになります。

$$
\begin{aligned}
P' &\equiv
\begin{pmatrix}
22 & 4
\end{pmatrix}
\begin{pmatrix}
24 & 21 \\
21 & 17
\end{pmatrix}
\pmod{26} \\
&\equiv
\begin{pmatrix}
612 & 530
\end{pmatrix}
\pmod{26} \\
&=
\begin{pmatrix}
14 & 10
\end{pmatrix}
\end{aligned}
$$


### プログラム例

ヒル暗号を Python で実装した例を以下に示します。

```python
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
        raise Exception('modular inverse does not exist')
    else:
        return x % m

def gen_K_inv(K):
    a, b = K[0]
    c, d = K[1]
    D = modinv(a*d - b*c, 26)
    print(a*d - b*c) # => 11
    print(D)         # => 19
    aa = ( d * D) % 26
    bb = (-b * D) % 26
    cc = (-c * D) % 26
    dd = ( a * D) % 26
    return [[aa, bb], [cc, dd]]

def mul(K, X):
    C = [0] * 2
    C[0] = (X[0] * K[0][0] + X[1] * K[1][0]) % 26
    C[1] = (X[0] * K[0][1] + X[1] * K[1][1]) % 26
    return C


K = [[5, 3], [3, 4]] # 暗号化鍵
K_inv = gen_K_inv(K) # 復号鍵
print(K_inv) # => [[24, 21], [21, 17]]

P = [14, 10] # 平文
C = mul(K, P) # 暗号化
print(C) # => [22, 4]

P2 = mul(K_inv, C) # 復号
print(P2) # => [14, 10]
```


### セキュリティ

基本的なヒル暗号 (Hill Cipher) は線形なので既知平文攻撃 (Known-plaintext attack) に脆弱です。
行列の乗算だけでは安全な暗号を提供できませんが、他の非線形な演算と組み合わせることで、安全で実用的な暗号を作ることは可能です。
例えば AES には MixColumns というヒル暗号のように行列乗算をするステップと、SubBytes や ShiftRows という非線形な演算をするステップがあり、2つを組み合わせることで暗号を構成しています。いわゆる SPN 構造と呼ばれるものです。

#### 参考文献

- [Hill cipher - Wikipedia](https://en.wikipedia.org/wiki/Hill_cipher)
- [Rijndael MixColumns - Wikipedia](https://en.wikipedia.org/wiki/Rijndael_MixColumns)
- [AES (Rijndael) の MixColumns を理解する](https://tex2e.github.io/blog/crypto/aes-mix-columns)
