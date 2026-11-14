---
layout:        post
title:         "同期元と同期先の両方にrsyncコマンドがないとエラーになる"
type:          Troubleshooting
description:   "rsync実行時にcommand not foundエラーが出る原因はリモート側未導入であり、同期先へのインストールで解決できることを解説。"
tags:          [shell, rsync, linux, troubleshooting]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2023-11-12T01:23:31Z
sources:
  - id:        ref-1
    resource:  https://unix.stackexchange.com/questions/324869/does-rsync-have-to-be-installed-on-the-remote-server
    title:     "Does rsync have to be installed on the remote server? - Unix & Linux Stack Exchange"
date:          2023-11-14
category:      Shell
cover:         /assets/cover14.jpg
redirect_from: /linux/rsync-on-remote-server
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ファイルの同期に使われるrsyncコマンドは、同期元だけでなく同期先のリモートサーバにもrsyncコマンドがインストールされていないと使用できません。

同期先のリモートサーバにrsyncが入っていない時は、ローカルでrsyncを実行した際に「rsync: command not found」や「rsync: コマンドが見つかりません」などのエラーが表示されます。

```console
bash: rsync: コマンドが見つかりません
rsync: connection unexpectedly closed (0 bytes received so far) [sender]
rsync error: error in rsync protocol data stream (code 12) at io.c(601) [sender=3.0.7]
```

対処法は、リモートにもrsyncコマンドをインストールすることで解決します。

以上です。

### 参考文献
- [Does rsync have to be installed on the remote server? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/324869/does-rsync-have-to-be-installed-on-the-remote-server)
