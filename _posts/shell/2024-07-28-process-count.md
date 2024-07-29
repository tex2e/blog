---
layout:        post
title:         "[Linux] スレッド数をカウントするコマンド"
date:          2024-07-28
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Linuxで全てのスレッドの数をカウントするには、次のコマンドで確認することができます。

```bash
ps -elfT | wc -l
```

psコマンドにつけるオプションはそれぞれ以下の意味を持ちます。

- **-e** : 全てのプロセスを表示します。
- **-l** : Long形式（通常よりも情報量が多い形式）でプロセス情報を表示します。
- **-f** : フル形式（通常よりも情報量が多い形式）でプロセス情報を表示します。他のオプションと併用可
- **-T** : スレッドを表示します。表示時はSPID列が追加されます。

特に重要なのは -e と -T です。この2つを組み合わせることで、全スレッド数をカウントすることができます。

定期的に監視したい時は、while文と組み合わせると良いです。

```bash
while true; do date; ps -elfT | wc -l; sleep 1; done
```


<br>

#### (補足) Linuxシステム上のスレッド数の上限

Linuxシステム上のスレッド数の上限は `ulimit -a` コマンドで確認することができます。

```cmd
$ ulimit -a
...(省略)...
max user processes       (-u) 63498
```

スレッド数の上限を増やすには、以下の limits.conf ファイルの設定を修正するか、limits.d ディレクトリの中に設定ファイルを配置する方法があります。

- /etc/security/limits.conf
- /etc/security/limits.d/

以上です。
