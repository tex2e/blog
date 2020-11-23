---
layout:        post
title:         "cmd.exeとbashのコマンド比較表"
date:          2020-11-23
category:      WindowsBatch
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

Windowsのcmd.exeで使えるコマンドと、bashで使えるコマンドの比較表です。
MacやLinuxから、Windowsに移行したときに、どのコマンドがどれと対応しているのか、名前が似ているけど機能が違うものがあって頭が混乱するので、cmd.exeとbashコマンドの対応表を作りました。


| 処理名 | cmd.exe | bash
|------+---------+------
ファイル・ディレクトリ一覧表示 | dir | ls
ディレクトリ構造表示 | tree | tree
カレントディレクトリ表示 | cd | pwd
ディレクトリの移動 | cd | cd
ファイルコピー | copy | cp
ファイル・ディレクトリ名変更 | ren | mv
ファイル移動 | move | mv
ファイル削除 | del | rm
ディレクトリ作成 | mkdir | mkdir
ディレクトリ削除 | rmdir | rmdir
ディレクトリコピー | xcopy, robocopy | cp -r
ファイルの内容表示 | type | cat
ファイル結合 | copy | cat
ファイル比較 | fc | diff
ファイル名検索 | dir | find
ファイル内検索 | find | grep
ファイルの先頭・末尾表示 | -- | head, tail
ファイルのアクセス権設定 | cacls | chmod
シンボリックリンクの作成 | mklink | ln -s
カレントディレクトリのスタック | pushd, popd | pushd, popd
ファイル圧縮 | compact (NTFS) | zip
標準入力からファイル作成 | copy con | cat >
画面クリア | cls | clear
文字色・背景色の設定 | color | --
1画面ずつ表示 | more | more, less
クリップボードにコピー | clip | (MacOS) pbcopy, pbpaste
コマンドの履歴表示 | [F7] | history
複数コマンドの実行 | cmd1 & cmd2 | cmd1; cmd2
コマンドの別名設定 | doskey | alias
コマンドの保存場所 | -- | type, which
コマンドのバックグラウンド実行 | start cmd1 | cmd1 &
待機 | timeout | sleep
日付表示 | date /t | date
時刻表示 | time /t | date
システム情報表示 | systeminfo | uname -a
プロセス一覧表示 | tasklist | ps auxw
プロセスキル | taskkill | kill
環境変数一覧表示 | set | set
環境変数の設定 | set | export
PATHの表示 | path, echo %PATH% | echo $PATH
予定時刻にコマンド実行 | at | at
パスワード変更 | net user | passwd
別ユーザとして実行 | runas /user | sudo
ボリュームラベル表示 | vol | --
ボリュームラベル変更 | label | --
IPアドレス・MACアドレス表示 | ipconfig /all | ip addr, ifconfig
ネットワークの疎通確認 | ping | ping
DNS名前解決 | nslookup | nslookup
ネットワーク状態表示 | netstat | ss
ファイルダウンロード | -- | curl
