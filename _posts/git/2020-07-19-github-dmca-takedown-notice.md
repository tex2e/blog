---
layout:        post
title:         "GitHubからDMCA takedownが来たときの対応手順"
date:          2020-07-19
category:      Git
cover:         /assets/cover1.jpg
redirect_from: /misc/github-dmca-takedown-notice
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

GitHubに公開していたファイルがDMCA(デジタルミレニアム著作権法)に引っかかり、GitHubから1営業日以内に対応しないとレポジトリを凍結すると通知が来たので、そのときに対応したことの備忘録です。

受信したメールの内容：

```
差出人：GitHub <support@githubsupport.com>
件名　：[GitHub Support] - [GitHub] DMCA Takedown Notice

Hi <ユーザ名>,

I'm contacting you on behalf of GitHub because we've received a DMCA takedown notice regarding the following content:

<著作権侵害しているレポジトリ内のコンテンツのURL>

We're giving you 1 business day to make the changes identified in the following notice:

<DMCAの申請内容のファイルURL>

If you need to remove specific content from your repository, simply making the repository private or deleting it via a commit won't resolve the alleged infringement. Instead, you must follow these instructions to remove the content from your repository's history, even if you don't think it's sensitive:

https://help.github.com/articles/remove-sensitive-data

Once you've made changes, please reply to this message and let us know. If you don't tell us that you've made changes within the next 1 business day, we'll need to disable the entire repository according to our GitHub DMCA Takedown Policy:

...以下省略...
```

注意点として、著作権侵害しているファイルをレポジトリから削除するだけではダメで、コミット履歴からも削除する必要があります。
レポジトリから情報を完全に削除する手順は[Removing sensitive data from a repository - GitHub Docs](https://docs.github.com/en/github/authenticating-to-github/removing-sensitive-data-from-a-repository)に書かれていますが、ここでは私が行った内容について説明します。


#### 1. コミット履歴から削除する

コミット履歴から特定のファイルの情報を削除するには、git filter-branch を使います。
filter-branch は全てのコミットに対して指定した処理を行うコマンドです。
以下のコマンドを実行すると、レポジトリの全てのコミットと全てのタグについて、指定したファイルを履歴から削除し、既存のタグを上書きします。

```bash
$ git filter-branch --force --index-filter \
    "git rm --cached --ignore-unmatch <ファイルのパス>" \
    --prune-empty --tag-name-filter cat -- --all
```

`git rm --cached` はファイルをバージョン管理から外すコマンドです。

#### 2. .gitignoreに追加する

レポジトリの履歴から削除したら、二度とバージョン管理に追加しないように（git addでステージングできないように）.gitignore にファイル名を追加しておきます。

#### 3. GitHubに強制pushする

バージョン管理の履歴を変えてしまったので、そのままpushすることはできません。
代わりに、強制的に全て履歴を上書きする強制プッシュを実行します。

```bash
$ git push origin --force --all
```

レポジトリの全ての履歴を更新するため、pushが終わるまでに時間がかかりますが、気長に待ちましょう。

#### 4. GitHubからのメールに返信する

レポジトリから完全に削除されたことを確認したら、GitHubからのメールに返信します。
1営業日以内に返信しないと何もアクションを取らなかったとみなされて、レポジトリが凍結されてしまいます。
英語のメールを書く機会があまりないので、一行だけで簡単に

```
I deleted the content from the repository and its history.
```

と書いて返信しました。

その2,3時間後、GitHub Supportから

```
Hello,

Thanks for letting us know you've made changes! We'll pass them along to the copyright holder, and let you know if they have any other concerns.
```

というメールが来たので、レポジトリの凍結は回避できました。

以上です。
