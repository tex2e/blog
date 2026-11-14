# linux/httpd

Parent: [All Categories](../../index.md)

## Articles (11)

- [Apache/Nginxのサーバ証明書を更新する](./2021-12-15-update-certificate.md) (`How-To | stable | stale_after: 2025-03-13`) — OpenSSLでのCSR・自己証明書作成から、Apache/Nginx設定ファイル上の配置パス調査およびサーバ証明書・秘密鍵の更新手順を解説します。
- [CMS管理者ログインページへのアクセスを接続元IPで制限する](./2021-12-08-apache-locationmatch-deny-admin.md) (`How-To | stable | stale_after: 2025-03-13`) — ApacheのLocationMatchディレクティブを使い、URLにadminを含むCMS管理画面へのアクセスを許可IPのみに制限する設定と検証手順を解説します。
- [CentOSのApacheでModSecurityを動かす](./2021-12-07-centos-apache-modsecurity.md) (`How-To | stable | stale_after: 2025-03-13`) — CentOSのApacheへオンラインまたはオフラインでModSecurityとCRSを導入し、WAFを有効化してSQLインジェクション遮断を検証する手順を解説します。
- [Nginxでパスやファイルへのアクセス制限をする](./2021-12-02-nginx-access-deny.md) (`How-To | stable | stale_after: 2025-03-13`) — Nginxのlocationディレクティブで正規表現とdeny allやallowを組み合わせ、特定のパスやファイルへのアクセスを制限する方法を解説します。
- [Apacheでパスやファイルへのアクセス制限をする](./2021-12-01-apache-access-deny.md) (`How-To | stable | stale_after: 2025-03-13`) — ApacheのDirectory・LocationMatch・FilesMatchディレクティブを使って特定ディレクトリやURLパス・ファイルへのアクセスを制限する方法を解説します。
- [Apacheで不要な設定ファイルを削除する](./2021-11-30-apache-rm-default-settings.md) (`How-To | stable | stale_after: 2025-03-13`) — Apacheのautoindexやwelcome・userdir・WebDAV・CGIの不要な設定ファイルをリネームして無効化し、セキュリティを強化する手順を解説します。
- [Webコンテンツの所有者・書き込み権限を確認する](./2021-11-29-web-content-permission.md) (`How-To | stable | stale_after: 2025-03-13`) — DocumentRoot配下のファイル所有者をrootへ統一し、その他ユーザに書き込み権限があるディレクトリをfindで検出・修正する方法を説明します。
- [Nginxの起動時のユーザ権限を確認する](./2021-11-25-nginx-start-previlege.md) (`How-To | stable | stale_after: 2025-03-13`) — nginx.confのuserディレクティブを確認し、Nginxがroot権限ではなくnginxユーザで起動しているか検証・修正する方法を説明します。
- [Apacheの起動時のユーザ権限を確認する](./2021-11-24-apache-start-previlege.md) (`How-To | stable | stale_after: 2025-03-13`) — httpd.confのUser・Groupディレクティブを確認し、Apacheがroot権限ではなくapacheユーザで起動しているか検証・修正する方法を説明します。
- [Nginxでリバースプロキシ](./2021-11-11-nginx-reverse-proxy.md) (`How-To | stable | stale_after: 2025-03-13`) — Nginxでupstreamとproxy_passによる同一サーバ内リバースプロキシを設定し、SELinux有効時のhttpd_can_network_relay許可も解説します。
- [Apache で画像やJSやフォントなどのログを除外する](./2019-03-06-apache-customlog-exclude-img.md) (`How-To | stable | stale_after: 2022-06-23`) — ApacheのSetEnvIfとCustomLogを使い、画像・CSS・JS・フォントなどへのアクセスを通常ログから除外または別ログへ分離する方法を解説します。
