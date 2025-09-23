---
layout:        post
title:         "[Linux] 共有ライブラリの読み込みエラーをLD_LIBRARY_PATHで解決させる"
date:          2025-09-23
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

OpenSSLをソースコードからビルドしたときに共有ライブラリの読み込みが失敗したため、
共有ライブラリの読み込みエラーをLD_LIBRARY_PATHで解決させる方法について説明します。

### 共有ライブラリの読み込みエラー

OpenSSL をソースからインストールした後、実行時に以下のようなエラー「error while loading shared libraries」が発生することがあります。

```console
/opt/openssl-3.5.2/bin/openssl: error while loading shared libraries: libssl.so.3: 
cannot open shared object file: No such file or directory
```

これは、動的ライブラリがシステムの検索パスに存在しないことが原因のエラーです。

通常、システムで利用されるライブラリパスは /etc/ld.so.conf.d/ に定義されており、例えば以下のようになっています。

```bash
~# cat /etc/ld.so.conf.d/libc.conf 
# libc default configuration
/usr/local/lib
```

このライブラリパスに含まれていないと、ldd コマンドで対象コマンドが依存するライブラリの解決状況を確認したときに「not found」と表示されます。
「not found」となっているライブラリは解決できていないことがわかります。
以下の例では、libssl.so.3 と libcrypto.so.3 の解決に失敗しています。

```bash
~# ldd /opt/openssl-3.5.2/bin/openssl
    linux-vdso.so.1 (0x0000ffff90a34000)
    libssl.so.3 => not found
    libcrypto.so.3 => not found
    libdl.so.2 => /lib/aarch64-linux-gnu/libdl.so.2 (0x0000ffff908d3000)
    libpthread.so.0 => /lib/aarch64-linux-gnu/libpthread.so.0 (0x0000ffff908a4000)
    libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000ffff90733000)
    /lib/ld-linux-aarch64.so.1 (0x0000ffff90a00000)
```

OpenSSL をインストールしたディレクトリを確認すると、ライブラリは以下のように存在しています。

```bash
~# ls /opt/openssl-3.5.2/lib/
libcrypto.so.3  libssl.so.3  ...
```

つまり、ライブラリは /opt/openssl-3.5.2/lib/ に配置されていますが、システムのデフォルト検索パスに含まれていないため読み込めません。


### LD_LIBRARY_PATHを利用した解決法

今回は複数のバージョンのOpenSSLを動作させるためにデフォルトのライブラリパスを編集しないようにしたいです。
そこで、環境変数 LD_LIBRARY_PATH に対象ディレクトリを追加することで、ライブラリの読み込みを行えるようになります。
LD_LIBRARY_PATH にライブラリのパスを追加して再度 ldd コマンドを実行すると、「not found」が表示されなくなります。

```bash
~# LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/openssl-3.5.2/lib/ ldd /opt/openssl-3.5.2/bin/openssl
    linux-vdso.so.1 (0x0000ffffa9a00000)
    libssl.so.3 (0x0000ffffa979a000)
    libcrypto.so.3 (0x0000ffffa9000000)
    libdl.so.2 => /lib/aarch64-linux-gnu/libdl.so.2 (0x0000ffffa9786000)
    libpthread.so.0 => /lib/aarch64-linux-gnu/libpthread.so.0 (0x0000ffffa9757000)
    libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000ffffa95e6000)
    /lib/ld-linux-aarch64.so.1 (0x0000ffffa99c0000)
```

この設定を適用した状態で OpenSSL を実行すると、正常に動作するようになります。

```bash
~# LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/openssl-3.5.2/lib/ /opt/openssl-3.5.2/bin/openssl version
OpenSSL 3.5.2 5 Aug 2025 (Library: OpenSSL 3.5.2 5 Aug 2025)
```

以上です。
