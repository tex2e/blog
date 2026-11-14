# shell

Parent: [All Categories](../index.md)

## Articles (31)

- [[Bash] /dev/tcpを使用してサーバのポートが開いているか確認する](./2025-05-12-dev-tcp-host-port.md) (`How-To | stable | stale_after: 2028-05-12`) — telnetが使えない環境でBashの仮想デバイス/dev/tcpを用いて指定IPとポートへのTCP疎通を定期監視するスクリプトを解説。
- [nkfで複数ファイルを一括でUTF8に変換する](./2025-04-13-nkf-utf8.md) (`How-To | stable | stale_after: 2028-04-13`) — findコマンドとnkfの-w・-Lu・--overwriteオプションを組み合わせ、複数ファイルを一括でUTF-8かつLFへ変換する手順を解説。
- [改行コードがLFのcmdファイル一覧を表示させる](./2024-09-27-CRLF-LF.md) (`How-To | stable | stale_after: 2027-09-27`) — Git Bash等でfindとfileコマンド、grep -vを組み合わせ、CRLF表記を含まない改行コードLFのcmdファイル一覧を抽出する方法を解説。
- [[Linux] スレッド数をカウントするコマンド](./2024-07-28-process-count.md) (`How-To | stable | stale_after: 2027-07-29`) — Linuxでps -elfTとwc -lを組み合わせて全スレッド数を計測・監視するコマンドと、ulimitやlimits.confでの上限確認法を解説。
- [[Vim] 一括置換をする方法](./2023-11-17-vim-substitute.md) (`How-To | stable | stale_after: 2027-07-28`) — Vimのコマンドモードで:%s/による全行一括置換や末尾cフラグを用いた対話的確認付き置換を行うコマンド書式と各指定文字の意味を解説。
- [同期元と同期先の両方にrsyncコマンドがないとエラーになる](./2023-11-14-rsync-on-remote-server.md) (`Troubleshooting | stable | stale_after: 2027-07-28`) — rsync実行時にcommand not foundエラーが出る原因はリモート側未導入であり、同期先へのインストールで解決できることを解説。
- [シェルスクリプト実行で「無効なオプション」でエラー終了する時の対処法](./2023-11-12-bash-invalid-option.md) (`Troubleshooting | stable | stale_after: 2026-11-11`) — Windowsで作成したシェルスクリプト実行時にCRLF改行が原因で無効なオプションエラーが出る事象とLF変換による対処法を解説。
- [findで特定パスを除外してファイル名を検索する方法](./2023-08-20-find-not-path.md) (`How-To | stable | stale_after: 2027-01-03`) — findコマンドで特定ディレクトリを検索対象から除外するgrep -v、-not -path、-regex、-pruneの4通りの方法を解説。
- [sedでDOM付きUTF-8からDOMを削除する](./2023-04-09-remove-utf8-dom.md) (`How-To | stable | stale_after: 2026-04-09`) — sedコマンドで先頭のバイト列xEFxBBxBFを置換し、複数テキストファイルからUTF-8のBOM（記事内表記DOM）を一括削除する方法。
- [iconvでエンコードをUTF16をUTF8に変換する](./2023-04-08-convert-utf16-to-utf8.md) (`How-To | stable | stale_after: 2026-04-09`) — fileコマンドでUTF-16LEを判定し、iconvを使って複数テキストファイルの文字コードをUTF-8へ一括変換する手順。
- [awkでCSVのN番目の列だけを置換する](./2023-04-07-replace-nth-item-in-csv.md) (`How-To | stable | stale_after: 2026-04-09`) — awkコマンドの-F、OFS、gsubを使い、CSVやタブ区切りファイルで指定したN番目の列だけを置換する方法を解説。
- [UID / GID の重複を検出するためのシェルスクリプト](./2021-11-18-duplicated-uid-gid.md) (`How-To | stable | stale_after: 2025-03-13`) — Linuxの/etc/passwdや/etc/groupからUIDとGIDの重複を検出するBashスクリプトとnewusersの注意点を紹介。
- [[Vim] シンタックスハイライトを暗い背景色に合わせる](./2021-11-09-vim-syntax-off.md) (`How-To | stable | stale_after: 2027-07-28`) — PowerShellのssh越しに使うVimで背景色と同化する配色を、syntax offやbackground=dark設定で見やすく改善する方法。
- [MacOSのWiresharkが権限エラーでキャプチャできないとき](./2021-10-08-wireshark-permission-err-macos.md) (`Troubleshooting | stable | stale_after: 2027-07-28`) — macOSのWiresharkでlo0キャプチャ時に権限エラーが出る原因と、/dev/bpfの所有者変更による対処法を解説。
- [Bashのif文でANDやOR条件、&&や||演算子を使う](./2021-07-03-bash-and-or.md) (`Reference | stable | stale_after: 2025-03-13`) — Bashのif文で&&や||演算子、非推奨の-a/-o引数、中括弧による条件のグループ化を記述する方法を解説。
- [GPG秘密鍵を別PCに移動させる](./2021-05-05-gpg-sec-key-export-import.md) (`How-To | stable | stale_after: 2025-03-13`) — GPG秘密鍵をエクスポートして別PCへインポートし、公開鍵の信用値設定やGitタグ署名を有効にする手順を解説。
- [Bashで文字列の右からN文字分を削除する](./2021-05-04-cut-from-right.md) (`How-To | stable | stale_after: 2025-03-13`) — Bashで文字列の末尾からN文字を削除するためにrevとcutを組み合わせる方法と、rev非搭載環境向けのawk代替コマンドを解説します。
- [topコマンドの結果をファイルに出力する](./2021-03-28-top-bn1.md) (`How-To | stable | stale_after: 2027-07-28`) — topコマンドのバッチモード(-b)と実行回数(-n)・間隔(-d)オプションを使い、システム監視結果を一定間隔でファイル出力する方法を解説します。
- [wgetでサイト全体をダウンロードする](./2020-08-28-wget-entire-website.md) (`How-To | stable | stale_after: 2025-03-13`) — wgetの--mirrorや--convert-links・--page-requisites・--waitオプションを使い、Webサイト全体をローカルへミラーリングする方法を解説します。
- [ImageMagicでExifのOrientationから画像を適切に回転する](./2020-03-29-mogrify-auto-orient.md) (`How-To | stable | stale_after: 2024-03-21`) — ImageMagickのmogrify -auto-orientコマンドでExifのOrientation情報をもとに画像を適切な向きへ回転・修正する方法を解説します。
- [入出力リダイレクタでファイルを上書き更新する](./2020-01-04-file-replace-without-tmpfile.md) (`How-To | stable | stale_after: 2023-01-04`) — 一時ファイルを作成せずBashの入出力リダイレクタとtrやsedを組み合わせて、ファイルを直接上書き更新する方法と仕組みの考察を解説します。
- [grepコマンドで特定のディレクトリを検索対象から除外する](./2019-05-27-grep-exclude-dir.md) (`How-To | stable | stale_after: 2026-08-22`) — grep -rで.gitなどの特定ディレクトリや*.min.jsのようなファイルを検索対象から除外するための--exclude-dirと--excludeの使い方を解説します。
- [wgetでWebサイトを巡回してリンク切れを確認する](./2019-05-25-check-broken-links-using-wget.md) (`How-To | stable | stale_after: 2026-08-22`) — wgetの--spiderと再帰オプションを用いてWebサイトを巡回し、リンク切れページをwget.logに出力して検出する方法を解説します。
- [コマンドでメールを送る](./2018-08-22-send-mail.md) (`How-To | stable | stale_after: 2026-08-22`) — LinuxのmailコマンドでCLIからメール送信する基本構文と、MTA(sendmail)・MUAの違いや日本語とJISコードの注意点を解説します。
- [Bashでパイプからの入力があるかどうかを確認する方法](./2017-08-21-check-if-has-input-from-stdin.md) (`How-To | stable | stale_after: 2026-08-22`) — Bashスクリプトでtest -p /dev/stdinを使い、パイプやFIFOを通じた標準入力の有無を判定する方法について解説します。
- [Convert ttf to png](./2017-07-08-ttf-to-png.md) (`How-To | stable | stale_after: 2026-08-22`) — ImageMagickのconvertコマンドと-font・labelオプションを使って、TTFフォントの指定文字をPNG画像として出力する方法を解説します。
- [findの -or オプションで複数条件の検索](./2017-06-12-find-name-or.md) (`How-To | stable | stale_after: 2026-08-22`) — Linuxのfindコマンドで-orオプションを使い、複数のファイル名やディレクトリ名の条件のいずれかに一致する対象を検索する方法を解説します。
- [find -exec でパイプを使った複数コマンドを実行する](./2017-06-11-find-exec.md) (`How-To | stable | stale_after: 2026-08-22`) — find -exec内でパイプを含む複数コマンドを実行できない原因と、sh -cや関数・for文を使って回避する実装方法を解説します。
- [Bashで一時ファイルを作る方法](./2016-12-30-tmpfile-best-practice.md) (`How-To | stable | stale_after: 2026-12-14`) — Bashスクリプトでmktempコマンドにより安全に一時ファイルを作成し、trapを使って正常・異常終了時に確実に自動削除するベストプラクティスを解説します。
- [冗長なパス foo/bar/../lib を foo/lib に変換する](./2016-10-09-remove-verbose-from-path.md) (`How-To | stable | stale_after: 2026-08-22`) — シェルスクリプトで結合されたパスの「.」や「..」を取り除いて正規化するBash関数remove_verboseの実装方法と動作例を解説します。
- [エラーメッセージ表示用の関数](./2016-04-14-warn-and-err-func.md) (`Reference | stable | stale_after: 2026-08-22`) — シェルスクリプトでANSIエスケープシーケンスにより色付きで警告・エラー・成功・失敗メッセージを出力するwarn/error/success/failed関数集です。
