---
layout:        post
title:         "firewalldコマンド集 (firewall-cmd)"
date:          2021-11-21
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

firewalldでよく使う基本的なコマンド集です。

```bash
# 使用可能なゾーン一覧
firewall-cmd --get-zones
# 現在有効なゾーン一覧
firewall-cmd --get-active-zones
# デフォルトゾーンの設定確認
firewall-cmd --list-all

# 使用可能なサービス名の一覧
firewall-cmd --get-services
# 使用可能なサービス名の詳細確認
cat /usr/lib/firewalld/services/サービス名.xml

# 一時的にhttpのポートを開ける
firewall-cmd --add-service=http
# 一時的にhttpのポートを閉める
firewall-cmd --remove-service=http
# 一時的な設定を恒久的にする
firewall-cmd --runtime-to-permanent
# 恒久的にhttpのポートを開ける
firewall-cmd --add-service=http --permanent
# 恒久的にhttpのポートを閉める
firewall-cmd --remove-service=http --permanent
# firewalldの設定を再読込する
firewall-cmd --reload

# 一時的に指定ポートを開ける
firewall-cmd --add-port=1110/tcp
# 一時的に指定ポートを閉める
firewall-cmd --remove-port=1110/tcp
# 一時的に指定IPからの通信を拒否する
firewall-cmd --add-rich-rule='rule family="ipv4" source address="192.168.0.25" reject'
# 一時的にICMP要求 (PING) の通信を許可する
firewall-cmd --add-icmp-block-inversion
# 一時的にICMP要求 (PING) の通信を拒否する
firewall-cmd --remove-icmp-block-inversion

# 指定IPとのアウトバウンド通信を拒否する
firewall-cmd --direct --add-rule ipv4 filter OUTPUT 0 -d 192.168.1.0 -j DROP

# 再起動
systemctl restart firewalld
```

以上です。
