# infra

Parent: [All Categories](../index.md)

## Articles (46)

- [[Azure] Microsoft Azure Administrator (AZ-104) 勉強ノート](./2025-07-28-azure-104-microsoft-azure-administrator.md) (`Book Chapter | stable | stale_after: 2027-06-20`) — Microsoft Azure Administrator (AZ-104)試験の出題範囲やARM、ID管理、ネットワークなどの要点をまとめた勉強ノート。
- [[Docker] drawioコンテナを起動する](./2025-05-03-docker-run-drawio.md) (`How-To | stable | stale_after: 2028-05-03`) — DockerやPodmanコマンドを用いてdraw.ioの公式コンテナをローカルポート18080で起動する手順。
- [[AWS] AWS Certified Solutions Architect - Professional 勉強ノート](./2025-03-14-aws-solution-architect-professional.md) (`Book Chapter | stable | stale_after: 2026-04-13`) — AWS Certified Solutions Architect - Professional (SAP-C02)試験に向けた設計戦略やAWSサービスの勉強ノート。
- [[systemd] SSH接続を止めるとPodmanのルートレスコンテナが停止してしまうときの対処法](./2024-12-17-podman-rootless-user.md) (`Troubleshooting | stable | stale_after: 2027-12-17`) — SSH切断時にPodmanのルートレスコンテナが停止する問題をloginctlのlinger有効化設定で解決する方法。
- [[Podman] サーバ再起動時にコンテナを自動起動させる方法](./2024-11-29-podman-start-container-on-reboot.md) (`How-To | stable | stale_after: 2027-11-30`) — systemdのpodman-restartサービスを有効化してサーバ再起動時にPodmanコンテナを自動起動させる設定方法。
- [nmcliコマンドでLinuxサーバの固定IPの変更をすぐに反映する](./2024-11-27-nmcli-device-connect.md) (`How-To | stable | stale_after: 2027-11-30`) — nmtuiで変更したLinuxサーバの固定IPアドレス設定をnmcli device connectコマンドで即時反映する手順。
- [[Podman] Rocky LinuxにDocker/Podman Composeをインストールする](./2024-11-26-install-podman-compose.md) (`How-To | stable | stale_after: 2027-11-30`) — Rocky Linux環境でpodman composeコマンドを実行するためにpodman-composeやdocker-composeを導入する手順を解説。
- [PodmanとDockerの比較](./2024-11-24-podman-vs-docker.md) (`Reference | stable | stale_after: 2027-11-29`) — OCI互換性やCLI、デーモンレス設計、ルートレス実行、systemd統合、Swarm対応などの観点でPodmanとDockerの機能を比較した一覧。
- [[Kubernetes] リソースの一覧](./2024-11-21-kubernetes-resources.md) (`Concept | stable | stale_after: 2027-11-28`) — C#のOOP設計との対比を交えながら、KubernetesのContainer、Pod、Service、Label、Namespaceの概念と役割を解説。
- [logrotateの設定ファイル](./2024-08-12-logrotate-conf.md) (`Reference | stable | stale_after: 2027-08-13`) — Linuxの/etc/logrotate.confおよび/etc/logrotate.d配下で使うローテーション間隔、世代数、圧縮、スクリプト実行などの設定項目を解説。
- [[rsyslog] ifやテンプレートで使えるプロパティの一覧](./2024-08-10-rsyslog-properties.md) (`Reference | stable | stale_after: 2027-10-13`) — rsyslogのテンプレートや条件式で利用可能なメッセージプロパティ、システムプロパティ、時間関連プロパティの一覧と用途を解説。
- [[rsyslog] アクションにおけるログ出力・保存の指定方法](./2024-08-08-rsyslog-action.md) (`Reference | stable | stale_after: 2027-08-07`) — rsyslogのアクション部でファイル出力や非同期書き込み、動的ファイル名、UDP/TCP転送、破棄、コマンド実行を指定する記法一覧。
- [[rsyslog] 条件に一致するログメッセージを抽出する](./2024-08-07-rsyslog-extract-log.md) (`Reference | stable | stale_after: 2027-08-07`) — rsyslogにおけるファシリティ・シビアリティの組み合わせ記号やホスト・プログラム名指定、プロパティベースフィルタの抽出書式を整理。
- [[rsyslog] rsyslog.conf の構成と書き方](./2024-08-06-rsyslog-config-sections.md) (`Reference | stable | stale_after: 2027-08-06`) — rsyslog.confを構成するグローバル設定、テンプレート、フィルタとアクションによるルールの基本構文と記述例を解説。
- [[Docker] docker-composeでログ出力先をsyslogにする](./2024-08-05-docker-syslog.md) (`How-To | stable | stale_after: 2027-08-06`) — rsyslogのテンプレート・転送ルール設定とdocker-compose.ymlのlogging設定を行い、コンテナログをsyslogへ出力する方法。
- [[Docker] インターネット通信できない環境でDockerをインストールする](./2024-06-02-docker-install-local-network.md) (`How-To | stable | stale_after: 2027-07-21`) — インターネット接続のないRocky Linux環境向けにオンライン環境でDockerのRPMパッケージとイメージを取得しオフライン導入する手順。
- [[Kubernetes] コンポーネントとクラスターのアーキテクチャ図](./2024-05-20-kubernetes-components.md) (`Concept | stable | stale_after: 2027-07-21`) — KubernetesクラスタにおけるControl PlaneとData Planeのアーキテクチャ構成とkube-apiserverやkubeletなど各コンポーネントの役割を解説。
- [[Kubernetes] MacOS (M1) に検証環境をminikubeで作成する](./2024-05-19-kubernetes-install-macos.md) (`How-To | stable | stale_after: 2027-07-21`) — M1 MacOS上にDockerとminikubeでKubernetesのローカル検証環境を構築し、サンプルアプリをデプロイする手順。
- [Webサーバー構成の設計パターン](./2024-04-01-web-server-network-diagram.md) (`Concept | stable | stale_after: 2027-12-29`) — Web・AP・DBサーバの役割と、小規模向け1台構成からマルチテナント対応の2層構造、負荷分散可能な3層構造の設計パターンを解説。
- [[AWS] CLIでバケットを作成する方法](./2023-11-04-aws-s3api-createbucket.md) (`How-To | stable | stale_after: 2025-07-21`) — AWS CLIのs3apiサブコマンドでcreate-bucketを呼び出し、指定リージョンに新しいS3バケットを作成する方法。
- [[AWS] CLIでIAMユーザの多要素認証を無効化する方法](./2023-11-03-aws-iam-deactivate-mfa.md) (`How-To | stable | stale_after: 2025-07-21`) — AWS CLIでIAMユーザに紐づくMFAデバイスのARNを取得し、STS一時認証の有無それぞれで多要素認証を無効化する手順。
- [[AWS] AWS Certified Developer - Associate 勉強ノート](./2023-10-27-aws-developer-notes.md) (`Book Chapter | stable | stale_after: 2026-03-15`) — AWS Certified Developer Associate試験対策としてWell-ArchitectedやEC2などAWS主要サービスの要点をまとめた学習ノート。
- [IAMユーザで請求コンソールが表示されないとき](./2023-07-22-aws-billing-console.md) (`Troubleshooting | stable | stale_after: 2024-07-22`) — AWSのIAMユーザで請求コンソールが表示されない問題に対し、ルートアカウントでのアクセス有効化と請求関連ポリシー付与手順を解説。
- [RTX1000ルータによる2セグメント間の通信](./2023-06-03-router-rtx1000.md) (`How-To | stable | stale_after: 2026-06-04`) — ヤマハRTX1000にMACアドレス由来のIPv6リンクローカルでTelnet接続し、各LANのIPv4設定とNAPTを設定する手順。
- [[Docker] VyOSの検証環境を構築する](./2022-10-29-docker-vyos.md) (`How-To | stable | stale_after: 2027-07-21`) — DockerとOpen vSwitchを使って2セグメント間にVyOSコンテナを配置したネットワーク検証環境を構築し、疎通確認する手順。
- [[AWS] Pythonのboto3でタグ付きEC2だけを停止させる](./2022-10-25-aws-stop-ec2.md) (`How-To | stable | stale_after: 2023-10-24`) — Pythonのboto3とAWS CLI設定を用い、稼働中かつ特定のタグが付与されたEC2インスタンスのみを抽出して自動停止するスクリプト。
- [[Docker] compose exec時のエラー「the input device is not a TTY」の対処法](./2022-10-24-docker-compose-exec-err.md) (`Troubleshooting | stable | stale_after: 2027-07-21`) — Jenkinsやcronなど非対話環境でdocker-compose execを実行した際のTTYエラーに対し、-Tオプションで擬似端末を無効化する対処法。
- [[Docker] compose up時のエラー「Couldn't connect to Docker daemon at http+docker://localhost - is it running?」の対処法](./2022-10-23-docker-compose-up-err.md) (`Troubleshooting | stable | stale_after: 2027-07-21`) — Dockerデーモン稼働中にdocker-compose upが接続エラーになる原因と、実行ユーザをdockerグループへ追加して解消する手順。
- [[AWS] CLIで起動中のEC2インスタンスID一覧を表示＆EC2を起動・停止する](./2022-10-14-aws-ec2-running-instances.md) (`How-To | stable | stale_after: 2025-07-21`) — AWS CLIのec2サブコマンドで起動中EC2インスタンスのID一覧をフィルタ取得し、インスタンスの起動と停止を行う方法。
- [[Ansible] 接続先にpythonが存在しないときの対処法](./2022-08-19-ansible-without-python.md) (`Troubleshooting | stable | stale_after: 2027-07-21`) — Ansible実行先のホストにPythonが存在せずエラーになる場合に、ansible.builtin.rawモジュールで直接シェルコマンドを実行する対処法。
- [[Ansible] replaceモジュールでファイルの内容を編集する](./2022-07-16-ansible-replace.md) (`How-To | stable | stale_after: 2027-07-21`) — Ansibleのansible.builtin.replaceモジュールと正規表現の後方参照を使い、設定ファイル内の文字列を一括置換する方法。
- [[Ansible] lineinfileモジュールでファイルに行を追加する](./2022-07-15-ansible-lineinfile.md) (`How-To | stable | stale_after: 2027-07-21`) — Ansibleのansible.builtin.lineinfileモジュールを使い、正規表現マッチによる行置換や新規行の追加を設定ファイルに行う方法。
- [[Ansible] fdiskを使ってパーティションを設定する](./2022-07-09-ansible-fdisk.md) (`How-To | stable | stale_after: 2027-07-21`) — fdiskを標準入力パイプで非対話実行し、AnsibleのshellモジュールからディスクにLinux LVMパーティションを作成する方法。
- [[Ansible] shellモジュールの結果で条件分岐させる](./2022-07-08-ansible-shell-when.md) (`How-To | stable | stale_after: 2027-07-21`) — Ansibleでshellモジュールの出力をregisterで保存し、changed_whenの抑制とwhenによるタスクの条件分岐を実装する方法。
- [[Ansible] timezoneモジュールでタイムゾーンを設定する](./2022-07-07-ansible-timezone.md) (`How-To | stable | stale_after: 2027-07-21`) — Ansibleのcommunity.general.timezoneモジュールを使って対象サーバのタイムゾーンを指定地域へ変更し確認する手順。
- [[Ansible] rebootモジュールでサーバを再起動する](./2022-07-06-ansible-reboot.md) (`How-To | stable | stale_after: 2027-07-21`) — Ansibleのansible.builtin.rebootモジュールで対象サーバを再起動し、タイムアウト指定や再起動後の後続タスク実行を行う手順。
- [[Ansible] selinuxモジュールで無効化・有効化する](./2022-07-05-ansible-selinux.md) (`How-To | stable | stale_after: 2027-07-21`) — Ansibleのansible.posix.selinuxモジュールを用いてSELinuxの有効化・無効化を設定し、再起動までの挙動を制御する方法。
- [[Ansible] userモジュールでユーザ作成する](./2022-07-04-ansible-user.md) (`How-To | stable | stale_after: 2027-07-21`) — Ansibleのansible.builtin.userモジュールを使い、root権限でLinuxユーザを作成してグループ所属やパスワードを設定する方法。
- [[Ansible] copyモジュールでファイルコピーする](./2022-07-03-ansible-copy.md) (`How-To | stable | stale_after: 2027-07-21`) — Ansibleのansible.builtin.copyモジュールでローカルまたはリモート内のファイルコピーとbackupオプションを使う手順。
- [[Ansible] fileモジュールでfileやdirの権限を設定する](./2022-07-02-ansible-file.md) (`How-To | stable | stale_after: 2027-07-21`) — Ansibleのansible.builtin.fileモジュールを使い、ディレクトリ作成、ファイルへの実行権限付与、シンボリックリンク作成を行う方法。
- [[Ansible] pingモジュールを使う](./2022-07-01-ansible-ping.md) (`How-To | stable | stale_after: 2027-07-21`) — Ansible組み込みのansible.builtin.pingモジュールをPlaybookおよびアドホックコマンドから呼び出して接続確認する方法。
- [[Ansible] SSH公開鍵認証からプレイブック実行までの流れ](./2022-05-04-ansible-tutorial.md) (`How-To | stable | stale_after: 2027-07-21`) — ed25519鍵の生成やSSH公開鍵認証の設定から、Ansibleの疎通確認、コマンド実行、サービスやファイアウォール管理までの基本手順。
- [[Docker] composeインストール後のエラー「error while loading shared libraries: libz.so.1」の対処法](./2021-12-04-docker-compose-err.md) (`Troubleshooting | stable | stale_after: 2027-07-21`) — docker-compose実行時のlibz.so.1読み込みエラーについて、/tmpのnoexecマウント設定をexecに変更して解決する対処法。
- [[Docker] コンテナにマウントしているパスの一覧を表示する](./2021-12-03-docker-inspect-mount.md) (`How-To | stable | stale_after: 2027-07-21`) — 起動中のDockerコンテナにマウントされているホスト側・コンテナ側のディレクトリパスをdocker inspectで確認する方法。
- [DockerやLXDを利用した権限昇格](./2021-05-23-docker-privilege-escalation.md) (`How-To | stable | stale_after: 2025-10-23`) — dockerやlxdグループ権限を持つ非rootユーザが特権コンテナでホストのルートをマウントしroot権限を奪取する手法と対策。
- [ネットワーク構築入門講座の参加メモ](./2019-02-24-nnct-1day-network-construction-beginners-course.md) (`Reference | stable | stale_after: 2027-12-29`) — ネットワーク構築講座で扱ったCisco Catalyst L2/L3スイッチの初期化、VLAN、ルーティング、ACL等の設定コマンドメモ。
