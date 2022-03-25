---
layout:        post
title:         "Gitの履歴内のコミットしたユーザ名を全て変更する"
date:          2019-06-22
category:      Git
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

Gitの履歴にあるコミットしたユーザ名を過去に遡って全て変更する方法について説明します。
全てのコミットには必ず **Author** (プログラムの作成者) と **Committer** (コミットした人) の情報がありますが、過去に遡って変更したいときは git filter-branch を使います。
コミット時に Author と Committer の名前は環境変数を使っているらしいので、環境変数を変更するためのフィルタオプション `--env-filter` を使って次のように書きます。

```bash
git filter-branch --env-filter '
OLD_EMAIL="以前使用していたメールアドレス"
CORRECT_NAME="正しい名前"
CORRECT_EMAIL="正しいメールアドレス"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```

このように書くことで、全てのブランチとタグに書かれてある Author と Committer を修正することができます。

もし、レポジトリを自分一人でしか使っていない場合は、次のように書くこともできます（ただし、この操作を共用レポジトリでやると、**他人のコミットを自分のコミットに書き換えてしまう**ので注意してください）。

```bash
git filter-branch --env-filter '
CORRECT_NAME="正しい名前"
CORRECT_EMAIL="正しいメールアドレス"

export GIT_COMMITTER_NAME="$CORRECT_NAME"
export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
export GIT_AUTHOR_NAME="$CORRECT_NAME"
export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
' --tag-name-filter cat -- --branches --tags
```

以上です。


-----

### 参考文献

- [Git - git-filter-branch Documentation](https://git-scm.com/docs/git-filter-branch)
- [How to change the author and committer name and e-mail of multiple commits in Git?](https://stackoverflow.com/questions/750172/how-to-change-the-author-and-committer-name-and-e-mail-of-multiple-commits-in-gi)
