---
layout:        post
title:         "QUIC の TLS ClientHello を解析する"
date:          2021-08-16
category:      Protocol
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

QUICパケットのペイロードにはTLSメッセージを運ぶため CRYPTO フレームがあり、ここにTLSハンドシェイクで使うClientHelloやServerHelloなどが格納されます。
QUICパケット内のTLSハンドシェイクメッセージのバイト列をPythonで解析してデータ構造を復元してみます。

本記事は、前回の「[QUIC の Initial Packet を復号する](./quic-initial-packet-decrypt)」の続きとなります。
前回は、暗号化されたQUICのペイロードを復号する実装を行いました。

### 1. CRYPTOフレーム内の Client Hello を解析する

QUICパケットのペイロードには複数のフレームが含まれています。
前の記事で復号した Client Initial Packet には 0x06 から始まる CRYPTO フレームと 0x00 のパディングフレームの2種類が含まれていました ([RFC 9001 - A.2. Client Initial](https://www.rfc-editor.org/rfc/rfc9001#section-a.2))。
また、Server Initial Packet には 0x02 から始まる ACK フレームと 0x06 の CRYPTO フレームが含まれていました。

CRYPTOフレームのデータ構造は次の通りです。0x06 から始まり、[可変長整数エンコード (Variable-Length Integer Encoding)](https://www.rfc-editor.org/rfc/rfc9000.html#section-16) でエンコードされた整数 Offset と Length があり、データ長 Length 分のデータ (Crypto Data) から構成されます ([RFC 9000 - 19.6. CRYPTO Frames](https://www.rfc-editor.org/rfc/rfc9000.html#section-19.6))。

```
CRYPTO Frame {
  Type (i) = 0x06,
  Offset (i),
  Length (i),
  Crypto Data (..),
}
```

ACKフレームのデータ構造は次の通りです。0x02 または 0x03 から始まり、可変長整数エンコードされた整数が4つ続いた後に、データが続きます。
なお、ACK Range Count が 0 のときは、ACK Range にデータは入りません。0x03 から始まる場合のみ輻輳状況を表す ECN Counts にデータが入ります
([RFC 9000 - 19.3. ACK Frames](https://www.rfc-editor.org/rfc/rfc9000.html#section-19.3))。

```
ACK Frame {
  Type (i) = 0x02..0x03,
  Largest Acknowledged (i),
  ACK Delay (i),
  ACK Range Count (i),
  First ACK Range (i),
  ACK Range (..) ...,
  [ECN Counts (..)],
}
```

PADDINGフレームのデータ構造は次の通りです。0x00 の 1byte だけで、名前の通り、サイズを合わせるための詰め物的な扱いです ([RFC 9000 - 19.1. PADDING Frames](https://www.rfc-editor.org/rfc/rfc9000#section-19.1))。
クライアントが送信するInitial Packetは少なくとも1200 bytesである必要があるため、サイズを合わせるために、このフレームが使われます ([RFC 9000 - 8.1. Address Validation during Connection Establishment](https://www.rfc-editor.org/rfc/rfc9000#section-8.1))。

```
PADDING Frame {
  Type (i) = 0x00,
}
```

解析するために最低限必要なフレームの説明をしましたので、次にこれらのバイト列をデータ構造で解析してオブジェクトに変換するクラスを定義していきます。
前回と同じように、自作のバイト列変換クラス群の [metastruct.py, metatype.py](https://gist.github.com/tex2e/a55cfe8f006799ff745dc888a0149183) を使ってデータ構造を定義します。

metatype.py について簡単に説明をすると、Uint8 は整数と1byteバイト列の変換クラス、VarLenIntEncoding はQUIC特有の可変長整数エンコードを行うクラス、Enum はバイト列に変換可能な列挙体クラス、List はデータが終了するまで先頭から同じ型で解析を繰り返すクラスです。QUICパケットの平文ペイロードには、複数のフレームが存在するため、List形式のデータ構造解析を行います。

```python
from metatype import Uint8, VarLenIntEncoding, Type, Enum, List
import metastruct as meta
from protocol_tls13_handshake import Handshake

class FrameType(Enum):
    elem_t = VarLenIntEncoding

    PADDING = VarLenIntEncoding(Uint8(0x00))
    ACK = VarLenIntEncoding(Uint8(0x02))
    CRYPTO = VarLenIntEncoding(Uint8(0x06))

class Padding(Type):
    def __init__(self, padding: bytes):
        self.padding = padding

    @classmethod
    def from_stream(cls, fs, parent=None):
        padding = bytearray()
        while True:
            data = fs.read(1)
            if len(data) <= 0:
                break
            if data == b'\x00':
                padding.append(ord(data))
            else:
                fs.seek(-1, 1) # seek -1 from current position (1)
        return Padding(padding)

    def __bytes__(self):
        return self.padding

    def __repr__(self):
        return 'Padding[%d]' % (len(self.padding) + 1)

@meta.struct
class AckFrame(meta.MetaStruct):
    largest_acknowledged: VarLenIntEncoding
    ack_delay: VarLenIntEncoding
    ack_range_count: VarLenIntEncoding   # ここでは = 0 として、ACK Ranges は存在しないものとする
    first_ack_range: VarLenIntEncoding
    # ack_range: AckRange

@meta.struct
class CryptoFrame(meta.MetaStruct):
    offset: VarLenIntEncoding
    length: VarLenIntEncoding
    data: Handshake

@meta.struct
class Frame(meta.MetaStruct):
    frame_type: FrameType
    frame_content: meta.Select('frame_type', cases={
        FrameType.PADDING: Padding,
        FrameType.ACK: AckFrame,
        FrameType.CRYPTO: CryptoFrame,
    })
```
注意点として、Paddingクラスについて、0x000000 というペイロードがあれば、本来は3つのPaddingフレームがあると解釈しますが、表示する時に煩わしいので、一つにまとめています。
また、ACK Frameについては私自身の理解が未完全で、実装が手間かつ今回の平文にはACK Rangeが存在しないため、ACK Rangeの部分は未実装です。

上記のプログラムで、metastruct.py の meta.Select について簡単に説明をすると、条件に応じてそれ以下のデータ構造が変化することを表すために Select(フィールド名, cases={パターンマッチ: クラス名, ...}) というものを用意しています。
これは TLS 1.3 実装時に同じ名前のデータ名でもクライアントとサーバでわずかにデータ構造が異なることを表現するために実装した関数です。
TLS 1.3 で作ったものをそのまま再利用できているので、昔の自分を褒めてやりたい気持ちです。

さて、ここまででフレームのデータ構造を定義できました。
あとはCRYPTOフレームのデータ部分に入っているデータの解析ですが、その部分にはTLS 1.3のHandshakeデータ構造が入っているので、筆者の[自作 TLS 1.3](https://github.com/tex2e/mako-tls13) から Handshake 以下のデータ構造を表すクラスを全て持ってきます。
Handshakeの中にClientHelloが存在し、その中には暗号スイートの一覧やTLS拡張の一覧などが存在するので、上記のレポジトリのProtocol関連のプログラム protocol_*.py を全て持ってきました（組み込み時の詳細な流れは省略します）。

これで、ペイロードに含まれているフレーム一覧と、CRYPTOフレームの中にあるTLSメッセージ (Handshake以下のデータ構造) が解析できるようになりましたので、バイト列を読み込ませます。

まず、平文ペイロードのバイト列は次のような感じでした。

```
00000000: 06 00 40 F1 01 00 00 ED  03 03 EB F8 FA 56 F1 29  ..@..........V.)
00000010: 39 B9 58 4A 38 96 47 2E  C4 0B B8 63 CF D3 E8 68  9.XJ8.G....c...h
00000020: 04 FE 3A 47 F0 6A 2B 69  48 4C 00 00 04 13 01 13  ..:G.j+iHL......
00000030: 02 01 00 00 C0 00 00 00  10 00 0E 00 00 0B 65 78  ..............ex
00000040: 61 6D 70 6C 65 2E 63 6F  6D FF 01 00 01 00 00 0A  ample.com.......
00000050: 00 08 00 06 00 1D 00 17  00 18 00 10 00 07 00 05  ................
00000060: 04 61 6C 70 6E 00 05 00  05 01 00 00 00 00 00 33  .alpn..........3
00000070: 00 26 00 24 00 1D 00 20  93 70 B2 C9 CA A4 7F BA  .&.$... .p......
00000080: BA F4 55 9F ED BA 75 3D  E1 71 FA 71 F5 0F 1C E1  ..U...u=.q.q....
00000090: 5D 43 E9 94 EC 74 D7 48  00 2B 00 03 02 03 04 00  ]C...t.H.+......
000000A0: 0D 00 10 00 0E 04 03 05  03 06 03 02 03 08 04 08  ................
000000B0: 05 08 06 00 2D 00 02 01  01 00 1C 00 02 40 01 00  ....-........@..
000000C0: 39 00 32 04 08 FF FF FF  FF FF FF FF FF 05 04 80  9.2.............
000000D0: 00 FF FF 07 04 80 00 FF  FF 08 01 10 01 04 80 00  ................
000000E0: 75 30 09 01 10 0F 08 83  94 C8 F0 3E 51 57 08 06  u0.........>QW..
000000F0: 04 80 00 FF FF 00 00 00  00 00 00 00 00 00 00 00  ................
00000100: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
...省略...
00000480: 00 00 00 00 00 00 00 00  00 00                    ..........
```

ペイロードに含まれているフレーム一覧を解析するFramesクラスに読み込ませて、データ構造のオブジェクトを作成させます。

```python
Frames = List(size_t=lambda self: len(plaintext_payload_bytes), elem_t=Frame)

frames = Frames.from_bytes(plaintext_payload_bytes)
print(frames)
```

解析結果を出力すると以下のようになりました。
Handshake.msg_type が 0x01 (ClientHello) であり、
ClientHello 内の暗号スイート (cipher_suites) の一覧が正しく表示されているあたりから、ClientHelloのデータ構造として正しく解析できていることが確認できます。
TLS拡張 (Extension) については全ての構造を完全に定義しているわけではないので、一部はそのまま Opaque (ただのバイト列) になっていますが、supported_versions や supported_groups、signature_algorithms、key_share あたりの ClientHello で重要となるTLS拡張は正しく解析できています。

```output
List<lambda>:
+ Frame:
  + frame_type: FrameType.CRYPTO(QuicUint8(0x06))
  + frame_content: CryptoFrame:
    + offset: QuicUint8(0x00)
    + length: QuicUint16(0x00f1)
    + data: Handshake:
      + msg_type: HandshakeType.client_hello(Uint8(0x01))
      + length: Uint24(0x0000ed)
      + msg: ClientHello:
        + legacy_version: Uint16(0x0303)
        + random: Opaque[32](b'\xeb\xf8\xfaV\xf1)9\xb9XJ8\x96G.\xc4\x0b\xb8c\xcf\xd3\xe8h\x04\
          xfe:G\xf0j+iHL')
        + legacy_session_id: Opaque<Uint8>(b'')
        + cipher_suites: List<Uint16>[CipherSuite.TLS_AES_128_GCM_SHA256(Uint16(0x1301)),
          CipherSuite.TLS_AES_256_GCM_SHA384(Uint16(0x1302))]
        + legacy_compression_methods: Opaque<Uint8>(b'\x00')
        + extensions: List<Uint16>:
          + Extension:
            + extension_type: ExtensionType.server_name(Uint16(0x0000))
            + length: Uint16(0x0010)
            + extension_data: Opaque[16](b'\x00\x0e\x00\x00\x0bexample.com')
          + Extension:
            + extension_type: ExtensionType.renegotiation_info(Uint16(0xff01))
            + length: Uint16(0x0001)
            + extension_data: Opaque[1](b'\x00')
          + Extension:
            + extension_type: ExtensionType.supported_groups(Uint16(0x000a))
            + length: Uint16(0x0008)
            + extension_data: NamedGroupList:
              + named_group_list: List<Uint16>[NamedGroup.x25519(Uint16(0x001d)),
                NamedGroup.secp256r1(Uint16(0x0017)), NamedGroup.secp384r1(Uint16(0x0018))]
          + Extension:
            + extension_type:
              ExtensionType.application_layer_protocol_negotiation(Uint16(0x0010))
            + length: Uint16(0x0007)
            + extension_data: Opaque[7](b'\x00\x05\x04alpn')
          + Extension:
            + extension_type: ExtensionType.status_request(Uint16(0x0005))
            + length: Uint16(0x0005)
            + extension_data: Opaque[5](b'\x01\x00\x00\x00\x00')
          + Extension:
            + extension_type: ExtensionType.key_share(Uint16(0x0033))
            + length: Uint16(0x0026)
            + extension_data: KeyShareHello:
              + shares: List<Uint16>:
                + KeyShareEntry:
                  + group: NamedGroup.x25519(Uint16(0x001d))
                  + key_exchange: Opaque<Uint16>(b'\x93p\xb2\xc9\xca\xa4\x7f\xba\xba\xf4U\x9f\x
                    ed\xbau=\xe1q\xfaq\xf5\x0f\x1c\xe1]C\xe9\x94\xect\xd7H')
          + Extension:
            + extension_type: ExtensionType.supported_versions(Uint16(0x002b))
            + length: Uint16(0x0003)
            + extension_data: SupportedVersions:
              + versions: List<Uint8>[ProtocolVersion.TLS13(Uint16(0x0304))]
          + Extension:
            + extension_type: ExtensionType.signature_algorithms(Uint16(0x000d))
            + length: Uint16(0x0010)
            + extension_data: SignatureSchemeList:
              + supported_signature_algorithms:
                List<Uint16>[SignatureScheme.ecdsa_secp256r1_sha256(Uint16(0x0403)),
                SignatureScheme.ecdsa_secp384r1_sha384(Uint16(0x0503)),
                SignatureScheme.ecdsa_secp512r1_sha512(Uint16(0x0603)),
                SignatureScheme.ecdsa_sha1(Uint16(0x0203)),
                SignatureScheme.rsa_pss_rsae_sha256(Uint16(0x0804)),
                SignatureScheme.rsa_pss_rsae_sha384(Uint16(0x0805)),
                SignatureScheme.rsa_pss_rsae_sha512(Uint16(0x0806))]
          + Extension:
            + extension_type: ExtensionType.psk_key_exchange_modes(Uint16(0x002d))
            + length: Uint16(0x0002)
            + extension_data: Opaque[2](b'\x01\x01')
          + Extension:
            + extension_type: ExtensionType.record_size_limit(Uint16(0x001c))
            + length: Uint16(0x0002)
            + extension_data: Opaque[2](b'@\x01')
          + Extension:
            + extension_type: ExtensionType.unknown(Uint16(0x0039))
            + length: Uint16(0x0032)
            + extension_data: Opaque[50](b'\x04\x08\xff\xff\xff\xff\xff\xff\xff\xff\x05\x04\x80
              \x00\xff\xff\x07\x04\x80\x00\xff\xff\x08\x01\x10\x01\x04\x80\x00u0\t\x01\x10\x0f\
              x08\x83\x94\xc8\xf0>QW\x08\x06\x04\x80\x00\xff\xff')
+ Frame:
  + frame_type: FrameType.PADDING(QuicUint8(0x00))
  + frame_content: Padding[917]
```

ClientHelloのTLS拡張の中に一つだけ ExtensionType.unknown (0x0039) となっている拡張があります。
この拡張は未実装のために unknown と表示されてしまいました。
これは、QUICが独自に定義しているTLS拡張 quic_transport_parameters で、QUICの通信で使用するパラメータを相手に送信するために使います。

quic_transport_parameters のExtensionTypeの定義は以下のようになっています ([RFC 9001 - 8.2. QUIC Transport Parameters Extension](https://www.rfc-editor.org/rfc/rfc9001#section-8.2))。
```
enum {
   quic_transport_parameters(0x39), (65535)
} ExtensionType;
```

Transport Parameterエンコードのデータ構造は次のようになっています ([RFC 9000 - 18. Transport Parameter Encoding](https://www.rfc-editor.org/rfc/rfc9000#section-18))。

```
Transport Parameter {
  Transport Parameter ID (i),
  Transport Parameter Length (i),
  Transport Parameter Value (..),
}
```

quic_transport_parameters 拡張のデータ内は複数のTransport Parameterデータが含まれています。IDは可変長整数エンコード (Variable-length integer encoding) でIDの一覧は [RFC 9000 - 18.2. Transport Parameter Definitions](https://www.rfc-editor.org/rfc/rfc9000#section-18.2) に書かれています。

RFC で定義されているデータ構造を読みながら、quic_transport_parameters 拡張と Transport Parameter のデータ構造を metatype.py と metastruct.py で定義すると次のようになります。

```python
from metatype import Uint8, List, Enum, VarLenIntEncoding, Opaque
import metastruct as meta

class QuicTransportParamID(Enum):
    elem_t = VarLenIntEncoding

    original_destination_connection_id = VarLenIntEncoding(Uint8(0x00))
    max_idle_timeout = VarLenIntEncoding(Uint8(0x01))
    stateless_reset_token = VarLenIntEncoding(Uint8(0x02))
    max_udp_payload_size = VarLenIntEncoding(Uint8(0x03))
    initial_max_data = VarLenIntEncoding(Uint8(0x04))
    initial_max_stream_data_bidi_local = VarLenIntEncoding(Uint8(0x05))
    initial_max_stream_data_bidi_remote = VarLenIntEncoding(Uint8(0x06))
    initial_max_stream_data_uni = VarLenIntEncoding(Uint8(0x07))
    initial_max_streams_bidi = VarLenIntEncoding(Uint8(0x08))
    initial_max_streams_uni = VarLenIntEncoding(Uint8(0x09))
    ack_delay_exponent = VarLenIntEncoding(Uint8(0x0a))
    max_ack_delay = VarLenIntEncoding(Uint8(0x0b))
    disable_active_migration = VarLenIntEncoding(Uint8(0x0c))
    preferred_address = VarLenIntEncoding(Uint8(0x0d))
    active_connection_id_limit = VarLenIntEncoding(Uint8(0x0e))
    initial_source_connection_id = VarLenIntEncoding(Uint8(0x0f))
    retry_source_connection_id = VarLenIntEncoding(Uint8(0x10))

@meta.struct
class QuicTransportParam(meta.MetaStruct):
    param_id: QuicTransportParamID
    param_value: Opaque(VarLenIntEncoding)

QuicTransportParams = List(size_t=lambda parent: parent.length, elem_t=QuicTransportParam)
```

これを既存の自作 TLS 1.3 の実装に組み込みます。
protocol_tls13_extension.py の ExtensionType に 0x39、Extensionデータ構造のマッチング処理部分に QuicTransportParams を追加します。

```python
class ExtensionType(EnumUnknown):
    elem_t = Uint16

    # ...省略...
    quic_transport_parameters = Uint16(0x39)  # <= 追加

@meta.struct
class Extension(meta.MetaStruct):
    extension_type: ExtensionType
    length: Uint16 = lambda self: Uint16(len(bytes(self.extension_data)))
    extension_data: meta.Select('extension_type', cases={
        ExtensionType.supported_versions: SupportedVersions,
        ExtensionType.supported_groups: NamedGroupList,
        ExtensionType.key_share: KeyShareHello,
        ExtensionType.signature_algorithms: SignatureSchemeList,
        ExtensionType.quic_transport_parameters: QuicTransportParams,  # <= 追加
        meta.Otherwise: OpaqueLength,
    })
```

QUIC独自のTLS拡張が解析できるようになったので、再度、平文ペイロードを解析してみます。

```python
Frames = List(size_t=lambda self: len(plaintext_payload_bytes), elem_t=Frame)

frames = Frames.from_bytes(plaintext_payload_bytes)
print(frames)
```

平文ペイロードの解析結果は次のようになりました。

```output
List<lambda>:
+ Frame:
  + frame_type: FrameType.CRYPTO(QuicUint8(0x06))
  + frame_content: CryptoFrame:
    + offset: QuicUint8(0x00)
    + length: QuicUint16(0x00f1)
    + data: Handshake:
      + msg_type: HandshakeType.client_hello(Uint8(0x01))
      + length: Uint24(0x0000ed)
      + msg: ClientHello:
        + legacy_version: Uint16(0x0303)
        + random: Opaque[32](b'\xeb\xf8\xfaV\xf1)9\xb9XJ8\x96G.\xc4\x0b\xb8c\xcf\xd3\xe8h\x04\
          xfe:G\xf0j+iHL')
        + legacy_session_id: Opaque<Uint8>(b'')
        + cipher_suites: List<lambda>[CipherSuite.TLS_AES_128_GCM_SHA256(Uint16(0x1301)),
          CipherSuite.TLS_AES_256_GCM_SHA384(Uint16(0x1302))]
        + legacy_compression_methods: Opaque<Uint8>(b'\x00')
        + extensions: List<lambda>:
          + Extension:
            + extension_type: ExtensionType.server_name(Uint16(0x0000))
            + length: Uint16(0x0010)
            + extension_data: Opaque[16](b'\x00\x0e\x00\x00\x0bexample.com')
          ...省略...
          + Extension:
            + extension_type: ExtensionType.quic_transport_parameters(Uint16(0x0039))
            + length: Uint16(0x0032)
            + extension_data: List<lambda>:
              + QuicTransportParam:
                + param_id: QuicTransportParamType.initial_max_data(QuicUint8(0x04))
                + param_value: Opaque<VarLenIntEncoding>(b'\xff\xff\xff\xff\xff\xff\xff\xff')
              + QuicTransportParam:
                + param_id:
                  QuicTransportParamType.initial_max_stream_data_bidi_local(QuicUint8(0x05))
                + param_value: Opaque<VarLenIntEncoding>(b'\x80\x00\xff\xff')
              + QuicTransportParam:
                + param_id: QuicTransportParamType.initial_max_stream_data_uni(QuicUint8(0x07))
                + param_value: Opaque<VarLenIntEncoding>(b'\x80\x00\xff\xff')
              + QuicTransportParam:
                + param_id: QuicTransportParamType.initial_max_streams_bidi(QuicUint8(0x08))
                + param_value: Opaque<VarLenIntEncoding>(b'\x10')
              + QuicTransportParam:
                + param_id: QuicTransportParamType.max_idle_timeout(QuicUint8(0x01))
                + param_value: Opaque<VarLenIntEncoding>(b'\x80\x00u0')
              + QuicTransportParam:
                + param_id: QuicTransportParamType.initial_max_streams_uni(QuicUint8(0x09))
                + param_value: Opaque<VarLenIntEncoding>(b'\x10')
              + QuicTransportParam:
                + param_id: QuicTransportParamType.initial_source_connection_id(QuicUint8(0x0f))
                + param_value: Opaque<VarLenIntEncoding>(b'\x83\x94\xc8\xf0>QW\x08')
              + QuicTransportParam:
                + param_id:
                  QuicTransportParamType.initial_max_stream_data_bidi_remote(QuicUint8(0x06))
                + param_value: Opaque<VarLenIntEncoding>(b'\x80\x00\xff\xff')
+ Frame:
  + frame_type: FrameType.PADDING(QuicUint8(0x00))
  + frame_content: Padding[917]
```

ClientHelloのTLS拡張の部分で quic_transport_parameters の一覧に QuicTransportParam の ID と value が正しく表示されているため、バイト列の解析に成功したことが確認できました。

補足として、上の出力で現れるQUICトランスポートパラメータの意味は次の通りです。

- initial_max_data (0x04) : Initialで送信できるデータの最大値
- initial_max_stream_data_bidi_local (0x05) : Initialで自分から開始した双方向ストリームのフロー制御をするための設定
- initial_max_stream_data_uni (0x07) : Initialで一方向ストリームのフロー制御をするための設定
- initial_max_streams_bidi (0x08) : Initialで作成できる双方向ストリームの最大個数
- max_idle_timeout (0x01) : 相手からパケットを受信するまでに待機する時間 (ミリ秒)
- initial_max_streams_uni (0x09) : Initialで作成できる一方向ストリームの最大個数
- initial_source_connection_id (0x0f) : 最初に送信したInitialパケットのソース接続IDフィールドの値
- initial_max_stream_data_bidi_remote (0x06) : Initialで相手から開始した双方向ストリームのフロー制御をするための設定


### 2. CRYPTOフレーム内の Server Hello を解析する

Server Initial Packet も Client Initial Packet とフレームの解析方法は同じです。
フレームの内容について違う点としては CRYPTO Frame の TLS メッセージが ServerHello であることです。

Server Initial Packet の平文ペイロードは以下のバイト列でした。

```
decrypted:
00000000: 02 00 00 00 00 06 00 40  5A 02 00 00 56 03 03 EE  .......@Z...V...
00000010: FC E7 F7 B3 7B A1 D1 63  2E 96 67 78 25 DD F7 39  ....{..c..gx%..9
00000020: 88 CF C7 98 25 DF 56 6D  C5 43 0B 9A 04 5A 12 00  ....%.Vm.C...Z..
00000030: 13 01 00 00 2E 00 33 00  24 00 1D 00 20 9D 3C 94  ......3.$... .<.
00000040: 0D 89 69 0B 84 D0 8A 60  99 3C 14 4E CA 68 4D 10  ..i....`.<.N.hM.
00000050: 81 28 7C 83 4D 53 11 BC  F3 2B B9 DA 1A 00 2B 00  .(|.MS...+....+.
00000060: 02 03 04                                          ...
```

上のバイト列をFramsクラスで解析した結果は次のようになりました。

```output
-----
List<lambda>:
+ Frame:
  + frame_type: FrameType.ACK(QuicUint8(0x02))
  + frame_content: AckFrame:
    + largest_acknowledged: QuicUint8(0x00)
    + ack_delay: QuicUint8(0x00)
    + ack_range_count: QuicUint8(0x00)
    + first_ack_range: QuicUint8(0x00)
+ Frame:
  + frame_type: FrameType.CRYPTO(QuicUint8(0x06))
  + frame_content: CryptoFrame:
    + offset: QuicUint8(0x00)
    + length: QuicUint16(0x005a)
    + data: Handshake:
      + msg_type: HandshakeType.server_hello(Uint8(0x02))
      + length: Uint24(0x000056)
      + msg: ServerHello:
        + legacy_version: Uint16(0x0303)
        + random: Opaque[32](b'\xee\xfc\xe7\xf7\xb3{\xa1\xd1c.\x96gx%\xdd\xf79\x88\xcf\xc7\x98
          %\xdfVm\xc5C\x0b\x9a\x04Z\x12')
        + legacy_session_id_echo: Opaque<Uint8>(b'')
        + cipher_suite: CipherSuite.TLS_AES_128_GCM_SHA256(Uint16(0x1301))
        + legacy_compression_method: Opaque[1](b'\x00')
        + extensions: List<lambda>:
          + Extension:
            + extension_type: ExtensionType.key_share(Uint16(0x0033))
            + length: Uint16(0x0024)
            + extension_data: KeyShareHello:
              + shares: KeyShareEntry:
                + group: NamedGroup.x25519(Uint16(0x001d))
                + key_exchange: Opaque<Uint16>(b'\x9d<\x94\r\x89i\x0b\x84\xd0\x8a`\x99<\x14N\
                  xcahM\x10\x81(|\x83MS\x11\xbc\xf3+\xb9\xda\x1a')
          + Extension:
            + extension_type: ExtensionType.supported_versions(Uint16(0x002b))
            + length: Uint16(0x0002)
            + extension_data: SupportedVersions:
              + versions: ProtocolVersion.TLS13(Uint16(0x0304))
```

平文ペイロードには 0x02 から始まる ACK Frame と 0x06 から始まる CRYPTO Frame がありましたが、
解析結果でも ACK と CRYPTO の2つのフレームが List クラスの要素になっているため、Framsは正しくバイト列を解析できています。

Handshakeの種類は server_hello (0x02) となっていて、key_share 拡張もサーバ側から送るデータ構造になっているため、正しくCRYPTO Frame内のバイト列を解析できたことが確認できました。

以上から、平文ペイロード内のCRYPTOフレームに書かれているTLSメッセージが解析できるプログラムが完成しました。

### おわりに

過去に実装した TLS 1.3 のプログラムのデータ構造を定義しているコードをほとんど変更することなくCRYPTOフレーム内の解析ができました。

次回は他のQUIC (HTTP/3) を実装しているプログラムに実際にQUICパケットを投げてみてTLSの(EC)DHEで鍵共有した後の通信について検証したいと思います。


### 参考文献

- [RFC 9000: QUIC: A UDP-Based Multiplexed and Secure Transport](https://www.rfc-editor.org/rfc/rfc9000)
- [RFC 9001: Using TLS to Secure QUIC](https://www.rfc-editor.org/rfc/rfc9001)
