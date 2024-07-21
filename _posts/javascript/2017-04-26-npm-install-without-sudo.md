---
layout:        post
title:         "[Node] npmをsudo権限なしでインストールする"
date:          2017-04-26
category:      JavaScript
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---

npmパッケージをmacOSとLinuxでsudoなしでグローバルにインストールする方法について説明します。

`npm`はデフォルトでプロジェクト内にパッケージをローカルにインストールします。
パッケージをグローバルにインストールすることもできます（例：`npm install -g <package>`）。
グローバルにインストールすると、コマンドラインで使用するときに便利になります。
ただし、これにはroot権限（または`sudo`の使用）が必要になるという欠点があります。

ここでは、特定のユーザーに対してパッケージをグローバルにインストールする方法を紹介します。

##### 1. グローバルパッケージ用のディレクトリを作成

```sh
mkdir "$HOME/.npm-packages"
```

##### 2. グローバルにインストールされたパッケージを保存する場所を`npm`に指定する

`~/.npmrc`ファイルに以下を追加します。

```sh
prefix=$HOME/.npm-packages
```

##### 3. インストールされたバイナリとmanページを`npm`が見つけられるようにする。

以下を`.bashrc`または`.zshrc`に追加します。

```sh
PATH="$PATH:$HOME/.npm-packages/bin"
```

`npm`のドキュメント
["Fixing `npm` permissions"](https://docs.npmjs.com/getting-started/fixing-npm-permissions)も参照してください。

以上です。
