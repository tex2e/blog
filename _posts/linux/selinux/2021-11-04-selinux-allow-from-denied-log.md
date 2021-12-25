---
layout:        post
title:         "監査ログからSELinuxアクセス拒否を一括で許可する"
menutitle:     "監査ログからSELinuxアクセス拒否を一括で許可する (audit2allow)"
date:          2021-11-04
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

audit2allow によって、監査ログから許可ルールを作るための提案を見ることができます。
すべての監査ログを読む -a オプションと、人間が読むことができる説明を表示する -w オプションを使います。
```bash
~]# audit2allow -a -w
```
出力結果：
```
type=AVC msg=audit(0000000000.864:348): avc:  denied  { read } for  pid=3183 comm="ls" name="home" dev="dm-0" ino=50710033 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:home_root_t:s0 tclass=dir permissive=0
        Was caused by:
        The boolean httpd_enable_homedirs was set incorrectly.
        Description:
        Allow httpd to enable homedirs

        Allow access by executing:
        # setsebool -P httpd_enable_homedirs 1

...省略...
```
上記の場合は httpd がホームディレクトリにアクセスしたときの拒否ログなので、ブール値「httpd_enable_homedirs」をOnにすれば許可できることが書かれています。
しかし、拒否ログの大体はブール値で許可できるものではないです。

続いて、-w オプションなしで実行すると、拒否されたアクセスを許可する Type Enforcement ルールの一覧が表示されます。
```bash
~]# audit2allow -a
```
出力結果：
```
#============= NetworkManager_t ==============

#!!!! This avc has a dontaudit rule in the current policy
allow NetworkManager_t initrc_t:process { noatsecure rlimitinh siginh };

#============= httpd_t ==============

#!!!! This avc can be allowed using the boolean 'httpd_enable_homedirs'
allow httpd_t home_root_t:dir read;

...省略...
```

内容を確認し、問題がなければ、カスタムポリシーモジュールを作成し（Type Enforcementルール(.te)をポリシーパッケージ(.pp)にコンパイルし）、モジュールをインストールします。
```bash
~]# audit2allow -a -M mycertwatch
~]# semodule -i mycertwatch.pp
```
注意点ですが、audit2allow -a で作成されたモジュールは、必要以上のアクセスを許可する可能性があります。
そのため、特定のプロセスやファイルに関する拒否メッセージだけを audit2allow に送る場合は、以下のように grep で絞り込んでからカスタムポリシーモジュールを作成します。
```bash
~]# grep ptrace /var/log/audit/audit.log | audit2allow -M mycertwatch
~]# semodule -i mycertwatch.pp
```

以上です。
