---
layout:        post
title:         "[C#] 任意のコマンドを並列で実行する汎用コマンドを自作する"
date:          2024-06-15
category:      Dotnet
cover:         /assets/cover14.jpg
redirect_from: /c%23/create-parallel-foreach
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

この記事では、C# (.NET 8.0) で任意のコマンド (MS-DOSコマンド) を複数スレッドで並列実行するための自作コマンドを作る方法について説明します。

### 複数スレッドの並列起動

スレッドを並列起動するとき、注意しなければいけないのは、共通のメンバ変数やグローバルにアクセスすると、取得するタイミングで他のスレッドと競合する可能性があります。
そのため、複数スレッドから共有の変数にアクセスするとき、その変数はスレッドセーフなキュー (ConcurrentQueue) にしておく必要があります。

```csharp
ConcurrentQueue<CommandParam> commandQueue = new();
foreach (var line in File.ReadLines(inputFile))
{
    var param = line.Trim();
    // コマンドの「{}」の部分に入力ファイルの各行の内容を埋め込んで実行するコマンドを作成する
    var commandEnbedded = templateCommand.Replace("{}", param);
    commandQueue.Enqueue(commandEnbedded);
}

// 複数スレッドを並列で起動する
Thread[] threads = new Thread[processCount];
for (int i = 0; i < processCount; i++)
{
    threads[i] = new Thread(ExecuteCommand);  // ExecuteCommandメソッド内でキューから実行コマンドを取得して実行していく
    threads[i].Start();
}

// 全てのスレッドが終了するまで待機する
foreach (Thread thread in threads)
{
    thread.Join();
}
```

### コマンドの実行

C#では Process クラスを使うことで外部コマンドを実行することができます。
以下はキューから1つコマンドを取り出して実行する場合のサンプルです。

```csharp
bool result = commandQueue.TryDequeue(out CommandParam? commandParam);
if (!result) continue;
if (commandParam == null) continue;

var command = commandParam.Command;
var param = commandParam.Param;

// プロセスの作成
var process = new Process();
// 実行ファイル名
process.StartInfo.FileName = "cmd.exe";
// 実行時の引数
process.StartInfo.Arguments = $"/c {command}";
// OSのシェル（コマンドプロンプト）を使用しない
process.StartInfo.UseShellExecute = false;
// 標準出力をリダイレクトする
process.StartInfo.RedirectStandardOutput = true;

// プロセスの開始
process.Start();

// 待機する前にリダイレクト先を設定することで、バッファが埋まることによるデッドロックを回避できる
// 詳細：https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.process.standardoutput?view=net-8.0
string strOutput = process.StandardOutput.ReadToEnd();

// プロセス終了まで待機
process.WaitForExit();

if (process.ExitCode == 0)
{
    // 正常終了
    Console.WriteLine($"[+] ProecssId={Thread.CurrentThread.ManagedThreadId}: {strOutput}");
}
else
{
    // 異常終了
    Console.WriteLine($"[-] ProcessId={Thread.CurrentThread.ManagedThreadId}: {strOutput}");
}
```

注意点として、`process.WaitForExit()` を実行する前に必ず、process.StandardOutput（標準出力）のリダイレクト先を設定してください。
この設定をしない状態で、プロセスが終了するのを待機すると、コマンドの標準出力がバッファを埋めてしまったときに、バッファが吐き出されるまでコマンドの実行が中断されてしまうため、子プロセスと親プロセスの両方が待ち状態になりデッドロックが発生してしまいます。
その辺の注意事項の説明が[Microsoftの公式ドキュメント](https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.process.standardoutput?view=net-8.0)には記載されています。


### コマンドの全体

最後に、ここまで説明してきたプログラム (.NET 8.0) の全体と使い方について以下の公開します。

使い方は -p で並列数、-i がパラメータ一覧、-c がテンプレート化されたコマンドで、例えば `ping {}` と書くと、-i で指定したファイルの各行の内容が埋め込まれて、`ping 192.168.11.1`、`ping 192.168.11.2` ... が並列で実行されていきます。

```cmd
echo 192.168.11.1 > ip-list.txt
echo 192.168.11.2 >> ip-list.txt
echo 192.168.11.3 >> ip-list.txt
echo 192.168.11.4 >> ip-list.txt
echo 192.168.11.5 >> ip-list.txt
ParallelForeach.exe -p 3 -i ip-list.txt -c "ping {}"
```

