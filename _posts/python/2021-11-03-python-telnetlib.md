---
layout:        post
title:         "Pythonのtelnetlibを使う"
date:          2021-11-03
category:      Python
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

Linuxの環境にtelnetコマンドは入っていないけどPythonは入っている環境の場合は、Pythonの標準ライブラリtelnetlibを使うことで、telnetの代わりとして使うことができます。
```python
from telnetlib import Telnet
with Telnet('接続先IP', ポート番号) as tn:
    tn.interact()
```

以上です。
