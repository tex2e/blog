---
layout:        post
title:         "Makefileから別のMakefileをimportする・実行する"
date:          2017-12-09
category:      Makefile
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

Makefileから別のMakefileをimportしたり、実行したりする方法について。
ディレクトリ構造は以下のようなのを想定しています。

```
.
├── Makefile      <= 実行するMakefile
└── sub/
    └── Makefile  <= 呼び出されるMakefile
```

include
----------

別のMakefileをimportするには、`include`を使います。

#### プログラム

```
# ./Makefile

include sub/Makefile
```

```
# ./sub/Makefile

subprocess:
	@echo "This is a subprocess."
```

#### 実行結果

```
$ make subprocess
This is a subprocess.
```


cd sub && make
----------------

下のディレクトリに移動してから実行したい場合もあります。
その時は `cd sub && make` とするのですが、実行してみると
「/bin/sh: line 0: cd: sub: No such file or directory」
と怒られてしまいます。
どうやら Makefile 内で実行する /bin/sh は相対パスで cd できない様なので、代わりに
`cd "$(PWD)/sub" && make`
と書きます。

#### プログラム

```
# ./Makefile

subprocess:
	cd "$(PWD)/sub" && make subprocess
```

```
# ./sub/Makefile

subprocess:
	@echo "This is a subprocess."
```

#### 実行結果

```
$ make subprocess
cd "path/to/sub" && make subprocess
This is a subprocess.
```
