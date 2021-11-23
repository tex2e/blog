---
layout:        post
title:         "RPMパッケージのインストール"
menutitle:     "RPMパッケージのインストール"
date:          2019-03-07
tags:          Linux
category:      Linux
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from: /shell/rpm-tutorial
comments:      true
published:     true
---

Red Hat系では rpm（Red hat Package Manager）を使うことによってパッケージをインストールすることができます。
基本的には yum を使う方が、依存関係のパッケージも一緒にインストールしてくれるので、yum 一択という人もいますが、プロダクトとして提供するときはバージョンを固定しておきたい場合もあります。

rpmパッケージだけをダウンロードするには、CentOS 7 では downloadonly プラグインがデフォルトで使えるので、次のコマンドを入力します。

```bash
~]# yum install --downloadonly --downloaddir=./ <package>
```

ダウンロードしたパッケージをインストールするには、次のコマンドを入力します。

```bash
~]# rpm -ivh ./*.rpm
```

オプションの意味は、インストールの `i`、詳細表示の `v`、プログレスバー表示の `h` です。
パッケージは1つずつインストールすることも可能ですが、全部の rpm ファイルを同時にインストールしないと依存関係でエラーになる場合があります。

既存のパッケージをアップデートするときは、オプションで `U` を指定します。
`i` と `U` を同時に指定することも可能です。

```bash
~]# rpm -Uvh ./*.rpm
```

バージョンの確認は `q`（Query）オプションを使います。
次のコマンドのどちらかでインストールしたパッケージのバージョンが確認できます。

```bash
~]# rpm -q <package>
~]# rpm -qa | grep <package>
```

パッケージの中のファイルの中身を表示するには query で `l` オプションを使います。
これを使うことで、どこにどのようなファイルが配置されるかを確認することができます。

```bash
~]# rpm -ql <package>
```

パッケージをアンインストールするには `e` オプションを使います。

```bash
~]# rpm -evh <package>
```
