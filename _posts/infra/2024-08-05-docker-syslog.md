---
layout:        post
title:         "[Docker] docker-composeでログ出力先をsyslogにする"
date:          2024-08-05
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

Docker composeでコンテナのログをsyslogに転送するための設定について説明します。

### syslogの設定

まず、rsyslogの設定に Docker 固有のログ転送設定を追加します。
設定ファイルは /etc/rsyslog.d/docker.conf に作成します。

```bash
$ vi /etc/rsyslog.d/docker.conf
```

syslog のテンプレート (\$template) は、出力先や出力メッセージの形式をカスタマイズできる機能です。
テンプレート形式が文字列1個のときは、それは出力先パスとなります。
そして、if文でファシリティ（ログの種類）が「daemon」、ログ生成元のプログラム名に「docker-」が含まれているとき、そのログをテンプレートで定義した DockerLogs へ転送します。

/etc/rsyslog.d/docker.conf

```conf
$template DockerLogs, "/var/log/docker/docker-%$year%%$month%%$day%-%syslogtag%.log"
if $syslogfacility-text == 'daemon' and $programname contains 'docker-' then {
  -?DockerLogs
}
& stop
```

syslogの設定が終わったら、デーモンを再起動しておきます。

```bash
$ sudo systemctl restart rsyslog
```

### docker-composeの設定

続いて、docker-compose側の設定をしていきます。
任意のディレクトリの中に docker-compose.yml を作成します。

```bash
$ cd rsyslog-test
$ vi docker-compose.yml
```

ここではサンプルとして、2秒ごとにログを出力するコンテナを作成し、そのログ出力を syslog にするという設定を行います。
logging.driver に「syslog」、logging.options にログ出力時のファシリティ名とタグ名をsyslogの設定に合わせて指定します。

docker-compose.yml

{% raw %}

```yaml
services:
    sample:
        build:
            context: sample
            dockerfile: Dockerfile
        logging:
            driver: syslog
            options:
                syslog-facility: daemon
                tag: docker-{{.Name}}
```

{% endraw %}

次に、2秒ごとにログを出力するサンプル用のコンテナを作成します。

```bash
$ mkdir sample
$ vi sample/Dockerfile
```

そして、Dockerfileにはコンテナがログを出力し続けるように、次のコマンドを記載しておきます。

Dockerfile

```dockerfile
FROM alpine

ENTRYPOINT ["/bin/sh", "-c", "while :; do echo 'Hello from Docker Container!'; sleep 2; done"]
```

ここまでできたら、docker-compose からコンテナを起動します。

```bash
$ docker compose up -d
[+] Running 2/2
 ✔ Network syslog-test_default     Created
 ✔ Container syslog-test-sample-1  Started
```

起動すると syslog を経由してログファイルにログが書き込まれることが確認できます。

```bash
$ tail -f /var/log/docker/docker-20240805-docker-syslog-test-sample-1\[1022\]\:.log
Aug  5 13:08:02 dockerserver docker-syslog-test-sample-1[1022]: Hello from Docker Container!
Aug  5 13:08:04 dockerserver docker-syslog-test-sample-1[1022]: Hello from Docker Container!
Aug  5 13:11:14 dockerserver docker-syslog-test-sample-1[1022]: message repeated 95 times: [ Hello from Docker Container!]
```

以上です。

### 参考資料

- [Dockerコンテナ内のログ – 技術ブログ](https://kstoneriver.com/tech/archives/66)
- [rsyslog のメモ - ngyukiの日記](https://ngyuki.hatenablog.com/entry/2016/04/18/220724)
