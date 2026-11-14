# protocol

Parent: [All Categories](../index.md)

## Subcategories

- [rfc/](./rfc/index.md) (2 posts)
- [tls13-book/](./tls13-book/index.md) (3 posts)

## Articles (30)

- [Syslogデータの構造 (RFC 5424)](./2024-08-09-syslog-message-format.md) (`Reference | stable | stale_after: 2027-08-10`) — RFC 3164およびRFC 5424で定義されたSyslogデータのABNF構文、ファシリティとシビアリティからPRI値を計算する規則、構造化データとMSG形式をまとめています。
- [TCPパケットの中継サーバ（プロキシサーバ）をPythonで実装する](./2023-08-08-tcp-proxy.md) (`How-To | stable | stale_after: 2026-08-12`) — Pythonのsocketモジュールとthreadingを使い、受信したTCPパケットを別ホストへ中継・hexdump表示するシンプルなプロキシサーバの実装方法を解説します。
- [マイナンバー制度と健康保険証](./2023-07-13-mynumber-insurancecard.md) (`Concept | stable | stale_after: 2026-10-31`) — マイナンバーカードの健康保険証利用におけるオンライン資格確認等システムの機能、PIN無し顔認証およびPIN認証でのカード読み取りと本人確認フローを解説します。
- [マイナンバー制度と申請管理（ぴったりサービス）](./2023-07-12-mynumber-shinseikanri.md) (`Concept | stable | stale_after: 2026-10-31`) — マイナポータルのぴったりサービスを用いたオンライン申請管理の仕組み、電子証明書シリアル番号による名寄せ手順、対象となる標準様式を解説します。
- [マイナンバー制度とコンビニ交付](./2023-07-11-mynumber-conveniencestore.md) (`Concept | stable | stale_after: 2026-10-31`) — マイナンバーカードを用いたコンビニ交付サービスについて、取得可能な証明書の種類、キオスク端末からJ-LIS・自治体サーバまでのシステム構成と発行制限を解説します。
- [マイナンバー制度と情報連携（団体内統合宛名）](./2023-07-10-mynumber-johorenkei.md) (`Concept | stable | stale_after: 2027-12-26`) — 自治体における団体内統合宛名機能と機関別符号の仕組み、中間サーバを介した副本登録および他機関との情報照会（情報連携）の流れを解説します。
- [マイナンバー制度と住民基本台帳](./2023-07-09-mynumber-juki.md) (`Concept | stable | stale_after: 2027-06-03`) — 住民基本台帳と住基ネットの仕組み、住民票コードからマイナンバーへの変換・付番および副本登録の流れ、引越し手続オンラインサービスを解説します。
- [マイナンバー制度の用語集](./2023-07-08-mynumber-terminology.md) (`Reference | stable | stale_after: 2026-10-31`) — マイナンバー制度の住民記録分野および医療保険分野で使用される宛名番号・符号・住基ネット・中間サーバなどの専門用語をまとめた用語集です。
- [サーバ名がIPアドレスの場合の証明書作成 / サブジェクト代替名 (SAN) の設定方法](./2022-10-21-certificate-with-ip-addr.md) (`How-To | stable | stale_after: 2025-10-30`) — IPアドレス直接アクセスのHTTPS通信で証明書検証を成功させるため、OpenSSLでSANにIPを設定した証明書を作成する手順とRFC 2818の背景を解説します。
- [Python/FlaskでOpenID Connectと通信する](./2022-08-12-openid-connect-example.md) (`How-To | stable | stale_after: 2023-12-29`) — PythonとFlaskを使い、GoogleのOpenID Connectの認可・トークン・UserInfo各エンドポイントと通信してユーザ情報を取得する手順を解説します。
- [OAuth (OAuth 2.0 認可フレームワーク)](./2022-06-19-oauth.md) (`Concept | stable | stale_after: 2026-08-24`) — 認可フレームワークであるOAuth 2.0について、4つのロールと4種類の認可グラントタイプ（認可コード・インプリシット等）の処理フローを解説します。
- [認証認可におけるクレデンシャルの共有](./2022-06-18-shared-credential.md) (`Concept | stable | stale_after: 2025-06-19`) — アプリケーションにユーザ名とパスワードを直接渡す認証パターンの問題点（中間者攻撃リスクや識別不能性）と、それを解決するOAuthの役割を解説します。
- [QUIC の Handshake Packet を復号する](./2021-10-10-quic-handshake-packet-decrypt.md) (`How-To | stable | stale_after: 2025-03-21`) — QUICのInitial Packetで交換したDiffie-Hellman公開鍵から共有鍵とTLS鍵スケジュールを導出し、Handshake PacketをPythonで復号する手順を解説します。
- [QUIC の Client Initial Packet で必須のTLS拡張](./2021-10-06-quic-client-initial-tls-ext.md) (`How-To | stable | stale_after: 2025-03-21`) — QUICのClient Initial Packetに必須となるTLS 1.3およびQUIC固有の拡張パラメータを解説し、Handshake Packet受信までの実装手順を示します。
- [QUICのRetryパケット](./2021-09-18-quic-retry-packet.md) (`Concept | stable | stale_after: 2025-03-13`) — QUICにおいてサーバが接続先コネクションIDの検証や変更を要求する際に送信するRetryパケットの役割、ハンドシェイクの流れ、パケット内容を解説します。
- [QUIC の Initial Packet を暗号化する](./2021-09-10-quic-initial-packet-encrypt.md) (`How-To | stable | stale_after: 2025-03-21`) — QUICのClient Initial Packetについて、鍵導出からCRYPTOフレーム構築、ペイロード暗号化、ヘッダ保護の付与までをPythonで実装する手順を解説します。
- [QUIC の TLS ClientHello を解析する](./2021-08-16-quic-tls-clienthello.md) (`How-To | stable | stale_after: 2025-03-21`) — QUICのCRYPTOフレームに格納されたTLSハンドシェイクメッセージ（ClientHello・ServerHelloやQUIC拡張）をPythonで解析する方法を解説します。
- [QUIC の Initial Packet を復号する](./2021-08-14-quic-initial-packet-decrypt.md) (`How-To | stable | stale_after: 2025-03-21`) — RFC 9000・9001の仕様に基づき、QUICのInitial Packetから鍵導出、ヘッダ保護解除、ペイロード復号までをPythonで実装する手順を解説します。
- [UUID (GUID) とは](./2021-04-03-uuid-and-guid.md) (`Concept | stable | stale_after: 2025-03-13`) — 一意な識別子であるUUID（RFC 4122）とMicrosoftのGUIDの仕様上の違いや、バージョン別の生成方式と構造について解説します。
- [ゼロトラストネットワークとは](./2021-03-29-zero-trust-network.md) (`Concept | stable | stale_after: 2025-03-13`) — 境界防御の限界を背景に生まれたゼロトラストネットワークの目的、基本7原則、動的な信用度評価に基づく認証フロー、関連技術を解説します。
- [認証・認可のフロー](./2021-03-28-auth-flow.md) (`Concept | stable | stale_after: 2025-03-13`) — ソーシャルログイン、FIDO（UAF/U2F）、OAuth 2.0、OpenID Connect、Active Directory、SAMLなど主要な認証・認可プロトコルの処理フローを図解します。
- [ASN.1 のタグ一覧](./2021-01-17-asn1-tags.md) (`Reference | stable | stale_after: 2025-03-13`) — ASN.1で定義されているBOOLEAN・INTEGER・OCTET STRING・OBJECT IDENTIFIERなどのタグ番号とデータ型の一覧をまとめたリファレンスです。
- [マイナンバーカードとAPDUで通信して署名データ作成](./2021-01-16-jpki-mynumbercard-with-apdu.md) (`How-To | stable | stale_after: 2026-09-29`) — マイナンバーカードとAPDUコマンドで通信し、証明書の取得やDigestInfoを用いた秘密鍵署名、OpenSSL検証、個人番号等の読み取り手順を解説します。
- [ASN.1 でのオブジェクトID (OID) とバイト列の表記](./2021-01-11-oids.md) (`Reference | stable | stale_after: 2025-09-30`) — ASN.1におけるオブジェクトID（OID）のドット表記とDERバイト列の相互変換ルールおよびPython実装、主要アルゴリズムのOID一覧をまとめています。
- [SMTPの応答コードの一覧](./2020-03-16-smtp-reply-code.md) (`Reference | stable | stale_after: 2023-03-16`) — RFC 5321で定義されているSMTPの3桁の応答コード一覧と、2桁目の数字が示す応答カテゴリ（構文・情報・接続・メールシステム）の意味をまとめています。
- [QUIC のパケット暗号化プロセス](./2019-12-11-quic-tls.md) (`Concept | stable | stale_after: 2024-09-10`) — QUICとTLS 1.3の連携関係および、鍵導出からペイロード暗号化、暗号化サンプルをマスクに用いるヘッダ保護までの暗号化プロセスを解説します。
- [draft-ietf-quic-tls の概要](./2019-11-16-draft-ietf-quic-tls.md) (`Concept | stable | stale_after: 2024-08-16`) — QUICの暗号化を定義するdraft-ietf-quic-tls（RFC 9001）について、TLS 1.3メッセージの運搬方法や鍵スケジュール、パケット保護の仕組みをまとめています。
- [draft-ietf-quic-transport の概要](./2019-11-13-draft-ietf-quic-transport.md) (`Concept | stable | stale_after: 2024-08-16`) — QUICトランスポート仕様draft-ietf-quic-transport（RFC 9000）について、ストリーム多重化や接続管理、フロー制御、パケット構造の要点をまとめています。
- [draft-ietf-quic-invariants の概要](./2019-11-08-draft-ietf-quic-invariants.md) (`Concept | stable | stale_after: 2024-08-16`) — QUICのバージョンに依存しない特性を定めるdraft-ietf-quic-invariants（RFC 8999）について、ヘッダ形式や接続ID、バージョン交渉の要点をまとめています。
- [nroffマクロを使ったRFCの作成](./2019-03-20-rfc2223-instructions-to-rfc-authors.md) (`How-To | stable | stale_after: 2024-03-21`) — RFC 2223に基づき、nroffのmsマクロと改ページ調整用のPerlスクリプトfix.plを使ってRFC形式の文書を作成する方法を解説します。
