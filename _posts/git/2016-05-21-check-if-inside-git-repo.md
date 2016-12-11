---
layout:        post
title:         "Gitレポジトリの中にいるか確認する方法"
menutitle:     "Gitレポジトリの中にいるか確認する方法"
date:          2016-05-21
tags:          Git Commands
category:      Git
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

ShellでカレントディレクトリがGitレポジトリの中にいるか確認する方法について


なにか git のコマンドを動かす
-------------------------

とりあえず、なにか git コマンドを実行させてエラーが起きなければ、gitレポジトリ内にいることがわかります。

```shell
if git status &>/dev/null; then
  echo "inside repo"
fi
```

git rev-parse --is-inside-work-tree を使う
-----------------------------------------

ただし、実行速度のことを考えたら `git rev-parse` を使うのが賢いし、
下手なコメントを書くよりもコードが英語として読みやすいと思います。

```shell
if git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "inside repo"
fi
```

関数にする場合は、次のような感じになる。

```shell
function is_inside_repo {
  git rev-parse --is-inside-work-tree &>/dev/null
  return $?
}
```
