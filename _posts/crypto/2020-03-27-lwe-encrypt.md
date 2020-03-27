---
layout:        post
title:         "LWE格子暗号による暗号化・復号"
date:          2020-03-27
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
# sitemap: false
# draft:   true
---

量子コンピュータの進歩に伴い、耐量子計算機暗号（Post-Quantum Cryptography; PQC）が注目されています。LWE問題はGapSVP（決定版の最短ベクトル問題）やSIVP（最短独立ベクトル問題）などの格子問題に基づいていて、効率よく（多項式時間で）解くことのできるアルゴリズム・量子アルゴリズムは見つかっていない（見つからないと信じられている）ため、安全とされています。
$$
\gdef\Z{\mathbb{Z}}
\gdef\vec#1{\textbf{#1}}
$$

### LWE格子暗号による1bitの暗号化・復号

まずは簡単な例として1bitの平文を暗号化・復号します。
プログラムは [LWE格子暗号による暗号化をやってみる - ももいろテクノロジー](http://inaz2.hatenablog.com/entry/2017/05/27/003343) を参考にしました。
より詳しい説明は [量子コンピュータの解読に耐えうる暗号アルゴリズム「格子暗号」の最新動向 -- 日本銀行金融研究所](https://www.imes.boj.or.jp/research/papers/japanese/15-J-09.pdf) を参照してください。

- **共通パラメータの設定**
  1. 利用する格子の次元 $n$ と素数 $q$ を選ぶ。
  2. $n$ 本の $n \times 1$ 行列 $\vec{a}_1, ..., \vec{a}_n$ を選び、要素ベクトルとした上で、これらの組を $n \times n$ 行列 $\vec{A} \in \Z_q^{n \times n}$ と表現し、これを基底とする。基底 $\vec{A}$ は非直行型である。
  3. 誤差の大きさに関するパラメータ $\alpha$ を選ぶ。

- **秘密鍵・公開鍵の設定**
  1. 受信者は秘密鍵 $\vec{s} \in \Z_q^{n \times 1}$ をランダムに選ぶ。
  2. 格子点 $\Z_q^{n \times 1} \ni \vec{G} = \vec{A} \cdot{} \vec{s} \mod q$ を求める。
  3. 実数 $\alpha$ により定まる確率分布 $\Psi_\alpha$ を使って誤差ベクトル $\vec{e} \in \Z_q^{n \times 1}$ を生成する。
  4. 公開鍵 $\Z_q^{n \times 1} \ni \vec{T} = \vec{G} + \vec{e} \mod q$ を求める。

- **暗号化の処理**
  1. 送信者は確率分布 $\Psi_\alpha$ を使って誤差ベクトル $\vec{r} \in \Z_q^{1 \times n}$ を生成する。
  2. $\vec{C}_1 = \vec{r} \cdot{} \vec{A} \mod q$ を求める。$\vec{C}_1 \in \Z_q^{1 \times n}$
  3. 平文が「1」のときは $M = (q+1)/2$ を、「0」のときは $M = 0$ を設定する。
  4. $C_2 = \vec{r} \cdot{} \vec{T} - M \mod q $ を求める。$C_2 \in \Z_q$
  5. 得られた $(\vec{C}_1, C_2) \in \Z_q^{1 \times n} \times \Z_q$ を暗号文とする。

- **復号の処理**
  1. 暗号文 $(\vec{C}_1, C_2)$ と秘密鍵 $\vec{s}$ を用意する。
  2. $p = \vec{C}_1 \cdot{} \vec{s} - C_2 \mod q$ を求める。$p \in \Z_q$
  3. $(q+1)/4 < p < 3(q+1)/4$ のときは「1」、それ以外は「0」を平文とする。


```python
import random
import numpy as np

n = 230  # 格子の次元
q = 2053 # 法とする素数
A = np.random.randint(q, size=(n, n)) # 基底
alpha = 8.0 # 誤差分布のパラメータ

def randint_from_gaussian(size):
    sigma = alpha / np.sqrt(2 * np.pi)
    x = np.random.normal(0, sigma, size)
    return np.rint(x)

def encrypt(plaintext):
    r = randint_from_gaussian(size=n)
    C1 = r.dot(A) % q
    M = (q+1)/2 * plaintext
    C2 = (r.dot(T) - M) % q
    return C1, C2

def decrypt(ciphertext, s):
    C1, C2 = ciphertext
    p = (C1.dot(s) - C2) % q
    return int((q+1)/4 < p < 3*(q+1)/4)

print('lattice basis: A = \n', A)
print()

# 秘密鍵と公開鍵の設定
s = np.random.randint(q, size=n)
G = A.dot(s) % q
e = randint_from_gaussian(size=n)
T = (G + e) % q

print('[+] secret key')
print('s =\n', s)
print('e =\n', e)
print('[+] public key')
print('T =\n', T)
print()

# 暗号化
plain_bit = random.randint(0, 1)
print('[+] plain_bit = %d' % plain_bit)
print()
C1, C2 = encrypt(plain_bit)
print('[+] ciphertext')
print('C1 =\n', C1)
print('C2 =\n', C2)
print()

# 復号
decrypted_bit = decrypt((C1, C2), s)
print('[+] decrypted_bit = %d' % decrypted_bit)
```

暗号化して復号したら元の平文に戻ることを確認すると、以下の式のようになります。

$$
\begin{aligned}
\vec{C}_1 &= \vec{r} \cdot{} \vec{A} \\[3pt]
C_2 &= \vec{r} \cdot{} \vec{T} - M \\
    &= \vec{r} \cdot{} (\vec{G} + \vec{e}) - M \\
    &= \vec{r} \cdot{} (\vec{A} \cdot{} \vec{s} + \vec{e}) - M \\[9pt]
\mathrm{Dec}(\vec{C}_1, C_2)
    &= \vec{C}_1 \cdot{} \vec{s} - C_2 \mod q \\
    &= \vec{r} \cdot{} \vec{A} \cdot{} s - (\vec{r} \cdot{} (\vec{A} \cdot{} \vec{s} + \vec{e}) - M) \mod q \\
    &= \vec{r} \cdot{} \vec{A} \cdot{} s - (\vec{r} \cdot{} \vec{A} \cdot{} \vec{s} + \vec{r} \cdot{} \vec{e} - M) \mod q \\
    &= - \vec{r} \cdot{} \vec{e} + M \mod q \\
    &= M
\end{aligned}
$$

途中式のところで、$-\vec{r}\cdot{}\vec{e}$ は高確率で $-(q+1)/4 < -\vec{r}\cdot{}\vec{e} < (q+1)/4$ となることが知られているので、誤差を取り除くように $-\vec{r}\cdot{}\vec{e}$ を除去することができます。


### LWE格子暗号による複数bitの暗号化・復号

一般的に平文は複数ビットです。複数ビットを暗号化するときは秘密鍵のベクトル $\vec{s} \in \Z_q^{n \times 1}$ を秘密行列 $\vec{S} \in \Z_q^{n \times n}$ に変更します。
合わせて、誤差ベクトル $\vec{e} \in \Z_q^{n \times 1}, \vec{r} \in \Z_q^{1 \times n}$ も、誤差行列 $\vec{E}, \vec{R} \in \Z_q^{n \times n}$ に変更します。

- **秘密鍵・公開鍵の設定**
  1. 受信者は秘密鍵 $\vec{S} \in \Z_q^{n \times n}$ をランダムに選ぶ。
  2. 格子点 $\Z_q^{n \times n} \ni \vec{G} = \vec{A} \cdot{} \vec{S} \mod q$ を求める。
  3. 実数 $\alpha$ により定まる確率分布 $\Psi_\alpha$ を使って誤差行列 $\vec{E} \in \Z_q^{n \times n}$ を生成する。
  4. 公開鍵 $\Z_q^{n \times n} \ni \vec{T} = \vec{G} + \vec{E} \mod q$ を求める。

- **暗号化の処理**
  1. 送信者は確率分布 $\Psi_\alpha$ を使って誤差行列 $\vec{R} \in \Z_q^{n \times n}$ を生成する。
  2. $\vec{C}_1 = \vec{R} \cdot{} \vec{A} \mod q$ を求める。$\vec{C}_1 \in \Z_q^{n \times n}$
  3. 平文 $$\vec{M} \in \{0,1\}^{n^2}$$ について、任意の1bitが「1」のときは $M_i = (q+1)/2$ を、「0」のときは $M_i = 0$ を設定する。
  4. 平文を1次元の行列 $$\vec{M} \in \{0,1\}^{n^2}$$ から2次元の行列 $$\vec{M} \in \{0,1\}^{n \times n}$$ に変換する（平文が足りないときはパディングする）。
  4. $\vec{C}_2 = \vec{R} \cdot{} \vec{T} - \vec{M} \mod q$ を求める。$\vec{C}_2 \in \Z_q^{n \times n}$
  5. 得られた $(\vec{C}_1, \vec{C}_2) \in \Z_q^{n \times n} \times \Z_q^{n \times n}$ を暗号文とする。

- **復号の処理**
  1. 暗号文 $(\vec{C}_1, \vec{C}_2)$ と秘密鍵 $\vec{S}$ を用意する。
  2. $\vec{p} = \vec{C}_1 \cdot{} \vec{S} - \vec{C}_2 \mod q$ を求める。$\vec{p} \in \Z_q^{n \times n}$
  3. $(q+1)/4 < p_i < 3(q+1)/4$ のときは「1」、それ以外は「0」を平文とする。

```python
import numpy as np

n = 230  # 格子の次元
q = 2053 # 法とする素数
A = np.random.randint(q, size=(n, n)) # 基底
alpha = 6.0 # 誤差分布のパラメータ

def randint_from_gaussian(size):
    sigma = alpha / np.sqrt(2 * np.pi)
    x = np.random.normal(0, sigma, size)
    return np.rint(x)

def encrypt(plaintext):
    R = randint_from_gaussian(size=(n, n))
    C1 = R.dot(A) % q
    M = (q+1)/2 * plaintext
    C2 = (R.dot(T) - M) % q
    return C1, C2

def decrypt(ciphertext, S):
    C1, C2 = ciphertext
    P = (C1.dot(S) - C2) % q
    return np.vectorize(lambda p: int((q+1)/4 < p < 3*(q+1)/4))(P)

print('lattice basis: A = \n', A)
print()

# 秘密鍵と公開鍵の設定
S = np.random.randint(q, size=(n, n))
G = A.dot(S) % q
E = randint_from_gaussian(size=(n, n))
T = (G + E) % q

print('[+] secret key')
print('S =\n', S)
print('E =\n', E)
print('[+] public key')
print('T =\n', T)
print()

# 暗号化
plain_bits = np.random.randint(0, 2, size=(n, n))
print('[+] plain_bits = \n', plain_bits)
print()
C1, C2 = encrypt(plain_bits)
print('[+] ciphertext')
print('C1 =\n', C1)
print('C2 =\n', C2)
print()

# 復号
decrypted_bits = decrypt((C1, C2), S)
print('[+] decrypted_bits =\n', decrypted_bits)
print()
print('plain_bits == decrypted_bits:', np.array_equal(plain_bits, decrypted_bits))
```

平文 $$M \in \{0,1\}^{n \times n}$$ をランダムに決めて、暗号化し、復号した結果を以下のように出力すると、元の平文に戻っていることが確認できます。

```output
lattice basis: A =
 [[1801  972 1429 ...  112 2042 1350]
 [ 348  329 1052 ...  978 1591 1479]
 [1035 1966  929 ...  230  286 1432]
 ...
 [  94 1924  908 ... 1470  558 1990]
 [1945  981 1516 ... 1007  564 1018]
 [ 966  943 1746 ... 1900  891 1410]]

[+] secret key
S =
 [[1520 1833 1586 ... 1396 1515 1509]
 [1753  473   42 ...  536 1419 1620]
 [ 285 1470  991 ... 1055 1656  577]
 ...
 [ 498 1067 1602 ...  195 1270   19]
 [1704  958 1842 ... 1642 1656  823]
 [ 617 1937  293 ... 1991   77  341]]
E =
 [[-1. -1.  1. ... -4. -2. -2.]
 [ 3.  1. -2. ...  2. -2.  4.]
 [-1. -0.  1. ...  7. -1.  0.]
 ...
 [ 2.  2.  4. ... -0.  0.  1.]
 [ 2. -0.  1. ...  3.  0.  2.]
 [-2.  2.  2. ... -3. -1. -1.]]
[+] public key
T =
 [[1665. 1456.  997. ...    9.  926.  403.]
 [1739. 1267.  345. ... 1546. 1160.  520.]
 [1380. 1802. 1570. ...  487.  347. 1693.]
 ...
 [1307. 1444.  736. ...   25. 1310. 1203.]
 [1042. 1646.  339. ...  694. 1968.  888.]
 [2007. 1821.  282. ... 1025.  164. 1554.]]

[+] plain_bits =
 [[1 0 1 ... 0 1 0]
 [0 1 0 ... 1 0 1]
 [1 0 0 ... 1 0 1]
 ...
 [1 1 1 ... 0 1 0]
 [1 1 1 ... 0 0 1]
 [0 0 1 ... 1 0 1]]

[+] ciphertext
C1 =
 [[ 627. 1823. 1900. ... 1174.  308. 1841.]
 [ 679.  405. 1841. ... 1167.  602. 1045.]
 [ 746.  973. 1876. ... 1686. 1658. 1277.]
 ...
 [1250. 1806. 1827. ...  815. 1719.  772.]
 [1921.  788. 1331. ...  388.  799. 1719.]
 [ 158.   46. 1937. ...  883.  592. 1019.]]
C2 =
 [[1581.  570. 1086. ...  821.  910.  884.]
 [  32.  784. 1644. ...  974.  289.  600.]
 [1888.  312.   80. ...  335.  278. 1521.]
 ...
 [1243. 1462. 1712. ... 1776.  509.  697.]
 [ 465. 1044. 1935. ... 2043. 1301.  364.]
 [1315. 1015.  543. ...  454.   42. 1035.]]

[+] decrypted_bits =
 [[1 0 1 ... 0 1 0]
 [0 1 0 ... 1 0 1]
 [1 0 0 ... 1 0 1]
 ...
 [1 1 1 ... 0 1 0]
 [1 1 1 ... 0 0 1]
 [0 0 1 ... 1 0 1]]

plain_bits == decrypted_bits: True
```

以上です。