C# のプログラム（.NET 8.0）は以下のようになっています。

```csharp
using System.Collections.Concurrent;
using System.Diagnostics;

string inputFile = "";
string templateCommand = "";
int processCount = Environment.ProcessorCount;

void ParseArgs()
{
    string[] args = Environment.GetCommandLineArgs();
    string argInputFile = "";
    string argTemplateCommand = "";
    string argProcessCount = "1";

    for (int i = 0; i < args.Length; i++)
    {
        switch (args[i])
        {
            case "-i":  // 入力ファイル
                i++;
                if (i < args.Length) argInputFile = args[i];
                break;
            case "-c":  // 実行コマンドのテンプレート
                i++;
                if (i < args.Length) argTemplateCommand = args[i];
                break;
            case "-p":  // プロセス数
                i++;
                if (i < args.Length) argProcessCount = args[i];
                break;
        }
    }

    inputFile = argInputFile;
    templateCommand = argTemplateCommand;
    _ = int.TryParse(argProcessCount, out processCount);

    if (string.IsNullOrEmpty(inputFile))
        throw new ArgumentException("入力ファイルを指定してください！");
    if (!File.Exists(inputFile))
        throw new ArgumentException("入力ファイルが存在しません！");
    if (string.IsNullOrEmpty(templateCommand))
        throw new ArgumentException("実行コマンドを指定してください！");
    if (!string.IsNullOrEmpty(argProcessCount) && !int.TryParse(argProcessCount, out int tmpProcessCount))
        throw new ArgumentException("プロセス数を指定してください！");
}

ParseArgs();

// 実行するコマンドをキューにためる
ConcurrentQueue<CommandParam> commandQueue = new();
foreach (var line in File.ReadLines(inputFile))
{
    var param = line.Trim();
    if (param.Length == 0) continue;
    // 「{}」の部分に引数を埋め込んで実行するコマンドを作成する
    var commandEnbedded = templateCommand.Replace("{}", param);
    commandQueue.Enqueue(new CommandParam()
    {
        Command = commandEnbedded,
        Param = param,
    });
}

// 複数スレッドを並列で起動する
Thread[] threads = new Thread[processCount];
for (int i = 0; i < processCount; i++)
{
    threads[i] = new Thread(ExecuteCommand);
    threads[i].Start();
}

// 全てのスレッドが終了するまで待機する
foreach (Thread thread in threads)
{
    thread.Join();
}

// コマンド実行処理
void ExecuteCommand()
{
    try
    {
        while (!commandQueue.IsEmpty)
        {
            bool result = commandQueue.TryDequeue(out CommandParam? commandParam);
            if (!result) continue;
            if (commandParam == null) continue;

            var command = commandParam.Command;
            var param = commandParam.Param;

            // プロセスの作成
            var process = new Process();
            // 実行ファイル名
            process.StartInfo.FileName = "cmd.exe";
            // 実行時の引数
            process.StartInfo.Arguments = $"/c {command}";
            // OSのシェル（コマンドプロンプト）を使用しない
            process.StartInfo.UseShellExecute = false;
            // 標準出力をリダイレクトする
            process.StartInfo.RedirectStandardOutput = true;

            // プロセスの開始
            process.Start();

            // 待機する前にリダイレクト先を設定することで、バッファが埋まることによるデッドロックを回避できる
            // 詳細：https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.process.standardoutput?view=net-8.0
            string strOutput = process.StandardOutput.ReadToEnd();

            // プロセス終了まで待機
            process.WaitForExit();

            if (process.ExitCode == 0)
            {
                // 正常終了
                Console.WriteLine($"[+] ProecssId={Thread.CurrentThread.ManagedThreadId}: {strOutput}");
            }
            else
            {
                // 異常終了
                Console.WriteLine($"[-] ProcessId={Thread.CurrentThread.ManagedThreadId}: {strOutput}");
            }
        }
    }
    catch (Exception ex)
    {
        // スレッド内の例外はスレッド内で処理すること
        Console.WriteLine(ex.ToString());
    }
}

class CommandParam
{
    public string Command { get; set; } = "";
    public string Param { get; set; } = "";
}
```

以上です。


### 参考文献

- [Process クラス (System.Diagnostics) \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/system.diagnostics.process?view=net-8.0)
- [Process.StandardOutput Property (System.Diagnostics) \| Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.process.standardoutput?view=net-8.0)
