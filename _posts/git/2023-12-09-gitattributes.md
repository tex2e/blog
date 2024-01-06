---
layout:        post
title:         "ローカルの全てのレポジトリに同じ.gitattributesを適用する方法"
date:          2023-12-09
category:      Git
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ローカルにある全てのレポジトリに対して同じ.gitattributesの内容を適用する方法について説明します。

### .gitattributesの内容

.gitattributesを作成する目的は、Windowsのバッチファイルは「CRLF」で改行しなければならず、一方でLinuxのシェルスクリプトは「LF」で改行しなければならない、というためです。
Windows端末で複数のOSで動くシステムを開発するときは、以下の.gitattributesファイルをレポジトリ内に配置することで、git pullしたときに適切な改行コードになります。

```conf
# Set default behavior to automatically normalize line endings.
* text=auto

# Force batch scripts to always use CRLF line endings so that if a repo is accessed
# in Windows via a file share from Linux, the scripts will work.
*.{cmd,[cC][mM][dD]} text eol=crlf
*.{bat,[bB][aA][tT]} text eol=crlf

# Force bash scripts to always use LF line endings so that if a repo is accessed
# in Unix via a file share from Windows, the scripts will work.
*.sh text eol=lf
```

しかし、全てのレポジトリに必ずしも.gitattributesが配置されているとは限りません。
そこで、ローカルPCの全てのレポジトリに適用する全体設定をします。

### 設定の全レポジトリへの適用

全レポジトリに適用するときの.gitattributesの格納場所のパスは、Windowsであれば「%userprofile%\\.config\\git\\」、Linuxであれば「$HOME/.config/git/」の直下に「attributes」という名前のファイルを作成します。
そのファイルの内容に、.gitattributesで書く内容を記載することで、ローカルPCの全レポジトリに適用され、git cloneするときも適切な改行コードに置換されます。

- Windows :
    - `%userprofile%\.config\git\attributes`
- Linux :
    - `$HOME/.config/git/attributes`

以上です。

### 参考資料

- [Git - gitattributes Documentation](https://git-scm.com/docs/gitattributes)
