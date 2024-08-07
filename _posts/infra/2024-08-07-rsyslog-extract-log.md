---
layout:        post
title:         "[rsyslog] 条件に一致するログメッセージを抽出する"
date:          2024-08-07
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

ここでは、rsyslogにおいて条件に一致するログメッセージを抽出する方法について説明します。

### ファシリティとは

ファシリティ (Facility) とは、ログメッセージの種類を表します。
代表的なものには以下のファシリティがあります。

- kern : カーネルのメッセージ
- user : 任意のユーザプロセスのメッセージ
- daemon : デーモンプログラムのメッセージ
- auth, authpriv : 認証メッセージ
- cron : cronやatなどのクロックデーモンのメッセージ
- local0〜local7 : 任意の用途で利用可能

### シビアリティとは

シビアリティ (Severity) とは、ログの重要度を表します。
代表的なものには以下のファシリティがあります。

- emerge : システムが利用できない緊急事態
- alert : 迅速に対応が必要
- err : エラーメッセージ（システムは動作続行できるが処理が正しく成功しなかった）
- warn : 警告メッセージ（処理は完了したが望ましい状態ではない）
- notice : 通知メッセージ（通常の範囲内だけど気になる状態）
- info : 情報メッセージ（正常動作のログ）
- debug : デバッグ用のメッセージ（デバッグ用の詳細ログ）

### ファシリティとシビアリティの両方で抽出する (.)

ファシリティとシビアリティの両方と一致するログを抽出することができます。
例えば、ファシリティがauthpriv、シビアリティがinfoと一致するログを /var/log/secure に出力するには、以下のように書きます。

```conf
authpriv.info    /var/log/secure
```

### 複数のセレクタで抽出する (;)

複数のセレクタを同時に指定するときは「; (セミコロン)」を使います。ルールが長くなるときは「\\ (バックスラッシュ)」で行継続させることもできます。

```conf
daemon.*;\
mail.*;    /dev/tty8
```

### 複数のファシリティで抽出する (,)

複数のファシリティを同時に指定するときは「, (カンマ)」を使います。
例えば、daemon.\* と mail.\* のルールをカンマを使ってまとめて書くと、次のようになります。

```conf
daemon,mail.*;    /dev/tty8
```

### 特定のシビアリティで抽出する (.=)

特定のシビアリティのログだけを抽出した場合は、「ファシリティ名.=シビアリティ名」を使います。
例えば、シビアリティがdebugのログを抽出するときは次のように書きます。

```conf
*.=debug    /var/log/debug.log
```

### 特定のシビアリティを除外する (.!=)

特定のシビアリティのログを除外するには、「ファシリティ名.!=シビアリティ名」を使います。
例えば、メールに関するログを抽出したいけど、シビアリティがinfoのログは除外したいときは次のように書きます。

```conf
mail.*;mail.!=info    /var/log/maillog
```

### 特定のファシリティを除外する (.none)

特定のファシリティのログを除外するには、「ファシリティ名.none」を使います。
例えば、全てのファシリティのシビアリティinfoのログを抽出したいけど、ファシリティがmailだけは除外したい時は次のように書きます。

```conf
*.=info;mail.none          /var/log/mycustom.log
```

### ホスト名で抽出する/除外する (+/-)

rsyslogでは、互換性のためにBSD-style行ブロックをサポートしており、これを使うことでログメッセージを出力したサーバのホスト名ごとにログを振り分けることができます。
特定のホストからのログだけを抽出するときは「+ホスト名」を使います。

```conf
+server01.example.com
mail.*                     /var/log/mail/server01.log

+server02.example.com
mail.*                     /var/log/mail/server02.log
```

逆に、特定のホストを除外するときは「-ホスト名」を使います。

```conf
+server03.example.com
mail.*                     /var/log/mail/all_without_server03.log
```

### プログラム名で抽出する/除外する (!/-)

rsyslogでは、互換性のためにBSD-style行ブロックをサポートしており、これを使うことでログメッセージを出力したプログラム名ごとにログを振り分けることができます。
特定のプログラムからのログだけを抽出するには「!プログラム名」を使います。

```conf
!named
*.*     /var/log/named.log
```

逆に、特定のプログラムからのログを除外するときは「-プログラム名」を使います。

```conf
-named
*.*     /var/log/messages
```

### プロパティベースフィルタで抽出する (:property)

syslogには、プロパティと呼ばれるログメッセージの内容 (msg)、プログラム名 (programname) やホスト名 (hostname) などを持っている変数が存在します。
以下のように書くことで、プロパティに対して条件を満たすログを抽出することができます。

```conf
:msg, contains, "error"        /var/log/error.log
:msg, regex, "not found .*"    /var/log/error.log
```

プロパティとしてよく使われる代表的なものには以下があります。

- `%msg%` : SyslogデータのMSG内容（メッセージ）
- `%hostname%` : SyslogデータのHEADERに記載されているホスト名
- `%fromhost%` : Syslogデータの受信側がDNSを使って記録したホスト名
- `%syslogtag%` : SyslogデータのMSGのTAGフィールドの内容
- `%programname%` : SyslogデータのMSGのTAGフィールドに含まれているプログラム名（例：TAGが「docker-service[1022]」のとき、プログラム名は「docker-service」）

また、プロパティベースフィルタで使える比較条件には以下があります。

- `contains` : プロパティに指定した値が含まれているか比較する
- `isequal` : プロパティと値が一致するか比較する
- `startswith` : プロパティが指定した値で始まるか比較する
- `regex` : プロパティと値を基本正規表現（POSIX BRE）で比較する
- `ereregex` : プロパティと値を拡張正規表現（POSIX ERE）で比較する

### 式ベースフィルタで抽出する (if〜then)

プロパティベースフィルタでは複雑な条件を組み合わせることができません。
そこで、if文による式ベースフィルタを使うことで、複雑な式を組み立てることができます。

```conf
if $syslogfacility-text == 'local0' and $programname == 'sample' then {
  /var/log/sample/messages
}
```

条件には and や or、否定の not の論理演算子の他に、contains や startswith などの文字列比較演算子も使うことができます。
また、大文字小文字のどちらにもマッチする contains_i や startswith も用意されています。

```conf
if $syslogfacility-text == 'local0' and $msg startswith 'DEVNAME' and \
    not ($msg contains 'error1' or $msg contains 'error0') then {
        /var/log/somelog
}
```

ただし、式ベースフィルタでは正規表現による抽出はサポートされていません。そのため、if文の中で regex や ereregex を使うことはできません。

以上です。

### 参考資料

- [Filter Conditions — Rsyslog documentation](https://www.rsyslog.com/doc/configuration/filters.html)
