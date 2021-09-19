---
layout:        post
title:         "QUICのRetryパケット"
menutitle:     "QUIC の Retryパケット"
date:          2021-09-18
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

QUICには、クライアントが生成した接続先コネクションIDを拒否するための仕組みとしてRetryパケット（Retry Packet）というものが存在します。
ここではRetryが発生したときのQUICハンドシェイクの流れについて説明します。

#### Retryパケットの使い方

QUICではコネクションIDと呼ばれる識別子でコネクションを識別します。
通信の流れとしては、まずQUICの通信を開始するクライアントが、自分で「送信元コネクションID」と「宛先コネクションID」を生成します。
そしてこの2つをサーバに Initial Packet で送信します。
サーバは、受信した「宛先コネクションID」を使う場合は、そのままハンドシェイクが継続します。
逆に、一番最初のハンドシェイクなので**クライアントが生成した接続先コネクションIDを使いたくないとき**や、通信元アドレスが本物かどうかを確認したいときは、サーバは Retry Packet をクライアントに送り返します。
Retry Packet にはサーバ側の「送信元コネクションID」と認証のために使われる「トークン」が含まれています。
Retry Packet を受信したクライアントは、宛先コネクションIDとしてサーバ側の送信元コネクションIDを使用し、Retry Packetに含まれているトークンを Initial Packet に含めてペイロードを再送信します。

#### Retry時のハンドシェイクの流れ

