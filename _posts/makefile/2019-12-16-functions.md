---
layout:        post
title:         "Makefile の関数一覧"
date:          2019-12-16
category:      Makefile
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

Makefile の組み込み関数の一覧です。
公式の[ドキュメント](https://www.gnu.org/software/make/manual/html_node/Functions.html)を読みながら、関数の引数と使い方について備忘録としてまとめました。

Makefile での関数の書き方は `$(関数名 引数,...)` または `${関数名 引数,...}` です。

## 文字列操作・検索の関数

### subst

文字列の置換です。使い方は \$(subst 置換前,置換後,対象)

```makefile
FILES := hoge.c hoge.h fuga.c fuga.h
all:
	@echo $(subst hoge,piyo,$(FILES))  # => piyo.c piyo.h fuga.c fuga.h
```

### patsubst

パターンマッチによる文字列の置換です。使い方は \$(patsubst 置換前,置換後,対象)

```makefile
FILES := hoge.c hoge.h fuga.c fuga.h
all:
	@echo $(patsubst %.c,%.cpp,$(FILES))  # => hoge.cpp hoge.h fuga.cpp fuga.h
```

パターンマッチで拡張子だけを置換したいときは、もっと簡単な書き方で \$(対象:置換前=置換後) でもできます。

```makefile
FILES := hoge.c hoge.h fuga.c fuga.h
all:
	@echo $(FILES:.c=.cpp)  # => hoge.cpp hoge.h fuga.cpp fuga.h
```

### strip

文字列から余分な空白を取り除きます。

```makefile
VAR := "     just   do   it  "
all:
	@echo $(VAR)           # =>      just   do   it
	@echo $(strip $(VAR))  # =>  just do it
```

### findstr

文字列が含まれているか調べます。使い方は \$(findstr 検索文字列,対象)

```makefile
all:
	@echo $(findstring a,a b c) # => a
	@echo $(findstring a,b c)   # =>
```

### filter

パターンに一致した文字列だけを抽出します。使い方は \$(filter パターン,対象)

```makefile
FILES := hoge.c hoge.h fuga.c fuga.h
all:
	@echo $(filter %.c,$(FILES))  # => hoge.c fuga.c
```

### filter-out

パターンに一致しない文字列だけを抽出します。使い方は \$(filter-out パターン,対象)

```makefile
FILES := hoge.c hoge.h fuga.c fuga.h
all:
	@echo $(filter %.c,$(FILES))  # => hoge.h fuga.h
```

### sort

ソートします。使い方は \$(sort 対象)

```makefile
FILES := Spam Ham Eggs
all:
	@echo $(sort $(FILES))  # => Eggs Ham Spam
```

### word

n番目の文字列を抽出します。先頭から 1,2,... と数えます。使い方は \$(word N,対象)

```makefile
FILES := Spam Ham Eggs
all:
	@echo $(word 2,$(FILES))  # => Ham
```

### wordlist

n番目からm番目の文字列を抽出します。先頭から 1,2,... と数えます。使い方は \$(wordlist N,M,対象)

```makefile
FILES := Spam Ham Eggs
all:
	@echo $(wordlist 2,3,$(FILES))  # => Ham Eggs
```

### words

文字列の個数を数えます。一番最後の文字列を取り出すために使えます。

```makefile
FILES := Spam Ham Eggs
all:
	@echo $(words $(FILES))                   # => 3
	@echo $(word $(words $(FILES)),$(FILES))  # => Eggs
```

### firstword

一番最初の文字列を取り出します。

```makefile
FILES := Spam Ham Eggs
all:
	@echo $(firstword $(FILES))  # => Spam
```

### lastword

一番最後の文字列を取り出します。

```makefile
FILES := Spam Ham Eggs
all:
	@echo $(lastword $(FILES))  # => Eggs
```

---

## ファイル名操作の関数

### dir

ディレクトリだけを抽出します。

```makefile
FILES := src/hoge.c src/hoge.h index.html
all:
	@echo $(dir $(FILES))  # => src/ src/ ./
```

### notdir

ディレクトリ以外を抽出します。

```makefile
FILES := src/hoge.c src/hoge.h index.html
all:
	@echo $(notdir $(FILES))  # => hoge.c hoge.h index.html
```

### suffix

拡張子だけを抽出します。

```makefile
FILES := src/hoge.c src/hoge.h index.html
all:
	@echo $(suffix $(FILES))  # => .c .h .html
```

### basename

ベース名 (拡張子以外) を抽出します。

```makefile
FILES := src/hoge.c src/hoge.h index.html
all:
	@echo $(basename $(FILES))  # => src/hoge src/hoge index
```

### addsuffix

末尾に文字列を追加します。使い方は \$(addsuffix 追加したい文字,対象)

```makefile
FILES := foo bar
all:
	@echo $(addsuffix .c,$(FILES))  # => foo.c bar.c
```

### addprefix

先頭に文字列を追加します。使い方は \$(addprefix 追加したい文字,対象)

```makefile
FILES := foo bar
all:
	@echo $(addprefix src/,$(FILES))  # => src/foo src/bar
```

### join

2つの文字列リストを要素ごとに結合します。使い方は \$(join リスト1,リスト2)

```makefile
LIST1 := foo bar
LIST2 := .c .h
all:
	@echo $(join $(LIST1)$,$(LIST2))  # => foo.c bar.h
```

### wildcard

ワイルドカードでディレクトリにあるファイル名を抽出します。

```makefile
all:
	@echo $(wildcard *)    # => Makefile foo.c foo.h bar.c bar.h
	@echo $(wildcard *.c)  # => foo.c bar.c
```

### abspath, realpath

abspath はファイルの絶対パスを表示します。
realpath はシンボリックリンクが指すファイルの絶対パスを表示します。

```makefile
all:
	@echo $(realpath /usr/local/bin/node) # => /usr/local/Cellar/node/12.5.0/bin/node
	@echo $(abspath /usr/local/bin/node)  # => /usr/local/bin/node
```


---

## その他の関数

### foreach

リストから文字列を一つずつ取り出して処理をします。使い方は \$(foreach 変数,リスト,処理)

```makefile
dirs := a b c d
all:
	@echo $(foreach dir,$(dirs),$(wildcard $(dir)/*))
	# $(wildcard a/* b/* c/* d/*) と同じ処理をする
```

### call

関数やマクロを呼び出します。使い方は \$(call 変数名,引数...)

```makefile
reverse = $(2) $(1)
all:
	@echo $(call reverse,A,B) # => B A
```

マクロは define で定義できます。

```makefile
define HELLO
	@echo "Hello, ${1}!"
endef

all:
	$(call HELLO,Japan)  # => Hello, Japan!
```

### eval

文字列を評価します。類似するルールを大量に作るときに役立ちます。特に foreach と組み合わせると最強です。

```makefile
PROGRAMS := server client
server_OBJS := server_a.o server_b.o server_c.o
client_OBJS := client_a.o client_b.o client_c.o

all: $(PROGRAMS)

define TEMPLATE
$(1):
	@echo "$1:"
	@echo "$($1_OBJS)"
endef

$(foreach pgm,$(PROGRAMS),$(eval $(call TEMPLATE,$(pgm))))
```

実行結果

```bash
$ make
server:
server_a.o server_b.o server_c.o
client:
client_a.o client_b.o client_c.o

$ make server
server:
server_a.o server_b.o server_c.o

$ make client
client:
client_a.o client_b.o client_c.o
```

### shell

シェルコマンドを実行します。

```makefile
RESULT = $(shell seq 1 10)
all:
	@echo $(RESULT)  # => 1 2 3 4 5 6 7 8 9 10
```

#### 参考文献

- [GNU make： Functions](https://www.gnu.org/software/make/manual/html_node/Functions.html)
- [Makefile の特殊変数・自動変数の一覧](https://tex2e.github.io/blog/makefile/automatic-variables)
