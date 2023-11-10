---
layout:        book
title:         "AWS Developer Associate 勉強ノート"
date:          2023-10-27
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
latex:         false
photoswipe:    false
sitemap: false
feed:    false
---

AWS Certified Developer Associate 認定試験を勉強した時の自分用のまとめです。 あくまで備忘録程度で、内容の正確性は保証しませんのでご了承ください。

## 第1章 AWSサービス全体の概要

### AWS Well-Architected

- **AWS Well-Architected** : 信頼性が高く、安全で、効率的で、費用対効果が高く、持続可能なシステムを設計して運用するためのアーキテクチャに関するベストプラクティス
- 用語の定義
  - **コンポーネント**：コード、設定、AWS リソース
  - **ワークロード**：ビジネス価値を提供する一連のコンポーネント
    - ワークロードを設計するときには、ビジネスの状況に応じて各柱の間でトレードオフを行う
    - 例）開発環境では、信頼性を犠牲にして持続可能性への影響を改善してコストを削減する
    - 例）本番環境では、コストを増加させて信頼性を最適化する
    - セキュリティと運用性が他の柱とトレードオフされることはない
  - **アーキテクチャ**：コンポーネントがワークロードで連携するための方法。アーキテクチャ図で表現される
  - **マイルストーン** : アーキテクチャのライフサイクル（設計、実装、テスト、稼働、本番）の中で重要な変更を記録するためのもの
  - **テクノロジーポートフォリオ** : ビジネスの運営に必要なワークロードの集合体
  - 工数レベル : タスクの実行に必要な時間、労力、複雑さの度合いを分類したもの
    - 高（数週間～数か月）
    - 中（数日または数週間）
    - 低（数時間または数日）

### 一般的な設計原則

- **AWS Well-Architected フレームワーク** : クラウド上における適切な設計を可能にする一般的な設計の原則
  - キャパシティニーズの推測が不要 : 自動的にスケールアップまたはスケールダウンできる
  - 本稼働スケールでテストできる : 本稼働スケールのテスト環境をオンデマンドで作成し、テスト完了後にリソースを解放できる
  - 自動化でアーキテクチャ実験を容易にする : 自動化により、低コストでワークロードを作成およびレプリケートすると、手作業でかかるコストを減らせる
  - 発展するアーキテクチャが可能 : 自動化し、オンデマンドでテストできるため、システムを時間とともに進化させることができる
  - データに基づいてアーキテクチャを駆動 : ログからワークロード改善の意思決定ができる
  - ゲームデーを利用して改善する : 本番環境のイベントをシミュレートすることで、アーキテクチャとプロセスのパフォーマンスをテストできる

### フレームワークの柱

- AWS Well-Architected の6つの柱 :
  - 優れた運用効率 : 開発をサポートし、ワークロードを効率的に実行し、運用に関するインサイトを得て、ビジネス価値をもたらすためのサポートプロセスと手順を継続的に改善する能力
    - 運用をコードとして実行する
    - 小規模かつ可逆的な変更を頻繁に行う
    - 運用手順を頻繁に改善する
    - 障害を予想する
    - 運用上の障害すべてから学ぶ
  - セキュリティ : データ、システム、資産を保護して、クラウドテクノロジーを活用してセキュリティを強化する能力
    - 強力なアイデンティティ基盤を実装する
    - トレーサビリティの実現
    - 全レイヤーでセキュリティを適用する
    - セキュリティのベストプラクティスを自動化する
    - 伝送中および保管中のデータを保護する
    - データを手作業で作成・修正しない
    - セキュリティイベントに備える
  - 信頼性 : 意図した機能を期待どおりに正しく一貫して実行するワークロードの能力
    - 障害から自動的に復旧する
    - 復旧手順をテストする
    - 水平方向にスケールしてワークロード全体の可用性を高める
    - キャパシティーを推測することをやめる
    - オートメーションで変更を管理する
  - パフォーマンス効率 : システムの要件を満たすためにコンピューティングリソースを効率的に使用し、要求の変化とテクノロジーの進化に対してその効率性を維持する能力
    - 最新テクノロジーを誰もが利用できるようにする
    - わずか数分でグローバル展開する
    - サーバーレスアーキテクチャを使用する
    - より頻繁に実験する
    - メカニカルシンパシーを重視する（クラウドサービスの使用方法を理解して最適なアプローチを採用する）
  - コストの最適化 : 最低価格でビジネス価値を実現するシステムを実行できる能力
    - クラウド財務管理を実装する
    - 消費モデルを導入する
    - 全体的な効率を測定する
    - 差別化につながらない高負荷の作業に費用をかけるのをやめる
    - 費用を分析し帰属関係を明らかにする
  - 持続可能性 : 環境に対する影響（特にエネルギーの消費と効率性）
    - 影響を理解する
    - 持続可能性の目標を設定する
    - 使用率を最大化する
    - より効率的なハードウェアやソフトウェアの新製品を予測して採用する
    - マネージドサービスを使用する
      - 例）ワークロードを AWS クラウド に移行し、サーバーレスコンテナに AWS Fargate などのマネージドサービスを採用する
      - 例）Simple Storage Service (Amazon S3) ライフサイクル設定を使用して、あまり頻繁にアクセスされていないデータを自動的にコールドストレージに移動する
      - 例）Amazon EC2 Auto Scaling を使用して容量を需要に合わせる
    - クラウドワークロードのダウンストリームの影響を軽減する

### AWSグローバルインフラストラクチャ

- **リージョン** : AWS がデータセンターをホストする世界中の地理的場所
  - リージョンコードの例 :
    - us-east-1 : 地理的名称はバージニア北部
    - ap-northeast-1 : 地理的名称は東京
  - 適切なAWSリージョンの選択 :
    - レイテンシー（データのリクエストとレスポンス間の遅延）
    - 料金
    - サービスの可用性
    - データコンプライアンス
- **アベイラビリティーゾーン (AZ)** :
  - すべてのリージョンには、AZのクラスタが存在する
  - AZは、冗長電源、ネットワーク、接続性を備えた1つ以上のデータセンターで構成される
  - AZコードの例
    - us-east-1a : us-east-1 (バージニア北部地域) の AZ
    - sa-east-1b : sa-east-1 (サンパウロ地域) の AZ
  - 少なくとも2つのAZを使用することで、可用性を維持できる

### AWSの操作

- **AWSマネジメントコンソール**
  - Webからログインし、目的のサービスを選択してGUIで操作する
- **AWS CLI** (AWSコマンドラインインターフェイス)
  - コマンドラインから複数の AWS サービスを制御し、スクリプトで自動化するためのツール
  - AWS CLI はオープンソースで、Windows、Linux、MacOS でインストールできる
  - AWS CLI でAPIコールした実行結果（レスポンス）はJSON形式となる
      ```json
      $ aws ec2 describe-Instances
      {
      "Reservations": [
      {
        "Groups": [],
        "Instances": [
          {
            "AmiLaunchIndex": 0,
            ...
      ```
- **AWS SDK**
  - AWSへのAPIコールをプログラミング言語でも実行できるソフトウェア開発キット（SDK）
  - AWS SDK はオープンソースで、C++、Go、Java、JavaScript、.NET、Node.js、PHP、Python、Ruby などで使用可
  - 以下はAWS SDK for Pythonによる例
      ```python
      import boto3
      ec2 = boto3.client('ec2')
      response = ec2.describe_instances()
      print(response)
      ```

### 責任共有モデル

- AWSの責任 :
  - AWS リージョン、アベイラビリティーゾーン (AZ)、データセンターの保護と保証、建物の物理的なセキュリティ
  - 物理的サーバー、ホストオペレーティングシステム、仮想化レイヤー、AWS ネットワークコンポーネントなどの AWS サービスを実行するハードウェア、ソフトウェア、ネットワークコンポーネントの管理
- AWS利用者の責任 :
  - データを完全に管理し、コンテンツに関連するセキュリティを管理する責任
  - 例：
    - データ主権規制に従って AWS リソースのリージョンを選択する
    - 暗号化やスケジュールバックアップなどのデータ保護メカニズムの実装
    - アクセスコントロールを使用して、データと AWS リソースにアクセスできるユーザーを制限する

### AWS EC2 (Elastic Compute Cloud)

- **EC2**は、規模の変更が可能なコンピューティング性能をクラウド内で安全に利用できるサービス
  - AWSがホストマシンとハイパーバイザーレイヤーを運用・管理している
  - EC2インスタンスと呼ばれる仮想サーバーをプロビジョニングできる
  - EC2インスタンス起動に以下の定義が必要 :
    - CPU、メモリ、ネットワーク、ストレージなどのハードウェア仕様
    - ネットワークの場所、ファイアウォールのルール、認証などの論理構成や、選択したオペレーティングシステム
    - AMI (Amazon マシンイメージ) の選択
  - インスタンス起動時に独自処理を実行する場合 :
    - ユーザデータ : EC2起動時にスクリプト実行を行う機能。シェルスクリプト or cloud-init の2種類ある
    - 起動テンプレート (Launch Template) : インスタンス起動の一連の設定をテンプレート化して実行する機能
  - プレイスメントグループの戦略（配置戦略）
    - **Cluster** : 単一のAZにEC2インスタンスを配置する
    - **Spread** : EC2インスタンスを別々のハードウェアに分散して配置する。AZをまたいだ配置もできる
    - **Partition** : 同一のハードウェアを共有しない論理的なパーティションに分割して配置される
  - AWSリソースへアクセスするときの認証情報 :
    - PCからアクセスする場合、
      - EC2のホームディレクトリ直下の ~/.aws/credential に認証情報を設定する
      - または、環境変数で認証情報を渡す
    - EC2からアクセスする場合、EC2に必要な権限（ポリシー）を設定したIAMロールを作成して、EC2起動時に割り当てる
  - EC2へのSSH接続
    - EC2を使用してキーペア（秘密鍵と公開鍵のペア）を作成し、SSH公開鍵認証で秘密鍵を指定してSSHログインする
  - Amazon EC2 インスタンスタイプ
    - 仮想プロセッサ (vCPU) 、メモリ、ネットワーク、GPUなどの組み合わせを選択する
    - 例えば「c5.large」は、インスタンスファミリー「c」の第5世代で、「large」はインスタンスの容量を表す
  - インスタンスファミリーの種類 :
    - 汎用
    - コンピューティング最適化
    - メモリ最適化
    - 高速コンピューティング
    - ストレージ最適化
  - EC2インスタンスの配置
    - デフォルトでは、EC2インスタンスはデフォルトのVPCネットワークに配置される
    - デフォルトVPC内に配置したリソースは、インターネットで公開され、アクセス可能になるため、顧客データや個人情報を保管してはいけない
  - 高可用性
    - 2つの異なるアベイラビリティーゾーンで少なくとも2つのEC2インスタンスを使用すること
  - インスタンスのライフサイクル
    1. インスタンスを起動すると、インスタンスは保留状態に移行する
    2. インスタンスが実行されると使用可能状態になる
    3. インスタンスを再起動すると、インスタンスは同じホストコンピュータに残り、そのパブリックとプライベートIPアドレス、およびその他のデータはインスタンスストアに維持される
    4. インスタンスを停止すると、インスタンスは新しいパブリックIPアドレスを取得する。ただし、プライベートIPアドレスを同じ値を保持する
    5. インスタンスを終了すると、インスタンスストアは消去され、マシンのパブリック IP アドレスとプライベート IP アドレスの両方が失われる
  - 停止と休止について
    - **停止**が実行されると、EC2使用料やデータ転送に課金されない。Amazon EBS ボリュームのストレージは引き続き課金される
    - **休止**が実行されると、AWS はオペレーティングシステムに休止状態 (ディスクへのサスペンド) を実行するように通知する
    - インスタンスを停止した後も、インスタンスの使用料やデータ転送料金は課金されることはない。しかし、Amazon EBS ボリュームのストレージは引き続き課金される。
    - インスタンスが停止状態にある間、インスタンスタイプなどの一部の属性を変更できる
    - インスタンスを停止すると、メモリ (RAM) に保管されているデータは失われる
  - 料金
    - **オンデマンド** :
      - インスタンスが実行されている時に課金され、インスタンスが停止状態または終了状態になると課金が停止する。
    - **リザーブドインスタンス** :
      - サーバーを停止できない場合、コストを節約するために使用する。
      - 1年間または3年間の期間を選択する
      - 全額前払い、一部前払い、前払いなしの3種類の支払いから選択する
    - **スポットインスタンス** :
      - AWSクラウド内の使用されていないEC2キャパシティーを活用する
      - オンデマンド料金と比較して最大90%の割引
      - 考慮事項は、スポットインスタンスが中断される可能性があること
      - AWSの判断でインスタンスが停止される。その際は中断する2分前にAWS側から警告が出される
      - 耐故障性のあるワークロードを設計する必要がある
- **AMI** (Amazonマシンイメージ) 
  - AMIをクラスと見なすと、EC2はクラスをインスタンス化したものと見なすことができる
    - 新しいインスタンスを起動すると、AWSはハイパーバイザーで実行する仮想マシンを割り当てる
    - 次に、選択した AMI がルートデバイスボリュームにコピーされる
  - AMIの利点
    - 再利用することが可能
    - 実行中のインスタンスからAMIを作成することも可能
  - AMIの検索
    - クイックスタート AMI（AWSが作成したAMI）
    - AWS Marketplace AMI（サードパーティーの商用AMI）
    - My AMI（EC2インスタンスから作成したAMI）
    - コミュニティAMI（AWSユーザーコミュニティの作成したAMI）
    - カスタムイメージ（EC2 Image Builderを使用した独自のAMI）
  - AMI ID : 先頭に「ami-」が付き、その後に数字と文字のランダムなハッシュ値が続く

### Amazon VPC (Virtual Private Cloud)

- **VPC** (仮想プライベートクラウド) とは、データセンターの従来のネットワークと同様に、AWS クラウドで作成する分離されたネットワーク
  - VPCを作成するときに必要な要素
    - VPCの名前
    - VPCのリージョン
    - CIDR表記法のVPCのIP範囲
      - 各VPCには、最大4つの /16 IP範囲を設定できる
  - サブネットの作成
    - サブネットを配置するVPC。例：VPC (10.0.0.0/16)
    - サブネットを配置するアベイラビリティーゾーン。例：AZ1
    - VPC CIDR ブロックのサブセットであるサブネットの CIDR ブロック。例：10.0.0.0/24
  - EC2 インスタンスを起動すると、選択したアベイラビリティーゾーン内に配置されるサブネット内で起動する
  - VPC での高可用性
    - 冗長性と耐障害性を維持するには、2 つのアベイラビリティーゾーンで構成されたサブネットを少なくとも2つ作成する
  - 予約済みIP
    - VPC (10.0.0.0/22) の場合、合計1024のIPアドレスが含まれている。
    - これを4つの等しいサイズのサブネットに分けると、それぞれに256のIPアドレスを持つ /24 IP 範囲になる
    - これらのサブネット範囲の中で以下の5つのIPがAWSによって予約済み
      - 10.0.0.0 : ネットワークアドレス
      - 10.0.0.1 : VPCローカルルータ
      - 10.0.0.2 : AWSが提供するDNSサーバ（Route53 Resolver）
      - 10.0.0.3 : 将来の利用のために予約済み
      - 10.0.3.255 : ブロードキャストアドレス
  - VPCの外部通信の種類 :
    - インターネットゲートウェイ (Internet GW) : VPCとインターネットの通信するため
    - NATゲートウェイ (NAT Gateway) : VPN内でプライベートサブネットからパブリックサブネットへ通信するため
    - 仮想プライベートゲートウェイ (VPN GW) : VPCとオンプレ環境を接続するため
    - カスタマーゲートウェイ (Customer GW) : VPCとオンプレ環境を接続するときにオンプレ側に配置するゲートウェイ。BGPでルーティングする
    - VPCピアリング接続 (VPC Peering) : 独立した2つのVPCを接続し、プライベートアドレスを使って相互に通信するため
    - **VPCエンドポイント** (VPC Endpoint) : VPCのプライベートサブネットからインターネットを経由しないでAWSサービスに直接アクセスするための機能（URLでアクセス可能）
    - トランジットゲートウェイ (Transit Gateway) : 上記の様々なVPC間の接続を統合したネットワーク管理サービス
  - VPCルーティング
    - ルートテーブル : VPC内の通信で指定されたCIDR表記 (X.X.X.X/N) のアドレスで通信をルーティングするルールセット
    - ルートテーブルには2種類ある
      - **メインルートテーブル** :
        - VPCを作成すると、AWSはメインルートテーブルと呼ばれるルートテーブルが作成される
        - ルートテーブルには、ルートと呼ばれるルールセットが保管され、ルートによって、ネットワークトラフィックの送信先が決まる
      - **カスタムルートテーブル** :
        - ユーザが編集できるルートテーブル
        - カスタムルートテーブルをサブネットに関連付けると、サブネットはメインルートテーブルの代わりにカスタムルートテーブルを使用してルーティングを行う
  - VPCのセキュリティ
    - ネットワークアクセスコントロールリスト (ネットワークACL)
      - ネットワークアクセスコントロールリストは、サブネットレベルのファイアウォール
      - ネットワークACLは、VPCのサブネットに関連付けする
      - インバウンドとアウトバウンドの送信先とポートを許可・拒否する
      - ネットワーク上のファイアウォールと同様で、ステートフルな制御はできない
    - セキュリティグループ
      - セキュリティグループと呼ばれるファイアウォールを作成して、EC2に関連付けする
      - ファイアウォールの機能としてはLinuxのiptablesと同様で、ステートフルな制御を行う
  - **VPCフローログ** : VPCのネットワークインターフェイスとの間で行き来するIPトラフィックに関する情報をキャプチャできるようにする機能
    - CloudWatch LogsやS3に出力できる

### ストレージタイプ

- AWSストレージサービスの種類 :
  - **ファイルストレージ** :
    - ファイルストレージは、複数のホストコンピュータで簡単に共有および管理することができる
    - WindowsのファイルエクスプローラーやMacOSのFinderなどのファイルストレージシステムなど
  - **ブロックストレージ** : EBSなど
    - ブロックストレージはファイルを独自のアドレスを持つブロックと呼ばれる固定サイズのデータのチャンクに分割する
    - ファイル内の1文字だけを変更するときなどに、効率良く変更できる
  - **オブジェクトストレージ** : S3など
    - オブジェクトは、ファイルと同様に、保存時に単一のデータ単位として扱われる。
    - ただし、ファイルストレージとは異なり、これらのオブジェクトは層ではなくフラット構造に保管される。

### Amazon EBS (Elastic Block Store)

- **EBS**とは、Amazon EC2インスタンスに接続できるブロックレベルのストレージデバイス
  - EBSボリュームは、外部ドライブと同様に動作する
  - Amazon EC2インスタンスストア :
    - Amazon EC2インスタンスストアは、インスタンス用にブロックレベルの一時的なストレージを提供する
    - このストレージは、ホストコンピュータに物理的に接続されたディスクに配置される
  - Amazon EBSボリュームの使用範囲 :
    - 使用できるストレージの最大容量は 16 TB
    - EC2には複数のEBSボリュームを紐づけることができる
  - Amazon EBSユースケース :
    - オペレーティングシステム : AMIから起動されるインスタンスのルートデバイス
    - データベース
    - アプリケーション
  - Amazon EBSのボリュームタイプ
    - **プロビジョンド IOPS SSD** (io2)
      - 利用料金 : 最も高額
      - レイテンシーの影響を受けやすいトランザクションワークロード向けに設計された最高パフォーマンスの SSD
      - ユースケース : I/O負荷の高いデータベース
      - ボリュームサイズ : 4GB～16TB
      - 最大IOPS : 64000
      - 最大スループット : 1000 MB/秒
    - **汎用SSD** (gp2)
      - 利用料金 : 高額
      - さまざまなトランザクションワークロードに適した、料金とパフォーマンスのバランスが取れている汎用 SSD
      - ユースケース : ブートボリューム、インタラクティブで低レイテンシーのアプリケーション、開発およびテスト環境
      - ボリュームサイズ : 1GB～16TB
      - 最大IOPS : 16000
      - 最大スループット : 250 MB/秒
    - **スループット最適化HDD** (st1)
      - 利用料金 : 低額
      - アクセス頻度が高く、高いスループットが必要なワークロード向けに設計された低コストHDD
      - ユースケース : ビッグデータ、データウェアハウス、ログ処理
      - ボリュームサイズ：500GB～16TB
      - 最大IOPS : 500
      - 最大スループット : 500 MB/秒
    - **コールドHDD** (sc1)
      - 利用料金 : 最も低額
      - アクセス頻度の低いワークロード向けに設計された最も低コストのHDD
      - ユースケース : 1日のスキャン必要回数が少ないコールドデータ。ログデータやアーカイブなど
      - ボリュームサイズ : 500GB～16TB
      - 最大IOPS : 250
      - 最大スループット : 250 MB/秒
  - Amazon EBSの利点 :
    - 高可用性 : ボリュームはアベイラビリティーゾーンに自動的に複製される
    - データの永続性
    - データ暗号化
    - 柔軟性 : インスタンスを停止することなくタイプの変更が可能
    - バックアップ
  - Amazon EBS スナップショット
    - EBS スナップショットは、直近のスナップショットの後に変更されたボリューム上のブロックのみを保存する増分バックアップ
    - 保存先は Amazon S3

### Amazon EFS (Amazon Elastic File System)

