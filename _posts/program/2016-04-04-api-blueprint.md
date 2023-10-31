---
layout:        post
title:         "API Blueprint の書き方"
date:          2016-04-04
category:      Program
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from: /misc/api-blueprint
comments:      false
published:     true
---

[API Blueprint](https://apiblueprint.org/) とは、API設計の形式的な書き方のことで、Markdownで書くことができます。


特徴
-----

API Blueprintを使うメリットは次のようなものがあります。

- Web APIの設計書のテンプレートとして使える
- Markdownで書けるため、GithubのREADME.mdなどに配置できる
- API Blueprintからモックサーバを作るツールを使えば、開発の一部を自動化させることができる

ではAPI Blueprintの書き方を見ていきましょう。


API Blueprintの簡単な例
----------------------

次の例は、`/message` にGETリクエストを送ったときの振る舞いを定義したものです。

    FORMAT: 1A

    # GET /message
    + Response 200 (text/plain)

            Hello World!


先頭にあるメタデータ `FORMAT: 1A` はAPI Blueprintのバージョンを表しています。
レスポンスの文字列はコードとして表示するために、リスティングのインデントに加えて
コード挿入のインデントが入るため、インデントはスペース8つ（もしくはタブ2つ）になることに注意してください。

次に、１つのリソースに対して複数のアクション（GETやPOST）が存在する場合の書き方を見ていきます。


リソースに対するアクションが複数の場合
--------------------------------

次の例は、`/message` にGETリクエストを送ったときとPOSTリクエストを送ったときの振る舞いを定義したものです。

    # /message
    リソースの説明をここに書く...

    ## GET
    説明をここに書く...

    + Response 200 (text/plain)

            Hello World!

    ## PUT
    説明をここに書く...

    + Request (text/plain)

            All your base are belong to us.

    + Response 204


1つのリソースに対して複数のアクションが存在する場合は、
1つ目のレベルにリソース、2つ目のレベルにアクション名を書きます。


リソースとアクションに概要を加える
------------------------------

このリソースやアクションは何のために使われているのかを、タイトルの中で説明することもできます。

    # メッセージ [/message]
    リソースの説明をここに書く...

    ## メッセージの取得 [GET]
    説明をここに書く...

    + Response 200 (text/plain)

            Hello World!

    ## メッセージの更新 [PUT]
    説明をここに書く...

    + Request (text/plain)

            All your base are belong to us.

    + Response 204


リソースやアクションに利用目的を加えるときは `# 説明 [リソース名]` のように
リソースやアクション名をブラケット`[]`で囲みます。
リソースやアクションの利用目的をタイトルの中で簡単に説明することで、ドキュメントが読みやすくなります。


リソースのグループ化
-----------------

関係のあるリソースを一つのセクションでまとめることも可能です。

    # メッセージ関係

    ## メッセージ [/message]
    ### メッセージの取得 [GET]
    ### メッセージの更新 [PUT]
    ...

    # ユーザー関係

    ## ユーザ [/user]
    ### ユーザ情報の取得 [GET]
    ### ユーザ情報の更新 [PUT]
    ...

構造は、1つ目のレベルでリソース群の名前、2つ目のレベルでリソース名、3つ目のレベルでアクション名
といった感じでリソース群をセクションごとにまとめることもできます。


レスポンスの書き方（Response）
--------------------------

アクションのレスポンスの説明は、`Response code (data/type)` と記述します。
ここでの`data/type`はリクエストを返すときのヘッダで、`Content-Type`に指定されたものとなります。

以下の例は、

- `/message`にGETリクエストを送ったときのレスポンスは
    - ヘッダには `Content-Type: text/plain`
    - ボディには「Hello World!」という文字列
    - レスポンスコードは`200`

というAPIを定義したものです。

    # GET /message
    説明をここに書く...

    + Response 200 (text/plain)

            Hello World!


レスポンスがヘッダも含む場合はインデントを一つ下げて
`Headers`と`Body`のリストを作り、その中に内容を書きます。

次の例は、

- `/message`にGETリクエストを送ったときのレスポンスは
    - ヘッダには `Content-Type: application/json` と `X-My-Message-Header: 42`
    - ボディには「{ "message": "Hello World!" }」 というJSON
    - レスポンスコードは`200`

というAPIを表したものです。

    # GET /message
    説明をここに書く...

    + Response 200 (application/json)

        + Headers

                X-My-Message-Header: 42

        + Body

                { "message": "Hello World!" }



リクエストの書き方（Request）
------------------------

アクションのリクエストの説明は `Request (data/type)` と記述します。
ここでの`data/type`はリクエストを送るときのヘッダで`Content-Type`に指定されたものとなります。

以下の例は、

- `/message`に送るPUTリクエストの内容は
    - ヘッダには `Content-Type: text/plain`
    - ボディには「All your base are belong to us.」という文字列
- `/message`にPUTリクエストを送ったときのレスポンスは
    - レスポンスコードは`204`

というAPIを表したものです。

    # PUT /message
    説明をここに書く...

    + Request (text/plain)

            All your base are belong to us.

    + Response 204


リクエストのときもレスポンスのときと同様に、ヘッダを含む場合はインデントを一つ下げて
`Headers`と`Body`のリストを作り、その中に内容を書きます。

次の例は、

- `/message`に送るGETリクエストの内容は
    - ヘッダには `Accept: application/json`
- `/message`にGETリクエストを送ったときのレスポンスは
    - ヘッダには `X-My-Message-Header: 42`
    - ボディには「{ "message": "Hello World!" }」 というJSON
    - レスポンスコードは`200`

というAPIを表したものです。

    # GET /message
    説明をここに書く...

    + Request JSON Message

        + Headers

                Accept: application/json

    + Response 200 (application/json)

        + Headers

                X-My-Message-Header: 42

        + Body

                { "message": "Hello World!" }


リクエストにパラメータを含む場合（Parameters）
---------------------------------------

リクエストにURIテンプレート変数を含む場合は`Parameters`を説明に加えます。

    # GET /message/{id}

    + Parameters

        + id: 1 (number) - メッセージの識別番号

    + Response 200 (application/json)

            {
              "id": 1,
              "message": "Hello World!"
            }

-----

リクエストにURLパラメータを含む場合も`Parameters`を使います。

    # GET /messages{?limit}

    + Parameters

        + limit (number, optional) - 対象となるメッセージの最大数
            + Default: `20`

    + Response 200 (application/json)

            [
              {
                "id": 1,
                "message": "Hello World!"
              },
              {
                "id": 2,
                "message": "Time is an illusion. Lunchtime doubly so."
              },
              {
                "id": 3,
                "message": "So long, and thanks for all the fish."
              }
            ]


POSTパラメータやレスポンスの内容の説明をする（Attributes）
--------------------------------------------------

POSTリクエストなどでデータを送るときのパラメータを説明する場合は、`Attributes`を使います。

次の例は、

- 送るPOSTリクエストの内容は
    - ヘッダには `Content-Type: application/json` または `Content-Type: application/yaml`
    - パラメータは `message`と`author`

というAPIを表したものです。

    ## Create a Post [POST]

    + Attributes
        + message (string) - The blog post article
        + author: john@appleseed.com (string) - Author of the blog post

    + Request (application/json)

    + Request (application/yaml)

    + Response 201


レスポンスがJSON形式（またはXMLなど）のときに
レスポンスのそれぞれの値を説明する場合は、`Attributes`をResponseの説明に追加します。

    ## GET /coupons/{id}
    与えられたIDのクーポン券を取得します

    + Response 200 (application/json)

        + Attributes (object)
            + id: 250FF (string, required)
            + created: 1415203908 (number) - タイムスタンプ
            + percent_off: 25 (number)

                クーポン券の割引率。1から100の範囲の整数が設定される。
                複数行にわたる説明はこのように書く
                ...

        + Body

                {
                    "id": "250FF",
                    "created": 1415203908,
                    "percent_off": 25
                }


その他
----------

API Blueprintにおける、さらに詳しい説明は公式レポジトリ[apiaryio/api-blueprint](https://github.com/apiaryio/api-blueprint)
の Trutorial.md や example/ の中にありますのでそちらを参照してください。
