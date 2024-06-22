---
layout:        post
title:         "[Python] UTF8またはShiftJISでエンコードされたファイルの読み込み"
date:          2024-06-21
category:      Python
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Pythonにおいて、UTF8とShiftJISのどちらかでエンコードされたファイルをPythonで読み込む方法について説明します。

Windowsで作業しているとUTF8とShiftJISのファイルが混在する場合があります。
Pythonでファイルを読み込む際には正しいエンコードを指定する必要があるのですが、ファイルのエンコードが特定できないと、行の読み込み時にエラーが発生してしまいます。
そのため、以下の方法でファイルのエンコードを特定する必要があります。

```py
# ファイルのエンコードを特定
try:
    with open(file, 'r', encoding='utf-8') as f:
        f.read()
    file_encoding = 'utf8'
except UnicodeDecodeError:
    file_encoding = 'cp932'

# 特定したエンコードでファイル読み込み
with open(file, 'r', encoding=file_encoding) as f:
    for line in f.readlines():
        print(line)
```

以上です。
