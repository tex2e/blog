---
layout:        post
title:         "ギリシャ文字・ドイツ文字・花文字・筆記体のLaTeX数式の書き方"
date:          2020-02-15
category:      Math
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         true
syntaxhighlight: false
# sitemap: false
# draft:   true
---

数学などの文書で現れるギリシャ文字・花文字・筆記体・ドイツ文字のTeXでの表記を一覧にまとめます。
LaTeX でギリシャ文字などの文字を書きたいときのためのものです。

### ギリシャ文字一覧

| 読み方 | 大文字 (TeX) | 小文字 (TeX) | 変体文字 (TeX)
|---|---|---|---|
| アルファ | $A$ (A) | $\alpha$ (\alpha) |  |
| ベータ | $B$ (B) | $\beta$ (\beta) |  |
| ガンマ | $\Gamma$ (\Gamma) | $\gamma$ (\gamma) |  |
| デルタ | $\Delta$ (\Delta) | $\delta$ (\delta) |  |
| イプシロン, エプシロン | $E$ (E) | $\epsilon$ (\epsilon) | $\varepsilon$ (\varepsilon) |
| ゼータ | $Z$ (Z) | $\zeta$ (\zeta) |  |
| イータ, エータ | $H$ (H) | $\eta$ (\eta) |  |
| シータ, テータ | $\Theta$ (\Theta) | $\theta$ (\theta) | $\vartheta$ (\vartheta) |
| イオタ | $I$ (I) | $\iota$ (\iota) |  |
| カッパ | $K$ (K) | $\kappa$ (\kappa) |  |
| ラムダ | $\Lambda$ (\Lambda) | $\lambda$ (\lambda) |  |
| ミュー | $M$ (M) | $\mu$ (\mu) |  |
| ニュー | $N$ (N) | $\nu$ (\nu) |  |
| クシー, グザイ | $\Xi$ (\Xi) | $\xi$ (\xi) |  |
| オミクロン | $O$ (O) | $o$ (o) |  |
| パイ | $\Pi$ (\Pi) | $\pi$ (\pi) | $\varpi$ (\varpi) |
| ロー | $P$ (P) | $\rho$ (\rho) | $\varrho$ (\varrho) |
| シグマ | $\Sigma$ (\Sigma) | $\sigma$ (\sigma) | $\varsigma$ (\varsigma) |
| タウ | $T$ (T) | $\tau$ (\tau) |  |
| ユプシロン | $\Upsilon$ (\Upsilon) | $\upsilon$ (\upsilon) |  |
| ファイ, フィー | $\Phi$ (\Phi) | $\phi$ (\phi) | $\varphi$ (\varphi) |
| カイ | $X$ (X) | $\chi$ (\chi) |  |
| プサイ, プシー | $\Psi$ (\Psi) | $\psi$ (\psi) |  |
| オメガ | $\Omega$ (\Omega) | $\omega$ (\omega) |  |


### 花文字・筆記体文字一覧

TeX コマンドは、花文字が `mathscr`、筆記体文字が `mathcal` です。

| アルファベット | 花文字 (TeX) | 筆記体 (TeX)
|---|---------------|---------------|
| A | $\mathscr{A}$ (\mathscr{A}) | $\mathcal{A}$ (\mathcal{A})
| B | $\mathscr{B}$ (\mathscr{B}) | $\mathcal{B}$ (\mathcal{B})
| C | $\mathscr{C}$ (\mathscr{C}) | $\mathcal{C}$ (\mathcal{C})
| D | $\mathscr{D}$ (\mathscr{D}) | $\mathcal{D}$ (\mathcal{D})
| E | $\mathscr{E}$ (\mathscr{E}) | $\mathcal{E}$ (\mathcal{E})
| F | $\mathscr{F}$ (\mathscr{F}) | $\mathcal{F}$ (\mathcal{F})
| G | $\mathscr{G}$ (\mathscr{G}) | $\mathcal{G}$ (\mathcal{G})
| H | $\mathscr{H}$ (\mathscr{H}) | $\mathcal{H}$ (\mathcal{H})
| I | $\mathscr{I}$ (\mathscr{I}) | $\mathcal{I}$ (\mathcal{I})
| J | $\mathscr{J}$ (\mathscr{J}) | $\mathcal{J}$ (\mathcal{J})
| K | $\mathscr{K}$ (\mathscr{K}) | $\mathcal{K}$ (\mathcal{K})
| L | $\mathscr{L}$ (\mathscr{L}) | $\mathcal{L}$ (\mathcal{L})
| M | $\mathscr{M}$ (\mathscr{M}) | $\mathcal{M}$ (\mathcal{M})
| N | $\mathscr{N}$ (\mathscr{N}) | $\mathcal{N}$ (\mathcal{N})
| O | $\mathscr{O}$ (\mathscr{O}) | $\mathcal{O}$ (\mathcal{O})
| P | $\mathscr{P}$ (\mathscr{P}) | $\mathcal{P}$ (\mathcal{P})
| Q | $\mathscr{Q}$ (\mathscr{Q}) | $\mathcal{Q}$ (\mathcal{Q})
| R | $\mathscr{R}$ (\mathscr{R}) | $\mathcal{R}$ (\mathcal{R})
| S | $\mathscr{S}$ (\mathscr{S}) | $\mathcal{S}$ (\mathcal{S})
| T | $\mathscr{T}$ (\mathscr{T}) | $\mathcal{T}$ (\mathcal{T})
| U | $\mathscr{U}$ (\mathscr{U}) | $\mathcal{U}$ (\mathcal{U})
| V | $\mathscr{V}$ (\mathscr{V}) | $\mathcal{V}$ (\mathcal{V})
| W | $\mathscr{W}$ (\mathscr{W}) | $\mathcal{W}$ (\mathcal{W})
| X | $\mathscr{X}$ (\mathscr{X}) | $\mathcal{X}$ (\mathcal{X})
| Y | $\mathscr{Y}$ (\mathscr{Y}) | $\mathcal{Y}$ (\mathcal{Y})
| Z | $\mathscr{Z}$ (\mathscr{Z}) | $\mathcal{Z}$ (\mathcal{Z})

