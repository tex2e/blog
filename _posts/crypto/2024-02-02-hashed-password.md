---
layout:        post
title:         "パスワードをハッシュ値する方法（ソルト、ストレッチング）"
date:          2024-02-02
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ここでは、ハッシュ値からパスワードの特定するのを困難にするための技術について説明します。

### ハッシュ関数

ハッシュ関数にはいくつか種類があり、ハッシュ関数によってハッシュ値を得るために必要な計算量やハッシュ値の長さが異なります。
現在では、SHA-2 や SHA-3 などのアルゴリズムが使われています。
SHA-2 の中には SHA-256 (256bit出力) や SHA-512 (512bit出力) があります。
SHA-512 の方がよりで安全ですが、計算量が高いため、リスク許容度の応じて SHA-256 を使う選択をとる場合もあり、自分が求める安全性と費やせるリソースを考慮して選択する必要があります。

### ソルト

ソルト (Salt) とは、パスワードをハッシュ関数に入れる前に付け加える特定の文字列のことです。
ログインユーザごとに異なるソルトをランダムな文字列として割り当て、それぞれパスワードとソルトを足し合わせた文字列をハッシュ関数に入れることで、パスワードが同一のユーザであってもハッシュ関数が異なるものになります。
ソルトを付け加えていない状態では、攻撃者は同じパスワードを使う人を効率よく特定することができますが、ソルトがあることでパスワードの特定を困難にすることができます。

```fig
        [salt] + [password]
               |
               V
     SHA-256( ... )
               |
               V
           hash_value
```

### ストレッチング

ストレッチング (Stretching) とは、平文をハッシュ値に変換するときに、ハッシュ関数に1回だけ入れるのではなく、出力されたハッシュ値から再びハッシュ値を得ることを何回も繰り返す作業のことです。
ストレッチングすることによって、ハッシュ値を求めるために必要な計算量が増えるため、攻撃者が解読するための計算量も増えて、元の入力に使われたパスワードを特定することを困難にすることができます。

```fig
          [password]
               |
               | <-------+
               |         |
               V         |
     SHA-256( ... )      |
               |         |
               V         |
               +---------+
               |
               V
           hash_value
```

ソルトとストレッチングを組み合わせて、より安全な仕組みを作ることもできます。

以上です。