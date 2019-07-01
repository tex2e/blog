# Mako's Blog

Mako(tex2e)の技術系ブログです。

[tex2e.github.io/blog/](https://tex2e.github.io/blog/)

- Jekyll Theme: **jekyllDecent**
- syntax highlighter: **prism.js**

#### 新規記事の作成

./new.sh を使って新規記事の作成をします。
カテゴリ名は /_posts 以下のディレクトリ名にします（例えば python）。
カテゴリ名の最初を大文字にしたものが、記事に埋め込まれます（記事のカテゴリは Python となる）。

```
./new.sh <category> <postname>
```

- 公開したくない記事は、ページ設定で `published: false` を追加します。
- ドラフトとして公開したい記事（記事一覧やsitemap.xmlにはリンクがないが、閲覧可能な状態）は、ページ設定で `sitemap: false` と `draft: true` を追加します。

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


-----

## [Prism](http://prismjs.com/)

> Prism is a lightweight, robust, elegant syntax highlighting library.
> It's a spin-off project from [Dabblet](http://dabblet.com/).
>
> You can learn more on http://prismjs.com/.
>
> Why another syntax highlighter?:
> http://lea.verou.me/2012/07/introducing-prism-an-awesome-new-syntax-highlighter/#more-1841
