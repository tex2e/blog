---
layout:        post
title:         "rsyslog.conf の構成"
date:          2024-08-06
category:      Infrastructure
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ここでは、rsyslogの設定の基本となる rsyslog.conf ファイルの構成について説明します。

rsyslog.conf は主に3つの部分から構成されています。

- グローバル設定
- テンプレート
- ルール

### 1. グローバル設定

グローバル設定では、拡張モジュールの読み込み (\$ModLoad) やログファイルの権限 (\$FileGroup, \$FileOwner) などの rsyslog の動作全般に関する設定を行います。
「\$」から始まる行は、rsyslogの動作全般に関する設定になります。
これらの設定を英語では、グローバルディレクティブ (Global Directives) と呼ばれています。
グローバル設定は、例えば、以下のように記述することができます。

```conf
# モジュールの読み込み
$ModLoad imjournal
# 設定ファイルの読み込み
$IncludeConfig /etc/rsyslog.d/*.conf
```

### 2. テンプレート

テンプレートでは、ログファイルの出力先や、ログメッセージのフォーマットを定義します。
テンプレートの定義は \$template を使用します。

```
$template tpl3,"%TIMESTAMP:::date-rfc3339% %HOSTNAME% %syslogtag%%msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%\n"
```

テンプレートの中で使用できる変数（プロパティ）として代表的なものには、以下があります。

- `%msg%` : SyslogデータのMSG内容（メッセージ）
- `%hostname%` : SyslogデータのHEADERに記載されているホスト名
- `%fromhost%` : Syslogデータの受信側がDNSを使って記録したホスト名
- `%syslogtag%` : SyslogデータのMSGのTAGフィールドの内容
- `%programname%` : SyslogデータのMSGのTAGフィールドに含まれているプログラム名（例：TAGが「docker-service[1022]」のとき、プログラム名は「docker-service」）

また、プロパティを使用するときはオプションも指定することができます。
プロパティにオプションを指定するときは以下の形式で指定します。

```
%プロパティ名:範囲開始:範囲終了:オプション%
```

例えば、drop-last-lf オプションは、Syslogデータの末尾にある改行文字（LF）を取り除きます。
使い方は `%msg:::drop-last-lf%` のように書きます。

### 3. ルール

ルールでは、対象とするログメッセージを指定し、保存方法や出力方法を設定します。
ログメッセージの指定には、セレクタ形式のほか、正規表現やif文を使うこともできます。
つまり、rsyslogでは処理対象とするメッセージを指定するフィルタには、次の3種類が存在します。

- 従来のsyslogと互換性のあるセレクタによるフィルタ
- メッセージのプロパティを対象としたフィルタ
- if〜then式を使ったフィルタ

セレクタなどでメッセージを抽出した後には、必ずアクションを指定します。

以下はルールの書き方の一例です。

```conf
# セレクタで一致するSyslogデータを指定ファイルに書き込む
auth,authpriv.*     /var/log/auth.log

# 正規表現で一致するSyslogデータを指定ファイルに書き込む
:msg, regex, "fatal .* error"     /var/log/myerror.log

# SyslogデータのMSGが特定の文字列のとき、指定したコマンドを実行する
:msg, startswith, "command-poweroff"     ^poweroff

# if文で条件に一致するSyslogデータを指定ファイルに書き込む
if $syslogfacility-text == 'daemon' and $programname contains 'docker-' then {
  /var/log/logfile
}
```

以上です。

### 参考資料

- [Welcome to Rsyslog — Rsyslog documentation](https://www.rsyslog.com/doc/index.html)
