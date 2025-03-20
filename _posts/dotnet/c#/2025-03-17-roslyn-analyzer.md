---
layout:        post
title:         "[C#] Roslyn Analyzerの作成方法・静的解析方法"
date:          2025-03-17
category:      Dotnet
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    true
# sitemap: false
# feed:    false
---

Roslyn Analyzer は、C# や VB.NET のコードを解析し、カスタムルールに基づいた警告やエラーを発生させる静的解析ツールです。
コードの品質向上やリファクタリングの支援に役立ちます。

### Roslyn Analyzer の作成手順

まず、事前準備として「Visual Studio 拡張機能の開発」ワークロードをVisual Studioにインストールしておきます。

<figure>
<img src="{{ site.baseurl }}/media/post/dotnet/csharp/vs-extension-analyzer-1.png" />
<figcaption>Visual Studio 拡張機能の開発のインストール</figcaption>
</figure>

Visual Studio で以下の手順に従って新規プロジェクトを作成します。

1. Visual Studio を開く
2. 「新しいプロジェクトの作成」 をクリック
3. 「Analyzer with Code Fix (.NET Standard)」テンプレートを選択
4. プロジェクト名を入力し、作成

<figure>
<img src="{{ site.baseurl }}/media/post/dotnet/csharp/vs-extension-analyzer-2.png" />
<figcaption>Roslyn Analyzer のプロジェクト作成</figcaption>
</figure>

プロジェクトが作成されると、以下のようにプロジェクトが複数作られます。
一番上のプロジェクトの末尾が「Analyzer」で終わっているものは、構文解析をして警告やエラーを出すことができる構文解析器を作るためのプロジェクトです。

<figure>
<img src="{{ site.baseurl }}/media/post/dotnet/csharp/vs-extension-analyzer-3.png" />
<figcaption>Roslyn Analyzer のフォルダ構成</figcaption>
</figure>

ここから Roslyn Analyzer を作る方法は、MSの公式ドキュメントをご覧ください。

[Roslyn アナライザーを始める方法 - Visual Studio (Windows) \| Microsoft Learn](https://learn.microsoft.com/ja-jp/visualstudio/extensibility/getting-started-with-roslyn-analyzers?view=vs-2022)

<br>

### Roslyn Analyzer による静的解析の実行方法

Analyzer をプロジェクトに追加すると、エディター上でリアルタイムに警告が表示されます。

<figure>
<img src="{{ site.baseurl }}/media/post/dotnet/csharp/vs-extension-analyzer-4.png" />
<figcaption>Roslyn Analyzer の追加</figcaption>
</figure>

以上です。
