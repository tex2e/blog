---
layout:        post
title:         "各入力ファイルのディレクトリが別々で、出力ディレクトリが同じときのMakefileルールの書き方"
date:          2019-11-07
tags:          Makefile
category:      Makefile
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

状況を説明すると、入力ファイルは別々のディレクトリ (下の例では data/1000/ と data/2000/ ) にあって、出力先のディレクトリは1つ (下の例では html/ ) にするような Makefile のルールを書きます。

```
# やりたいことは、jsonをhtmlにすること
.
├── Makefile
├── data/             # 入力ファイルはいくつかのディレクトリにある
│   ├── 1000/
│   │   ├── 1000.json
│   │   └── 1001.json
│   └── 2000/
│       ├── 2000.json
│       └── 2001.json
│
└── html/             # 出力先ディレクトリは1つにする
    ├── 1000.html
    ├── 1001.html
    ├── 2000.html
    └── 2001.html
```

このルールを作る上で何が難しいかというと、入力ファイルがあるディレクトリの場所に関係なく、出力先を統一したい点です。

例えば、Makefileでよくある型ルールを使えば、次のように書きます。

```makefile
%.html: %.json
	cp $< $@
```

しかし、これでは出力先は入力ファイルと同じ場所になり、期待通りになりません。

```
# 失敗例
.
├── Makefile
├── data/
│   ├── 1000/
│   │   ├── 1000.json  # 入力ファイル1
│   │   ├── 1000.html  # 出力ファイル1
│   │   ├── 1001.json  # 入力ファイル2
│   │   └── 1001.html  # 出力ファイル2
```

期待する結果は次の通りです。

```
# 成功例
.
├── Makefile
├── data/
│   ├── 1000/
│   │   ├── 1000.json  # 入力ファイル1
│   :   └── 1001.json  # 入力ファイル2
│
└── html/
    ├── 1000.html  # 出力ファイル1
    └── 1001.html  # 出力ファイル2
```

<br>

### 期待通りに動くルールを書く

入力ファイルは別々のディレクトリだけど、出力先のディレクトリは1つにするルールの作り方は次の通りです：

1. wildcard関数による入力ファイル(JSON)の一覧を取得します

    ```makefile
    FILE_JSON = $(wildcard data/*/*.json)
    ```

2. ルールを出力する関数Fを定義します

    ```makefile
    define F
    $(2): $(1)
    	cp $(1) $(2)
    endef
    ```

3. 関数Fに入力ファイル(JSON)と出力ファイル(HTML)を引数として与えて、出力をeval関数で評価します。この処理を foreach で回します。

    ```makefile
    $(foreach x, $(FILE_JSON),\
      $(eval $(call F,$(x),$(patsubst %.json,html/%.html,$(notdir $(x))))))
    ```

    関数呼び出しについて
    - 1つ目の引数 `$(x)` は入力ファイル(JSON)
    - 2つ目の引数 `$(patsubst %.json,html/%.html,$(notdir $(x)))` は出力ファイル(HTML)

例えば、入力ファイルが「data/1000/1001.json」だとすると、notdir関数によって「1001.json」となり、patsubst関数による置き換えで「html/1001.html」となります。

あとは、allルールに出力ファイル(HTML)の一覧を依存として与えれば、`make all` で全てのファイルが生成されます。

まとめると、Makefile全体としては次のようになります。

```makefile
FILE_JSON = $(wildcard data/*/*.json)
FILE_HTML = $(patsubst %.json,html/%.html,$(notdir $(FILE_JSON)))

all: $(FILE_HTML)

define F
$(2): $(1)
	cp $(1) $(2)
endef

$(foreach x, $(FILE_JSON),\
  $(eval $(call F,$(x),$(patsubst %.json,html/%.html,$(notdir $(x))))))
```


実行結果：

```bash
$ tree
.
├── Makefile
├── data/
│   ├── 1000/
│   │   ├── 1000.json
│   │   └── 1001.json
│   └── 2000/
│       ├── 2000.json
│       └── 2001.json
└── html/

4 directories, 5 files

$ make
cp data/1000/1000.json html/1000.html
cp data/1000/1001.json html/1001.html
cp data/2000/2000.json html/2000.html
cp data/2000/2001.json html/2001.html

$ make
make: Nothing to be done for `all'.

$ tree
.
├── Makefile
├── data/
│   ├── 1000/
│   │   ├── 1000.json
│   │   └── 1001.json
│   └── 2000/
│       ├── 2000.json
│       └── 2001.json
└── html/
    ├── 1000.html
    ├── 1001.html
    ├── 2000.html
    └── 2001.html

4 directories, 9 files

$ touch data/2000/2000.json

$ make
cp data/2000/2000.json html/2000.html
```

以上です。
