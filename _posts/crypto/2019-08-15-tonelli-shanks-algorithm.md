---
layout:        post
title:         "Tonelli-Shanks Algorithm"
date:          2019-08-15
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

Tonelli-Shanks Algorithm は平方剰余の根を求めるアルゴリズムです。
以下にPythonでの実装例を載せます。

```python
def legendre(a, p):
    return pow(a, (p - 1) // 2, p)

def tonelli_shanks(a, p):
    if legendre(a, p) != 1:
        raise Exception("not a square (mod p)")
    # Step 1. By factoring out powers of 2, find q and s such that p - 1 = q 2^s with Q odd
    q = p - 1
    s = 0
    while q % 2 == 0:
        q >>= 1
        s += 1
    # Step 2. Search for a z in Z/pZ which is a quadratic non-residue
    for z in range(2, p):
        if legendre(z, p) == p - 1:
            break
    # Step 3.
    m = s
    c = pow(z, q, p) # quadratic non residue
    t = pow(a, q, p) # quadratic residue
    r = pow(a, (q + 1) // 2, p)
    # Step 4.
    t2 = 0
    while True:
        if t == 0: return 0
        if t == 1: return r
        t2 = (t * t) % p
        for i in range(1, m):
            if t2 % p == 1:
                break
            t2 = (t2 * t2) % p
        b = pow(c, 1 << (m - i - 1), p)
        m = i
        c = (b * b) % p
        t = (t * c) % p
        r = (r * b) % p


if __name__ == '__main__':
    from sympy.ntheory.residue_ntheory import sqrt_mod

    ttest = [
        (10, 13), (56, 101), (1030, 10009), (44402, 100049),
        (665820697, 1000000009), (881398088036, 1000000000039),
        (41660815127637347468140745042827704103445750172002, 10**50 + 577)
    ]

    for n, p in ttest:
        r = tonelli_shanks(n, p)
        roots = [r, p-r]
        r2 = sqrt_mod(n, p)
        roots2 = [r2, p-r2]
        assert (roots[0] * roots[0] - n) % p == 0
        assert (roots[1] * roots[1] - n) % p == 0
        assert min(roots, roots2)
        assert max(roots, roots2)
        print("n = %d p = %d" % (n, p), end=' ')
        print("roots : %d %d" % (r, p - r))
```


### 参考文献

- [Tonelli–Shanks algorithm -- Wikipedia](https://en.wikipedia.org/wiki/Tonelli%E2%80%93Shanks_algorithm)

- [Tonelli-Shanks algorithm -- Rosetta Code](https://rosettacode.org/wiki/Tonelli-Shanks_algorithm#Python)

- [Sympy residue_ntheory source code](https://docs.sympy.org/latest/_modules/sympy/ntheory/residue_ntheory.html)
