---
layout:        post
title:         "[C#] ファイルストリームをUTF8で読み書きする"
date:          2024-06-13
category:      C#
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

この記事では、C# (.NET 8.0) で UTF-8 のファイルを高速に読み書きするときに、ストリーム操作でバイナリ読み書きする方法について説明します。

まず、ファイルをストリームで読み取る場合、読み取った結果得られるものはバイト列です。
今回はUTF-8のファイルのため、RFC 3269 の仕様を読むことで、1文字のエンコード方式は以下のようになっていることがわかります。

| Unicodeのコードポイントの範囲 (16進数) | UTF-8 エンコード形式 (バイナリ記法)
| --------------------+---------------------------------------------
| 0000 0000 〜 0000 007F | 0xxxxxxx
| 0000 0080 〜 0000 07FF | 110xxxxx 10xxxxxx
| 0000 0800 〜 0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
| 0001 0000 〜 0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx

そのため、ファイル読み取り時の作戦としては、まず1バイトを読み取り、その先頭ビットがどのようになっているかを確認することで、残り何バイト読み取れば1文字が完成するのかを判定することができます。

- 先頭ビットが0のとき、すでに1文字（1バイト）の読み取りを完了とする
- 先頭ビットが10のとき、1文字の途中のため読み取りエラー
- 先頭ビットが110のとき、残り1バイト読み取ることで、1文字（2バイト）の読み取りが完了する
- 先頭ビットが1110のとき、残り2バイト読み取ることで、1文字（3バイト）の読み取りが完了する
- 先頭ビットが11110のとき、残り3バイト読み取ることで、1文字（4バイト）の読み取りが完了する

実際にプログラムに書き下すと、以下のようになります。

```csharp
using System.Text;

using (var inStream = new FileStream(@"input-utf8.txt", FileMode.Open, FileAccess.Read))
using (var outStream = new FileStream(@"output-utf8.txt", FileMode.Create, FileAccess.Write))
{
    byte[] buffer;
    byte tmpbuffer;
    int readByteCount;
    while (true)
    {
        // --- 1文字読み込み ---

        buffer = new byte[1];
        readByteCount = inStream.Read(buffer, 0, 1);  // 1バイト読み取り
        if (readByteCount == 0) break;  // ファイル終端（EOF）のとき終了
        // UTF-8 の仕様で、最初の1バイトの先頭ビットから、1文字が全体で何バイトで構成されているかが判定できる。
        // 詳細は RFC 3269 を参照ください。
        //
        // 先頭ビットが0のとき
        if ((buffer[0] & 0b10000000) == 0b00000000)
        {
            // すでに1文字読み取り完了したため、追加の読み取りなし
        }
        // 先頭ビットが110のとき
        else if ((buffer[0] & 0b11100000) == 0b11000000)
        {
            // 残りの1バイトを読み取り、1文字の読み取りを完了させる
            tmpbuffer = buffer[0];
            buffer = new byte[2];
            buffer[0] = tmpbuffer;
            readByteCount = inStream.Read(buffer, 1, 1);  // 1バイト追加読み取り
            if (readByteCount == 0) break;  // ファイル終端（EOF）のとき終了
        }
        // 先頭ビットが1110のとき
        else if ((buffer[0] & 0b11110000) == 0b11100000)
        {
            // 残りの2バイトを読み取り、1文字の読み取りを完了させる
            tmpbuffer = buffer[0];
            buffer = new byte[3];
            buffer[0] = tmpbuffer;
            readByteCount = inStream.Read(buffer, 1, 2);  // 2バイト追加読み取り
            if (readByteCount == 0) break;  // ファイル終端（EOF）のとき終了
        }
        // 先頭ビットが11110のとき
        else if ((buffer[0] & 0b11111000) == 0b11110000)
        {
            // 残りの3バイトを読み取り、1文字の読み取りを完了させる
            tmpbuffer = buffer[0];
            buffer = new byte[4];
            buffer[0] = tmpbuffer;
            readByteCount = inStream.Read(buffer, 1, 3);  // 3バイト追加読み取り
            if (readByteCount == 0) break;  // ファイル終端（EOF）のとき終了
        }

        // --- 文字変換処理 ---

        var str = Encoding.UTF8.GetString(buffer);
        Console.WriteLine(str);
        //
        // 特定文字の除外や文字変換の処理などがあればここに書く
        //
        var outbuffer = Encoding.UTF8.GetBytes(str);

        // --- 1文字書き込み ---

        outStream.Write(outbuffer, 0, outbuffer.Length);
    }
}
```

1行ずつ読む方法には他にも ReadLines() メソッドなどもありますが、改行が存在しないファイルや、1行が非常に膨大なデータを持っている場合などは、ストリーム操作でファイルの読み書きを行うことで、メモリ空間を節約することができ、高速なファイル読み書きを実現することができます。

以上です。

### 参考文献

- [RFC 3629 - UTF-8, a transformation format of ISO 10646](https://datatracker.ietf.org/doc/html/rfc3629)
- [unicode.scarfboy.com (テスト用に1〜4バイトの様々なUTF8文字を調べるときに便利なサイト)](https://unicode.scarfboy.com/)
