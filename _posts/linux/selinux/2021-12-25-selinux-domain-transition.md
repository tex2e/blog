---
layout:        post
title:         "SELinuxのドメイン遷移の一覧を表示する"
date:          2021-12-25
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

sepolicyコマンドでは、SELinuxのドメイン遷移の一覧を表示することができます。

出力フォーマットは以下の通りです。「@」は「実行する」の意味に置き換えて読みます。
```
source_type @ target_type --> new_type
```
- **source_type** : サブジェクトのタイプ (ドメイン)
- **target_type** : オブジェクトのタイプ
- **new_type** : 生成されたプロセスのタイプ（ドメイン）

各行のルールの末尾に `-- Allowed True [ 条件 ]` がある場合は、対象のブール値のOn/Offによって、ルールが有効化/無効化されることを表します。

以下は sshd_t ドメインが、特定のタイプのファイルを実行したときに、生成されるプロセスのタイプ（ドメイン）のルールの一覧を表示した時の例です。

```bash
~]# sepolicy transition -s sshd_t
sshd_t @ xauth_exec_t --> xauth_t
sshd_t @ oddjob_mkhomedir_exec_t --> oddjob_mkhomedir_t
sshd_t @ updpwd_exec_t --> updpwd_t
sshd_t @ lvm_exec_t --> lvm_t
sshd_t @ chkpwd_exec_t --> chkpwd_t
sshd_t @ mount_exec_t --> mount_t
sshd_t @ passwd_exec_t --> passwd_t
sshd_t @ abrt_helper_exec_t --> abrt_helper_t
sshd_t @ mount_ecryptfs_exec_t --> mount_ecryptfs_t
sshd_t @ fusermount_exec_t --> mount_t
sshd_t @ shell_exec_t --> unconfined_t -- Allowed True [ ssh_sysadm_login=1 || unconfined_login=1 ]
sshd_t @ setfiles_exec_t --> setfiles_t -- Allowed False [ polyinstantiation_enabled=0 ]
sshd_t @ namespace_init_exec_t --> namespace_init_t -- Allowed False [ polyinstantiation_enabled=0 ]
```

以下は httpd_t ドメインが、生成できるプロセスのタイプ（ドメイン）のルールの一覧です。

```bash
~]# sepolicy transition -s httpd_t
...
httpd_t @ httpd_suexec_exec_t --> httpd_suexec_t
httpd_t @ httpd_php_exec_t --> httpd_php_t
...
httpd_t @ sendmail_exec_t --> system_mail_t -- Allowed False [ httpd_can_sendmail=0 ]
httpd_t @ postfix_postdrop_t --> system_mail_t -- Allowed False [ httpd_can_sendmail=0 ]
...
```

以上です。
