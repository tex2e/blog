---
layout:        post
title:         "QUIC の Initial Packet を復号する"
date:          2021-08-14
category:      Protocol
cover:         /assets/cover5.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    true
syntaxhighlight: true
# sitemap: false
# feed:    false
---

QUIC の Initial Packet のヘッダ保護解除とペイロード復号を Python で実装して復号してみます。

### はじめに

QUICパケットは暗号化通信をする際に (1) パケットのペイロードを暗号化して (2) パケットのヘッダーを暗号化します。
ここでは説明のために、前者を「暗号化」、後者を「ヘッダー保護」と呼ぶことにしています。
QUICパケットの復号は、ヘッダ保護を解除してからペイロードを復号します。
本記事では [RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000), [RFC 9001](https://datatracker.ietf.org/doc/html/rfc9001) の仕様を元に、Initial Packetのヘッダ保護解除とペイロード復号をPythonで実装していきます。

### 1. Client Initial Packet を解析する

Initial Packet は通常UDPで受信しますが、今回はすでにバイト列を受信したとして、その後の解析に注目していきます。
解析対象は RFC 9001 の付録Aに書かれている Client Initial の暗号化パケットを解析していきます ([RFC 9001 - A.2. Client Initial](https://www.rfc-editor.org/rfc/rfc9001.html#section-a.2))。

Client Initial の先頭バイト列は以下のような感じになっています。
```
c000000001088394c8f03e5157080000 449e7b9aec34d1b1c98dd7689fb8ec11
d242b123dc9bd8bab936b47d92ec356c 0bab7df5976d27cd449f63300099f399
...
```

これをRFC 9000のInitial Packetのデータ構造 ([RFC 9000 - 17.2.2. Initial Packet](https://www.rfc-editor.org/rfc/rfc9000.html#section-17.2.2)) と照らし合わせて確認します。
Initial Packet はペイロード (Payload) を暗号化した後にヘッダー保護 (Header Protection) をしているため、受信した時点では、パケット番号 (Packet Number) の長さとデータがわからない状態です。
パケット番号はペイロードの暗号化・復号で使用するため、復号時には知っている必要がある情報です。

```
Initial Packet {
  Header Form (1) = 1,
  Fixed Bit (1) = 1,
  Long Packet Type (2) = 0,
  Reserved Bits (2),         # Protected
  Packet Number Length (2),  # Protected
  Version (32),
  DCID Len (8),
  Destination Connection ID (0..160),
  SCID Len (8),
  Source Connection ID (0..160),
  Token Length (i),
  Token (..),
  Length (i),
  Packet Number (8..32),     # Protected
  Protected Payload (0..24), # Skipped Part
  Protected Payload (128),   # Sampled Part
  Protected Payload (..)     # Remainder
}
```

そのため、受信データをまずは Long Packet のデータ構造として解析し、ヘッダー保護を解除した後に、Initial Packet のデータ構造として解釈しておきます ([RFC 9000 - 17.2. Long Header Packets](https://www.rfc-editor.org/rfc/rfc9000.html#section-17.2))。

```
Long Header Packet {
  Header Form (1) = 1,
  Fixed Bit (1) = 1,
  Long Packet Type (2),
  Type-Specific Bits (4),
  Version (32),
  Destination Connection ID Length (8),
  Destination Connection ID (0..160),
  Source Connection ID Length (8),
  Source Connection ID (0..160),
  Type-Specific Payload (..),
}
```

上のデータ構造を Python で実装し、バイト列からデータ構造のオブジェクトに変換するものを作成します。
筆者自身が TLS 1.3 実装時に作った、データ型を扱う [metatype.py](https://gist.github.com/tex2e/a55cfe8f006799ff745dc888a0149183#file-metatype-py) とデータ構造を扱う [metastruct.py](https://gist.github.com/tex2e/a55cfe8f006799ff745dc888a0149183#file-metastruct-py) を使って、Long Packet と Initial Packet を扱うデータ構造クラスを定義します。

metatype.py について簡単に説明すると、型とバイト列を相互変換するためのクラスで、例えば Uint8 は整数 `1` とバイト列 `0x01` の変換、Uint32 は `1` と `0x00000001` の変換、OpaqueUint8 はデータ長とデータのペアで `0x0401020304` のような形式を扱うためのクラスです。
追加で、QUIC 特有の整数エンコード方式に「可変長整数エンコード ([RFC 9000 - 16. Variable-Length Integer Encoding](https://www.rfc-editor.org/rfc/rfc9000.html#section-16))」があり、最上位2ビットの値でデータ長を表して残りのビットで整数の値を表す、符号なし整数型の亜種です。ここでは VarLenIntEncoding クラスとして定義・使用しています。

また、metastruct.py については、クラス変数にType Hintsで型を指定すると、定義したクラス変数の順番に型がバイト列やストリーム文字列を読みながらデータ構造を復元していくための meta.MetaStruct 抽象クラスと、構造体を定義するための meta.struct デコレータを定義・使用しています。

```python
from metatype import Uint8, Uint32, Opaque, OpaqueUint8, VarLenIntEncoding, Type, Enum
import metastruct as meta

class LongPacketFlags(Type):
    def __init__(self, header_form, fixed_bit, long_packet_type, type_specific_bits):
        # ...省略...

    @classmethod
    def from_stream(cls, fs, parent=None):
        flags = fs.read(1)
        header_form        = (ord(flags) & 0b10000000) >> 7
        fixed_bit          = (ord(flags) & 0b01000000) >> 6
        long_packet_type   = (ord(flags) & 0b00110000) >> 4
        type_specific_bits = (ord(flags) & 0b00001111) >> 0
        return LongPacketFlags(header_form, fixed_bit,
                               long_packet_type, type_specific_bits)

    def __bytes__(self):
        # ...省略...
    def __repr__(self):
        # ...省略...

@meta.struct
class LongPacket(meta.MetaStruct):
    flags: LongPacketFlags # Protected
    version: Uint32
    dest_conn_id: OpaqueUint8
    src_conn_id: OpaqueUint8
    token: Opaque(VarLenIntEncoding)
    length: VarLenIntEncoding
    protected_payload: Opaque(lambda self: self.length) # Protected

@meta.struct
class InitialPacket(meta.MetaStruct):
    flags: LongPacketFlags
    version: Uint32
    dest_conn_id: OpaqueUint8
    src_conn_id: OpaqueUint8
    token: Opaque(VarLenIntEncoding)
    length: VarLenIntEncoding
    packet_number: Opaque(lambda self: self.flags.type_specific_bits_lsb2bit + 1)
    packet_payload: Opaque(lambda self: int(self.length) - self.packet_number.get_size())

    def get_header_bytes(self):
        # AEAD Auth Data
        return bytes(self.flags) + bytes(self.version) + bytes(self.dest_conn_id) + \
               bytes(self.src_conn_id) + bytes(self.token) + bytes(self.length) + \
               bytes(self.packet_number)

    def get_packet_number_int(self):
        return int.from_bytes(bytes(self.packet_number), 'big')
```

定義した LongPacket クラスで、受信したパケットをデータ構造に from_bytes メソッドで変換します。

```python
recv_msg = bytes.fromhex("""
c000000001088394c8f03e5157080000 449e7b9aec34d1b1c98dd7689fb8ec11
d242b123dc9bd8bab936b47d92ec356c 0bab7df5976d27cd449f63300099f399
...省略...
""")

recv_packet = LongPacket.from_bytes(recv_msg)
recv_packet_bytes = bytes(recv_packet)
print(recv_packet)
print(hexdump(recv_packet_bytes))
```

LongPacket インスタンスの出力は以下のようになります。Version や Length が正しく取得できていることを確認します。

```
LongPacket:
+ flags: header_form=1(Long), fixed_bit=1, long_packet_type=00(Initial),
  type_specific_bits=0000
+ version: Uint32(0x00000001)
+ dest_conn_id: Opaque<Uint8>(b'\x83\x94\xc8\xf0>QW\x08')
+ src_conn_id: Opaque<Uint8>(b'')
+ token: Opaque<VarLenIntEncoding>(b'')
+ length: QuicUint16(0x049e)
+ protected_payload: Opaque[1182](b'{\x9a\xec4\xd1\xb1\xc9\x8d\xd7h\x9f...\x19L\xd94')

00000000: C0 00 00 00 01 08 83 94  C8 F0 3E 51 57 08 00 00  ..........>QW...
00000010: 44 9E 7B 9A EC 34 D1 B1  C9 8D D7 68 9F B8 EC 11  D.{..4.....h....
00000020: D2 42 B1 23 DC 9B D8 BA  B9 36 B4 7D 92 EC 35 6C  .B.#.....6.}..5l
...省略...
```

### 2. 復号に必要な鍵を導出する

復号に必要な鍵は鍵導出関数を用いて求めます。
クライアントからの送信情報から導出できる初期シークレットは求め方は [RFC 9001 - 5.2. Initial Secrets](https://www.rfc-editor.org/rfc/rfc9001.html#section-5.2) に書かれています。
さらに、初期シークレットから暗号化・復号とヘッダ保護・解除のために以下の3つの値を鍵導出関数で求めます ([RFC 9001 - 5.1. Packet Protection Keys](https://www.rfc-editor.org/rfc/rfc9001.html#section-5.1) や [RFC 9001 - A.1. Keys](https://www.rfc-editor.org/rfc/rfc9001.html#section-a.1) 参照)。

- 鍵 (key) : AEADでの暗号化・復号に使用する
- 初期ベクタ (iv; Initialization Vector) : AEADでの暗号化・復号で必要なナンス (Nonce) を作るために必要な値
- ヘッダー保護鍵 (hp; Header Protection Key) : ヘッダーにあるパケット番号情報を保護・解除をする

鍵導出関数は TLS 1.3 の鍵スケジュールで使用しているHMACベースの鍵導出関数HKDFを使います。
仕様の詳細は [RFC 5869 - HKDF-Extract](https://datatracker.ietf.org/doc/html/rfc5869#section-2.2) と [RFC 8446 - HKDF-Expand-Label](https://datatracker.ietf.org/doc/html/rfc8446#section-7.1) に書かれています。
以前 [TLS 1.3 の実装](https://github.com/tex2e/mako-tls13)をしたことがあり、HKDF関連の関数をまとめた [crypto_hkdf.py](https://github.com/tex2e/mako-tls13/blob/master/crypto_hkdf.py) から当該関数をコピーして使います。

QUICのパケット暗号化で必要な鍵は次の手順で求めます。

<figure>
<img src="{{ site.baseurl }}/media/post/quic/quic-initial-packet-decrypt-keyschedule.png" />
<figcaption>QUICの鍵導出プロセス</figcaption>
</figure>

必要な鍵導出関数HKDFをPythonで定義したものが次のプログラムです。

```python
# protocol_keyschedule.py

import hmac
import hashlib
from metatype import Uint8, Uint16, Opaque
OpaqueUint8 = Opaque(Uint8)

def divceil(n, d) -> int:
    q, r = divmod(n, d)
    return q + bool(r)

def secure_HMAC(key, msg, hash_name='sha256') -> bytearray:
    return bytearray(hmac.new(key, msg, getattr(hashlib, hash_name)).digest())

def HKDF_extract(salt, IKM, hash_name='sha256') -> bytearray:
    # HKDF-Extract (https://tools.ietf.org/html/rfc5869#section-2.2)
    return secure_HMAC(salt, IKM, hash_name)

def HKDF_expand(PRK, info, L, hash_name='sha256') -> bytearray:
    # HKDF-Expand (https://tools.ietf.org/html/rfc5869#section-2.3)
    N = divceil(L, getattr(hashlib, hash_name)().digest_size)
    T      = bytearray()
    T_prev = bytearray()
    for x in range(1, N+2):
        T += T_prev
        T_prev = secure_HMAC(PRK, T_prev + info + bytearray([x]), hash_name)
    return T[:L]

def HKDF_expand_label(secret, label, hash_value, length,
                      hash_name='sha256') -> bytearray:
    # HKDF-Expand-Label (https://tools.ietf.org/html/rfc8446#section-7.1)
    hkdf_label = b''
    hkdf_label += bytes(Uint16(length))
    hkdf_label += bytes(OpaqueUint8(b'tls13 ' + label))
    hkdf_label += bytes(OpaqueUint8(hash_value))

    out = HKDF_expand(secret, hkdf_label, length, hash_name)
    return out
```

次に、鍵導出で使う初期ソルトと、鍵、初期ベクトル、ヘッダー保護鍵を生成する関数をPythonで書くと以下のようになります。
初期ソルトはQUICバージョンごとに異なる値が使われますが、RFCに定義されている固定値が使用されます ([RFC 9001 - 5.2. Initial Secrets](https://www.rfc-editor.org/rfc/rfc9001.html#section-5.2))。
また、今回は暗号スイートに TLS_AES_128_GCM_SHA256 を使っていることを想定しているので、SHA256でHash.lengthは32、AES128-GCMでAEAD.key_lengthは16、AEAD.iv_lengthは12となります。
補足ですが、AEADで ChaCha20-Poly1305 を使う場合は鍵長AEAD.key_lengthは32となるので注意が必要です。

```python
# protocol_packetprotection.py

from protocol_keyschedule import HKDF_expand_label

initial_salt = bytes.fromhex('38762cf7f55934b34d179ae6a4c80cadccbb7f0a')

def get_key_iv_hp(cs_initial_secret):
    cs_key = HKDF_expand_label(cs_initial_secret, b'quic key', b'', 16)
    cs_iv = HKDF_expand_label(cs_initial_secret, b'quic iv', b'', 12)
    cs_hp = HKDF_expand_label(cs_initial_secret, b'quic hp', b'', 16)
    return cs_key, cs_iv, cs_hp
```

最後にTLS 1.3 の鍵導出関数HKDFを使って、鍵導出の手順をプログラムで実装すると次のようになります。

```python
from protocol_keyschedule import HKDF_extract, HKDF_expand_label
from protocol_packetprotection import initial_salt, get_key_iv_hp
initial_secret = HKDF_extract(initial_salt, client_dst_connection_id)
client_initial_secret = HKDF_expand_label(initial_secret, b'client in', b'', 32)
server_initial_secret = HKDF_expand_label(initial_secret, b'server in', b'', 32)
client_key, client_iv, client_hp = get_key_iv_hp(client_initial_secret)
server_key, server_iv, server_hp = get_key_iv_hp(server_initial_secret)
```

導出した鍵の一覧（16進数ダンプ）は次のようになります。

```
initial_secret:
00000000: 7D B5 DF 06 E7 A6 9E 43  24 96 AD ED B0 08 51 92  }......C$.....Q.
00000010: 35 95 22 15 96 AE 2A E9  FB 81 15 C1 E9 ED 0A 44  5."...*........D
client_initial_secret:
00000000: C0 0C F1 51 CA 5B E0 75  ED 0E BF B5 C8 03 23 C4  ...Q.[.u......#.
00000010: 2D 6B 7D B6 78 81 28 9A  F4 00 8F 1F 6C 35 7A EA  -k}.x.(.....l5z.
client_key:
00000000: 1F 36 96 13 DD 76 D5 46  77 30 EF CB E3 B1 A2 2D  .6...v.Fw0.....-
client_iv:
00000000: FA 04 4B 2F 42 A3 FD 3B  46 FB 25 5C              ..K/B..;F.%\
client_hp:
00000000: 9F 50 44 9E 04 A0 E8 10  28 3A 1E 99 33 AD ED D2  .PD.....(:..3...
server_initial_secret:
00000000: 3C 19 98 28 FD 13 9E FD  21 6C 15 5A D8 44 CC 81  <..(....!l.Z.D..
00000010: FB 82 FA 8D 74 46 FA 7D  78 BE 80 3A CD DA 95 1B  ....tF.}x..:....
server_key:
00000000: CF 3A 53 31 65 3C 36 4C  88 F0 F3 79 B6 06 7E 37  .:S1e<6L...y..~7
server_iv:
00000000: 0A C1 49 3C A1 90 58 53  B0 BB A0 3E              ..I<..XS...>
server_hp:
00000000: C2 06 B8 D9 B9 F0 F3 76  44 43 0B 49 0E EA A3 14  .......vDC.I....
```

### 3. パケットのヘッダー保護を解除する

必要な鍵が揃ったら、続いてパケットのヘッダー保護を解除します。
Initial Packetにおいて、ヘッダー保護されている部分の情報はパケット番号長 (Packet Number Length) とパケット番号 (Packet Number) です。
ヘッダ保護の解除には次の値が必要となります。

- ヘッダー保護鍵 (hp_key) : QUICの鍵導出プロセスで求めたヘッダーを保護するための鍵
- サンプル (sample) : 暗号化ペイロードの一部分がサンプリングされ、マスクの作成に使われます

パケットのヘッダー保護を解除する手順は次の図のようになります。

<figure>
<img src="{{ site.baseurl }}/media/post/quic/quic-initial-packet-decrypt-header-protect.png" />
<figcaption>QUICパケットのヘッダ保護解除の流れ</figcaption>
</figure>

暗号化ペイロードから一部分がサンプリングされて、マスクの作成に使われますが、この sample は以下の擬似Pythonコードで定義されています ([RFC 9001 - 5.4.2. Header Protection Sample](https://www.rfc-editor.org/rfc/rfc9001#section-5.4.2))。

```
pn_offset = 7 + len(destination_connection_id) + len(source_connection_id) +
                len(payload_length)
if packet_type == Initial:
    pn_offset += len(token_length) + len(token)

sample_offset = pn_offset + 4

sample = packet[sample_offset..sample_offset+sample_length]
```

以上より、パケットのヘッダー保護を解除する図の流れをPythonで実装すると次のようになります。
なお、AES は ECB モードで行い、cryptographyライブラリを使用しました ([Cryptography - Symmetric encryption](https://cryptography.io/en/latest/hazmat/primitives/symmetric-encryption/#module-cryptography.hazmat.primitives.ciphers))。

```python
def header_protection(long_packet: LongPacket, sc_hp_key) -> bytes:
    recv_packet_bytes = bytes(long_packet)

    def get_np_offset_and_sample_offset(long_packet: LongPacket) -> (int, int):
        assert isinstance(long_packet, LongPacket)
        pn_offset = 7 + len(long_packet.dest_conn_id) + \
                        len(long_packet.src_conn_id) + \
                        len(long_packet.length)
        if PacketType(long_packet.flags.long_packet_type) == PacketType.INITIAL:
            pn_offset += len(bytes(long_packet.token))

        sample_offset = pn_offset + 4  # パケット番号(最大4byte)を含まない位置から開始

        return pn_offset, sample_offset

    pn_offset, sample_offset = get_np_offset_and_sample_offset(recv_packet)

    sample_length = 16  # AESの鍵長
    # Sample取得
    sample = recv_packet_bytes[sample_offset:sample_offset+sample_length]
    print('sample:')
    print(hexdump(sample))

    def generate_mask(hp_key, sample) -> bytes:
        cipher = Cipher(algorithms.AES(key=hp_key), modes.ECB())
        encryptor = cipher.encryptor()
        ct = encryptor.update(sample) + encryptor.finalize()
        mask = bytearray(ct)[0:5]
        return mask

    # Mask作成
    mask = generate_mask(sc_hp_key, sample)
    print('mask:')
    print(hexdump(mask))

    recv_packet_bytes = bytearray(recv_packet_bytes)
    if (recv_packet_bytes[0] & 0x80) == 0x80:
        # Long header: 4 bits masked
        recv_packet_bytes[0] ^= mask[0] & 0x0f
    else:
        # Short header: 5 bits masked
        recv_packet_bytes[0] ^= mask[0] & 0x1f
    
    # ヘッダ保護解除後にパケット番号の長さ取得
    pn_length = (recv_packet_bytes[0] & 0x03) + 1

    # pn_offset is the start of the Packet Number field.
    recv_packet_bytes[pn_offset:pn_offset+pn_length] = \
        bytexor(recv_packet_bytes[pn_offset:pn_offset+pn_length], mask[1:1+pn_length])

    return recv_packet_bytes

recv_packet_bytes = header_protection(recv_packet, client_hp)

initial_packet = InitialPacket.from_bytes(recv_packet_bytes)
initial_packet_bytes = bytes(initial_packet)
print(initial_packet)
print(hexdump(initial_packet_bytes))
```

例のヘッダー保護されているLong Packetに対して、
ヘッダー保護の解除をするときのsampleとmaskのバイト列は次のようになります。

```
sample:
00000000: D1 B1 C9 8D D7 68 9F B8  EC 11 D2 42 B1 23 DC 9B  .....h.....B.#..
mask:
00000000: 43 7B 9A EC 36                                    C{..6
```

Long Packetのヘッダー保護を解除して、データ構造を表すInitialPacketクラスに解析させて作成されたオブジェクトを確認すると、次のようになります。
ヘッダー保護でわからなかったパケット番号 (packet_number) が 0x00000002 のように正しく取得できている点に注目してください。

```
InitialPacket:
+ flags: header_form=1(Long), fixed_bit=1, long_packet_type=00(Initial),
  type_specific_bits=0011
+ version: Uint32(0x00000001)
+ dest_conn_id: Opaque<Uint8>(b'\x83\x94\xc8\xf0>QW\x08')
+ src_conn_id: Opaque<Uint8>(b'')
+ token: Opaque<VarLenIntEncoding>(b'')
+ length: QuicUint16(0x049e)
+ packet_number: Opaque[4](b'\x00\x00\x00\x02')
+ packet_payload: Opaque[1178](b'\xd1\xb1\xc9\x8d\xd7h\x9f...\x19L\xd94')

00000000: C3 00 00 00 01 08 83 94  C8 F0 3E 51 57 08 00 00  ..........>QW...
00000010: 44 9E 00 00 00 02 D1 B1  C9 8D D7 68 9F B8 EC 11  D..........h....
00000020: D2 42 B1 23 DC 9B D8 BA  B9 36 B4 7D 92 EC 35 6C  .B.#.....6.}..5l
...省略...
```

### 4. 暗号化ペイロードを復号する

ヘッダー保護が解除できたことでパケット番号がわかるため、続いてペイロードの復号ができるようになります。
ペイロードは複数のフレーム ([RFC 9000 - 12.4. Frames and Frame Types](https://www.rfc-editor.org/rfc/rfc9000#section-12.4)) を含めることができます。フレームは種類とデータから構成されます。フレーム種類には ACKフレームは 0x02、TLSの暗号化通信に関連するフレームは 0x06、パディングフレームは 0x00 などがあります。

ペイロードはAEADで暗号化されます。[RFC 9001 - 5.4.1. Header Protection Application](https://www.rfc-editor.org/rfc/rfc9001#section-5.4.1) ではQUICペイロードの暗号化に以下の4つのAEADアルゴリズムについて書かれています。

- AEAD_AES_128_GCM
- AEAD_AES_256_GCM
- AEAD_AES_128_CCM
- AEAD_CHACHA20_POLY1305

今回は AEAD_AES_128_GCM で暗号化されていることを想定して、ペイロードを復号します。
AEADの暗号化・復号で必要な値は次の4つです。

- ペイロード / 暗号化ペイロード : AEADへ入力する平文 / 暗号文
- 鍵 (Key) : 暗号化・復号するための共通鍵
- ナンス (Nonce) : 一度しか使用しないランダムな文字列
- 追加認証情報 (Additional Authentication Data; AAD) : 暗号化・復号時に使用するラベル

パケットのペイロードを復号する手順は次の図のようになります。

<figure>
<img src="{{ site.baseurl }}/media/post/quic/quic-initial-packet-decrypt-payload.png" />
<figcaption>QUICパケットのペイロード復号の流れ</figcaption>
</figure>

QUICパケットのペイロードを復号する図の流れをPythonで実装すると、次のようになります。
なお、暗号化・復号には cryptographyライブラリのAESGCMを使用しました ([Cryptography - AESGCM](https://cryptography.io/en/latest/hazmat/primitives/aead/#cryptography.hazmat.primitives.ciphers.aead.AESGCM))。

```python
packet_number = initial_packet.get_packet_number_int()
packet_number_bytes = packet_number.to_bytes(len(client_iv), 'big')
print('packet_number:')
print(hexdump(packet_number_bytes))

nonce = bytexor(packet_number_bytes, client_iv)
print('nonce:')
print(hexdump(nonce))

aad = initial_packet.get_header_bytes()
print('aad:')
print(hexdump(aad))

data = bytes(initial_packet.packet_payload)
print('data:')
print(hexdump(data))
aesgcm = AESGCM(key=client_key)

decrypted = aesgcm.decrypt(nonce, data, aad)
print('decrypted')
print(hexdump(decrypted))
```

例のInitialPacketを復号する際にAEADに入力するパケット番号、ナンス、AADは次の通りです。

```
packet_number:
00000000: 00 00 00 00 00 00 00 00  00 00 00 02              ............
nonce:
00000000: FA 04 4B 2F 42 A3 FD 3B  46 FB 25 5E              ..K/B..;F.%^
aad:
00000000: C3 00 00 00 01 08 83 94  C8 F0 3E 51 57 08 00 00  ..........>QW...
00000010: 44 9E 00 00 00 02                                 D.....
```

そして、暗号化ペイロード (data) と復号したペイロード (decrypted) を16進数ダンプした結果は次のようになります。

```
data:
00000000: D1 B1 C9 8D D7 68 9F B8  EC 11 D2 42 B1 23 DC 9B  .....h.....B.#..
00000010: D8 BA B9 36 B4 7D 92 EC  35 6C 0B AB 7D F5 97 6D  ...6.}..5l..}..m
00000020: 27 CD 44 9F 63 30 00 99  F3 99 1C 26 0E C4 C6 0D  '.D.c0.....&....
00000030: 17 B3 1F 84 29 15 7B B3  5A 12 82 A6 43 A8 D2 26  ....).{.Z...C..&
00000040: 2C AD 67 50 0C AD B8 E7  37 8C 8E B7 53 9E C4 D4  ,.gP....7...S...
00000050: 90 5F ED 1B EE 1F C8 AA  FB A1 7C 75 0E 2C 7A CE  ._........|u.,z.
...省略...

decrypted
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
...省略...
```

復号した平文ペイロードの先頭1byteはフレームタイプを表しており、タイプが 0x06 は CRYPTO Frames であるので、正しく元のフレームに戻っていることが確認できます ([RFC 9000 - 19.6. CRYPTO Frames](https://www.rfc-editor.org/rfc/rfc9000#section-19.6))。
また、平文ペイロードの16進数ダンプのASCII部分を見ると、example.com が見えているので、正しく復号できていることが確認できます。
[RFC 9001 - A.2. Client Initial](https://www.rfc-editor.org/rfc/rfc9001.html#section-a.2) の暗号化前のCRYPTO Frameと一致していることが確認できます。


### 5. Server Initial Packet を解析する

Server Initial は Client Initial と同じように復号することができます。
解析対象は RFC 9001 の付録Aに書かれている Server Initial の暗号化パケットを解析していきます
[RFC 9001 - A.3. Server Initial](https://www.rfc-editor.org/rfc/rfc9001.html#section-a.3)。

Server Initial の先頭バイト列は以下のような感じになっています。

```
cf000000010008f067a5502a4262b500 4075c0d95a482cd0991cd25b0aac406a
5816b6394100f37a1c69797554780bb3 8cc5a99f5ede4cf73c3ec2493a1839b3
...省略...
```

鍵導出時の注意点として、初期シークレット (Initial Secret) を作成するときのクライアントの宛先接続ID (client_dst_connection_id) はクライアントから受信したQUICパケットに書かれている宛先接続IDを使います。

ヘッダー保護解除時とペイロード復号時の注意点として、サーバ側から送信するパケットは server_key, server_iv, server_hp で暗号化・保護されているので、復号も server_* を使用します。

Server Initial のヘッダー保護解除とペイロード復号時に渡している変数名を client_* から server_* に変えてプログラムを実行したときの結果は次のようになります。

```
LongPacket:
+ flags: header_form=1(Long), fixed_bit=1, long_packet_type=00(Initial),
  type_specific_bits=1111
+ version: Uint32(0x00000001)
+ dest_conn_id: Opaque<Uint8>(b'')
+ src_conn_id: Opaque<Uint8>(b'\xf0g\xa5P*Bb\xb5')
+ token: Opaque<VarLenIntEncoding>(b'')
+ length: QuicUint16(0x0075)
+ protected_payload: Opaque[117](b"\xc0\xd9ZH,\xd0\x99...\xd0t\xee")
00000000: CF 00 00 00 01 00 08 F0  67 A5 50 2A 42 62 B5 00  ........g.P*Bb..
00000010: 40 75 C0 D9 5A 48 2C D0  99 1C D2 5B 0A AC 40 6A  @u..ZH,....[..@j
00000020: 58 16 B6 39 41 00 F3 7A  1C 69 79 75 54 78 0B B3  X..9A..z.iyuTx..
00000030: 8C C5 A9 9F 5E DE 4C F7  3C 3E C2 49 3A 18 39 B3  ....^.L.<>.I:.9.
00000040: DB CB A3 F6 EA 46 C5 B7  68 4D F3 54 8E 7D DE B9  .....F..hM.T.}..
00000050: C3 BF 9C 73 CC 3F 3B DE  D7 4B 56 2B FB 19 FB 84  ...s.?;..KV+....
00000060: 02 2F 8E F4 CD D9 37 95  D7 7D 06 ED BB 7A AF 2F  ./....7..}...z./
00000070: 58 89 18 50 AB BD CA 3D  20 39 8C 27 64 56 CB C4  X..P...= 9.'dV..
00000080: 21 58 40 7D D0 74 EE                              !X@}.t.
---
initial_secret:
00000000: 7D B5 DF 06 E7 A6 9E 43  24 96 AD ED B0 08 51 92  }......C$.....Q.
00000010: 35 95 22 15 96 AE 2A E9  FB 81 15 C1 E9 ED 0A 44  5."...*........D
client_initial_secret:
00000000: C0 0C F1 51 CA 5B E0 75  ED 0E BF B5 C8 03 23 C4  ...Q.[.u......#.
00000010: 2D 6B 7D B6 78 81 28 9A  F4 00 8F 1F 6C 35 7A EA  -k}.x.(.....l5z.
client_key:
00000000: 1F 36 96 13 DD 76 D5 46  77 30 EF CB E3 B1 A2 2D  .6...v.Fw0.....-
client_iv:
00000000: FA 04 4B 2F 42 A3 FD 3B  46 FB 25 5C              ..K/B..;F.%\
client_hp:
00000000: 9F 50 44 9E 04 A0 E8 10  28 3A 1E 99 33 AD ED D2  .PD.....(:..3...
server_initial_secret:
00000000: 3C 19 98 28 FD 13 9E FD  21 6C 15 5A D8 44 CC 81  <..(....!l.Z.D..
00000010: FB 82 FA 8D 74 46 FA 7D  78 BE 80 3A CD DA 95 1B  ....tF.}x..:....
server_key:
00000000: CF 3A 53 31 65 3C 36 4C  88 F0 F3 79 B6 06 7E 37  .:S1e<6L...y..~7
server_iv:
00000000: 0A C1 49 3C A1 90 58 53  B0 BB A0 3E              ..I<..XS...>
server_hp:
00000000: C2 06 B8 D9 B9 F0 F3 76  44 43 0B 49 0E EA A3 14  .......vDC.I....
sample:
00000000: 2C D0 99 1C D2 5B 0A AC  40 6A 58 16 B6 39 41 00  ,....[..@jX..9A.
mask:
00000000: 2E C0 D8 35 6A                                    ...5j
---
InitialPacket:
+ flags: header_form=1(Long), fixed_bit=1, long_packet_type=00(Initial),
  type_specific_bits=0001
+ version: Uint32(0x00000001)
+ dest_conn_id: Opaque<Uint8>(b'')
+ src_conn_id: Opaque<Uint8>(b'\xf0g\xa5P*Bb\xb5')
+ token: Opaque<VarLenIntEncoding>(b'')
+ length: QuicUint16(0x0075)
+ packet_number: Opaque[2](b'\x00\x01')
+ packet_payload: Opaque[115](b"ZH,\xd0\x99...\xd0t\xee")
00000000: C1 00 00 00 01 00 08 F0  67 A5 50 2A 42 62 B5 00  ........g.P*Bb..
00000010: 40 75 00 01 5A 48 2C D0  99 1C D2 5B 0A AC 40 6A  @u..ZH,....[..@j
00000020: 58 16 B6 39 41 00 F3 7A  1C 69 79 75 54 78 0B B3  X..9A..z.iyuTx..
00000030: 8C C5 A9 9F 5E DE 4C F7  3C 3E C2 49 3A 18 39 B3  ....^.L.<>.I:.9.
00000040: DB CB A3 F6 EA 46 C5 B7  68 4D F3 54 8E 7D DE B9  .....F..hM.T.}..
00000050: C3 BF 9C 73 CC 3F 3B DE  D7 4B 56 2B FB 19 FB 84  ...s.?;..KV+....
00000060: 02 2F 8E F4 CD D9 37 95  D7 7D 06 ED BB 7A AF 2F  ./....7..}...z./
00000070: 58 89 18 50 AB BD CA 3D  20 39 8C 27 64 56 CB C4  X..P...= 9.'dV..
00000080: 21 58 40 7D D0 74 EE                              !X@}.t.
packet_number:
00000000: 00 00 00 00 00 00 00 00  00 00 00 01              ............
nonce:
00000000: 0A C1 49 3C A1 90 58 53  B0 BB A0 3F              ..I<..XS...?
aad:
00000000: C1 00 00 00 01 00 08 F0  67 A5 50 2A 42 62 B5 00  ........g.P*Bb..
00000010: 40 75 00 01                                       @u..
data:
00000000: 5A 48 2C D0 99 1C D2 5B  0A AC 40 6A 58 16 B6 39  ZH,....[..@jX..9
00000010: 41 00 F3 7A 1C 69 79 75  54 78 0B B3 8C C5 A9 9F  A..z.iyuTx......
00000020: 5E DE 4C F7 3C 3E C2 49  3A 18 39 B3 DB CB A3 F6  ^.L.<>.I:.9.....
00000030: EA 46 C5 B7 68 4D F3 54  8E 7D DE B9 C3 BF 9C 73  .F..hM.T.}.....s
00000040: CC 3F 3B DE D7 4B 56 2B  FB 19 FB 84 02 2F 8E F4  .?;..KV+...../..
00000050: CD D9 37 95 D7 7D 06 ED  BB 7A AF 2F 58 89 18 50  ..7..}...z./X..P
00000060: AB BD CA 3D 20 39 8C 27  64 56 CB C4 21 58 40 7D  ...= 9.'dV..!X@}
00000070: D0 74 EE                                          .t.
decrypted
00000000: 02 00 00 00 00 06 00 40  5A 02 00 00 56 03 03 EE  .......@Z...V...
00000010: FC E7 F7 B3 7B A1 D1 63  2E 96 67 78 25 DD F7 39  ....{..c..gx%..9
00000020: 88 CF C7 98 25 DF 56 6D  C5 43 0B 9A 04 5A 12 00  ....%.Vm.C...Z..
00000030: 13 01 00 00 2E 00 33 00  24 00 1D 00 20 9D 3C 94  ......3.$... .<.
00000040: 0D 89 69 0B 84 D0 8A 60  99 3C 14 4E CA 68 4D 10  ..i....`.<.N.hM.
00000050: 81 28 7C 83 4D 53 11 BC  F3 2B B9 DA 1A 00 2B 00  .(|.MS...+....+.
00000060: 02 03 04                                          ...
```

[RFC 9001 - A.3. Server Initial](https://www.rfc-editor.org/rfc/rfc9001.html#section-a.3) の暗号化前の 0x02 から始まる ACK Frame と 0x06 から始まる CRYPTO Frame に一致していることが確認できます。
以上より、QUICパケットのペイロードの復号ができるプログラムが完成しました。


### おわりに

Cloudflareが公開しているHTTP/3のRust実装である[cloudflare/quiche](https://github.com/cloudflare/quiche)で通信したときのInitial Packetをバイト列にして自作したプログラムに渡しても正しく復号できました。そのときの結果をGistの [quic-packet-decrypt-result.txt](https://gist.github.com/tex2e/f12bb48c39f7d99903e91c8be1fee6ad) に乗せておきます。
テストベクタが欲しい人はこちらもご覧ください。

実験に使用したプログラムは Gist の [decrypt-quic-initial-packet.py](https://gist.github.com/tex2e/a5fd72c8a0c56f43d77bbfa446a820f1) と [metastruct.py, metatype.py, utils.py](https://gist.github.com/tex2e/a55cfe8f006799ff745dc888a0149183) に置いておきますので、参考にしてください。一部 TLS 1.3 の実装で使ったものが残っていて、今回の実験では使わなかった関数やクラスもありますので、適宜無視して読み進めてください。

TLS 1.3 実装経験者としては、自作の [tex2e/mako-tls13](https://github.com/tex2e/mako-tls13) から TLS 1.3 関連の実装を全部持ってくれば、CRYPTO Frame内のTLS Messageも簡単に解析できるのではないかと思っているのですが、その辺の検証は次回にしたいと思います。


### 参考文献

- [QUIC の Initial packet を Ruby で受けとる \| うなすけとあれこれ](https://blog.unasuke.com/2021/read-quic-initial-packet-by-ruby/)
- [RFC 9000: QUIC: A UDP-Based Multiplexed and Secure Transport](https://www.rfc-editor.org/rfc/rfc9000)
- [RFC 9001: Using TLS to Secure QUIC](https://www.rfc-editor.org/rfc/rfc9001)
