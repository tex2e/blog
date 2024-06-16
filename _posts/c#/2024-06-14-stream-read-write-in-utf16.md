---
layout:        post
title:         "[C#] ファイルストリームをUTF16で高速読み書きする"
date:          2024-06-14
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

この記事では、C# (.NET 8.0) で UTF-16 のファイルを高速に読み書きするときに、ストリーム操作でバイナリ読み書きする方法について説明します。

まず、ファイルをストリームで読み取る場合、読み取った結果得られるものはバイト列です。
今回はUTF-16のファイルのため、RFC 2781 の仕様を読むことで、1文字のエンコード方式は以下のようになっていることがわかります。

- その文字のUnicodeのコードポイントが 0x10000 未満のとき
    - 16ビット（2バイト）で表現される
- その文字のUnicodeののコードポイントが 0x10000 以上のとき
    - 32ビット（4バイト）で表現される
    - 最初の2バイトは**上位サロゲート**と呼ばれ、Unicodeコードポイントの範囲は U+D800 〜 U+DBFF です。
    - 残りの2バイトは**下位サロゲート**と呼ばれ、Unicodeコードポイントの範囲は U+DC00 〜 U+DFFF です。

そのため、ファイル読み取り時の作戦としては、まず2バイトを読み取り、それが上位サロゲートかどうかで1文字が完成しているかどうかわかります。

- 先頭の2バイトが上位サロゲートではないとき、すでに1文字（2バイト）の読み取りを完了とする
- 先頭の2バイトが上位サロゲートのとき、残り2バイト読み取ることで、1文字（4バイト）の読み取りが完了する

実際にプログラムに書き下すと、以下のようになります。

```csharp
using System.Text;

using (var inStream = new FileStream(@"input-utf16.txt", FileMode.Open, FileAccess.Read))
using (var outStream = new FileStream(@"output-utf16.txt", FileMode.Create, FileAccess.Write))
{
    byte[] buffer;
    byte[] tmpbuffer;
    int readByteCount;
    while (true)
    {
        // --- 1文字読み込み ---

        buffer = new byte[2];
        readByteCount = inStream.Read(buffer, 0, 2);  // 2バイト読み取り
        if (readByteCount == 0) break;  // ファイル終端（EOF）のとき終了
        // UTF-16 の仕様で、最初の2バイトが上位サロゲートかを判定することで、1文字の全体のバイト数（2 or 4バイト）が判定できる。
        // 詳細は RFC 2781 を参照ください。
        //
        // 先頭2バイトが上位サロゲートのとき
        if (IsHighSurrogate(buffer))
        {
            tmpbuffer = new byte[2];
            tmpbuffer[0] = buffer[0];
            tmpbuffer[1] = buffer[1];
            buffer = new byte[4];
            buffer[0] = tmpbuffer[0];
            buffer[1] = tmpbuffer[1];
            // 上位サロゲート、下位サロゲートの順番で格納する。
            readByteCount += inStream.Read(buffer, 2, 2);  // 2byte追加読み取り
        }

        // --- 文字変換処理 ---

        var str = Encoding.Unicode.GetString(buffer);
        Console.WriteLine(str);
        //
        // 特定文字の除外や文字変換の処理などがあればここに書く
        //
        var outbuffer = Encoding.Unicode.GetBytes(str);

        // --- 1文字書き込み ---

        outStream.Write(outbuffer, 0, outbuffer.Length);
    }

}

bool IsHighSurrogate(byte[] input)
{
    if (input == null) return false;
    if (input.Length < 2) return false;
    // UTF-16 LE（リトルエンディアン）のとき
    return (0xD8 <= input[1] && input[1] <= 0xDB);
}
```

1行ずつ読む方法には他にも ReadLines() メソッドなどもありますが、改行が存在しないファイルや、1行が非常に膨大なデータを持っている場合などは、ストリーム操作でファイルの読み書きを行うことで、メモリ空間を節約することができ、高速なファイル読み書きを実現することができます。

以上です。

### 参考文献

- [RFC 2781 - UTF-16, an encoding of ISO 10646](https://datatracker.ietf.org/doc/html/rfc2781)
- [Section 3.8, Surrogates. -- Unicode.org](https://www.unicode.org/versions/Unicode15.1.0/ch03.pdf#G2630)
