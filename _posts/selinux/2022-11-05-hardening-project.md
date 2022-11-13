---
layout:        post
title:         "競技でのSELinux導入手順（チーム向け説明資料）"
date:          2022-11-05
category:      SELinux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
draft: true
---

### 概要

WASNight 2022 Kick-Off のLT発表したスライド「[SELinuxで堅牢化する](https://speakerdeck.com/tex2e/selinux)」をご覧ください。

SELinuxの対応方針としては「Permissive + setenforce 1」の運用で行きたい。
以下は理由です：
- 競技時間の8時間を耐えれば良いため
- 復旧できるように起動時は permissive にしておく

### 作業手順

1. /etc/selinux/configでPermissiveにする
2. サーバを再起動する
3. 許容モード (Permissive Mode) で動作確認して拒否ログを集める
4. 拒否ログの内容に応じて、例外ルールを作成して適用する
5. `setenforce 1` でモード変更
6. 強制モード (Enforcing Mode) で動作確認、拒否ログ監視

#### SELinux関連コマンド有無の確認

```bash
getenforce
which audit2allow
which semanage
```

#### SELinux有効化〜再起動

```bash
### ブートローダーの設定確認 (CentOS7以上)
# /boot/grub2/grubenvファイルから、selinux=0とenforcing=0を削除する
grep -E 'kernelopts=(\S+\s+)*(selinux=0|enforcing=0)+\b' /boot/grub2/grubenv
# 設定ファイル再作成
grub2-mkconfig -o /boot/grub2/grub.cfg

### ブートローダーの設定確認 (CentOS6)
# /boot/efi/EFI/*/grub.confファイルや/boot/grub/grub.confファイルから、selinux=0とenforcing=0を削除する
[ -f /boot/efi/EFI/*/grub.conf ] && grep '^\s*kernel' /boot/efi/EFI/*/grub.conf | grep -E '(selinux=0|enforcing=0)' || grep '^\s*kernel' /boot/grub/grub.conf | grep -E '(selinux=0|enforcing=0)'

### SELinux有効化の設定
grep ^SELINUX= /etc/selinux/config
sed -ie 's/^SELINUX=disabled/SELINUX=permissive/' /etc/selinux/config
reboot
```

#### 再起動後〜許容モード適用

```bash
# SELinuxが有効か確認
getenforce
# 監査ログに拒否ログが記録されないか確認
tail -f /var/log/audit/audit.log | grep "denied"
```

監査ログのUnix時間は読みにくいので、自作の[Unixtime2Datetime](https://tex2e.github.io/unixtime2datetime/)のサイトにログ内容を貼り付けて確認する。

```bash
# 拒否ログの詳細と修正方法の提案
sealert -l "*"
# 例外ルールの作成・適用
echo '</var/log/audit/audit.logのdeniedが含まれている行>' | audit2allow -M my-module
semodule -X 300 -i my-module.pp
semodule --list-modules=full | grep my-module -3
```

#### 許容モード適用後〜強制モード適用

```bash
# Enforcingに設定
setenforce 1
# 監査ログに拒否ログが記録されないか確認
tail -f /var/log/audit/audit.log | grep "denied"
```

<br>

### その他の役立つコマンド集

#### SELinux基本コマンド
```bash
getenforce    # 状態確認
setenforce 0  # Permissiveに設定
setenforce 1  # Enforcingに設定

# サブジェクト
id -Z                          # 自分自身
ps -efZ                        # プロセス

# オブジェクト
ls -Z                          # ファイル・ディレクトリ
matchpathcon -V <ファイル名>     # デフォルトとの差分
chcon -t <タイプ> <ファイル名>    # ラベル付け替え
restorecon -R -v <ディレクトリ>  # デフォルトに戻す
```

#### SELinux コンテキスト確認
```bash
# ブール値一覧
semanage boolean -l
# ログイン一覧
semanage login -l
# ファイルのコンテキスト一覧
semanage fcontext -l
# ポート一覧
semanage port -l
# ユーザ一覧
semanage user -l
```

#### SELinux＆Apache/Nginx
```bash
# PHP実行権限
setsebool -P httpd_builtin_scripting On
# メール送信権限
setsebool -P httpd_can_sendmail On
# DBサーバへの接続権限
setsebool -P httpd_can_network_connect_db On
# LDAPサーバへの接続権限
setsebool -P httpd_can_connect_ldap On
# TCPで任意のサーバへの接続権限
setsebool -P httpd_can_network_connect On
# リバースプロキシとしての動作権限
setsebool -P httpd_can_network_relay On
# CGIの実行権限（実行ファイルは httpd_sys_script_exec_t のラベル付けが必要）
setsebool -P httpd_enable_cgi On
# ユーザのホームディレクトリへのアクセス権限
setsebool -P httpd_enable_homedirs On

# 一般ポート以外を使用するとき（新規追加）
semanage port -a -t http_port_t -p tcp 10080
# 一般ポート以外を使用するとき（修正）
semanage port -m -t http_port_t -p tcp 10080

# ドキュメントルートの変更
semanage fcontext -a -e /var/www /var/test_www
restorecon -R -v /var/test_www
# Webコンテンツのラベル付けの追加
chcon -t httpd_sys_rw_content_t /var/www/html/upload
semanage fcontext -a -t httpd_sys_content_t "/var/srv/myweb(/.*)?"
semanage fcontext -a -t httpd_sys_rw_content_t "/var/srv/myweb/upload(/.*)?"
semanage fcontext -a -t httpd_sys_script_exec_t "/var/srv/myweb/cgi-bin(/.*)?"

# httpdでよく使用する重要なタイプ
#   httpd_sys_content_t (読み取り)
#   httpd_sys_rw_content_t (読み書き)
#   httpd_sys_script_exec_t (実行)
```

#### SELinux＆Tomcat
```bash
# DBサーバへの接続権限
setsebool -P tomcat_can_network_connect_db On
```

#### SELinux＆MySQL
```bash
# HTTPポートへの接続権限
setsebool -P mysql_connect_http On
# 任意のポートへの接続権限
setsebool -P mysql_connect_any On
# ユーザがローカルのMySQLサーバに接続する権限
setsebool -P selinuxuser_mysql_connect_enabled On

# 一般ポート以外を使用するとき（新規追加）
semanage port -a -t mysqld_port_t -p tcp 13306
```

#### SELinux＆PostgreSQL
```bash
# ユーザがローカルのPostgreSQLサーバに接続する権限
setsebool -P selinuxuser_postgresql_connect_enabled On

# 一般ポート以外を使用するとき（新規追加）
semanage port -a -t postgresql_port_t -p tcp 5432
```

#### SELinux＆BIND
```bash
# 動的DNSやゾーン転送によるゾーンファイル上書き権限
setsebool -P named_write_master_zones On
# DNS over HTTPS の使用権限
setsebool -P named_tcp_bind_http_port On

# 一般ポート以外を使用するとき（新規追加）
semanage port -a -t dns_port_t -p tcp 5353
semanage port -a -t dns_port_t -p udp 5353
# 一般ポート以外を使用するとき（修正）
semanage port -m -t dns_port_t -p tcp 5353
semanage port -m -t dns_port_t -p udp 5353
```

#### SELinux＆SSH
```bash
# LinuxユーザにSELinuxユーザを割り当てる
semanage login -a -s sysadm_u <ユーザ名>
# sysadm_uのユーザのSSHログイン権限
setsebool -P ssh_sysadm_login On

# 一般ポート以外を使用するとき（新規追加）
semanage port -a -t ssh_port_t -p tcp 10022
```

#### SELinux＆Docker
```bash
# コンテナが任意のTCPポートに接続する権限
setsebool -P container_connect_any On

# コンテナにマウントするディレクトリのラベル付け替え
chcon -R -t container_file_t /var/mnt
```

#### SELinux＆Users
```bash
# ログインシェル無効化
usermod -s /sbin/nologin <ユーザ名>
# ログインシェル有効化
usermod -s /bin/bash <ユーザ名>
# ロック
usermod -L <ユーザ名>
# アンロック
usermod -U <ユーザ名>
# 一般ユーザのファイル実行権限を制限する
semanage login -a -s user_u <ユーザ名>
setsebool -P user_exec_content Off
semanage login -l
```

#### 特定プロセスの例外化（許可ルールのチューニングに失敗した時）
```bash
# 実行ファイルの、SELinuxによる制限をなくす
chcon -t bin_t /sbin/httpd
# 特定ユーザの、SELinuxによる制限をなくす
semanage login -a -s unconfined_u <ユーザ名>
```

#### SELinux拒否ログ確認
```bash
# SELinuxによる拒否ログの検索
grep "denied" /var/log/audit/audit.log
grep "SELinux is preventing" /var/log/messages
# tailf版
tail -f /var/log/audit/audit.log | grep "denied"
tail -f /var/log/messages | grep "SELinux is preventing"
```

#### SELinuxの許可ルールの作成と適用
```bash
# 拒否ログの詳細と修正方法の提案
sealert -l "*"
# 例外ルールのインストール
echo '</var/log/audit/audit.logのdeniedが含まれている行の内容>' | audit2allow -M my-module
semodule -i myrule.pp
# 例外ルールの一覧確認
semodule --list-modules=full | grep my-module -3
```

