---
layout:        post
title:         "QUIC の Handshake Packet を復号する"
date:          2021-10-10
category:      Protocol
cover:         /assets/cover5.jpg
redirect_from:
comments:      true
published:     true
latex:         true
photoswipe:    true
syntaxhighlight: true
# sitemap: false
# feed:    false
---

QUIC の Initial Packet で交換したDiffie-Hellmanの公開鍵から共有鍵を導出し Handshake Packet を復号する処理を Python で実装してみます。

### QUIC の鍵スケジュール

まず、QUIC は TLS 1.3 の鍵スケジュールと同じようにパケット保護鍵を導出します。
簡単に説明すると、**鍵スケジュール**は主鍵から副鍵を生成する手順と鍵の使用場面を決めた一覧のことです。
主鍵から副鍵を生成することを**鍵導出**といい、一方向性関数を使うため逆操作である副鍵から主鍵を求めることはできません。正しく鍵導出ができるとクライアントとサーバで同じ鍵である**共有鍵**を得ることができます。
一般的に主鍵はDiffie-Hellman鍵交換などで共有しますが、事前共有鍵を使う場合もあります。
主鍵はマスターシークレットとも呼ばれますが、ここではHandshakeパケットの復号に注目しているので、Diffie-Hellman鍵交換で得られた共有鍵 (ハンドシェイクシークレット) のことを主鍵と呼ぶことにします。

