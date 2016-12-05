---
title: "ブログ内部の構造を改造しました"
date:  2016-09-22
published: false
---

ブログの内部構造を大きく変えたのでそのお話。


なぜ Jekyll を使うのを止めたか
---------------------------

個人的には Jekyll はブログを構築するにはとても良いツールだと思います。
それでも使うのを止めたのは次のような理由からです。

1. ポストを書いておくファイル名は `YYYY-MM-DD-title.md` という指定がある
2. （Jekyllだけの問題ではないが）Markdown の中に HTML を書くという汚いことはしたくない
3. ブログというより、備忘録にしたい

1つ目は、今日の日付もろくに覚えていない私にとって、ファイル名に日付を含めないといけない規則は非常に苦痛でした。
もしかしたら、将来この仕様が変わる可能性がごくわずかに残されていますが、あまり期待はしてません。

2つ目は、Markdown の中に HTML を書きたくないので、独自で Markdown のようなルールを作りました。
という話はあとでします。

3つ目は、言葉通りです。昔やったことをもう一度思い出すときに、ポストが投稿日付順に並んでいると探すのに苦労します。
備忘録として使いたいと考えているので、ポストを投稿日付順にソートして表示する機能などは廃止していく方向で考えています。


新しくなったブログの特徴（利用者視点）
--------------------------------

今回の改造によって変更された「ブログの見た目」は次のようなものがあります。

1. RSSフィードの停止
2. 投稿日付順にソートして表示する機能の廃止
3. feedly にあるようなメニューバー

1つ目の、RSSフィードの停止した理由は、改造を行ったことによってRSSフィードを配信するのが難しくなったからです。
そもそも、このサイトをブログから備忘録にしようとしているので、RSSの有無は大きな問題ではないと考えています。

2つ目の、投稿日付順にソートして表示する機能の廃止は、理由3の「備忘録としての役割」を重視した結果です。

3つ目は、feedly の左側にあるマウスを載せるとぬるぬる動くメニューがとても気に入っていたので、それを再現しました。
feedly ではメニューバーを固定することもできるように pin ボタンがありますが、そこまで再現する予定はないです。


新しくなったブログの特徴（投稿者視点）
--------------------------------

今回の改造によって新しくなった「投稿時の注意点」は次のようなものがあります。

1. ポストを書いておくファイルは全て posts ディレクトリ直下に配置すること
2. ポストを書いておくファイル名は `category-title.md` という形式で作成すること
3. Markdown の中に書ける Haml のような独自ルールの追加

1つ目は、現状では、全てのポストを posts 直下に配置しないと Github API で全てのポストのリストを一度に取得できないからです。

2つ目は、今回のブログ改造の最大の目的である「ファイル名に日付をつけない」の達成結果です。
ファイル名の形式のカテゴリ（category）には任意の文字列を入れることが可能です。
例えば `ruby-open-class.md` と書くと、カテゴリは ruby でタイトルは open-class という風に解釈します。

3つ目の、今回作った独自ルールは以下のような感じです。

    %callout-danger{
        title: "Cross-browser compatibility"
        body: |
            Progress bars use CSS3 transitions and animations to achieve some of their effects.
            These features are not supported in Internet Explorer 9 and below or older versions of Firefox.
            Opera 12 does not support animations.
    }

上のコードを Markdown 内に書くと、独自ルールが適応されて下のようになります。

%callout-danger{
    title: "Cross-browser compatibility"
    body: |
        Progress bars use CSS3 transitions and animations to achieve some of their effects.
        These features are not supported in Internet Explorer 9 and below or older versions of Firefox.
        Opera 12 does not support animations.
}

これは通常の Markdown ではできないことです。

また、`callout-danger` の他にも `callout-default`, `callout-primary`, `callout-success`, `callout-info`, `callout-warning`
を使うことができます。

%callout-default{
    title: "Callout default"
    body: |
        default の書き方は
        ```
        %callout-default{ ... }
        ```
}

%callout-primary{
    title: "Callout primary"
    body: |
        primary の書き方は
        ```
        %callout-primary{ ... }
        ```
}

%callout-success{
    title: "Callout success"
    body: |
        success の書き方は
        ```
        %callout-success{ ... }
        ```
}

%callout-info{
    title: "Callout info"
    body: |
        info の書き方は
        ```
        %callout-info{ ... }
        ```
}

%callout-warning{
    title: "Callout warning"
    body: |
        warning の書き方は
        ```
        %callout-warning{ ... }
        ```
}

現在の段階では、まだソースコードがごちゃごちゃしていて API を策定するほどに至っていないのですが、
将来的には、しっかりとしたドキュメントを置いて、新しいルールの追加が楽にできるようにしていきたいです。


新しくなったブログの特徴（開発者視点）
--------------------------------

今回の改造によって新しくなった「ブログの構造」は次のようなものがあります。

1. ブログ生成ツールを使うのをやめた
2. markdown ファイルをコンパイルして html ファイルを作るのをやめた
3. 代わりに marked.js を使って、その場で markdown から html に変換するようにした
4. ポストの一覧を取得するために、Github API を使って tex2e/blog の posts ディレクトリ下のファイルのリストを受け取るようにした
5. Github API ではファイルの作成日などの情報はないので、ポストの日付順のソートはできなくなった

全てのコードは https://github.com/tex2e/blog に載せてあるので、詳しくはそちらを参照してください。
