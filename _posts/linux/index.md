# linux

Parent: [All Categories](../index.md)

## Subcategories

- [firewall/](./firewall/index.md) (3 posts)
- [httpd/](./httpd/index.md) (11 posts)
- [ssh/](./ssh/index.md) (5 posts)

## Articles (39)

- [[Linux] 共有ライブラリの読み込みエラーをLD_LIBRARY_PATHで解決させる](./2025-09-23-cannot-open-shared-lib.md) (`Troubleshooting | stable | stale_after: 2028-09-23`) — ソースビルドしたOpenSSL実行時の共有ライブラリ読み込みエラーの原因をlddで調査し、LD_LIBRARY_PATHで解決する方法を解説します。
- [[Linux] sqlcmdとbcpコマンドをインストールする](./2025-08-24-install-sqlcmd-bcp.md) (`How-To | stable | stale_after: 2028-08-23`) — Ubuntu環境にMicrosoftリポジトリを追加してmsodbcsql18とmssql-tools18を導入し、sqlcmdとbcpコマンドへパスを通す手順を解説します。
- [Rocky Linux で hostnamectl コマンドでサーバ名を変更する](./2024-01-30-rocky-change-hostname.md) (`How-To | stable | stale_after: 2027-11-28`) — Rocky Linuxでhostnamectl set-hostnameとsystemd-hostnamed再起動によりホスト名を変更し、/etc/hostsを更新する手順を解説します。
- [Rocky Linux における nmcil によるIPアドレス固定](./2024-01-29-rocky-nmcli-change-ipaddr.md) (`How-To | stable | stale_after: 2027-02-03`) — Rocky Linuxでnmcli conn modを使いIPv4アドレス指定後にmethodをmanualへ変更してIPアドレスを固定化する手順を解説します。
- [systemdからinit.dのスクリプトを呼び出すまでの流れ](./2023-11-13-systemd-call-initd.md) (`Concept | stable | stale_after: 2026-11-12`) — 起動時にsystemd-sysv-generatorが/etc/rc?.d配下のinit.dスクリプトをユニットへ変換しsystemctlから制御可能にする仕組みを解説します。
- [Ubuntu22.04で固定IPの設定やDNSの変更をする (netplan)](./2023-05-01-ubuntu-netplan.md) (`How-To | stable | stale_after: 2026-05-01`) — Ubuntu 22.04のNetplan設定YAMLを編集し、固定IPアドレス・DNSサーバ・デフォルトゲートウェイを設定して適用する手順を解説します。
- [CentOS8でハードディスクを拡張する手順](./2022-11-05-extend-hdd-centos.md) (`How-To | stable | stale_after: 2025-11-05`) — CentOS 8で仮想ディスク拡張後にfdisk・pvcreate・vgextend・lvextend・xfs_growfsを用いてLVM領域を拡張する手順を解説します。
- [Linuxのスワップファイルを増やす方法](./2022-11-04-swapfile.md) (`How-To | stable | stale_after: 2025-11-05`) — dd・mkswap・swaponコマンドでLinuxのスワップファイルを作成して領域を拡張し、/etc/fstabへ追記して永続化する手順を解説します。
- [pingは失敗するがdigの名前解決はできる場合の対処法 (nsswitch.conf)](./2022-10-30-nsswitch.md) (`Troubleshooting | stable | stale_after: 2025-10-30`) — digでは名前解決できるのにpingで名前解決に失敗する事象について、/etc/nsswitch.confのhosts行を確認・修正する対処法を解説します。
- [lsofでファイルを開いているプログラムを特定する](./2022-10-29-lsof-check-open-pgm.md) (`How-To | stable | stale_after: 2025-10-30`) — lsofコマンドを使って指定ファイルやディレクトリ・PID・ソケットを開いているプロセスを特定する方法とssとの使い分けを説明します。
- [aptでdebのダウンロードと配置先の確認方法](./2022-01-12-apt-download-only.md) (`How-To | stable | stale_after: 2025-03-13`) — aptの--download-onlyオプションでdebパッケージのみを取得し、dpkg-deb -cで展開先パスと収録ファイルを確認する方法を説明します。
- [Linuxで消せない・編集できないファイルの作り方 (chattr)](./2021-12-12-chattr-lsattr.md) (`How-To | stable | stale_after: 2026-11-05`) — extファイルシステムでchattrコマンドによりファイルやディレクトリへ不変属性を付与・解除し、lsattrで確認する方法を説明します。
- [AppArmorでcurlとwgetコマンドの動作を制限する](./2021-12-09-apparmor-curl-wget.md) (`How-To | stable | stale_after: 2027-07-28`) — Ubuntu等でAppArmorのaa-genprofを用いて空に近いプロファイルを作成し、curlとwgetの実行を制限する手順を解説します。
- [ログインシェルが存在するユーザ一覧を表示する](./2021-12-06-list-users-have-loginshell.md) (`How-To | stable | stale_after: 2025-03-13`) — /etc/passwdからログインシェルが有効なユーザをgrepで抽出し、不要アカウントをusermod -sで無効化する方法を説明します。
- [systemctlで disabled かつ start しているサービスを調べる](./2021-12-05-systemctl-disabled-and-started.md) (`How-To | stable | stale_after: 2025-03-13`) — systemctl list-unit-filesとsystemctl statusを組み合わせ、自動起動が無効のまま稼働中のサービスを特定する方法を説明します。
- [Linuxで重要なファイルの権限を確認する](./2021-11-28-file-permission.md) (`How-To | stable | stale_after: 2025-03-13`) — passwd・shadow・group・PATH配下・cron・SSH秘密鍵といった重要ファイルの権限を確認・修正する堅牢化手順を解説します。
- [/etc/cron.denyでユーザがcrontabを編集できないようにする](./2021-11-27-cron-deny.md) (`How-To | stable | stale_after: 2025-03-13`) — /etc/cron.denyや/etc/cron.allowを用いて一般ユーザのcrontab編集を禁止し、既存ジョブを精査する方法を説明します。
- [systemctl で /tmp 内のファイルを実行不可にする](./2021-11-17-tmp-noexec.md) (`How-To | stable | stale_after: 2025-03-13`) — systemdのtmp.mountユニット設定にnoexecオプションを追加し、/tmpディレクトリ配下でのファイル実行を禁止する手順を解説します。
- [systemctlで有効・無効なサービス一覧を表示する](./2021-11-16-systemctl-list-services.md) (`How-To | stable | stale_after: 2026-09-17`) — systemctl list-unit-filesとgrepを組み合わせて、起動時に有効化または無効化されているサービス一覧を表示する方法を説明します。
- [ログインシェルを /sbin/nologin にしたユーザにログインする](./2021-11-15-su-sbin-nologin-user.md) (`How-To | stable | stale_after: 2025-07-16`) — ログインシェルが/sbin/nologinに設定されたユーザに対し、suコマンドの--shell=/bin/bashオプションでログインする方法を説明します。
- [SUID/SGIDファイルをfindコマンドで見つける](./2021-11-13-find-suid-sgid-files.md) (`How-To | stable | stale_after: 2025-03-13`) — 権限昇格の踏み台になり得るSUIDやSGIDビット付きファイルをfindコマンドで検出し、不要なフラグを精査する方法を説明します。
- [不要なWebコンテンツファイルを削除する](./2021-11-12-remove-unnecessary.md) (`How-To | stable | stale_after: 2025-03-13`) — Web公開ディレクトリ配下からreadmeや設定・ダンプ等の不要ファイルをfindで検出し、削除や権限制限を行う方法を説明します。
- [Linuxでスケジュールされたジョブを確認する](./2021-11-07-scheduled-jobs.md) (`How-To | stable | stale_after: 2025-03-13`) — Linuxで意図しない定期実行を調査するため、cron関連ディレクトリや各ユーザのcrontab、atジョブの中身を確認・削除する方法を解説します。
- [BINDで再帰問い合わせを無効化する](./2021-11-06-bind-dns-recursion.md) (`How-To | stable | stale_after: 2025-03-13`) — DNS増幅攻撃対策としてBINDのnamed.confでrecursion noを設定し、再帰問い合わせを無効化する手順と動作の違いを解説します。
- [BINDによるDNSサーバの構築](./2021-11-05-bind-dns-server.md) (`How-To | stable | stale_after: 2025-03-13`) — CentOSでBINDを用いたDNSサーバを構築し、正引き・逆引きゾーンの設定とdigやnslookupでの動作確認を行う手順を解説します。
- [[Linux] タイムゾーンと時刻を手動で修正する](./2021-10-10-fix-date.md) (`How-To | stable | stale_after: 2027-07-28`) — NTPが使えないLinux環境においてtimedatectlとdate -sコマンドでタイムゾーンと現在時刻を手動設定する方法を解説します。
- [Parallels 仮想環境のSSHサーバ設定](./2021-07-19-parallels-vms.md) (`How-To | stable | stale_after: 2025-03-13`) — macOSのParallels上でKali LinuxとFedoraにOpenSSHサーバとsudo権限付きユーザをセットアップする手順をまとめます。
- [useradd, usermod によるLinuxグループへの追加](./2021-05-22-useradd-usermod.md) (`How-To | stable | stale_after: 2027-01-28`) — useradd -Gによる新規ユーザ作成時のグループ割り当てやusermod -aGによる既存ユーザへの追加方法と注意点を説明します。
- [apt upgradeでセキュリティアップデートのみ適用する](./2021-05-21-install-only-security-updates.md) (`How-To | stable | stale_after: 2025-09-04`) — Ubuntuでapt upgradeの代わりにunattended-upgradeを使い、ドライランで確認しつつセキュリティ更新のみを適用する方法を説明します。
- [[Kali Linux] 起動時に自動ログインできるように設定する](./2021-04-22-autologin.md) (`How-To | stable | stale_after: 2027-07-28`) — Kali Linuxでlightdmやgdm3の設定ファイルを修正し、起動時にパスワード入力なしで自動ログインさせる手順を解説します。
- [OpenVASをKali Linuxにインストール](./2021-04-06-openvas-installation.md) (`How-To | stable | stale_after: 2025-03-13`) — Kali LinuxにOpenVAS(GVM)をインストールして初期セットアップ、ユーザ作成、脆弱性スキャンの実行までを行う手順を解説。
- [tmuxの使い方の概要](./2020-02-28-tmux-tutorial.md) (`Reference | stable | stale_after: 2027-07-28`) — ターミナルマルチプレクサtmuxのセッション復帰デモとセッション・ウィンドウ・ペイン操作のコマンドやショートカット一覧。
- [技術検証用にCentOS7を仮想環境にインストールする](./2019-07-12-virtual-box-centos.md) (`How-To | stable | stale_after: 2023-11-28`) — VirtualBox上にCentOS 7をインストールしネットワーク設定やSSH公開鍵認証、クローンによる複数台検証環境を構築する手順。
- [/tmp ディレクトリのパーミッション](./2019-06-23-tmp-directory-permission.md) (`How-To | stable | stale_after: 2022-06-23`) — 全ユーザが書込可能な/tmpディレクトリで誤削除を防ぐスティッキービットの仕組みとchmodによる設定・解除・確認方法を解説。
- [Postfix & Dovecot のサーバ構築](./2019-03-09-centos-install-postfix-dovecot.md) (`How-To | stable | stale_after: 2024-10-30`) — CentOS環境にPostfixとDovecotをインストールしてMaildir形式を用いたSMTPおよびPOP3メールサーバを構築・疎通確認する手順。
- [systemdでプロセス自動再起動](./2019-03-08-systemd-restart-config.md) (`How-To | stable | stale_after: 2026-09-17`) — systemdのUnitファイルにあるRestart設定値の意味とプロセス異常終了時に自動再起動させるための構成と動作確認手順を解説。
- [RPMパッケージのダウンロードとインストール](./2019-03-07-rpm-tutorial.md) (`How-To | stable | stale_after: 2025-01-12`) — Red Hat系Linuxでyumのdownloadonlyプラグインを用いてRPMパッケージを取得しrpmコマンドで導入・更新・確認・削除する方法。
- [systemd のユニットファイルの作り方](./2019-03-05-create-my-systemd-service.md) (`How-To | stable | stale_after: 2026-09-17`) — CentOSでUnit・Service・Installセクションの構造を解説しつつ自作サービス用のsystemdユニットファイルを作成し起動する手順。
- [/tmp/systemd-private-* の意味について](./2019-03-04-tmp-systemd-private.md) (`Concept | stable | stale_after: 2025-02-27`) — systemdのPrivateTmp=trueにより生成される/tmp/systemd-private-*ディレクトリの仕組みとLinux名前空間による分離効果を解説。
