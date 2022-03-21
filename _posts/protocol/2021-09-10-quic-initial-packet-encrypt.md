---
layout:        post
title:         "QUIC の Initial Packet を暗号化する"
date:          2021-09-10
category:      Protocol
cover:         /assets/cover5.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
similarPosts:
- [./quic-initial-packet-decrypt, QUIC の Initial Packet を復号する]
- [./quic-tls-clienthello, QUIC の TLS ClientHello を解析する, ««« 前回]
- [./quic-initial-packet-encrypt, QUIC の Initial Packet を暗号化する, ««« 今回]
- [./quic-client-initial-tls-ext, QUIC の Client Initial Packet で必須のTLS拡張, ««« 次回]
- [./quic-handshake-packet-decrypt, QUIC の Handshake Packet を復号する]
---

QUICパケットでTLSメッセージを運ぶ Initial Packet を**暗号化**するまでの処理をPythonで実装しつつ説明していきたいと思います。

本記事は、前回の「[QUIC の Initial Packet を復号する](./quic-initial-packet-decrypt)」の続きとなります。
前回は、Pythonで暗号化されたQUICのペイロードを復号する実装を行いました。
鍵導出方法の詳細は前回で説明していますので、前回の記事を読んでいる前提でお話しを進めていきます。

まず、Client Initial Packet の暗号化は次の手順で行います。

1. TLSメッセージを送信するためのCRYPTOフレームのバイト列を作る
2. 送信するUDPペイロード（QUICパケット）のサイズが**1200バイト以上**になるように逆算してPADDINGフレームを追加する
3. CRYPTOとPADDINGフレームを含む平文ペイロードを暗号化する
4. パケットのヘッダー保護をする

一方、Server Initial Packet の暗号化は1200バイト以上にする必要がなく、PADDINGフレームが不要なので、暗号化は次の手順になります。

1. TLSメッセージを送信するためのCRYPTOフレームのバイト列を作る
2. ACKとCRYPTOフレームを含む平文ペイロードを暗号化する
3. パケットのヘッダ保護をする

## Client Initial Packet を暗号化する