一方向性関数は TLS 1.3 ([RFC 8446](https://datatracker.ietf.org/doc/html/rfc8446)) で使用している HKDF ([RFC 5869](https://datatracker.ietf.org/doc/html/rfc5869)) を使用します。
ハッシュベースの鍵導出関数 HKDF は、HMAC を使って安全な擬似乱数鍵を生成する関数です。
HKDF は2種類の関数 HKDF-Extract と HKDF-Expand があります。
HKDF-Extract は入力がパスワードや(EC)DH鍵共有などの一様分布ではない共有の秘密の値であっても、出力が安全な擬似乱数となる関数です[^RFC5869][^1]。
もう一つの HKDF-Expand は、入力の擬似乱数鍵を使って、指定の長さの（入力よりも長い）擬似乱数鍵を出力するための関数です。

[^RFC5869]: [RFC 5869](https://datatracker.ietf.org/doc/html/rfc5869#section-1) の In many applications, the input keying material is not necessarily distributed uniformly, ... あたりに HKDF-Extract が必要な場合について書かれています。

[^1]: HKDF-Extractへ入力する値は IKM（Input Keying Material) と呼びます。

関数 Derive-Secret は内部で関数 HKDF-Expand-Label を呼び出しているので、この2つはほぼ同じものです（Derive-Secret の定義は [RFC 8446 - 7.1](https://datatracker.ietf.org/doc/html/rfc8446#section-7.1) を参照）。

QUIC のハンドシェイク暗号化・復号鍵は TLS 1.3 の鍵スケジュールに基づいていますが、最後の部分だけ QUIC 独自の鍵導出処理になっています。
TLS 1.3 の鍵スケジュールは
[RFC 8446 - 7.1. Key Schedule](https://datatracker.ietf.org/doc/html/rfc8446#section-7.1)
に書かれています。
そして、導出した client/server_handshake_traffic_secret から HKDF-Expand-Label を使って QUIC パケットの暗号化に使う鍵(Key)、初期ベクタ(IV)、ヘッダー保護鍵(Header Protection Key; HP Key)を導出します。
以下は TLS 1.3 の鍵スケジュールで、赤の点線で囲んだ部分が QUIC 独自の鍵スケジュールです。

<figure>
<img src="{{ site.baseurl }}/media/post/quic/quic-handshake-packet-decrypt-keyschedule.png" />
<figcaption>QUICのハンドシェイク鍵導出プロセス</figcaption>
</figure>

Key、IV、HP Key の3つを使ってパケットを復号する手順は前の記事「[QUIC の Initial Packet を復号する](http://localhost:4000/blog/protocol/quic-initial-packet-decrypt)」で説明していますが、簡単に説明すると、
QUICパケットを復号するには (1) HP Key を使ってヘッダー保護を解除して、(2) Key、IV を使ってペイロードの暗号化を解除します。

### QUIC 上でDiffie-Hellman鍵交換

続いて、パケットを暗号化・復号する副鍵を生成するための元となる主鍵をクライアント・サーバ間で共有する方法について説明します。

TLS 1.3 では Client Hello と Server Hello はTLS拡張の部分に key_share があり、そこで鍵共有で使用するDiffie-Hellmanの群（Group）を指定して公開鍵（32byte程度）を送信します。
QUIC でも同様に、ペイロード内のCRYPTO Frameの中にあるClient HelloやServer HelloのTLS拡張で、(EC)DHEの公開鍵をお互いに送り合います。

以下はClient Helloに含まれている key_share というTLS拡張の内容を表示したものです。
図中に表示していませんが、今回は supported_groups というTLS拡張で、鍵交換アルゴリズムに x25519 を使うことを宣言しています（実際には複数のアルゴリズムを宣言し、サーバがその中から1つ使いたいアルゴリズムを宣言し返します）。
なので、key_share には x25519 で導出した公開鍵が格納されています。

<figure>
<img src="{{ site.baseurl }}/media/post/quic/quic-kex-client-hello-key-exchange.png" />
<figcaption>QUICのClient Helloにある(EC)DHE公開鍵</figcaption>
</figure>

サーバ側は受信した Client Hello の supported_groups TLS拡張を確認して、鍵交換で使用するアルゴリズムを決定し、それに伴う公開鍵を key_share に含めて送信します。

<figure>
<img src="{{ site.baseurl }}/media/post/quic/quic-kex-server-hello-key-exchange.png" />
<figcaption>QUICのServer Helloにある(EC)DHE公開鍵</figcaption>
</figure>

TLS における x25519 での(EC)DH鍵交換の手順は次の通りです。
ここではクライアントは C、サーバは S で表し、小文字 $c, s$ はスカラー値、大文字 $C, S$ は楕円曲線上の座標を表しています。

1. ランダムな値を生成し、秘密鍵 $c_\text{sec}$ とする
2. x25519 の関数に自分の秘密鍵を入力して、公開鍵 $C_\text{pub} = c_\text{sec} G$ を生成する（内部的にはベースポイントは固定値 $G$ を使い、自分の秘密鍵の値で楕円曲線上のスカラー倍算し、その結果をバイト列にして出力する）
3. 自分の公開鍵を Client/Server Hello に入れて送信する
4. 受信した Server/Client Hello から相手の公開鍵を取得する
5. x25519 の関数に相手の公開鍵 $S_\text{pub}$ と自分の秘密鍵を入力して、共有鍵 $K = c_\text{sec} S_\text{pub}$ を生成する（内部的にはベースポイントは相手の公開鍵の値を使い、自分の秘密鍵の値で楕円曲線上のスカラー倍算し、その結果をバイト列にして出力する）

ECDHEでの鍵について表にまとめると以下のようになります。

|                | クライアント                         | サーバ
|----------------|------------------------------------|-------------------------------|
| (1) ECDHE秘密鍵 | $c_\text{sec}$                     | $s_\text{sec}$
| (2) ECDHE公開鍵 | $C_\text{pub} = c_\text{sec} G$    | $S_\text{pub} = s_\text{sec} G$
| (3) ECDHE共有鍵 | $K = c_\text{sec} S_\text{pub}$    | $K = s_\text{sec} C_\text{pub}$

以上の流れをプログラム的に書くと次のようになります（注意：疑似コードなので動きません）。

```python
from crypto_x25519 import x25519

# DH秘密鍵
secret_key = bytes.fromhex('6923bcdc7b80831a7f0d6fdfddb8e1b5e2f042cb1991cb19fd7ad9bce444fe63')
# ^^^^^^^^実際には暗号学的に安全な擬似乱数生成関数を使って文字列を生成すること！

# DH公開鍵
public_key = x25519(secret_key) # C_{pub} = c_{sec}*G

# Client Hello に格納して送信する
print(public_key.hex())
# => 5f1d5eeaa423010eecf09c19d5ec777de8ed9440687a61c0c75ab57134671c53
crypto_frame = Frame(
    frame_type=FrameType.CRYPTO,
    frame_content=CryptoFrame(
        offset=VarLenIntEncoding(Uint8(0)),
        data=Handshake(
            msg_type=HandshakeType.client_hello,
            msg=ClientHello(
                legacy_version=Uint16(0x0303),
                legacy_session_id=OpaqueUint8(b''),
                cipher_suites=CipherSuites([
                    CipherSuite.TLS_AES_128_GCM_SHA256,
                ]),
                extensions=Extensions([
                    ...
                    Extension(
                        extension_type=ExtensionType.key_share,
                        extension_data=KeyShareHello(
                            shares=KeyShareEntrys([
                                KeyShareEntry(
                                    group=NamedGroup.x25519,
                                    key_exchange=OpaqueUint16(public_key) # <= ここに格納
    ...


# ...(省略)...

# 受信した Server Hello からECDH鍵交換の公開鍵を取得する
for ext in server_hello.msg.extensions:
    if ext.extension_type == ExtensionType.key_share:
        peer_share = ext.extension_data.shares
        break
peer_public_key = peer_share.key_exchange.get_raw_bytes()

# DH共有鍵
shared_key = x25519(secret_key, peer_public_key) # K = c_{sec}*S_{pub}
print(shared_key.hex())
# => 6def0fe20a2d0aae66c7d52947c977b346c5ee1fa441ba11e2feece47c4a9e57
```

x25519 の Python 実装が欲しい方は、昔筆者が実装した[tex2e/elliptic-curves: Elliptic Curves for Security (RFC 7748)](https://github.com/tex2e/elliptic-curves)に x25519 と x448 のプログラムがあるので、参考にしてみてください。
以上で、DH共有鍵のバイト列が得られます。

### 実装に関する話

TLS 1.3 の鍵導出のプログラムですが、自作 TLS 1.3 の [mako-tls13/protocol_tlscontext.py](https://github.com/tex2e/mako-tls13/blob/master/protocol_tlscontext.py) にある、key_schedule_in_handshake メソッドとかを参考にしてください (説明丸投げで済みません)。
やっていることは順番に HKDF の関数を呼び出して、その結果を別の関数に入れて、みたいな作業だけなので、上で示した鍵導出の図と比較しながら読めば難しくはないと思います。
少しだけ図について補足すると、引数で `ClientHello...ServerHello` と書かれている部分は「Client Hello から Server Hello の全ての Handshake レコードのバイト列」という意味です。
これは、Derive-Secret で `Transcript-Hash(ClientHello...ServerHello)` のように、今までの通信内容のハッシュ値として使われます。
クライアントとサーバで同じバイト列を送信・受信していることを鍵導出で検知できるように、このようなプロトコル設計になっていると思われます。

また、QUICで受信したCRYPTO Frameはそのまま復号しても認証タグ不一致エラーが発生する場合があります。
理由としては、CRYPTO Frameで送られてくるTLSメッセージは分割される場合があるからです。
rust の QUIC 実装である quiche では、ハンドシェイクパケットのTLSメッセージは2つに分割されて送られてきました。
なので、CRYPTO Frameのペイロードのバイト列を全て結合してから、鍵スケジュールで求めたハンドシェイク鍵を使って復号しないといけない点に注意が必要です。

自作QUICでは、Initial Packet送受信後にサーバから送られた EncryptedExtensions, Certificate, CertificateVerify, Finished の4つのハンドシェイクを正しく復号できました。
次のプログラムは、解析するときのコードです。

```python
crypto_frame_split_stream_len = len(crypto_frame_split_bytes)
crypto_frame_split_stream = io.BytesIO(crypto_frame_split_bytes)
while crypto_frame_split_stream.tell() < crypto_frame_split_stream_len:
    handshake = Handshake.from_stream(crypto_frame_split_stream)
    print(handshake)
```

復号したデータを TLS の Handshake データ構造として解析し、EncryptedExtensions, Certificate, CertificateVerify, Finished の4つを出力した結果は以下のようになりました。

```output
00000000: 08 00 00 83 00 81 00 10  00 05 00 03 02 68 33 00  .............h3.
00000010: 39 00 74 00 14 1A 26 DC  5B D9 62 5E 2B CD 0E FD  9.t...&.[.b^+...
00000020: 3A 32 9C E8 31 36 A3 22  95 01 04 80 00 75 30 03  :2..16.".....u0.
...(省略)...
00000530: BF 79 CA 14 00 00 20 1F  A7 31 6E 12 FF 8C 6C B1  .y.... ..1n...l.
00000540: 21 D5 D6 9B E4 47 01 87  28 F6 10 2F 68 15 AE 06  !....G..(../h...
00000550: D5 1D CE BC 84 09 92                              .......

Handshake:
+ msg_type: HandshakeType.encrypted_extensions(Uint8(0x08))
+ length: Uint24(0x000083)
+ msg: EncryptedExtensions:
  + extensions: List<Uint16>:
    + Extension:
      + extension_type:
        ExtensionType.application_layer_protocol_negotiation(Uint16(0x0010))
      + length: Uint16(0x0005)
      + extension_data: Opaque[5](b'\x00\x03\x02h3')
    + Extension:
      + extension_type: ExtensionType.quic_transport_parameters(Uint16(0x0039))
      + length: Uint16(0x0074)
      + extension_data: List<lambda>:
        + QuicTransportParam:
          + param_id: QuicTransportParamType.original_destination_connection_id(Va
            rLenIntEncodingUint8(0x00))
          + param_value: Opaque<VarLenIntEncoding>(b'\x1a&\xdc[\xd9b^+\xcd\x0e\xfd
            :2\x9c\xe816\xa3"\x95')
        + QuicTransportParam:
          + param_id:
            QuicTransportParamType.max_idle_timeout(VarLenIntEncodingUint8(0x01))
          + param_value: Opaque<VarLenIntEncoding>(b'\x80\x00u0')
        + QuicTransportParam:
          + param_id: QuicTransportParamType.max_udp_payload_size(VarLenIntEncodin
            gUint8(0x03))
          + param_value: Opaque<VarLenIntEncoding>(b'EF')
        + QuicTransportParam:
          + param_id:
            QuicTransportParamType.initial_max_data(VarLenIntEncodingUint8(0x04))
          + param_value: Opaque<VarLenIntEncoding>(b'\x80\x98\x96\x80')
        + QuicTransportParam:
          + param_id: QuicTransportParamType.initial_max_stream_data_bidi_local(Va
            rLenIntEncodingUint8(0x05))
          + param_value: Opaque<VarLenIntEncoding>(b'\x80\x0fB@')
        + QuicTransportParam:
          + param_id: QuicTransportParamType.initial_max_stream_data_bidi_remote(V
            arLenIntEncodingUint8(0x06))
          + param_value: Opaque<VarLenIntEncoding>(b'\x80\x0fB@')
        + QuicTransportParam:
          + param_id: QuicTransportParamType.initial_max_stream_data_uni(VarLenInt
            EncodingUint8(0x07))
          + param_value: Opaque<VarLenIntEncoding>(b'\x80\x0fB@')
        + QuicTransportParam:
          + param_id: QuicTransportParamType.initial_max_streams_bidi(VarLenIntEnc
            odingUint8(0x08))
          + param_value: Opaque<VarLenIntEncoding>(b'@d')
        + QuicTransportParam:
          + param_id: QuicTransportParamType.initial_max_streams_uni(VarLenIntEnco
            dingUint8(0x09))
          + param_value: Opaque<VarLenIntEncoding>(b'@d')
        + QuicTransportParam:
          + param_id: QuicTransportParamType.ack_delay_exponent(VarLenIntEncodingU
            int8(0x0a))
          + param_value: Opaque<VarLenIntEncoding>(b'\x03')
        + QuicTransportParam:
          + param_id:
            QuicTransportParamType.max_ack_delay(VarLenIntEncodingUint8(0x0b))
          + param_value: Opaque<VarLenIntEncoding>(b'\x19')
        + QuicTransportParam:
          + param_id: QuicTransportParamType.disable_active_migration(VarLenIntEnc
            odingUint8(0x0c))
          + param_value: Opaque<VarLenIntEncoding>(b'')
        + QuicTransportParam:
          + param_id: QuicTransportParamType.initial_source_connection_id(VarLenIn
            tEncodingUint8(0x0f))
          + param_value: Opaque<VarLenIntEncoding>(b'\x8e\xbe\x80\xa3\x1f\x1e\n\xa
            c\\\xd2\x19\xef\x0e\xcb\xc2f*\xa5\x9b\xc5')
        + QuicTransportParam:
          + param_id: QuicTransportParamType.retry_source_connection_id(VarLenIntE
            ncodingUint8(0x10))
          + param_value: Opaque<VarLenIntEncoding>(b'\x8e\xbe\x80\xa3\x1f\x1e\n\xa
            c\\\xd2\x19\xef\x0e\xcb\xc2f*\xa5\x9b\xc5')
Handshake:
+ msg_type: HandshakeType.certificate(Uint8(0x0b))
+ length: Uint24(0x0003a0)
+ msg: Certificate:
  + certificate_request_context: Opaque<Uint8>(b'')
  + certificate_list: List<Uint24>:
    + CertificateEntry:
      + cert_data: Opaque<Uint24>(b'0\x82\x03\x930\x82\x02{\xa0\x03\x02\x01\x02\x
        02\x14j=\xba\x0f,\xeb\xd9oQ\xf2;\x8a\x9bjM\xca\xbbZ\xb6-0\r\x06\t*\x86H\x
        86\xf7\r\x01\x01\x0b\x05\x000Y1\x0b0\t\x06\x03U\x04\x06\x13\x02AU1\x130\x
        11\x06\x03U\x04\x08\x0c\nSome-State1!0\x1f\x06\x03U\x04\n\x0c\x18Internet
        Widgits Pty Ltd1\x120\x10\x06\x03U\x04\x03\x0c\tquic.tech0\x1e\x17\r18093
        0221148Z\x17\r190930221148Z0Y1\x0b0\t\x06\x03U\x04\x06\x13\x02AU1\x130\x1
        1\x06\x03U\x04\x08\x0c\nSome-State1!0\x1f\x06\x03U\x04\n\x0c\x18Internet
        Widgits Pty Ltd1\x120\x10\x06\x03U\x04\x03\x0c\tquic.tech0\x82\x01"0\r\x0
        6\t*\x86H\x86\xf7\r\x01\x01\x01\x05\x00\x03\x82\x01\x0f\x000\x82\x01\n\x0
        2\x82\x01\x01\x00\xaa\xb4\xb7\xd1\xf9\xe4#\xa4>\xe5"\xac\x05y\x08\xc2xN\x
        eb\\\x7fZ\x0bt\xce\x8eO\xfbL\x93\x01\x90\xd8U\x8bD\x85\x19_\x98\x9d\xde\x
        b0I^;Y\xea\xe4\xcbL\xdd\xdf\xbaiPI\x97\x0bS\x8b\xcaA;5_&Ig\xc5\xdd;7z\xca
        \x87q\xd9la\xf2n8I\x14d\xfdS\x8b\x14\xad\xc2\x9c\n\x94\x8a%\xa1.\xec\x84,
        A\x0b5\x1e\x1d\x01\xeb\xb3\x1e\xa8\x91\xb7\x17\xb3\x9c`!w9p\xb5\xd5b\xb7\
        n\xd0\xc3)\xc2\xdc\xb1\xad\xb1\xf9b&\xce\xc3\xdfk,\xc4\x8d\x0e\x04-5C?\xb
        d\xe8@dz\x0fq\xdaY\xab\x8a\x11.\t\x8c\x8fB2\x7f\x04%\x10\x9c\xc6<\x1e\xb7
        \xe78Sy\x10\x83l\xf9(6\xe8\xa0\x17\xc2~\xbc\xe6_\x7f\xc4\xa4\xc7\xffE\xa0
        \x12iKY\x17y |4\xfa\xe3\xc7H\te(\x8a\x96\xab\xa3U{\xde\x986\xbc7\xb9F\xc0
        )\xe2}@\xedP\x98\xe3\xc5o\x18L\xfdB\x07)\xf1\x01s\xb6\x91I\x9f\x02\x03\x0
        1\x00\x01\xa3S0Q0\x1d\x06\x03U\x1d\x0e\x04\x16\x04\x14\x14\xe9R!\xe6\x07\
        xff\x8dB7\x90O\xff\xcc<\x17w\xbf~F0\x1f\x06\x03U\x1d#\x04\x180\x16\x80\x1
        4\x14\xe9R!\xe6\x07\xff\x8dB7\x90O\xff\xcc<\x17w\xbf~F0\x0f\x06\x03U\x1d\
        x13\x01\x01\xff\x04\x050\x03\x01\x01\xff0\r\x06\t*\x86H\x86\xf7\r\x01\x01
        \x0b\x05\x00\x03\x82\x01\x01\x00e\xae\xd7+s2\xe0\x9a^H\xbc\xf4\x04\x08\xf
        8\xe1\x0b`\x84g`\xf7\xc4\x05Gx\x99\x12y\xf4\\-=\x1e\xb9!n6\x91\xf0\xc6\xb
        7v}\x10\xc8\xc0\xd1\xb8\xf2\xcb6^c\xddU\xae\xac:\xa7\x80C[\xb8\x92A<i\x02
        O:3\x15\xf3\x14\xe8\xc6s\x18\xb2\xb5\x962"\x1b9\x0c]Q\x1ajd\xa3\xec`\xc9\
        xd9\xe4v\x8bg\x01\xba\x08\x8cb\xfe\xcd\xfd\xef\x05m#\x11\x05z\x18T\xf8\xe
        e\x92\x80<C\x00\xc9\x85/\xe87\x8e\xef\xb7O\x95\xb18\xb9\xc1\xa8}w{tD*\xee
        \x01\xef\xf8LD\xe8\x8c\xfcclA\x93C\xbd]\x99N\xba\xc4\xf6L\xaez\xa5\x18#Z\
        xe2CvjP\x835\xf4\xa0\xd7$i\xe2=t\xcd)\x8a\xd21\xc4\x1c\xeb\xa2\x1eX\x96\x
        fd\x97>h\xb1\x05qPu@y\x88\xca\xf7\x01"\x12\xa2\xb86\xdfnE\xab\xa9(\x9e\x9
        7\xa9\xcbI\xc2/\x84\x96\x89:\xb1\xb3A\x80_\x8d\xe6xL\xed& rT\xa27 d')
      + extensions: List<Uint16>:
Handshake:
+ msg_type: HandshakeType.certificate_verify(Uint8(0x0f))
+ length: Uint24(0x000104)
+ msg: CertificateVerify:
  + algorithm: SignatureScheme.rsa_pss_rsae_sha256(Uint16(0x0804))
  + signature: Opaque<Uint16>(b'.\xf36_\x1f\x15`|\x82zd7^\xae\xc1\x1b\xff\x11\xf
    7\xda.O\x96\x9f\xb3\xcb}B\xa1\xed\x98\xcb\xb7\xe6gzp\xef\xc8\r%\xce4?\xa3\xb
    8\xaeA\x91\x982I\xa6\xb2v\xae\xc4\x9a\xb2\x07\xa5-\x0b\'\n\xab\xedb\xf0\xeb5
    ]\xcdk\\\xf7\xc0\x9a8\r\xfb\x14\x9bQ\xcf\xbcG\x8a\xbf\xa4N\xc2\xc4\xbb]\xd4$
    hq\x03o\xb2jT\xb6&\xb2r\xd8\xdf\x1b\x8f\x90U\xbbu#\xda\xb4\xbf\xc2T\xb8\xd3;
    \xb3%o\x04\xb1\xedQ:\x80\xe3Ab\xaco\x9d_\x94\x10\x80\x92.\x88\xac\xdd<L\xc58
    [\xd0vS\x00\xb1Z^\xc9\xaeO\xca\x01\xe5\xd6\xfd\xaaa\xa2-\'$\xd7~\xb8 {\x93.\
    xf4\x0e\xb6d\x84\xc6H\x0bA\t"\xbd\xddgw\xcdO7:W\xb7|\x99H@,\xfb\\W\x92\x84\x
    fe\xa3\x9d\xfc7\x99\x9b\xc7\x9f\x97{e\x9a}\xc5\n^\x17IY\xc8\x8b\x10@\x7f\x02
    \xea>oA\n\x04\xdd\xda,\x18GG\xf5\x1d\xbfy\xca')
Handshake:
+ msg_type: HandshakeType.finished(Uint8(0x14))
+ length: Uint24(0x000020)
+ msg: Finished:
  + verify_data: Opaque<Uint24>(b'n\x12\xff\x8cl\xb1!\xd5\xd6\x9b\xe4G\x01\x87(\
    xf6\x10/h\x15\xae\x06\xd5\x1d\xce\xbc\x84\t\x92')
```

### まとめ

前回までの記事を含めて、Initial Packet と Handshake Packet の暗号化についてまとめると次のようになります。

- Initial Packet は公開情報のみで暗号化されるため、パケットは誰でも復号できる
    - 鍵スケジュールでは、主鍵として「クライアントの宛先コネクションID (DCID)」が使われる
    - クライアントのDCIDは通信を盗聴した第三者も取得できる値
- Handshake Packet はInitial Packet送受信後の通信のため、DH鍵交換した同士しか復号できない
    - 鍵スケジュールでは、主鍵として「(EC)DHEで鍵交換して得られた共有鍵」が使われる
    - (EC)DHEの公開鍵を盗聴しただけでは、離散対数問題により秘密鍵を求めることができないため、攻撃者は共有鍵の値も知ることができない

### おわりに

サーバ側から送られてきたハンドシェイクの復号まで完了したので、次はクライアント側が送るFinishedの作成・送信と、アプリケーションプロトコル周りの調査を進めていきたいところです。
自分自身がまだHTTP/2プロトコルの深い部分まで理解していないので、遠回りになりそうだなと思いつつ、ゆっくり進めていきたいと思います。

以上です。

---
