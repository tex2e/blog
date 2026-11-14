# selinux

Parent: [All Categories](../index.md)

## Subcategories

- [selinux-book/](./selinux-book/index.md) (3 posts)

## Articles (41)

- [SELinuxでDockerのセキュリティを強化する](./2024-05-18-docker.md) (`How-To | stable | stale_after: 2027-05-18`) — Rocky Linux上でDockerのsystemdユニットに--selinux-enabledを設定し、container_tやcontainer_file_tによるホスト保護を検証する手順を解説します。
- [競技でのSELinux導入手順（チーム向け説明資料）](./2022-11-05-hardening-project.md) (`How-To | draft`) — セキュリティ競技向けに、再起動時はPermissiveで起動し拒否ログ収集と例外ルール適用を経てEnforcingへ切り替えるSELinux導入手順とコマンド集です。
- [Dirty Pipeの脆弱性をSELinuxで緩和する](./2022-03-15-dirty-pipe.md) (`How-To | stable | stale_after: 2023-10-23`) — Linuxカーネルの脆弱性Dirty Pipe(CVE-2022-0847)に対し、SELinuxユーザの制限ドメインを用いてPoCによる権限昇格を緩和する検証と対策を解説します。
- [Ubuntu 20.04でSELinuxを有効化する](./2022-03-11-ubuntu-install-selinux.md) (`How-To | stable | stale_after: 2025-10-23`) — Ubuntu 20.04環境で標準のAppArmorを無効化・削除し、selinux-basicsなどを導入してselinux-activateでSELinuxを有効化する手順を解説します。
- [SELinuxのマニュアル(manページ)をインストールする](./2022-01-22-selinux-manpage.md) (`How-To | stable | stale_after: 2025-10-23`) — selinux-policy-docパッケージをインストールし、httpd_selinuxやpostgresql_selinuxなど対象別のSELinux用manページを閲覧する方法を解説します。
- [SELinuxのポリシーパッケージ (.pp) を CIL に変換して中身を確認する](./2022-01-21-selinux-convert-pp-to-cil.md) (`How-To | stable | stale_after: 2025-10-23`) — バイナリ形式のSELinuxポリシーパッケージ(.pp)を/usr/libexec/selinux/hll/ppコマンドで可読なCIL形式に変換し、内容を確認する方法を解説します。
- [SELinuxでカスタムポリシーパッケージを作成・適用する](./2022-01-20-selinux-custom-policy-package.md) (`How-To | stable | stale_after: 2025-10-23`) — teファイルの作成からcheckmodule・semodule_packageでのコンパイル、semoduleによるカーネルへの適用・無効化・削除までの手順を解説します。
- [SELinuxで個別追加した設定を別のサーバにも適用する](./2021-12-25-semanage-export.md) (`How-To | stable | stale_after: 2025-10-23`) — semanage exportとsemanage importを使い、SELinuxに追加した個別設定をテキスト出力して別のサーバへ移行・適用する方法を解説します。
- [SELinuxのドメイン遷移の一覧を表示する](./2021-12-25-selinux-domain-transition.md) (`How-To | stable | stale_after: 2025-10-23`) — sepolicy transitionコマンドでSELinuxのドメイン遷移ルール一覧を表示する方法と、sshd_tやhttpd_tを例に出力形式の読み方を解説します。
- [SELinuxポリシー(Access Vector)の一覧を表示する](./2021-12-25-list-selinux-policy.md) (`How-To | stable | stale_after: 2025-10-23`) — setools-consoleのsesearchコマンドを使ってSELinuxのAccess Vectorポリシーを検索・表示する方法と、出力フォーマットの読み方を解説します。
- [Hardening Projectで記録されたSELinuxによる拒否ログの一覧](./2021-12-18-hardening-project-auditlog.md) (`Essay | stable`) — Hardening Project競技中にSELinuxを有効化して観測したaudit.logの拒否ログをサーバ別に整理し、攻撃内容や対処を振り返ります。
- [SELinuxとauditdでハニーポットもどきを作る](./2021-12-17-simple-honeypot.md) (`How-To | stable | stale_after: 2025-10-23`) — SELinuxのstaff_uで権限昇格を制限したSSHユーザを作成し、auditdのexecve監視ルールで実行コマンドをすべて記録する手順と検証ログを解説します。
- [SELinuxのstaff_uがsudoできるコマンドを限定する (/etc/sudoers)](./2021-12-14-selinux-staff_u-sudo.md) (`How-To | stable | stale_after: 2025-10-23`) — SELinuxのstaff_uユーザに対し、/etc/sudoersでROLEとTYPEを指定してsudo実行可能なコマンドを限定する設定手順とロール追加方法を解説します。
- [CentOSでsemanageコマンドをインストールする](./2021-12-13-install-semanage.md) (`How-To | stable | stale_after: 2025-10-23`) — CentOS 7およびCentOS 8/Stream 9の最小インストール環境で、yumやdnfを使ってsemanageやaudit2allowを含むパッケージを導入する手順を解説します。
- [SELinux上でhttpdがファイルを実行可能にする](./2021-12-11-httpd_sys_script_exec_t.md) (`How-To | stable | stale_after: 2025-10-23`) — SELinux有効環境でhttpdがスクリプトを実行できるよう、実行ファイルのコンテキストをhttpd_sys_script_exec_tに変更して検証する手順を解説します。
- [SELinux上でhttpdがファイル書き込み可能にする](./2021-12-10-httpd_sys_rw_content_t.md) (`How-To | stable | stale_after: 2025-10-23`) — Apache(httpd)が特定ディレクトリへ書き込めるように、対象のSELinuxコンテキストをhttpd_sys_rw_content_tへ変更し動作検証する手順を解説します。
- [usermod -Z でSELinuxユーザを割り当てる](./2021-11-24-usermod-Z.md) (`How-To | stable | stale_after: 2025-10-23`) — semanageコマンドがない最小構成のCentOS環境でも利用できるusermod -Zを使い、LinuxユーザにSELinuxユーザを割り当てる方法を解説します。
- [CentOS 7の最小インストールで使用可能なSELinuxコマンドの一覧](./2021-11-24-selinux-minimal-install.md) (`Reference | stable | stale_after: 2025-10-23`) — CentOS 7のMinimal環境で標準利用できるSELinuxコマンドとパッケージの対応表、およびオフライン環境へのrpm追加手順をまとめています。
- [SELinuxのアクセス拒否の監査ログ(audit.log)の読み方](./2021-11-24-selinux-denied-log.md) (`Reference | stable | stale_after: 2025-10-23`) — SELinuxのaudit.logに出力されるavc: deniedログのフォーマットと、operation・scontext・tcontext・tclassなど各項目の意味を解説します。
- [SELinuxでユーザのファイル実行を制限する](./2021-11-23-selinux-noexec.md) (`How-To | stable | stale_after: 2025-10-23`) — SELinuxのsysadm_exec_contentなどのブール値を用いて、ユーザのホームディレクトリや/tmp配下のファイル実行を制限する設定と検証結果を解説します。
- [CIS Benchmarkを元にSELinuxの設定をする](./2021-11-19-selinux-cis-benchmark.md) (`How-To | stable | stale_after: 2025-10-23`) — CIS Benchmarkに基づき、SELinuxの有効化やブートローダー設定、Enforceモード、不要パッケージ削除の確認・修正方法を解説します。
- [[SELinux] Webやメールサーバのプロセスのドメイン](./2021-11-18-selinux-process-type.md) (`Reference | stable | stale_after: 2027-07-30`) — sshdやhttpd、named、postfix、dovecot、mysqld、dockerなど主要サーバプロセスのSELinuxドメイン一覧をまとめたリファレンスです。
- [httpd に関するSELinuxブール値](./2021-11-14-selinux-httpd-boolean.md) (`Reference | stable | stale_after: 2025-10-23`) — ApacheやNginxなどのhttpdでよく使うSELinuxブール値の名前・デフォルト値・機能と主要なSELinuxタイプをまとめたリファレンスです。
- [ポート番号を変更したBINDをSELinuxで許可する](./2021-11-08-dns-bind-change-port-with-selinux.md) (`How-To | stable | stale_after: 2025-10-23`) — BINDの待受ポートを53から5353へ変更した際に発生するSELinux拒否をsealertで確認し、semanage portでdns_port_tに許可設定する手順を解説します。
- [監査ログからSELinuxアクセス拒否を一括で許可する](./2021-11-04-selinux-allow-from-denied-log.md) (`How-To | stable | stale_after: 2025-10-23`) — audit2allowコマンドで監査ログの原因確認や許可ルール生成を行い、semodule -iでカスタムポリシーモジュールを適用する手順を解説します。
- [SELinuxによるアクセス拒否のログを発見する](./2021-11-03-selinux-log.md) (`Troubleshooting | stable | stale_after: 2025-10-23`) — SELinuxによるアクセス拒否ログを/var/log/audit/audit.logや/var/log/messagesからgrepやtail -fで抽出し発見する方法を解説します。
- [SELinuxのサイレント拒否を無効化/有効化する](./2021-11-02-selinux-disable-dontaudit.md) (`How-To | stable | stale_after: 2025-10-23`) — トラブルシューティング時にすべての拒否ログを記録するため、semodule -DBでdontauditのサイレント拒否を無効化および再有効化する方法を解説します。
- [SELinuxでApacheで/var/wwwから変更した先のパスも許可する](./2021-11-01-selinux-httpd-change-documentroot.md) (`How-To | stable | stale_after: 2025-10-23`) — Apacheのドキュメントルートを/var/wwwから変更した際に、semanage fcontext -eとrestoreconで新しいパスをSELinux上で許可する手順を解説します。
- [SELinuxによるドメインに対する制限を無くす](./2021-10-31-selinux-permissive-process.md) (`How-To | stable | stale_after: 2025-10-23`) — システム全体ではなくhttpd_tなど特定のSELinuxドメインのみをsemanage permissiveコマンドでPermissiveモードに設定・解除する方法を解説します。
- [SELinuxで許可ポート番号を追加/削除する](./2021-10-30-semanage-port.md) (`How-To | stable | stale_after: 2025-10-23`) — semanage portコマンドを使ってhttp_port_tなどのSELinuxタイプに許可ポート番号を追加・変更・削除する手順を解説します。
- [SELinuxユーザのデフォルトマッピングを変更する](./2021-10-29-selinux-user-mapping.md) (`How-To | stable | stale_after: 2025-10-23`) — 新規Linuxユーザー作成時のデフォルトSELinuxユーザをunconfined_uからuser_uへsemanage loginで変更し、権限昇格リスクを低減する手順を解説します。
- [SELinuxユーザによる権限昇格対策](./2021-10-28-selinux-user.md) (`Concept | stable | stale_after: 2025-10-23`) — sysadm_uやstaff_u、user_uなどSELinuxユーザごとの権限一覧と、suやsudoの制限による権限昇格対策の仕組みを検証とともに解説します。
- [SELinuxによるコマンドに対する制限を完全に無くす](./2021-10-27-selinux-unrestricted-process.md) (`How-To | stable | stale_after: 2025-10-23`) — 実行ファイルにchcon -t bin_tを設定することで、httpdなどのプロセスをunconfined_service_tとしてSELinux制限なしで動作させる方法を解説します。
- [ptrace を SELinux で無効化する](./2021-10-26-selinux-ptrace.md) (`How-To | stable | stale_after: 2025-10-23`) — メモリ改ざん攻撃への対策として、SELinuxのdeny_ptraceブール値を用いて全ユーザーのptraceシステムコール利用を禁止する設定方法を解説します。
- [ファイルのデフォルトSELinuxコンテキストを確認する](./2021-10-25-verify-default-selinux-context.md) (`How-To | stable | stale_after: 2025-10-23`) — matchpathconコマンドを使ってファイルやディレクトリの現在のSELinuxコンテキストがポリシールールのデフォルトと一致するか検証する方法を解説します。
- [cpでSELinuxコンテキストもコピーする](./2021-10-24-copy-with-selinux-context.md) (`How-To | stable | stale_after: 2025-10-23`) — cpコマンドの--preserve=contextオプションでSELinuxコンテキストを保持してコピーする方法と、mvコマンドとのコンテキスト継承の違いを解説します。
- [永続的にSELinuxコンテキストを変更する (semanage fcontext)](./2021-10-23-semanage-fcontext.md) (`How-To | stable | stale_after: 2025-10-23`) — semanage fcontextコマンドでファイルやディレクトリのSELinuxコンテキストルールを永続的に追加・削除し、restoreconで反映する手順を解説します。
- [一時的にSELinuxコンテキストを変更する (chcon)](./2021-10-22-selinux-chcon.md) (`How-To | stable | stale_after: 2025-10-23`) — chconコマンドを用いてファイルやディレクトリのSELinuxコンテキストを一時的に変更する方法と、restoreconによる復元方法を解説します。
- [ApacheとNginxプロセスのSELinuxコンテキスト](./2021-10-21-selinux-httpd_t-apache-nginx.md) (`Concept | stable | stale_after: 2025-10-23`) — ApacheとNginxはどちらもSELinux上で同じhttpd_tドメインで動作し、http_port_tや関連ブール値が共通適用されることをps -eZで確認します。
- [SELinuxによるPHPバックドア(WebShell)の<br>OSコマンド実行拒否と例外ルール作成](./2021-10-20-selinux-and-php-backdoor.md) (`How-To | stable | stale_after: 2025-10-23`) — SELinux環境下でPHP製WebShellによるcurl実行が拒否される挙動を検証し、audit2allowやブール値で例外ルールを作成する手順を解説します。
- [SELinuxを有効化する](./2021-10-19-enable-selinux.md) (`How-To | stable | stale_after: 2025-10-23`) — ブートローダーのgrub設定確認から/etc/selinux/configの編集、setenforceによるSELinuxの有効化手順を解説します。
