---
layout:        post
title:         "RFC1149 伝書鳩によるIPパケットの送信規格"
date:          2022-08-01
category:      Protocol
cover:         /assets/cover14.jpg
redirect_from: /rfc/rfc1149-ip-over-avian-carriers
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

RFC 1149 (エイプリルフールRFC) の紹介です。

### 伝書鳩によるIPパケットの送信規格
**(A Standard for the Transmission of IP Datagrams on Avian Carriers)**

発行日：1990/4/1

### 概要と理論

- 伝書鳩は、高遅延、低スループット、低高度のサービスを提供できます。
- 多くの伝書鳩は、**繁殖時期の春先以外は互いに干渉しません**（cf. 無線通信における電波干渉）。
- 伝書鳩は、**本能的に通信データの衝突回避システムを持つ**ため、可用性が向上します (cf. CSMA/CA)。
- ラジオなどの無線通信技術とは異なり、遮蔽物を迂回して通信することが可能です。

### フレーム形式

- IPパケットは小さな巻物に16進数で印刷されます。
- 巻物は、伝書鳩の片足に巻き付けます。
- 帯域幅は、伝書鳩の足の長さによって制限されます。
- MTU (最大転送単位) は伝書鳩の年齢とともに増加します。一般的には 256 ミリグラムです（通信データ量ではなく巻物の重さ。若鳥よりも成鳥の方が多く運べるため）
- 受信者は、印刷されたIPパケットをスキャンして電子転送できるようにします。

### 議論

- 伝書鳩には**ワームを自動で検知して除去する機能**が組み込まれています (マルウェア / 虫)。
- IPパケットの送信はベストエフォートのため、伝書鳩が損失する可能性があります。
- ブロードキャストは定義されていないが、嵐によってデータが損失する可能性があります (ブロードキャストストーム)。
- 伝書鳩が疲れて着地するまで、永続的に送信を再試行します。
- 監査証跡は自動で生成され、丸太やケーブルトレイに残されています（動物が残した跡 ~= 糞）

### セキュリティ上の考慮事項

- 戦術的な環境で使用される場合は、データ暗号化などの対策が必要です。

以上です。


### 参考文献

- [RFC 1149 - Standard for the transmission of IP datagrams on avian carriers](https://datatracker.ietf.org/doc/html/rfc1149)