- **EFS**とは、LinuxワークロードにNFSで共有するファイルシステムストレージを提供するフルマネージドサービス
  - フルマネージド
  - 高可用性および高耐久性
  - 伸縮自在でスケーラブル（ストレージ容量の拡張・収縮が自動で行われる）
  - ストレージクラスとライフサイクル管理
  - スループットモード : 高いスループットを実現するために、伸縮自在なスループットとプロビジョンドスループットの2つのオプションを提供している
  - データ保護
    - Amazon EFS Replication : ファイルシステムのデータを他のAWSリージョンや同じリージョン内にレプリケートする
    - AWS Backup
    - 暗号化

### 適切なストレージサービスの選択

- Amazon EC2インスタンスストア
  - インスタンスストアは一時的なブロックストレージ
  - EC2インスタンスをホストする同じ物理サーバー上に存在し、Amazon EC2からデタッチできない事前設定されたストレージ
- Amazon EBS
  - インスタンスの停止、終了、またはハードウェア障害によって永続化する必要があり、頻繁に変更されるデータを扱う
  - SSDバックアップボリューム
  - HDDバックアップボリューム
- Amazon S3
  - データを頻繁に変更しない場合、Amazon S3は費用対効果が高い
- Amazon Elastic File System (Amazon EFS) と Amazon FSx
  - 複数のEC2インスタンスにマウントできるファイルストレージ
    - Amazon Elastic File System (Amazon EFS) : フルマネージド型NFSファイルシステム
    - Windowsファイルサーバー専用のAmazon FSx : SMBプロトコルをサポートするWindowsサーバー上に構築されたフルマネージド型ファイルサーバー
    - Lustre専用Amazon FSx : S3と統合する完全マネージド型のLustreファイルシステム

### ソリューションの最適化

- 可用性 :
  - 90% : 年間36.53日間のダウンタイム
  - 99% : 年間3.65日間のダウンタイム
  - 99.9% : 年間8.77時間のダウンタイム
  - 99.99% : 年間52.60分間のダウンタイム
  - 99.999% : 年間5.26分間のダウンタイム
- アプリケーションの可用性の向上
  - Second Availability Zone
  - レプリケーション
    - 複数の EC2 インスタンスを立てる
    - 課題は、インスタンス間で設定ファイル、ソフトウェアパッチ、アプリケーションを複製するプロセスを作成する必要があること
  - リダイレクト
    - DNSを使用してクライアントに異なるサーバを知らせること
    - 各サーバー間で負荷を分散するロードバランサーを使用すること
  - 高可用性の種類 :
    - アクティブ／パッシブ
    - アクティブ／アクティブ


## 第2章 展開（デプロイ）関連サービス

### AWS CodeCommit

- **CodeCommit**とは、完全マネージド型のGitレポジトリ
  - 連携可能サービス :
    - CloudFormation : テンプレートを記述してCodeCommitレポジトリを迅速に作成できる
    - CloudTrail : CodeCommitで実行されたAPIコールやGitコマンドを記録し、ログをS3に保存する
    - CloudWatch Event : リポジトリを監視し、リポジトリ変更のイベントが発生すると、SQSやKinesis、Lambdaなどで処理を実行する
    - CodeGuru Reviewer : 機械学習を利用したソースコードの分析とコードレビュー
    - AWS KMS : リポジトリの暗号化
    - AWS Lambda : イベントをトリガーとしてLambda関数を実行する
    - Amazon SNS : イベントをトリガーとしてメールを通知する
  - IAMベースのアクセス制御
    - IAMユーザにCodeCommitへのアクセス権限を付与できる
    - IAMポリシーでユーザ・リポジトリ・ブランチ単位で操作できるGitコマンドを制御できる
    - SSH接続できないときは、IAMユーザでGit認証情報を払い出して開発端末のツールに設定する
    - SSH接続できるときは、公開鍵認証でCodeCommitに接続する
  - CodeCommitへの接続方法 :
    - HTTPS接続によるGit認証情報の設定
    - SSHを使ったアクセス設定
    - git-remote-codecommitツールをインストールし、AWS CLIを使ってプロファイルやロールのARNをセットアップする
      - AWS SDKを使ってCodeCommitクライアントをインスタンス化し、メソッドを呼び出すことでコミットを作成することもできる

### AWS CodeBuild

- **CodeBuild**とは、ソースコードのビルドや静的チェック、コンパイル、ユニットテストなどを実行するサービス
  - 任意のカスタムコンテナイメージを利用してビルドすることができる
  - 任意の時間にビルドを走らせるトリガーもサポートされている
  - 連携可能サービス :
    - CodeCommitやCodepipeline : ビルドプロジェクトとしての連携
    - CloudWatch Logs : ログ出力できる
    - S3 : ビルドしたリリース媒体（アーティファクト）をS3に出力できる
    - Systems Manager Parameter StoreやSecrets Manager : 機密データを環境変数経由で取得できる
  - buildspec.ymlの記述方法
    - サンプル
      ```yml
      version: 0.2
      env:
        parameter-store:
          DOCKER_PASSWORD: "DOCKER_PASSWORD"
      phases:
        install:
          runtime-versions:
            docker: 18
        build:
          commands:
            - echo ビルドコマンド
      artifacts:
        files:
          - output.json
      ```
    - 構成要素
      - version : buildspecのバージョン
      - env : 環境変数の定義
        - variables : 環境変数を指定する
        - parameter-store : System Manager Parameter Storeに保存されている環境変数を取得する
      - phase
        - install : ビルドに必要なパッケージのインストール
        - pre_build : ビルド実行前の処理（リポジトリへのログインなど）
        - build : ビルド処理
        - post_build : ビルド実行後の処理（アップロードなど）
        - run-as : コマンドを実行するLinuxユーザ
        - on-failure : フェーズ中にコマンド実行エラーが発生したときの挙動をABORTまたはCONTINUEで指定
        - runtime-versions : 各プログラミング言語やツールのバージョンを指定
        - commands : ビルドで実行するコマンドを指定。複数指定すると上から順に実行する
        - finally : コマンドの正常終了・異常終了に関係なく最後に必ず実行するコマンドを指定
      - artifacts
        - files : ビルド出力アーティファクトのファイル名を指定する。複数指定することが可能
    - プロジェクト作成時にbuildspec.ymlのパスを定義できるため、ルートディレクトリ直下に必ず配置する必要はない
      - 用途に応じて複数のbuildspec.ymlを配置することも可能
    - buildspec.ymlではプロジェクトを同時に実行できるバッチビルドのオプションがある
  - **CodeBuild Local** : buildspec.ymlの挙動をローカル端末で確認できるツール
    - ビルド環境のコンテナイメージとCodeBuildエージェントが含まれるコンテナイメージの2種類を用意する
    - 動かすためにはDockerとBashスクリプトが実行できる環境を用意する必要あり。また、CodeBuildエージェントが含まれているDockerコンテナが必要
  - CodeBuildがSystems Manager Parameter Storeに保存されている環境変数を取得するとき、CodeBuildに設定するサービスロールに「ssm:GetParameters」アクションの権限を追加する必要がある
    - 値を参照する時は常に最新のバージョンが指定される
  - 出力がDockerコンテナの場合、Privilegedモードを選択する必要がある
  - 設定することで、任意の時刻にビルドジョブなどのイベントを実行できる
  - ビルド処理の環境
    - Amazon Linux2やUbuntu、任意のカスタムコンテナイメージが利用できる
    - ビルド処理を実行するコンテナのスペックでメモリは変更できない

### AWS CodePipeline

- **CodePipeline**とは、Codeシリーズのサービスを統合して継続的デリバリーを実現するサービス
  - CodePipelineがサポートするプロバイダ
    - Source : ソースコード・コンテナイメージを格納しているリポジトリを指定
      - AWS CodeCommit, AWS ECR (コンテナイメージ), AWS S3, GitHub, BitBucketなど
    - Build : ビルド処理を実行するためのツール・サービスを指定
      - AWS CodeBuild, Jenkinsなど
    - Test : テストを実行するためのツール・サービスを指定
      - AWS CodeBuild, AWS Device Farm, Jenkinsなど
    - Deploy : デプロイ先を指定
      - AWS S3, AWS CloudFormation, AWS CodeDeploy, Amazon ECS (コンテナサービス) など
    - Approval : デプロイの承認
      - Amazon SNSでメール通知が可能
    - Invoke : カスタム実行アクション
      - AWS Lambda, AWS Step Functions
  - DeployでECSを選択する場合、実行中のコンテナをBlue/Greenでアップデートできる
  - DeployでECSを選択する場合、サービスのコンテナ名とイメージとタグを記述したJSONファイル「imagedefinitions.json」が必要になる
  - SourceステージでGitHubを選択した場合、OAuth2.0のWebIDフェデレーションを利用してGitHubへアクセスする
  - Sourceステージについて、リポジトリやブラウザに対してWebHookを設定し、イベントが発生した時にビルドを実行することができる
    - WebHookの代わりに定期的にポーリングするオプションも選択できる（例：GitHubのWebHookは選択できない）

### AWS CodeDeploy

- **CodeDeploy**とは、アプリケーションをデプロイするためのサービス
  - CodeDeployは「デプロイグループ」というグループ単位でデプロイ先のノードを扱う
    - デプロイグループは特定のタグを指定したEC2インスタンスまたはAutoScalingグループ
  - EC2にインストールしたCodeDeployエージェントが、CodeDeployサービスへポーリングすることで自動デプロイを実現している
  - デプロイグループには、デプロイする条件を定義した「デプロイ設定」を割り当てる
    - EC2のとき :
      - CodeDeployDefault.OneAtTime（一度に1つのインスタンスにのみデプロイ）
      - CodeDeployDefault.HalfAtTime（一度に全体の半分のインスタンスにデプロイ）
      - CodeDeployDefault.AllAtOne（一度に全てのインスタンスにデプロイ）
    - ECSのとき :
      - CodeDeployDefault.ECSLinear10PercentEvery1Minutes（1分ごとにトラフィックの10%を新ECSコンテナへ移行する）
      - CodeDeployDefault.ECSCanary10Percent15Minutes（最初のトラフィックの10%を、15分後に残りの90%を新ECSコンテナへ移行する）
      - CodeDeployDefault.ECSAllAtOnce（全てのトラフィックを新CESコンテナへ移行する）
    - Lambdaのとき :
      - CodeDeployDefault.LambdaLinear10PercentEvery1Minute（1分ごとにトラフィックの10%を新Lambda関数へ移行する）
      - CodeDeployDefault.LambdaCanary0Percent15Minute（最初のトラフィックの10%を、15分後に残りの90%を新Lambda関数へ移行する）
      - CodeDeployDefault.LambdaAllAtOnce（全てのトラフィックを新Lambda関数へ移行する）
  - 利用できるデプロイ戦略
    - EC2
      - **In-place**デプロイメント戦略 : 新しいアプリケーションを置き換えていく戦略
      - **Blue/Green**デプロイメント戦略 : 新しいアプリケーションのテスト完了後にトラフィックを新しいノードへ切り替える戦略
    - ECSやLambda
      - **Canary**デプロイメント戦略 : 最初のトラフィックのN%を新しいノードに切り替え、しばらくした後に残りのトラフィックを新しいノードに切り替える
      - **Linear**デプロイメント戦略 : 一定間隔ごとにトラフィックを新しいノードへ切り替える戦略
  - appspec.ymlの記述方法
    - サンプル
      ```yml
      version: 0.0
      os: linux

      files:
        - source: /target/sample.war
          destination: /etc/tomcat/deploy-area/

      hooks:
        ApplicationStop:
          - location: scripts/stop_app.sh
            timeout: 300
        BeforeInstall:
          - location: scripts/install_deps.sh
            timeout: 300
        ApplicationStart:
          - location: scripts/start_app.sh
            timeout: 300
        ValidateService:
          - location: scripts/health_check.sh
      ```
    - 構成要素
      - version : appspecのバージョン。0.0のみ許容される
      - os : デプロイ先のインスタンスのOS名。EC2のときのみ設定する必要あり。linuxまたはwindowsを指定する
      - files : ファイルのコピー元とコピー先を指定する。EC2のときのみ有効
      - resources : デプロイ先のコンテナ名またはLambda名を指定する。ECSまたはLambdaのときのみ有効
      - hooks :
        - EC2で有効な設定（値には実行コマンドを設定）
          - ApplicationStop : アプリケーションの停止
          - DownloadBundle : リリース媒体のダウンロード
          - BeforeInstall : インストール前の処理（バックアップなど）
          - Install : インストール処理
          - AfterInstall : インストール後の処理（設定の修正など）
          - ApplicationStart : アプリ起動
          - ValidateService : 稼働確認の処理
          - BeforeBlockTraffic : ロードバランサからの登録を解除する前の処理
          - AfterBlockTraffic : ロードバランサからの登録を解除した後の処理
          - BeforeAllowTraffic : ロードバランサへ登録する前の処理
          - AfterAllowTraffic : ロードバランサへ登録した後の処理
        - ECSで有効な設定（値にはLambda関数を指定）
          - BeforeInstall : ECSタスクの更新前の処理
          - AfterInstall : ECSタスクの更新後の処理
          - AfterAllowTestTraffic : テストリスナーがトラフィックを確認した後の処理
          - BeforeAllowTraffic : 2番目のターゲットグループのタスクの更新前の処理
          - AfterAllowTraffic : 2番目のターゲットグループのタスクの更新後の処理
        - Lambdaで有効な設定（値にはLambda関数を指定）
          - BeforeAllowTraffic : Lambda関数の更新前の処理
          - AfterAllowTraffic : Lambda関数の更新後の処理
  - EC2インスタンスにアプリケーションをデプロイするには、appspec.yml ファイルをアプリケーションのソースコードのディレクトリ構造のルートに配置する
  - CodeDeployエージェントは、ポート443のアウトバウンド通信を行うため、通信できるようネットワークを設定する必要がある
  - CodeDeployするときは、デプロイ対象に応じて以下のIAMポリシーを割り当てる必要がある
    - AWSCodeDeployRole
    - AWSCodeDeployRoleForLambda
    - AWSCodeDeployRoleForLambdaLimited
    - AWSCodeDeployRoleForECS
    - AWSCodeDeployRoleForECSLimited
  - VPCエンドポイントを経由することでインターネットを経由することなくVPCからCodeDeployサービスにアクセスできる。ただし以下のエンドポイントを作る必要がある
    - **codedeployエンドポイント** : EC2, ECS, Lambdaへデプロイするときに必要
    - **codedeploy-commands-secureエンドポイント** : EC2へデプロイするときのみ必要
  - イベント
    - CloudWatch Events (Event Bridge) を使うことで、パイプラインの状態変化をモニタリングできる

### AWS CloudFormation

{% raw %}

- **CloudFormation**とは、YAML形式で記述されたテンプレートテキストから、AWS上のリソース環境を構築できるサービス
  - コストを最適化するためには、必要なときに環境構築をし、終了したら破棄する
  - 用語
    - **スタック** (Stack) : CloudFormationによって構築されたリソースの集合
  - テンプレート
    - サンプル
      ```yaml
      AWSTemplateFormatVersion: "2010-09-09"

      Description: "テンプレートの説明"

      Parameters:
        InstanceType:
          Type: String
          AllowedValues: [ "t1.micro", "t2.nano", "t2.micro", "t2.small", "t2.medium", "t2.large"]
          Default: "t2.small"

      Mappings:
        AWSRegionArch2AMI:
          ap-northeast-1:
            HVM64: ami-0b2c2a754d5b4da22
            HVMG2: ami-09d0e0e099ecabba2
          ap-northeast-2:
            HVM64: ami-0493ab99920f410fc
            HVMG2: NOT_SUPPORTED

      Resources:
        EC2Instance:
          Type: AWS::EC2::Instance
          Properties:
            InstanceType:
              Ref: InstanceType
            SecurityGroups:
            - Ref: InstanceSecurityGroup
            KeyName:
              Ref: KeyName
            ImageId:
              Fn::FindInMap:
              - AWSRegionArch2AMI
              - Ref: AWS::Region
              - Fn::FindInMap:
                - AWSInstanceType2Arch
                - Ref: InstanceType
                - Arch

        InstanceSecurityGroup:
          Type: AWS::EC2::SecurityGroup
          Properties:
            GroupDescription: "Enable SSH access via port 22"
            SecurityGroupIngress:
            - IpProtocol: tcp
              FromPort: 22
              ToPort: 22
              CidrIp: 
              - Ref: SSHLocation

        Outputs:
          InstanceId:
            Description: InstanceId of the newly created EC2 instance
            Value:
              Ref: EC2Instance
          AZ:
            Description: Availability Zone of the newly created EC2 instance
            Value:
              Fn::GetAtt:
              - EC2Instance
              - AvailabilityZone
          PublicDNS:
            Description: Public DNSName of the newly created EC2 instance
            Value:
              Fn::GetAtt:
              - EC2Instance
              - PublicDnsName
          PublicIP:
            Description: Public IP address of the newly created EC2 instance
            Value:
              Fn::GetAtt:
              - EC2Instance
              - PublicIp
      ```
  - テンプレートの構成要素
    - Template Version : テンプレートのバージョン。最新は 2010-09-09
    - Description : テンプレートの説明
    - Metadata : Resourceに指定したAWSリソースに対する補足情報。項目の表示順序の制御など
    - Parameters : AWSコンソールからスタックを構築する際に画面で指定できる項目を定義する
    - Rules : スタックの作成・更新時にテンプレートに渡されるパラメータを検証する。無効なパラメータのときはスタックは作成・更新されない
    - Mappings : テンプレート内で使用する連想配列の定義
    - **Conditions** : Resourcesの記述について、有効となる条件を事前に定義する
    - **Resources** : スタックの構成要素となるAWSリソースを定義する
    - **Outputs** : スタック構築後にAWSコンソールで表示させる情報や、他のテンプレートから参照可能な情報を定義する
  - 組み込みファンクション : 接頭辞「!」または「Fn::」を付けるとファンクションとして評価される
    - Sub : 変数を展開して評価する（`!Sub https://dynamodb.${AWS::Region}.amazonaws.com`）
    - GetAtt : リソースの属性値を取得する。子スタックのOutputsの出力値を取得する（`!GetAtt SampleStack.Outputs.EnvironmentRegion`）
    - Ref : リソース論理名の物理IDを参照する（`!Ref SampleVPC`）
    - ImportValue : 別のスタック・テンプレートで使用されたリソースの出力を取り出す（`!ImportValue sample-cloudformation`）
    - 条件関数 (**If**, Or, And, Not, Equals) : 条件判断の記述に使用する（`!Equals ["A", "B"]`）
  - 擬似パラメータ
    - AWS::Region : リージョン名
    - AWS::StackId : スタックID
    - AWS::StackName : スタック名
    - AWS::AccountId : AWSアカウント名
  - **ネステッドスタック** (Nested Stack)
    - 複数のテンプレートをネスト（親子）にすることができる
    1. 親テンプレートのResources内で `Type: AWS::CloudFormation::Stack` を定義し、子テンプレートのスタックを定義する
    2. 子テンプレートを作成し、親テンプレートにそのファイルのローカルパスを指定する
    3. `aws cloudformation package`コマンドを実行してパスをローカルからS3に修正した親テンプレートを出力する
    4. 子テンプレートをS3にアップロードする
    5. 親テンプレートをコンソールからアップロードする or AWS CLIで実行する
  - **クロススタックリファレンス**
    - スタックのOutputsは組み込みファンクションImportValueで取得できる（`Fn::ImportValue 出力名`）
    - 親子関係でなくても別のスタック・テンプレートを呼び出すことができる
  - **ダイナミックリファレンス**
    - AWS Systems Manager Parameter StoreやAWS Secrets Managerと連携して、パスワードなどの認証情報を動的に参照できる
    - 書き方は `'{{resolve:サービス名:キー名:バージョン}}'` のような形式
      - 例：`'{{resolve:secretsmanager:secret-id:secret-string:json-key:version-stage:version-id}}'`
  - **カスタムリソース** : 独自リソースを定義できる
    - 書き方は `ResourceType: "Custom::TestResource"` で定義する
  - マクロ : テンプレート化が難しい処理をLambda関数で記述する
  - **チェンジセット** : 変更箇所の影響を受けるリソース論理IDを事前に確認できる機能
  - **ドリフト検出** : 現在のリソースとテンプレート定義の差分を検出する機能
  - スタックセット : 1つのテンプレートを複数のAWSアカウントやリージョンに展開する機能
  - CloudFormationデザイナー : GUIでテンプレートを作成できる機能
  - AWS CLI
    - `aws cloudformation create-stack` : 新規スタック作成時のテンプレートを出力
    - `aws cloudformation package` : S3バケットへのローカルアーティファクトのアップロード
    - `aws cloudformation deploy` : テンプレートのデプロイ（スタックの構築）
    - `aws cloudformation delete-stack` : スタックの削除

{% endraw %}

### AWS SAM (Serverless Application Model)

