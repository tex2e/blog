# dotnet

Parent: [All Categories](../index.md)

## Subcategories

- [blazor/](./blazor/index.md) (18 posts)
- [c#-sprache/](./c#-sprache/index.md) (11 posts)

## Articles (27)

- [Visual Studioのマルチカーソル機能のカスタマイズ](./2026-06-24-multi-cursor-editing.md) (`Troubleshooting | stable | stale_after: 2029-06-24`) — Visual Studio 2022以降でCtrl+Dを押すとマルチカーソルではなく行の複製が実行される競合問題の原因と、キーボードショートカット設定の変更手順を解説します。
- [NuGetパッケージのキャッシュをクリアする方法](./2026-02-07-nuget-cache-clear.md) (`How-To | stable | stale_after: 2029-02-08`) — NuGetの最新パッケージが取得できない場合に備え、Visual Studioの設定画面およびdotnet nuget localsコマンドからローカルキャッシュを削除する手順を解説します。
- [[C#] tail -f コマンドをC#プログラムで自作する](./2025-05-25-create-tail-f-command.md) (`How-To | stable | stale_after: 2028-05-25`) — C#でFileStreamやStreamReaderとConsole.CancelKeyPressを組み合わせ、ファイル末尾の追記をリアルタイムに監視・出力するtail -f互換プログラムの自作例を解説します。
- [[C#] マルチスレッド処理：Parallel.For/ForEachで並列処理](./2025-05-24-multithreading-for-foreach.md) (`How-To | stable | stale_after: 2028-05-25`) — C#のParallel.ForおよびParallel.ForEachを使って配列やリストの反復処理を複数CPUコアで並列実行し、大量データ処理を高速化する方法を解説します。
- [[C#] マルチスレッド処理：例外処理とAggregateException](./2025-05-23-multithreading-exception.md) (`Concept | stable | stale_after: 2028-05-25`) — C#のTask内で発生した例外がTask.WaitではAggregateExceptionに包まれawaitでは直接スローされる違いと、Handleメソッドでの処理方法を解説します。
- [[C#] マルチスレッド処理：async/awaitで並列処理](./2025-05-22-multithreading-async-await.md) (`How-To | stable | stale_after: 2028-05-25`) — C#のasync/awaitを使い非同期メソッドや同期メソッドからTaskを待機・結果取得する方法と、コンパイラによるGetAwaiter継続変換の仕組みを解説します。
- [[C#] マルチスレッド処理：スレッドセーフなキュー (ConcurrentQueue)](./2025-05-21-multithreading-concurrentqueue.md) (`How-To | stable | stale_after: 2028-05-25`) — C#のConcurrentQueueを用いたProducer-Consumerパターンの実装方法と、Enqueue・TryDequeue・TryPeekの使い方およびnull返却時の注意点を解説します。
- [[C#] マルチスレッド処理：lockによる変数へのアクセス排他制御](./2025-05-20-multithreading-lock.md) (`How-To | stable | stale_after: 2028-05-25`) — C#のマルチスレッド処理で複数スレッドが共有変数へ同時アクセスする際のデータ破損を防ぐため、lockステートメントで排他制御を行う方法と注意点を解説します。
- [[C#] マルチスレッド処理：Taskクラスで並列処理](./2025-05-19-mulththreading-task.md) (`How-To | stable | stale_after: 2028-05-26`) — C#でスレッドプールを活用するTask.Runを使い、返り値なしTaskや返り値ありジェネリクスTaskの起動・待機、ThreadPool直接呼び出しとの比較を解説します。
- [[C#] マルチスレッド処理：Threadクラスで並列処理](./2025-05-18-multithreading-thraed.md) (`How-To | stable | stale_after: 2028-05-25`) — C#でプロセスとスレッドの基礎知識を踏まえ、Threadクラスによるスレッドの起動・待機方法と過剰生成による負荷・スレッドプールとの違いを解説します。
- [[C#] Roslyn Analyzerの作成方法・静的解析方法](./2025-03-17-roslyn-analyzer.md) (`How-To | stable | stale_after: 2028-03-20`) — Visual Studioに拡張機能開発ワークロードを導入し、Roslyn Analyzerプロジェクトを作成してプロジェクトへ組み込み静的解析を実行する手順を解説します。
- [[C#] Workerを使ってサービスを実装する](./2024-10-18-WorkerService.md) (`How-To | stable | stale_after: 2027-10-22`) — C#のWorkerテンプレートからバックグラウンドサービスプロジェクトを作成し、BackgroundServiceを実装して定期処理を実行する手順を解説します。
- [[C#] Loggingを使ったログの記録](./2024-10-17-logging.md) (`How-To | stable | stale_after: 2027-10-14`) — Microsoft.Extensions.Loggingを使い、コンソール出力の基本設定からコンパイル時のログソース生成、ログの書式設定までを実装する方法を解説します。
- [[C#] プログラム実行時の構成 (Configuration) の読み込み](./2024-10-16-MS-Configuration.md) (`How-To | stable | stale_after: 2027-10-14`) — Microsoft.Extensions.Configurationを用いてInMemory構成やJSONファイルから設定値を読み込み、オプションの入力検証を行う方法を解説します。
- [[C#] MS.DIコンテナでデリゲートを用いたサービス登録](./2024-10-15-MSDI-AddServiceWithDelegate.md) (`How-To | stable | stale_after: 2027-10-14`) — Microsoft.Extensions.DependencyInjectionのサービス登録時にデリゲートを指定し、設定クラスのインスタンス値を動的に構成して注入する方法を解説します。
- [[C#] 依存注入のためのMS.DIコンテナの生存管理 (Transient/Singleton/Scoped)](./2024-10-14-MSDI-container-lifetime-management.md) (`Concept | stable | stale_after: 2027-10-14`) — Microsoft.Extensions.DependencyInjectionにおけるTransient・Singleton・Scopedの3種類のインスタンス生存期間の違いと登録メソッドの挙動を解説します。
- [[C#] 例外を再スローするときの注意点](./2024-07-29-best-practices-for-exceptions.md) (`Concept | stable | stale_after: 2027-07-29`) — C#のcatch句でthrow exと書くと元のスタックトレースが失われて原因調査が困難になる理由と、引数なしのthrowで再スローすべき理由を解説します。
- [[C#] ネットワーク通信失敗時に自動でリトライする仕組みを実装する](./2024-07-21-network-connection-retry.md) (`How-To | stable | stale_after: 2027-07-21`) — C#でHttpRequestException発生時に一定回数リトライし、失敗回数に応じて待機時間を段階的に延ばしてサーバー負荷を抑える再接続処理の実装例を解説します。
- [[C#] Reflectionで属性付きメソッドの一覧を動的に取得する](./2024-07-10-GetMethodsByAttribute.md) (`How-To | stable | stale_after: 2027-07-21`) — C#のReflection機能でType.GetMethodsとMethodInfo.IsDefinedを組み合わせ、特定のカスタム属性が付与されたメソッド一覧を動的に抽出する方法を解説します。
- [[C#] Reflectionでメソッド一覧を動的に取得する](./2024-07-09-GetMethods.md) (`How-To | stable | stale_after: 2027-07-21`) — C#のReflection機能を使い、クラスやインスタンスから取得したTypeオブジェクトに対してType.GetMethodsを呼び出し、メソッド一覧を動的に取得する方法を解説します。
- [[C#] Reflectionでプロパティ値を動的に取得する](./2024-07-08-GetProperty.md) (`How-To | stable | stale_after: 2027-07-21`) — C#のReflection機能を使い、Type.GetPropertyとPropertyInfo.GetValueを用いてインスタンスのプロパティ値を名前指定で動的に取得する方法を解説します。
- [[C#] Reflectionでプロパティ一覧を動的に取得する](./2024-07-08-GetProperties.md) (`How-To | stable | stale_after: 2027-07-07`) — C#のReflection機能を使い、typeofやGetTypeで取得したTypeオブジェクトからType.GetPropertiesメソッドでクラスのプロパティ一覧を動的取得する方法を解説します。
- [[C#] デコレータパターンを実装する](./2024-07-07-decorator-pattern.md) (`How-To | stable | stale_after: 2027-07-21`) — C#で高階関数を用いて既存の関数をラップし、元の処理を変更せずに前後のログ出力などの振る舞いを追加するデコレータパターンの実装例を解説します。
- [[C#] 任意のコマンドを並列で実行する汎用コマンドを自作する](./2024-06-15-create-parallel-foreach.md) (`How-To | stable | stale_after: 2027-06-15`) — C#(.NET 8)のConcurrentQueueとProcessクラスを組み合わせ、任意の外部コマンドを複数スレッドで並列実行する汎用CLIツールを自作する方法を解説します。
- [[C#] ファイルストリームをUTF16で高速読み書きする](./2024-06-14-stream-read-write-in-utf16.md) (`How-To | stable | stale_after: 2027-06-16`) — C#(.NET 8)のFileStreamとRFC 2781の上位・下位サロゲートペア判定を用いて、UTF-16ファイルを省メモリかつ高速に1文字ずつバイナリ読み書きする実装を解説します。
- [[C#] ファイルストリームをUTF8で高速読み書きする](./2024-06-13-stream-read-write-in-utf8.md) (`How-To | stable | stale_after: 2027-06-16`) — C#(.NET 8)のFileStreamとRFC 3629のUTF-8先頭ビット判定を用いて、巨大ファイルや改行なしテキストを省メモリかつ高速に1文字ずつバイナリ読み書きする方法を解説します。
- [[C#] オブジェクト指向プログラミング](./2016-12-03-OOP-in-Csharp.md) (`Reference | stable | stale_after: 2027-07-30`) — C#におけるクラス定義、コンストラクタ、プロパティ、継承、抽象クラス、インターフェース、ジェネリクス、拡張メソッドなどオブジェクト指向構文を網羅的にまとめます。
