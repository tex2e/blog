---
layout:        post
title:         "GitHubからpullすると公開鍵認証のフィンガープリントで失敗するときの対処法"
date:          2023-03-30
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

GitHubからレポジトリをpullしたり、pushしたりするときに接続先情報の公開鍵認証のフィンガープリントで接続エラーになったときの対処法について説明します。
結論だけ言うと、~/.ssh/known_hosts を手動で修正する必要があります。

### 事象

GitHubがSSHホストの鍵ペアを更新した際、公開鍵が変わるため、そのフィンガープリント（ハッシュ値）も変わります。
そのため、Git で pull や push をした際に以下のエラーが出力されることがあります。

```txt
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the RSA key sent by the remote host is
SHA256:uNiVztksCsDhcc0u9e8BujQXVUpKZIDTMczCvj3tD2s.
Please contact your system administrator.
Add correct host key in /Users/mako/.ssh/known_hosts to get rid of this message.
Offending RSA key in /Users/mako/.ssh/known_hosts:1
Host key for github.com has changed and you have requested strict checking.
Host key verification failed.
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
```

このエラーは、SSH接続先サーバから送られてきた公開鍵のフィンガープリントと、自分PCがローカルで過去に接続した際に保存していたフィンガープリントが一致しないために、中間者攻撃が発生している可能性があることの注意喚起をしています。
実運用としてSSHサーバ側で鍵ペアを更新するのは定期的に発生します。そのため、このメッセージが出たときは、サーバ管理者がSSH鍵ペアを更新したことを承知した上で、SSH接続する必要があります。

### 解決方法

焦って、自分のローカルの鍵ペアを再作成しても、中間者攻撃への

GitHubのSSH鍵のフィンガープリントは、GitHubの公式の以下のページに書かれています。

[GitHub's SSH key fingerprints - GitHub Docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)

2023年3月時点では、GitHubが対応している署名アルゴリズムは RSA、ECDSA、Ed25519 の3種類があります。
そのため、以下の内容を `~/.ssh/known_hosts` に貼り付けます。
さらに、過去に接続した際のgithub.comのフィンガープリントの行は削除しておきます。

```txt
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
```

この状態で、git pull や git fetch してみて問題なければ解決です。

以上です。

#### 参考文献

- [GitHubからfetch/pullできなくなった場合の対処（2023/03/24秘密鍵公開） - Qiita](https://qiita.com/ktateish/items/c986891e429469c7105c)
- [GitHub's SSH key fingerprints - GitHub Docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)