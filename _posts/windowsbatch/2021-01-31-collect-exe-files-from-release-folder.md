---
layout:        post
title:         "[Windows] 任意の階層にある全てのReleaseフォルダからexeを集めるコマンド"
date:          2021-01-31
category:      WindowsBatch
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Visual Studio でコンパイルすると、デバッグ時は obj/Debug、リリース時は obj/Release フォルダの中に成果物の exe や dll が作成されます。
最終的に出荷媒体を作るときは、Releaseフォルダ内の exe を集めることになりますが、バッチコマンドで集める方法について説明します。

結論としては、現在のフォルダ以下の全ての Release フォルダから exe を集めるには、次のバッチファイルを実行します。

```batch
for /r /d %%a in (*Release) do xcopy /y %%a\*.exe .\bin
```

for の `/r` オプションは現在のフォルダ以下の全てのフォルダを探索します。
また、`/d` オプションは、セット（inの右項）にワイルドカードを含むときはディレクトリを探索するようになります。
for の変数 `%%a` には Release フォルダまでのパスが格納されるので、`%%a\*.exe` を展開すると Release 内の exe ファイルを見つけることができます。
最後に xcopy で exe を出荷媒体の保存先（上の例ではbin）にコピーします。
これで、Batchファイルで任意の階層にある全てのReleaseフォルダからexeを集めることができるようになります。

指定のフォルダ下の exe を収集したい場合は、`/r パス` を指定します。

```batch
for /r C:\path\to\folder /d %%a in (*Release) do xcopy /y %%a\*.exe .\bin
```

#### 注意点

上記のコマンドを Windows のコンソールで直接実行する場合は、`%%a` を `%a` に置き換えてから実行してください。

#### 補足

以下 for コマンドのオプション /d と /r の説明です。


```
FOR /D %変数 IN (セット) DO コマンド [コマンド パラメーター]

    セットがワイルドカードを含む場合は、ファイル名ではなくディレクトリ名
    の一致を指定します。

FOR /R [[ドライブ:]パス] %変数 IN (セット) DO コマンド [コマンド パラメーター]

    [ドライブ:]パスから始めて、ツリーの各ディレクトリで FOR 文を実行し
    ます。/R の後にディレクトリが指定されていない場合は、現在の
    ディレクトリが使用されます。セットが単一のピリオド (.) である場合は、
    ディレクトリ ツリーの列挙だけを行います。
```

以上です。

#### 参考文献

[windows - 「指定ディレクトリ」内の「任意の階層」にある「指定ディレクトリ名」内にある全ファイルを抽出したい - スタック・オーバーフロー](https://ja.stackoverflow.com/questions/60797/%e6%8c%87%e5%ae%9a%e3%83%87%e3%82%a3%e3%83%ac%e3%82%af%e3%83%88%e3%83%aa-%e5%86%85%e3%81%ae-%e4%bb%bb%e6%84%8f%e3%81%ae%e9%9a%8e%e5%b1%a4-%e3%81%ab%e3%81%82%e3%82%8b-%e6%8c%87%e5%ae%9a%e3%83%87%e3%82%a3%e3%83%ac%e3%82%af%e3%83%88%e3%83%aa%e5%90%8d-%e5%86%85%e3%81%ab%e3%81%82%e3%82%8b%e5%85%a8%e3%83%95%e3%82%a1%e3%82%a4%e3%83%ab%e3%82%92%e6%8a%bd%e5%87%ba%e3%81%97%e3%81%9f%e3%81%84)

