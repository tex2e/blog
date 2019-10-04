---
layout:        post
title:         "texlive2019へのアップグレード in Ubuntu"
date:          2019-10-04
tags:          LaTeX
category:      LaTeX
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
sitemap: false
draft:   true
---


https://tug.org/texlive/upgrade.html

```
cd /usr/local/texlive
cp -a 2018 2019

wget http://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh
sh update-tlmgr-latest.sh -- --upgrade
sudo tlmgr update --self --all

ln -sf /usr/local/texlive/2019/bin/x86_64-linux/* /usr/local/bin
```