- **SAM**とは、CloudFormationの拡張機能で、サーバレスアプリケーションをより簡易的な記述で定義して構築することができるサービス
  - SAMのテンプレートの構成要素
    - CloudFormationの構成要素に加えて以下が追加される
    - **Transform** : サーバレスアプリの場合に使用し、AWS SAMのバージョンを指定する（必須）
    - **Global** : 複数のリソースに共通する構成を定義する（任意）
      - Functions : Lambda関数の設定
        - Runtime : Lambda関数の実行ランタイム
        - Handler : Lambda関数のハンドラー
        - Environment : Lambda関数を実行するときの環境変数
      - Api : REST APIの設定
        - Auth : API Gatewayへのアクセス制御をする認証方法
        - EndpointConfiguration : REST APIのエンドポイントタイプ
        - Cors : API GatewayのCORS (Cross Origin Resource Sharing) を有効化するURL
        - Domain : API Gatewayに設定するカスタムドメイン
      - HttpApi : HTTP APIの設定
        - Auth : API Gatewayへのアクセス制御をする認証方法
    - **Resource** : リソースのほかにサーバレスの構築に特化したリソースタイプも定義できる（必須）
      - AWS::Serverless::Function (AWS Lambda)
      - AWS::Serverless::LayerVersion (AWS Lambda)
      - AWS::Serverless::Api (REST API)
      - AWS::Serverless::HttpApi (HTTP API)
      - AWS::Serverless::SimpleTable (DynamoDB)
      - AWS::Serverless::Application (AWS Serverless Application Repository)
      - AWS::Serverless::StateMachine (Step Function)
  - ポリシーテンプレート : Lambda関数に付与するIAMポリシー定義を簡易化したもの
  - SAM CLI : サーバレスアプリの開発、SAMテンプレートの検証、デプロイなどの各種操作ができるコマンドラインツール
    - `sam init` : 初期化処理。SAMテンプレートを生成する
    - `sam validate` : SAMテンプレートを検証する
    - `sam build` : SAMテンプレートを使ってアプリケーションをビルドする
    - `sam package` : パッケージ（ソースコードと依存関係のZIPファイル）を作成し、S3にアップロードする（aws cloudformation packeageと同等の機能）
    - `sam deploy` : AWSにデプロイする（aws cloudformation deployと同等の機能）
  - SAMはCloudFormationの記述を全てそのまま実行できる
  - SAMはLambdaやAPI Gateway, DynamoDB, StepFunctionsなどのリソースの定義をCloudFormationよりも簡潔に記述できる

### AWS CDK (Cloud Development Kit)

- **CDK**とは、TypeScript及びPythonなどのプログラミング言語を使用して、AWSリソースを定義し、Terraformの様にInfrastructure as Code（IaC）を実現する手段
  - プログラミング言語の優れた表現力を活かして、信頼性が高く、スケーラブルで、コスト効率の高いアプリケーションをクラウドで構築できる
  - AWSリソースに適切で安全なデフォルトを自動的に提供する高レベルの構造を使用して構築し、より少ないコードでより多くのインフラストラクチャを定義できる
  - パラメーター、条件、ループ、構成、継承などのプログラミングイディオムを使用して、AWSや他の人が提供するビルディングブロックからシステム設計をモデル化する
  - インフラストラクチャ、アプリケーションコード、構成をすべて1か所にまとめることで、すべてのマイルストーンで完全なクラウド導入可能なシステムを確保できる
  - コードレビュー、ユニットテスト、ソース管理などのソフトウェアエンジニアリング手法を採用して、インフラストラクチャをより堅牢にする
  - シンプルかつインテント指向の API を使用して、AWSリソースを (スタック間でも) Connect し、権限を付与する
  - AWS CloudFormation既存のテンプレートをインポートして、リソースに CDK API を提供する
  - AWS CloudFormationの機能を活用して、インフラストラクチャのデプロイを予測どおりに繰り返し実行し、エラー発生時にロールバックすることも可能
  - インフラストラクチャの設計パターンを、組織内のチーム間または一般ユーザーと簡単に共有できる

### AWS Elastic Beanstalk

- **Elastic Beanstalk**とは、典型的なシステム構成やインフラストラクチャ設定をオプションの中から選択して、自動的にアプリケーション環境を構築するサービス
  - 典型的なプラットフォームの構築ができる
    - プレゼンテーション層、アプリケーション層、データ層からなる3層Webアプリ
    - キューを用いたバッチ処理
  - 用意されているデプロイ戦略（デプロイポリシー）
    - All at once : 1回で全てのインスタンスが更新される
    - Rolling : バッチと呼ばれる単位でインスタンスを順次更新する。フルキャパシティを維持できない
    - Rolling with additional batch : 追加でバッチ数だけインスタンスを起動してから、既存の古いインスタンスを終了する。フルキャパシティを維持できる
    - Immutable : 追加でオートスケーリンググループを作成して、新しいバージョンのインスタンスが全て正常に実行できることを確認した後に、既存の古いオートスケーリンググループを削除する。Rolling with addtional batchの代替手段
    - Traffic splitting : Canaryリリース。新旧両方のアプリを並行稼働し、一部のユーザに先行で新バージョンへアクセスさせる手法
  - そのほかのデプロイ戦略
    - URL Swap : 環境に割り当てられているURLを交換する
    - Route53 Swap : AレコードやCNAMEレコードを更新する

### Amazon OpsWorks

- **Amazon OpsWorks**とは、自動化ツールのPuppetやChefを使用するマネージドサービス
  - AWS OpsWorks for Puppet Enterprise
  - AWS OpsWorks for Chef Automate
  - AWS OpsWorks スタック

### AWS Cloud9

- **Cloud9**とは、コードを記述、実行、デバッグできるクラウドベースの統合開発環境 (IDE)
  - ブラウザのみでコードを記述できる
  - リアルタイムに共同でコーディング
  - サーバーレスアプリケーションを簡単に構築できる
  - AWSのサービスに直接ターミナルアクセスできる

### AWS CloudShell

- **CloudShell**とは、ブラウザベースの事前に認証されたシェル環境
  - マネジメントコンソール上でCloudShellを起動すると、すぐにAW CLI (awsコマンド) が使えるLinux環境が利用できる

### AWS CodeArtifact

- **CodeArtifact**とは、ソフトウェア開発のためのセキュアかつスケーラブルでコスト効率性に優れたパッケージ管理サービス
  - 一般的なパッケージマネージャーを使用してアーティファクトを格納し、Maven、Gradle、npm、Yarn、Twine、pip、NuGet などのツールを構築できる
  - パブリックパッケージリポジトリからオンデマンドでソフトウェアパッケージを自動的にフェッチできるため、アプリケーションの依存関係の最新バージョンにアクセスできる

### Amazon CodeGuru

- **Amazon CodeGuru**とは、機械学習によってプログラムからセキュリティ脆弱性を検出するためのサービス
  - セキュリティを開発パイプラインと統合することで、コードの品質を向上させ、アプリケーションのパフォーマンスを最適化できる
  - コードのレビューを開始するには、GitHub、GitHub Enterprise、Bitbucket、または AWS CodeCommit の既存のコードリポジトリを CodeGuru コンソールで関連付ける
  - 支援付き修復 : 自動推論を使用して、特定の脆弱性に対する推奨コード修正を提供する

### AWS CodeStar

- **CodeStar**とは、AWS でアプリケーションを短期間で開発、構築、デプロイするためのサービス
  - AWS CodeStar は統合されたユーザーインターフェイスを備えているため、ソフトウェア開発アクティビティを1つの場所で簡単に管理できる
  - 2024年7月31日でCode Starのサポートは終了される

### Amazon CodeWhisperer

- **CodeWhisperer**とは、アプリケーションをより迅速かつ安全に構築するAIコーディング支援サービス
  - 日本語や英語などの自然言語で開発者のIDE上に入力することで、リアルタイムで汎用的なコードを提案する
  - Python、Java、および JavaScript のコードを対象にセキュリティスキャン機能が提供されており、脆弱性や非推奨のライブラリを特定して修正方法を提案する


## 第3章 セキュリティ関連サービス

### AWS IAM (Identity and Access Management)

- **IAM**とは、AWSのサービスやリソースへのアクセスを管理する認証認可サービス
  - AWSアカウント内で許可されているユーザーと対象 (認証) 、AWSリソースを使用および操作する権限を持つユーザーと対象 (認可) を表示できる
  - IAMを使用すると、アクセスキーやパスワードを共有することなく、AWSアカウントとリソースへのアクセスを共有できる
  - IAMの設定はグローバルであり、特定のリージョンに対するサービスではない
  - IAMのパスワードポリシーでは、ユーザーの複雑な要件と必須のローテーション期間を指定できる
  - IAMはMFA（多要素認証）をサポートしている
  - IAMはIDフェデレーション（ID連携）に対応している
  - 用語
    - アカウント : AWSを利用するためのユーザアカウント。最初はアカウントに対して1つのルートユーザのみが作成されている
    - **IAMユーザ** : AWSとやり取りするユーザーまたはサービスのこと
      - ルートユーザ : 全てのAWSサービスとリソースに対する全権限を持つユーザ
      - IAMユーザ : AWSを利用する個人またはアプリケーション単位で作成するユーザ
      - フェデレーテッドユーザ : OpenID Connectなどで連携された外部ユーザ
    - **IAMロール** : 特定のアクセス権限を付与できる役割
    - **プリンシパル** (Principal) : AWSリソースに対するアクションやオペレーションをリクエストできるユーザやロールのこと
    - リクエスト : プリンシパルがAWSサービスにアクセスするためにマネジメントコンソールやCLIやSDKを経由して送信する要求
      - アクション : マネジメントコンソールから実行する操作
      - オペレーション : CLIやSDKから実行する操作
      - リソース : 実行対象となるAWSリソース
      - 環境データ : IPアドレス、ユーザエージェント、SSL有効化ステータス、時刻などのクライアントに関する情報
      - リソースデータ : リソースに関するデータ
      - 認証情報 : リクエストを出したプリンシパルの正当性を証明する署名など
    - **IAMポリシー** : アクセスを管理し、AWSのサービスとリソースへのアクセス権限を付与するためのJSON
      - アクセスポリシー : S3などのリソースに対して割り当てるポリシー
    - IAMグループ : IAMユーザーの集合
      - ユーザをグループに所属させることで、グループに割り当てられたアクセス許可を継承する
      - より便利でスケーラブルな方法であるため、ベストプラクティスとされている
  - IAMポリシーはアクセス許可をJSON形式で定義する
    - 管理ポリシーの例 :
      ```json
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "arn:aws:dynamodb:us-east-2:123456789012:table/Books"
          }
        ]
      }
      ```
    - IAMポリシーの例 :
      ```json
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "iam:ChangePassword",
              "iam:GetUser"
            ],
            "Resource": "arn:aws:iam::123456789012:user/${aws:username}"
          }
        ]
      }
      ```
    - 構成要素
      - Version : ポリシー言語のバージョン。最新は「2012-10-17」
      - Statement : アクセス許可の対象
        - Sid : 複数のステートメントを区別するためのID
        - Effect : 対象のアクションの許可・拒否（Allow / Deny）
        - Principal : アクションを実行するプリンシパルのARN
          - アカウント全体を指定するときは `arn:aws:iam::123456789012:root` または `AWS:*id*`
          - 特定のユーザを指定するときは `arn:aws:iam::123456789012:user/ユーザ名`
          - 特定のロールを指定するときは `arn:aws:iam::123456789012:role/ロール名`
        - Action : アクション。許可または拒否すべきアクションのタイプを指定する。`*` はAWSの全てのアクションを表す。
          - 例）s3:CreateBucket, rds:CreateDBSnapshot など
        - Resource : アクションの対象となるリソースのARN。`*` はAWSの全てのリソースを表す。
          - リソースの変数 `${aws:username}` は自分自身を表す
        - Condition : ポリシーを適用する条件。条件演算子やポリシー変数、条件キーを設定できる
  - ポリシーの種類
    - **アイデンティティベースポリシー** : ユーザなどに設定するポリシー
      - **インラインポリシー** : ユーザやグループ、ロールに直接設定するポリシー（管理面で非推奨）
      - **管理ポリシー** :
        - AWS管理ポリシー : AWSが事前に定義している編集不可のポリシー（例：AmazonEC2FullAccess）
        - カスタマー管理ポリシー : ユーザがカスタマイズ可能な管理ポリシー
    - **リソースベースポリシー** : S3やSQSなどのリソースに設定するポリシー。プリンシパルを限定するために使用
  - AWSルートユーザの保護 :
    - AWSルートユーザは、AWSのすべてのサービスとリソースにアクセスする完全な権限があるアカウント
    - AWSアカウントを初めて作成するときにAWSルートユーザが作成される
    - AWSルートユーザーを使用する際のベストプラクティス :
      - 一般ユーザを作成して、ルートユーザを日常的なタスクで使用しないこと
      - ルートユーザには強力なパスワードを設定すること
      - ルートユーザログイン時は多要素認証 (MFA) にすること
  - AWSロールベースアクセス
    - ロールベースアクセスにおけるベストプラクティス :
      - AWS ルートユーザーをロックダウン
      - 最小権限の原則に従う
      - IAM を適切に使用する
      - 可能であれば IAM ロールを使用する
      - ID プロバイダの使用を検討する
      - AWS シングルサインオンを検討する
  - IAMでの認証認可
    - リクエスト認証の方法 :
      - (パターンA) IDとパスワードによる認証。マネジメントコンソールを使用するとき
      - (パターンB) アクセスキーIDとシークレットアクセスキーによる認証。SDKやCLIを使用するとき
      - (パターンC) AWS STS (Security Token Service) を使用して信頼されたユーザを一時的に作成・提供する
  - 認可の評価方法
    1. アクションが拒否に含まれている場合は、拒否される
    2. アクションが許可に含まれている場合は、許可される
    3. 上記のいずれにも該当しない場合は、デフォルトで拒否される
      - リソースの場合は、リソースベースポリシーとアイデンティティベースポリシーのどちらかに拒否があると、アクセスが拒否される
  - パーミッションバウンダリー : プリンシパルに追加で管理ポリシーを設定する機能
    - ロールを引き受けた（AssumeRoleした）ユーザに対して特定の権限をさらに制限することが可能になる
  - セッションポリシー : STSで一時的な認証情報をアプリで生成する場合に、カスタマイズしたポリシーを評価条件に付け加える機能
  - 権限の委任
    - ロールの引き受け (**AssumeRole**) : 一時的にAWSリソースにアクセス可能な認証情報を作成する操作
      1. 提供側ユーザに、信頼されたエンティティ（利用側ユーザ）とアクセスポリシーを設定したIAMロールを割り当てる
      2. 利用側ユーザは、AWS STS (Security Token Service) へ一時認証情報を要求する (AssumeRole)
      3. AWS STSは、アクセス対象リソース（例：S3）に一時的にユーザのアクセスを許可する認証を設定する
      4. AWS STSは、利用側ユーザに一時認証情報を渡す
      5. 利用側ユーザは、一時認証情報を利用してリソースにアクセスする (GetObject)
    - 信頼されたエンティティ（利用側ユーザ）を許可するために提供側のポリシーで `"Action": "sts:AssumeRole` を設定する
    - EC2インスタンスのIAMロール :
      - 起動時にIAMロールを割り当てるだけで、アクセスキーなどを設定することなく、透過的に一時認証情報を使ってアクセスできる
    - クロスアクカウントルール :
      - 別のアカウントのリソースにアクセスする場合も同様にAssumeRoleが発生する
    - 外部IDフェデレーションユーザのロール引き受け
      - SAML2.0のとき : AssumeRoleWithSAML アクションによってロールを引き受けて一時認証情報を取得する
      - Amazon Cognitoのとき : AssumeRoleWithWebIdentity アクション

### AWS STS (Security Token Service)

- **STS**とは、一時的な認証情報を生成できるサービス
  - 用語
    - **サーバサイド暗号化** (Server Side Encryption; **SSE**)
      - 例）SSE-S3 : S3上で実行される暗号化
    - **クライアントサイド暗号化** (Client Side Encryption; **CSE**)
  - 永続的に有効なアクセスキーを発行するよりも安全
  - STSで提供されているAPI
    - AssumeRole
    - AssumeRoleWithSAML
    - AssumeRoleWithWebIdentity
    - DecodeAuthorizationMessage
    - GetAccessKeyInfo
    - GetCallerIdentity
    - GetFederationToken
    - GetSessionToken
  - 認証情報に含まれる情報
    - 署名に使用したアルゴリズム (AWS4-HMAC-SHA256)
    - 認証情報スコープ (アクセスキーIDを含む)
    - 署名付きヘッダの一覧
    - 署名

### AWS KMS (Key Management Service)

