---
layout:        post
title:         "SELinuxのポリシーパッケージ (.pp) を CIL に変換して中身を確認する"
date:          2022-01-21
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

SELinuxのポリシーパッケージ (.pp) はバイナリファイルのため、中身を確認することができません。
そこで、.pp を CIL 形式に変換し、人間が解読できる形式にします。

### ポリシーパッケージからCILへの変換
CILへの変換は /usr/libexec/selinux/hll/pp コマンドを使って変換します。
```bash
~]# cat /root/my_tomcat_policy.pp | /usr/libexec/selinux/hll/pp
(typeattributeset cil_gen_require tomcat_t)
(auditallow tomcat_t self (tcp_socket (*)))
(auditallow tomcat_t self (udp_socket (*)))
(auditallow tomcat_t self (rawip_socket (*)))
```

### ポリシーパッケージの作成
上記のポリシーパッケージは以下のコマンドで作成しました。
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

以上です。

### 参考文献
- [SELinuxProject/selinux-notebook: The SELinux Notebook](https://github.com/SELinuxProject/selinux-notebook)
- [SELinux Notebook -- Types of SELinux Policy](https://github.com/SELinuxProject/selinux-notebook/blob/main/src/types_of_policy.md)

