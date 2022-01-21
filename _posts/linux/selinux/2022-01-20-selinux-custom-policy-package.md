---
layout:        post
title:         "SELinuxでカスタムポリシーパッケージを作成・適用する"
date:          2022-01-20
category:      Linux
cover:         /assets/cover6.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

SELinuxでカスタムポリシーパッケージを作成・適用する方法について説明します。

### カスタムポリシーパッケージの作成手順
まず初めに、checkmodule コマンドと semodule_package コマンドを使って作成するため、以下のパッケージをインストールします。
```bash
$ sudo yum install checkpolicy policycoreutils-python
```
カスタムポリシーパッケージを作成と適用する手順は次のように、.te ファイルを作成したら、checkmoduleコマンドで .mod ファイル（モジュール）を作成し、semodule_packageコマンドで .pp ファイル（ポリシーパッケージ）を作成します。
```bash
# モジュールのコンパイル
$ checkmodule -M -m -o <モジュール名>.mod <モジュール名>.te
# ポリシーパッケージの作成
$ semodule_package -o <モジュール名>.pp -m <モジュール名>.mod
# カーネルへのモジュール読み込み
$ semodule -i <モジュール名>.pp
```
.te ファイル（タイプ強制）の記述方法は、以下の2つのページや `sesearch --allow -s <ドメイン名>` コマンドの結果を参考にしながら、書いていきます。
- [SELinux Notebook -- Access Vector Rules](https://github.com/SELinuxProject/selinux-notebook/blob/main/src/avc_rules.md)
- [SELinux Notebook -- Appendix A - Object Classes and Permissions](https://github.com/SELinuxProject/selinux-notebook/blob/main/src/object_classes_permissions.md)

### teファイルとポリシーパッケージの作成と適用
今回は tomcat_t ドメインのプロセスが、外部と通信したら、許可するがログに残す (auditallow) ように設定します。
```bash
~]# cat <<'EOS' > my_tomcat_policy.te
module my_tomcat_policy 1.0.0;
require {
        type tomcat_t;
        class tcp_socket *;
        class udp_socket *;
        class rawip_socket *;
}
auditallow tomcat_t self:{ tcp_socket udp_socket rawip_socket } *;
EOS
~]# checkmodule -M -m -o my_tomcat_policy.mod my_tomcat_policy.te
~]# semodule_package -o my_tomcat_policy.pp -m my_tomcat_policy.mod
~]# semodule -i my_tomcat_policy.pp
~]# semodule -lfull | grep my_tomcat_policy
```
もし設定を修正して再インストールする場合は、teファイルの1行目のバージョン番号を上げることで、適切に設定がカーネルに反映されたか確認できます。

### 監査ログ
以上で、tomcat_tが外部ポートと通信したイベントがログに残るようになりました。
例えば、Tomcat経由で8080番で待ち受けているWebアプリにアクセスすると、次のようなログが /var/log/audit/audit.log に残ります。
```
type=AVC msg=audit(0000000000.569:186): avc:  granted  { accept } for  pid=1501 comm="java" lport=8080 scontext=system_u:system_r:tomcat_t:s0 tcontext=system_u:system_r:tomcat_t:s0 tclass=tcp_socket
```
他にも、Tomcatが展開したwarファイルの中のJavaが、外部の8888番ポートへ通信した際は次のようなログが残ります。
```
type=AVC msg=audit(0000000000.592:195): avc:  granted  { write } for  pid=1501 comm="java" laddr=::ffff:192.168.56.105 lport=34470 faddr=::ffff:192.168.56.104 fport=8888 scontext=system_u:system_r:tomcat_t:s0 tcontext=system_u:system_r:tomcat_t:s0 tclass=tcp_socket
```

### ポリシーモジュールの無効化・有効化・削除
追加したポリシーは、無効化したり、削除したりすることができます。
```bash
~]# semodule -d my_tomcat_policy    # 無効化
~]# semodule -e my_tomcat_policy    # 有効化
~]# semodule -r my_tomcat_policy    # 削除
```
以上です。

### 参考文献
- [SELinuxProject/selinux-notebook: The SELinux Notebook](https://github.com/SELinuxProject/selinux-notebook)
