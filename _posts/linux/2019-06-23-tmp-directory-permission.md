---
layout:        post
title:         "/tmp ディレクトリのパーミッション"
date:          2019-06-23
category:      Linux
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

/tmp というディレクトリは全てのユーザが書き込み可能ですが、権限を777にしてしまうとディレクトリ名を変更されたりディレクトリ自身を削除されてしまう可能性があります。そこで**スティッキービット** (Sticky bit) を使います。スティッキービットがディレクトリに対して設定されていると、ディレクトリ名の変更や削除ができなくなります。

### スティッキービットの設置と削除

chmod によるスティッキービットの設定は以下の通りです（`chmod 1777 tmp` でも設定可）。

```command
chmod +t tmp
```

スティッキービットの設定を削除するには以下の通りです (`chmod 0777 tmp` でも削除可)。

```command
chmod -t tmp
```

### 確認方法

ls -l で確認するとパーミッションのところに、実行ファイルだと「x」と表示されるところにスティッキービットが設定されていると「t」と表示されます。

```command
$ ls -ld /tmp
drwxrwxrwt   4 root     sys          485 Jun 23 06:01 /tmp
```

MacOS の場合は、シンボリックリンクで /tmp -> /private/tmp となっているので、実体の方を ls します。

```command
$ ls -ld /private/tmp
drwxrwxrwt  7 root  wheel  224 Jun 23 16:35 /private/tmp/
```

以上です。
