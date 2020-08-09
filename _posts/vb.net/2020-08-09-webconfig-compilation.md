---
layout:        post
title:         "ASP.NETでコンパイルとDLL読み込みを高速化する"
date:          2020-08-09
category:      VB.NET
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

ASP.NETでコンパイルとDLL読み込みを高速化する方法についてです。
やり方は web.config を開いて system.web > compilation の設定を変更します。
デフォルトの設定は以下の通りです。

```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <system.web>
    <compilation defaultLanguage="vb" debug="true">
      <assemblies>
        ...
      </assemblies>
    </compilation>
  </system.web>
</configuration>
```

開発時に画面の読み込み速度を高速化するためのcompilationの設定として、次の2つの設定を追加します。

- `optimizeCompilations=[true|false]` : 動的コンパイルの設定。falseの場合は、ファイルが変更されたときにサイト全体を再コンパイルする。サイトが大きいほどコンパイル＆DLL読み込みに時間がかかるので、trueにして変更したファイルのみを再コンパイルするようにすると、画面読み込みまでの時間を高速化できる
- `batch=[true|false]` : バッチモードの設定。trueの場合、初回アクセス時に発生するコンパイルをなくすために事前コンパイルする。2回目以降のアクセスは高速化されるが、コードを頻繁に変更する開発時はfalseにしておくと、画面読み込みまでの時間を高速化できる


```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <system.web>
    <compilation defaultLanguage="vb" debug="true"
                 batch="false" optimizeCompilations="true">
      <assemblies>
        ...
      </assemblies>
    </compilation>
  </system.web>
</configuration>
```

上記の設定によって画面読み込みまでの時間は大幅に短縮されます。

なお、動的コンパイルで生成したDLLはIIS内にキャッシュされるため、IISをリスタートしてしまうと、コンパイル＆DLL読み込みが発生して、初回ページ読み込みは時間がかかってしまいます。

以上です。

#### 参考

- [compilation Element (ASP.NET Settings Schema) \| Microsoft Docs](https://docs.microsoft.com/en-us/previous-versions/dotnet/netframework-4.0/s10awwz0%28v=vs.100%29?redirectedfrom=MSDN)
