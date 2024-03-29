---
layout:        post
title:         "draft-ietf-quic-invariants の概要"
date:          2019-11-08
category:      Protocol
author:        tex2e
cover:         /assets/cover5.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

[Version-Independent Properties of QUIC](https://www.rfc-editor.org/rfc/rfc8999.html) を読んで要点だけをまとめた自分用の資料です。
読んでいる時点では draft-07 です。


## Version-Independent Properties of QUIC

バージョンに依存しないQUICの特性

### 概要

- この文書では新しいバージョンになっても変わらないQUICの特性について定義する

### 1. はじめに

- QUICは安全な通信路の提供、接続の多重化、バージョン交渉ができる
- IPのバージョン(IPv4, IPv6)に依存しないプロトコル

### 3. QUICの簡単な概要

- QUICは2点間の通信プロトコルで、UDPで通信する
- UDPデータグラムの中にQUICパケットが含まれる
- QUICパケットを用いてQUICコネクションを確立する

### 4. QUICパケットのヘッダ

- QUICは2種類のヘッダ（**長いヘッダ** と **短いヘッダ**）があり、最上位ビットで識別する
- 長いヘッダのときは最上位ビットが1
- 短いヘッダのときは最上位ビットが0
- QUICパケットの長さは定まっていない

#### 4.1. 長いヘッダ (Long Header)

```fig
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+
|1|X X X X X X X|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Version (32)                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
| DCID Len (8)  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|               Destination Connection ID (0..2040)           ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
| SCID Len (8)  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                 Source Connection ID (0..2040)              ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X  ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

図1: QUIC Long Header

- 最上位ビットは 1
- バージョンによって異なる部分は `X`
- 4バイトのVersion (QUICのバージョン)
- 可変長のDCID (接続先ID) ... 先頭の1バイトはDCID長を表す
- 可変長のSCID (接続元ID) ... 先頭の1バイトはSCID長を表す
- 残りの `X` の部分はバージョンによって異なる内容が格納される

#### 4.2. 短いヘッダ (Short Header)

```fig
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+
|0|X X X X X X X|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                 Destination Connection ID (*)               ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X  ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

図2: QUIC Short Header

- 最上位ビットは 0
- バージョンによって異なる部分は `X`
- DCID (接続先ID) ... DCID長はパケット内で指定されない
- 短いヘッダには、DCID長、SCIDやVersionが含まれない

#### 4.3. 接続ID (Connection ID)

- 接続IDは任意長のopaque（色々なデータが格納される）フィールドで表される
- 下位プロトコルレイヤ(UDP, IPなど)のアドレス変更によって、間違った相手に送信されないようにするために、接続IDを使う
- 接続IDはエンドポイントと仲介者(プロキシサーバか何かを想定している?)によって使用される
- エンドポイントでは、接続IDによってパケットが対象とするQUIC接続を識別する
- 接続IDはバージョン固有の方法によって選ばれる
- 同じQUIC接続で流れるパケットは、異なる接続IDを持つ

#### 4.4. バージョン (Version)

- QUICバージョンは32ビットのネットワークバイトオーダ (ビッグエンディアン)
- バージョン0はバージョン交渉時に使用する


### 5. バージョン交渉 (Version Negotiation)

- 長いヘッダや理解不能なパケットを受信したときは、バージョン交渉パケットで応答する
- 短いヘッダを受信した場合は、バージョン交渉はしない
- バージョン交渉パケットのVersionは0に設定する

```fig
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+
|1|X X X X X X X|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Version (32) = 0                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
| DCID Len (8)  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|               Destination Connection ID (0..2040)           ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
| SCID Len (8)  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                 Source Connection ID (0..2040)              ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Supported Version 1 (32)                   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                   [Supported Version 2 (32)]                  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
                              ...
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                   [Supported Version N (32)]                  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

図3: Version Negotiation Packet

- バージョン交渉パケットには、対応しているバージョンのリストのみが含まれる
- 機密性や完全性を保証しない
- 特定のQUICバージョンでは、接続確立プロセスでパケットを認証する場合がある
- エンドポイントが返信するときは、受信したパケットの接続元IDを、パケットの接続先IDにする
- 接続元IDはランダム
- 両者が接続IDをエコーすることで、Off-Path攻撃を防ぐ
- エンドポイントが受信したバージョン交渉パケットによって、バージョンが変更される
- エンドポイントがQUICバージョンを変更する条件は、バージョンによって異なる
- QUICバージョン1のバージョン交渉パケットの詳細は[QUIC-TRANSPORT](https://tools.ietf.org/html/draft-ietf-quic-transport)を参照


### 6. セキュリティとプライバシの考慮事項

- 全てのQUICパケットにQUICバージョンが含まれるわけではない
- この文書ではバージョン交渉パケットの完全性が保護されていないので、Off-Path攻撃に対して弱い
- QUICではバージョン交渉に含まれる値を認証するメカニズムを定義しなければならない


### 付録A. 間違った仮定

- QUICバージョン1では盗聴への対策はないが、今後のバージョンで変更される
- 以下の条件は全てのQUICバージョンで真であるとは限らない：
  - TLSを使用すること
  - 長いヘッダは接続の確立時のみに使用すること
  - 全ての通信フローに、接続確立フェーズが含まれること
  - 通信フローの最初では、長いヘッダを使用すること
  - ACKフレームのみを含むパケットの確認応答を禁止すること
  - AEADを使用して、パケットの完全性を保護すること
  - パケットのVersionフィールドの後にパケット番号が現れること
  - 送信するパケットごとに、1つずつパケット番号を増やすこと
  - クライアントが送信した最初のハンドシェイクパケットには、最小サイズがあること
  - ハンドシェイクはクライアントから開始すること
  - バージョン交渉パケットはサーバからのみ送信すること
  - 接続IDは滅多に変わらないこと
  - バージョン交渉パケットを送信したとき、エンドポイントはQUICバージョンを変更すること
  - 長いヘッダに含まれるVersionフィールドは両者が同じであること
  - エンドポイントのペア間は、一度に一つの接続のみが確立されること
