---
layout:        post
title:         "systemdからinit.dのスクリプトを呼び出すまでの流れ"
type:          Concept
description:   "起動時にsystemd-sysv-generatorが/etc/rc?.d配下のinit.dスクリプトをユニットへ変換しsystemctlから制御可能にする仕組みを解説します。"
tags:          [linux, systemd, initd]
status:        stable
stale_after:   2026-11-12T00:00:00Z
generated:
  by:          human:tex2e
  at:          2023-11-12T01:23:11Z
sources:
  - id:        ref-1
    resource:  https://unix.stackexchange.com/questions/233468/how-does-systemd-use-etc-init-d-scripts
    title:     "How does systemd use /etc/init.d scripts? - Unix & Linux Stack Exchange"
  - id:        ref-2
    resource:  https://www.veritas.com/support/ja_JP/article.100036901
    title:     "systemd を採用した Linux に NetBackup をインストールすると、NetBackup サービスは自動的に起動しません。"
date:          2023-11-13
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

systemctl から /etc/init.d/ にあるサービスを開始・停止できる仕組みについて説明します。

通常では `/etc/init.d/ServiceName status` と `systemctl status ServiceName` は同じようにサービスのステータスを取得することができます。
start や stop なども同様です。
現在は init.d は非推奨で systemd に移行することが求められていますが、それでも systemd から init.d への互換性の仕組みが用意されています。

systemd には systemd-sysv-generator と呼ばれる機能があります。
これはLinux起動直後（ブート直後）に実行されて、/etc/rc?.d/ にあるスクリプトの実ファイル名からsystemd用のユニットファイルに変換し、その変換結果を **/var/run/systemd/generator.late/\*.service** に格納することで、systemctl から /etc/rc?.d のスクリプト（つまり /etc/init.d/* のサービス）を管理・制御できる仕組みになっています。

そのため、/etc/rc?.d/ (例えば /etc/rc3.d など) に配置しただけだと systemctl から呼び出せず、サーバを再起動することで systemctl から使えるようになります。

以上です。

### 参考文献
- [How does systemd use /etc/init.d scripts? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/233468/how-does-systemd-use-etc-init-d-scripts)
- [systemd を採用した Linux に NetBackup をインストールすると、NetBackup サービスは自動的に起動しません。](https://www.veritas.com/support/ja_JP/article.100036901)

