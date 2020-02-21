---
layout:        post
title:         "安全素数の生成方法"
date:          2020-02-21
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

安全素数を生成する方法を Python で実装します。
安全素数とは、素数 $q$ のとき $p = 2q + 1$ の形で表せる素数 $p$ を安全素数といいます。
素因数分解アルゴリズムの p - 1 法に耐えるためには、$p - 1$ が大きな素因数を持つものを選ぶ必要があり、安全素数はこの性質を持つために安全と呼ばれます。

- **安全素数の生成アルゴリズム**

    生成したい素数のビット長 $k$ を入力する。

    1. $p$ が素数になるまで、以下を繰り返す。
        1. $k-1$ビットの素数 $q$ を生成する。
        2. $p = 2q + 1$ を計算して、$p$ が素数か判定する。

素数の生成には[Miller-Rabin素数判定法](/blog/crypto/miller-rabin-test)を使います。
安全素数の生成方法を Python で実装したものは以下の通りです。

```python
import random
import secrets

# Miller-Rabin素数判定法
def miller_rabin_test(n):
    if n <= 1:
        return False
    k = 0
    m = n - 1
    while m & 1 == 0:
        k += 1
        m >>= 1
    assert(2**k * m == n - 1)

    def trial(n):
        a = random.randint(2, n - 1)
        b = pow(a, m, n)
        if b == 1:
            return True
        for i in range(0, k):
            if b == n - 1:
                return True
            b = pow(b, 2, n)
        return False

    for i in range(10):
        if not trial(n):
            return False
    return True

# Miller-Rabin素数判定法を用いたRandomChoice素数生成法
def get_prime(bits):
    while True:
        num = secrets.randbits(bits)
        if miller_rabin_test(num):
            return num

# 安全素数の生成
def get_safe_prime(bits):
    while True:
        q = get_prime(bits-1)
        p = 2*q + 1
        if miller_rabin_test(p):
            return p
```

実行した結果は次の通りです。

```
get_safe_prime(20)
# => 29123
get_safe_prime(100)
# => 998253646717961301888879123359
get_safe_prime(100)
# => 847896611978968344495556288823
```

安全素数 $p = 2q + 1$ を満たしているか確認すると

```python
14561 * 2 + 1 == 29123
499126823358980650944439561679 * 2 + 1 == 998253646717961301888879123359
423948305989484172247778144411 * 2 + 1 == 847896611978968344495556288823
```

上の式は全て True になり、WolframAlpha で確認したら $p, q$ は素数と判定されます。


### 参考文献

- [安全素数 - Wikipedia](https://ja.wikipedia.org/wiki/%E5%AE%89%E5%85%A8%E7%B4%A0%E6%95%B0)
- [Handbook of Applied Cryptography](https://doc.lagout.org/network/3_Cryptography/CRC%20Press%20-%20Handbook%20of%20applied%20Cryptography.pdf), Algorithm 4.86
