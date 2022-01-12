---
layout:        post
title:         "SELinuxポリシー(Access Vector)の一覧を表示する"
menutitle:     "SELinuxポリシー(Access Vector)の一覧を表示する (sesearch)"
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

sesearchコマンドでは、SELinuxのポリシー(Access Vector)を検索して表示することができます。
なお、sesearch は setools-console パッケージをインストールしないと使えません。

sesearch の出力フォーマットは以下の形式になっています。
```
rule_name source_type target_type : class perm_set;
```
- **rule_name** : ルールの種類。allow, dontaudit, auditallow, neverallow など
- **source_type** : サブジェクトのタイプ (ドメイン)
- **target_type** : オブジェクトのタイプ
- **class** : オブジェクトのクラス
- **perm_set** : アクセスベクタ。複数存在する場合は「{ }」で囲む

また、各行のルールの末尾に `[ ブール値 ]:True` が書かれている場合は、そのブール値が有効になっているときにのみ、当該ルールが有効化されます。
```
rule_name source_type target_type : class perm_set; [ boolean ]:True
```

- **boolean** : SELinuxのブール値。setsebool コマンドでOn/Offを切り替える

以下は httpd_t ドメインで許可されているアクセス（allow と allowxperm のルール）を表示したときの例です。

```bash
~]# yum install setools-console
~]# sesearch -A -s httpd_t
...
allow httpd_t public_content_rw_t:dir { add_name create getattr ioctl link lock open read remove_name rename reparent rmdir search setattr unlink write }; [ httpd_anon_write ]:True
allow httpd_t public_content_rw_t:dir { add_name getattr ioctl lock open read remove_name search write }; [ httpd_anon_write ]:True
allow httpd_t public_content_rw_t:dir { add_name getattr ioctl lock open read remove_name search write }; [ httpd_anon_write ]:True
allow httpd_t public_content_rw_t:dir { add_name getattr ioctl lock open read remove_name search write }; [ httpd_anon_write ]:True
allow httpd_t public_content_rw_t:dir { getattr ioctl lock open read search };
allow httpd_t public_content_rw_t:file { append create getattr ioctl link lock open read rename setattr unlink write }; [ httpd_anon_write ]:True
allow httpd_t public_content_rw_t:file { getattr ioctl lock map open read };
allow httpd_t public_content_rw_t:lnk_file { append create getattr ioctl link lock read rename setattr unlink write }; [ httpd_anon_write ]:True
allow httpd_t public_content_rw_t:lnk_file { getattr read };
allow httpd_t public_content_t:dir { getattr ioctl lock open read search };
allow httpd_t public_content_t:file { getattr ioctl lock map open read };
allow httpd_t public_content_t:lnk_file { getattr read };
...
```
以上です。