### ドイツ文字一覧

ドイツ文字の TeX コマンドは `mathfrak` です。

| 読み方 | 大文字 (TeX) | 小文字 (TeX)
|---|---|---|
| アー | $\mathfrak{A}$ (\mathfrak{A}) | $\mathfrak{a}$ (\mathfrak{a})
| ベー | $\mathfrak{B}$ (\mathfrak{B}) | $\mathfrak{b}$ (\mathfrak{b})
| ツェー | $\mathfrak{C}$ (\mathfrak{C}) | $\mathfrak{c}$ (\mathfrak{c})
| デー | $\mathfrak{D}$ (\mathfrak{D}) | $\mathfrak{d}$ (\mathfrak{d})
| エー | $\mathfrak{E}$ (\mathfrak{E}) | $\mathfrak{e}$ (\mathfrak{e})
| エフ | $\mathfrak{F}$ (\mathfrak{F}) | $\mathfrak{f}$ (\mathfrak{f})
| ゲー | $\mathfrak{G}$ (\mathfrak{G}) | $\mathfrak{g}$ (\mathfrak{g})
| ハー | $\mathfrak{H}$ (\mathfrak{H}) | $\mathfrak{h}$ (\mathfrak{h})
| イー | $\mathfrak{I}$ (\mathfrak{I}) | $\mathfrak{i}$ (\mathfrak{i})
| ヨット, ヤット | $\mathfrak{J}$ (\mathfrak{J}) | $\mathfrak{j}$ (\mathfrak{j})
| カー | $\mathfrak{K}$ (\mathfrak{K}) | $\mathfrak{k}$ (\mathfrak{k})
| エル | $\mathfrak{L}$ (\mathfrak{L}) | $\mathfrak{l}$ (\mathfrak{l})
| エム | $\mathfrak{M}$ (\mathfrak{M}) | $\mathfrak{m}$ (\mathfrak{m})
| エヌ | $\mathfrak{N}$ (\mathfrak{N}) | $\mathfrak{n}$ (\mathfrak{n})
| オー | $\mathfrak{O}$ (\mathfrak{O}) | $\mathfrak{o}$ (\mathfrak{o})
| ペー | $\mathfrak{P}$ (\mathfrak{P}) | $\mathfrak{p}$ (\mathfrak{p})
| クー | $\mathfrak{Q}$ (\mathfrak{Q}) | $\mathfrak{q}$ (\mathfrak{q})
| エール, エア | $\mathfrak{R}$ (\mathfrak{R}) | $\mathfrak{r}$ (\mathfrak{r})
| エス | $\mathfrak{S}$ (\mathfrak{S}) | $\mathfrak{s}$ (\mathfrak{s})
| テー | $\mathfrak{T}$ (\mathfrak{T}) | $\mathfrak{t}$ (\mathfrak{t})
| ウー | $\mathfrak{U}$ (\mathfrak{U}) | $\mathfrak{u}$ (\mathfrak{u})
| ファウ | $\mathfrak{V}$ (\mathfrak{V}) | $\mathfrak{v}$ (\mathfrak{v})
| ヴェー | $\mathfrak{W}$ (\mathfrak{W}) | $\mathfrak{w}$ (\mathfrak{w})
| イクス | $\mathfrak{X}$ (\mathfrak{X}) | $\mathfrak{x}$ (\mathfrak{x})
| エプシロン | $\mathfrak{Y}$ (\mathfrak{Y}) | $\mathfrak{y}$ (\mathfrak{y})
| ツェット | $\mathfrak{Z}$ (\mathfrak{Z}) | $\mathfrak{z}$ (\mathfrak{z})
