---
layout:        post
title:         "[C#] tail -f コマンドをC#プログラムで自作する"
date:          2025-05-25
category:      Dotnet
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ログファイルの監視に便利な「tail -f」コマンドはLinuxやmacOSでは有名ですが、Windows環境や独自のアプリケーションに組み込みたい場合は自作する必要があります。
この記事では、C#を使ってtail -fのようにリアルタイムでファイルの末尾を監視し続けるプログラムについて解説します。

## tail -f の実装例

以下のプログラムは指定したファイル（例: sample.log）の末尾に追加される新しい行を検知し、リアルタイムでコンソールに出力します。
また、Ctrl+Cで終了できるようになっています。

```cs
using System;
using System.IO;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

class TailFile
{
    public static async Task TailAsync(string filePath, CancellationToken cancellationToken)
    {
        using var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
        using var reader = new StreamReader(stream, Encoding.UTF8);

        // ファイルの末尾にシーク
        stream.Seek(0, SeekOrigin.End);

        while (!cancellationToken.IsCancellationRequested)
        {
            string? line = await reader.ReadLineAsync();

            if (line != null)
            {
                Console.WriteLine(line);
            }
            else
            {
                // データがなければ少し待って再度チェック
                await Task.Delay(500, cancellationToken);
            }
        }
    }

    static async Task Main(string[] args)
    {
        string filePath = "sample.log"; // 監視するファイルのパス
        using var cts = new CancellationTokenSource();

        Console.CancelKeyPress += (s, e) =>
        {
            e.Cancel = true;
            cts.Cancel();
        };

        Console.WriteLine("ファイルのtailを開始します。Ctrl+Cで終了します。");
        await TailAsync(filePath, cts.Token);
    }
}
```

いくつか重要な部分について補足説明します。

- `Console.CancelKeyPress` はコンソール上で Ctrl+C を入力したときに呼び出されるイベントです。
  キャンセル要求を受け付けるためのトークンに対してキャンセルが発生したことを設定するために使用します。
- `async Task TailAsync(filePath, cancellationToken)` メソッドは、定期的にファイルの末尾から行を取得できるかチェックします。
- `StreamReader#Seek(0, SeekOrigin.End)` メソッドは対象のStreamの末尾に移動します。今回のストリームはファイルのため、ファイルの末尾に移動します。
- CPU負荷を軽減するために、行がまだ追加されていない場合は500ミリ秒待機して再度チェックします。

以上です。
