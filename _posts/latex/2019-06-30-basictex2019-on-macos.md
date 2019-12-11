---
layout:        post
title:         "BasicTex2019 on MacOS"
date:          2019-06-30
category:      LaTeX
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

BasicTex2018 から BasicTex2019 にアップデートしたので、その方法についてメモします。
MacOS で BasicTex2019 へのアップデート手順は以下の通りです。
LaTeXのパッケージは必要に応じてインストールしてください。

```bash
brew cask reinstall basictex
brew upgrade ghostscript

# 全パッケージをアップデート
sudo tlmgr update --self --all
# デフォルトの用紙サイズをA4
sudo tlmgr paper a4

# 日本語対応
sudo tlmgr install collection-langjapanese
# 図の位置指定
sudo tlmgr install here
# newtxフォント
sudo tlmgr install newtx txfonts fontaxes helvetic boondox kastrup tex-gyre
# プレゼン作成
sudo tlmgr install beamer bxdpx-beamer
# TeXを画像にする用
sudo tlmgr install standalone
# 参照チェック
sudo tlmgr install refcheck
# 自動コンパイル
sudo tlmgr install latexmk

# MacOS ヒラギノ
sudo tlmgr repository add http://contrib.texlive.info/current tlcontrib
sudo tlmgr pinning add tlcontrib '*'
sudo tlmgr install japanese-otf-nonfree japanese-otf-uptex-nonfree ptex-fontmaps-macos cjk-gs-integrate-macos
sudo cjk-gs-integrate --link-texmf --cleanup
sudo cjk-gs-integrate-macos --link-texmf
sudo mktexlsr
sudo kanji-config-updmap-sys --jis2004 hiragino-highsierra-pron
# フォント確認
kanji-config-updmap-sys status
```

以上です。

-----

### 参照

- [\[Mac\] HomebrewとVSCodeで快適LaTeX環境構築 (2019)](https://qiita.com/skyloken/items/bb602494317ba0daa11f)
- [MacTeX 2019 のインストール＆日本語環境構築法 - TeX Alchemist Online](https://doratex.hatenablog.jp/entry/20190502/1556775026)
