---
layout:        post
title:         "SELinuxのサイレント拒否の無効化/有効化"
date:          2021-11-02
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

SELinux がアクセスを拒否するとき、その拒否ログが audit.log に記録されない場合があります。
SELinuxのアクセス拒否で監査ログが埋まらないようにするためです。
ログが読みやすくなるメリットもありますが、トラブルシューティング時は調査が困難になるデメリットもあります。

### サイレント拒否の無効化

一時的に dontaudit ルールを無効にし、すべての拒否をログに記録できるようにするには、`semodule -DB` コマンドを実行します。

サイレント拒否を無効化 (-D) して、ポリシーを再構築 (-B) するコマンド：
```bash
~]# semodule -DB
```

### サイレント拒否の有効化

逆に、dontaudit ルールを有効にして、重要ではないアクセス拒否のログを記録しないようにするには、`semodule -B` コマンドを実行します。

サイレント拒否を有効化して、ポリシーを再構築 (-B) するコマンド：
```bash
~]# semodule -B
```

以上です。
