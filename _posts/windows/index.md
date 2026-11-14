# windows

Parent: [All Categories](../index.md)

## Articles (18)

- [[Windows] sqlcmdコマンドをインストールする](./2025-08-24-install-sqlcmd.md) (`How-To | stable | stale_after: 2028-08-23`) — 古いTLS非対応の旧sqlcmdを置き換えるため、Windowsへ最新のgo-sqlcmd（ver18）をインストールしSQL Server接続を確認する手順を解説。
- [[Windows] OneDriveを削除してディスク容量を確保する](./2023-11-10-delete-onedrive-files.md) (`How-To | stable | stale_after: 2027-07-28`) — Windows 10でOneDriveをアンインストールし、全ユーザのAppData配下に残るキャッシュフォルダをPowerShellで一括削除する方法を解説。
- [[Windows] CertreqコマンドでCSRファイルを作成する](./2023-08-21-create-csr-file.md) (`How-To | stable | stale_after: 2027-07-28`) — Windows標準のcertreq -NewコマンドとINFファイルを用い、SANs等を含むSSL/TLS証明書用のCSRファイルを作成する手順を解説。
- [pandocでWordファイル(.docx)をMarkdownへ変換する](./2023-04-30-word-to-markdown.md) (`How-To | stable | stale_after: 2027-07-28`) — pandocコマンドでWordファイル（.docx）をGFM形式のMarkdownへ変換し、折り返し無効化や埋め込み画像抽出を行うオプションを解説。
- [AWS EC2のWindows Serverでタイムゾーンを東京/日本時刻にする](./2022-10-05-aws-ec2-windows-server-timezone.md) (`How-To | stable | stale_after: 2023-10-05`) — AWS EC2上のWindows ServerでUTC時刻を日本時間に変更するため、tzutilとreg addでTokyo Standard Timeを永続化する方法。
- [MacからWindowsへRDP接続するとキーボードがJISではなくUS配列になるとき](./2022-08-06-RDP-from-macos.md) (`Troubleshooting | stable | stale_after: 2025-08-06`) — MacからWindowsへRDP接続時にキーボードがUS配列になる不具合について、レジストリのLayout Fileをkbd106.dllへ変更する対処法を解説。
- [[Windows] ローカルのAdministratorsグループに所属するアカウントの確認](./2021-11-18-net-localgroup-administrators.md) (`How-To | stable | stale_after: 2027-07-28`) — コマンドプロンプトのnet localgroup administratorsでローカル管理者グループ所属アカウントを確認し不要ユーザを削除する方法を解説。
- [[Windows] PrintNightmare攻撃を回避するための対策](./2021-11-13-printnightmare.md) (`How-To | stable | stale_after: 2025-07-28`) — PrintNightmare脆弱性（CVE-2021-34527）への回避策として、PowerShellでPrint Spoolerサービスを停止・無効化する手順を解説。
- [[Windows] AlwaysInstallElevatedのレジストリ値を確認する](./2021-11-11-always-install-elevated.md) (`How-To | stable | stale_after: 2027-07-28`) — Windowsの権限昇格につながるAlwaysInstallElevated設定の有無をreg queryコマンドで確認し、無効化を促す手順を解説。
- [[Windows] イベントログを保存する](./2021-11-10-save-eventlog.md) (`How-To | stable | stale_after: 2027-07-28`) — Windowsのイベントビューアーで期間フィルターを適用したセキュリティログをevtx形式および日本語表示情報付きで保存する手順を解説。
- [[Windows] ユーザ端末間のファイル共有を禁止する](./2021-11-09-disable-net-share.md) (`How-To | stable | stale_after: 2027-07-28`) — WindowsでAutoShareWksを0に設定し管理共有を無効化するGPO・レジストリ編集手順と、FirewallによるSMBアクセス制限法を解説。
- [[Windows] レジストリのハイブの省略形の一覧](./2021-11-08-registry-abbreviations.md) (`Reference | stable | stale_after: 2027-07-28`) — Windowsレジストリのハイブ（Hive）の概念と、HKLM・HKCU・HKU・HKCC・HKCRの5つの省略形との対応一覧を紹介。
- [[Windows] セキュリティログ：イベントID 4672 新しいログオンに特権が割り当てられました。とは](./2021-11-07-assigned-privileges.md) (`Concept | stable | stale_after: 2027-07-28`) — WindowsセキュリティログのイベントID 4672が記録される意味と、SeDebugPrivilegeなど割り当てられる主な特権の役割を解説。
- [[Windows] 監査ログのログオンタイプ一覧](./2021-11-06-security-log-logon.md) (`Reference | stable | stale_after: 2027-07-28`) — WindowsセキュリティログのイベントID 4624に記録されるログオンタイプ2〜11の意味と、対話型・ネットワーク・RDP等の判別基準を一覧で紹介。
- [[Windows] セキュリティログで注目すべきイベントID](./2021-11-05-security-log.md) (`Reference | stable | stale_after: 2027-07-28`) — Windowsイベントビューアーのセキュリティログで監視・調査時に注目すべきログオンやプロセス作成、タスク登録等のイベントID一覧。
- [[Windows] Windowsサービスが使用するポート番号の一覧](./2021-07-09-microsoft-ports.md) (`Reference | stable | stale_after: 2027-07-28`) — Kerberos、RPC、NetBIOS、SMB、LDAP、MSSQL、RDPなどWindowsサービスが使用するTCP/UDPポート番号を一覧で整理。
- [[Windows] IISのサイトでHTTPエラー401.3 Unauthorized](./2021-02-27-iis-401-3-unauthorized.md) (`Troubleshooting | stable | stale_after: 2027-07-28`) — IISでHTTPエラー401.3 Unauthorizedが発生する原因を説明し、対象フォルダのセキュリティ設定へIUSRを追加して解消する手順を解説。
- [Windowsで作成したZIPファイルをmacOSで解凍する](./2020-05-12-mac-unzip-windows-file.md) (`How-To | stable | stale_after: 2024-03-21`) — Windowsで作成したZIPファイルをmacOSで解凍するため、dittoコマンドの-V・-x・-kや--passwordオプションの使い方を解説。