[RFC 9000 - Figure 9: Example Handshake with Retry](https://www.rfc-editor.org/rfc/rfc9000#fig-retry) に書かれている、サーバがRetryパケットを送信する際のハンドシェイクの流れが以下の図になります。
左側がクライアント、右側がサーバです。
Initial[0] はパケット番号が「0」のInitial Packetを送信することを意味しており、その後ろの CRYPTO[CH] はペイロードがTLSメッセージのClientHello(CH)を含むCRYPTOフレームであることを表しています。
Initial+Token[1] はパケット番号が「1」のInitial Packetでトークンが含まれていることを表しています。

```fig
Client                                                  Server

Initial[0]: CRYPTO[CH] ->

                                                <- Retry+Token

Initial+Token[1]: CRYPTO[CH] ->

                                 Initial[0]: CRYPTO[SH] ACK[1]
                       Handshake[0]: CRYPTO[EE, CERT, CV, FIN]
                                 <- 1-RTT[0]: STREAM[1, "..."]
```

クライアントの宛先コネクションIDがサーバに受け入れられていない状態のときは、上図の流れからわかるように、Retryが発生するため、クライアントは最低1200byteのペイロードの内容が同じInitial Packetを2回送信する必要があります。
意外と無駄が多いです。



#### Retry時のパケット内容

Retry時のハンドシェイクをパケットキャプチャした結果の抜粋を以下に示しました。

`Initial[0]: CRYPTO[CH] ->` ではパケット番号「0」で Initial Packet を送信します。

```output
# Initial[0]: CRYPTO[CH]
Internet Protocol Version 4, Src: 127.0.0.1, Dst: 127.0.0.1
User Datagram Protocol, Src Port: 62492, Dst Port: 4433
QUIC IETF
    QUIC Connection information
    [Packet Length: 1201]
    1... .... = Header Form: Long Header (1)
    .1.. .... = Fixed Bit: True
    ..00 .... = Packet Type: Initial (0)
    .... 00.. = Reserved: 0
    .... ..11 = Packet Number Length: 4 bytes (3)
    Version: 1 (0x00000001)
    Destination Connection ID Length: 20
    Destination Connection ID: 1a26dc5bd9625e2bcd0efd3a329ce83136a32295
    Source Connection ID Length: 20
    Source Connection ID: c6b336557f9128bef8a099a10d320c26e9c8d1ab
    Token Length: 0
    Length: 1151
    Packet Number: 1
    Payload: 2375057687644e9effa614abb9d2e156a4f28fa00ed36a1e1b934916967bfb86d6123b0c…
    TLSv1.3 Record Layer: Handshake Protocol: Client Hello
        Frame Type: CRYPTO (0x0000000000000006)
        Offset: 0
        Length: 219
        Crypto Data
        Handshake Protocol: Client Hello
            Handshake Type: Client Hello (1)
            Length: 215
            Version: TLS 1.2 (0x0303)
            Random: 1f9acee37511743216e45c31f1ad8671dadd77162d3bb3f8a7a069b440dccb0e
            Session ID Length: 0
            Cipher Suites Length: 2
            Cipher Suites (1 suite)
                Cipher Suite: TLS_AES_128_GCM_SHA256 (0x1301)
            Compression Methods Length: 1
            Compression Methods (1 method)
                Compression Method: null (0)
            Extensions Length: 172
            Extension: ...
```

`<- Retry+Token` では、サーバ側が使って欲しい宛先コネクションID (Source Connection ID) とトークン (Retry Token) を含めて送信しています。

```output
Internet Protocol Version 4, Src: 127.0.0.1, Dst: 127.0.0.1
User Datagram Protocol, Src Port: 4433, Dst Port: 62492
QUIC IETF
    QUIC Connection information
    [Packet Length: 93]
    1... .... = Header Form: Long Header (1)
    ..11 .... = Packet Type: Retry (3)
    Version: 1 (0x00000001)
    Destination Connection ID Length: 20
    Destination Connection ID: c6b336557f9128bef8a099a10d320c26e9c8d1ab
    Source Connection ID Length: 20
    Source Connection ID: 838543a9c2a56ca7739881ac3207f467c011605f  <== サーバ側が使って欲しい宛先コネクションID
    Retry Token: 7175696368657f0000011a26dc5bd9625e2bcd0efd3a329ce83136a32295  <== トークン
    Retry Integrity Tag: 2dad6cd2e1f7d8ef5db88b6d05a410b5 [verified]
```

`Initial+Token[1]: CRYPTO[CH] ->` では受信したサーバの送信元コネクションIDを宛先コネクションID (Destination Connection ID) に格納し、受信したRetry Tokenをトークン (Token) に格納して再送信します。
ペイロードの中身は1回目と同じです。

```output
Internet Protocol Version 4, Src: 127.0.0.1, Dst: 127.0.0.1
User Datagram Protocol, Src Port: 60214, Dst Port: 4433
QUIC IETF
    QUIC Connection information
    [Packet Length: 1231]
    1... .... = Header Form: Long Header (1)
    .1.. .... = Fixed Bit: True
    ..00 .... = Packet Type: Initial (0)
    .... 00.. = Reserved: 0
    .... ..11 = Packet Number Length: 4 bytes (3)
    Version: 1 (0x00000001)
    Destination Connection ID Length: 20
    Destination Connection ID: 838543a9c2a56ca7739881ac3207f467c011605f  <== Retryの送信元コネクションID
    Source Connection ID Length: 20
    Source Connection ID: c6b336557f9128bef8a099a10d320c26e9c8d1ab
    Token Length: 30
    Token: 7175696368657f0000011a26dc5bd9625e2bcd0efd3a329ce83136a32295  <== 受信したトークンをそのまま返す
    Length: 1151
    Packet Number: 2
    Payload: 211a5a3ffb783e987cfc3cd0236d16c5aa7adb31dc1b2e133440dcacfa4806eef4515988…
    TLSv1.3 Record Layer: Handshake Protocol: Client Hello
        Frame Type: CRYPTO (0x0000000000000006)
        Offset: 0
        Length: 219
        Crypto Data
        Handshake Protocol: Client Hello
            Handshake Type: Client Hello (1)
            Length: 215
            Version: TLS 1.2 (0x0303)
            Random: 1f9acee37511743216e45c31f1ad8671dadd77162d3bb3f8a7a069b440dccb0e  <== 1回目の送信と同じ値
            Session ID Length: 0
            Cipher Suites Length: 2
            Cipher Suites (1 suite)
                Cipher Suite: TLS_AES_128_GCM_SHA256 (0x1301)
            Compression Methods Length: 1
            Compression Methods (1 method)
                Compression Method: null (0)
            Extensions Length: 172
            Extension: ...
```

以上です。

#### 参考文献

- [n月刊ラムダノート Vol.2, No.1(2020) – 技術書出版と販売のラムダノート: #1 パケットの設計から見るQUIC（西田佳史）](https://www.lambdanote.com/collections/frontpage/products/nmonthly-vol-2-no-1-2020)
- [RFC 9000: QUIC: A UDP-Based Multiplexed and Secure Transport](https://www.rfc-editor.org/rfc/rfc9000)
