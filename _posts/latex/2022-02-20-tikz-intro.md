---
layout:        post
title:         "LaTeX + TikZ を使った画像作成"
date:          2022-02-20
category:      LaTeX
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    true
syntaxhighlight: true
# sitemap: false
# feed:    false
---

LaTeX と TikZ を使って pdf や png 形式の画像を作成する方法についての備忘録です。
また、TikZ による線や図形の描画や色の塗り方についても説明します。

## 1. 画像の生成

### texからpdfの生成手順

tex2pdf-sample.tex

```tex
\documentclass[dvipdfmx]{article}
\usepackage{tikz}

\begin{document}
  We are working on
  \begin{tikzpicture}
    \draw (-1.5,0) -- (1.5,0);
    \draw (0,-1.5) -- (0,1.5);
  \end{tikzpicture}
\end{document}
```

```bash
$ platex tex2pdf-sample.tex
$ dvipdfmx tex2pdf-sample.dvi
```

### texからpngの生成手順

tex2png-sample.tex

```tex
\documentclass[dvipdfmx]{standalone}
\usepackage{tikz}

\begin{document}
  We are working on
  \begin{tikzpicture}
    \draw (-1.5,0) -- (1.5,0);
    \draw (0,-1.5) -- (0,1.5);
  \end{tikzpicture}
\end{document}
```

```bash
$ platex tex2png-sample.tex
$ dvipdfmx tex2png-sample.dvi
$ convert -density 300 tex2png-sample.pdf -quality 90 tex2png-sample.png
```

<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/0-intro/tex2png-sample.png" width=250px />
<!--<figcaption></figcaption>-->
</figure>

<br>

## 2. 線を引く

### 直線

2つの (x, y) 座標を `--` で結ぶと、2点間に直線が描かれます。

```tex
\begin{tikzpicture}
  \draw (-1.5,0) -- (1.5,0) -- (0,-1.5) -- (0,1.5);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-01.png" width=150px />
</figure>

### 座標指定

座標は `(x,y)` と書きます。
座標の単位を省略すると、単位は cm になります。
つまり、 `(1,2)` は `(1cm,2cm)` と同じ座標です。

また、2点目以降で `++(x,y)` と書くと、 **1つ前の点** から見た相対座標を指定することができます。

```tex
\begin{tikzpicture}
  \draw (0.5,0) -- ++(0,1) -- ++(1,-1);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-02.png" width=100px />
</figure>

似た様な書き方で `+(x,y)` というのもあります。これは **1番目の点** からみた相対座標を指定することができます。
以下に、1つ上と同じ図形を `+(x,y)` の形式で書いたものを置くので、コードを比較してみてください。

```tex
\begin{tikzpicture}
  \draw (0.5,0) -- +(0,1) -- +(1,0);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-03.png" width=100px />
</figure>

### ベジェ曲線

2つの (x, y) 座標を `.. controls (座標1の制御点) and (座標2の制御点) ..` で結ぶと、
2点間にベジェ曲線が描かれます。

```tex
\begin{tikzpicture}
  \draw (0,0) .. controls (0,1) and (2,1) .. (2,0);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-04.png" width=100px />
</figure>

```tex
\begin{tikzpicture}
  \draw (0,0) .. controls (0,1) and (2,-1) .. (2,0);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-05.png" width=100px />
</figure>

### 円

円を描くには、 `(原点) circle (半径)` と書きます。
半径の単位は tex で使えるもの（pt, cm など）が使えます。

```tex
\begin{tikzpicture}
  \draw (0,0) circle (20pt);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-06.png" width=100px />
</figure>

### 楕円

楕円を描くには、 `(原点) ellipse (幅 and 高さ)` と書きます。

```tex
\begin{tikzpicture}
  \draw (0,0) ellipse (20pt and 10pt);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-07.png" width=100px />
</figure>

### 四角形

四角形を描くには、 `(座標1) rectangle (座標2)` と書くことで、座標1と座標2を対角線とする四角形が描かれます。

```tex
\begin{tikzpicture}
  \draw (0,0) rectangle (3,2);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-08.png" width=100px />
</figure>

### グリッド

グリッドを描くには、 `(座標1) grid (座標2)` と書きます。
オプション `step` でグリッド線の間隔を指定することもできます。

