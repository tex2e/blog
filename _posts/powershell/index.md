# powershell

Parent: [All Categories](../index.md)

## Articles (46)

- [[PowerShell] Windowsイベントログを収集する](./2024-06-05-Get-Eventlog.md) (`How-To | stable | stale_after: 2027-07-21`) — PowerShellのGet-EventlogとExport-Clixmlを組み合わせ、WindowsのアプリケーションやシステムイベントログをXML形式で収集する方法を解説します。
- [[PowerShell] 多階層のフォルダを一発で作成する (mkdir -p)](./2024-01-28-New-Item-mkdir-p.md) (`How-To | stable | stale_after: 2027-07-21`) — PowerShellのNew-Itemに-ItemType Directoryと-ErrorAction SilentlyContinueを指定し、mkdir -p相当の多階層フォルダを作成する方法を説明します。
- [[PowerShell] 正規表現で名前付きグループ (Named Group) を使う](./2024-01-26-regex-namedgroup.md) (`How-To | stable | stale_after: 2027-08-05`) — PowerShellの正規表現で名前付きグループを使うため、-match演算子ではなくregexクラスのMatchesメソッドで値を抽出する方法を解説します。
- [[PowerShell] N日経過したファイルを削除する](./2023-11-11-delete-by-last-write-time.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのGet-ChildItemとLastWriteTimeプロパティ、AddDaysを組み合わせて、更新から指定日数経過したファイルを削除する方法を解説します。
- [[PowerShell] 実行時に管理者権限で動作しているか調べる](./2023-04-22-check-is-admin.md) (`How-To | stable | stale_after: 2026-04-22`) — PowerShellで.NETのWindowsPrincipalクラスを利用し、実行中のスクリプトが管理者権限を持っているか判定する方法を紹介します。
- [[PowerShell] ローカルユーザを無効化する](./2022-11-11-disable-localuser.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのDisable-LocalUserおよびEnable-LocalUserコマンドレットを使い、ローカルユーザを無効化・有効化する方法を説明します。
- [[PowerShell] ローカルユーザのパスワードを変更する](./2022-11-10-change-localuser-password.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのGet-LocalUserとConvertTo-SecureString、Set-LocalUserを用いてローカルユーザのパスワードを変更する方法を解説します。
- [[PowerShell] コンソールでSSH公開鍵認証をする](./2022-07-12-ssh-pub-key-auth.md) (`How-To | stable | stale_after: 2027-07-28`) — Windows 10のPowerShell標準のOpenSSHを使い、SSH鍵生成からサーバへの公開鍵登録、秘密鍵を指定したSSH接続手順を説明します。
- [[PowerShell] PowerShellコンソールの配色を設定する](./2022-07-09-windows-powershell-color-themes.md) (`How-To | stable | stale_after: 2027-07-28`) — Microsoft製のColorTool.exeを使い、Windows PowerShellコンソールの配色テーマを設定・変更する手順を説明します。
- [[PowerShell] AES暗号で文字列を暗号化する](./2022-04-23-AES-Encrypt.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのAesCryptoServiceProviderを用い、CBCモードおよびECBモードで文字列をAES暗号化・復号する実装例を紹介します。
- [[PowerShell] 文字列を日付に変換して時間差を求める (New-TimeSpan)](./2022-04-21-New-TimeSpan.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellでParseExactを用いて文字列をDateTime型へ変換し、New-TimeSpanで2つの日時の時間差を計算する方法を解説します。
- [[PowerShell] 複数ファイルを一つにまとめる (Get-Content)](./2022-04-20-concat-files.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのGet-ContentとSet-Contentで文字化けを防ぎつつ複数ファイルを結合し、ソートや重複排除して保存する方法を説明します。
- [[PowerShell] 処理をバックグラウンドで実行する (Start-Job)](./2022-04-19-background-job.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのStart-JobやGet-Job、Receive-Job、Remove-Jobを使って処理をバックグラウンドで非同期実行・管理する方法を解説します。
- [BashのコマンドとPowerShellコマンドの対応表](./2022-04-18-bash-to-powershell.md) (`Reference | draft`) — cp・mv・rm・cat・ls・pwd・cd・dirname・test・sleepなど主要なBashコマンドに対応するPowerShellコマンドレットの対応表です。
- [[PowerShell] ファイルの更新を監視する (Get-Content -Wait, FileSystemWatcher)](./2022-04-17-Register-ObjectEvent.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのGet-Content -WaitやFileSystemWatcher、Register-ObjectEventを用いてファイルの変更等を監視する方法を解説します。
- [[PowerShell] 進捗を表すプログレスバーを表示する (Write-Progress)](./2022-04-16-Write-Progress.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのWrite-Progressコマンドレットと-PercentCompleteオプションを使ってコンソール上に進捗バーを表示する方法を紹介します。
- [[PowerShell] 標準出力に色付けをする (Write-Host)](./2022-04-15-Write-Host-Color.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのWrite-Hostコマンドレットで-ForegroundColorと-BackgroundColorを指定し出力文字に色を付ける方法を解説します。
- [PowerShellでファイル内の文字列置換 (sed -i) をする](./2022-04-14-sed.md) (`How-To | stable | stale_after: 2026-09-17`) — PowerShellでGet-Contentと-replace、Set-Contentを組み合わせてsed -i相当のファイル内文字列置換を行う手順と注意点を解説します。
- [PowerShellでhead, tail (Get-Content) を使う](./2022-04-13-Get-Content-TotalCount-Tail.md) (`Reference | stable | stale_after: 2025-04-13`) — Linuxのheadやtailコマンド相当の先頭行・末尾行取得をPowerShellのGet-Contentの-TotalCountと-Tailで行う方法を説明します。
- [PowerShellでgrep (Select-String) を使う](./2022-04-12-Select-String.md) (`Reference | stable | stale_after: 2027-01-26`) — Linuxのgrepにおける再帰検索や否定マッチ、大文字小文字区別、エンコーディング指定をPowerShellのSelect-Stringで行う対応集です。
- [[PowerShell] Map, Filter, Reduceの使い方](./2022-04-11-map-filter-reduce.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellでforeachやwhere、スクリプトブロックのbegin・process・endを用いてMap・Filter・Reduceを実装する方法を示します。
- [[PowerShell] 関数とパイプラインの使い方](./2022-04-10-function.md) (`Reference | stable | stale_after: 2027-10-15`) — PowerShellにおける関数定義、paramや参照渡し、戻り値の仕様、begin・process・endブロック、高階関数を解説します。
- [[PowerShell] 自動変数の使い方](./2022-04-09-automatic-variables.md) (`Reference | stable | stale_after: 2027-07-28`) — PowerShellで自動的に定義される$_や$args、$Error、$matches、$profileなどの自動変数の意味と用途をまとめます。
- [[PowerShell] 制御フロー (if, switch, for, foreach) の使い方](./2022-04-08-control-flow.md) (`Reference | stable | stale_after: 2027-07-28`) — PowerShellにおけるif-elseif-else、正規表現やファイル入力に対応したswitch、for、foreach、while文の構文を説明します。
- [[PowerShell] 演算子の使い方の一覧](./2022-04-07-operators.md) (`Reference | stable | stale_after: 2027-07-28`) — PowerShell独自の比較・パターンマッチ・正規表現・型判定・論理・ビット・算術などの各演算子の意味と使用例を一覧で解説します。
- [[PowerShell] XMLデータを読み取る](./2022-04-06-read-xml.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShell組み込みのXML型キャストとGet-Contentを組み合わせて、XML文字列やXMLファイルの要素を読み取る方法を説明します。
- [[PowerShell] 配列と連想配列の使い方](./2022-04-05-array.md) (`Reference | stable | stale_after: 2027-07-28`) — PowerShellにおける配列と連想配列の定義、スライス、並列代入、-join/-split演算子、順序付き連想配列の構文をまとめます。
- [[PowerShell] エスケープシーケンスで特殊文字を表現する](./2022-04-04-escape-sequence.md) (`Reference | stable | stale_after: 2027-07-28`) — PowerShellのエスケープ文字であるバッククォートを使った行継続、特殊文字の一覧、クォート文字の二重記述ルールを解説します。
- [PowerShellにおける変数の定義・読み書き](./2022-04-03-variables.md) (`Reference | stable | stale_after: 2027-07-28`) — PowerShellにおける大文字小文字を区別しない変数、記号を含む変数名、ファイル読み書き変数、型付け、動的取得の仕様をまとめます。
- [[PowerShell] 複数行コメントの書き方](./2022-04-02-comments.md) (`Reference | stable | stale_after: 2027-07-28`) — PowerShellで複数行コメントを記述する構文と、PowerShell v1環境向けにヒアドキュメントを代用する書き方を紹介します。
- [[PowerShell] 文字列展開・リストの評価](./2022-04-01-expression.md) (`Concept | stable | stale_after: 2027-07-28`) — PowerShellにおける式評価の制御方法である丸括弧による優先順位指定、式のサブパースによる文字列展開、リスト評価を解説します。
- [PowerShellでfind (Get-ChildItem) を使う](./2022-03-05-Get-ChildItem.md) (`Reference | stable | stale_after: 2028-10-13`) — Linuxのfindコマンドにおけるファイル名検索や深さ制限、更新時間指定などの処理をPowerShellのGet-ChildItemで実現する対応例集です。
- [[PowerShell] フォルダをコピーする (Copy-Item -Recurse)](./2022-03-04-Copy-Item_Recurse.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのCopy-Item -Recurseでフォルダをコピーする際のTest-Pathによる存在確認と例外処理を説明します。
- [[PowerShell] ConvertFrom-CSVでタブ区切り (TSV) をforeachで1行ずつ処理する](./2022-03-03-ConvertFrom-CSV.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellでヒアドキュメントのTSV文字列をConvertFrom-CSVで変換し、foreachで1行ずつ処理する方法を示します。
- [[PowerShell] Get-Itemでファイルサイズを取得する](./2022-03-02-Get-Item_Length.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのGet-ItemとLengthプロパティでファイルサイズを取得し、再帰的に空ファイルを検索する方法を解説します。
- [[PowerShell] New-Itemの出力結果を表示させない方法](./2022-03-01-New-Item.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのNew-Itemでファイルやフォルダ作成時の出力やエラーを$nullへのリダイレクト等で抑制する方法を説明します。
- [[PowerShell] Windowsユーザの一覧を表示する](./2021-11-05-list-user.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのGet-WmiObjectやGet-LocalUserでWindowsユーザ一覧を表示する方法とSIDの見方を解説します。
- [[PowerShell] リモートでコマンドを実行する](./2021-03-06-enable-psremoting.md) (`How-To | stable | stale_after: 2027-07-28`) — Enable-PSRemotingやWinRM、TrustedHostsを設定しPowerShellでリモートコマンドを実行する手順を説明します。
- [[PowerShell] ログイン・ログアウトのイベントログを取得する](./2021-02-02-get-eventlog-logon-logoff.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのGet-EventLogでWindowsのシステムログからログイン・ログアウトのイベント時刻を抽出する方法を紹介します。
- [[PowerShell] SQLコマンドを実行する](./2021-02-01-invoke-sql-command.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellからOleDbでSQL Serverに接続し、Windows認証やSQL認証でSQLを実行して表形式で出力する方法を解説します。
- [[PowerShell] Linuxのwhichコマンドを作る](./2021-01-23-which.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのGet-CommandをProfileに関数登録し、Linuxのwhichコマンドのように定義場所を調べる方法を説明します。
- [[PowerShell] MacOSのopenコマンドを作る](./2021-01-11-open.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのInvoke-ItemとProfileへのSet-Alias設定でmacOSのopenコマンド相当を再現します。
- [[PowerShell] Excelを読み込む](./2021-01-02-read-excel.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellからExcel.ApplicationのCOMオブジェクトを操作してExcelファイルのセル値を読み込む方法を解説します。
- [[PowerShell] バッチファイルからPowerShellを呼び出す](./2021-01-01-cmd-call-powershell.md) (`How-To | stable | stale_after: 2027-07-28`) — バッチファイルから位置引数や名前付き引数を渡してPowerShellスクリプトを呼び出す方法と実行ポリシー設定を説明します。
- [[PowerShell] 部分文字列を抽出する](./2020-12-31-substring.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのSubStringで長さ超過エラーを起こさずに配列の範囲指定とJoin演算子で部分文字列を抽出する方法を解説します。
- [[PowerShell] 型エイリアスの一覧](./2020-11-29-type-alias.md) (`Reference | stable | stale_after: 2027-07-28`) — PowerShellの型アクセラレータ一覧と、Get・Addメソッドで型エイリアスを取得・追加および型特定する方法をまとめます。