- **KMS**とは、データを暗号化するための**鍵**を管理するサービス
  - EBSやRDS、S3などのデータ暗号化で使用されている
  - 用語
    - 暗号化 : KMSは保存データの暗号化を行う
    - 暗号化キー :
      - カスタマーマスターキー (Customer Master Key; CMK)
        - **カスタマー管理CMK** : 
          - AWS KMSを使って生成した場合、1年ごとに自動ローテーションされる
          - 外部で作成したキーをインポートした場合、手動でローテーションする必要がある
        - AWSマネージドCMK :
          - AWSマネージドサービスが作成したキー。キー名が「aws/*service-name*」で作成される
          - 生成されたキーは3年間でローテーションする
        - AWS所有CMK :
          - 複数のAWSアカウントで使用するためにAWSが管理するキーのコレクション。ユーザは意識することなく使用できる
      - カスタマーデータキー (Customer Data Key; CDK)
        - データキー : 対称鍵。AESなど
        - データキーペア : 非対称鍵。RSAやECCなど
    - **エンベロープ暗号化** : カスタマー管理CMKを使って指定された暗号化アルゴリズムと共にデータキーを生成する機能
      - KMS GenerateDataKey APIを利用してデータキーを生成する。暗号化した後はすぐにデータキーを破棄する
  - KMSの機能
    - 鍵の生成 : カスタマーマスターキーの生成
    - 鍵のインポート : AWS外部で作成したCMKのインポート (Bring Your Onw Key; BYOK)
    - 鍵へのアクセス管理 : IAMユーザ・ロールの定義。キーポリシーによるアクセス制御
    - 鍵管理 : CMKの無効化・有効化・削除・ローテーション
  - ユースケース
    - S3やEBSなどの多数のAWSサービスのデータ暗号化でKMSが使われている
      - SSE-KMSは暗号化すると同時にCloudTrailに暗号化の証跡をログとして記録する。一方でSSE-S3はCloudTrailに記録されない
      - 完全な暗号化が求められるときは、**SSE-C**（ユーザが用意したキーによるサーバサイド暗号化）や**CSE-C**（ユーザが用意したキーによるクライアントサイド暗号化）を使う
    - 非対称キーを生成・利用したいときは、AWS CSE-KMS（クライアントサイド暗号化）でKMS API経由で取得する
  - APIリクエスト制限
    - APIリクエスト上限に到達すると「KMS ThrottlingException」が発生する
    - 対策として、エラーが発生するたびに呼び出し間隔を指数関数的に伸ばしてリトライする「エクスポネンシャルバックオフ」が標準で採用されている

### AWS Secrets Manager

- **Secrets Manager**とは、DBのパスワードやAPIキーなどデータ流出の危険性がある**認証情報**（シークレット）を集約して管理するサービス
  - アプリケーションにシークレット情報を保存する必要がなくなる
  - AWS Systems Managerと比較して、Secrets Managerはシークレットの更新間隔を指定できる。
  - 更新間隔を指定すると自動でパスワードが変更され、DBサービス側のパスワードも自動的に変更される。
  - 管理できるシークレットの種類 :
    - データベース認証情報
    - オンプレミスリソース認証情報
    - SaaSアプリケーション認証情報
    - サードパーティーAPIキー
    - Secure Shell (SSH) キー

### AWS Systems Manager (Parameter Store)

- **Systems Manager**とは、AWSにおけるシステム運用でソフトウェアインベントリの収集やOSのパッチ適用、運用コマンドの実行、環境変数の管理などを行うサービス
  - パラメータストア (Parameter Store) : Systems Managerの機能の一つで、AWSサービスやアプリで利用するパラメータを管理する機能。パスワードやDBの接続文字列などを管理するために使う
  - EC2, ECS, Lambda, CloudFormation, CodeBuild, CodeDeploy, CodePipeline のサービスで利用するパラメータや環境変数をパラメータストアで管理できる
- **AWS AppConfig**
  - Systems Managerの機能の1つで、アプリケーション設定を作成、管理し、迅速にデプロイできる
  - LambdaやEC2, EKSやCodePipelineなどの統合できる

### AWS Certificate Manager (ACM)

- **ACM**とは、AWSサービスと内部接続リソースで使用するパブリックおよびプライベート SSL/TLS 証明書をプロビジョニング、管理、および展開するためのサービス
  - SSL/TLS 証明書の購入、アップロード、および更新という時間のかかるプロセスを手動で行う必要がなくなる

### AWS Private Certificate Authority

- **Private CA**とは、可用性の高い汎用的な認証局を構築するためのサービス
  - 組織がプライベート証明書を使用してアプリケーションとデバイスを保護するために利用できる

### Amazon Cognito

- **Cognito**とは、Webアプリやモバイルアプリに認証機能を提供するAPIベースのサービス
  - ユーザディレクトリサービスの「ユーザプール」と認証されたユーザに対し権限を付与する機能の「IDプール」がある
  - **ユーザプール** (ユーザの認証)
    - 利用方法
      - 認証用の管理APIのユーザ名パスワード認証（ALLOW_ADMIN_USER_PASSWORD_AUTH）を有効にする
        - リクエストにパスワードが含まれるためHTTPSが必須
      - Lambdaトリガーベースのカスタム認証 (ALLOW_CUSTOM_AUTH) を有効にする
        - Lambdaでカスタム認証をするとき
      - ユーザ名パスワードベースの認証 (ALLOW_USER_PASSWORD_AUTH) を有効にする
        - リクエストにパスワードが含まれるためHTTPSが必須
      - セキュアリモートパスワード (SRP) プロトコルベースの認証 (ALLOW_USER_SRP_AUTH) を有効にする
        - Secret Saltやチャレンジレスポンスに対応
        - モバイルアプリなどのデコンパイルされる可能性があるときは、SRPを利用するかクライアントシークレットを発行しない認証方法を構築する
      - 更新トークンベースの認証 (ALLOW_REFRESH_TOKEN_AUTH) を有効にする
        - リフレッシュトークンを使うとき
    - ユースケース
      - EC2やECS上に配置したWebアプリの認証（サインアップ・サインイン）
      - モバイルアプリの認証
      - API GatewayからのCognitoオーソライザ
      - AWS Lambdaを使ったカスタムオーソライザ
      - ALBからのCognitoオーソライザ
    - Cognitoでは、OIDC (OpenID Connect) の仕様が定めるいくつかのトークンエンドポイントが提供されている
    - 外部フェデレーション
      - Facebook, Google, Amazon, Apple, SAML, OpenID Connectプロバイダと連携して、ユーザ情報を利用することができる
  - **IDプール** (AWSサービスへのアクセス認可)
    - 利用方法
      1. クライアントは、Amazon Cognitoユーザプールに認証リクエストを投げる
      2. AWS Cognitoユーザプールは、ユーザ認証をして、クライアントにJWTトークンを返却する
      3. クライアントは、Amazon Cognito IDプールにリソースへのアクセス要求を投げる
      4. Amazon Cognito IDプールは、Amazon CognitoユーザプールへJWTトークンの情報を取得して検証を行う
      5. Amazon Cognito IDプールは、AWS STSに一時的なAWS認証情報を要求する
      6. Amazon Cognito IDプールは、クライアントに一時的なAWS認証情報を提供する
      7. クライアントは、一時的な認証情報を利用してリソースにアクセスする
    - 流れ図
      ```fig
              (1) RequestAuth
      client -------------------> Cognito (User Pool)
       |  |  <-------------------       ^
       |  |   (2) ReturnJWT             |(4) VerifyToken
       |  |                             |
       |  |   (3) RequestCred           |              (5) RequestCred
       |  +---------------------> Cognito (ID Pool) -------------------> AWS STS
       |  <----------------------                   <-------------------
       |      (7) ReturnTmpCred                        (6) ReturnTmpCred
       |
       |      (8) Access
       +------------------------> AWS Service
      ```

### AWS WAF (Web Application Firewall)

- **AWS WAF**とは、Webアプリの脆弱性を悪用した攻撃からシステムを保護する仕組み
  - 通信内容に応じてバケットをブロックできる
  - 特定のIPアドレスからのアクセスを抑止することもできる

### その他のセキュリティサービス

- **AWS Shield** : L3, L4, L7レイヤーへのDDoS攻撃からシステムを保護する仕組み
- **Amazon Inspector** : EC2の脆弱性を診断するサービス
  - ホスト型診断 : Amazon Inspectorエージェントをインストールして診断する
  - 外部ネットワーク型診断 : 外部ネットワークから脆弱性を診断する
- **Amazon Detective** : 各種AWSサービスから収集できるデータを分析・可視化してインシデントの原因を特定するためのサービス
- **Amazon GuardDuty** : ユーザの動作や通信をモニタリングして脅威を識別する脅威検出サービス
  - 脅威インテリジェンスと機械学習モデルを使った脅威検出を行う
- **Amazon Macie** (メイシー) : S3バケットと内部のオブジェクトを分析して、機械学習とパターンマッチングによる脅威検出やデータ分類を行うサービス
  - データ分類のための機能で、機密データを検知するために使用する
  - バケットのセキュリティとアクセス制御を自動的に評価・監視する機能を提供する


## 第4章 開発関連サービス

### Amazon API Gateway

- **API Gateway**とは、オンラインサービスへのリクエストを受け付ける機能を提供するサービス
  - API Gatewayが提供する機能
    - **REST API**
      - OpenAPI (Swagger) に準拠した定義ファイルからAPI作成が可能
      - エンドポイントタイプの種類
        - エッジ最適化APIエンドポイント : Amazon CloudFrontのエッジロケーションを使用して、クライアントに最も近い接続ポイント (POP) にルーティングする
        - リージョンAPIエンドポイント : 指定したリージョンにAPIエンドポイントをデプロイし、同一リージョン内のクライアントにサービスを提供する
        - プライベートAPIエンドポイント : インターネットから分離されたVPNからのアクセスを許可するAPIエンドポイント
      - 設定項目
        - リソース : 例）/users
        - メソッド : 例）GET, POST
        - メソッドリクエスト : APIで必須となるクエリパラメータ、ヘッダなどを定義
        - 統合リクエスト : バックエンドへ転送するリクエストを定義。バックエンドにはLambda関数、HTTPエンドポイント、Mock、AWSサービス、VPCリンクを選択できる
        - 統合レスポンス : バックエンドから返却されたレスポンスを定義
          - マッピングテンプレート : 統合リクエストと統合レスポンスの設定で使用し、入力JSONから出力JSONへデータを変換する方法をJavaScript風の独自言語で定義できる
        - メソッドレスポンス : APIから返却されるレスポンスの定義
        - モデル : リクエスト・レスポンスで共通的に扱われるデータスキーマの定義
        - **ステージ** : APIがデプロイされる論理的な環境の名前。ステージごとに設定（ステージ変数）を変えることができる。例）prod, staging, dev
        - **オーソライザ** : 認証認可の設定
          - IAMアクセス権限 (AWS_IAM)
          - Lambdaオーソライザ
          - Cognitoオーソライザ
          - （JWTオーソライザはHTTP APIでのみ設定可能）
    - **HTTP API**
      - REST APIと比較してLambda関数などを使うことでより柔軟な設定ができる
      - OIDC, OAuth2.0対応（ソーシャルIDプロバイダとの連携）
      - CORS対応
      - エンドポイントタイプの種類
        - リージョンAPIエンドポイント : 指定したリージョンにAPIエンドポイントをデプロイし、同一リージョン内のクライアントにサービスを提供する
      - 設定項目
        - ルート : HTTPメソッドとリソースパスの組み合わせ
        - 統合 : リクエストをバックエンドに転送する定義。バックエンドにはLambda関数、HTTPエンドポイント、AWSサービス、VPCリンクを選択できる
        - ステージ : APIをデプロイする論理的な環境
    - **WebSocket API**
      - 双方向のステートレス通信を行う
      - 設定項目
        - ルート選択式 : API Gatewayが受信したメッセージに対して行う評価の定義
        - ルート : ルート選択式によって評価された後の処理の振り分け先を定義
        - 統合 : リクエストをバックエンドに転送する定義
        - ステージ : APIをデプロイする論理的な環境
  - アクセス元IPアドレスの制限 :
    - リソースポリシーを設定することでアクセス元IPアドレスの制限ができる
    - リソースポリシーのConditionを使い、`"Condition": {"IpAddress": {"aws:SoureIp": ["IPアドレス"]}}`で指定可能
  - IAMアクセス権限 : AWS署名バージョン4を利用した認証認可
    - AWS署名バージョン4は、IAMユーザのアクセスキーIDとシークレットアクセスキーをもとに作成したハッシュ値
    - クライアントは、HTTPリクエストヘッダにAWS署名バージョン4を含めて送信することで、API Gateway側でハッシュ値の検証が行われる
  - **Lambdaオーソライザ** : Lambda関数を利用した認証認可
    - クライアントは、API Gatewayに対してBearerトークンもしくはHTTPリクエストヘッダのパラメータに認証情報を付与したリクエストを送る
  - **Cognitoオーソライザ** : Amazon Cognitoユーザプールを利用した認証認可
    - クライアントは、Cognitoのユーザプールで認証を行いトークン (JWT) を取得し、HTTPリクエストヘッダにトークンをセットしてリクエストを送る
  - **JWTオーソライザ** : OpenID ConnectまたはOAuth2.0を利用した認証
    - クライアントは、OpenID ConnectまたはOAuth2.0で認証を行いトークン (JWT) を取得し、HTTPリクエストヘッダにトークンをセットしてリクエストを送る
    - プロバイダをCognitoに設定することもできる。その場合はCognitoオーソライザと同じ構成になる
  - 相互TLS認証 : TLSクライアント認証による認証認可
  - **スロットリング** (Throttling) :
    - API Gatewayにはトークンバケットアルゴリズムに基づく流量制御の仕組みとしてスロットリングがある
    - 用語
      - トークン : 1リクエストを処理するたびに、バケット内に複数保持しているトークンを1つ消費する
      - 定常レート : トークンの補充速度
      - バースト : バケット内に格納するトークンの最大数
      - APIキー : クライアント側から送信され、クライアントの使用量プランを取得するために使われる
        - ※APIキーを認証目的で利用することはバッドプラクティス
    - サーバ側のスロットリング : 全てのクライアントに適用し、大量のリクエストからバックエンドを守るために設定する
      - AWSアカウントレベル : デフォルトで定常レートは10000リクエスト/秒、バーストは5000リクエストが設定されている
      - ステージまたはメソッドレベル : 特定のステージまたはAPI個別のメソッドに対して制限値をオーバーライド（上書き）できる
    - クライアントあたりのスロットリング : クライアントごとに使用量プランを設定して制限を行う
      - メソッドレベル : クライアントの使用量プランに基づくメソッドレベルでのスロットリング
      - ステージレベル : クライアントの使用量プランに基づくステージメソッドでのスロットリング
    - 制限を超えるとAPI Gatewayは「429 Too Many Requests」を返す
  - APIのキャッシュ : TTLの設定も可能
  - **カナリアリリース** : 
    - 任意のステージに対して「Canary」という特別なステージを定義できる
    - API Gatewayへのリクエストを指定した比率でCanaryステージに分配できる（一部ユーザのみ限定して公開する）
    - ダウン時間やリスクを最小限にしながら最も低コストで新しいバージョンのリリースができる
  - WAF連携 : API GatewayにAWS WAFやACL (Access Control List) を設定することで、SQLiやXSSなどの攻撃を防ぐことができる
  - 監視連携 : CloudWatchやX-Rayと連携でき、メトリクスの収集が可能
  - API GatewayとLambdaエイリアスの対応付け :
    - LambdaとAPI Gatewayをセットで使う場合、両サービスはそれぞれに状態を持っているため、それらの関連性を管理する必要がある
      - Lambda : VersionとAlias
      - API Gateway : Deployment Stage
    - 関連付けるためには変数stageVariableを使用する
      - `${stageVariable.stageVariableName}`
      - `${stageVariable.alias}`
      - `${stageVariable.version}`
    - 例）`http://hykf0*****.execute-api.ap-northeast-1.amazonaws.com/${stageVariables.stageVariableName}/resource/operation`

### AWS Lambda

- **Lambda**とは、アプリケーションサーバの実行ランタイムを完全マネージドとするコンピューティングサービス
  - サーバーレスの特徴
    - プロビジョンまたは管理するサーバーがない
    - 使用状況に応じた提供範囲
    - アイドルリソースに対して料金を支払う必要がない
    - 可用性と耐障害性が組み込まれている
  - AWSには、AWS FargateやAWS Lambdaなど、いくつかのサーバーレスコンピューティングオプションがある
  - 用語
    - **イベントソース** : AWSのサービスまたはデベロッパーが構築したアプリケーションで、AWS Lambda関数の実行をトリガーするイベントの発生元
    - イベントソースマッピング : イベントソースから読み取りLambda関数を呼び出すLambdaリソースのこと
  - ランタイム : アプリケーションを実行させるために必要なライブラリやパッケージ
    - Node.js, Python, Ruby, Java, Go, C#, PowerShell
    - カスタムランタイム : 標準のランタイムでサポートされていないバージョンを作成して実行することができる
  - Lambda関数
    - pythonで実装する場合は関数「lambda_handler」で処理を定義する
    - 関数ハンドラーを別の名前にしたい場合は、ランタイム設定で任意の名前を付ける必要がある
      ```py
      def lambda_handler(event, context):
          return {'statusCode': 200}
      ```
    - 設定項目 :
      - 環境変数
      - 基本設定 :
        - ランタイム : 実行環境
        - ハンドラ : メソッド名
        - メモリ : 128MB〜3008MB
        - タイムアウト : 最大900秒（15分）
        - 実行ロール : IAMロール
      - モニタリングツール : CloudWatchの設定
      - VPC : Lambda関数をVPC内に配置する場合に設定する
      - ファイルシステム : Amazon EFSによるファイルシステムのマウントが必要な場合に設定する
      - 同時実行数 : 最大1000
      - 非同期呼び出し : 非同期呼び出し時のリトライ操作の設定
      - データベースプロキシ : DB接続時に利用するProxy
  - 料金
    - 最小実行時間なしで最も近いミリ秒単位で切り上げる
    - 期間が100ミリ秒未満の関数や低レイテンシーAPIなど、実行時間が非常に短い関数を実行すると費用対効果が高くなる
    - AWS Lambda では、サーバーのプロビジョニングや管理を行わずにコードを実行でき、使用した分だけ料金を支払うことができる
    - コードがトリガー (リクエスト) された回数とコードが実行された時間に対して、1ミリ秒単位で切り上げられた時間 (期間) に対して課金される
  - ソースコード
    - Lambda関数の作成例）https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/with-s3-example.html
  - 実行ロール :
    - 通常はAWSLambdaBasicExecutionRole管理ポリシーを付与する
    - 上記にはAmazon CloudWatch LogsのAPIを呼び出す権限も含まれている。ただし、CloudWatch Logsを有効化しておかないと意味ない
  - VPCアクセスの権限 : 実行ロールに「AWSLambdaVPCAccessExecutionRole」ポリシーをアタッチすることで、VPC内で実行されているRDSやElastiCacheなどのリソースにアクセスできるように設定できる
  - Lambda実行の流れ
    1. コンテナの作成
    2. デプロイパッケージのロード
    3. デプロイパッケージの展開
    4. ランタイム起動・初期化
    5. 関数・メソッドの実行
    6. コンテナの破棄
    - ウォームスタート : リクエストが継続的に発生するときにコンテナが再利用される（1〜4が省略される）
    - コールドスタート : 不要と判断されたコンテナは破棄され、次回Lambda関数を実行するときにコンテナ作成から開始される
    - Provisioned Concurrency : 性能要件を満たすためにLambda関数を事前にプロビジョニングして、常にウォームスタートになるようにする
  - **Lambdaレイヤー** (Layers) : 補助的なコードやデータを含むZIPファイルアーカイブ
    - 複数のLambda関数で共通利用する機能
    - 複数の関数間で依存関係を共有し、コーディング量を減らすことができる
    - 1つのLambda関数でLayerを最大5個まで指定できる
    - レイヤーには通常、ライブラリの依存関係、カスタムランタイム、設定ファイルが含まれている
    - デプロイパッケージのサイズを小さくすることができる
    - Lambdaレイヤーを作成し、Lambda関数にアタッチすることで利用できる
  - Extensions (Lambda拡張) : Layersを利用してLambdaの機能を拡張できる
    - 任意のモニタリング、オブザーバビリティ、セキュリティ、ガバナンス用ツールを利用できるようにするため
    - 1つのLambda関数にExtensionは最大10個まで利用できる
  - デプロイパッケージ : Lambda関数でビルドして作成したパッケージをAWS Lambdaにデプロイすること
    - サポートされる形式 :
      - ZIP : サイズの上限が250MB
      - Dockerコンテナイメージ : サイズの上限が10GB。ECSやFargateなどとデプロイ方法を統一できる
  - バージョニングとエイリアス
    - Lambdaはバージョン管理が可能
    - **Lambdaエイリアス** : 特定のバージョンのLambda関数を指すポインタ。バージョンに対して任意の名前をエイリアス（別名）で定義できる
      - エイリアス名とLambda関数のARNをセットで登録する
      - イベントソースマッピングでLambda関数の指定にARNを使用する代わりに、エイリアスARNを使用できる
      - 例）DevやProductionというエイリアス名を特定のバージョンに紐づける
    - Lambda関数のARN
      - 修飾ARN : ARNの末尾にバージョン番号がある（`arn:aws:lambda:aws-region:acct-id:function:helloworld:42`）。本番環境での使用を想定
      - 被修飾ARN : ARNの末尾にバージョン番号がない（`arn:aws:lambda:aws-region:acct-id:function:helloworld`）。開発環境での使用を想定。
        - バージョン指定なしのときは、暗黙的にLambdaエイリアス $LATEST (最新バージョン) のLambdaが呼び出される
  - Lambda関数の呼び出し
    - イベント :
      - トリガー : Lambda関数を呼び出すリソースや設定のこと
      - イベント : Lambda関数の呼び出し元から連携されるJSONのこと
    - イベントソースの種類 :
      - ポーリングベースのイベントソース
      - イベントドリブンのイベントソース
    - 呼び出し方の種類 :
      - 同期呼び出し : Lambda関数からのレスポンスを待つ
        - 呼び出し元となるサービスの例 : API Gateway, DynamoDB, SQS, Cognito, ...
      - 非同期呼び出し : Lambda関数からのレスポンスを待たずに、クエリの受付結果のみを受信する
        - 呼び出し元となるサービスの例 : S3, SNS, CloudWatch Events, EventBridge
    - エラーハンドリング
      - 同期呼び出しのとき、レスポンスヘッダ「X-Amz-Function-Error」が設定される
      - 非同期呼び出しのとき、デフォルトで2回までリトライされ、SNSやSQSに対してデッドレターキューを送信する。
        - クライアントは CloudWatch Logsのサブスクリプションフィルタで特定のエラーを抽出し、Lambda関数でサービスエンドポイントへ連携する必要がある
    - 送信先 : 条件に応じて呼び出すサービスを指定できる
      - On failure (失敗時)
      - On success (成功時)
      - 送信先として指定できるサービスは SQS, SNS, Amazon EventBridge, Lambda関数
    - 同時実行数
      - 各リージョンごとに同時実行数の上限が設定されている。東京リージョンでは最大1000リクエスト同時実行できる
      - より多くのリクエストの同時実行が見込まれるとき、AWSサポートにLambda関数の同時実行の制限を引き上げるようにリクエストを出すことができる
    - HTTPSを通してLambda関数を呼び出すには、Amazon API Gatewayを使用してカスタムのRESTful APIを定義する
    - Lambda関数は、ブラウザ、curl、任意の HTTP クライアントを使用して呼び出すことができる組み込みのHTTPSエンドポイントである関数のURLを用いて設定することができる
    - Lambda関数のURLは、デフォルトではIAM認可で保護される
    - クライアントはHTTPライブラリを使用してクライアントアプリケーションのコードから、またはcurlを使用してコマンドラインから、Lambda関数を簡単に呼び出すことができる
  - AWS Lambda SnapStart :
    - (Java向け) AWS Lambda SnapStartを使用すると、関数の起動を10倍高速化できる

### Amazon DynamoDB

- **DynamoDB**とは、優れたスケーラビリティと拡張性を持つNoSQLデータベースサービス
  - 多数の書き込みトランザクションが発生し、非常に低いレイテンシでの読み書き応答が要求されるアプリに対して有効な選択肢
  - エンドポイントを通していずれかのAZにあるDynamoDBの正常なノードにアクセスする
  - 障害などで複数のノード間で整合性の取れないとき :
    - ReadRepair機能 : 読み込み時に最新のデータで古いノードのデータを更新する
    - Quorumで整合性を取る方法 : 不整合が出たときになるべく多く一致したデータを使用する多数決に似た手法
  - DynamoDBのキーと属性・インデックス
    - 親キー : **パーティションキー** (Partition Key) : 項目 (Item) がどのパーティションに保存されているかを決めるキー。設定は必須
    - 子キー : **ソートキー** (Sort Key) : 項目 (Item) の検索をするためのキー。設定は任意
    - **プライマリキー** : パーティションキーとソートキーを合わせたもの
    - キーのルール :
      - 親キーで配置されるノードが決まる
      - ノード内のデータ準受を決定する子キーは任意に設定できる
      - 親キーと子キーの組み合わせでデータを一意に特定できる（子キーを作成しない場合は親キーのみで一意になる）
      - キーにはインデックスを設定できる
    - DynamoDBのデータサイズ上限は1項目(Item)あたり400KB（バイナリデータの保存には向いていない）
    - セカンダリインデックス : プライマリキー以外の属性で、データの効率的にアクセスするための仕組み
      - **グローバルセカンダリインデックス** :
        - テーブル作成時に設定したパーティションキー・ソートキーとは別の「パーティションキー・ソートキー」をインデックスとして設定できる仕組み
      - **ローカルセカンダリインデックス** :
        - テーブル作成時に設定したソートキーとは別の「ソートキー」をインデックスとして設定できる仕組み
  - RDBと比較したDynamoDB (NoSQL) の制約
    - テーブル間の結合ができない
    - 外部キーがない
    - 条件指定は基本的にプライマリキー以外はできない
    - 副問い合わせができない
    - 集約関数 (GROUP BYなど) は存在しない
    - 論理演算はANDしかできない。OR, NOTは存在しない
  - 読み込み整合性
    - 結果整合性のある読み込み : Read時に最近完了したWrite操作の結果が応答に反映されない場合あり
    - 強力な整合性のある読み込み : Read時に最近完了したWrite操作の結果が応答に必ず反映される。コストは結果整合性のある読み込みの2倍かかる
  - キャパシティユニット
    - 定義 :
      - **RCUs** (Read Capacity Units)
        - 「4KB」までを1ブロックとして計算する
        - 1秒あたりの読み込み項目数 × 項目(Item)サイズ
        - 結果整合性がある読み込みのとき、スループットは2倍になる
        - トランザクション読み込みのとき、スループットは1/2倍になる
      - **WCUs** (Write Capacity Units)
        - 「1KB」までを1ブロックとして計算する
        - 1秒あたりの書き込み項目数 × 項目サイズ
        - トランザクション書き込みのとき、スループットは1/2倍になる
    - 課金体系の種類 :
      - **オンデマンドキャパシティモード** : リクエスト数に応じた課金
      - **プロビジョンドモード** : テーブル単位での読み書きのパフォーマンスをスループットとして定義する課金
  - フィルタを使った読み込み・条件付き書き込み（クエリフィルター式）
    - GetItem : テーブルから1個の項目を取り出す
    - BatchGetItem : テーブルから複数の項目（最大100個）を取り出す
    - Query : 特定のパーティションキーを持つ全ての項目を取り出す
    - Scan : 指定されたテーブルまたはインデックスの全ての項目を取り出す
    - PutItem : 項目を作成する
    - UpdateItem : 1つ以上の項目を更新する
    - DeleteItem : 項目を削除する
    - BatchWriteItem : 1つ以上のテーブルから最大25個の項目を更新・削除する
    - TransactGetItems : 最大25個のGetアクションをまとめてグループ化して実行する。エラー発生時はTransactionCanceledExceptionで失敗する
    - TransactWriteItems : 最大25個の書き込みアクションをまとめてグループ化して実行する
      - 途中でエラーした場合はロールバックされ、TransactionCanceledExceptionで失敗する
  - スキャン制限パラメータ
    - DynamoDBスキャンオペレーションで取得できる項目の最大数を設定できる（SQLのlimitと同じようなもの）
  - **TTL** (Time To Live) : 有効期限を過ぎると自動的にテーブルからデータを削除する機能
  - **DAX** (DynamoDB Accelarator) : マルチAZで自動フェイルオーバー機能を持つインメモリキャッシュの機能
    - 多数の書き込みトランザクションに対応し、キャッシュを用いて低レイテンシーな要求に対応できる
  - **DynamoDB Streams** : データの追加・変更・削除履歴を記録する機能
    - **DynamoDB Trigger** : データ更新をトリガーとしてLambda関数を実行する機能（DynamoDB Streamsを有効にすると使える機能）
  - グローバルテーブル : リージョンをまたいでDynamoを構築する機能
  - スケーリングの方法 :
    - オンデマンドキャパシティモード : リクエスト数に応じて動的にキャパシティユニットが自動的に調整される
    - Auto Scaling + プロビジョニングモード : トラフィックの変更に応じてテーブルのプロビジョンドキャパシティーを自動的に調整する

### Amazon Route53

- **Route53**とは、AWSが提供しているDNSサービス
  - Route 53はVPC内の閉鎖的なネットワーク内でもDNSサーバとしての役割を提供する
  - 用語
    - ドメイン名 : ゾーンを管理するネームサーバのドメイン名
    - TTL : レコードが有効な期限
    - CLASS : ネットワークプロトコル。ほとんどの場合は IN (インターネット) が使用される
    - TYPE : レコードのタイプ
      - SOA (Start Of Authority) : ゾーンを管理する主体であることを示すレコード
      - NS (Name Server) : ゾーンを管理するネームサーバのドメイン名を指定する
      - A : ドメイン名に対応するIPv4アドレスもしくはDNS名を指定する
      - AAAA : ドメインん名に対応するIPv6アドレスもしくはDNS名を指定する
      - CNAME : 複数のドメインの名前解決を置き換えるときに使用する
      - MX : 対象ドメイン宛のメールの配送先（メールサーバ）のホスト名を指定する
    - RDATA : レコードに対して実際に指定する値
  - ホストゾーン (Hosted Zone) : Route53でDNSサービスを定義すること
    - パブリックホストゾーン : インターネットからのDNS問い合わせに対応する
    - プライベートホストゾーン : 閉鎖されたネットワーク内からのDNS問い合わせにのみ対応する
  - トラフィックルーティングの種類
    - シンプルルーティング : ドメインに紐づいたアドレスにルーティングする
    - 位置情報ルーティング : クライアントのIPアドレスから位置情報を特定し、ルーティングを行う
    - **フェールオーバールーティング** : ヘルスチェックと組み合わせてシステムがダウンしたときに待機システムに切り替える
    - **地理的近接性ルーティング** : ユーザとサービスを提供するサーバの物理的な距離に基づいてルーティングを行う
    - **レイテンシーベースドルーティング** : クライアントが最もレイテンシーが低くなるようにルーティングを行う
    - 加重ルーティング : ユーザによって指定された割合に基づき、複数のAWSリソースへルーティングされる
    - 複数回答ルーティング : 1つのドメインに対して、最大8つのランダムに選択された正常なレコードの結果でDNSクエリに応答する
  - トラフィックフロー : GUIコンソール上で簡単にトラフィックルーティングを組み合わせて作成できる機能
  - **Route53 Resolver** : VPCを構築した際に作成されるDNSサーバ（プライベートホストゾーンとは別）
    - 内部的には「フルサービスリゾルバ」と「DNSフォワーダ」の機能を持つ
    - DNSフォワーダ : 名前解決の要求をドメイン名に応じて振り分ける。
      - クライアントは一般的に名前解決の際にドメインの種類に応じて問い合わせ先DNSサーバを切り替えることはできないため
  - Route53 Resolverの役割
    - オンプレミスネットワークからVPCリソースへの名前解決
    - オンプレミスネットワークからインターネット外への名前解決（オンプレDNSサーバ => AWS Route53 Resolver => AWS Route53）
    - VPCリソースからオンプレミスネットワーク向けの名前解決

### Amazon ELB (Elastic Load Balancing)

- **ELB**とは、AWSが提供する完全マネージドな仮想ロードバランシングサービス
  - ロードバランシングとは、一連のリソースにタスクを分散するプロセスのこと
  - ELBの共通の特徴
    - **ヘルスチェック** : ELBはヘルスチェックとしてロードバランシング先となるターゲット (EC2インスタンスやコンテナ) に対してリクエストを送信して死活監視を行う
      - アプリケーションのポートが開いていることを確認するだけでは、アプリケーションが動作していることの保証にはならないため
      - アプリケーション側に /monitor などのエンドポイントを作成しておく
    - リクエストモニタリング・ログ : ヘルスチェックの結果はCloudWatchでグラフ化される
    - **SSL/TLSターミネーション** (TLS終端)
      - 以下のいずれかを選択できる
        - **クライアントとELBの間の暗号化** : ELBでTLS終端をしたのち、ELBからバックエンドターゲットへは平文で通信する
        - **クライアントとサーバ間の暗号化** : ELBでTLS終端をしたのち、ELBからバックエンドターゲットへの通信もTLS通信を行う
        - **SSLパススルー型通信** : ELBでTLS終端をしない。クライアント証明書などをEC2などのバックエンド側で処理する場合に使用する
    - Connection Drain : ロードバランサーを終了するとき、残ったリクエスト処理のために一定期間待機してから終了する。デフォルトは300秒、最大1時間まで延長できる
    - **スティッキーセッション** : 同じクライアントからのリクエストを常に固定したターゲットに振り分ける。振り分けにはCookieを利用している
      - WebSocket対応
    - スケーラビリティの観点から、ELBは受信トラフィックの需要に合わせて自動的にスケーリングされる
    - ELBはIPアドレスにロードバランスできるため、ハイブリッドモードで動作できる。オンプレミスサーバーへのロードバランスもできる
    - ELBは高可用性を備えている。ロードバランサーを複数のアベイラビリティーゾーンにデプロイすること
  - ELBサービスの構成要素 :
    - **ルール** :
      - ターゲットグループをリスナーに関連付ける
      - ルールはクライアントの送信元IPアドレスを指定できる条件と、トラフィックを送信するターゲットグループを決定する条件で構成される
    - **リスナー** :
      - クライアント側のこと
    - **ターゲットグループ** :
      - サーバ側は1つ以上のターゲットグループで定義される
      - トラフィックの接続先を定義する
- **ALB** (Application Load Balancer)
  - ALBはリバースプロキシ型のロードバランシングサービス (**L7ロードバランサ**)
  - 以下のルーティング設定を組み合わせることができる
    - パスベースルーティング : リクエストURLのパスに応じてルーティングする
    - ホストベースルーティング : HTTPヘッダのhostフィールドに応じてルーティングする
    - HTTPヘッダベースルーティング : HTTPヘッダの値（任意のヘッダを選択可）に応じてルーティングする
    - HTTPメソッドルーティング : HTTPメソッドに応じてルーティングする
    - クエリ文字列ベースルーティング : HTTPリクエストのクエリパラメータの値（任意のパラメータを選択可）に応じてルーティングする
    - ソースIPアドレスCIDRベースルーティング : リクエスト元のIPアドレスに応じてルーティングする
  - OIDCプロバイダ認証 : AWS Cognito, OIDC IDプロバイダと連携したユーザ認証ができる
  - AWSサービスとの連携
    - EC2 / ECS / AutoScaling : 需要に応じて自動的にリソースを増減できる
    - Lambda : ターゲットグループにLambda関数を設定できる
    - Route53 : エイリアスコードを用いたドメイン名とロードバランサDNSの関連付け
    - Certificate Manager : ALBで使用するTLS証明書の発行・設定を簡単に行える
    - AWS WAF : Web ACL (アクセスコントロールリスト) に基づいてリクケスとを許可・拒否する
    - AWS Global Accelerator : AWSエッジロケーションを使ってALBへアクセスする高速なグローバルネットワークロードバランサ
  - 振り分け可能なプロトコル :
    - HTTP, HTTPS
    - ネイティブなHTTP/2 : 圧縮によるデータサイズの軽減
    - gRPC通信のサポート
  - TLSオフロード（TLS終端）のサポート
  - ALBはユーザーを認証できる（SAML, LDAP, Microsoft Active Directory）
  - ALBはトラフィックを保護できる
    - 許可のIPアドレス範囲だけがALBにアクセスできるようにセキュリティグループを設定できる
  - ALBはラウンドロビンルーティングアルゴリズムを使用する
  - ALBは未処理のリクエストが最も少ないルーティングアルゴリズムを使用する
  - ALBの**スティッキーセッション** :
    - HTTP Cookieを使用してトラフィックを送信するサーバ間で接続を記憶する
- **NLB** (Network Load Balancer)
  - NLBはトランスポート層 (第4層) の負荷分散で使用される**L4ロードバランサ**
  - NLBはALBと同様にリスナーやロードバランスされる対象（EC2やECSなど）をターゲットグループとして設定する
  - NLBの特徴
    - 高可用性・高スループット・低レイテンシ
    - クライアントIPとポートの保持
    - ロードバランサーのIPアドレスが固定
    - 暖機運転 (Pre-Warming) 申請が不要 : ALBでは通常のスケーリングで間に合わない見込みの時は事前に暖機運転申請が必要
    - VPCエンドポイント (Private Link) のサポート : 異なるVPCのWebサービスをインターネットを経由せずにアクセスしたい場合に使用
  - NLBそのものにセキュリティグループは設定できない
    - ターゲットグループにECSを選択して動的ポートマッピングを使う場合は、アクセス可能なポートを制限するなどの注意が必要
  - TLSオフロード（TLS終端）のサポート
  - **SSLパススルー通信** : クライアント証明書によるユーザ認証をする場合に有効化する
  - 振り分け可能なプロトコルは TCP、UDP、TLS
  - NLBはフローハッシュルーティングアルゴリズムを使用する
    - プロトコル、送信元IPアドレスと送信元ポート、宛先IPアドレスと宛先ポート、TCPシーケンス番号 が同じ場合は常に同じターゲットに送信される。
  - NLBの**スティッキーセッション** :
    - クライアントの送信元IPに基づく
  - NLBは毎秒数百万のリクエストを処理できる
  - NLBはスタティックおよびエラスティックIPアドレスをサポート
  - NLPは送信元IPアドレスを保持する
  - リクエストを特定のポートへ転送（ポートフォワード）できる
- その他のロードバランサ
  - GLB (Gateway Load Balancer) : インターネットゲートウェイまたは仮想プライベートゲートウェイにおけるトラフィックを別のVPCネットワークへ中継する
    - ユースケースとしては、主にゲートウェイを通じて入ったトラフィックに攻撃が含まれていないか、EC2インスタンスで構成されるネットワークへ転送し、検出・対応するため
  - CLB (Classic Load Balancer) : L4とL7の両方のロードバランサ機能を提供する旧サービス。使用は非推奨

### Amazon ECS (Elastic Container Service)

- **ECS**とは、Dockerコンテナをスケーラブルかつ簡単に実行・停止・管理できるコンテナ管理サービス
  - 用語
    - コンテナ : ホストとなるLinux OS上でOSイメージとアプリをひとまとめにして1プロセスとして動作するもの
    - Docker : コンテナを実行する代表的なソフトウェア
    - コンテナオーケストレーション
      - データプレーン : コンテナが実行されるリソース
      - コントロールプレーン : コンテナを管理するオーケストレータ
  - ECSの構成要素は「クラスタ」「タスク」「サービス」の3つからなる
  - **クラスタ** :
    - Dockerコンテナを実行するためのデータプレーンの実態となる1つ以上のEC2インスタンス群
    - Fargateではクラスタ自体がAWSマネージドサービスとして管理される
  - **タスク** :
    - Dockerコンテナイメージ設定と、イメージから生成されるコンテナにおけるクラスタ上の実行設定をセットにしたもの (docker-composer.ymlのようなもの)
    - タスク定義の例 :
      ```json
      {
        "family": "webserver",
        "containerDefinitions": [{
          "name": "web",
          "image": "nginx",
          "memory": "100",
          "cpu": "99"
        }],
        "requiresCompatibilities": [ "FARGATE" ],
        "networkMode": "awsvpc",
        "memory": "512",
        "cpu": "256"
      }
      ```
    - ECSタスク定義項目 :
      - タスクとコンテナの定義設定 :
        - タスク定義名 : 任意の名前を設定する
        - タスクロール : アプリの処理内容に応じて必要なIAMロールを設定する
        - ネットワークモード : コンテナとクラスタ間のネットワーク変換方法。none / bridge (EC2のデフォルト値) / host / awsvpc (Fargateのデフォルト値) から選択する
      - タスクの実行IAMロール :
        - タスク実行ロール : タスク実行用エージェントのIAMロール。最低限 AmazonECSTaskExecutionnRolePolicy が必要
      - タスクサイズ :
        - タスクメモリ : コンテナに割り当てるメモリサイズ
        - タスクCPU : コンテナに割り当てるCPUユニット数
      - コンテナの定義 :
        - コンテナ名 : 任意の名前を設定する
        - イメージ : コンテナイメージの識別子「*repository-url*/*image-name*:*tag*」
        - プライベートレジストリの認証 : Secrets Managerの認証情報を利用したプライベートレジストリの認証設定
        - メモリ制限 : コンテナが使用するメモリの制限を指定する
      - コンテナの定義 :
        - ポートマッピング : ホストOSのポートとコンテナに割り当てるポートのマッピング設定
        - 環境変数 : コンテナへ渡す環境変数を設定する。valueFromオプションを使うとSystem Manager Parameter Storeから値を取得できる
      - ボリューム :
        - ボリューム : コンテナにアタッチするストレージの設定
  - **サービス** :
    - タスク定義された内容に基づき実際に実行されるコンテナ
    - EC2と同様に各コンテナにAWSサービスにアクセスするためのIAMロールを割り当てることができる（最小権限の原則）
    - ECSサービスの定義項目 :
      - サービスの設定 :
        - 起動タイプ : FARGATE / EC2 / EXTERNAL のいずれかを選択する
        - タスク定義 : サービスとして実行するタスク定義を指定する
        - クラスタ : サービスを実行するクラスタを選択する
        - サービスタイプ : REPLICA / DAEMON のいずれかを選択する
          - REPLICAは、クラスタ全体で「タスク数」として指定した数のコンテナを実行するオプション
          - DEAMONは、ECSクラスタ1台につき1つのサービスを実行し、クラスターインスタンスの増減に合わせて実行コンテナのサービスを増減させるオプション
        - タスク数 : クラスタで実行するコンテナ数
        - 最小ヘルス数 : コンテナの最小実行数の割合を設定する
        - 最大率 : コンテナの最大実行数の割合を設定する
      - デプロイメント :
        - デプロイメントタイプ : コンテナをアップロードするときの戦略（ローリングアップデート または Blue/Greenデプロイメント）を選択する
      - タスクの配置 :
        - 配置テンプレート : コンテナを配置する戦略を選択する（起動タイプがEC2のとき）
          - タスク配置戦略
            - **binpack** : ECSクラスタのCPUやメモリ状況に基づき、使用中のコンテナインスタンスの数が最小になるように配置する
            - random : ECSクラスタに対し、タスクをランダムに配置する
            - **spread** : 指定した値に基づいて、タスクを均等に配置する
            - 例）AZバランス-スプレッドは、AZはspread（AZ全体で分散し）、インスタンスIDもspreadで配置する
            - 例）AZバランス-ビンパックは、AZはspread（AZ全体で分散し）、メモリに基づいてタスクをbinpackで配置する
          - タスク配置制約
            - **distinctInstance** : 各タスクを別々のクラスタのインスタンスに配置する
            - **memberOf** : 特定の条件を満たすクラスタのインスタンスにタスクを配置する。クラスタークエリ言語で条件式を定義する
        - ※共有ストレージを使いながら複数のコンテナで処理を並列実行する場合は、各リソースができるだけ近い位置にあった方が高速化につながる
      - ネットワーク構成 :
        - クラスターVPC : コンテナを配置するクラスターのVPC
        - サブネット : コンテナを配置するサブネット
        - セキュリティグループ : ECSクラスタに割り当てるセキュリティグループ
      - ロードバランシング :
        - ロードバランサーの種類 : ECSコンテナに処理を分散させるロードバランサの設定
      - ヘルスチェック :
        - ヘルスチェックの猶予時間 : ECSコンテナを起動してからのヘルスチェックの猶予時間の設定
      - サービスの検出 :
        - サービス検出統合の有効化 : Route53を使ったサービス検出・ディスカバリー機能を有効化するオプション
      - Auto Scaling :
        - Service Auto Scaling : Auto Scaling機能を有効化するときのオプション

