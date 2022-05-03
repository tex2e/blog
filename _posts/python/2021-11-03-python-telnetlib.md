---
layout:        post
title:         "telnetコマンドの代わりにPythonのtelnetlibを使う"
date:          2021-11-03
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

Linuxの環境にtelnetコマンドは入っていないけどPythonは入っている環境の場合は、Pythonの標準ライブラリtelnetlibを使うことで、telnetの代わりとして使うことができます。
```python
from telnetlib import Telnet
with Telnet('接続先IP', ポート番号) as tn:
    tn.interact()
```
PythonのREPLを開いて、プログラムを貼り付けるだけで実行したい方は、以下をコピペして接続先 IP とポートを入力してください。
```python
from telnetlib import Telnet
with Telnet(input('Dest IP:'), int(input('port:'))) as tn:
    tn.interact()
```

以上です。
