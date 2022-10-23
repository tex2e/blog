---
layout:        post
title:         "SELinuxで個別追加した設定を別のサーバにも適用する"
menutitle:     "SELinuxで個別追加した設定を別のサーバにも適用する (semanage export/import)"
date:          2021-12-25
category:      SELinux
cover:         /assets/cover6.jpg
redirect_from: /linux/semanage-export
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

SELinuxの個別追加設定した内容は semanage export コマンドで確認することができます。ただし、semodule -i などで追加したカスタムモジュールの情報は見ることができません。
semanage export コマンドを実行すると以下のような出力になります。

```bash
~]# semanage export
boolean -D
login -D
interface -D
user -D
port -D
node -D
fcontext -D
module -D
ibendport -D
ibpkey -D
permissive -D
boolean -m -1 httpd_can_network_relay
boolean -m -1 virt_sandbox_use_all_caps
boolean -m -1 virt_use_nfs
```

設定をファイルに保存する場合は -f オプションを使います。
インポートするときは、設定内容を別のサーバにテキストで保存して -f オプションを使うことで設定を適用できます。

```bash
~]# semanage export -f semanage-mods.txt   # 保存
~]# semanage import -f semanage-mods.txt   # 読み込み
```

以上です。

### 参考文献
- [9.3. Transferring SELinux settings to another system with semanage Red Hat Enterprise Linux 8 \| Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html/using_selinux/transferring-selinux-settings-to-another-system-with-semanage_deploying-the-same-selinux-configuration-on-multiple-systems)

