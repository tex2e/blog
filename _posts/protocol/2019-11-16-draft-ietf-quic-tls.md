---
layout:        post
title:         "draft-ietf-quic-tls の概要"
date:          2019-11-16
category:      Protocol
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

[Using TLS to Secure QUIC](https://quicwg.org/base-drafts/boilerplate/draft-ietf-quic-tls.html) を読んで要点だけをまとめた自分用の資料です。
読んでいる時点では draft-24 です。

## Using TLS to Secure QUIC

TLSを使ったセキュアなQUIC


### 1. はじめに

- この文書ではQUICをセキュアにするためのTLSの使い方について説明する
- TLS 1.3 では1往復でセキュアなチャネルが確立する


### 2. 表記規則

- 簡潔にするために、TLS 1.3 を TLS と表現しているが、新しいバージョンを指すこともできる

#### 2.1. TLSの概要

- TLSは信頼できないメディア上でセキュアな通信路を提供することで、メッセージの盗聴、改ざん、偽造ができなくなる
- TLSは構造化されたプロトコル

```fig
          +-------------+------------+--------------+---------+
Handshake |             |            |  Application |         |
Layer     |  Handshake  |   Alerts   |     Data     |   ...   |
          |             |            |              |         |
          +-------------+------------+--------------+---------+
Record    |                                                   |
Layer     |                      Records                      |
          |                                                   |
          +---------------------------------------------------+
```

図1: TLS Layers

- 複数のハンドシェイクメッセージを1つのレコードレイヤに乗せて送信する
- 各レコードは暗号化される
- TLSは事前共有鍵(PSK)と有限体上もしくは楕円曲線上のDiffie-Hellman鍵交換で鍵を共有する
- Diffie-Hellman鍵交換を使うときは、前方秘匿性になる
- サーバの認証は必須。クライアントの認証は任意
- 認証は、X.509証明書に対応している
- 2つの基本的なハンドシェイク
  - 1-RTTハンドシェイク
  - 0-RTTハンドシェイク
- QUICではTLSの EndOfEarlyData、ChangeCipherSpec、KeyUpdate メッセージは使われない
- QUICは独自の鍵更新メカニズムを持つ

```fig
    Client                                             Server

    ClientHello
   (0-RTT Application Data)  -------->
                                                  ServerHello
                                         {EncryptedExtensions}
                                                    {Finished}
                             <--------      [Application Data]
   {Finished}                -------->

   [Application Data]        <------->      [Application Data]

    () Indicates messages protected by Early Data (0-RTT) Keys
    {} Indicates messages protected using Handshake Keys
    [] Indicates messages protected using Application Data
       (1-RTT) Keys
```

図2: TLS Handshake with 0-RTT

- データは場面（暗号化レベル）によって異なる鍵で暗号化される
  - 初期鍵 (Initial Keys)
  - 初期データ鍵 (0-RTT)
  - ハンドシェイク鍵
  - アプリケーションデータ鍵 (1-RTT)
- 0-RTTはクライアントとサーバが以前に通信したことがある場合にのみ可能


### 3. プロトコルの概要

- TLSレコードの役割は、QUICではQUICトランスポートが担う

```fig
+--------------+--------------+ +-------------+
|     TLS      |     TLS      | |    QUIC     |
|  Handshake   |    Alerts    | | Applications|
|              |              | |  (h3, etc.) |
+--------------+--------------+-+-------------+
|                                             |
|                QUIC Transport               |
|   (streams, reliability, congestion, etc.)  |
|                                             |
+---------------------------------------------+
|                                             |
|            QUIC Packet Protection           |
|                                             |
+---------------------------------------------+
```

図3: QUIC Layers

- QUICはTLSハンドシェイクを利用する
- TLSはQUICが提供する信頼性、順番通りの配信、レコードレイヤを使用する
- TLSとQUICの主な関係
  - TLSはQUICを介してメッセージを送受信する
  - QUICはTLSに信頼できるストリームを提供する
  - TLSはQUICに共通鍵の更新やハンドシェイク完了による状態変更などの情報を提供する

```fig
+------------+                               +------------+
|            |<---- Handshake Messages ----->|            |
|            |<- Validate 0-RTT parameters ->|            |
|            |<--------- 0-RTT Keys ---------|            |
|    QUIC    |<------- Handshake Keys -------|    TLS     |
|            |<--------- 1-RTT Keys ---------|            |
|            |<------- Handshake Done -------|            |
+------------+                               +------------+
 |         ^
 | Protect | Protected
 v         | Packet
+------------+
|   QUIC     |
|  Packet    |
| Protection |
+------------+
```

- TLS over TCP とは違い、データを送信したいときは application_data レコードで送信しない
- 代わりに、QUICの STREAM フレームで送信する


### 4. TLSメッセージの運搬

- TLSハンドシェイクデータは CRYPTO フレームで運ぶ
- TLSレコードとQUICのCRYPTOフレームの違いは、QUICでは複数のフレームが同じQUICパケットに現れること (例えば、CRYPTOフレームとACKフレームが一つのパケットで送られる)
- 異なる暗号化レベルでは送信できないフレームがある
  - PADDINGフレームとPINGフレームは、全ての暗号化レベルのパケットで現れる場合がある (MAY)
  - CRYPTOフレームとCONNECTION_CLOSEフレームは、0-RTT以外の暗号化レベルのパケットで現れる場合がある (MAY)
  - ACKフレームは、0-RTT以外の暗号化レベルのパケットで現れる場合がある (MAY)。ただし、そのパケット番号スペースに現れるパケットに対してのみ確認応答できる
  - その他のフレームは 0-RTT と 1-RTT レベルでのみ送信される (MUST)
- ACK, CRYPTO, NEW_TOKEN, PATH_RESPONSE, RETIRE_CONNECTION_ID フレームは様々な理由により、0-RTT で送信できないことに注意

表1: Encryption Levels by Packet Type

| パケットタイプ<br>(Packet Type) | 暗号化レベル<br>(Encryption Level) | パケット番号スペース<br>(PN Space)
|:--------------------|:-----------------|:-------------
| Initial             | Initial secrets  | Initial
| 0-RTT Protected     | 0-RTT            | 0/1-RTT
| Handshake           | Handshake        | Handshake
| Retry               | N/A              | N/A
| Version Negotiation | N/A              | N/A
| Short Header        | 1-RTT            | 0/1-RTT

#### 4.1. TLSへのインターフェイス

- QUICからTLSへのインターフェイス
  - ハンドシェイクメッセージの送受信
  - 再開されたセッションから保存されたトランスポートとアプリケーションの状態を処理し、初期データを受け入れることが有効かどうかを判断する
  - 鍵の再生成 (送信用と受信用の両方)
  - ハンドシェイクの状態の更新

##### ハンドシェイクの完了

- TLSがFinishedメッセージを送信し、相手のFinishedメッセージを検証した時にハンドシェイクが完了する

##### 確認済みハンドシェイク

- 2つの条件が満たされると、エンドポイントでTLSハンドシェイクが確認されたと見なされる
  - ハンドシェイクが完了し、1-RTT鍵で暗号化して送信したパケットの確認応答を受信したとき
  - ACKの最大値が、送信したパケット番号の最小値以上のとき (?)

##### ハンドシェイクメッセージの送受信

- QUICは、CRYPTOフレームでのみTLSハンドシェイクレコードを伝送する
- TLSアラートは、QUICの CONNECTION_CLOSE エラーに変わる

##### 暗号化レベルの変更

- 暗号化レベルの鍵が利用可能になると、TLSはそれらの鍵をQUICに提供する
- 新しい暗号化レベルが利用可能になるとTLSがQUICに提供するもの
  - 秘密鍵 (secret)
  - 認証付き暗号機能 (AEAD)
  - 鍵導出関数 (KDF)

##### TLSインターフェイスのまとめ

- 図はクライアントとサーバの両方のQUICとTLS間のやりとりをまとめたもの
- 各矢印には、その送信で使用される暗号レベルが書かれている

```fig
Client                                                    Server

Get Handshake
                     Initial ------------->
                                              Handshake Received
Install tx 0-RTT Keys
                     0-RTT --------------->
                                                   Get Handshake
                     <------------- Initial
Handshake Received
Install Handshake keys
                                           Install rx 0-RTT keys
                                          Install Handshake keys
                                                   Get Handshake
                     <----------- Handshake
Handshake Received
                                           Install tx 1-RTT keys
                     <--------------- 1-RTT
Get Handshake
Handshake Complete
                     Handshake ----------->
                                              Handshake Received
                                           Install rx 1-RTT keys
                                              Handshake Complete
Install 1-RTT keys
                     1-RTT --------------->
                                                   Get Handshake
                     <--------------- 1-RTT
Handshake Received
```

図5: Interaction Summary between QUIC and TLS

#### 4.2. TLSバージョン

- TLS 1.3を使う
- 1.3より古いバージョンが交渉される場合は、接続を終了しなければならない (MUST)

#### 4.3. ClientHelloのサイズ

- ClientHelloメッセージは、初期パケットとして送信される
- QUICパケットとフレームによって、ClientHelloメッセージに少なくとも36バイトのオーバーヘッドが追加される

#### 4.4. 相手の認証

- TLSはサーバ認証を提供し、クライアント認証を要求できる

#### 4.5. 0-RTTの有効化

- サーバは0-RTTを処理する意思があることを伝えるために、0xffffffff の max_early_data_size を持つ「early_data」拡張を含む NewSessionTicket メッセージを送信する
- クライアントが0-RTTで送信できるデータ量はサーバが提供するトランスポートパラメータ「initial_max_data」によって決まる
- サーバは max_early_data_size を 0xffffffff 以外の値に設定した「early_data」拡張を送信してはいけない (MUST NOT)
- そのような「early_data」を受信したときは、PROTOCOL_VIOLATION エラーとして扱う (MUST)
- クライアントが0-RTTパケットを送信する際は、ClientHelloメッセージで「early_data」拡張を使用して、アプリケーションデータを送信する

#### 4.6. 0-RTT の受け取りと拒否

#### 4.7. 0-RTT の検証

#### 4.8. HelloRetryRequest

#### 4.9. TLSエラー

- TLSアラートは、QUICエラーコードに変換される
- TLSアラートの値に 0x100 を加えたものが QUICエラーコードとなる
- 例えば no_application_protocol (0x78) は、QUICエラーコード (0x178) になる

#### 4.10. 未使用鍵の破棄

- 暗号化レベルに移行すると、前の暗号化レベルの鍵は破棄できる
- 新しい鍵が利用可能になっても、前の暗号化レベルのパケットを再送信する場合があるので、鍵はすぐに破棄されない

##### 4.10.1. 初期鍵の破棄

- 初期鍵で保護されたパケットは認証されない
- 攻撃者は接続を中断する目的で初期パケットをスプーフィングできる
- クライアントが最初にハンドシェイクパケットを送信するときに初期鍵を破棄する (MUST)
- サーバは、最初のハンドシェイクパケットを正常に処理したときに、初期鍵を破棄する (MUST)
- これにより、初期レベルでの損失回復状態は破棄され、未処理の初期パケットは無視される


### 5. パケット保護

- QUICは、TLSによって交渉したAEADアルゴリズムを使用して、TLSハンドシェイクによって導出した共通鍵でパケットを保護する

#### 5.1. パケット保護に使用する鍵

- 各暗号化レベルで、受信用と送信用の鍵がある
- 初期暗号化レベルを除く全ての暗号化レベルで、TLSが導出した秘密鍵を用いる
- 初期暗号化レベルの秘密鍵は、クライアントの初期宛先接続IDから求める
- TLSが提供する鍵導出関数 (HKDF-Expand-Label) を用いて、パケット保護に使用する鍵を求める
- 現在の暗号化レベルとラベル「quic key」を鍵導出関数に入力すると、鍵が生成される
- ラベル「quic iv」は初期ベクタ(IV)を導出するときに使う
- ラベル「quic hp」はヘッダ保護に使用する鍵を導出するときに使う

#### 5.2. 初期秘密鍵

- 初期パケットは、クライアントの初期パケットの接続先IDから導出した秘密鍵で保護される

```
initial_salt = 0xc3eef712c72ebb5a11a7d2432bb46365bef9f502
initial_secret = HKDF-Extract(initial_salt,
                              client_dst_connection_id)

client_initial_secret = HKDF-Expand-Label(initial_secret,
                                          "client in", "",
                                          Hash.length)
server_initial_secret = HKDF-Expand-Label(initial_secret,
                                          "server in", "",
                                          Hash.length)
```

- HKDF内のハッシュ関数は主に SHA-256
- クライアントの初期パケットの接続先IDはランダムに選んだ値をとる
- サーバがRetryパケットを送信したときは、サーバが接続先IDを選ぶ
- initial_salt は図に示す20バイトの16進数文字列「0xc3eef...f502」(**バージョンごとに変わる**)
- initial_saltは、QUICのバージョンごとに変わるので、鍵もバージョンによって異なる
- 付録Aに、初期パケット暗号化のテストベクトルが載っている

#### 5.3. AEADの使い方

- TLSが交渉したAEADを使う
- ヘッダを保護する前に、パケットを保護する
- 保護されていないパケットヘッダは関連データ (A) の一部になる
- ヘッダの保護を解除してから、パケットの保護を解除する
- バージョン交渉とRetryパケット以外の全てのQUICパケットは、AEADで保護される
- パケットの保護(認証付き暗号化)には、クライアントの最初の初期パケットの宛先接続IDから導出した鍵を使う
- AEADの出力には、16バイトの認証タグがあり、入力よりも16バイト大きい出力を生成する
- パケットを暗号する鍵と初期ベクタ(IV)の導出は、それぞれラベル「quic key」と「quic iv」を使う
- ノンス N は、パケット番号と初期ベクタを結合(XOR)したもの (AEADの入力で使う)
- A : AEADに入力する関連データ。メタデータ的な役割。QUICにおいては、ヘッダの内容が関連データとなり、短い・長いヘッダのフラグバイトからパケット番号まで
- P : 入力された平文
- C : 出力した暗号文

#### 5.4. ヘッダー保護

- パケット番号は、パケット暗号鍵と初期ベクタとは別に導出した鍵を使って暗号化する
- ヘッダの保護は、最初のバイトの最下位Nビットとパケット番号に対して行う
- 長いヘッダのときは、最下位4ビット
- 短いヘッダのときは、最下位5ビット
- 最下位Nビットには、予約ビット、パケット番号長、鍵フェーズが含まれる
- Retryパケットとバージョン交渉パケットのヘッダは保護しない

##### ヘッダー保護アプリケーション

- パケット保護をした後に、ヘッダー保護をする
- 暗号化したパケットの一部がサンプリングされて、ヘッダー保護のアルゴリズム(AEAD)へ入力される
- AEADの出力は5バイトのマスク
- マスクの最初の1バイトは、パケットの最下位NビットとXORする
- マスクの残りの4バイトは、パケット番号フィールドとXORする
- パケット番号が4バイト未満のとき、はみ出た残りのマスクは使われない
- 図6はヘッダー保護の擬似コード
- 保護を解除するときは、パケット番号長 `pn_length` が決まる順番が異なる

```fig
mask = header_protection(hp_key, sample)

pn_length = (packet[0] & 0x03) + 1
if (packet[0] & 0x80) == 0x80:
   # Long header: 4 bits masked
   packet[0] ^= mask[0] & 0x0f
else:
   # Short header: 5 bits masked
   packet[0] ^= mask[0] & 0x1f

# pn_offset is the start of the Packet Number field.
packet[pn_offset:pn_offset+pn_length] ^= mask[1:1+pn_length]
```

図6: Header Protection Pseudocode

- 図7は長いヘッダと短いヘッダで暗号化したパケット全体の様子
- 暗号化された部分は E で示されている

```fig
Long Header:
+-+-+-+-+-+-+-+-+
|1|1|T T|E E E E|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+  # Versionから
|                    Version -> Length Fields                 ...  # Lengthまでの
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+  # フィールド

Short Header:
+-+-+-+-+-+-+-+-+
|0|1|S|E E E E E|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|               Destination Connection ID (0/32..144)         ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Common Fields:
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|E E E E E E E E E  Packet Number (8/16/24/32) E E E E E E E E...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|   [Protected Payload (8/16/24)]             ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|             Sampled part of Protected Payload (128)         ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                 Protected Payload Remainder (*)             ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

- ヘッダー保護アルゴリズムは使用するAEADを決める必要がある (MUST)
  - AEAD_AES_128_GCM
  - AEAD_AES_128_CCM
  - AEAD_AES_256_GCM
  - AEAD_CHACHA20_POLY1305

##### ヘッダー保護のためのサンプリング

- ヘッダー保護アルゴリズム(AEAD)は、ヘッダー保護のための鍵と、暗号化したパケットから抽出したサンプルを使う
- 常に同じバイト数がサンプリングされる
- エンドポイントはパケット番号長を知らない
- 暗号化したパケットからサンプリングするとき、パケット番号長は4バイト（想定される最大エンコード長）が想定される
- サンプリングに十分なデータを使用できるように、エンコードされたパケット番号長と暗号化ペイロード長を合わせた長さが、ヘッダ保護に必要なサンプルより少なくとも4バイト長くなるように、パケットがパディングされる
- 例えば、パケット番号が1バイトのとき、保護されていないペイロードには少なくとも3バイトのフレームがある
- 例えば、パケット番号が2バイトのとき、保護されていないペイロードには少なくとも2バイトのフレームがある
- 短いヘッダを持つパケットでの、暗号化パケットのサンプリングは次のようになる

```txt
sample_offset = 1 + len(connection_id) + 4

sample = packet[sample_offset..sample_offset+sample_length]
```

- 例えば、8バイトの接続IDを持ち、AEAD_AES_128_GCM で暗号化したパケットを持つ短いヘッダの場合は、13〜28バイトの部分がサンプリングされる（ただし、インデックスは0バイトから数える）
- 訳注：ヘッダの最初(1byte) + 接続先ID(最大20byte. この例では8byte) + パケット番号(最大4byte) = 13byte

```txt
sample_offset = 7 + len(destination_connection_id) +
                    len(source_connection_id) +
                    len(payload_length) + 4
if packet_type == Initial:
    sample_offset += len(token_length) +
                     len(token)

sample = packet[sample_offset..sample_offset+sample_length]
```

##### AESに基づくヘッダー保護

- 以下のアルゴリズムについて定義する
  - AEAD_AES_128_GCM
  - AEAD_AES_128_CCM
  - AEAD_AES_256_GCM
- これらは暗号利用モードの ECB モードを使う
- AESに基づくアルゴリズムは、暗号化パケットから **16バイト** をサンプリングする
- サンプルは平文としてAESに入力する

```txt
mask = AES-ECB(hp_key, sample)
```

##### ChaCha20に基づくヘッダー保護

- 以下のアルゴリズムについて定義する
  - AEAD_CHACHA20_POLY1305
- [RFC8439 - ChaCha20 and Poly1305 for IETF Protocols](https://tools.ietf.org/html/rfc8439) の2.4節で定義されているChaCha20関数を使う
- 256ビットの鍵と、暗号化パケットからサンプリングした **16バイト** の文字列を使う
- サンプルの最初の4バイトはChaCha20のブロックカウンターに入力する (リトルエンディアンで解釈する)
- サンプルの残りの12バイトはChaCha20のノンスに入力する (リトルエンディアンで解釈する)
- 5つのゼロバイトを平文としてChaCha20に入力し、暗号化マスクを生成する

```txt
counter = sample[0..3]
nonce = sample[4..15]
mask = ChaCha20(hp_key, counter, nonce, {0,0,0,0,0})
```

#### 5.5. 保護されたパケットの受信

- あるパケット番号を持つパケットを受信したときについて、同じ鍵で保護を解除できないとき、または鍵更新があるとき、より大きいパケット番号を持つパケットは全て破棄する必要がある (MUST)

#### 5.6. 0-RTT鍵の使用

- 再送攻撃を防ぐために、0-RTTは暗号化する
- クライアントは基本的に 0-RTT と 1-RTT を同等に扱う
- 0-RTT鍵でACKを送信してはいけない (MUST NOT)
- サーバは0-RTT鍵を使用してはいけない (MUST NOT)
- クライアントは1-RTT鍵を導出したら、0-RTTパケットを送信してはいけない (MUST NOT)
- 注：0-RTTパケットの確認応答パケットは、サーバが1-RTT鍵で暗号化するので、ハンドシェイクが完了するまでクライアントは0-RTTパケットが受け取られたのかを確認できない

#### 5.7. 順不同で受信した暗号化フレーム

- 正しい順番に直したり、パケットが損失したりすることで、最終的なTLSハンドシェイクメッセージを受信する前に、保護されたパケットを受信するときがある

### 6. 鍵の更新

- ハンドシェイクが確認されると、エンドポイントは鍵の更新を開始できる
- 鍵フェーズビットは、使用されるパケット保護鍵を示す
- 鍵フェーズビットは、最初は0に設定され、鍵の更新ごとに0から1へ、1から0へと切り替えられる
- このメカニズムは TLS の KeyUpdate メッセージを置き換えるものである
- 下図は、鍵の更新処理を示す
- 使用している鍵 `@M` を、更新する鍵 `@N` に置き換える例
- 鍵フェーズビットの値は括弧 `[]` で示される

```fig
   Initiating Peer                    Responding Peer

@M [0] QUIC Packets

... Update to @N
@N [1] QUIC Packets
                      -------->
                                         Update to @N ...
                                      QUIC Packets [1] @N
                      <--------
                                      QUIC Packets [1] @N
                                    containing ACK
                      <--------
... Key Update Permitted

@N [1] QUIC Packets
         containing ACK for @N packets
                      -------->
                                 Key Update Permitted ...
```

図8: Key Update

#### 6.1. 鍵更新の開始

- ラベル「quic ku」を鍵導出関数に入力する
- 鍵の更新は以下のように HKDF-Expand-Label を使用する

```fig
secret_<n+1> = HKDF-Expand-Label(secret_<n>, "quic ku",
                                 "", Hash.length)
```

- エンドポイントは、鍵フェーズビットの値を切り替え、後続の全てのパケットを更新した鍵とIVで保護する
- 1-RTTパケット以外のパケットでは、鍵の更新は行われない
- 1-RTTパケット以外のパケットは、TLSハンドシェイク状態からのみ導出される

#### 6.2. 鍵更新への対応
#### 6.3. 受信鍵生成のタイミング
#### 6.4. 更新された鍵での送信
#### 6.5. 異なる鍵での受信
#### 6.6. 鍵更新の頻度
#### 6.7. 鍵更新のエラーコード


### 7. 初期メッセージのセキュリティ

- 初期パケットは秘密鍵で保護されていないので、改ざんされる可能性がある
- TLSメッセージの改ざんは検知できるが、ACKなどの改ざんは検知できない

### 8. QUIC固有のTLSハンドシェイク

### 9. セキュリティの考慮事項

- Replay Attacks with 0-RTT (0-RTTの再送攻撃)
  - 0-RTTは再送攻撃に対して脆弱
  - 0-RTTを無効にすることが、再送攻撃に対する最も効果的な防御策
- Packet Reflection Attack Mitigation (パケットリフレクション攻撃の軽減)
  - ClientHelloを複数のフラグメントにして送信し、トラフィックを増幅させる攻撃
  - QUICでは3つの対策が取られている
    - ClientHelloは最小サイズにパディングされる (MUST)
    - 検証していない送信元アドレスからは、3つ以上のUDPを送信することを禁止する
    - ハンドシェイクパケットの確認応答は認証されるので、攻撃者は偽造できない
- Header Protection Analysis (ヘッダー保護の解析)
- Header Protection Timing Side-Channels (ヘッダー保護のタイミング攻撃)
- Key Diversity (鍵の多様性)
