---
layout:        post
title:         "[Python] Pythonのtelnetlibでtelnetコマンドを実現する"
type:          How-To
description:   "telnetコマンドがないLinux環境でPython 3.12以下の標準ライブラリtelnetlibを使い対話的にtelnet通信を行う方法。"
tags:          [python, telnet, telnetlib, network]
status:        stable
stale_after:   2027-08-07T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-04T12:52:00Z
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

LinuxにtelnetはないけどPython (3.12以下) はある環境の場合は、Pythonの標準ライブラリ「telnetlib」を使うことで、telnetとしての通信を行うことできます。

```python
from telnetlib import Telnet
with Telnet('接続先IP', ポート番号) as tn:
    tn.interact()
```

PythonのREPLを開いて、プログラムを貼り付けるだけで実行したい方は、以下をコピペして接続先 IP とポートを入力してください。

```python
from telnetlib import Telnet
with Telnet(input('IP or Domain Name: '), int(input('Port: '))) as tn:
    tn.interact()
```

補足：Python 3.12 以下では使用できますが、Python 3.13 以上では telnetlib が使えなくなるため、注意が必要です。
「DeprecationWarning: 'telnetlib' is deprecated and slated for removal in Python 3.13」

以上です。
