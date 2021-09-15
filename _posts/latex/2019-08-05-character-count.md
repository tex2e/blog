---
layout:        post
title:         "文字数を数えるLaTeXマクロ"
date:          2019-08-05
category:      LaTeX
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

レポートで論述するときに文字数が指定されることがありますが、LaTeXで文字数をカウントした結果を末尾に（xxx文字）のように表示させる方法を説明します。
まず、LaTeXには文字列を1つずつ取り出す `\@tfor` コマンドというものがあります[^njet] [^kuroworks]。

```latex
\@tfor 変数 := 文字列 \do{ 1文字ごとに実行する内容 }
```

1文字ごとに実行する内容のところで変数をインクリメントしていけば、文字数をカウントしたことになります。実際の文字数をカウントするマクロは以下の通りです [^njet]。

{% raw %}

```latex
\makeatletter
\def\WordCount#1{%
  \@tempcnta\z@%
  \@tfor \@tempa:=#1\do{\advance\@tempcnta\@ne}%
  {#1}%
  （\the\@tempcnta 文字）
}
\makeatother
```

{% endraw %}

マクロの説明です：

- `\makeatletter ... \makeatother` : @を文字として扱います。これにより `\@tfor` などのマクロを実行することができます。
- `\@tempcnta\z@` : 一時的なカウンタ `\@tempcnta` にゼロ (`\z@`) を代入します。
- `\@tfor \@tempa:=#1\do{...}` : マクロの引数に渡された文字列を1文字ずつ取り出して、変数 `\@tempa` に代入します。
- `\advance\@tempcnta\@ne` : 変数 `\@tempcnta` にイチ (`\@ne`) を加算します。
- `\the\@tempcnta` : 変数 `\@tempcnta` を文字列に変換します。

なお、LaTeXでは事前に `\z@`, `\@ne`, `tw@`, `thr@@` には 0, 1, 2, 3 の値が代入されています。

### 文字数カウントマクロの使い方

実際にマクロを使うときは以下のようになります。

```latex
\WordCount{LaTeXとはテキストベースの組版処理システムである。}
```

実行結果：

```
LaTeX とはテキストベースの組版処理システムである。(27 文字)
```

### 複数段落での使い方

複数の段落になる場合は、改行 `\\` とインデント `\indent` を使います。
単純に段落間に空行を挟むと、`\@tfor` のループでエラーになります。

```latex
\WordCount{
LaTeXとはテキストベースの組版処理システムである。
\\\indent
学術機関においては標準的な論文執筆ツールとして扱われている。
}
```

実行結果：

```
　LaTeX とはテキストベースの組版処理システムである。
　学術機関においては標準的な論文執筆ツールとして扱われている。(59 文字)
```

使用上の注意ですが、改行 `\\` とインデント `\indent` も1文字として扱います。
もしこれらは除外したい場合は、tfor の1文字ごとに実行する内容で条件分岐を書けばできると思います。

それでは良い LaTeX 生活を。

-----

[^kuroworks]: [メモ　LaTex　文字列を一つずつ取り出す　\@tfor - タイトルはそのうち決める](http://kuroworks.hatenadiary.jp/entry/2018/02/11/200753)
[^njet]: [文字数を数えるLaTeXマクロ &#8211; Sukarabe&#039;s Easy Living](http://njet.oops.jp/wordpress/2008/02/28/%E6%96%87%E5%AD%97%E6%95%B0%E3%82%92%E6%95%B0%E3%81%88%E3%82%8Blatex%E3%83%9E%E3%82%AF%E3%83%AD/)
