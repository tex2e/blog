---
layout:        post
title:         "[PowerShell] 自動変数の使い方"
date:          2022-04-09
category:      PowerShell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

PowerShellの自動変数（自動的に定義される変数）について説明します。
なお、以下では変数名に大文字小文字が混在して統一されていませんが、PowerShellでは変数名は大文字小文字を区別しないので、大文字・小文字どちらで書いても同じ変数にアクセスすることができます。

- **$$** : シェルが受け取った最後の行にある最後のトークン (Bashと同じ動き)
- **$?** : 最後のコマンドの実行状態 (Bashと同じ動き)
- **$^** : シェルが受け取った最後の行にある最初のトークン
- **$_** : スクリプトブロックで使用している現在のパイプラインオブジェクト
  ```ps1
  1..5 | foreach { $_ * 2 }
  ```
- **$args** : スクリプト、関数、スクリプトブロックに渡されるパラメータの配列
  ```ps1
  function sample() {
    $val1 = $args[0]
    $val2 = $args[1]
  }
  sample 123 456
  ```
- **$Error** : シェル内で発生したエラーを保持する配列
- **$ErrorActionPreference** : エラーの制御をする設定。設定できる値は SilentlyContinue, Continue, Inquire, Stop の4つ。エラーが発生したらスクリプトを停止する場合は、以下のように設定します。
  ```ps1
  $ErrorActionPreference = "Stop"
  ```
- **$false** : ブール値のFalseを表す変数
- **$home** : ユーザーのホームディレクトリの絶対パス
  ```ps1
  PS> $home
  C:\Users\username
  ```
- **$input** : スクリプトブロックで使用されている現在の入力パイプライン
  ```ps1
  PS> echo Hello | & { echo "$input world!" }
  Hello world!
  ```
- **$matches** : -match 演算子の括弧にマッチした部分の文字列を保持する配列
  ```ps1
  PS> "Hello world!" -match "(\w+) (\w+)"
  PS> $matches[1]
  Hello
  PS> $matches[2]
  world
  ```
- $MyInvocation : 実行されたスクリプト、関数、スクリプトブロックのコンテキストに関する情報
- $NestedPromptLevel : 現在のプロンプトの入れ子のレベル
- **$null** : Nullを表す変数
- **$outputEncoding** : パイプラインデータを外部プロセスに送信する際に使用する文字エンコード
- $pid : 現在のPowerShellインスタンスのプロセスID
- **$profile** : 現在のPowerShellプロファイルのパス
- $pshome : PowerShell のインストールディレクトリのフルパス
- **$pwd** : カレントディレクトリ
- **$stackTrace** : 最後のエラーの詳細なスタックトレース情報
- **$this** : オブジェクト指向のクラス定義で自分自身を参照するための変数
- **$true** : ブール値のTrueを表す変数

以上です。

### 参考文献
- [自動変数について - PowerShell \| Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.2)
