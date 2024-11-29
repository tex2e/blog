---
layout:        post
title:         "PodmanとDockerの比較"
date:          2024-11-24
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

PodmanとDockerの機能比較の一覧です。

### Podman/Dockerの両方で有効な機能

- OCIとDockerイメージのサポート [Podman/Docker 両方]
    - コンテナレジストリ (quay.ioやdocker.io) からコンテナイメージをプルして実行する。
- OCIコンテナエンジンの起動
    - runc, crun, Kata, gVisorやOCIコンテナエンジンを利用してコンテナを起動する。
- コマンドラインインターフェース
    - PodmanとDockerで同じCLIを利用できる。
- クライアントサーバモデル
    - Dockerはデーモンが必要。PodmanはsystemdのサービスのソケットアクティベーションでRESTful APIを提供する。
- docker-composeのサポート
    - compose用のスクリプトは、どちらのRESTful APIでも動作する。Podmanではルートレスモードで実行できる。
- docker-pyのサポート
    - どちらのRESTful APIでも動作する。Podmanではルートレスモードで実行でき、podman-pyで高度な機能にも対応している。
- Windowsのサポート
    - PodmanとDockerは、WindowsのWSL2または仮想マシンを利用してコンテナを実行できる
- Linuxのサポート
    - PodmanとDockerは、主要なLinuxディストリビューションを全てサポートしている

### Podmanでのみ有効な機能

- systemdとの統合
    - Podmanはコンテナ内でのsystemdが実行が可能で、多くのsystemdの機能をサポートする。
- fork/execモデル
    - コンテナはPodmanコマンドの直接の子プロセスとして生成される。
- デーモンレス
    - Podmanコマンドは、伝統的なコマンドラインツールのように動作する。
    - Dockerは、複数のroot権限で稼働するデーモンが必要となる。
- ユーザー名前空間の完全なサポート
    - Podmanはコンテナを別々のユーザー名前空間で実行できる。
- レジストリの短縮名展開のカスタマイズ
    - Podmanでは、短縮名で指定したレジストリの展開に関する設定が変更できる。
    - Dockerは、短縮名を展開するときは docker.io が前提となっており、変更ができない。
- デフォルト設定のカスタマイズ
    - Podmanは、セキュリティ、名前空間、ボリュームなど、全ての設定がデフォルト値からカスタマイズできる
- コンテナ無停止でのソフトウェアアップグレード
    - Podmanは、Podmanを一時的に停止させても、実行中のコンテナ起動し続けることができる
    - Dockerは、Dockerデーモンがコンテナを監視しており、デーモンが停止すると全てのコンテナが停止する

### Dockerでのみ有効な機能

- Docker Swarmのサポート
    - Podmanでは、複数ノード環境でのコンテナオーケストレーションの役割は Kubernetes が担う

以上です。

### 参考資料

- [『Podmanイン・アクション』秀和システム, 2023/9](https://amzn.to/3CAPFqb)

