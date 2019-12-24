---
layout:        post
title:         "LaTeX で EPS 画像挿入時に Cannot determine size of graphic エラー"
menutitle:     "LaTeX で EPS 画像挿入時に BoundingBox のエラー"
date:          2019-12-24
category:      LaTeX
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

LaTeX で EPS 画像を挿入したときに LaTeX Error: Cannot determine size of graphic と言われてしまった時の対処法について説明します。

はじめに、LaTeX で画像を埋め込むときは次のように書きます。

```latex
\begin{figure}[H]
  \centering
  \includegraphics[scale=0.5]{img/test.eps}
  \caption{Caption}
  \label{fig:test.eps}
\end{figure}
```

しかし、エラーで次のように言われることがあります。

```log
! LaTeX Error: Cannot determine size of graphic in img/test.eps (no BoundingBox).
```

普通ではEPSの画像ファイルにはBoundingBoxの情報が書かれてありますが、LaTeXでは正しく読み込めていないようです。
そこで、BoundingBoxの情報をLaTeX側に与える作業が必要となります。

EPSファイルを開くと、最初の部分にBoundingBoxの情報が書かれてあります。

```eps
%!PS-Adobe-3.0 EPSF-3.0
%%Title: image/test.eps
%%Creator: matplotlib version 3.0.2, http://matplotlib.org/
%%CreationDate: Sat Dec 24 00:00:00 2019
%%Orientation: portrait
%%BoundingBox: 75 223 536 568
%%EndComments
%%BeginProlog
```

このBoundingBoxの値（今回の例では 75 223 536 568）を、LaTeXで画像を読み込むときに includegraphics のオプション bb を使って直接指定してあげると、正しく読み込まれるようになります。

```latex
\begin{figure}[H]
  \centering
  \includegraphics[bb=75 223 536 568, scale=0.5]{img/test.eps}
  \caption{Caption}
  \label{fig:test.eps}
\end{figure}
```

以上です。
