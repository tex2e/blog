---
layout:        post
title:         "Windowsで作成したZIPファイルをmacOSで解凍する"
type:          How-To
description:   "Windowsで作成したZIPファイルをmacOSで解凍するため、dittoコマンドの-V・-x・-kや--passwordオプションの使い方を解説。"
tags:          [windows, macos, zip, ditto]
status:        stable
stale_after:   2024-03-21T00:00:00Z
generated:
  by:          human:tex2e
  at:          2020-05-12T12:11:33Z
date:          2020-05-12
category:      Windows
cover:         /assets/cover14.jpg
redirect_from: /misc/mac-unzip-windows-file
comments:      true
published:     true
latex:         false
# sitemap: false
# feed:    false
---

Windowsで作成したZIPファイルをmacOSで解凍するには、dittoコマンドを使います。

```cmd
ditto -V -x -k --sequesterRsrc ファイル名.zip .
```

パスワード付きの場合はオプションに `--password` を加えます。

```cmd
ditto -V -x -k --sequesterRsrc --password ファイル名.zip .
```

各オプションの説明：

- `-V` (表示) : display a line of output to stderr for every file, symbolic link, and device copied.
- `-x` (解凍) : Extract the archives given as source arguments. The format is CPIO, unless -k is given. Compressed CPIO is automatically handled.
- `-k` (PKZip) : Create or extract from a PKZip archive instead of the default CPIO. PKZip archives should be stored in filenames ending in .zip.
- `--sequesterRsrc` (メタデータの扱い) : When creating a PKZip archive, preserve resource forks and HFS meta-data in the subdirectory __MACOSX. PKZip extraction will automatically find these resources.
- `--password` (パスワード入力) : When extracting a password-encrypted ZIP archive, you must specify --password to allow ditto to prompt for a password to use to extract the contents of the file. If this option is not provided, and a password-encrypted file is encoun- tered, ditto will emit an error message.
