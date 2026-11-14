# database

Parent: [All Categories](../index.md)

## Articles (15)

- [[SQLServer] テーブルに列を追加する方法](./2025-04-23-sqlserver-add-column-to-table.md) (`How-To | stable | stale_after: 2028-05-03`) — SQL Serverで既存テーブルをsp_renameで退避し、列を追加した新テーブルを作成してデータをINSERT後に旧テーブルを削除する一連のSQLテンプレートを紹介します。
- [[SQLServer] テーブルをロックしているセッションを特定するSQL](./2024-08-04-sqlserver-disconnect-connection-table.md) (`Troubleshooting | stable | stale_after: 2027-08-04`) — SQL Serverでデッドロック等によりテーブルロックを解放しないセッションをsys.dm_tran_locksとsys.partitionsで特定し、KILLで終了するSQLを解説します。
- [[SQLServer] 全ての接続元セッションを切断するためのSQL](./2024-08-03-sqlserver-disconnect-connection-db.md) (`How-To | stable | stale_after: 2027-08-04`) — SQL ServerでDBリネームなどの操作前に特定データベースへ接続中の全セッションを特定し、KILLコマンドで強制切断するためのT-SQLクエリを紹介します。
- [[SQLServer] SELECTした行に連番を振る (ROW_NUMBER)](./2024-06-03-sqlserver-row-number.md) (`How-To | stable | stale_after: 2027-08-04`) — SQL ServerでSELECT結果の行に連番を振るROW_NUMBER()関数の使い方と、PARTITION BY句でグループごとに番号を振り直すSQL例を解説します。
- [[MySQL] DBのダンプの作成とリストアの方法](./2021-11-19-mysql-dump-restore.md) (`How-To | stable | stale_after: 2027-07-21`) — mysqldumpとmysqlコマンドを用いて、MySQLの全データベース・指定データベース・指定テーブルをそれぞれバックアップ(ダンプ)しリストアする方法を紹介します。
- [[MySQL] MariaDBでユーザ作成と権限付与をする](./2021-11-18-mysql-create-user.md) (`How-To | stable | stale_after: 2027-07-21`) — MySQLやMariaDBのコンソールでCREATE USERとGRANT ALL PRIVILEGESを実行し、新規データベースユーザーを作成して権限を付与する手順を解説します。
- [[MySQL] mysql_secure_installationで不要なユーザを削除する](./2021-11-17-mysql-secure-installation.md) (`How-To | stable | stale_after: 2027-07-21`) — MySQLのユーザー一覧で匿名ユーザーやリモートroot権限を確認し、mysql_secure_installationコマンドで不要なアカウントを削除する手順を説明します。
- [[MySQL] mysqldが起動できないときの対処 (/var/lib/mysql/ 関連)](./2021-10-11-mysql-start-err.md) (`Troubleshooting | stable | stale_after: 2027-07-21`) — systemctlでMySQLが起動せず/var/lib/mysql/が使用不可のエラーが出た際に、データディレクトリ削除とmysqld --initializeで復旧する対処法をまとめます。
- [[MySQL] DBへ外部からの接続するための手順](./2021-08-07-mysql-setup.md) (`How-To | stable | stale_after: 2027-07-21`) — UbuntuにMySQLをインストールし、mysql_secure_installationや接続ユーザー作成、mysqld.cnfのbind-address設定、ufwで外部接続を許可する手順を解説します。
- [[PostgreSQL] 共通鍵によるデータ暗号化・復号](./2021-03-14-postgresql-pgp-encrypt.md) (`How-To | stable | stale_after: 2027-07-21`) — PostgreSQLのpgcrypto拡張を導入し、pgp_sym_encryptとpgp_sym_decrypt関数やbytea型を使って共通鍵でデータを暗号化・復号する方法を解説します。
- [[SQLServer] SQL Serverへ別PCから接続できるようにする](./2021-01-24-sqlserver-setup.md) (`How-To | stable | stale_after: 2027-08-04`) — SQL ServerとSSMSの認証・TCP/IP設定、SQL Server Browserの起動、Windowsファイアウォール許可を行い別PCからリモート接続する手順をまとめます。
- [[MySQL] SQLでFizzBuzzを出力する](./2019-03-11-mysql-fizzbuzz.md) (`How-To | stable | stale_after: 2027-07-21`) — MySQLで1から100の数列を生成するサブクエリとCASE式を組み合わせ、SQLクエリのみでFizzBuzzの結果を出力する実装例を紹介します。
- [[MySQL] 1〜Nの数列をSQLで扱う](./2019-03-10-mysql-numerical-sequence.md) (`How-To | stable | stale_after: 2027-07-21`) — MySQLでUNIONやテーブルの直積(CROSS JOIN)とユーザー変数のインクリメントを組み合わせ、1からNまでの連番数列をSQLで生成する方法を解説します。
- [[SQLite] VARCHAR型の文字数を制限する方法](./2016-12-10-sqlite-varchar-length.md) (`Concept | stable | stale_after: 2027-07-21`) — SQLiteのスキーマではVARCHAR(N)を指定してもTEXT型として扱われ、文字列の最大長が強制・制限されない仕様を公式FAQをもとに解説します。
- [[SQLite] データベースを作る方法](./2016-11-21-sqlite-create-db.md) (`How-To | stable | stale_after: 2027-07-21`) — SQLファイルにテーブルのスキーマを定義し、sqlite3コマンドへ流し込んでSQLiteデータベースとテーブルを新規作成する基本手順を説明します。
