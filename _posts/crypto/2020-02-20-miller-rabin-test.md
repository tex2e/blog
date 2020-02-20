---
layout:        post
title:         "Miller-Rabin素数判定法"
date:          2020-02-20
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

Miller-Rabin (ミラーラビン) 素数判定法とは、与えられた整数が素数かどうかを判定する確率的アルゴリズムの一つです。
Python での本アルゴリズムの実装例を示します。

Miller-Rabin素数判定法のアルゴリズムは次の通りです。

- **Miller-Rabin素数判定法**

    $n$ を測定対象の整数とする。

    1. $n-1 = 2^k m$ となる $k,m$ を計算する。
    2. $2 \le a \le n-1$ を満たす整数 $a$ を無作為に選ぶ
    3. $b = a^m \mod n$ を計算する
    4. $b \equiv 1 \pmod{n}$ なら「$n$は素数である」と判定して停止する
    5. $i = 0$ から $k-1$ について、以下の計算を行う
        1. $b \equiv -1 \pmod{n}$ なら「$n$は素数である」と判定して停止する
        2. $b = b^2 \mod n$ を計算する
    6. 「$n$は合成数である」と判定して停止する

    このアルゴリズムで、$n$が合成数のとき「$n$は素数である」と判定される確率は $1/4$ 以下


Miller-Rabin素数判定法のPythonプログラムは次の通りです。

```python
# Miller-Rabin素数判定法
# nを測定対象の整数とする。
# このアルゴリズムで、nが合成数のとき「nは素数である」と判定される確率は 1/(4^10) 以下
def miller_rabin_test(n):
    if n <= 1:
        return False

    # (1) n-1 = 2^k * m となる k,m を計算する
    k = 0
    m = n - 1
    while m & 1 == 0:
        k += 1
        m >>= 1
    assert(2**k * m == n - 1)

    def trial(n):
        # (2) 2 ≦ a ≦ n-1 を満たす整数 a を無作為に選ぶ
        a = random.randint(2, n - 1)

        # (3) b = a^m mod n を計算する
        b = pow(a, m, n)

        # (4) b = 1 (mod n) なら「nは素数である」と判定して停止する
        if b == 1:
            return True

        # (5) i = 0 から k-1 について、以下の計算を行う
        for i in range(0, k):
            # (5.1) b = -1 (mod n) なら「nは素数である」と判定して停止する
            if b == n - 1:
                return True
            # (5.2) b = b^2 mod n を計算する
            b = pow(b, 2, n)

        # (6) 「nは合成数である」と判定して停止する
        return False

    # 繰り返しテストすることで誤った判定の確率を下げる
    for i in range(10):
        if not trial(n):
            return False

    return True
```

様々な整数で素数判定をした結果は以下の通りになります。

```
miller_rabin_test(10) # => False
miller_rabin_test(11) # => True
miller_rabin_test(12) # => False
miller_rabin_test(13) # => True
miller_rabin_test(57) # => False
miller_rabin_test(389754788748510373) # => True
miller_rabin_test(389754788748510379) # => False
miller_rabin_test(389754788748510389) # => True
```

### 判定の正確度

1回の判定で 3/4 以上の確率で合成数をふるい落とすことができます。
上のプログラムでは繰り返しテストする回数を10としていますが、試行回数をより多くすれば、正確度は高くなります。

また、他の確率的素数判定法である Fermat 法や Solovay-Strassen 法と比較して、Miller-Rabin 法はより高い確率で判定ができる、つまり素数を選り分ける能力が高いと言われています。

なお、Lucas–Lehmer法という素数判定法では強擬素数を合成数と判定することが可能になるので、実際に ANXI X9.80 では Miller-Rabin 法を数個の基底に関して実行した後に、Lucas-Lehmer 法を1度行うことが推奨されています[^1]。

### 参考文献

- [ミラー–ラビン素数判定法 - Wikipedia](https://ja.wikipedia.org/wiki/%E3%83%9F%E3%83%A9%E3%83%BC%E2%80%93%E3%83%A9%E3%83%93%E3%83%B3%E7%B4%A0%E6%95%B0%E5%88%A4%E5%AE%9A%E6%B3%95)
- [Miller–Rabin primality test - Rosetta Code](https://rosettacode.org/wiki/Miller%E2%80%93Rabin_primality_test#Python:_Probably_correct_answers)
- [廣瀬勝一. 整数論と代数の初歩, p. 42](http://fuee.u-fukui.ac.jp/~hirose/lectures/crypto_security/slides/01number_algebra.pdf)

-----

[^1]: [素数生成アルゴリズムの調査・開発 調査報告書 -- 情報処理振興事業協会 セキュリティセンター (2003)](https://www.ipa.go.jp/files/000013662.pdf)
