---
layout:        post
title:         "QUIC の Client Initial Packet で必須のTLS拡張"
date:          2021-10-06
category:      Protocol
cover:         /assets/cover5.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

QUIC のハンドシェイクで、クライアントが Initial Packet を送信するときに含める必要のあるTLS拡張について説明し、サーバから Handshake Packet が返ってくるようになるまでの実装手順について説明します。

### Client Initial Packet で必須のTLS拡張

クライアントがサーバに Initial Packet を投げる際に、いくつかの必須パラメータがあり、それらはサーバに必ず送らないとQUICの通信が始まらないです。
QUICの通信を開始するために必要なパラメータは TLS 1.3 プロトコルで使うものと QUIC プロトコルで使うものの2種類があります。
CRYPTOフレームのTLSメッセージに必ず含めるTLS拡張は以下のものがあります (参照：[RFC 9000: QUIC: A UDP-Based Multiplexed and Secure Transport](https://www.rfc-editor.org/rfc/rfc9000.html#section-7)）

- 鍵交換 (TLS)
    - **ExtensionType.supported_versions** : 対応するTLSバージョンの一覧があり、QUICでは TLS 1.3 (0x0304) のみを指定します。
    - **ExtensionType.supported_groups** : (EC)DHEの鍵交換で使用する群（Group）を指定します。TLS 1.3 で使用できる群の一覧は[RFC 8446 - B.3.1.4. Supported Groups Extension](https://datatracker.ietf.org/doc/html/rfc8446#appendix-B.3.1.4)に書かれています。
    - **ExtensionType.signature_algorithms** : 送信するデータの署名アルゴリズムを指定します。証明書だけは別の署名アルゴリズムを使う場合は signature_algorithms_cert という別のTLS拡張も送信します。
    - **ExtensionType.key_share** : 暗号パラメータを送信するためのTLS拡張です。TLS 1.3 では (EC)DHE で鍵共有するために相手に送る公開鍵をこのTLS拡張に含めて送信します。
- ALPN (QUIC)
    - **ExtensionType.application_layer_protocol_negotiation** : 暗号化通信を確立するときにどのプロトコルを使うかを指定するためのTLS拡張です (暗号化通信が確立する前にサーバ側にHTTP/1.1 or HTTP/2.0の使用を宣言するときなどに使う)。TLSでは必須ではないですが、QUICでは送信が必須です。
- トランスポートパラメータ (QUIC)
    - **ExtensionType.quic_transport_parameters** : QUICトランスポートパラメータを送信するためのTLS拡張
        - **initial_source_connection_id** (0x0f) : クライアントの接続元コネクションID

QUICトランスポートパラメータについて、クライアントはInitial Packetにパラメータ initial_source_connection_id または original_destination_connection_id が存在しないときは、接続エラー TRANSPORT_PARAMETER_ERROR を返します。

### 自作QUICプロトコルで書いてみる

QUICのInitial PacketのペイロードにはCRYPTO Frameがあり、その中にはTLS Handshake (Client Hello) が含まれています。Client Hello の末尾には TLS 拡張が含まれており、その中には上記の必須のTLS拡張でパラメータが指定されています。
ここまでの話を筆者の自作QUICプロトコルで表現すると、以下のような形になります。

```python
from crypto_x25519 import x25519
dhkex_class = x25519
secret_key = bytes.fromhex('6923bcdc7b80831a7f0d6fdfddb8e1b5e2f042cb1991cb19fd7ad9bce444fe63')
public_key = dhkex_class(secret_key)

client_src_connection_id = bytes.fromhex('c6b336557f9128bef8a099a10d320c26e9c8d1ab')

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
                    Extension(
                        extension_type=ExtensionType.supported_versions,
                        extension_data=SupportedVersions(
                            versions=ProtocolVersions([
                                ProtocolVersion.TLS13
                            ])
                        )
                    ),
                    Extension(
                        extension_type=ExtensionType.supported_groups,
                        extension_data=NamedGroupList(
                            named_group_list=NamedGroups([
                                NamedGroup.x25519
                            ])
                        )
                    ),
                    Extension(
                        extension_type=ExtensionType.application_layer_protocol_negotiation,
                        extension_data=ALPNProtocols([
                            OpaqueUint8(b'h3')
                        ])
                    ),
                    Extension(
                        extension_type=ExtensionType.signature_algorithms,
                        extension_data=SignatureSchemeList(
                            supported_signature_algorithms=SignatureSchemes([
                                SignatureScheme.rsa_pss_rsae_sha256,
                            ])
                        )
                    ),
                    Extension(
                        extension_type=ExtensionType.key_share,
                        extension_data=KeyShareHello(
                            shares=KeyShareEntrys([
                                KeyShareEntry(
                                    group=NamedGroup.x25519,
                                    key_exchange=OpaqueUint16(public_key)
                                )
                            ])
                        )
                    ),
                    Extension(
                        extension_type=ExtensionType.quic_transport_parameters,
                        extension_data=QuicTransportParams([
                            QuicTransportParam(
                                param_id=QuicTransportParamType.initial_source_connection_id,
                                param_value=OpaqueUint8(client_src_connection_id)
                            ),
                        ])
                    )
                ])
            )
        )
    )
)
```

ALPNでプロトコルを指定するときは、事前に定義されている文字列を送ります。
例えば、HTTP/3の場合は「h3」、HTTP/2 over TLSの場合は「h2」、HTTP/2 over Cleartext (非暗号化通信) の場合は「h2c」となります。



CRYPTO Frameを作ったら、以下は暗号化までの流れになります。
詳細は[QUIC の Initial Packet を暗号化する](./quic-initial-packet-encrypt)に書いております。
自作QUICプロトコルで表現すると、以下のような形になります。

```python
client_src_connection_id = bytes.fromhex('c6b336557f9128bef8a099a10d320c26e9c8d1ab') # ランダム値
client_dst_connection_id = bytes.fromhex('1a26dc5bd9625e2bcd0efd3a329ce83136a32295') # ランダム値

# 1回目
packet_number = 1
initial_packet = InitialPacket(
    flags=LongPacketFlags(header_form=HeaderForm.LONG, fixed_bit=1,
                          long_packet_type=PacketType.INITIAL, type_specific_bits=0b0011),
    version=QUICVersions.QUICv1,
    dest_conn_id=OpaqueUint8(client_dst_connection_id),
    src_conn_id=OpaqueUint8(client_src_connection_id),
    token=OpaqueVarLenIntEncoding(b''),
    length=None,
    packet_number=Uint32(packet_number),
    packet_payload=None
)

aead_tag_len = 16
LengthType = Uint16
length_len = LengthType.size

def calc_padding_frame_len(initial_packet):
    packet_number_len = (initial_packet.flags.type_specific_bits & 0x03) + 1  # バケット番号長
    # Clientが送信するInitial Packetを含むUDPペイロードは1200バイト以上にしないといけない (MUST)
    padding_frame_len = 1200 - 5 - len(bytes(initial_packet.dest_conn_id)) - len(bytes(initial_packet.src_conn_id)) - len(bytes(initial_packet.token)) - length_len - packet_number_len - crypto_frame_len - aead_tag_len - 1
    return padding_frame_len

padding_frame_len = calc_padding_frame_len(initial_packet)
print('[+] padding_frame_len:', padding_frame_len)

# 1200バイト以上になるようにパディング追加
padding_frame = Frame(
    frame_type=FrameType.PADDING,
    frame_content=b'\x00' * padding_frame_len
)

Frames = List(size_t=lambda x: None, elem_t=Frame)
frames = Frames([
    crypto_frame,
    padding_frame,
])
plaintext_payload_bytes = bytes(frames)

packet_number_len = (initial_packet.flags.type_specific_bits & 0x03) + 1  # バケット番号長
initial_packet.length = VarLenIntEncoding(LengthType(len(plaintext_payload_bytes) + packet_number_len + aead_tag_len))
initial_packet.update()

client_key, client_iv, client_hp_key, server_key, server_iv, server_hp_key = \
    get_client_server_key_iv_hp(client_dst_connection_id)

aad = initial_packet.get_header_bytes()

ciphertext_payload_bytes = encrypt_payload(plaintext_payload_bytes, client_key, client_iv, aad, packet_number)
initial_packet.length = VarLenIntEncoding(LengthType(len(ciphertext_payload_bytes) + packet_number_len))
initial_packet.packet_payload = OpaqueLength(ciphertext_payload_bytes)
initial_packet.update()

send_packet = LongPacket.from_bytes(bytes(initial_packet))
send_packet_bytes = header_protection(send_packet, client_hp_key, mode='encrypt', debug=True)
```

Client Initial Packet のバイト列を作成したら、それを UDP で送信します。

```python
import socket

class ClientConn:
    def __init__(self, host, port=443):
        self.server_address = (host, port)
        # ソケット作成
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    # メッセージの送信
    def sendto(self, message: bytes):
        return self.sock.sendto(message, self.server_address)

    # メッセージの受信
    def recvfrom(self, buffer_size=2048): # 1024
        data, addr = self.sock.recvfrom(buffer_size)
        return data, addr

peer_ipaddr = '127.0.0.1'
peer_port = 4433
peer = (peer_ipaddr, peer_port)

conn = ClientConn(peer_ipaddr, peer_port)
conn.sendto(send_packet_bytes)
```

上記で送った直後に recvfrom でUDPをListenします。

```python
res = conn.recvfrom()
recv_msg, addr = res
print(hexdump(recv_msg))
```

サーバ側からServer Helloとは別の暗号化された1000bytesくらいの証明書データが入っていそうな通信が返ってきたらハンドシェイク成功です（実際は受信したバイト列を復号して読み解く作業が必要ですが、ここでは省略）。

サーバ側からRetryパケットを受信したら、パケット番号を1増やして、Retryパケットの送信元コネクションIDを、クライアントが送信する宛先コネクションIDにして、Retryパケットに含まれているトークンを、Initial Packetに含めて送信します。
Retryパケット受信時の詳細は[QUICのRetryパケット](./quic-retry-packet)に書いております。

### おわりに

今回は、サーバ側からServer Helloが返ってくるようにClient Helloに必要なTLS拡張は何であるかの調査をした回でした。
次回は、Client HelloとServer Helloに含まれている鍵共有の公開鍵から、共有鍵を導出し、サーバから受信した暗号化されている証明書などが含まれているパケット（Handshake Packet）の復号を行いたいと思います。

### 参考文献

- [RFC 9000: QUIC: A UDP-Based Multiplexed and Secure Transport](https://www.rfc-editor.org/rfc/rfc9000.html#section-7)
- [HTTP/2: ちょっと詳細: プロトコルネゴシエーション編 - Qiita](https://qiita.com/kitauji/items/3bf03533895251c93af2)
- [3. フォーカス・リサーチ（2）HaskellによるQUICの実装 \| Internet Infrastructure Review（IIR）Vol.52 \| IIJの技術 \| インターネットイニシアティブ(IIJ)](https://www.iij.ad.jp/dev/report/iir/052/03.html)
