# Mako's Blog

Mako(tex2e)の技術系ブログです。

[tex2e.github.io/blog/](https://tex2e.github.io/blog/)

- Framework: [**Jekyll**](https://jekyllrb.com/)
- Theme: [**jekyllDecent**](https://github.com/jwillmer/jekyllDecent)
- Markdown: [**kramdown**](https://kramdown.gettalong.org/)
- Template: [**Liquid**](https://shopify.github.io/liquid/)
- Syntax Highlighter: [**Prism**](http://prismjs.com/)
- Math Engine: [**KaTeX**](https://katex.org/)

#### 新規記事の作成

./new.sh を使って新規記事の作成をします。
カテゴリ名は /_posts 以下のディレクトリ名にします（例 : python）。
カテゴリ名の最初を大文字にしたものが、記事に埋め込まれます（例 : 記事のカテゴリは Python）。

```
./new.sh <category> <postname>
```

ページ設定：
- `cover: /assets/cover1.jpg` : ヘッダー画像
- `redirect_from: /PATH` : 変更元のPATHからこのページにリダイレクトする
- `comments: true` : Disqusによるコメント投稿を有効にする
- `published: false` : ページを非公開にする
- `latex: true` : 数式レンダリングを許可する
- `sitemap: false` : sitemap.xmlにリンクを追加しない (検索エンジンから少しだけ見つかりにくくなる)
- `feed: false` : feed.xmlにリンクを追加しない (RSSで更新情報を知らせない)

#### 固定ページの作成

/_pages 以下にmdファイルを作成します。
ページ設定で `permalink: /PATH` と書くことで、そのPATHの場所にページを配置することができます。

#### サーバの起動

./server.sh を使ってサーバの起動をします。
Rubyを新しくインストールした際は `bundle install` する必要があります。

```
./server.sh
```

開発用のオプションとして、次を有効にしています。

- `--incremental` (`-I`) : 差分だけをビルドするので、ビルド時間が高速化されます
- `--livereload` : ページが編集されたら自動的に更新します (ライブリロード)
- `--future` : 公開の日付が未来になっている記事も公開します

また、インクリメンタルビルドが有効になっている関係で、時々サイト生成時にリンクが正しくない場合が発生します。その時に、強制的に再ビルドさせたい場合は、次のコマンドを入力します。

```
./server.sh rebuild
```

サブコマンドは rebuild の代わりに re でも実行できます。

```
./server.sh re
```

#### aliase

blogのディレクトリに移動して、エディタを開き、ブラウザでページを開いて、サーバを立ち上げる一連の処理をする `blog` コマンド

```
alias blog="cd ~/path/to/blog; atom .; open http://localhost:4000/blog/; ./server.sh &"
```

-----

## [jekyllDecent](https://github.com/jwillmer/jekyllDecent)

> [![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](#license)
>
> This is a blog template for a static site generator named [Jekyll](https://jekyllrb.com/docs/home/)
> based on a [Ghost](https://ghost.org) template named [Decent](https://github.com/serenader2014/decent).
>
> Installation instructions, features, previews and more can be found in the
> **[GitHub generated blog](http://jwillmer.github.io/jekyllDecent)**.
> This blog is automatically generated out of the source code in the `gh-pages` branch.
> If you like to see the theme in production have a look at [jwillmer.de](http://jwillmer.de).
>
> [![](./media/img/2016-06-08-Readme-front-page-previewe.jpg)](http://jwillmer.github.io/jekyllDecent)
