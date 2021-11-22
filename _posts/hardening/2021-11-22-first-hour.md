---
layout:        post
title:         "Hardeningの最初の1時間で作業すべき内容"
date:          2021-11-22
category:      Hardening
cover:         /assets/cover1.jpg
redirect_from:
comments:      false #!!!
published:     false #!!!
latex:         false
photoswipe:    false
syntaxhighlight: true
sitemap: false #!!!
feed:    false #!!!
---

Hardeningは攻撃が始まらない最初の1時間の内に設定を完了させるのが理想的です。

- コメントがない行は実行しても影響がないコマンド
- コメントがある行 (`#`) は設定変更するコマンド

## Linux

#### SSHログイン
```bash
ssh user01@VPN側のIPアドレス
```

#### ログインシェル変更
サービスアカウント (apacheやpostgresなど) はログインシェルを/sbin/nologinにする
```bash
cat /etc/passwd | grep -v -e /sbin/nologin$ -e /bin/false$ \
  -e /bin/sync$ -e /sbin/shutdown$ -e /sbin/halt$
#usermod -s /sbin/nologin ユーザ名
```

#### パスワード変更
パスワード変更後はssh繋いだままで、別のsshでログインできることを確認する。
```bash
# 変数PASSは適宜変更してください！
PASS=TeamXXSrv01
echo root:$PASS!! | chpasswd
echo user01:$PASS | chpasswd
echo user02:$PASS | chpasswd
echo user03:$PASS | chpasswd
echo user04:$PASS | chpasswd
echo user05:$PASS | chpasswd
echo user06:$PASS | chpasswd
echo user07:$PASS | chpasswd
```

#### SELinuxをPermissiveで有効化 (CentOS7)
- 再起動が必要になるので、状況に応じて対応
- 再起動する前に開いているポート一覧を残す (ss -tualpn)
- まずは、Permissiveで動作させることを優先
- 拒否ルールのチューニングは後回し
```bash
grep -E 'kernelopts=(\S+\s+)*(selinux=0|enforcing=0)+\b' /boot/grub2/grubenv
#grub2-mkconfig -o /boot/grub2/grub.cfg

grep ^SELINUX= /etc/selinux/config
#sed -ie 's/^SELINUX=disabled/SELINUX=permissive/' /etc/selinux/config
reboot
```
- SELinuxのコマンド
    - /var/log/audit/audit.log を見ながらMACアクセス拒否ルールを環境に合わせる
    - semanage, sealert などの便利コマンドは最小インストールだと入っていない
    - 許可ルール追加は以下のコマンドで行う
        ```bash
        echo 'audit.logのエラー内容' | audit2allow -M myrule
        semodule -i myrule.pp
        ```
    - ブール値で設定できるものはOn/Offを変える
    - 大丈夫そうだったら setenforce 1 で適用する

SELinuxブール値
- SELinux＆Apache/Nginx
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
    ```
- SELinux＆Tomcat
    ```bash
    # DBサーバへの接続権限
    setsebool -P tomcat_can_network_connect_db On
    ```
- SELinux＆BIND
    ```bash
    # 動的DNSやゾーン転送によるゾーンファイル上書き権限
    setsebool -P named_write_master_zones On
    # DNS over HTTPSの使用権限
    setsebool -P named_tcp_bind_http_port On
    ```
- SELinux＆Docker
    ```bash
    # コンテナが任意のTCPポートに接続する権限
    setsebool -P container_connect_any On
    # コンテナにマウントするディレクトリのラベル付け替え
    chcon -R -t container_file_t /var/mnt
    ```



## FW

$ show configuration //コンフィグを表示
$ configure //設定モード以降
■VyOS自身からの通信を許可
set firewall name OUTSIDE-IN default-action drop
set firewall name OUTSIDE-IN rule 10 action accept
set firewall name OUTSIDE-IN rule 10 state established enable
set firewall name OUTSIDE-IN rule 10 state related enable

■外部からFWへの通信を全拒否（インターフェース要確認）
set firewall name OUTSIDE-FW-IN default-action drop
set firewall name OUTSIDE-FW-IN rule 99 action drop
set firewall name OUTSIDE-FW-IN rule 99 protocol all
set firewall name OUTSIDE-FW-IN rule 99 log 'enable'
set interfaces ethernet eth0 firewall local name OUTSIDE-FW-IN

■外部からサポート端末セグメントへの通信を全拒否（インターフェース要確認）
※EDRを入れる場合、通信要件要確認
※戻り通信も全拒否される
set firewall name OUTSIDE-SUPPORT-IN default-action drop
set firewall name OUTSIDE-SUPPORT-IN rule 99 action drop
set firewall name OUTSIDE-SUPPORT-IN rule 99 protocol all
set firewall name OUTSIDE-SUPPORT-IN rule 99 log 'enable'
set interfaces ethernet ethX firewall in name OUTSIDE-SUPPORT-IN

■設定の適用と保存
変更点確認：compare
変更破棄：discard
変更適用：commit
保存：save


・まず、開いているポート一覧をメモする
・不必要に開いているポートを閉める

VyOS-ConfigurationGuide
https://docs.vyos.io/en/latest/configuration/index.html

何かしら影響が出た場合は、以下のコマンドで切り戻す。
delete firewall name <firewall名>

■外部からサポート端末セグメントへの通信を許可する場合は以下のコマンド
set firewall name OUTSIDE-FW-IN rule <NUM> action accept
set firewall name OUTSIDE-FW-IN rule <NUM> source address x.x.x.x
set firewall name OUTSIDE-FW-IN rule <NUM> source port xx
set firewall name OUTSIDE-FW-IN rule <NUM> destination address x.x.x.x
set firewall name OUTSIDE-FW-IN rule <NUM> destination port xx
set firewall name OUTSIDE-FW-IN rule <NUM> protocol xxx
set firewall name OUTSIDE-FW-IN rule <NUM> log 'enable'

■以下のコマンドでfirewallログのモニターが可能
monitor firewall name <firewall名>

■各IFに以下の設定をしているとログのモニターができて面白いかも
set firewall name <firewall名> default-action drop
set firewall name <firewall名> rule 80 action accept
set firewall name <firewall名> rule 80 action protocol all
set firewall name <firewall名> rule 80 action log 'enable'
set interfaces ethernet ethX firewall <in/out/local> name <firewall名>

-----

■ポート確認(Linuxのコマンド)
ss -tualpn
systemctl disable --now サービス名

ufw deny ポート番号
ufw reload

firewall-cmd --add-service=ssh
firewall-cmd --remove-port=80/tcp
firewall-cmd --runtime-to-permanent

iptables -A INPUT -p tcp --dport 80 -j DROP

外部からDMZのみ許可する
ポートなども絞りたい
MP購入時は導入作業





