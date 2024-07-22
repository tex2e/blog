---
layout:        post
title:         "[VB.NET] 文字列を指定のバイト数で切り取る"
date:          2021-03-10
category:      VB.NET
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

文字列を指定のバイト数で切り取る関数をVB.NETで作る方法について説明します。

指定のバイト数で切り取る関数は以下のように書きます。

```vb
Imports System

Module VBModule

    Sub Main()

        Console.WriteLine(CutStrByteLen("ABCあいう", 4))  '=> ABC
        Console.WriteLine(CutStrByteLen("ABCあいう", 8))  '=> ABCあい
        Console.WriteLine(CutStrByteLen("ABCあいう", 9))  '=> ABCあいう

    End Sub

    '文字列を指定のバイト数にカットする関数（漢字分断回避あり）
    Private Function CutStrByteLen(ByVal strInput As String, ByVal intLen As Integer) As String
        Dim sjis As System.Text.Encoding = System.Text.Encoding.GetEncoding("Shift_JIS")
        Dim tempLen As Integer = sjis.GetByteCount(strInput)
        ' 引数チェック
        If intLen < 0 OrElse strInput.Length <= 0 Then 
            Return ""
        End If
        ' 文字列が指定のバイト数未満の場合は、入力をそのまま返す
        If tempLen <= intLen Then
            Return strInput
        End If
        Dim bytTemp As Byte() = sjis.GetBytes(strInput)
        Dim strTemp As String = sjis.GetString(bytTemp, 0, intLen)
        ' 末尾の漢字が分断されたらバイト数-1で切り取る (VB2005="・"、.NET2003=NullChar）
        If strTemp.EndsWith(ControlChars.NullChar) OrElse strTemp.EndsWith("・") Then
            strTemp = sjis.GetString(bytTemp, 0, intLen - 1)
        End If
        Return strTemp
    End Function

End Module
```

処理のおおまかな流れは以下の通りです。

1. 入力文字列のバイト長を取得
2. 不正な引数が入力されたときは空文字を返す
3. 文字列が指定のバイト数未満の場合は、入力をそのまま返す
4. バイト数で文字列を切り取る
5. 末尾の漢字が分断されたら、バイト長を1減らしてから切り取る
6. 切り取った文字列を返す

<!--
# MacOSでのコンパイル方法
vbnc test.vb && echo "-----" && mono test.exe
-->

以上です。
