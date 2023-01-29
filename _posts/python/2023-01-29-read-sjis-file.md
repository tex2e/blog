---
layout:        post
title:         "[Python] Windowsで作成されたShift-JISファイルを開く方法"
date:          2023-01-29
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

Pythonを使って、Windowsで作成されたShift-JISファイルを開く場合、指定するエンコードは **cp932** を指定します。
open関数の encoding 引数に指定してファイルを開きます。

似ている名前で shift_jis もありますが、こちらでは開く際にエラー「codec can't decode byte」が発生します。
理由は、Windows で使われている cp932 は shift_jis をベースに作られていて、Windows用に文字（外字）を追加して、shift_jis と cp932 で文字種類数が異なるからです。

組み込み関数のopen()を使ってエンコードを指定するには、以下のようにencoding引数を使います。

```python
ENCODING = 'cp932'

with open('in.txt', 'r', encoding=ENCODING, newline='\n') as f:
    text = f.read()

with open('out.txt', 'w', encoding=ENCODING, newline='\n') as f:
    f.write(text)
```

補足：open関数ではデフォルトで読み込み時に改行の自動変換（`\r\n` → `\n`）が発生します。
自動変換を回避するには、ファイルを開く際に行の区切りとして `newline='\n'` を指定する必要があります。

以上です。

### 参考資料
- [Python♪Windowsの「Shift JIS」の落とし穴 \| Snow Tree in June](https://snowtree-injune.com/2020/05/15/codec-py003/)
- [\[Python3\]open関数でファイルを開くと、改行コードが\[CRLF\]から\[LF\]に変換されてしまう](https://www.curict.com/item/1b/1b608b2.html)