### Amazon ECR (Elastic Container Registry)

- **ECR**とは、AWSが提供する完全マネージド型のDockerコンテナレジストリ
  - ECRはコンテナイメージを非公開にできる
  - ECRはAWSネットワークからのプルリクエストは無料でできる

### Amazon EKS (Elastic Kubernetes Service)

- **EKS**とは、Kubernetesの実行環境を提供するマネージドサービス
  - Kubernetesをすでに使用している場合は、Amazon EKSを使用してAWSクラウドのワークロードをオーケストレーションできる
  - Amazon EKSとAmazon ECSの違い :
    - ECSエージェントがインストールされ、構成された EC2 インスタンスは「コンテナインスタンス」と呼ばれるが、Amazon EKSでは「**ワーカーノード**」と呼ばれる
    - ECSコンテナは「タスク」と呼ばれるが、Amazon EKSでは「**ポッド**」と呼ばれる
    - Amazon ECSは「AWSネイティブテクノロジー」で実行されるが、Amazon EKSは「**Kubernetes**」の上で実行される

### AWS Copilot

- **AWS Copilot**とは、AWSでコンテナ化されたアプリケーションを素早く起動し、管理することを可能にするコマンドラインインターフェイス (CLI) 
  - Copilotを使うことで、Amazon Elastic Container Service (ECS)、AWS Fargate、および AWS App Runner でのアプリケーションの実行が簡素化される

### Amazon RDS (Relational Data Service) 

