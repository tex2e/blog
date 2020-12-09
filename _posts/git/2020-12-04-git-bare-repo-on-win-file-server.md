---
layout:        post
title:         "Windows共有フォルダにGitベアレポジトリを作る"
date:          2020-12-04
category:      Git
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

社内LANで共有のGitレポジトリを作りたいけど新しくサーバを立てたくない、という場合は、共有フォルダ上にGitレポジトリを作って、これをローカルリポジトリとして運用する方法があります。
その設定方法について説明します。

まず、必要な環境は次の通りです。

- サーバー：Windowsファイル共有（samba）がある
- ローカル：Git for Windows がインストール済み

共有のGitベアレポジトリを作るには、まず共有フォルダにエクスプローラーで入って、レポジトリを作りたいフォルダで右クリックから「Git Bash Here」をします。
プロンプトが起動したら、次のコマンドを入力してリモートレポジトリを作ります。

```bash
$ git init --bare --shared
Initialized empty shared Git repository in //192.168.XX.XX/path/to/gitrepo
```

この共有フォルダにアクセスできる人は全員このリモートレポジトリからclone, pullでき、同様にpushもできます。

次のコマンドを入力してローカルレポジトリにcloneしてみましょう。

```bash
$ git clone //192.168.XX.XX/path/to/gitrepo
Cloning into 'gitrepo'...
warning: You appear to have cloned an empty repository.
done.
```

リモートの接続先は共有フォルダのパスになります。

```bash
$ git remote -v
origin  //192.168.XX.XX/path/to/gitrepo (fetch)
origin  //192.168.XX.XX/path/to/gitrepo (push)
```

共有フォルダにアクセスできる人ならpush時のパスワードは不要です。

```bash
$ git push origin master

To //192.168.XX.XX/path/to/gitrepo
 * [new branch]      master -> master
```

GitHubやGitLabのようにブラウザで閲覧しながらMergeRequestを出すとかはできませんが、バージョン管理のバックアップ的な意味で作るのはありかもしれません。

以上です。
