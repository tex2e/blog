# git

Parent: [All Categories](../index.md)

## Articles (11)

- [ローカルの全てのレポジトリに同じ.gitattributesを適用する方法](./2023-12-09-gitattributes.md) (`How-To | stable | stale_after: 2027-01-06`) — OS混在環境向けにCRLFやLFの改行コード設定を記した.gitattributesを全ローカルリポジトリへグローバル適用する方法。
- [GitHubへTCP/443番ポートでssh接続を行う](./2023-10-14-github-ssh-443-port.md) (`Troubleshooting | stable | stale_after: 2026-10-14`) — TCP/22番ポートが遮断された環境でssh.github.comの443番ポート経由でGitHubへSSH接続するための~/.ssh/config設定。
- [Gitでブランチ間の差分ファイルだけをZipにする方法](./2023-06-24-create-diff-zip.md) (`How-To | stable | stale_after: 2026-06-24`) — git diff --name-onlyとgit archiveを組み合わせ、ブランチ間の差分ファイルだけをZip圧縮するLinuxとPowerShellの手順。
- [GitHubからpullすると公開鍵認証のフィンガープリントで失敗するときの対処法](./2023-04-01-ssh-known-hosts.md) (`Troubleshooting | stable | stale_after: 2026-04-02`) — GitHubのSSHホスト鍵更新によりpullやpushでフィンガープリント不一致エラーが出た際のknown_hosts修正手順を解説。
- [Windows共有フォルダにGitベアレポジトリを作る](./2020-12-04-git-bare-repo-on-win-file-server.md) (`How-To | stable | stale_after: 2025-03-13`) — 新規サーバを立てずにWindowsのファイル共有フォルダ上にGitベアリポジトリを作成し、社内LANで共有運用する設定手順。
- [GitHubからDMCA takedownが来たときの対応手順](./2020-07-19-github-dmca-takedown-notice.md) (`How-To | stable | stale_after: 2025-03-13`) — GitHubからDMCAテイクダウン通知を受けた際に該当ファイルを履歴から削除し、.gitignore追加や強制push、返信を行う手順。
- [Gitの履歴内のコミットしたユーザ名を全て変更する](./2019-06-22-rewrite-author.md) (`How-To | stable | stale_after: 2022-06-23`) — git filter-branchの--env-filterを使い、過去すべてのコミットに含まれるAuthorとCommitterのユーザ名を一括変更する方法。
- [Gitの履歴からファイルを完全に削除する](./2019-06-10-filter-branch.md) (`How-To | stable | stale_after: 2022-06-10`) — git filter-branchの--index-filterとgit rmを使い、指定したファイルを過去の全コミット履歴から完全に削除する方法。
- [GitサーバとGitWebをCentOS 7で構築する](./2017-12-29-git-server-and-gitweb-on-centos7.md) (`How-To | stable | stale_after: 2022-03-06`) — CentOS 7上にベアリポジトリを用いたGitサーバとGitWebを構築し、post-updateフックでWebサイトを自動更新する手順。
- [Gitの使い方（コマンド）](./2016-09-23-git-command.md) (`Reference | stable | stale_after: 2019-12-05`) — Gitの基本的な作業フローに沿ってinit、clone、commit、push、branch、mergeなど主要コマンドの書式と例を整理。
- [Gitレポジトリの中にいるか確認する方法](./2016-05-21-check-if-inside-git-repo.md) (`How-To | stable | stale_after: 2019-12-05`) — シェルスクリプトやコマンドラインで現在位置がGitリポジトリ内かをgit rev-parseで判定する方法と関数化例を解説。
