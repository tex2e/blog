# windowsbatch

Parent: [All Categories](../index.md)

## Articles (14)

- [[Windows] コマンドプロンプトのhelpの閲覧方法](./2024-06-06-how-to-get-help.md) (`How-To | stable | stale_after: 2027-07-28`) — Windowsコマンドプロンプトの仕様を調べる方法として、helpコマンド、/?オプション、MS公式Learn、ss64サイトの活用法を紹介。
- [[Windows] バッチ実行時に管理者権限で動作しているか調べる](./2023-04-22-check-is-admin.md) (`How-To | stable | stale_after: 2027-07-28`) — Windowsバッチで管理者権限が必要なopenfilesコマンドを実行し、%ERRORLEVEL%の値で管理者権限の有無を判定する処理を解説。
- [[Windows] バッチのfor文で変数を遅延展開する](./2022-07-09-enabledelayedexpansion.md) (`How-To | stable | stale_after: 2027-07-28`) — Windowsバッチのfor文内で最新の変数値を得るため、EnableDelayedExpansionを有効化し!変数名!で遅延展開する手順を解説。
- [[Windows] サブフォルダも含めた全てのファイルの更新時間を出力](./2021-03-27-list-timestamp-of-files.md) (`How-To | stable | stale_after: 2027-07-28`) — Windowsバッチのfor /rループと~t変数展開を使い、サブフォルダ配下を含む全ファイルの更新時間一覧を出力する方法を解説。
- [[Windows] バッチファイルの引数の文字列置換・パス展開](./2021-03-12-path-expansion-for-args.md) (`Reference | stable | stale_after: 2027-07-28`) — Windowsバッチファイルの引数展開（%~d1・%~dp1・%~nx1・%~t1等）、%~a1の属性表記、および変数の文字列置換構文の仕様一覧。
- [[Windows] 更新時間が異なるときにファイルコピーする](./2021-03-11-check-timestamp-and-copy.md) (`How-To | stable | stale_after: 2027-07-28`) — Windowsバッチでfor文と%~ti展開を用いてファイルの更新日時を取得・比較し、差分がある場合のみxcopyでコピーする処理と複数ファイル対応を解説。
- [[Windows] 任意の階層にある全てのReleaseフォルダからexeを集めるコマンド](./2021-01-31-collect-exe-files-from-release-folder.md) (`How-To | stable | stale_after: 2027-07-28`) — Windowsバッチのfor /r /dループとxcopyを組み合わせ、任意階層下にある全てのReleaseフォルダからexeファイルを一括収集する方法を解説。
- [[Windows] VSSからファイル取得を自動化する](./2021-01-30-vss-command-line.md) (`How-To | stable | stale_after: 2027-07-28`) — Visual SourceSafeの環境変数（SSUSER・SSPWD・SSDIR）を設定し、ss CP/GETコマンドをバッチやPowerShellで自動取得する手順。
- [[Windows] VSSコマンドのオプション一覧](./2021-01-29-vss-command-options.md) (`Reference | stable | stale_after: 2027-07-28`) — Visual SourceSafe（VSS）のssコマンドで利用する-#・-C・-D・-E・-G・-I・-K・-L・-O・-V・-W等のオプション仕様一覧。
- [cmd.exeとbashのコマンド比較表](./2020-11-23-batch-vs-bash.md) (`Reference | stable | stale_after: 2025-03-13`) — Windowsのcmd.exeコマンドとLinux/macOSのbashコマンドをファイル操作・プロセス管理・ネットワーク等の処理別に対比したリファレンス表。
- [[Windows] コマンドプロンプトでlsを使う](./2020-08-30-autorun.md) (`How-To | stable | stale_after: 2027-07-28`) — Windowsでdoskeyコマンドによりlsをdirへ割り当てるマクロを作成し、レジストリのAutoRun設定でコマンドプロンプト起動時に自動読込する手順。
- [[Windows] WinSCPでファイルダウンロードを自動化する](./2020-08-13-winscp-cmd.md) (`How-To | stable | stale_after: 2027-07-28`) — WinSCP.exeの/console・/commandオプションとopen・get・putコマンドを使い、バッチからファイル転送を自動化する方法を解説。
- [[Windows] TeraTermマクロでリモートログイン自動化](./2020-08-12-teraterm-auto-login.md) (`How-To | stable | stale_after: 2027-07-28`) — TeraTermマクロ（TTL）のstrconcat・connect・waitコマンドを使い、SSHリモートログインとパスワード入力を自動化する方法を解説。
- [[Windows] バッチファイルで固定長・可変長の文字列切り取り](./2020-07-23-substring.md) (`How-To | stable | stale_after: 2027-07-28`) — Windowsバッチファイルで:~構文を使った固定長の文字列切り取りや、call・遅延環境変数展開を組み合わせて可変長で部分抽出する方法を解説。
