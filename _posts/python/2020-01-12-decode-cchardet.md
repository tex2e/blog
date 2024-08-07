---
layout:        post
title:         "[Python] 文字コードの判定と変換"
date:          2020-01-12
category:      Python
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

Python3でバイト文字列の文字コードを判定して、適切に文字列に変換するための方法について説明します。

まず、[cChardet](https://github.com/PyYoshi/cChardet)というC拡張のPythonライブラリをインストールします。

```bash
$ pip install cchardet
```

次に、Shift_JIS および UTF-8 で書かれたファイル（もしくはURL）を使って判定と変換をします。
セキュリティ・キャンプ全国大会2019の応募用紙は Shift_JIS と UTF-8 の2種類の文字コードでエンコードされたものが掲載されているので、それぞれを url に入れて実行してみると、正しく文字コードを検知してデコードされるのが確認できます。

```python
import urllib.request
import cchardet

url = 'https://www.ipa.go.jp/files/000073171.txt' # Shift_JIS
# url = 'https://www.ipa.go.jp/files/000073101.txt' # UTF-8

with urllib.request.urlopen(url) as f:
    byte = f.read()
    html = byte.decode(cchardet.detect(byte)['encoding'])
    print(html)
```

Shift_JIS のファイルに対して `byte.decode('utf-8')` するとエラーになるので、cchardet を使うことで、適切な文字コードでエンコードすることができます。

Shift_JIS が今なお生き続ける諸悪の根源は Windows のせいだと思うのですが...
