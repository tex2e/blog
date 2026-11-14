# linux/ssh

Parent: [All Categories](../../index.md)

## Articles (5)

- [Linuxサーバからプロキシ経由でyum/aptインストールをする](./2022-09-03-ssh-reverse-proxy-forward.md) (`How-To | stable | stale_after: 2025-09-17`) — SSHの-Rリモートフォワードを使い、インターネット非接続のLinuxサーバからローカルPCのプロキシ経由でyum/aptを実行する手順を解説します。
- [SSHログインでrootユーザを拒否する](./2021-11-26-ssh-permitrootlogin-no.md) (`How-To | stable | stale_after: 2025-03-13`) — /etc/ssh/sshd_configのPermitRootLoginをnoに設定してsshdを再起動し、SSHによるroot直接ログインを禁止する手順を説明します。
- [PwnBoxへのSSH接続時にフィンガープリントの警告をなくす](./2021-05-17-ssh-pwnbox-ignore-fingerprint.md) (`How-To | stable | stale_after: 2025-03-13`) — Hack The BoxのPwnBox接続時に毎回発生するSSHホスト鍵確認を、~/.ssh/configのStrictHostKeyChecking等で抑止する方法を説明します。
- [踏み台サーバ経由の多段SSH](./2019-01-20-ssh-proxy-command.md) (`How-To | stable | stale_after: 2025-05-05`) — ~/.ssh/configのProxyCommandにssh -Wを指定し、踏み台サーバ経由で別サーバへ多段SSH接続する設定方法を説明します。
- [SSHで公開鍵認証 (~/.ssh/configの設定とssh-copy-idコマンドによる配布)](./2019-01-19-ssh-pub-key-auth.md) (`How-To | stable | stale_after: 2027-11-28`) — ed25519鍵生成から~/.ssh/config設定、ssh-copy-idや手動での公開鍵配布、sshdのパスワード認証無効化までSSH公開鍵認証の手順を解説します。
