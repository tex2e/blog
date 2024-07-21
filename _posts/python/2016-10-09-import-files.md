---
layout:        post
title:         "[Python] 別ファイルをimportする方法"
date:          2016-10-09
category:      Python
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---

Python で別ファイルをインポートする方法は `import` を使いますが、
別ファイルが、実行ファイルと同じ階層にある場合と、子のディレクトリの中にある場合と、
親ディレクトリにある場合とでは、少しやり方が違うのでそれについての説明を行います。

import の手順は大きく分けて3通りあります。

1. 同じ階層にあるファイルの import
2. 同じ階層にあるディレクトリの中にあるファイルの import
3. 親ディレクトリにあるファイルの import

それぞれ一つずつ説明していきます。


### 1. 同じ階層にあるファイルの import

これは一番簡単にできるやり方で、
次のような構造のときに呼び出したい側（ここでは main.py）から `import ファイル名`（ファイルの拡張子pyはいらない）と書けば良いです。

ディレクトリ構造

```sh
.
├── foo.py
└── main.py # <= 呼び出し側
```

main.py

```py
import foo
```

<br>

### 2. 同じ階層にあるディレクトリの中にあるファイルの import

次に、ディレクトリの下にあるファイルを呼び出す場合を説明します。
この場合は、`from ディレクトリ名 import ファイル名`（ファイルの拡張子pyはいらない）と書けば、
指定したファイルをインポートすることができます。

ディレクトリ構造

```sh
.
├── aaa/
│   ├── bbb/
│   │   └── bar2.py
│   └── bar.py
└── main.py # <= 呼び出し側
```

main.py

```py
from aaa import bar
from aaa.bbb import bar2
```

<br>

### 3. 親ディレクトリにあるファイルの import

最後に、親ディレクトリにあるファイルを呼び出す場合です。
この場合は、python がファイルを検索するときに使うパスに親ディレクトリを加えれば、
親ディレクトリにあるファイルを呼び出すことができるようになります。

具体的には `sys.path.append('..')` などとやって検索対象のパスを追加します。

```sh
.
├── baz.py
├── ccc/
│   └── baz2.py
└── main/
    └── main.py # <= 呼び出し側

```

main.py

```py
import sys
sys.path.append('..')

import baz
from ccc import baz2
```

以上です。
