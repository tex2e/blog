# javascript

Parent: [All Categories](../index.md)

## Articles (19)

- [[JavaScript] Uint8ArrayをHex形式（16進数）に変換する](./2025-08-10-convert-uint8array-to-hex.md) (`How-To | stable | stale_after: 2028-08-10`) — JavaScriptでUint8Arrayのバイト列をtoString(16)とpadStartを用いてHex形式の16進数文字列に変換する関数の実装方法。
- [[JavaScript] Uint8ArrayとBase64形式の相互変換](./2025-08-10-convert-uint8array-to-base64.md) (`How-To | stable | stale_after: 2028-08-10`) — JavaScriptのbtoaとatobを利用してUint8ArrayのバイナリデータとBase64形式の文字列を相互変換する関数の実装方法。
- [[JavaScript] アクセス元の国によってGoogle Analyticsを制限する](./2022-03-06-GDPR-and-google-analytics.md) (`How-To | stable | stale_after: 2025-07-21`) — GDPR対応としてGoogle Analyticsのgtag.jsのconsentコマンドを使いEU域内アクセス時のCookie利用を制限する設定方法。
- [[JavaScript] WebページにPWA (Progressive Web Apps) を導入する](./2021-09-03-PWA.md) (`How-To | stable | stale_after: 2025-07-21`) — 既存の静的Webサイトにmanifest.jsonやアイコン画像、ServiceWorker用スクリプトを追加してPWA化する手順を解説。
- [[Vue] Vue.jsを初めて使う人のための入門](./2021-03-13-vue-js-tutorial.md) (`How-To | stable | stale_after: 2025-07-21`) — Vue.jsの基本的な使い方としてデータ展開やv-bind・v-model・v-on・v-if・v-for・computedなどの主要ディレクティブを解説。
- [[JavaScript] WebAssemblyでAES暗号 (+CryptoJSと実行速度比較)](./2020-08-10-webassembly-aes-encrypt.md) (`How-To | stable | stale_after: 2025-07-21`) — C言語で実装したAES暗号化処理をEmscriptenでWebAssembly化してブラウザから呼び出しCryptoJSと速度比較した記録。
- [[JavaScript] WebAssemblyで32bit整数配列をC言語で処理する](./2020-08-09-webassembly-int32array.md) (`How-To | stable | stale_after: 2025-07-21`) — Emscriptenの導入からC言語の配列演算関数をWebAssemblyへコンパイルしJavaScriptのInt32Arrayで連携する手順。
- [[ブラウザ] Markdown/HTML用のリンクを生成するブックマークレット](./2020-03-05-bookmarklet-for-links.md) (`How-To | stable | stale_after: 2025-10-14`) — 閲覧中ページのタイトルとURLからMarkdown・HTML・テキスト形式のリンクを生成してコピーするブックマークレットの作成手順。
- [[JavaScript] Webページでコマンド例の「$」の部分をコピペさせない](./2019-07-02-command-prompt-user-select-none.md) (`How-To | stable | stale_after: 2025-07-21`) — CSSのuser-select: noneやPrism.jsのトークン定義を使ってWeb上のコマンド例からプロンプト記号のコピーを防ぐ方法。
- [[Node] npmをsudo権限なしでインストールする](./2017-04-26-npm-install-without-sudo.md) (`How-To | stable | stale_after: 2025-07-21`) — macOSやLinux環境でsudo権限を使わずにnpmパッケージをグローバルインストールするためのディレクトリ設定とPATH設定手順。
- [[JavaScript] オブジェクト指向プログラミング](./2016-12-03-OOP-in-JavaScript.md) (`Reference | stable | stale_after: 2027-07-21`) — JavaScriptにおけるES5・ES6・ES7世代別のクラス定義やコンストラクタ、継承、アクセス制御の書き方まとめ。
- [[JavaScript] テンプレートエンジンを使わないで、コードの埋め込みを行う](./2016-09-25-html-template-and-binding.md) (`How-To | stable | stale_after: 2027-07-21`) — テンプレートエンジンを使わずにJavaScriptのテンプレートリテラルやreplace・bind・evalで変数埋め込みを行う方法。
- [[JavaScript] node.js の EventEmitter をブラウザでも使う](./2016-09-25-EventEmitter-for-browser.md) (`How-To | stable | stale_after: 2025-07-21`) — browserifyとuglifyjsを用いてNode.js標準のEventEmitterをブラウザで利用可能なJSファイルとして切り出す手順。
- [[JavaScript] HTTPで渡されたGETパラメータを取得する方法](./2016-09-23-extract-http-get-param-by-name.md) (`How-To | stable | stale_after: 2027-07-21`) — JavaScriptで正規表現とdecodeURIComponentを用いてURLのHTTP GETクエリパラメータを名前指定で取得する関数の実装法。
- [[JavaScript] sleep関数の作り方](./2016-06-16-sleep-func.md) (`How-To | stable | stale_after: 2027-07-21`) — JavaScriptのPromiseとsetTimeoutを組み合わせて非同期待機を行うsleep関数を実装し利用する方法を解説。
- [[JavaScript] 難読化プログラムの作り方](./2016-05-22-obfuscation.md) (`Concept | stable | stale_after: 2027-07-21`) — CTF問題の解析をもとにマルチバイト変数名やカンマ演算子、Functionコンストラクタを用いたJavaScript難読化の仕組みを解説。
- [[JavaScript] 整数の乱数を取得する方法](./2016-05-04-random-int.md) (`How-To | stable | stale_after: 2027-07-21`) — JavaScriptのMath.randomとMath.floorを組み合わせて任意の範囲の整数乱数を生成する関数の書き方を解説。
- [[JavaScript] ヒアドキュメントのインデントを取り除く関数の作り方](./2016-04-30-dedent.md) (`How-To | stable | stale_after: 2027-07-21`) — JavaScriptのテンプレートリテラルで記述した複数行文字列から共通の先頭インデントを除去するdedent関数の実装方法。
- [[JavaScript] Rubyの .times .upto .downto メソッドを作る](./2016-04-03-add-method-to-standard-class.md) (`How-To | stable | stale_after: 2027-07-21`) — JavaScriptのNumber.prototypeを拡張してRubyのtimes・upto・downto相当の繰り返しメソッドを実装する方法。
