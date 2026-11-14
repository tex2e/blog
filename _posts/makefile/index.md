# makefile

Parent: [All Categories](../index.md)

## Articles (5)

- [Makefile の関数一覧](./2019-12-16-functions.md) (`Reference | stable | stale_after: 2026-09-17`) — Makefileの組み込み関数について、文字列操作・ファイル名操作・foreach/call/eval/shellなど各種関数の引数と使用例をまとめた一覧です。
- [各入力ファイルのディレクトリが別々で、出力ディレクトリが同じときのMakefileルールの書き方](./2019-11-07-multi-dir-of-each-input-file.md) (`How-To | stable | stale_after: 2022-11-08`) — 複数ディレクトリ配下の入力ファイルを単一の出力ディレクトリへ変換するため、wildcard・notdir・foreach・eval・callでMakefileルールを動的生成する方法を解説します。
- [Makefileから別のMakefileをimportする・実行する](./2017-12-09-import-another-makefile.md) (`How-To | stable | stale_after: 2026-09-17`) — Makefileからincludeディレクティブで別ファイルを読み込む方法と、サブディレクトリへ移動してmakeを実行する際の$(PWD)指定法を説明します。
- [クロスプラットフォームで make](./2016-12-05-cross-platform.md) (`How-To | stable | stale_after: 2019-12-05`) — Makefile内で$(shell uname)の実行結果とifeqディレクティブを使い、macOS・Linux・Cygwinごとに処理を分岐させる方法を説明します。
- [Makefile の特殊変数・自動変数の一覧](./2016-10-09-automatic-variables.md) (`Reference | stable | stale_after: 2026-09-17`) — Makefileの自動変数（ターゲットや依存ファイルを表す特殊記号）およびMakeの暗黙ルールで使われる変数と追加引数の意味をまとめた一覧です。
