---
layout:        post
title:         "NuGetパッケージのキャッシュをクリアする方法"
type:          How-To
description:   "NuGetの最新パッケージが取得できない場合に備え、Visual Studioの設定画面およびdotnet nuget localsコマンドからローカルキャッシュを削除する手順を解説します。"
tags:          [dotnet, nuget, visual-studio, cache]
status:        stable
stale_after:   2029-02-08T00:00:00Z
generated:
  by:          human:tex2e
  at:          2026-02-08T00:11:23Z
date:          2026-02-07
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

csprojの設定で「Version="*"（ワイルドカード）」と指定しても、最新のNuGetパッケージが取得できないときは、NuGetパッケージのキャッシュのクリアを試してみてください。
この記事では、ローカルのNuGetキャッシュのクリア方法について説明します。

### 1. Visual Studioでクリアする方法

Visual StudioからNuGetパッケージのキャッシュをクリアするには、Visual Studioを開いて以下の画面を開きます。

ツール > オプション > NuGet パッケージ マネージャ > 全般

<figure>
<img src="{{ site.baseurl }}/media/post/dotnet/nuget-cache-clear.png" />
<figcaption>NuGet パッケージ マネージャの設定画面</figcaption>
</figure>

全般を開いたら、「すべてのNuGetストレージをクリア」をクリックします。

出力に「NuGet ストレージが yyyy/mm/dd HH:MM:SS でクリアされました」と表示されれば、NuGetパッケージのキャッシュクリア完了です。


### 2. dotnetコマンドでクリアする方法

dotnetコマンドが使える場合は、以下のコマンドを実行して、ローカルのNuGetパッケージのキャッシュを削除してください。

```bash
$ dotnet nuget locals all --clear
```

「NuGet グローバル パッケージ フォルダーをクリア中: C:\Users\USERNAME\.nuget\packages\」と表示されたら、クリア作業が開始されています。
「NuGet ストレージが yyyy/mm/dd HH:MM:SS でクリアされました」と表示されれば、NuGetパッケージのキャッシュクリア完了です。

以上です。
