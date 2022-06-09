---
layout:        post
title:         "[VB.NET] Proxy経由でPOSTリクエストを送信する"
date:          2022-06-08
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

VB.NETでProxyを経由してPOSTリクエストを送信する方法について説明します。
検証環境は .NET Framework 3.5 です。
以下は、ローカルで起動しているプロキシサーバを経由して、HTTPサーバにjsonデータを送信する例です。

```vb
Module Module1

    Sub Main()
        Dim webreq As System.Net.HttpWebRequest =
            CType(System.Net.WebRequest.Create("http://www.example.local/test"), System.Net.HttpWebRequest)

        ' プロキシの設定
        Dim proxy As New System.Net.WebProxy("http://localhost:8000", False)
        webreq.Proxy = proxy

        ' POSTリクエストヘッダの設定
        webreq.Method = "POST"
        webreq.ContentType = "application/json"

        ' POSTリクエストボディの設定
        Dim postData As String = "{""key1"":""value1"",""key2"":""value2""}"
        Dim postDataBytes As Byte() = System.Text.Encoding.ASCII.GetBytes(postData)
        webreq.ContentLength = postDataBytes.Length
        Dim reqStream As IO.Stream = webreq.GetRequestStream()
        reqStream.Write(postDataBytes, 0, postDataBytes.Length)
        reqStream.Close()

        ' レスポンスの取得
        Dim webres As System.Net.HttpWebResponse =
            CType(webreq.GetResponse, System.Net.HttpWebResponse)
        Dim st As System.IO.Stream = webres.GetResponseStream()
        Dim sr As New System.IO.StreamReader(st)
        Console.WriteLine(sr.ReadToEnd())
        sr.Close()
        st.Close()

        'Console.ReadLine()
    End Sub

End Module
```

注意点の1つ目は設定する順番で、.Proxy の設定をしてから .GetRequestStream() を呼び出す必要があります。
GetRequestStream() 後にWebProxyオブジェクトを設定すると、「System.InvalidOperationException: 要求が送信された後にこの操作を実行することはできません。」とエラーが表示されます [^1]。

2つ目は、プロキシとHTTPサーバを同じlocalhostの別ポートで起動していて、プロキシと接続先のURLのドメインがどちらも「localhost」のとき、ローカルプロキシバイパス [^1] が発生してしまいます。
つまり、プロキシを経由しないで直接HTTPサーバに通信してしまいます。
検証などで必ずプロキシを経由させたいときは、C:\Windows\System32\drivers\etc\hosts に `127.0.0.1 www.example.local` などとドメイン名を設定し、接続先のHTTPサーバのドメインを www.example.local に変えることで、ローカルの環境でローカルプロキシバイパスを回避することができます。

以上です。

---

[^1]: [https://docs.microsoft.com/ja-jp/dotnet/api/system.net.httpwebrequest.proxy?view=netframework-3.5](https://docs.microsoft.com/ja-jp/dotnet/api/system.net.httpwebrequest.proxy?view=netframework-3.5)
