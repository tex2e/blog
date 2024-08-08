---
layout:        post
title:         "[rsyslog] ifやテンプレートで使えるプロパティの一覧"
date:          2024-08-10
category:      Protocol
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ここでは、rsyslogのテンプレートやif文の式ベースフィルタなどで使用できるプロパティの一覧について説明します。

rsyslog におけるデータ項目は「プロパティ」と呼ばれています。
以下では、メッセージの内容を取得するプロパティ（メッセージプロパティ）、システムの設定値を取得するプロパティ（システムプロパティ）、現在日時を取得するプロパティの使い方について説明します。

## メッセージプロパティ

メッセージプロパティは、Syslogデータの内容を取得するためのプロパティです。

- **msg** :
    - SyslogデータのMSGパート
- **rawmsg** :
    - Syslogデータの全パートのそのままのメッセージ。動作確認時のデバッグなどの利用される
- **rawmsg-after-pri** :
    - rawmsgからSyslogデータのPRIパート（例：\<191>）を取り除いた内容
- **hostname** :
    - SyslogデータのHEADERパートの中に含まれているHOSTNAMEの値
- **source** :
    - hostnameと同じ値
- **fromhost** :
    - Syslogデータの受信側がDNSを使って記録したメッセージ送信元のホスト名（中継されたときは中継サーバのホスト名）
- **fromhost-ip** :
    - Syslogデータの受信側が記録したメッセージ送信元のIPアドレス。ローカルで生成されたメッセージのときは 127.0.0.1 が固定で設定される
- **syslogtag** :
    - SyslogデータのMSGパートの中に含まれているTAGの値 (RFC 3164 参照)
- **programname** :
    - SyslogデータのMSGパートの中に含まれているTAGからプログラム名だけを取り出した値（例：syslogtagが「named[12345]」であれば、programnameは「named」となる）
    - 正確には、TAGの値から「:」「\[」「/」の記号などが現れる直前までの文字列を切り取っているだけです。そのため、syslogtagが「app/foo[1234]」だと、programnameは「app」になってしまいます。
- **pri** :
    - SyslogデータのPRIパート（整数値）
- **pri-text** :
    - priの内容を「ファシリティ.シビアリティ」のテキストに変換した値
- **iut** :
    - MonitorWare (Windowsで動作するSyslogサーバ) のインフォメーションユニットタイプ
- **syslogfacility** :
    - Syslogデータのファシリティ（整数値）
- **syslogfacility-text** :
    - Syslogデータのファシリティ（テキスト）
- **syslogseverity** :
    - Syslogデータのシビアリティ（整数値）
- **syslogseverity-text** :
    - Syslogデータのシビアリティ（テキスト）
- **syslogpriority** :
    - syslogseverityと同じ値（歴史的な理由で残されている。使用は非推奨）
- **syslogpriority-text** :
    - syslogseverity-textと同じ値（歴史的な理由で残されている。使用は非推奨）
- **timegenerated** :
    - rsyslogデーモンがログを受け取った日時（RFC 3164 形式）
- **timereported** :
    - SyslogデータのHEADERパートの中に含まれているTIMESTAMPフィールドの日時
- **timestamp** :
    - timereportedと同じ値
- **protocol-version** :
    - SyslogデータのHEADERパートに含まれるVERSIONの値（RFC 5424 参照）
- **structured-data** :
    - SyslogデータのHEADERパートに含まれるSTRUCTURED-DATAの値（RFC 5424 参照）
- **app-name** :
    - SyslogデータのHEADERパートに含まれるAPP-NAMEの値（RFC 5424 参照）
- **procid** :
    - SyslogデータのHEADERパートに含まれるPROCIDの値（RFC 5424 参照）
- **msgid** :
    - SyslogデータのHEADERパートに含まれるMSGIDの値（RFC 5424 参照）
- **inputname** :
    - "imuxsock" や "imudp" などのメッセージを生成したrsyslogの拡張モジュール名。未使用のときは空文字

## システムプロパティ

システムプロパティは、システムの設定値を取得するためのプロパティです。

- **$bom** :
    - BOM文字。RFC5424に対応したログ形式を出力するときのテンプレートに使用するためのプロパティ
- **$myhostname** :
    - 現在のメッセージを受信したホスト名

## 時間に関するプロパティ

Time-Related System Propertiesは、現在日時を取得するためのプロパティです。

- **$now** :
    - 現在の日付（YYYY-MM-DD形式）
- **$year** :
    - 現在の年 (4桁)
- **$month** :
    - 現在の月（2桁）
- **$day** :
    - 現在の日（2桁）
- **$wday** :
    - gmtime()関数で取得できる現在の曜日（例：日曜日は0, 月曜日は1, …, 土曜日は6）
- **$hour** :
    - 現在の時（24時間表記、2桁）
- **$minute** :
    - 現在の分（2桁）
- **$hhour** :
    - 現在の分を30分単位で表記（00〜29分は0、30〜59分は1）
- **$qhour** :
    - 現在の分を15分単位で表記（00〜14分は0、15〜29分は1、30〜44分は2、45〜59分は3）

以上です。

### 参考資料

- [rsyslog Properties — Rsyslog documentation](https://www.rsyslog.com/doc/configuration/properties.html)
