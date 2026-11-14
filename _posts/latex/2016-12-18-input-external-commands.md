---
layout:        post
title:         "TeXから外部コマンドを実行する方法"
type:          How-To
description:   "TeXのinputコマンドにパイプ付きコマンドを渡しコンパイル時に-shell-escapeオプションを付けて外部処理の結果を埋め込む方法。"
tags:          [latex, tex, shell-escape]
status:        stable
stale_after:   2023-06-20T00:00:00Z
generated:
  by:          human:tex2e
  at:          2016-12-18T06:53:20Z
date:          2016-12-18
category:      LaTeX
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from: /tex/input-external-commands
comments:      false
published:     true
photoswipe:    true
---

TeXから外部コマンドを実行する方法について。
意外とどこのドキュメントを読んでも説明されていなかったりするので、メモ書きとして残しておく。

\\input
-----------------------

TeXのコマンドには、\\input という別のTeXファイルを読み込むコマンドがありますが、
\\input の引数が `|"command"`（先頭にパイプが1つとダブルクオートで囲われた文字列）のようになっていると、指定したコマンド `command` が実行されます。

main.tex

```tex
\begin{document}
Hello, \LaTeX.
\input{|"ruby ./sample.rb"}
\end{document}
```

sample.rb

```ruby
puts Time.now
```


-shell-escape
-----------------------

上のコードをコンパイルしただけではコマンドは実行されません。
外部コマンドの実行は危険を伴う場合があるので、どのようなコマンドが実行されるか理解した上で、
`-shell-escape` というオプションを加えてコンパイルします。

```
platex -shell-escape main.tex
```


結果
-----------------------

Rubyのコードは現在時間を返すプログラムなので、正しく埋め込まれているのが確認できます。

<figure>
<img src="{{ site.baseurl }}/media/post/tex-input-external-commands.png" />
<figcaption>Rubyの結果がTeXに埋め込まれている様子</figcaption>
</figure>
