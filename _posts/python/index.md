# python

Parent: [All Categories](../index.md)

## Articles (30)

- [[Python] Irodori-TTSの音声生成速度とGPU](./2026-09-27-irodori-tts.md) (`How-To | stable | stale_after: 2027-09-27`) — 日本語音声合成モデルIrodori-TTSの導入手順とCPU・MPS・RTX 3060の合成速度比較、参照音声による声の統一方法を解説。
- [[Python] LarkでMS-DOSコマンドの構文解析](./2025-11-22-msdoc-cmd-parser.md) (`Concept | stable | stale_after: 2027-01-13`) — PythonのパーサーライブラリLarkとEBNF文法定義grammar.larkを使い、MS-DOSコマンドを構文解析してASTを得る設計解説。
- [[Python] argparseで引数名とプロパティ名を別名にする方法](./2025-09-22-argparse-add-argument-dest.md) (`How-To | stable | stale_after: 2028-09-23`) — Pythonのargparse.add_argumentでdest引数を指定し、コマンドライン引数名とNamespace上のプロパティ名を別名にする方法。
- [[Python] サロゲートペアのバイト列を文字列に変換する方法](./2024-10-29-surrogate-pair.md) (`How-To | stable | stale_after: 2027-10-29`) — PythonでUTF-16のサロゲートペアを含む文字列やバイト列をencodeのsurrogatepass指定やdecodeで文字変換する方法。
- [[Python] UTF8またはShiftJISでエンコードされたファイルの読み込み](./2024-06-21-read-file-sjis-or-utf8.md) (`How-To | stable | stale_after: 2027-06-22`) — UTF-8とShift-JISが混在するファイルをPythonで開く際に、UnicodeDecodeErrorの捕捉で文字コードを判別し読み込む方法。
- [[Python] openpyxlを使ってExcelファイルを読み込む](./2024-06-04-read-excel-file.md) (`How-To | stable | stale_after: 2025-08-07`) — PythonのopenpyxlライブラリでExcelファイルを読み込み、シートや行列番号・coordinate_to_tupleでセル値を取得する方法。
- [PythonとFlaskによるmTLSのクライアント証明書のテスト環境構築方法](./2023-12-16-mtls.md) (`How-To | stable | stale_after: 2024-12-31`) — OpenSSLで認証局・サーバ証明書・クライアント証明書を作成し、FlaskのmTLS環境をcurlとWindowsブラウザで検証する手順。
- [[Python] Windowsで作成されたShift-JISファイルを開く方法](./2023-01-29-read-sjis-file.md) (`How-To | stable | stale_after: 2027-06-21`) — Windows由来のShift-JISファイルをPythonで開く際に、shift_jisではなくencoding=cp932とnewline指定を使う理由と方法。
- [[Python] json.dumps()で日本語が\uXXXXになるときの対処法](./2023-01-29-json-dumps-ensure-ascii-false.md) (`Troubleshooting | stable | stale_after: 2026-01-29`) — Pythonのjson.dumpsで日本語が\uXXXX形式にエスケープされる原因と、引数ensure_ascii=Falseを指定する対処法。
- [[Python] defaultdictの使い方](./2023-01-29-defaultdict.md) (`How-To | stable | stale_after: 2026-01-29`) — Python標準ライブラリcollectionsのdefaultdict(int)やdefaultdict(list)を使い、初期値付き辞書を簡潔に扱う方法。
- [[Python] FlaskでHTTPSサーバを立てる方法](./2022-10-22-flask-https.md) (`How-To | stable | stale_after: 2023-10-23`) — Flaskのapp.runにssl_contextとして証明書と秘密鍵を指定し、HTTPSサーバを起動してcurlで疎通確認する方法。
- [pip installでCERTIFICATE_VERIFY_FAILEDが出る時の対処法](./2022-07-09-pip-trusted-host.md) (`Troubleshooting | stable | stale_after: 2023-10-14`) — SSLインスペクション環境でpip install時にCERTIFICATE_VERIFY_FAILEDが出る原因と、trusted-host指定での対処法。
- [[Python] Seleniumでスクリーンショットを撮りPDFにまとめる](./2021-12-16-selenium-screenshot.md) (`How-To | stable | stale_after: 2025-07-30`) — PythonとSelenium（Firefox）でWebページの連続スクリーンショットを撮影し、ImageMagickのconvertで切り抜き・PDF化する手順。
- [[Python] Pythonのtelnetlibでメールを送信する](./2021-11-04-python-telnetlib-smtp.md) (`How-To | stable | stale_after: 2027-08-07`) — Pythonのtelnetlibを使ってSMTPプロトコルでメール送信テストを行う手順と、検証用Postfixサーバの構築・確認方法。
- [[Python] Pythonのtelnetlibでtelnetコマンドを実現する](./2021-11-03-python-telnetlib.md) (`How-To | stable | stale_after: 2027-08-07`) — telnetコマンドがないLinux環境でPython 3.12以下の標準ライブラリtelnetlibを使い対話的にtelnet通信を行う方法。
- [[Python] tkinterでフォルダ指定画面を作成する](./2021-08-28-tkinter-askdirectory.md) (`How-To | stable | stale_after: 2027-08-07`) — Pythonのtkinter.filedialog.askdirectoryでフォルダ選択画面を作る手順と、WindowsのCOMスレッド競合によるフリーズ回避法。
- [APDUコマンドの返り値をメッセージで表示する](./2021-01-26-apdu-return-status-msg.md) (`Reference | stable | stale_after: 2025-03-13`) — ICカードへのAPDUコマンド送信で返るSW1・SW2の2バイトステータスコード一覧と、意味を文字列で返すPythonデバッグ関数。
- [[Windows] PythonでICカードのIDmを確認する](./2021-01-25-get-idm-from-scard.md) (`How-To | stable | stale_after: 2023-03-13`) — Windows環境でSony PaSoRi RC-S380とpyscardを使い、APDUのGET DATAコマンドでICカードのIDmを取得する方法。
- [[Python] 単語単位の言語モデルの作り方](./2020-01-16-word-based-language-model.md) (`How-To | stable | stale_after: 2025-08-07`) — PythonのMeCabとnltk（MLE）を使い、日本語コーパスから単語単位のn-gram言語モデルを構築して次単語確率を求める方法。
- [[Python] 文書のコサイン類似度を求める](./2020-01-15-docs-similarity.md) (`How-To | stable | stale_after: 2025-08-07`) — コサイン類似度の定義式と、Pythonのscikit-learnでTF-IDFベクトルから文書間の類似度行列を計算する方法。
- [[Python] scikit-learn で tf-idf を求める](./2020-01-14-tf-idf.md) (`How-To | stable | stale_after: 2025-08-07`) — TF-IDFの定義式を確認し、Pythonのscikit-learn（TfidfVectorizer）と手計算の両方で重みを求める方法。
- [[Python] Unicodeの正規化とテキストのクレンジング](./2020-01-13-unicodedata-normalize.md) (`How-To | stable | stale_after: 2027-08-07`) — Pythonのunicodedata.normalize（NFKC）によるUnicode正規化と、str.maketransで特定全角記号を戻す手法。
- [[Python] 文字コードの判定と変換](./2020-01-12-decode-cchardet.md) (`How-To | stable | stale_after: 2025-08-07`) — Python3のcChardetライブラリを用いてShift_JISやUTF-8のバイト列から文字コードを自動判定しデコードする方法。
- [[Python] SeleniumでGoogle翻訳を自動化する](./2019-12-17-selenium-google-translate.md) (`How-To | stable | stale_after: 2025-07-30`) — PythonとSeleniumのヘッドレスFirefoxを使い、Google翻訳のWebページからCSSセレクタで翻訳結果を自動取得する方法。
- [研究室の自動開錠システムを作った話](./2019-09-13-auto-door-unlock.md) (`Essay | stable`) — FeliCaリーダーとRaspberry Pi、サーボモータ、systemdを用いて研究室の自動開錠システムを後輩と製作した開発記録。
- [[Python] タイピングゲーム「寿司打」の自動化](./2019-02-12-auto-SushiDA.md) (`Concept | stable | stale_after: 2025-07-21`) — PyAutoGUIの画像認識とTesseract（PyOCR）の2値化前処理を組み合わせてタイピングゲーム「寿司打」を自動化した構成と工夫。
- [[Python] 構造体を継承してコンストラクタをなくす](./2018-06-24-class-namedtuple.md) (`How-To | stable | stale_after: 2027-07-21`) — Python3のcollections.namedtupleをクラス継承に使い、制約のないフィールドを持つクラスのコンストラクタを省略する方法。
- [[Python] RubyのEnumerable#each_with_indexを自作する](./2016-12-15-each-with-index.md) (`How-To | stable | stale_after: 2027-07-21`) — Pythonの組み込み関数enumerateを使ってRubyのeach_with_indexのようにインデックス付きでループを回す方法と等価実装。
- [[Python] オブジェクト指向プログラミング](./2016-12-03-OOP-in-Python.md) (`Reference | stable | stale_after: 2027-07-21`) — Python3のクラス定義、コンストラクタ、クラス・スタティックメソッド、ネームマングリング、演算子、継承、デコレータの構文まとめ。
- [[Python] 別ファイルをimportする方法](./2016-10-09-import-files.md) (`How-To | stable | stale_after: 2027-07-21`) — Pythonで同じ階層・サブディレクトリ・親ディレクトリ（sys.path追加）にある別ファイルをimportする方法を階層別に解説。
