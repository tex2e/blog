---
layout:        post
title:         "[Python] tkinterでフォルダ指定画面を作成する"
type:          How-To
description:   "Pythonのtkinter.filedialog.askdirectoryでフォルダ選択画面を作る手順と、WindowsのCOMスレッド競合によるフリーズ回避法。"
tags:          [python, tkinter, windows, gui]
status:        stable
stale_after:   2027-08-07T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-09-03T10:14:40Z
sources:
  - id:        ref-1
    resource:  https://qiita.com/dgkmtu/items/2367a73f7e2d498e6075
    title:     "【Python】tkinterでファイル&フォルダパス指定画面を作成する - Qiita"
  - id:        ref-2
    resource:  https://github.com/pywinauto/pywinauto/issues/517
    title:     "Tkinter filedialog.askdirectory() freezing when importing pywinauto · Issue #517 · pywinauto/pywinauto"
date:          2021-08-28
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

tkinter の filedialog にはフォルダを指定するダイアログを表示するための askdirectory メソッドがあります。
ボタンを押すと、ダイアログでフォルダを指定させるプログラムは以下の通りです。

```python
import os
import tkinter as tk
from tkinter import ttk
from tkinter import filedialog

root = tk.Tk()
root.geometry("200x100")

def dirdialog_clicked():
    current_dir = os.path.abspath(os.path.dirname(__file__))
    dir_path = filedialog.askdirectory(initialdir=current_dir)
    entry_ws.set(dir_path)

entry_ws = tk.StringVar()
dir_entry = ttk.Entry(root, textvariable=entry_ws, width=20)
dir_entry.pack(side=tk.LEFT)

dir_button = ttk.Button(root, text="参照", command=dirdialog_clicked)
dir_button.pack(side=tk.LEFT)

root.mainloop()
```

askdirectory でフォルダが指定されたら、そのパスを entry_ws に格納しています。


### 補足

Windowsでは上記のプログラムを動かすと、askdirectoryを呼び出した時点でフリーズしてしまう問題が発生しました。
調査してみると、互換性のないCOMスレッドモデルで実行しているらしく、pywinautoはデフォルトで「Multi-threaded Apartment (MTA)」を使うのに対して、askdirectoryは「Single-threaded Apartment (STA)」を使うため、フリーズしてしまうものと考えられます。
解決方法は、tkinter を読み込む前 (importする前) に `sys.coinit_flags = 2` を追加します。

```python
import sys
sys.coinit_flags = 2  # COINIT_APARTMENTTHREADED

import os
import tkinter as tk
from tkinter import ttk
from tkinter import filedialog

root = tk.Tk()
root.geometry("200x100")

def dirdialog_clicked():
    current_dir = os.path.abspath(os.path.dirname(__file__))
    dir_path = filedialog.askdirectory(initialdir=current_dir)
    entry_ws.set(dir_path)

entry_ws = tk.StringVar()
dir_entry = ttk.Entry(root, textvariable=entry_ws, width=20)
dir_entry.pack(side=tk.LEFT)

dir_button = ttk.Button(root, text="参照", command=dirdialog_clicked)
dir_button.pack(side=tk.LEFT)

root.mainloop()
```

以上です。

### 参考文献

- [【Python】tkinterでファイル&フォルダパス指定画面を作成する - Qiita](https://qiita.com/dgkmtu/items/2367a73f7e2d498e6075)
- [Tkinter filedialog.askdirectory() freezing when importing pywinauto · Issue #517 · pywinauto/pywinauto](https://github.com/pywinauto/pywinauto/issues/517)