- **RDS**とは、構築や運用を容易にするリレーショナルデータベースサービス
  - RDSでサポートされる内容 :
    - 拡張性 : スケールアップ・スケールダウンが容易にできる。保存ストレージもDBを停止することなく増やすことができる
    - 高可用性 : AZをまたいだ冗長化構成による自動フェイルオーバーに対応
    - DBバックアップ : 自動バックアップデータをS3へ保存する。1日1回のDBスナップショットと、5分間隔のトランザクションログの保存
    - DBパッチ適用 : メンテナンスウィンドウで指定した時間帯にソフトウェアアップデートが自動的に適用される
    - OSパッチ適用 : メンテナンスウィンドウで指定した時間帯にOSアップデートが自動的に適用される
  - **リードレプリカ** : 読み取り専用DB。読み込みアクセスを分散して全体のパフォーマンスを向上させるため
    - 読み込みアクセスが多い場合、最大5台までリードレプリカを構築してリクエストをオフロードする（負担を肩代わりする）ことができる。ただし、常に最新のデータを取得できるとは限らない
    - オプションで任意のタイミングでリードレプリカをスタンドアロンDBへ昇格できる
    - クロスリージョンレプリカ : 災害対策用に別リージョンにレプリカを作成する
      - 複数のリージョンにあるRDSのレプリカを1つのリージョンにまとめることでアクセス管理が簡単になるといった使い方もできる
  - サポートされているAmazon RDSエンジン
    - 商業: Oracle、Microsoft SQL Server
    - オープンソース: MySQL、PostgreSQL、MariaDB
    - クラウドネイティブ: Amazon Aurora
  - DBインスタンス
    - スタンダード (m) : メモリ用に最適化された汎用インスタンス
    - Memory Optimized (r, x) : メモリを大量に消費するアプリケーション
    - バースタブル (t) : パフォーマンスに最適であり、CPU 使用率をフルにバーストできる
  - VPC内でのAmazon RDS
    - DBインスタンスを作成するとき
      - データベースが所属するAmazon VPCを選択する
      - DBインスタンスを配置するサブネット（DBサブネットグループ）を選択する
  - バックアップデータ :
    - **自動バックアップ**
      - デフォルトで設定されている
      - DBインスタンス全体とトランザクションログがバックアップされる
      - 自動バックアップは0～35日間保持できる
    - **マニュアルスナップショット**
      - 自動バックアップを35日以上保持する場合は、マニュアルスナップショットを使用する
  - Amazon RDSマルチAZによる冗長性
    - 可用性を向上させるために、Amazon RDS Multi-AZ では、データベースの 2 つのコピーが実行され、そのうちの 1 つがプライマリロールにあることが保証される
    - プライマリデータベースが接続を失うなど、可用性の問題が発生した場合、Amazon RDS は自動フェールオーバーを発生させる

### Amazon Aurora

- **Aurora**とは、完全マネージド型のリレーショナルデータベースエンジン
  - Auroraの特徴 :
    - RDBの一貫性を持つ
    - RDSのリードレプリカ機能を持つ
    - Quorumに基づく結果整合性でデータを分散して保存するストレージクラスノードクラスタを採用して高可用性を実現する
    - より高速なデータ同期・フェイルオーバー
  - Auroraの機能
    - 自動ストレージ拡張
    - エンドポイント :
      - **クラスターエンドポイント** : プライマリインスタンスと通信するためのエンドポイント
      - **読み取りエンドポイント** : リードレプリカと通信するためのエンドポイント
      - **カスタムエンドポイント** : ユーザがワークロードに応じて任意にレプリカを設定できるエンドポイント
    - リードレプリカのオートスケーリング
    - DBバックアップ機能
    - クロスリージョンデータベースの性能向上・低価格化
    - パラレルクエリ : 多数のストレージノードで並列にクエリを実行する
- **Aurora Serverless**
  - 管理する際はキャパシティユニットと呼ばれる使用量を指定する（DBサーバをプロビジョニングして管理しない）
  - リクエストの負荷に応じてインスタンスタイプの変更や起動停止を自動実行できる
  - 自動起動停止 : オンデマンドで起動し、使用していないときはシャットダウンする
  - インスタンスタイプ変更 : リクエスト負荷に応じて自動スケールアップ・スケールダウンする
  - Data API : Aurora DBクラスにVPC外からアクセスするためのエンドポイントを作成する
  - 適切なデータベースサービスを選択すること。AWSのデータベースサービスは以下の通り :
    - リレーショナル : Amazon RDS, Amazon Aurora, Amazon Redshift（一般的なアプリケーション）
    - キーバリュー : Amazon DynamoDB（NoSQL、トラフィックの多いウェブアプリ）
    - インメモリ : Memcached 専用 Amazon ElastiCache, Redis 専用 Amazon ElastiCache（キャッシュ、セッション管理）
    - ドキュメント : Amazon DocumentDB (MongoDBの互換、コンテンツ管理)
    - ワイドカラム : Amazon Keyspaces (Apache Cassandra用、分散型のNoSQLデータベース)
    - グラフ : Amazon Neptune
    - 時系列 : Amazon Timestream
    - 台帳 : Amazon QLDB (暗号的に検証可能なトランザクションログを提供するDB、経済活動や財務活動の履歴を記録)

### Amazon ElastiCache

- **Amazon ElastiCache**とは、セットアップ・運用・拡張が容易なマネージドキャッシュサービス
  - RDBに保存してあるマスターデータのキャッシュ化や、複数のアプリケーションサーバでセッションの共有をするために利用する
  - MemcachedとRedisをベースとして2種類のエンジンをサポートしている
  - キャッシュ戦略
    - **遅延読み込み** (Lazy loading) : キャッシュにレコードがないときのみ、データベースからレコードを取得する
      ```c
      customer_record = cache.get(customer_id)
      if (customer_record == null)
        customer_record = db.query("SELECT * FROM Customers WHERE id = {0}", customer_id)
        cache.set(customer_id, customer_record)
      ```
- **ElastiCache for Memcached**
  - Memcachedをベースとしたインメモリ型キーバリューストア
  - シンプルなキーバリュー型のデータをキャッシュして、低レイテンシで参照できる
  - マルチスレッドでアクセス可能な共通データをキャッシュできる
  - リクエスト量に応じてノードをスケールアウト・スケールインする
  - クラスタへのアクセスには、AWSが提供しているAuto Discoveryに対応したクライアント (ElastiCache Cluster Client) を使う
    - C#, PHP, Javaのみ利用可能
    - それ以外の言語では、どのノードにデータが保存されているかをアプリケーション側で判断してから通常のクライアントライブラリを使ってキャッシュノードに直接アクセスする
- **ElastiCache for Redis**
  - Redisをベースとしたインメモリ型キーバリューストア
  - クラスタモードが無効のときは、シャーディング（データをいくつかのグループで分割して保存すること）を行わない代わりに、リードレプリカを別のAZに配置する
  - クラスタモードが有効のときは、シャーディングを行う。データの保存先はスロット（キーのハッシュ値）によって決まる
  - その他の機能
    - 自動バックアップ・リストア
    - ダウンタイム0のクラスタリサイズ
    - グローバルデータストア : クロスリージョン間のレプリケーション機能

### Amazon MemoryDB for Redis

- **Amazon MemoryDB for Redis**とは、マイクロ秒の読み取り、1桁台前半のミリ秒の書き込み、スケーラビリティ、エンタープライズセキュリティを備え、耐久性に優れたデータベース
  - MemoryDBは99.99%の可用性を実現し、データを失うことなくほぼ瞬時に復元できる

### Amazon S3 (Simple Storage Service)

- **S3**とは、容量無制限で高い耐久性・性能を備えるスケーラブルなオブジェクトストレージサービス
  - Amazon S3では、バケットと呼ばれるコンテナにオブジェクトを保管する
  - S3はオブジェクトストレージのため、要求に応じて一意の識別子を使用してオブジェクトを検索するフラットな構造にデータを保管する
  - 用語
    - **オブジェクト** : ファイルと同じ単位で保存する実態データ。1オブジェクトあたり最大5TBまで
    - **バケット** : オブジェクトを格納するルートとなる保存場所。デフォルトでは各アカウントあたり100バケットまで作成可能
    - **キー** : オブジェクトを指し示すパス。キーにスラッシュを使うことで階層構造を表現できる。「バケット名 + キー + バージョン」で必ずユニークになる
    - メタデータ : オブジェクトに付与される名前と値のペアセットとなる属性情報。AWS固有のメタデータと、ユーザが任意に設定できるメタデータの2種類がある
    - バージョン : 作成時・更新時にS3によってオブジェクトに付与されるID
  - S3の使用方法
    - マネージメントコンソール / AWS CLI / AWS SDK : 他のAWSサービスと同様
    - REST API / SOAP API : HTTPS経由でファイルのアップロードが可能
  - URLの例 :
    - `https://<backetname>.s3.amazonaws.com/2006-03-01/SampleFile.txt`
    - バケット名はすべてのAWSアカウントに対して一意である必要がある
  - Amazon S3のユースケース
    - バックアップとストレージ : Amazon S3は冗長性が高い
    - メディアホスティング : オブジェクトは無制限に保存でき、個々のオブジェクトは最大 5 TB まで保存できる
    - ソフトウェア配信
    - データレイク
    - 静的ウェブサイト : HTML、CSS、クライアントサイドスクリプトの静的ウェブサイトのホスティング
    - 静的コンテンツ : ウェブ上で任意のオブジェクトにいつでもアクセス可能
  - リソースに適した接続オプションを選択する
    - Amazon S3のすべてのものはデフォルトでプライベートになる
    - 公開リソースにすると、インターネット上の誰もがS3のリソースを見ることができる
  - ストレージクラス
    - 下に行くほどコストが低くなり、ほとんどアクセスされない情報を保存するのに向いている
      - **S3 標準** : デフォルトのストレージ
      - **S3 Intelligent-Tiering** : アクセスの頻度に応じて自動的にストレージタイプを変更するストレージ
      - **S3 標準 - 低頻度アクセス (S3 標準-IA)** : 取り出しに料金が発生するストレージ。アクセス頻度が低いデータの格納向け
      - **S3 One Zone - 低頻度アクセス (S3 One Zone-IA)** : 単一のAZに保存されるため可用性が低い。取り出しにも料金が発生する。
      - **S3 Glacier** : 取り出しに料金が発生するのに加えて、取り出しに時間がかかる。アーカイブデータの格納向け
      - **S3 Glacier Deep Archive** : 最も低コスト。年に1, 2回しかアクセスされないようなデータの格納向け。取り出しは最大12時間かかる
  - 通常オブジェクトは3箇所以上のAZに分散して配置されるため、高可用性を維持できる（S3 One Zoneは1箇所のAZのみに配置）
  - セキュリティ保護
    - アクセスコントロール
      - **ユーザポリシー** (IAMポリシー)
        - IAMユーザに対してアクセス制御を設定する。実体はIAMポリシーのアクセス権限と同じ
      - **バケットポリシー**
        - バケットに対してアクセス制御を設定する (JSON形式)。クロスアカウントでのアクセス権限を設定したいときに利用する。実体はIAMポリシーのアクセス制御と同じ
        - IAMポリシーのCondition要素を使って、IPアドレスやHTTPヘッダのRefferrerやMFAを使ったアクセス制御もできる
          ```json
          {
            "Version":"2012-10-17",
            "Statement":[{
              "Sid":"PublicRead",
              "Effect":"Allow",
              "Principal": "*",
              "Action":["s3:GetObject"],
              "Resource":["arn:aws:s3:::employeebucket/*"]
            }]
          }
          ```
        - IAMポリシーはユーザー、グループ、ロールに付与されるのに対して、S3バケットポリシーはS3バケットにのみ付与される
      - **ACL (Access Control List)**
        - バケットおよびオブジェクトに対してアクセス制御を設定する。AWSアカウントに所属しない不特定多数のユーザへのアクセス権限の設定に利用する。
        - ACLには「被付与者」と呼ばれる個別にアクセス権を付与できる対象が4つ存在する
          - バケット・オブジェクト所有者
          - All Usersグループ : 不特定多数の全てのユーザ
          - Authenticated Usersグループ : 認証されたAWSアカウントのユーザ
          - Log Deliveryグループ : サーバアクセスログを記録するためのグループ
        - ACLのアクセス許可
          - READ (s3:ListBucket, s3:GetObject)
          - WRITE (s3:PutObject)
          - READ_ACP (s3:GetBucketAcl, s3:GetObjectAcl) : ACLの読み取り
          - WRITE_ACP (s3:PutBacketAcl, s3:PutObjectAcl) : ACLの書き込み
          - FULL_CONTROLL : 上記の全て
        - 事前定義されたACL（使用は非推奨）:
          - プライベート : 被付与者「オブジェクトの所有者」に対してFULL_CONTROLを与える
          - パブリックアクセス : 被付与者「オブジェクトの所有者」へFULL_CONTROLを与え、被付与者「All Usersグループ」に対してREADを与える
    - クロスアカウントのとき
      - バケットの所有者Aはバケットにバケットポリシーを設定し、アクセスユーザのBにはユーザポリシーを設定する
    - ブロックパブリックアクセス
      - 意図しないパブリックアクセスを抑止する機能
      - バケットを作成する際にコンソール上で選択できる
      - オプション名 :
        - BlockPublicAcls : パブリックアクセスを許可するACL設定の更新や、パブリックアクセス設定されたオブジェクトのアップロードを許可しない
        - IgnorePublicAcls : パブリックアクセスを許可するACLが設定されたバケットやオブジェクトが存在しても、パブリックアクセスを無視する
        - BlockPublicPolicy : パブリックアクセスを許可するバケットポリシーの設定・更新を許可しない
        - RestrictPublicBuckets : パブリックアクセスを許可するバケットポリシー設定が存在しても、パブリックアクセスおよびクロスアカウントアクセスを無視する
    - **VPCエンドポイント**
      - VPCのプライベートサブネットからインターネットを経由しないで直接アクセスしたいときは、S3エンドポイントを作成する
      - 以下のアクセスポリシーをVPCエンドポイントにアタッチする
        ```json
        {
          "Effect": "Allow",
          "Action": ["s3:ListBucket", "s3:GetObject", "s3:PutObject"],
          "Resource": ["arn:aws:s3:::example-bucket", "arn:aws:s3:::example-bucket/*"]
        }
        ```
    - アクセスポイント : バケットにアタッチする名前付きのネットワークエンドポイント
      - アクセスポイントポリシーでアクセス制限をすることができる
    - **署名付きURL** (Pre-signed Object URL)
      - AWS SDKやCLIを使って、一時的にS3へアクセス可能なURLを発行する機能
    - 暗号化
      - SSE-S3 : S3が管理するキーで暗号化。キーのローテーションをしないときなどに利用
      - SSE-KMS : KMSが管理するキーで暗号化。キーのローテーションをするときなどに利用
      - ※S3にアップロードする際に「x-amz-server-side-encryption」ヘッダが含まれていると、サーバ側で暗号化される
        - バケット内のオブジェクトの暗号化を担保するには、バケットポリシーのConditionで当該ヘッダが含まれていないリクエストを拒否すること
  - 静的Webサイトホスティング
    - バケットでS3の静的Webサイトホスティングを有効化すると以下の形式でアクセス可能になる
    - `http://<bucket-name>.s3-website-<region>.amazon.com/`
    - CloudFrontからのHTTP/HTTPSリクエストのみを許可することもできるため、アクセスするユーザのロケーションに応じて高速なアクセスが可能
  - **イベント通知機能**（イベントトリガー）
    - バケットに対する更新が発生したとき、AWS Lambda関数やSQS、SNSに対して通知を行う設定ができる
    - 例）PutObject（アップロード）に対してイベントを設定して、SQS標準キューを通知先として設定する
  - CORS (Cross-Origin Resource Sharing) 機能
    - ブラウザがアクセスしたURLと別のドメインの静的コンテンツを取得できるようにCORSヘッダを付与できる
  - クロスリージョン / 同一リージョンレプリケーション
    - 同一リージョン内の3箇所のAZにデータが複製されて保存される
    - クロスリージョンレプリケーション : 非同期でデータを別のリージョンへ転送する機能
  - **S3バージョニング**（バージョン管理機能）
    - S3バージョニングを使用することで世代管理が可能
    - 偶発的な削除や上書きやアプリケーション障害からのファイルの復元に役立つ
  - **ライフサイクルルール設定**
    - ファイル作成からN日後に、S3標準から低頻度アクセスS3へ移動させることができる
      - 移行アクション : オブジェクトを別のストレージクラスに移行するタイミングの定義
      - 失効アクション : オブジェクトが期限切れになるタイミングを定義
    - 更新日時から一定期間経過したオブジェクトをより低価格のストレージクラスへ変更する
    - 最新のバージョン以外のオブジェクトのストレージクラス変更
    - 有効期限切れや古いバージョンの削除
    - ※ライフサイクルの処理は毎日0:00に自動実行される
  - **オブジェクトロック機能**
    - バケット単位で読み取り専用の期間を設定する機能
    - 2種類のモード :
      - コンプライアンスモード : Rootユーザであってもオブジェクトの削除が一定期間不可能になるモード。ログの改ざんの防止などに利用
      - ガバナンスモード : コンプライアンスモードと同様だが、Lock解除オペレーションによって削除が可能
  - **S3 Transfer Acceleration**
    - S3へのアップロードを高速化するための機能
    - AWSのエッジネットワークを利用したファイル転送を行う
  - リクエスタ支払い機能 : バケットに対してアクセス可能なユーザを特定し、データ転送にかかる費用をユーザ側が負担する機能
  - S3アナリティクス : オブジェクトに対するアクセス状況やデータ量を可視化する機能
  - S3インベントリ : S3に保存されたオブジェクトのリストをCSVやORCファイルで出力する機能
  - サーバログアクセス機能 : S3はCloudTrailを用いたログ監査機能とは別に、バケットに対するアクセスログを記録する機能も提供している
  - Lambda関数のキャッシュ :
    - Lambda環境は、コード内かつハンドラーメソッドの外で初期化処理（DB接続など）を行うことで、後続の呼び出しで同じ初期化処理を再利用できる

### Amazon SNS

- **SNS**とは、スケーラブルなプッシュ配信型メッセージ送信サービス
- クライアントは、以下のサポートされたエンドポイントを使用してSNSトピックにサブスクライブし、発行されたメッセージを受信できる
  - Amazon Kinesis Data Firehose
  - Amazon SQS
  - AWS Lambda
  - HTTP
  - Eメール
  - モバイルプッシュ通知
  - モバイルテキストメッセージ (SMS) 

### Amazon SQS (Simple Queue Service)

- **SQS**とは、ほぼ無限のスケーラビリティを備えたフルマネージドの分散メッセージキューサービス
  - 用語
    - **キュー** : 主にアプリケーション間のメッセージ交換として使用されるテキストデータを一時的に保管し、順序性を持って取り出せる仕組み
    - **プロデューサ** : メッセージをキューに送信するアプリケーション
    - **コンシューマ** : キューからメッセージを取得するアプリケーション
  - SQSのキューの種類
    - **スタンダードキュー** (標準キュー) :
      - 概ね時系列順に処理されるが、順序性はベストエフォート
      - 少なくとも1回は配信され、2回以上配信されることもある（コンシューマ側で処理済みフラグを持つ必要性がある）
      - ほぼ無限のスループットを持つ
    - **FIFOキュー** :
      - 順序性が保証される
      - 1回のみ配信される
      - 最大300件/秒のメッセージの処理が可能
  - キューの作成時の属性
    - キュー名
    - **可視性タイムアウト** : キューから受信したメッセージが他のコンシューマに表示されない時間の長さ。デフォルトは30秒、最大12時間
      - 別のコンシューマがメッセージを取得するとキューのパラメータReceiptHandleの値が書き換えられる
    - メッセージの保持期間 : 最小1分、最大14日間
    - 配送遅延 : 配信する前にSQSが待機する時間。デフォルトは0秒、最大15分。
    - 最大メッセージサイズ
    - メッセージ受信待機時間 : キューが受信リクエストを受信した後、メッセージが使用可能になるまでSQSが待機する時間
    - コンテンツベースの重複排除を有効にする（FIFOキューのみ）
    - 高スループットFIFOの有効化（FIFOキューのみ）
    - 重複排除スコープ（FIFOキューのみ） : プロデューサからの意図しないメッセージの2重送信に対して重複を削除する機能
    - FIFO関連 :
      - **メッセージグループID**（MessageGroupId） : メッセージが所属するメッセージグループを指定するタグ。同じメッセージグループに所属するメッセージは常に厳格な順序で1つずつ処理される（順序性の担保）
      - **メッセージ重複排除ID** : 2重送信による重複メッセージを排除する
  - プロデューサからの送信
    - `aws sqs send-message --queue-url https://sqs.us-east-1.amazonaws.com/*** --message-body 'Message...' --message-attributes send-message.json`
  - コンシューマでのメッセージ受信
    - 流れ
      1. コンシューマからキューに対してポーリングを行う
      2. コンシューマがメッセージを取得したら、処理を行う
      3. コンシューマが処理済みのメッセージをキューから削除する
    - 種類
      - **ショートポーリング** : 分散配置されたSQSサーバの中から「一部」をサンプリングしてポーリングを行い、すぐに応答を返す
      - **ロングポーリング** : 分散配置された「全部」のSQSサーバに対してポーリングを行い、最大20秒の待機時間の後に応答を返す
    - 複数のメッセージをまとめて受信したいときは、ReceiveMessage APIを呼び出す時のパラメータMaxNumberOfMessageの値を大きくする
  - コンシューマでのメッセージ削除
    - `aws sqs delete-message ...`
    - 可視性タイムアウトを過ぎると別のコンシューマがメッセージを取得する可能性があるため、その前に処理済みのメッセージは削除すること
  - **デッドレターキュー**
    - デッドレターキュー : 正常に処理できないメッセージを格納するためのキュー
    - 正常に処理できないメッセージがキューに滞留し続けることを防止するために、滞留して最大受信数を超えたメッセージをデッドレターキューに移動する
    - キューの属性である Redriveポリシー (RedrivePolicy) を設定して、メッセージ処理の失敗回数が設定した「最大受信回数 (maxRecieveCount)」を超えた場合に、メッセージの移動先となる「デッドレターキューのARN (deadLetterTargetArn)」に移動させる
    - デッドレターキューにはデフォルトで4日までメッセージが保存される
  - セキュリティ
    - 暗号化 : SSE-KMSを利用してキュー内に保管されたメッセージを暗号化できる
    - アクセス制御 : IAMによるアクセス制御やキューへのアクセスポリシーのアタッチができる

