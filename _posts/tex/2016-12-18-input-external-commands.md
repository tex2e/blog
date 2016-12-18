---
layout:        post
title:         "TeXから外部コマンドを実行する方法"
menutitle:     "TeXから外部コマンドを実行する方法"
date:          2016-12-18
tags:          Programming Language LaTeX
category:      TeX
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true # set to be true
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
<img src="{{ site.baseurl }}/media/post/tex-input-external-commands.png" width="200" />
<figcaption>Rubyの結果がTeXに埋め込まれている様子</figcaption>
</figure>
