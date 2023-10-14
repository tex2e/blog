---
layout:        post
title:         "GitHubへTCP/443番ポートでssh接続を行う"
date:          2023-10-14
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

インターネットへのTCP/22ポートの通信が拒否されているときに、GitHubとSSHでgit pullやgit pushしたいときの対処法について説明します。

TCP/22ポートでSSH接続ができるときは、22番ポートに接続するとSSHのバージョン情報が返ってきます。逆に接続できないときは何も表示されません。
```bash
$ telnet github.com 22
SSH-2.0-babeld-dd067d10
```

GitHubでは22番ポートの代わりに443番ポートでもSSH接続することができます。
接続先を「ssh.github.com」、ポート番号を443にして接続できるかは以下のコマンドで確認できます。
```bash
ssh -T -p 443 git@ssh.github.com
```

接続できることを確認したら「~/.ssh/confg」に以下の設定を追加します（IdentityFileはGitHubのSSH公開鍵認証で使用している秘密鍵を指定してください）。
以下の設定を追加することで、github.com への通信が ssh.github.com に自動的に切り替わります。

```config
Host github.com
    HostName ssh.github.com
    Port 443
    IdentityFile ~/.ssh/id_ed25519
    User git
```

最後に、接続先を「github.com」にして通常通りSSH接続できればOKです。
```bash
ssh -T git@github.com
```

以上です。

### 参考資料

- [Using SSH over the HTTPS port - GitHub Docs](https://docs.github.com/en/authentication/troubleshooting-ssh/using-ssh-over-the-https-port)
- [githubでssh: connect to host github.com port 22エラーが発生した - Qiita](https://qiita.com/yuikoito/items/672cd9e2c62a5d897b72)
