---
layout:        post
title:         "[Python] openpyxlを使ってExcelファイルを読み込む"
type:          How-To
description:   "PythonのopenpyxlライブラリでExcelファイルを読み込み、シートや行列番号・coordinate_to_tupleでセル値を取得する方法。"
tags:          [python, openpyxl, excel]
status:        stable
stale_after:   2025-08-07T00:00:00Z
generated:
  by:          human:tex2e
  at:          2024-06-05T13:44:37Z
sources:
  - id:        ref-1
    resource:  "https://openpyxl.readthedocs.io/en/stable/tutorial.html#loading-from-a-file"
    title:     "Tutorial — openpyxl 3.1.3 documentation"
  - id:        ref-2
    resource:  "https://openpyxl.readthedocs.io/en/stable/api/openpyxl.utils.cell.html#openpyxl.utils.cell.coordinate_to_tuple"
    title:     "openpyxl.utils.cell module — openpyxl 3.1.3 documentation"
date:          2024-06-04
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

Pythonのopenpyxlライブラリを使ってExcelファイルを読み込む方法について説明します。

### 前提条件

openpyxlは外部のライブラリなので、pipを使ってインストールします。

```bash
pip install openpyxl
```

### 使い方

openpyxlの`load_workbook`メソッド使って、Excelファイルを読み込みます。
読み込んだ後は、book (Excelファイル) からsheet (シート) を選択します。

```py
from openpyxl import load_workbook  # pip install openpyxl

workbook = load_workbook('テスト.xlsx')
worksheet = workbook['シート1']
print(worksheet)
```

選択したシートのセルの値を読み込むときは、`cell` メソッドを使用します。
以下の例では、行番号=7、列番号=23 のセルの値を表示します。

```py
print(worksheet.cell(row=7, column=23).value)
```

行番号と列番号の代わりに、アルファベット＋数値 で位置を指定したい場合は、`coordinate_to_tuple` メソッドで座標に変換してから指定します。
以下の例では、「C16」のセルの値を表示します。

```py
from openpyxl.utils.cell import coordinate_to_tuple

pos = coordinate_to_tuple('C16')
print(worksheet.cell(row=pos[1], column=[0]))
```

以上です。


### 参考資料

- [Tutorial — openpyxl 3.1.3 documentation](https://openpyxl.readthedocs.io/en/stable/tutorial.html#loading-from-a-file)
- [openpyxl.utils.cell module — openpyxl 3.1.3 documentation](https://openpyxl.readthedocs.io/en/stable/api/openpyxl.utils.cell.html#openpyxl.utils.cell.coordinate_to_tuple)