[RFC 9001 - Appendix A. Sample Packet Protection](https://www.rfc-editor.org/rfc/rfc9001#section-appendix.a) に書かれているテストベクタを参考に、クライアントが送信する Initial Packet を暗号化してみます。

### 1. 暗号化に必要な鍵の導出

まず、暗号化するにあたって必要な鍵を準備します。
ペイロード暗号化鍵とIVやヘッダー保護鍵については、前回の「[QUIC の Initial Packet を復号する](./quic-initial-packet-decrypt)」で説明していますので、こちらを参考にしてください。
クライアントの宛先接続IDから鍵を導出するときに使っている関数 get_client_server_key_iv_hp() は次のように定義します。

```py
def get_key_iv_hp(cs_initial_secret):
    cs_key = HKDF_expand_label(cs_initial_secret, b'quic key', b'', 16)
    cs_iv = HKDF_expand_label(cs_initial_secret, b'quic iv', b'', 12)
    cs_hp = HKDF_expand_label(cs_initial_secret, b'quic hp', b'', 16)
    return cs_key, cs_iv, cs_hp

def get_client_server_key_iv_hp(client_dst_connection_id):
    initial_secret = HKDF_extract(initial_salt, client_dst_connection_id)
    client_initial_secret = HKDF_expand_label(initial_secret, b'client in', b'', 32)
    server_initial_secret = HKDF_expand_label(initial_secret, b'server in', b'', 32)
    client_key, client_iv, client_hp = get_key_iv_hp(client_initial_secret)
    server_key, server_iv, server_hp = get_key_iv_hp(server_initial_secret)
    return (client_key, client_iv, client_hp,
            server_key, server_iv, server_hp)
```

関数 get_client_server_key_iv_hp() を使って鍵を導出します。

```py
client_key, client_iv, client_hp, server_key, server_iv, server_hp = \
    get_client_server_key_iv_hp(client_dst_connection_id)
print('---')
print('client_key:')
print(hexdump(client_key))
# => 00000000: 1F 36 96 13 DD 76 D5 46  77 30 EF CB E3 B1 A2 2D  .6...v.Fw0.....-
print('client_iv:')
print(hexdump(client_iv))
# => 00000000: FA 04 4B 2F 42 A3 FD 3B  46 FB 25 5C              ..K/B..;F.%\
print('client_hp:')
print(hexdump(client_hp))
# => 00000000: 9F 50 44 9E 04 A0 E8 10  28 3A 1E 99 33 AD ED D2  .PD.....(:..3...

cs_key = client_key
cs_iv = client_iv
cs_hp = client_hp
```

### 2. メッセージのバイト列を用意する

本来は送信したい内容をデータ構造からバイト列に変換するのですが、ここでは、平文ペイロードは [RFC 9001 - A.2. Client Initial](https://www.rfc-editor.org/rfc/rfc9001.html#section-a.2) の付録に書かれているテスト用のバイト列を使用します。

```py
# Client Inital Packet
plaintext_payload_bytes_orig = bytes.fromhex("""
060040f1010000ed0303ebf8fa56f129 39b9584a3896472ec40bb863cfd3e868
04fe3a47f06a2b69484c000004130113 02010000c000000010000e00000b6578
616d706c652e636f6dff01000100000a 00080006001d00170018001000070005
04616c706e0005000501000000000033 00260024001d00209370b2c9caa47fba
baf4559fedba753de171fa71f50f1ce1 5d43e994ec74d748002b000302030400
0d0010000e0403050306030203080408 050806002d00020101001c0002400100
3900320408ffffffffffffffff050480 00ffff07048000ffff08011001048000
75300901100f088394c8f03e51570806 048000ffff
""")
```

### 3. 平文ペイロードを暗号化する

テストベクタでは次の条件でペイロードが作られています。

* クライアントの宛先接続IDは 0x8394c8f03e515708 
* パケット番号は 2

これを元に Initial Packet を構築していきます。
まずは、暗号化するに当たってAAD (Additional Auth Data; AEAD暗号に渡すラベル) を求める必要があるのですが、Initial PacketのヘッダがAADになるので、まずヘッダを先に作ります。Initial Packet の「Length」と「Packet Payload」を暫定的に null にしてインスタンス化します
（各クラスは自作のプロトコルアナライザのものを使用しています）。

```py
client_dst_connection_id = bytes.fromhex('8394c8f03e515708')

packet_number = 2
initial_packet = InitialPacket(
    flags=LongPacketFlags(header_form=1, fixed_bit=1,
                          long_packet_type=PacketType.INITIAL, type_specific_bits=0b0011),
    version=QUICVersions.QUICv1,
    dest_conn_id=OpaqueUint8(dest_conn_id_bytes),
    src_conn_id=OpaqueUint8(b''),
    token=OpaqueVarLenIntEncoding(b''),
    length=None,
    packet_number=Uint32(packet_number),
    packet_payload=None
)
```

続いて、UDPペイロード（QUICパケット）を1200バイトにするために、1200から既に使用済みのバイト数を引き算して、必要なパディングを求めます。
Initial Packet のデータ構造は [RFC 9000 - 17.2.2. Initial Packet](https://www.rfc-editor.org/rfc/rfc9000#section-17.2.2) を参照してください。
PADDINGフレーム長の計算式は「(PADDINGフレーム長) = 1200 byte − (HeaderFormからVersionまで: 5byte) − (宛先接続ID: 1〜21byte) − (差出接続ID: 1〜21byte) − (トークン: 1byte以上) − (Length長: 1〜4byte) − (平文ペイロード長) − (AEAD暗号化で付加されるMAC長: 16byte)」で求めた値がパディングの長さになります。
AEADで暗号化するため、暗号化したペイロードは 16 byte の認証タグ (MAC) が付加されていることに注意が必要です。

```py
packet_number_len = (initial_packet.flags.type_specific_bits & 0x03) + 1  # バケット番号長
aead_tag_len = 16
length_len = Uint16.size

# Clientが送信するInitial Packetを含むUDPペイロードは1200バイト以上にしないといけない
# PADDINGフレームの長さを計算する
padding_frame_len = 1200 - 5 - len(bytes(initial_packet.dest_conn_id)) \
  - len(bytes(initial_packet.src_conn_id)) - len(bytes(initial_packet.token)) \
  - length_len - packet_number_len - len(plaintext_payload_bytes_orig) - aead_tag_len
print('[+] padding_frame_len:', padding_frame_len) # => 917
# パディングの追加
plaintext_payload_bytes = plaintext_payload_bytes_orig + bytes.fromhex("00" * padding_frame_len)
```

ペイロードにパディングを追加したらペイロード長も決定するので、Initial Packet のインスタンス化時に null を設定していた部分を埋めていきます。

平文を暗号化する前に、認証付き暗号(AEAD)に入力するAAD(追加の認証データ)には、暗号化した後のペイロードの長さ(bytes)を使用するため、これを計算によって求める必要があります。
必要な情報は以下の2つです。

* Initial Packet のQUIC暗号化はハンドシェイク前なので AEAD_AES_128_GCM しか使えません。よって、AEADで暗号化したデータには16byteの認証タグが末尾に付加されます。
* 暗号化ペイロードにはパケット番号長を表すフィールドも含まれています。パケット番号長を持つフィールドの長さは、ヘッダの最初の1byteの最下位2bitを見ればわかります。

つまり、「平文の長さ」＋「AEADの認証タグ長(16bytes)」＋「パケット番号長」が暗号化後のペイロード長になります。
ここまでの情報が揃って、ようやく暗号化に必要なAADのバイト列を求められるようになります。

```py
# Initial Packetの再作成
initial_packet.packet_payload = plaintext_payload_bytes
initial_packet.length = VarLenIntEncoding(Uint16(len(plaintext_payload_bytes) + packet_number_len + aead_tag_len))
initial_packet.update()
print(initial_packet)
```

パディング追加時点での Initial Packet の構造体は次のような感じになります。

```
InitialPacket:
+ flags: LongPacketFlags(header_form=1(Long), fixed_bit=1,
  long_packet_type=00(Initial), type_specific_bits=0011)
+ version: QUICVersions.QUICv1(Uint32(0x00000001))
+ dest_conn_id: Opaque<Uint8>(b'\x83\x94\xc8\xf0>QW\x08')
+ src_conn_id: Opaque<Uint8>(b'')
+ token: Opaque<VarLenIntEncoding>(b'')
+ length: VarLenIntEncodingUint16(0x049e)
+ packet_number: Uint32(0x00000002)
+ packet_payload: b'\x06\x00@\xf1\x01\x00\x00\xed\x03\x03\xeb\xf8\xfaV\xf
  1)9\xb9XJ8\x96G.\xc4\x0b\xb8c\xcf\xd3\xe8h\x04\xfe:G\xf0j+iHL\x00\x00\x
  04\x13\x01\x13\x02\x01\x00\x00\xc0\x00\x00\x00\x10\x00\x0e\x00\x00\x0be
  xample.com\xff\x01\x00\x01\x00\x00\n\x00\x08\x00\x06\x00\x1d\x00\x17\x0
  0\x18\x00\x10\x00\x07\x00\x05\x04alpn\x00\x05\x00\x05\x01\x00\x00\x00\x
  00\x003\x00&\x00$\x00\x1d\x00 \x93p\xb2\xc9\xca\xa4\x7f\xba\xba\xf4U\x9
  f\xed\xbau=\xe1q\xfaq\xf5\x0f\x1c\xe1]C\xe9\x94\xect\xd7H\x00+\x00\x03\
  x02\x03\x04\x00\r\x00\x10\x00\x0e\x04\x03\x05\x03\x06\x03\x02\x03\x08\x
  04\x08\x05\x08\x06\x00-\x00\x02\x01\x01\x00\x1c\x00\x02@\x01\x009\x002\
  x04\x08\xff\xff\xff\xff\xff\xff\xff\xff\x05\x04\x80\x00\xff\xff\x07\x04
  \x80\x00\xff\xff\x08\x01\x10\x01\x04\x80\x00u0\t\x01\x10\x0f\x08\x83\x9
  4\xc8\xf0>QW\x08\x06\x04\x80\x00\xff\xff\x00\x00\x00\x00\x00\x00\x00\x0
  0\x00...\x00\x00\x00'
```

暗号化ではInitial PacketのヘッダをAAD (Additional Auth Data) として使います。
InitialPacketクラスのメソッドに get_header_bytes() を以下のように定義して AAD を簡単に取得できるようにします。

```py
@meta.struct
class InitialPacket(meta.MetaStruct):
    flags: LongPacketFlags
    version: Uint32
    dest_conn_id: OpaqueUint8
    src_conn_id: OpaqueUint8
    token: OpaqueVarLenIntEncoding
    length: VarLenIntEncoding
    packet_number: Opaque(lambda self: self.flags.type_specific_bits_lsb2bit + 1)
    packet_payload: Opaque(lambda self: int(self.length) - self.packet_number.get_size())

    def get_header_bytes(self):
        return create_aad(self.flags, self.version, self.dest_conn_id, self.src_conn_id, \
                          self.token, self.length, self.packet_number)

    def get_packet_number_int(self):
        return int.from_bytes(bytes(self.packet_number), 'big')

def create_aad(flags: LongPacketFlags, version: Uint32, dest_conn_id: OpaqueUint8,
               src_conn_id: OpaqueUint8, token: OpaqueVarLenIntEncoding,
               length: VarLenIntEncoding, packet_number):
    return bytes(flags) + bytes(version) + bytes(dest_conn_id) + \
           bytes(src_conn_id) + bytes(token) + bytes(length) + \
           bytes(packet_number)
```

平文ペイロードを含むInitial Packetからヘッダを取得して、ペイロードを暗号化します。

```py
aad = initial_packet.get_header_bytes()
# => 00000000: C3 00 00 00 01 08 83 94  C8 F0 3E 51 57 08 00 00  ..........>QW...
# => 00000010: 44 9E 00 00 00 02                                 D.....

ciphertext_payload_bytes = encrypt_payload(plaintext_payload_bytes, cs_key, cs_iv, aad, packet_number)
print('encrypted:')
print(hexdump(ciphertext_payload_bytes))
```

なお、平文ペイロードを暗号化する関数 encrypt_payload は次のようになっています。

```python
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

def _enc_dec_payload(input_bytes, key, iv, aad, packet_number, mode='encrypt'):
    packet_number_bytes = packet_number.to_bytes(len(iv), 'big')
    nonce = bytexor(packet_number_bytes, iv)
    aesgcm = AESGCM(key=key)
    output_bytes = b''
    if mode == 'encrypt':
        output_bytes = aesgcm.encrypt(nonce, input_bytes, aad)
    else:
        output_bytes = aesgcm.decrypt(nonce, input_bytes, aad)
    return output_bytes

def decrypt_payload(payload: bytes, cs_key: bytes, cs_iv: bytes, aad: bytes,
                    packet_number: int) -> bytes:
    return _enc_dec_payload(payload, cs_key, cs_iv, aad, packet_number, mode='decrypt')

def encrypt_payload(payload: bytes, cs_key: bytes, cs_iv: bytes, aad: bytes,
                    packet_number: int) -> bytes:
    return _enc_dec_payload(payload, cs_key, cs_iv, aad, packet_number, mode='encrypt')
```

暗号化した結果について、暗号化ペイロードを16進数ダンプした結果は以下のようになります。

```
encrypted:
00000000: D1 B1 C9 8D D7 68 9F B8  EC 11 D2 42 B1 23 DC 9B  .....h.....B.#..
00000010: D8 BA B9 36 B4 7D 92 EC  35 6C 0B AB 7D F5 97 6D  ...6.}..5l..}..m
00000020: 27 CD 44 9F 63 30 00 99  F3 99 1C 26 0E C4 C6 0D  '.D.c0.....&....
...
00000480: E5 5C 88 D4 A9 A7 F9 47  42 41 E2 21 AF 44 86 00  .\.....GBA.!.D..
00000490: 18 AB 08 56 97 2E 19 4C  D9 34                    ...V...L.4
```

そしたら、暗号化したペイロードを Initial Packet に再度格納します。

```py
initial_packet.length = VarLenIntEncoding(Uint16(len(ciphertext_payload_bytes) + packet_number_len))
initial_packet.packet_payload = OpaqueLength(ciphertext_payload_bytes)
initial_packet.update()
print(initial_packet)
```

暗号化ペイロードを格納した Initial Packet は次のようになっています。

```
InitialPacket:
+ flags: LongPacketFlags(header_form=1(Long), fixed_bit=1,
  long_packet_type=00(Initial), type_specific_bits=0011)
+ version: QUICVersions.QUICv1(Uint32(0x00000001))
+ dest_conn_id: Opaque<Uint8>(b'\x83\x94\xc8\xf0>QW\x08')
+ src_conn_id: Opaque<Uint8>(b'')
+ token: Opaque<VarLenIntEncoding>(b'')
+ length: VarLenIntEncodingUint16(0x049e)
+ packet_number: Uint32(0x00000002)
+ packet_payload: Opaque[1182](b'\xd1\xb1\xc9\x8d\xd7h\x9f\xb8\xec\x11\xd
  2B\xb1#\xdc\x9b\xd8\xba\xb96\xb4}\x92\xec5l\x0b\xab}\xf5\x97m\'\xcdD\x9
  ...
  \x9aD\xe5\\\x88\xd4\xa9\xa7\xf9GBA\xe2!\xafD\x86\x00\x18\xab\x08V\x97.\
  x19L\xd94')
```

ここまででペイロードの暗号化が完了しました。

### 4. パケットのヘッダー保護をする

続いて、パケットのヘッダ保護を行います。前回の記事でヘッダ保護を解除するために作成した header_protection を少しだけ修正します。
header_protection の引数に mode を追加して「encrypt」のときは暗号化前に、「decrypt」のときは復号後にパケット番号のバイト長を取得します。
なお、パケット番号のバイト長は Initial Packet データ構造の Packet Number Length (2bit) の値を10進数にした値 + 1 となります。

```py
def header_protection(long_packet, sc_hp_key, mode=None, debug=False) -> bytes:
    assert mode in ('encrypt', 'decrypt')
    recv_packet_bytes = bytes(long_packet)

    def get_np_offset_and_sample_offset(long_packet) -> (int, int):
        # pn_offset is the start of the Packet Number field.
        pn_offset = 7 + len(long_packet.dest_conn_id) + \
                        len(long_packet.src_conn_id) + \
                        len(long_packet.payload.length)
        if PacketType(long_packet.flags.long_packet_type) == PacketType.INITIAL:
            pn_offset += len(bytes(long_packet.payload.token))

        sample_offset = pn_offset + 4

        return pn_offset, sample_offset

    pn_offset, sample_offset = get_np_offset_and_sample_offset(long_packet)

    sample_length = 16
    sample = recv_packet_bytes[sample_offset:sample_offset+sample_length]
    if debug:
        print('sample:')
        print(hexdump(sample))

    def generate_mask(hp_key, sample) -> bytes:
        cipher = Cipher(algorithms.AES(key=hp_key), modes.ECB())
        encryptor = cipher.encryptor()
        ct = encryptor.update(sample) + encryptor.finalize()
        mask = bytearray(ct)[0:5]
        return mask

    mask = generate_mask(sc_hp_key, sample)
    if debug:
        print('mask:')
        print(hexdump(mask))

    if mode == 'encrypt':
        # ヘッダ保護前にパケット番号の長さ取得
        pn_length = (recv_packet_bytes[0] & 0x03) + 1

    recv_packet_bytes = bytearray(recv_packet_bytes)
    if (recv_packet_bytes[0] & 0x80) == 0x80:
        # Long header: 4 bits masked
        recv_packet_bytes[0] ^= mask[0] & 0x0f
    else:
        # Short header: 5 bits masked
        recv_packet_bytes[0] ^= mask[0] & 0x1f

    if mode == 'decrypt':
        # ヘッダ保護解除後にパケット番号の長さ取得
        pn_length = (recv_packet_bytes[0] & 0x03) + 1

    recv_packet_bytes[pn_offset:pn_offset+pn_length] = \
        bytexor(recv_packet_bytes[pn_offset:pn_offset+pn_length], mask[1:1+pn_length])

    return recv_packet_bytes
```

修正したヘッダー保護を行う関数を使って、Initial Packet のヘッダを暗号化します。
復号のときと反対の処理になるように、Initial Packet を Long Packet に変換してから、ヘッダー保護とします。

```py
send_packet = LongPacket.from_bytes(bytes(initial_packet))
send_packet_bytes = header_protection(send_packet, cs_hp, mode='encrypt', debug=True)
print('encrypted packet:')
print(hexdump(send_packet_bytes))
```

ヘッダー保護の処理のデバッグモードをOnにして、ヘッダー保護をした結果は次のようになります（途中省略）。

```
sample:
00000000: D1 B1 C9 8D D7 68 9F B8  EC 11 D2 42 B1 23 DC 9B  .....h.....B.#..
mask:
00000000: 43 7B 9A EC 36                                    C{..6

encrypted packet:
00000000: C0 00 00 00 01 08 83 94  C8 F0 3E 51 57 08 00 00  ..........>QW...
00000010: 44 9E 7B 9A EC 34 D1 B1  C9 8D D7 68 9F B8 EC 11  D.{..4.....h....
00000020: D2 42 B1 23 DC 9B D8 BA  B9 36 B4 7D 92 EC 35 6C  .B.#.....6.}..5l
...
00000490: 8B 4C 8D 16 9A 44 E5 5C  88 D4 A9 A7 F9 47 42 41  .L...D.\.....GBA
000004A0: E2 21 AF 44 86 00 18 AB  08 56 97 2E 19 4C D9 34  .!.D.....V...L.4
```

[RFC 9001 - A.2. Client Initial](https://www.rfc-editor.org/rfc/rfc9001#section-a.2) のところに暗号化したパケットの結果が書いてあるので、これとバイト列で比較を行なったところ、一致したため、Client Initial Packet の暗号化とヘッダー保護は期待通りにできました。



## Server Initial Packet を暗号化する

Server Initial Packet は Client Initial Packet への応答として送信します。
Server Initial Packet の方は 1200 バイト以上にするという制約はありません。
なので、Client のときより楽に暗号化できます。

### 1. 暗号化に必要な鍵の導出

Client Initial Packet で鍵導出したのと同じように get_client_server_key_iv_hp() 関数を使います。

```py
client_key, client_iv, client_hp, server_key, server_iv, server_hp = \
    get_client_server_key_iv_hp(client_dst_connection_id)
print('---')
print('server_key:')
print(hexdump(server_key))
# => 00000000: CF 3A 53 31 65 3C 36 4C  88 F0 F3 79 B6 06 7E 37  .:S1e<6L...y..~7
print('server_iv:')
print(hexdump(server_iv))
# => 00000000: 0A C1 49 3C A1 90 58 53  B0 BB A0 3E              ..I<..XS...>
print('server_hp:')
print(hexdump(server_hp))
# => 00000000: C2 06 B8 D9 B9 F0 F3 76  44 43 0B 49 0E EA A3 14  .......vDC.I....

cs_key = server_key
cs_iv = server_iv
cs_hp = server_hp
```

### 2. メッセージのバイト列を用意する

本来は送信したい内容をデータ構造からバイト列に変換するのですが、ここでは、平文ペイロードは [RFC 9001 - A.3. Server Initial](https://www.rfc-editor.org/rfc/rfc9001.html#section-a.3) の付録に書かれているテスト用のバイト列を使用します。

```py
# Server Inital Packet
plaintext_payload_bytes_orig = bytes.fromhex("""
02000000000600405a020000560303ee fce7f7b37ba1d1632e96677825ddf739
88cfc79825df566dc5430b9a045a1200 130100002e00330024001d00209d3c94
0d89690b84d08a60993c144eca684d10 81287c834d5311bcf32bb9da1a002b00
020304
""")
```

### 3. 平文ペイロードを暗号化する

テストベクタでは次の条件でペイロードが作られています。

* クライアントの送信元接続IDは 0xf067a5502a4262b5 
* パケット番号は 1

これを元に Initial Packet を構築していきます。

```py
packet_number = 1
initial_packet = InitialPacket(
    flags=LongPacketFlags(header_form=HeaderForm.LONG, fixed_bit=1,
                        long_packet_type=PacketType.INITIAL, type_specific_bits=0b0001),
    version=QUICVersions.QUICv1,
    dest_conn_id=OpaqueUint8(b''),
    src_conn_id=OpaqueUint8(bytes.fromhex('f067a5502a4262b5')),
    token=OpaqueVarLenIntEncoding(b''),
    length=None,
    packet_number=Uint16(packet_number),
    packet_payload=None
)

packet_number_len = (initial_packet.flags.type_specific_bits & 0x03) + 1  # バケット番号長
aead_tag_len = 16
length_len = Uint16.size

plaintext_payload_bytes = plaintext_payload_bytes_orig
initial_packet.packet_payload = plaintext_payload_bytes
initial_packet.length = VarLenIntEncoding(Uint16(len(plaintext_payload_bytes) + packet_number_len + aead_tag_len))
initial_packet.update()
print(initial_packet)
```

平文の Server Initial Packet は次のようになります。

```
InitialPacket:
+ flags: LongPacketFlags(header_form=1(Long), fixed_bit=1,
  long_packet_type=00(Initial), type_specific_bits=0001)
+ version: QUICVersions.QUICv1(Uint32(0x00000001))
+ dest_conn_id: Opaque<Uint8>(b'')
+ src_conn_id: Opaque<Uint8>(b'\xf0g\xa5P*Bb\xb5')
+ token: Opaque<VarLenIntEncoding>(b'')
+ length: VarLenIntEncodingUint16(0x0075)
+ packet_number: Uint16(0x0001)
+ packet_payload: b'\x02\x00\x00\x00\x00\x06\x00@Z\x02\x00\x00V\x03\x03\x
  ee\xfc\xe7\xf7\xb3{\xa1\xd1c.\x96gx%\xdd\xf79\x88\xcf\xc7\x98%\xdfVm\xc
  5C\x0b\x9a\x04Z\x12\x00\x13\x01\x00\x00.\x003\x00$\x00\x1d\x00 \x9d<\x9
  4\r\x89i\x0b\x84\xd0\x8a`\x99<\x14N\xcahM\x10\x81(|\x83MS\x11\xbc\xf3+\
  xb9\xda\x1a\x00+\x00\x02\x03\x04'
```

続いて、Initial Packetからヘッダを取り出して、ペイロードの暗号化をします。

```py
aad = initial_packet.get_header_bytes()
print(hexdump(aad))
# => 00000000: C1 00 00 00 01 00 08 F0  67 A5 50 2A 42 62 B5 00  ........g.P*Bb..
# => 00000010: 40 75 00 01                                       @u..

ciphertext_payload_bytes = encrypt_payload(plaintext_payload_bytes, cs_key, cs_iv, aad, packet_number)
print('encrypted:')
print(hexdump(ciphertext_payload_bytes))
```

暗号化ペイロードのバイト列は次のようになっています。

```
00000000: 5A 48 2C D0 99 1C D2 5B  0A AC 40 6A 58 16 B6 39  ZH,....[..@jX..9
00000010: 41 00 F3 7A 1C 69 79 75  54 78 0B B3 8C C5 A9 9F  A..z.iyuTx......
00000020: 5E DE 4C F7 3C 3E C2 49  3A 18 39 B3 DB CB A3 F6  ^.L.<>.I:.9.....
00000030: EA 46 C5 B7 68 4D F3 54  8E 7D DE B9 C3 BF 9C 73  .F..hM.T.}.....s
00000040: CC 3F 3B DE D7 4B 56 2B  FB 19 FB 84 02 2F 8E F4  .?;..KV+...../..
00000050: CD D9 37 95 D7 7D 06 ED  BB 7A AF 2F 58 89 18 50  ..7..}...z./X..P
00000060: AB BD CA 3D 20 39 8C 27  64 56 CB C4 21 58 40 7D  ...= 9.'dV..!X@}
00000070: D0 74 EE                                          .t.
```

次に、暗号化ペイロードをInitial Packetに格納します。

```py
initial_packet.length = VarLenIntEncoding(Uint16(len(ciphertext_payload_bytes) + packet_number_len))
initial_packet.packet_payload = OpaqueLength(ciphertext_payload_bytes)
initial_packet.update()
print(initial_packet)
```

暗号化ペイロードを含むInitial Packetは次のようになります。

```
InitialPacket:
+ flags: LongPacketFlags(header_form=1(Long), fixed_bit=1,
  long_packet_type=00(Initial), type_specific_bits=0001)
+ version: QUICVersions.QUICv1(Uint32(0x00000001))
+ dest_conn_id: Opaque<Uint8>(b'')
+ src_conn_id: Opaque<Uint8>(b'\xf0g\xa5P*Bb\xb5')
+ token: Opaque<VarLenIntEncoding>(b'')
+ length: VarLenIntEncodingUint16(0x0075)
+ packet_number: Uint16(0x0001)
+ packet_payload: Opaque[117](b"ZH,\xd0\x99\x1c\xd2[\n\xac@jX\x16\xb69A\x
  00\xf3z\x1ciyuTx\x0b\xb3\x8c\xc5\xa9\x9f^\xdeL\xf7<>\xc2I:\x189\xb3\xdb
  \xcb\xa3\xf6\xeaF\xc5\xb7hM\xf3T\x8e}\xde\xb9\xc3\xbf\x9cs\xcc?;\xde\xd
  7KV+\xfb\x19\xfb\x84\x02/\x8e\xf4\xcd\xd97\x95\xd7}\x06\xed\xbbz\xaf/X\
  x89\x18P\xab\xbd\xca= 9\x8c'dV\xcb\xc4!X@}\xd0t\xee")
```

### 4. パケットのヘッダー保護をする

次に、Client Initial Packet と同様に header_protection 関数でヘッダーの保護をします。

```py
send_packet = LongPacket.from_bytes(bytes(initial_packet))
send_packet_bytes = header_protection(send_packet, cs_hp, mode='encrypt', debug=True)
print('encrypted packet:')
print(hexdump(send_packet_bytes))
```

ヘッダー保護の処理のデバッグモードをOnにして、ヘッダー保護をした結果は次のようになります。

```
sample:
00000000: 2C D0 99 1C D2 5B 0A AC  40 6A 58 16 B6 39 41 00  ,....[..@jX..9A.
mask:
00000000: 2E C0 D8 35 6A                                    ...5j

encrypted packet:
00000000: CF 00 00 00 01 00 08 F0  67 A5 50 2A 42 62 B5 00  ........g.P*Bb..
00000010: 40 75 C0 D9 5A 48 2C D0  99 1C D2 5B 0A AC 40 6A  @u..ZH,....[..@j
00000020: 58 16 B6 39 41 00 F3 7A  1C 69 79 75 54 78 0B B3  X..9A..z.iyuTx..
00000030: 8C C5 A9 9F 5E DE 4C F7  3C 3E C2 49 3A 18 39 B3  ....^.L.<>.I:.9.
00000040: DB CB A3 F6 EA 46 C5 B7  68 4D F3 54 8E 7D DE B9  .....F..hM.T.}..
00000050: C3 BF 9C 73 CC 3F 3B DE  D7 4B 56 2B FB 19 FB 84  ...s.?;..KV+....
00000060: 02 2F 8E F4 CD D9 37 95  D7 7D 06 ED BB 7A AF 2F  ./....7..}...z./
00000070: 58 89 18 50 AB BD CA 3D  20 39 8C 27 64 56 CB C4  X..P...= 9.'dV..
00000080: 21 58 40 7D D0 74 EE                              !X@}.t.
```

[RFC 9001 - A.3. Server Initial](https://www.rfc-editor.org/rfc/rfc9001#section-a.3) のところに暗号化したパケットの結果が書いてあるので、これとバイト列で比較を行なったところ、一致したため、Server Initial Packert の暗号化とヘッダー保護は期待通りにできました。


### おわりに

暗号化パケットを投げて反応を見るためには、まず暗号化パケット作る必要があったので、今回は暗号化をしました。
次回はQUICパケットでTLSハンドシェイクを投げる検証をしたいと思います。

自分で実装してみることで、わからなかった部分が明確になってよかったです。
特に、Client Initial Packet を暗号化をするときに、暗号化後のパケットのヘッダの情報（ペイロード長など）が必要なので、「鶏が先か、卵が先か」問題が存在するのでは？と思っていましたが誤解でした。
暗号化前の情報から全て計算によって暗号化後のヘッダ情報を求めることができるので、鶏卵問題はありませんでした。
自己解決できてよかったです。

### 参考文献

- [RFC 9000: QUIC: A UDP-Based Multiplexed and Secure Transport](https://www.rfc-editor.org/rfc/rfc9000)
- [RFC 9001: Using TLS to Secure QUIC](https://www.rfc-editor.org/rfc/rfc9001)
