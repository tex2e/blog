---
layout:        post
title:         "[PHP] php.iniで危険な関数を無効化する"
date:          2021-05-26
category:      Programming
cover:         /assets/cover14.jpg
redirect_from:
    - /php/set-disable-functions
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

PHPのバックドアやリバースシェルで使われる関数を無効化することで、攻撃を防ぐことが可能になります。
設定方法は php.ini に以下の内容を追加します。

```
disable_functions = phpinfo,eval,exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source
```

php.ini の場所がわからない場合は、`find /etc -name 'php.ini' -type f` で探してみてください。

以下、各種危険な関数の説明です。

- phpinfo : 現在のPHPの状態を表示する。バージョンとか色々見えてしまうので良くない
- eval : 文字列を評価する。普通は使わない。任意コード実行でよく使う
- exec : 外部コマンドの実行。リバースシェルでよく使う
- passthru : 外部コマンドの実行。リバースシェルでよく使う
- shell_exec : 外部コマンドの実行。リバースシェルでよく使う
- system : 外部コマンドの実行。リバースシェルでよく使う
- proc_open : 外部コマンドの実行（コマンドを実行してプロセスへのパイプを開く）
- popen : 外部コマンドの実行（コマンドを実行してプロセスへのパイプを開く）
- curl_exec : HTTPリクエストを送信する
- curl_multi_exec : HTTPリクエストを並列で送信する
- parse_ini_file : 設定ファイルを解析する。ファイル内容の表示に利用される
- show_source : ソースコードを表示する。普通は使わない。

### おまけ

その他、php.iniに書いておくとよいセキュリティ項目です。

```
// HTTPヘッダーに追加されるX-Powered By :PHP/5.3.0 を非表示にする
expose_php = Off

// アップロード機能使わないのであればOff
file_uploads = Off

// PHP5.2.0以降ではRFIはデフォルトで禁止されている
allow_url_include = Off

// 指定したディレクトリ以下にしかアクセスできないように制限する。
// ディレクトリトラバーサルに対して有効
open_basedir = /var/www/html/
```

以上です。

### 参考文献
- [Linux 25 PHP Security Best Practices For Sys Admins - nixCraft](https://www.cyberciti.biz/tips/php-security-best-practices-tutorial.html)
