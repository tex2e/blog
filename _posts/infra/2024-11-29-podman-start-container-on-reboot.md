---
layout:        post
title:         "[Podman] サーバ再起動時にコンテナを自動起動させる方法"
date:          2024-11-29
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

Podmanはデーモンとして起動しないため、systemdと組み合わせることで、サーバ起動時にコンテナが自動起動するようになります。
以下のsystemctlコマンドで、podman-restartサービスを有効化してください。
1行目がRootfulコンテナの自動起動の設定で、2行目がRootlessコンテナの自動起動の設定です（Rootfulが存在しない場合は、必要に応じて2行めだけ実行してください）。

```bash
$ sudo systemctl enable --now podman-restart
$ systemctl --user enable --now podman-restart
```

上記のコマンドで podman-restart.service を有効にしておくと、`--restart=always` で起動したコンテナや、docker-compose.yml で `restart: always` と定義したコンテナは、サーバ起動時に自動で立ち上がってくるようになります。

※注意点として、Docker のときは `restart: unless-stopped` と指定したコンテナも、サーバ再起動時に自動で立ち上がっていましたが、Podman では、unless-stopped のコンテナは自動で立ち上がってこない点に注意ください。

<br>

### （参考） podman-restartサービスの起動内容

Podmanをインストールすると、podman-restart.service が標準で追加できるサービスとして配置されます。

- Rootfulコンテナの自動起動： `/usr/lib/systemd/system/podman-restart.service`
- Rootlessコンテナの自動起動： `/usr/lib/systemd/user/podman-restart.service`

systemdサービス用のユニットファイル podman-restart.service には、デフォルトで以下が記載されています。

```ini
[Unit]
Description=Podman Start All Containers With Restart Policy Set To Always
Documentation=man:podman-start(1)
StartLimitIntervalSec=0
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=true
Environment=LOGGING="--log-level=info"
ExecStart=/usr/bin/podman $LOGGING start --all --filter restart-policy=always
ExecStop=/bin/sh -c '/usr/bin/podman $LOGGING stop $(/usr/bin/podman container ls --filter restart-policy=always -q)'

[Install]
WantedBy=default.target
```

重要な部分は ExecStart のところで、restart-policyが「always」の全てのPodmanコンテナを起動しています。
もし、Dockerのときと同じように「unless-stopped」のコンテナもサーバ起動時に自動起動させたいときは、ExecStartとExecStopのpodmanの引数のfilterを `restart-policy=unless-stopped` に変えた新しいsystemdサービスユニットファイルを新規作成して、サービスを有効化する必要があります。

以上です。