### Amazon Kinesis

- **Kinesis**とは、連続性のあるデータ（ストリームデータ）を扱うためのサービス
- **Kinesis Data Streams**
  - プロデューサ（データの発生源）から発生するストリームデータを処理し、コンシューマ（データの受信者）へメッセージとして中継するマネージドサービス
  - プロデューサにはAWS IoTやAWS CloudWatchなどがある
  - コンシューマにはKinesis Data Firehose, Kinesis Data Analytics, AWS Glue, AWS Lambda, Amazon EMRなどがある
  - Kenesis Data Streamsプロデューサ
    - プロデューサ
      - AWS SDK / CLIを使用したアプリ
      - Kinesis Producer Library (KPL) を使用したアプリ
      - Kinesis Agent : データを収集してKinesis Data Streamsへデータを簡易的に送信できる
      - サードパーティソフトウェアが提供するクライアントライブラリ
      - Kinesis Data Generator : テストデータを送信できるテストツール
    - AWS IoT : AWS IoTのルールに基づいて、MQTTプロトコルから発生したデータをKinesis Data Streamsへメッセージとして送信できる
    - Amazon CloudWatch : CloudWatch Logsのサブスクリプションフィルタを用いて、収集したログデータをKinesis Data Streamsへ送信できる
  - Kinesis Data Streamsコンシューマ
    - クライアント
      - AWS SDK / CLIを使用したアプリ
      - Kinesis Client Library (Java) を使用したアプリ
      - サードパーティソフトウェアが提供するクライアントライブラリ
    - Kinesis Data Firehose : 受信したデータをS3やAmazon Redshift, Amazon Elasticsearch Serviceなどへ配信するサービス
    - Kinesis Data Analytics : 受信したデータをSQLクエリでリアルタイムに分析できるサービス
    - AWS Lambda : 受信したデータをサーバレスで処理する
    - Amazon EMR : Kinesis用コネクタを使って、Hadoop向けにData Streamsから直接データの読み取りとクエリを実行できる
  - データレコード : データストリームで扱われる個々のデータ
  - **シャード** : データストリームを構成する要素。各シャードには複数のデータレコードを保存できる。
    - シャード分割 : スループットを増やす
    - シャード結合 : スループットを減らす
    - リシャーディング : 作成済みシャードを調整すること
  - パーティションキー : 各データレコードを保存するシャードを決めるためのキー（最大256文字のUnicode文字列）
  - シーケンス番号 : 全シャード間でユニークとなり、順序性を維持するための番号
  - **KCLワーカー** : Kinesis Client Library (Java) を使ったクライアントアプリで、コンシューマとなるサービス
    - シャードの数を超えるKCLワーカーを配置しても、それ以上の分散処理はできない。1シャードに対して1ECインスタンス（1KCLワーカー）が適切
- **Kinesis Data Firehose**
  - ストリームデータを配信するサービス
  - Kinesis Data Firehoseを使うことで、コンシューマアプリケーションの実装なしで、ターゲットに配信できる
  - 配信先となるサービス
    - AWSマネージドサービスの S3, Amazon Redshift, Amazon Elasticsearch Service
    - アードパーティサービスの Splunk, Datadog, New Relic
  - 配信データのプロデューサとして選択する代表的なサービス
    - Kinesis Data Streams
    - AWS SDK / CLIを使用したアプリケーション
    - Kinesis Agent
    - AWS IoT
    - Amazon CloudWatch
- **Kinesis Data Analytics**
  - 格納されたデータをリアルタイム分析できるサービス
  - Kinesis Data StreamsやKinesis Data Firehoseの解析ができる
  - 分析にはSQLステートメントを記述することで対象データを出力できる
  - 分析対象をLambdaで前処理できる
- **Kinesis Video Streams**
  - 動画・音声ストリームデータの収集や、ストリーミング・ライブ配信・オンデマンド再生を行うためのサービス
    - メディア形式による取り込み : Kinesis Video Streams Producer SDKを使った実装
    - WebRTCによる取り込み : オンラインビデオ会議などに向いている

### AWS AppSync

- **AppSync**とは、GraphQL APIの完全マネージド型サービス
  - **GraphQL** : API向けに作られたクエリ言語
  - サーバーレスのGraphQLおよびPub/Sub APIを作成できる
  - クライアントがGraphQLサブスクリプション操作を呼び出すと、セキュアなWebSocket接続が自動的に確立され、アプリケーションはデータソースからサブスクライバーにデータをリアルタイムで配信できる

### AWS Step Functions

- **Step Functions**とは、分散アプリケーションとマイクロサービスを「ステートマシン」と呼ばれるサーバーレスな「ワークフロー」を使って制御（オーケストレーション）・可視化するサービス
  - LambdaなどのAWSサービスを呼び出すことができる
  - 処理の順序、並列実行、条件分岐、失敗時のリトライなどをワークフローとしてJSONで定義できる
  - Step Functions で作成するワークフローは、サービスの統合を利用して200以上のAWSのサービスに対し接続および調整を行うことができる
    - Step FunctionsとAmazon API Gatewayの連携
    - AWS Step FunctionsとAmazon EventBridgeの連携
    - AWS Step FunctionsとAWS Lambda
  - ユースケース :
    - データ処理 :
      - 複数のデータベースのデータを統合して統一レポートを作成
      - 大規模なデータセットを便利な形式に改良および縮小
      - S3バケット内の数百万のファイルを高い同時実行性ワークフローで反復処理
      - マルチステップ分析や機械学習ワークフローを連携
    - DevOps, ITオートメーション: 継続的インテグレーション、継続的デプロイのためにツールの構築
    - eコマース : 注文のフルフィルメントや在庫追跡など、ミッションクリティカルなビジネスプロセスの自動化
    - ウェブアプリケーション : 強力なユーザー登録プロセスとサインオン認証の実装

### AWS Amplify

- **Amplify**とは、モバイルアプリやWebアプリ開発のためのプラットフォーム
  - CLIで簡単にバックエンドを構築できる（Cognitoによる認証認可、DynamoDBやLambdaなどの処理、AppSyncなどのAPI）

### AWS Config

- **AWS Config**とは、リソースの構成を評価、監査、診断するサービス
  - AWS、オンプレミス、その他のクラウド上のリソースの設定と関係を継続的に評価、監査、評価できる
  - 運用上のトラブルシューティングと変更管理を合理化する

### その他の開発関連サービス

- **AWS App Runner** : コンテナアプリケーションを簡単にデプロイするサービス


## 第5章 リファクタリング関連サービス

### Amazon CloudFront

- **CloudFront**とは、CDN (Contents Delivery Network) の機能を持つマネージドサービス
  - CloudFrontの構成要素
    - **ディストリビューション** (Distribution) : ドメイン単位の設定。WebACL、TLS証明書、セキュリティポリシー、ロギングなど
      - **オリジン** (Origin) : オリジン（原本）サーバとの接続の設定。オリジンドメイン名・パス名、カスタムヘッダなど
      - **ビヘイビア** (Behavior) : エッジサーバの振る舞いの設定。パスパターン、キャッシュポリシー、ビューワー接続設定など
  - キャッシュ設定
    - キャッシュ : URLやHTTPヘッダ、クエリ文字列、Cookieパラメータなどの任意の複数の組み合わせで完全一致した場合に返信データを再利用できる
    - オリジンサーバはHTTPレスポンスの「Cache-Control」ヘッダでキャッシュ期間を指定する
      - 即時反映させたい（キャッシュを利用させない）ときは、Cache-Controlでmax-age=0かExpiresヘッダに過去の日時を指定する
    - Cache-Controlがないときは、CloudFrontのビヘイビアで設定したデフォルトTTLが有効になるように設定する
    - 設定方法一覧 :
      - Cache-Controlヘッダにmax-age値を指定
      - Cache-Controlヘッダにs-maxage値を指定
      - Cache-Controlヘッダなし＆CloudFrontのデフォルトTTLがキャッシュ期間として有効
      - Expiresヘッダに日時を設定
      - Cache-Controlヘッダに"no-cache"または"no-store"を設定することで、キャッシュを無効化できる
    - **キャッシュの無効化**
      - コンソール上やCLIからファイル名（ワイルドカード指定も可能）を指定してキャッシュを無効化 (Invalidation) できる
  - セキュリティ
    - 通信の暗号化 : cloudfront.netドメインのTLS証明書を標準で利用可能
      - AWS Certification Managerで発行した独自のTLS証明書を設定することも可能。ただし、リージョン「us-east-1（米国東部：バージニア北部）」で証明書を作成する必要がある
    - **署名付きURL/Cookie** : コンテンツへのアクセス制御ができる。
      - 署名付きURL : 単一のコンテンツに対するアクセス制御
      - 署名付きCookie : アクセスするユーザに対するアクセス制御
      - ※署名付きURLと署名付きCookieを作成できる署名者は「信頼されたキーグループ」を使用すること。信頼されたキーグループに対して公開鍵を追加し、ビヘイビアの設定のビューワー接続で信頼されたキーグループを指定する
    - フィールドレベルの暗号化 : クレジットカード番号やセキュリティ秘匿データなどをサーバ側のログに残さないようにするときに有効な機能
    - AWS WAF (Web Application Firewall) やAWS Shield (DDoS攻撃の緩和) との連携
    - ファイル圧縮 : Gzip/Brotli形式で圧縮してから転送
    - オリジンフェイルオーバ : オリジンを複数作成して、プライマリオリジン・セカンダリオリジンをまとめたオリジングループを構成できる
    - 地域制限（許可リスト・拒否リスト）
    - **Lambda@Edge** : CloudFrontのエッジサーバで動作するLambda関数。動的なページ作成など
      - **ビューワーリクエスト** : ビューワーからCloudFrontがリクエストを受信したときに実行される処理 (Lambda関数)。A/Bテストのためのリクエストの書き換えなど
      - **オリジンリクエスト** : CloudFrontからオリジンへ転送するときに実行される処理 (Lambda関数)。ビューワーに近いリージョンのS3バケットに書き換えるなど
      - **オリジンレスポンス** : オリジンからCloudFrontがレスポンスを受信したときに実行される処理 (Lambda関数)。レスポンスの画像イメージをリサイズするなど
      - **ビューワーレスポンス** : CloudFrontがビューワーへレスポンスを返す前に実行される処理 (Lambda関数)。レスポンスヘッダの値を書き換えるなど
    - CloudFront Functions : Lambda@Edgeよりも軽量な処理を実行できる

### Auto Scaling

- **Auto Scaling**とは、リソース使用量を検知して自動的にリソースを増減される機能
  - スケーリングの種類 :
    - 垂直スケーリング
      - アクティブ／パッシブ（サーバのサイズを大きくする）
    - 水平スケーリング
      - アクティブ／アクティブ（サーバの台数を増やす）
  - 構成要素
    - Auto Scaling Group : インスタンス配置数の最小値、最大値、希望値、ヘルスチェックの方法を設定
    - Launch Configuration : 起動ルールの設定
    - Launch Template : 起動テンプレートの設定
    - Scaling Plan : スケールするルールの設定。代表例は以下
      - 最小台数の維持 (Auto Healing) : 障害が発生したインスタンスを切り離して新たなインスタンスを立ち上げる
      - 手動スケーリング : 手動でインスタンスを立ち上げる
      - **スケジューリング** : 指定した日時にスケーリングする
      - **動的スケーリング** : ルールに基づいてスケーリングする
        - シンプルスケーリングポリシー : 1つのメトリクスが条件を満たすとスケーリングを行う
        - **ステップスケーリングポリシー** : 複数のメトリクスを設定でき、段階的にスケーリングを行う（メトリクスが1つのときでも推奨）
        - **ターゲット追跡スケーリングポリシー** : 定められたメトリクス (ネットワークIOなど) を維持するようにEC2インスタンス数を調整する
      - **予測スケーリング** : 2週間分のメトリクスを分析して時間帯別の需要を予測して自動的にスケーリングする（すぐに開始はできない）
  - スケーリングされたインスタンスのライフサイクル
    - Pending : インスタンスの起動や初期化が処理中
    - InService : インスタンスが正常起動
    - Terminating : インスタンスの終了処理中
    - Terminated : インスタンスが終了
    - Detaching : インスタンスがユーザ操作によってAuto Scaling Groupからデタッチ処理中
    - Detached : インスタンスのデタッチ処理が完了
    - Entering Standby : インスタンスがユーザ操作によってStandbyへ移行中
    - Standby : インスタンスがAuto Scaling Groupで管理されながらも一時的に削除されている状態。インスタンスの設定変更をするため
  - **EC2 Auto Scaling**
    - モニタリングして閾値を超えたときに自動でEC2インスタンスを起動させる。閾値を下回ったらEC2を停止させる
    - EC2 Auto ScalingとELB : ELBはヘルスチェック機能を使って、各インスタンスと通信して、どこにトラフィックをルーティングするか決める
    - 監視にはAmazon CloudWatch のメトリクスとアラームを利用している
    - コンポーネントの種類
      - テンプレートまたは設定の起動 : 自動的にスケーリングされるリソース
      - EC2 Auto Scaling グループ : リソースの展開場所
      - スケーリングポリシー : リソースの追加または削除のタイミング
    - **起動テンプレート**
      - EC2インスタンスを作成するためのパラメータ群を定義したもの
      - AMIのID、インスタンスタイプ、セキュリティグループなど
      - EC2 Auto Scalingで必要
    - **EC2 Auto Scalingグループ**
      - 最小数 : Auto Scalingで実行されるインスタンスの最小数
      - 最大数 : Auto Scalingで実行されるインスタンスの最大数
      - 希望する容量 : 最小数〜最大数の間の値を指定する
    - スケーリングポリシーによる自動化
      - **シンプルスケーリングポリシー** (単純なスケーリングポリシー) : CloudWatchアラームを使用したスケーリング
      - **ステップスケーリングポリシー** : CPU使用率の段階毎に起動するインスタンス数が決定する
      - **ターゲット追跡スケーリングポリシー** : アプリケーションの平均 CPU 使用率、平均ネットワーク使用率 (入出力)、リクエスト数に基づいてスケーリングする
  - Application Auto Scaling : APIリクエスト数の基づいてAWSサービスをスケーリングする機能。以下のサービスでサポートされている。
    - AppStream 2.0フリート : ストリーミングを実行しているインスタンス群（フリート）をユーザ数に応じて自動的にスケールする
    - Aurora DBクラスタ : メトリクスに応じてAuroraリードレプリカを自動的にスケールする
    - Amazon Comprehend : 機械学習でテキスト内の固有名詞・キーワード抽出や感情分析を行う自然言語処理サービス
    - Amazon DynamoDB : テーブルとグローバルセカンダリインデックスに対してキャパシティユニットを動的にスケールする
    - Amazon EMR (Elastic Map Reduce) クラスタ : ビックデータ処理プラットフォームのサービス
    - Amazon ECS : AutoScalingが設定可能
    - Amazon Keyspaces : Apache Cassandraのマネージドサービス（NoSQL）
    - AWS Lambda : Lambda関数の同時実行数
    - Amazon MSK (Managed Service for Kafka) クラスタストレージ
    - Amazon SageMaker : 機械学習サービス Safe Maker の学習モデルをデプロイするインスタンスをAuto Scalingできる
    - EC2スポットインスタンスのリクエスト : スポットインスタンス（廉価な価格のEC2）でもAuto Scalingできる


## 第6章 監視関連サービス

### Amazon CloudWatch

- **CloudWatch**とは、AWSクラウド監視のためのサービス
  - CloudWatchの仕組み
    - 基本モニタリングは無料。メトリクスごとに1つのデータポイントを5分間隔でCloudWatchに送信する
    - 詳細モニタリングは料金が発生するが、より細かい間隔でメトリクスをCloudWatchに送信できる
- **CloudWatch Metrics** : リソースのパフォーマンスメトリクス（CPU, メモリなど）を収集し表示する機能
  - メトリクス : システムのパフォーマンスを表す時系列データ
    - **標準メトリクス**
      - CPUUtilization (CPU使用率)
      - DiskRead/WriteOps (Disk読み書き回数)
      - DiskRead/WriteBytes (Disk読み書きバイト数)
      - NetworkIn/Out (ネットワーク送受信バイト数)
      - EBSRead/WriteOps (EBS読み書き回数)
    - **カスタムメトリクス** :
      - EC2インスタンス内などで独自のメトリクスをCloudWatchに送信することもできる
      - AWS CLIの「put-metric-data」や「PutMetricData API」を使用して任意のメトリクスを送信できる
      - ※EC2では「メモリ使用率」と「ディスク使用率」などの重要な指標が標準メトリクスに含まれていない
        - CloudWatchエージェント (CloudWatch Logs Agent) を利用して、カスタムメトリクスの設定が必要になる
  - ログ収集間隔 :
    - **標準解像度** : デフォルトでは1分または5分間隔でデータが収集される
    - **高解像度** : 設定で10秒や30秒なども設定可能
  - 名前空間 : AWSサービスの名前空間は「AWS/サービス名」
    - 例）AWS/ApiGateway
  - ディメンション : 名前空間ごとに作成されるリソースを一意に識別するためのキー文字列ペア
    - CloudWatchにデータを送信するAWSサービスは、各メトリクスにディメンションを付ける
    - 例）AutoScalingGroupName, ImageId, InstanceId
- **CloudWatch Alerms** : CloudWatch Metricsのメトリクスに基づいてアラーム通知やアクションを実行する機能
  - アラーム状態の種類
    - **OK** : メトリクスが定義したしきい値内にあるとき
    - **ALARM** : メトリクスが定義したしきい値を超えたとき
    - **INSUFFICIENT_DATA** : 計測を開始したばかりでアラームの状態を判断するのに十分なデータがないとき
  - アラームの評価指標
    - 期間 : データポイントを評価するタイミング。1分間隔など
    - 評価期間 : データポイントを評価する数。例えば5つのデータポイントの平均値
    - アラームを実行するデータポイント : ALERMに遷移するために必要な条件を満たす連続したデータポイントの個数
    - 閾値 : アラームを実行する境界となるメトリクスの値
  - しきい値を超えたときにアクションがトリガーされる
  - アクションの例：
    - Amazon EC2 アクション
    - 自動スケーリングアクション
    - Amazon Simple Notification Service (Amazon SNS)
- **CloudWatch Logs** : サーバの標準出力に出力されたログを集約して表示する機能
  - CloudWatchは、Amazon CloudWatch Logsを使用することで、ログを保存および分析するための一元的な場所になる
  - CloudWatch Logsを使用すると、ログデータのクエリとフィルタリングができる
  - EC2インスタンスからCloudWatch Logsにアプリケーションログを送信する場合は、EC2インスタンスに**CloudWatch Logsエージェント** (CloudWatchエージェント) をインストールして設定する必要がある
  - ログの構造 :
    - **ロググループ** : 同じ設定を共有するログストリームのグループ。例）/aws/lambda/関数名
    - **ログストリーム** : 一連のログイベント。監視対象のリソースから送信されたタイムスタンプ順のイベント
    - **ログイベント** : 監視対象のリソースのアクティビティが記録されたログ。タイムスタンプとイベントメッセージが含まれる
  - **サブスクリプションフィルタ** : 指定したフィルタパターンに合致する文字列がログに含まれていた場合に、AWS LambdaやKinesis Data FirehoseなどのAWSサービスをイベント駆動（サブスクリプション）する機能
    - Lambda関数を実装する必要あり。直接SNSで通知することはできない
  - **メトリクスフィルタ** : 指定したフィルタパターンに合致する文字列がログに含まれていた場合に、CloudWatch Metricsにメトリクスデータとして送信する機能
  - CloudWatch Logsエージェントによるログ収集 :
    - CloudWatch LogsにログデータをプッシュするAWS Command Line Interface (AWS CLI) へのプラグイン
    - CloudWatch Logsにデータをプッシュするプロセスを開始するスクリプト
    - デーモンが常に実行されていることを確認するcronジョブ
- **CloudWatch Logs Insights** : CloudWatch Logsで収集されたログを分析・可視化する機能
  - イベントログを発生から「リアルタイム」に近いタイミングで解析できる
  - 検索には専用のクエリ言語を使用する
  - 自動生成されるフィールドの種類 :
    - `@message` : 未加工のログの内容
    - `@timestamp` : CloudWatch Logsに追加された時間
    - `@ingestionTime` : CloudWatch Logsがログイベントを受信した時間
    - `@logStream` : ログストリームの名前
    - `@log` : account-id:log-group-nameの形式のロググループ識別子
  - クエリ言語の構文
    - コマンド : display (表示するフィールドの選択), field (フィールドの選択), filter (選択条件), stats (集約), sort (ソート), limit (取得上限), parse
    - 例：
      ```
      fields @timestamp, @message
      | sort bytes desc
      | limit 20
      ```
- **CloudWatch Dashboards** : 様々なメトリクスの時系列データを集約して表示する機能
  - グラフの自動更新間隔の設定も可能（10秒、1分、2分、5分、15分）
