---
layout:        post
title:         "Bashで一時ファイルを作る方法"
menutitle:     "Bashで一時ファイルを作る方法"
date:          2016-12-30
tags:          Programming Language Bash
category:      Shell
author:        tex2e
cover:         /assets/cover2.jpg
redirect_from:
comments:      false
published:     true
---

Bashで一時ファイルを mktemp で作る方法と、trap を使った一時ファイルの削除方法について説明します。
まず、一時ファイルの作成・削除でよく使う雛形を以下に示します。

```bash
# 一時ファイルを作る
tmpfile=$(mktemp)

# 生成した一時ファイルを削除する
function rm_tmpfile {
  [[ -f "$tmpfile" ]] && rm -f "$tmpfile"
}
# 正常終了したとき
trap rm_tmpfile EXIT
# 異常終了したとき
trap 'trap - EXIT; rm_tmpfile; exit -1' INT PIPE TERM

# この下に一時ファイルを使った処理を書く...
```


以下はコマンドの説明です。

### mktemp

まず、mktemp というコマンドは「一時ファイルとして利用できるファイル名」を返すコマンドです。
つまり、mktemp を実行した時点ではファイルは何一つ作られていません。
なので、mktemp によって得られたファイル名は、変数に保存しておく必要があります。

```bash
tmpfile=$(mktemp)
```

実際に使いたい場合は、変数名にリダイレクトさせるなり、変数名をプログラムの引数に渡したりして使います。

```bash
echo "Hello, world" > $tmpfile
cat $tmpfile
```

使い終わったら自分で削除しないとファイルは消えないので（OSが定期的に削除してくれる）、最後に一時ファイルを削除します。

```bash
rm "$tmpfile"
```

ただ、毎回自分で削除させるのは大変ですし、そもそも全てのコマンドが必ず正常終了で終わるとは限りません。つまり途中のコマンドがエラーで止まってしまった場合は、最後に書いた一時ファイルの削除するコマンドが実行されないかもしれないのです。そこで、trap を使います。

### trap

trap コマンドはシグナルを受け取るための処理を記述するためのコマンドで、いわゆるイベントハンドラです。
具体的には、正常終了した時に送られる EXIT シグナルや、
Ctrl+C で処理が中断された時に送られる INT（interrupt）シグナルなどを捕まえることができます。

例えば、正常終了の EXIT シグナルが送られた時に ok と表示させるには次のように書きます。

```bash
trap 'echo ok' EXIT
```

異常終了系の INT PIPE TERM などのシグナルが送られた時に ng と表示させるには次のように書きます。

```bash
trap 'echo ng' INT PIPE TERM
```

trap の第一引数に実行したいスクリプトを書くのですが、複数のコマンドを実行したいときは `cmd1; cmd2; ...` となって読みにくいので、関数にまとめてそれを呼び出すというのが一般的です。

```bash
function rm_tmpfile {
  rm -f "$tmpfile"
  echo 'Bye!'
}
echo rm_tmpfile EXIT
```

以上です。
