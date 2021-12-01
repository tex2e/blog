---
layout:        post
title:         "SELinuxで許可ポート番号を追加/削除する"
menutitle:     "SELinuxで許可ポート番号を追加/削除する (semanage port)"
date:          2021-10-30
category:      Linux
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

SELinuxポリシーの設定では、サービスは特定のポート番号でのみ実行することができます。
例えば、httpd が 80 や 443 以外のポート番号で実行しようとすると、SELinuxによってサービス起動が拒否される場合があります。
一般的なポート番号以外でもサービス起動させたい場合は、ポート番号に関するポリシーにルールを追加する必要があります。

結論だけ書くと、`semanage port -a -t タイプ名 -p tcp ポート番号` でタイプとポート番号の紐付けを行います (UDPの場合は -p udp にします)。

まず、設定前の状態では http は 80, 81, 443, 488, 8008, 8009, 8443, 9000 でサービスを起動することができます。
```bash
~]# semanage port -l | grep http
http_port_t         tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
```
次に、semanage port コマンドの -a (Add: 追加) でルールを登録します（追加に失敗した場合は -m (Modify: 修正) でルールを追加します）。
-t (SELinuxタイプ) と -p (プロトコル tcp/udp) を指定します。
ここでは http がポート 3131 番でLISTENできるようします。
```bash
~]# semanage port -a -t http_port_t -p tcp 3131
~]# semanage port -l | grep http
http_port_t         tcp      3131, 80, 81, 443, 488, 8008, 8009, 8443, 9000
```
/etc/httpd/conf/httpd.conf のApacheの設定でLISTENするポートを80から3131に変更します。
```
Listen 3131
```
設定したら、Apacheを再起動します。正しく起動すれば成功です。
```bash
~]# systemctl restart httpd
~]# curl localhost:3131
```

検証が完了したら、最後に、ポリシーを元に戻しておきます。
登録したポートに関するポリシーを削除する場合は -a を -d (Delete: 削除) に変えて実行するだけです。
```bash
~]# semanage port -d -t http_port_t -p tcp 3131
```

### 補足：ポート番号を追加しない場合

semanage port に http が実行できるポートに3131番を追加しないで、3131/tcpでLISTENしようとすると、SELinuxによってアクセス拒否されます。messages と audit.log にはそれぞれ次のようなエラーが記録されます。

/var/log/messages
```
localhost httpd[8698]: (13)Permission denied: AH00072: make_sock: could not bind to address [::]:3131
localhost httpd[8698]: (13)Permission denied: AH00072: make_sock: could not bind to address 0.0.0.0:3131
```
/var/log/audit/audit.log
```
type=AVC msg=audit(0000000000.214:1561): avc:  denied  { name_bind } for  pid=8698 comm="httpd" src=3131 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
```
SELinuxのポリシーに基づいて、httpd が3131ポートでソケット通信を待ち受けることが拒否されたことがログに残っています。

以上です。

