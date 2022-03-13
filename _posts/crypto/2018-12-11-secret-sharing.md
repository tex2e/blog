---
layout:        post
title:         "秘密分散技術とホワイトハッカ飴の解説"
menutitle:     "秘密分散技術とホワイトハッカ飴の解説 (Adv.Cal. 2018)"
date:          2018-12-11
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         true
photoswipe:    true
---

🎄
この記事は「[セキュリティキャンプ 修了生進捗 Advent Calendar 2018](https://adventar.org/calendars/3191)」の12日目です
🎄

## 秘密分散技術

DNSSEC のルートサーバの秘密鍵は誰が管理しているかご存知ですか？
実は、世界中にいる7人が秘密鍵の一部分を持っていて、その内の5つが集まると秘密鍵を復元できる仕組みになっています[^1] [^2]。
一般的に、情報を $n$ 個に分割し、そのうちの $k$ 個が集まると復元できる秘密分散法を $(k,n)$ 閾値法と呼びます。

[^1]: [DNSSEC Root Key Split Among Seven People](https://www.schneier.com/blog/archives/2010/07/dnssec_root_key.html)
[^2]: [DNSSEC KEY SIGNING PROCESS](http://www.cdns.net/dnssec.html#signing)

秘密分散法で一番有名なものはシャミアの秘密分散法（Shamir's Secret Sharing）です[^sss]。
DNSSECのルートサーバの秘密鍵も、このシャミアの秘密分散法を使って秘密分散しています。

[^sss]: Shamir, Adi (1979), "How to share a secret", Communications of the ACM, 22

シャミアの秘密分散法は次の手順で行います。

- **秘密の分配**

    1. 秘密の一部として共有する数を $n$、秘密を復元するのに必要な数を $k$ とする。
    2. 素数を $p$、秘密を $s \in \mathbb{F}_p$ とする
       （素数には $2^{256} - 189$ がよく使われる?）。
    3. $k-1$ 個のランダムな整数 $r_1, ..., r_{k-1} \in \mathbb{F}_p$ を用意する。
    4. $k-1$ 次多項式 $f(x)$ を定義する。

        $$
        \begin{aligned}
        f(X) &= s + r_1 X + \cdots + r_{k-1} X^{k-1} \\
             &= s + \sum_{i=1}^{k-1} r_i X^i
        \tag{1}
        \end{aligned}
        $$

    5. $n$ 個のランダムな整数 $$x_1, ..., x_n \in \mathbb{F}_p \setminus \{0\}$$ を用意する。
    6. $$i \in \{0, 1, ..., n\}$$ とし、$y_i = f(x_i)$ を計算して $(x_i, y_i)$ を秘密の一部として分配する。

- **秘密の再構成**

    1. 秘密の一部 $$(x_i, y_i)$$ を $k$ 個集める。
    2. 式(2)のラグランジュ補間より $k$ 個の座標から $k-1$ 次多項式が一意に決まる。

        $$
        f(X) = \sum_{i=1}^k y_i \prod_{j=1,\, j \ne i}^k \dfrac{x_j - X}{x_j - x_i}
        \tag{2}
        $$

    3. 実際には $X = 0$ として秘密 $s$ を計算するので式(3)を使う。これで秘密 $s$ が復元される。

        $$
        s = f(0) = \sum_{i=1}^k y_i \prod_{j=1,\, j \ne i}^k \dfrac{x_j}{x_j - x_i}
        \tag{3}
        $$

この方法の一番のポイントは「ラグランジュ補間では $k$ 個の座標がないと $k-1$ 次多項式が一意に定まらない」というところです。このことは有限体 $\mathbb{F}_p$ 上でも同様に定義されます。

なお、ラグランジュ補間とは、複数の座標から各点を通るような多項式を求める多項式補間のことです。
上記アルゴリズムで実際に分散している秘密の一部というのはただの座標のことなので、ラグランジュ補間が使えます。
具体例を示すと以下の通りです。

- $2$ 点の座標があれば $1$ 次多項式 $ax + b$（直線）が一意に決まる
- $3$ 点の座標があれば $2$ 次多項式 $ax^2 + bx + c$（二次曲線）が一意に決まる
- $4$ 点の座標があれば $3$ 次多項式 $ax^3 + bx^2 + cx + d$（三次曲線）が一意に決まる
- $k$ 点の座標があれば $k-1$ 次多項式 $$\sum_{i=0}^{k-1} a_i X^i$$ が一意に決まる

このことから、例えば復元には3個必要なのに2個だけで無理やりラグランジュ補間をしても、直線の式が求まるだけで本来求めたい二次曲線の式にはならないことがわかります。

有限体 $\mathbb{F}_p$ 上のシャミアの秘密分散法のPython3での実装は以下のようになります。
関数`split`の座標を求めるときに $x = 1,2,3,...$ としていますが本来は乱数で $x$ を決めるのが好ましいです。
ですが、乱数だと過去に出した値と重複していないか調べる手間が増えてしまうので、その辺は簡単な実装にしています。
関数`modinv`は有限体 $\mathbb{F}_p$ で除算をしたいときに使います。厳密に言うと、剰余環の乗法の逆元を求める関数です。

```python
def randint(maxint):
    import secrets
    return secrets.SystemRandom().randint(0, maxint)

# 秘密の分配
def split(secret, k, n, m):
    poly = [s] + [randint(m) for i in range(k-1)]

    def f(poly, x, m):
        accum = 0
        for coeff in reversed(poly):
            accum = (accum * x + coeff) % m
        return accum

    points = [ (x, f(poly, x, m)) for x in range(1, n+1) ]
    return points

# 秘密の再構築
def combine(shares, m):
    secret = 0
    for i, (xi, yi) in enumerate(shares):
        numerator = 1
        denominator = 1
        for j, (xj, yj) in enumerate(shares):
            if j != i:
                numerator = (numerator * (-xj)) % m
                denominator = (denominator * (xi - xj)) % m

        secret = (secret + (yi * numerator * modinv(denominator, m))) % m

    return secret

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


prime = 2**127 - 1 # 素数の大きさは安全性と情報量のトレードオフ

s = 1234 # 秘密
n = 6    # 分散させる数
k = 3    # 復元に必要な数

print("original:", s)
# => 1234

shares = split(secret=1234, k=3, n=6, m=prime)
print("shares:", shares)
# => [(1, 163479941475766671844423304849441363496),
#     (2, 59814007738176700763333734372418642301),
#     (3, 29284565708168550220105896000700049103),
#     (4, 71891615385742220214739789734285583902),
#     (5, 17493973310428479015548111857291140971),
#     (6, 36232822942696558354218166085600826037)]

# 3つを使って復元する
s = [shares[2], shares[4], shares[5]]

restored = combine(s, m=prime)
print("restored:", restored)
# => 1234
```

長いメッセージを暗号化したい場合はECBなどのブロック暗号を使います。
暗号化においてはECBモードは危険なのですが[^ECB]、秘密分散においては乱数が入るのでECBモードでも異なる結果になります。

[^ECB]: [暗号利用モード - Wikipedia](https://ja.wikipedia.org/wiki/%E6%9A%97%E5%8F%B7%E5%88%A9%E7%94%A8%E3%83%A2%E3%83%BC%E3%83%89)


## ホワイトハッカ飴の解説

ところで、Seccamp 2018 の受講者の皆さんは NRI Secure のハッカ飴（通称ホワイトハッカ飴）が配られたのを覚えているでしょうか。
飴だけなめて捨てちゃった人もいるかと思いますが、今一度どんなものだったか確認してみましょう。

<figure>
<img src="{{ site.baseurl }}/media/post/crypto-advent-seccamp-2018-h4kk44m3.jpg" />
<figcaption>セキュリティキャンプで配られたホワイトハッカ飴</figcaption>
</figure>


簡単に内容を説明すると、飴が入っている袋の2次元バーコードを読み取って、秘密のメッセージを取り出そう！というものです。
本文やヒントから、これは $(3,5)$ 閾値法のShamirの秘密分散であることが推察され、飴が3つあるので復元できそうです。

バーコードのスキャンは iPhone か iPad を持っている人は App Store で [Barcode Scanners](https://itunes.apple.com/us/app/barcode-scanners/id504201315?mt=8) をインストールすると、各種2次元バーコード（AZTEC CODE, Dotcode, Data Matrix, Maxicode）を読み取ることができます。
読み取った値は「共有」で自分のメールアドレス宛てに送信するのがおすすめです。

私の環境で読み取った値は以下の通りです。

- Dotcode: `(1,23552694744141927957);Shamir(3,n)`
- AZTEC CODE: `(3,102098157863567270479);Shamir(3,n)`
- Data Matrix: `(4,164599670825765668263);Shamir(3,n)`

ここでラグランジュ補間から元の多項式（今回は二次曲線）の切片を求めれば、それが秘密となります。
本文やヒントには素数に関する記述はないので有限体 $\mathbb{F}_p$ 上ではなく、単に整数 $\mathbb{Z}$ 上のラグランジュ補間を行います（実際には整数上の秘密分散は脆弱性があるので使うべきではありません[^sss_over_Z]）。
得られた切片の値から、数字を文字列にするCTFお馴染みのあの処理をすれば答えが求まります。
以下はPython3による実装です。

[^sss_over_Z]: [Shamir's Secret Sharing - Problem ... 整数上のシャミア秘密分散法での問題点](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing#Problem)

```python
share1 = (1,23552694744141927957)
share2 = (3,102098157863567270479)
share3 = (4,164599670825765668263)

shares = [share1, share2, share3]

# 秘密の再構築
def combine(shares):
    secret = 0
    for i, (xi, yi) in enumerate(shares):
        numerator = 1
        denominator = 1
        for j, (xj, yj) in enumerate(shares):
            if j != i:
                numerator *= (-xj)
                denominator *= (xi - xj)

        secret += yi * numerator // denominator

    return secret


secret = combine(shares)

print(secret)
# => 7508744586914983219
print(bytes.fromhex(hex(secret)[2:]).decode('ascii'))
# => h4kk44m3
```

「h4kk44m3」はリート表記なので、英字にすると「hakkaame」= ハッカ飴 という秘密のメッセージでした。

## 終わりに

秘密分散技術は情報理論的安全性があり、どんな鍵によって得られるどんな復号結果も同様に確からしくなるので、どれほどの計算能力があっても（量子コンピュータでも）解読は不可能です[^3]。
また、個人情報を秘密分散しておけば、容易に結合不能な条件下で秘密の一部が漏洩してもそれは個人情報とは言えず、個人情報漏洩には当たらない。と言う法的見解も出ています[^4]。
日本では「電子割符」と言う名前で製品・サービスを提供している会社もあります[^5] [^6]。
また、2018/12現在 JavaScript の BigInt はまだステージ3ですが Chromeの最新版でBigIntが使えるので、多倍長計算の計算速度が上がり、セキュアブラウザで情報を共有するようなソリューションが将来現れるかもしれませんね[^7]。

[^3]: [情報理論的安全性 (Information-theoretic security)](https://ja.wikipedia.org/wiki/%E6%83%85%E5%A0%B1%E7%90%86%E8%AB%96%E7%9A%84%E5%AE%89%E5%85%A8%E6%80%A7)
[^4]: 「情報分散管理技術（電子的割符技術を利用した情報管理）に関する意見書」（財団法人日本情報処理開発協会（現一般財団法人日本情報経済社会推進協会：JIPDEC）電子商取引推進センター：2010年2月）
[^5]: [情報セキュリティ―ツール「電子割符」株式会社イフェクト ](https://www.effect-inc.jp/product/tally.php)
[^6]: 電子割符ゲートウェイ Tally-WariZen -- Soliton
[^7]: [電子記録管理に関する調査検討報告書 2014 - 3章 電子記録利活用の情報セキュリティ推進の検討](http://www.cdns.net/dnssec.html#signing)


🎄🎄🎄