```tex
\begin{tikzpicture}
  \draw (0,0) grid (3,2);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-09.png" width=100px />
</figure>

```tex
\begin{tikzpicture}
  \draw[step=0.5cm] (0,0) grid (3,2);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-10.png" width=100px />
</figure>

### オプション群に名前を付ける

オプションが複数個あって使いまわしたいときなどは、オプション群に名前を付けると良い。
下の例では `help lines` という名前で、 `step=0.5cm, gray, very thin` のオプションが使えるようになります。

```tex
\begin{tikzpicture}
  \tikzset{help lines/.style={step=0.5cm, gray, very thin}}

  \draw[help lines] (0,0) grid (3,2);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-11.png" width=100px />
</figure>

オプション群に名前を付けるときに別のオプション群の名前を使うこともできます。

```tex
\begin{tikzpicture}
  \tikzset{foo/.style=gray}
  \tikzset{bar/.style=very thin}
  \tikzset{help lines/.style={step=0.5cm, foo, bar}}

  \draw[help lines] (0,0) grid (3,2);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-12.png" width=100px />
</figure>

### 線の描画オプション

| オプション | 説明 |
| :------------- | :------------- |
| draw=<color>   | 線の色
| thin, very thin, ultra thin | 線を細くすます。右にいくほどより細くする
| thick, very thick, ultra thick | 線を太くすます。右にいくほどより太くする
| loosely dashed | 破線より少し線の間隔を広くした破線
| dashed | 破線 `--- ---`
| densely dashed | 点線より少し線の間隔を広くした破線
| loosely dotted | 破線より少し線の間隔を狭くした点線
| dotted | 点線 `- - - -`
| densely dotted | 点線より少し線の間隔を狭くした点線

```tex
\begin{tikzpicture}
  \draw[draw=blue]      (0,-0  ) -- (2,-0  );
  \draw[thin]           (0,-0.5) -- (2,-0.5);
  \draw[very thin]      (0,-1  ) -- (2,-1  );
  \draw[ultra thin]     (0,-1.5) -- (2,-1.5);
  \draw[thick]          (0,-2  ) -- (2,-2  );
  \draw[very thick]     (0,-2.5) -- (2,-2.5);
  \draw[ultra thick]    (0,-3  ) -- (2,-3  );
  \draw[loosely dashed] (0,-3.5) -- (2,-3.5);
  \draw[dashed]         (0,-4  ) -- (2,-4  );
  \draw[densely dashed] (0,-4.5) -- (2,-4.5);
  \draw[loosely dotted] (0,-5  ) -- (2,-5  );
  \draw[dotted]         (0,-5.5) -- (2,-5.5);
  \draw[densely dotted] (0,-6  ) -- (2,-6  );
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-13.png" width=150px />
</figure>

### 円弧

円弧を描くには、 `(始点) arc (開始度:終了度:半径)` と書きます。

```tex
\begin{tikzpicture}
  \draw[step=.5cm,gray,very thin] (-1.4,-1.4) grid (1.4,1.4); % 補助線
  \draw (1,0) arc (0:70:1cm);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-14.png" width=100px />
</figure>

### 楕円弧

楕円弧を書くには、 `(始点) arc (開始度:終了度:幅 and 高さ)` と書きます。

```tex
\begin{tikzpicture}
  \draw[step=.5cm,gray,very thin] (-1.4,-1.4) grid (1.4,1.4); % 補助線
  \draw (1,0) arc (0:315:1cm and 0.5cm);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-15.png" width=100px />
</figure>

### キャンパスの切り取り

キャンパスの切り取りをすることで、指定した範囲のみを描くことができます。
書き方は `\clip 切り取る範囲を表す図形` で、この図形は四角形や円などで指定できます。

```tex
\begin{tikzpicture}
  \clip (-0.1,-0.1) rectangle (2.1,2.1); % <= 切り取る範囲の指定
  \draw[step=.5cm,gray,very thin] (-1.4,-1.4) grid (2.4,2.4);
  \draw (0,0) circle (2cm);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-16.png" width=100px />
</figure>

### 放物線（Parabola）

放物線を描くには、 `(頂点) parabola (終点)` と書きます。