- **CloudWatch Events** : AWSリソースの変更や時刻起動でイベントを送信し、それに基づいて何らかのアクションをする機能。AWS内のイベントのみ扱うことができる
- **Amazon EventBridge** : CloudWatch Eventsの機能を持ち、さらにAWS以外のSaaS製品で発生したイベントも扱うことができる
  - イベントソース :
    - S3などのAWSリソース
  - ルール :
    - **イベント駆動処理** : ルール（イベントパターン）に基づいてイベントターゲットを更新する
    - **時間駆動処理** : ルール（Cron式、Rate式）に基づいてイベントターゲットを更新する
  - イベントターゲット :
    - EC2インスタンスの停止・再起動・削除
    - EBSのスナップショットの作成
    - Lambda関数
    - Amazon Kinesis Data Streamsのストリーム
    - Amazon Kinesis Data Firehoseの配信ストリーム
    - CloudWatch Logsのロググループ
    - ECSのタスク
    - Systems Manager RunCommand
    - Systems Manager Automation
    - AWS Batchのジョブ
    - Step Functionsのステートマシン
    - AWS CodePipelineのパイプライン
    - AWS CodeBuildのプロジェクト
    - Amazon Inspectorの評価テンプレート
    - Amazon SNSのトピック
    - Amazon SQSのキュー
    - 他のAWSアカウントへのイベントバス（マルチアカウントでのシステムで利用）
  - CloudWatch EventsではPrivateLinkがサポートされているため、プライベートサブネットやオンプレミス環境からのイベントをトリガーとする処理の実装が可能

### AWS CloudTrail

- **CloudTrail**とは、AWSで実行されるほぼ全てのAPIの実行履歴を記録するサービス
  - CloudTrailの機能
    - マネジメントコンソール・CLI・SDKから実行したAPIアクションのイベント履歴の記録を90日間保存する
      - 90日間以上保存したい場合はS3に出力すること
    - CloudTrailを有効化するとAPI実行履歴がイベントログとして約15分ごとに出力される
    - イベントの種類 :
      - **管理イベント** : AWSアカウントのリソースで実行される「管理オペレーション（コントロールプレーンオペレーション）」によるイベント。IAMポリシーのアタッチ、ネットワーク構成の変更など
      - **データイベント** : AWSサービスのリソースやデータへの「操作オペレーション（データプレーンオペレーション）」によるイベント。S3オブジェクトの操作、Lambda関数の実行、DynamoDBのデータ更新など
      - **インサイトイベント** : 管理イベントがエラーを示した場合に記録されるイベント。異常検知用
        - CloudTrail Insights : 短時間で大量のAPIリクエストを異常値として検知するなど
  - CloudTrailイベント履歴の調査
    - マネジメントコンソール > CloudTrail > イベント履歴 で過去90日間のイベントが閲覧できる
    - **Amazon Athena** : S3内にある構造化されたデータをSQLで分析できるサービス
    - **Amazon OpenSearch Service** : ElasticsearchとKibanaを組み合わせたサービス (旧名 : Amazon Elasticsearch Service)
    - **Amazon CloudWatch Logs Insights** : イベントログを発生からリアルタイムに近いタイミングで解析できる

### AWS X-Ray

- **X-Ray**とは、アプリケーションの処理単位でメトリクスを収集・可視化・分析できるサービス
  - アプリケーションの性能ボトルネックを検出したり、障害検出するための利用される
  - X-Rayの機能
    - **サービスマップ** : AWSサービス間の呼び出しの成否や処理にかかった時間を可視化するマップ
    - トレース : アプリケーションへの呼び出しの内訳を時間軸で並べてリスト化する機能
    - アナリティクス : 各トレースを統計的に計測した場合のトレンドを可視化する機能
  - トレースリストの内容
    - セグメント : データを収集する単位。同じセグメントとするときは、リクエストヘッダ X-Amzn-Trace-Id にトレースIDを設定して送信する
    - サブセグメント : セグメントを任意に分割したもの。特定のアプリケーションでの実行時間を計測するためなど
    - トレースID (TraceID) : リクエストを識別するID。一意となるUUIDが割り当てられる
  - X-Rayの利用
    - X-Rayデーモンの設定
      - X-RayのSDKライブラリ or X-Rayのコンテナ を経由してアプリケーションのトレースデータを収集する
      - EC2の場合は権限「PutTraceSegments」を付与する必要あり
    - SDK利用時の設定
      - サンプリングルールの設定（Lambdaの場合は1秒ごとに最初のリクエスト、5%のサンプリングレートで収集される設定で固定）
      - 受信リクエスト : 最初のセグメントでTraceIDをリクエストヘッダで付与する
      - AWS SDKクライアント : DynamoDBやS3、SQSキューの送信にX-Rayを使う場合は設定が必要
      - SQLクライアント : データベースへの接続ドライバやSQLクライアントにX-Rayを使う場合は設定が必要
      - カスタムサブセグメント : アプリケーションの任意のタイミングでサブセグメントを開始・終了して実行時間を計測できる
  - X-Rayのその他の機能
    - **フィルタ式** : トレースを抽出するための機能。例）http.url CONTAINS "/api/users"
      - **注釈** (Annotation) : フィルタ式で使用するためのインデックス化されたキーバリューペア。例）http.url
    - メタデータ (Metadata) : トレースに付加的な情報を記録できるキーバリューペア
- **CloudWatch ServiceLens** :
  - X-Rayで収集したデータをCloudWatchに統合して、サービスマップやトレースリストなど、アプリケーション可視化を1カ所でまとめて確認できるAWSサービス

### 参考資料

- [AWS Certified Developer - Associate 認定](https://aws.amazon.com/jp/certification/certified-developer-associate/)
  - 公式情報で試験範囲やサンプルの問題などの情報があります。必ず目を通すようにしましょう
- [AWS Skill Builder](https://explore.skillbuilder.aws/learn/signin)
  - AWSが提供しているデジタルコンテンツです。無料（20問）と有料（65問）の問題集があります
- [『徹底攻略AWS認定デベロッパー - アソシエイト教科書 (徹底攻略シリーズ)』株式会社NTTデータ 川畑 光平](https://amzn.to/45TPbVh)
  - AWS Developerで扱われる各サービスについて詳細な説明が書かれていてとても良いです。AWSマネジメントコンソールで少し触ったことがある人ならより理解が早まると思います。


---

## 試験情報

- 点数は 100〜1000 のスケールスコア
- 合計スコアは 720
- ドメインの重み
  1. AWSサービスによる開発 (32%)
  2. セキュリティ (26%)
  3. デプロイ (24%)
  4. トラブルシューティングと最適化 (18%)
- 試験時間 : 140分

### 第1分野: AWS のサービスによる開発

- タスクステートメント1 : **AWSでホストされているアプリケーション用のコードの開発**
  - 対象知識 :
    - アーキテクチャパターン (イベント駆動型、マイクロサービス、モノリシック、コレオグラフィー、オーケストレーション、ファンアウトなど)
    - べき等性
    - ステートフルとステートレスの概念の違い
    - 密結合されたコンポーネントと疎結合されたコンポーネントの違い
    - フォールトトレラントな設計パターン (エクスポネンシャルバックオフとジッターを使用した再試行、デッドレターキューなど)
    - 同期パターンと非同期パターンの違い
  - 対象スキル :
    - プログラミング言語 (Java、C#、Python、JavaScript、TypeScript、Go など) での耐障害性と回復力のあるアプリケーションの作成
    - APIの作成、拡張、保守 (レスポンス/リクエストの変換、検証ルールの適用、ステータスコードのオーバーライドなど)
    - 開発環境での単体テストの作成と実行 (AWS Serverless Application Model [AWS SAM] の使用など)
    - メッセージングサービスを使用するためのコードの作成
    - APIとAWS SDKを使用したAWSのサービスとやり取りするためのコードの作成
    - AWSのサービスを使用したデータストリーミングの処理
- タスクステートメント2 : **AWS Lambda用のコードの開発**
  - 対象知識 :
    - イベントソースマッピング
    - ステートレスアプリケーション
    - 単体テスト
    - イベント駆動型アーキテクチャ
    - スケーラビリティ
    - LambdaコードからのVPCでのプライベートリソースのアクセス
  - 対象スキル :
    - 環境変数とパラメータ (メモリ、同時実行、タイムアウト、ランタイム、ハンドラー、レイヤー、拡張機能、トリガー、送信先など) を定義することによるLambda関数の設定
    - コード (Lambda 送信先、デッドレターキューなど) を使用したイベントライフサイクルとエラーの処理
    - AWSのサービスとツールを使用したテストコードの作成と実行
    - Lambda関数とAWSのサービスの統合
    - 最適なパフォーマンスのためのLambda関数のチューニング
- タスクステートメント 3 : **アプリケーション開発でのデータストアの使用**
  - 対象知識 :
    - リレーショナルデータベースと非リレーショナルデータベース
    - 作成、読み取り、更新、削除 (CRUD) オペレーション
    - バランスの取れたパーティションアクセスのための高カーディナリティパーティションキー
    - クラウドストレージオプション (ファイル、オブジェクト、データベースなど)
    - データベース整合性モデル (強整合性、結果整合性など)
    - クエリオペレーションとスキャンオペレーションの違い
    - Amazon DynamoDBキーとインデックス作成
    - キャッシュ戦略 (書き込みスルー、リードスルー、遅延読み込み、TTLなど)
    - Amazon S3の階層とライフサイクル管理
    - エフェメラルデータストレージパターンと永続データストレージパターンの違い
  - 対象スキル :
    - データをシリアル化および逆シリアル化してデータストアに永続性を提供
    - データストアの使用、管理、保守
    - データライフサイクルの管理
    - データキャッシュサービスの使用

### 第2分野: セキュリティ

- タスクステートメント1 : **アプリケーションとAWSのサービスの認証および/または認可の実装**
  - 対象知識 :
    - ID フェデレーション (Security Assertion Markup Language [SAML]、OpenID Connect [OIDC]、Amazon Cognitoなど)
    - ベアラートークン (JSON ウェブトークン [JWT]、OAuth、AWS Security Token Service [AWS STS] など)
    - Amazon Cognito でのユーザープールと ID プールの比較
    - リソースベースのポリシー、サービスポリシー、プリンシパルポリシー
    - ロールベースのアクセスコントロール (RBAC)
    - ACLを使用するアプリケーション認可
    - 最小権限の原則
    - AWSマネージドポリシーと顧客マネージドポリシーの違い
    - アイデンティティとアクセスの管理
  - 対象スキル :
    - ID プロバイダーの使用によるフェデレーテッドアクセスの実装 (Amazon Cognito、AWS Identity and Access Management [IAM] など)
    - ベアラートークンを使用したアプリケーションのセキュリティ保護
    - AWSへのプログラムによるアクセスの設定
    - AWSのサービスに対して認証された呼び出しを行う
    - IAMロールを引き受ける
    - プリンシパルのアクセス許可の定義
- タスクステートメント2 : **AWSサービスを使用した暗号化の実装**
  - 対象知識 :
    - 保管中と転送中の暗号化
    - 証明書管理 (AWS Private Certificate Authority など)
    - キーの保護 (キーのローテーションなど)
    - クライアント側の暗号化とサーバー側の暗号化の違い
    - AWS マネージドキーとカスタマーマネージド AWS Key Management Service (AWS KMS) キーの違い
  - 対象スキル :
    - 暗号化キーの使用によるデータの暗号化または復号化
    - 開発目的での証明書とSSHキーの生成
    - アカウントの境界を越えた暗号化の使用
    - キーローテーションの有効化と無効化
- タスクステートメント3 : **アプリケーションコードでの機密データの管理**
  - 対象知識 :
    - データ分類 (個人を特定できる情報 [PII]、保護対象医療情報 [PHI] など)
    - 環境変数
    - シークレット管理 (AWS Secrets Manager、AWS Systems Manager Parameter Storeなど)
    - セキュアな認証情報の処理
  - 対象スキル :
    - 機密データを含む環境変数の暗号化
    - シークレット管理サービスの使用による機密データの保護
    - 機密データのサニタイズ

### 第3分野: デプロイ

- タスクステートメント 1 : **AWSにデプロイするアプリケーションアーティファクトの準備**
  - 対象知識 :
    - アプリケーション設定データ (AWS AppConfig、Secrets Manager、パラメータストアなど) へのアクセス方法
    - Lambdaデプロイのパッケージ化、レイヤー、および設定オプション
    - Gitベースのバージョン管理ツール (Git、AWS CodeCommit など)
    - コンテナイメージ
  - 対象スキル :
    - パッケージ内でのコードモジュール (環境変数、設定ファイル、コンテナイメージなど) の依存関係の管理
    - アプリケーションデプロイのためのファイルとディレクトリ構造の整理
    - デプロイ環境でのコードリポジトリの使用
    - リソース (メモリ、コアなど) に対するアプリケーション要件の適用
- タスクステートメント 2 : **開発環境でのアプリケーションのテスト**
  - 対象知識 :
    - アプリケーションのデプロイを実行するAWSサービスの機能
    - モックエンドポイントを使用する統合テスト
    - Lambdaのバージョンとエイリアス
  - 対象スキル :
    - AWSのサービスとツールを使用したデプロイされたコードのテスト
    - APIのモック統合の実行と統合の依存関係の解決
    - 開発エンドポイントを使用したアプリケーションのテスト (Amazon API Gatewayでのステージの設定など)
    - 既存の環境へのアプリケーションスタックの更新のデプロイ (AWS SAMテンプレートの別のステージング環境へのデプロイなど)
- タスクステートメント 3 : **デプロイテストの自動化**
  - 対象知識 :
    - API Gatewayステージ
    - 継続的インテグレーションと継続的デリバリー (CI/CD) ワークフローにおけるブランチとアクション
    - 自動化されたソフトウェアテスト (単体テスト、モックテストなど)
  - 対象スキル :
    - アプリケーションテストイベントの作成 (Lambda、API Gateway、AWS SAMリソースをテストするためのJSONペイロードなど)
    - さまざまな環境へのAPIリソースのデプロイ
    - 統合テスト用に承認済みのバージョンを使用するアプリケーション環境の作成 (Lambda エイリアス、コンテナイメージタグ、AWS Amplifyブランチ、AWS Copilot環境など)
    - Infrastructure as Code (IaC) テンプレートの実装およびデプロイ (AWS SAMテンプレート、AWS CloudFormationテンプレートなど)
    - 個々のAWSのサービスの環境管理 (API Gatewayでの開発、テスト、本番環境の区別など)
- タスクステートメント 4 : **AWS CI/CDサービスを使用したコードのデプロイ**
  - 対象知識 :
    - Gitベースのバージョン管理ツール (Git、AWS CodeCommitなど)
    - AWS CodePipelineでのマニュアル承認と自動承認
    - AWS AppConfigとSecrets Managerからアプリケーション設定にアクセス
    - AWSサービスを使用するCI/CDワークフロー
    - AWSのサービスとツール (CloudFormation、AWS CDK、AWS SAM、AWS CodeArtifact、AWS Copilot、Amplify、Lambdaなど) を使用するアプリケーションのデプロイ
    - Lambdaデプロイのパッケージングオプション
    - API Gatewayステージとカスタムドメイン
    - デプロイ戦略 (Canary、ブルー/グリーン、ローリングなど)
  - 対象スキル :
    - 既存のIaCテンプレート (AWS SAMテンプレート、CloudFormationテンプレートなど) の更新
    - AWSのサービスを使用したアプリケーション環境の管理
    - デプロイ戦略を使用したアプリケーションバージョンのデプロイ
    - ビルド、テスト、デプロイアクションを呼び出すためのリポジトリへのコードのコミット
    - さまざまな環境にコードをデプロイするためのオーケストレーションされたワークフローの使用
    - 既存のデプロイ戦略を使用したアプリケーションロールバックの実行
    - バージョンとリリース管理へのラベルとブランチの使用
    - 動的デプロイを作成するための既存のランタイム設定の使用 (Lambda 関数での API Gateway のステージング変数の使用など)

### 第4分野: トラブルシューティングと最適化

- タスクステートメント1 : **根本原因分析の支援**
  - 対象知識 :
    - ロギングおよびモニタリングシステム
    - ログクエリの言語 (Amazon CloudWatch Logs Insightsなど)
    - データの可視化
    - コード分析ツール
    - 一般的なHTTPエラーコード
    - SDKによって生成される一般的な例外
    - AWS X-Rayのサービスマップ
  - 対象スキル :
    - 欠陥を特定するためのデバッグコード
    - アプリケーションメトリクス、ログ、トレースの解釈
    - 関連データを検索するためのログのクエリ
    - カスタムメトリクスの実装 (CloudWatch埋め込みメトリクスフォーマット [EMF] など)
    - ダッシュボードとインサイトを使用したアプリケーションヘルスの確認
    - サービス出力ログを使用したデプロイ失敗のトラブルシューティング
- タスクステートメント2 : **可観測性のためのコードの計測**
  - 対象知識 :
    - 分散トレース
    - ロギング、モニタリング、可観測性の違い
    - 構造化ログ
    - アプリケーションメトリクス (カスタム、埋め込み、組み込みなど)
  - 対象スキル :
    - アプリケーションの動作と状態を記録する効果的なロギング戦略の実装
    - カスタムメトリクスを出力するコードの実装
    - トレースサービスへの注釈の追加
    - 特定のアクション (クォータ制限またはデプロイの完了に関する通知など) に関する通知アラートの実装
    - AWSのサービスとツールを使用したトレースの実装
- タスクステートメント3 : **AWSのサービスと機能を使用したアプリケーションの最適化**
  - 対象知識 :
    - キャッシュ
    - 同時実行
    - メッセージングサービス (Amazon SQS、Amazon SNSなど)
  - 対象スキル :
    - アプリケーションパフォーマンスのプロファイリング
    - アプリケーションの最小メモリと処理能力の決定
    - サブスクリプションフィルターポリシーを使用したメッセージの最適化
    - リクエストヘッダーに基づくコンテンツのキャッシュ

### Appendix

- 試験に出題される可能性のあるテクノロジーと概念
  - 分析
  - アプリケーション統合
  - コンピューティング
  - コンテナ
  - コストと容量管理
  - データベース
  - デベロッパーツール
  - マネジメントとガバナンス
  - ネットワークとコンテンツ配信
  - セキュリティ、アイデンティティ、コンプライアンス
  - ストレージ
- **範囲内**のAWSサービスと機能
  - 分析 :
    - Amazon Athena
    - Amazon Kinesis
    - Amazon OpenSearch Service
  - アプリケーション統合 :
    - AWS AppSync
    - Amazon EventBridge
    - Amazon Simple Notification Service (Amazon SNS)
    - Amazon Simple Queue Service (Amazon SQS)
    - AWS Step Functions
  - コンピューティング :
    - Amazon EC2
    - AWS Elastic Beanstalk
    - AWS Lambda
    - AWS Serverless Application Model (AWS SAM)
  - コンテナ :
    - AWS Copilot
    - Amazon Elastic Container Registry (Amazon ECR)
    - Amazon Elastic Container Service (Amazon ECS)
    - Amazon Elastic Kubernetes Service (Amazon EKS)
  - データベース :
    - Amazon Aurora
    - Amazon DynamoDB
    - Amazon ElastiCache
    - Amazon MemoryDB for Redis
    - Amazon RDS
  - デベロッパーツール :
    - AWS Amplify
    - AWS Cloud9
    - AWS CloudShell
    - AWS CodeArtifact
    - AWS CodeBuild
    - AWS CodeCommit
    - AWS CodeDeploy
    - Amazon CodeGuru
    - AWS CodePipeline
    - AWS CodeStar
    - Amazon CodeWhisperer
    - AWS X-Ray
  - マネジメントとガバナンス :
    - AWS AppConfig
    - AWS CLI
    - AWS Cloud Development Kit (AWS CDK)
    - AWS CloudFormation
    - AWS CloudTrail
    - Amazon CloudWatch
    - Amazon CloudWatch Logs
    - AWS Systems Manager
  - ネットワークとコンテンツ配信 :
    - Amazon API Gateway
    - Amazon CloudFront
    - Elastic Load Balancing (ELB)
    - Amazon Route 53
    - Amazon VPC
  - セキュリティ、アイデンティティ、コンプライアンス :
    - AWS Certificate Manager (ACM)
    - Amazon Cognito
    - AWS Identity and Access Management (IAM)
    - AWS Key Management Service (AWS KMS)
    - AWS Private Certificate Authority
    - AWS Secrets Manager
    - AWS Security Token Service (AWS STS)
    - AWS WAF
  - ストレージ :
    - Amazon Elastic Block Store (Amazon EBS)
    - Amazon Elastic File System (Amazon EFS)
    - Amazon S3
    - Amazon S3 Glacier
- **範囲外**のAWSサービスと機能
  - 分析 :
    - Amazon QuickSight
  - ビジネスアプリケーション :
    - Amazon Chime
    - Amazon Connect
    - Amazon WorkMail
  - エンドユーザーコンピューティング :
    - Amazon AppStream 2.0
    - Amazon WorkSpaces
  - フロントエンドのウェブとモバイル :
    - AWS Device Farm
  - ゲーム関連テクノロジー :
    - Amazon GameLift
  - 機械学習 :
    - Amazon Lex
    - Amazon Machine Learning (Amazon ML)
    - Amazon Polly
    - Amazon Rekognition
  - マネジメントとガバナンス :
    - AWS Managed Services (AMS)
    - AWS Service Catalog
  - メディアサービス :
    - Amazon Elastic Transcoder
  - 移行と転送 :
    - AWS Application Discovery Service
    - AWS Application Migration Service
    - AWS Database Migration Service (AWS DMS)
  - セキュリティ、アイデンティティ、コンプライアンス :
    - AWS Shield Advanced
    - AWS Shield Standard
  - ストレージ :
    - AWS Snow ファミリー
    - AWS Storage Gateway