```tex
\begin{tikzpicture}
  \draw[step=.5cm,gray,very thin] (-1.4,-1.4) grid (1.4,1.4); % 補助線
  \draw (0,0) parabola (1,-1);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-17.png" width=100px />
</figure>

放物線を描くときに `(始点) parabola bend (頂点) (終点)` と書けば、放物線の頂点を指定できます。

```tex
\begin{tikzpicture}
  \draw[step=.5cm,gray,very thin] (-1.4,-1.4) grid (1.4,1.4); % 補助線
  \draw (0,0) parabola bend (0.5,1) (1,-1);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-18.png" width=100px />
</figure>

### サイン・コサイン

サイン曲線を描くには、 `(始点) sin (終点)` と書きます。
コサインも同様に、 `(始点) cos (終点)` と書きます。
ただし、どちらも [0, π/2] の範囲の曲線しか描画しない点に注意。

```tex
\begin{tikzpicture}
  \draw (0,0) sin (1,1) cos (2,0) sin (3,-1) cos (4,0);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-19.png" width=100px />
</figure>

### 閉じた経路

`-- cycle` は、経路を閉じるときに使います。

```tex
\begin{tikzpicture}
  \draw (-1.5,0) -- (1.5,0) -- (0,-1.5) -- (0,1.5) -- cycle;
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-20.png" width=100px />
</figure>

### 線の組み合わせ

線の種類は常に同じである必要はありません。
例えば直線を書いた後に、円弧を書くことができます。

```tex
\begin{tikzpicture}
  \draw (0,0) -- (1cm,0mm) arc (0:30:1cm) -- cycle;
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/1-path/1-21.png" width=100px />
</figure>

<br>

## 3. 色を付ける

### 色の指定の仕方

あらかじめ定義されている色は以下の通りです。

- red(赤), green(緑), blue(青), cyan(シアン), magenta(マゼンタ), yellow(黄),
black(黒), gray(灰), darkgray(深灰), lightgray(浅灰), brown(茶),
lime(ライム), olive(オリーブ), orange(オレンジ), pink(ピンク), purple(赤系の紫),
teal(青緑), violet(青系の紫), white(白)

色の濃さを設定することもでき、 `色名!濃度` と書きます。
普通に色を使うと発色がきついので、濃度を 20%〜80% くらいにするのが良いでしょう。
また、 `色名!濃度!別の色` と書くことで2色を合わせた色を作ることもできます。

- `blue` -- 青色
- `blue!30` -- 濃度が30%の青色
- `blue!30!red` -- 青色が30%、赤色が70%の混色

### 塗りつぶす

図形の内部を塗りつぶすには `\fill` コマンドを使い、オプションで色を指定します。

```tex
\begin{tikzpicture}
  \fill[color=green!50!white] (0,0) circle (10pt);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/2-filling-and-drawing/2-01.png" width=50px />
</figure>

オプションcolorは省略することが可能です。
実際のところ、省略されることがほとんどだと思います。

### 不透明度

色のオプションとは別に `opacity` オプションを付けることができます。
`opacity` の範囲は 0.0 〜 1.0 です。

```tex
\begin{tikzpicture}
  \fill[blue, opacity=0.3] (0,0) circle (10pt);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/2-filling-and-drawing/2-02.png" width=50px />
</figure>

### 線の色と塗りつぶす色を別にする

線の色と塗りつぶす色を別にするには `\filldraw` を使い、オプションで `fill` と `draw` で色を指定します。
`fill` は塗りつぶす色で、 `draw` は線の色です。

```tex
\begin{tikzpicture}
  \filldraw[fill=green!20!white, draw=green!20!black, thick] (0,0) circle (10pt);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/2-filling-and-drawing/2-03.png" width=50px />
</figure>

### グラデーション

`\shade` を使うことで塗りつぶす色をグラデーションにすることができます。
使う方法は、色の場所を示すオプション
`top color`, `bottom color`, `left color`, `right color` などで色を指定します。

```tex
\begin{tikzpicture}
  \shade[top color=yellow, bottom color=black] (0,0) rectangle +(2,1);
  \shade[left color=yellow, right color=black] (3,0) rectangle +(2,1);
  \shade[inner color=yellow, outer color=black] (6,0) rectangle +(2,1);
  \shade[ball color=green!50] (9,0.5) circle (.5cm);
\end{tikzpicture}
```
<figure>
<img src="{{ site.baseurl }}/media/post/tikz/tikz-intro/2-filling-and-drawing/2-04.png" width=500px />
</figure>
