# Mako's Blog

Mako(tex2e)の技術系ブログです。

サイト : [tex2e.github.io/blog/](https://tex2e.github.io/blog/)

使用技術：
- Framework: [**Jekyll**](https://jekyllrb.com/)
- Theme: [**jekyllDecent**](https://github.com/jwillmer/jekyllDecent)
- Markdown: [**kramdown**](https://kramdown.gettalong.org/)
- Template: [**Liquid**](https://shopify.github.io/liquid/)
- Syntax Highlighter: [**Prism**](http://prismjs.com/)
- Math Engine: [**KaTeX**](https://katex.org/)

#### 新規記事の作成
./new.sh を使って新規記事の作成をします。
カテゴリ名は /_posts 以下のディレクトリ名にします (例 : python)。
カテゴリ名の最初を大文字にしたものが、記事に埋め込まれます。
```
./new.sh <category> <postname>
```

ページの設定用変数：
- `cover: /assets/cover1.jpg` : ヘッダー画像
- `redirect_from: /PATH` : 変更元のPATHからこのページにリダイレクトする
- `comments: true` : Disqusによるコメント投稿を有効にする
- `published: false` : ページを非公開にする
- `latex: true` : 数式レンダリングを許可する
- `photoswipe: true` : 画像の拡大を有効にする
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

開発用のオプションとして、次を有効にしています：
- `--incremental` (`-I`) : 差分だけをビルドするので、ビルド時間が高速化されます
- `--livereload` : ページが編集されたら自動的にブラウザも更新します (ライブリロード)
- `--future` : 公開の日付が未来になっている記事も公開します

また、インクリメンタルビルドが有効になっている関係で、時々サイト生成時にリンクが正しくない場合が発生します。その時に、強制的に再ビルドさせたい場合は、サブコマンドで `build` または `re` を指定して実行します。

```
./server.sh build
```


### 環境構築手順
Ubuntu, WSL を使用する場合：
```
sudo apt install build-essential git ruby ruby-dev zlib1g-dev
gem install bundler
git clone git@github.com:tex2e/blog.git
cd blog
bundle install
```

脆弱性対応のためにバージョンアップするときは、次のコマンドで対応します。
```
bundle update
```

#### alias
blogの環境でエディタとブラウザの起動から、サーバを立ち上げる処理までをする `blog` コマンドを定義しておくと、すぐに記事が書けて便利です。
```
alias blog="cd ~/path/to/blog; open http://localhost:4000/blog/; ./server.sh &"
```

#### latexによる画像作成
事前に latex + standalone の環境を構築します（参照：[texlive2020(basic)のインストール on WSL](https://tex2e.github.io/blog/latex/texlive2020-in-wsl)）。
その上で、ImageMagickをインストールします。
```
sudo apt-get install imagemagick
```

ImageMagickは脆弱性への対策としてデフォルトではPDFが入力できませんが、入力PDFは自分で作成したもののみを使用するため、ImageMagickのポリシーを変更します。
/etc/ImageMagick-6/policy.xml のポリシーを変更して、PDFをpngに変換できるようにします。
```
<policymap>
  ...
  <!-- disable ghostscript format types -->
  <policy domain="coder" rights="none" pattern="PS" />
  <policy domain="coder" rights="none" pattern="PS2" />
  <policy domain="coder" rights="none" pattern="PS3" />
  <policy domain="coder" rights="none" pattern="EPS" />
  <!-- <policy domain="coder" rights="none" pattern="PDF" /> この行をコメントアウト-->
  <policy domain="coder" rights="none" pattern="XPS" />
</policymap>
```

platex, standalone, ImageMagick の3つを用意することで tex から画像を生成できるようになります。
このレポジトリのトップディレクトリで以下のコマンドを叩くと、更新日時が新しい tex から png を作成できます。
```
make png
```

特定のtexに対応する画像のみを生成したいときは以下のコマンドを叩きます。
```
cd media/post/tikz
make path/to/file.tex
```

### GitHub Action

#### リンク切れチェック
リンク切れチェックに使用しているもの：
- [tcort/markdown-link-check](https://github.com/tcort/markdown-link-check)
- [gaurav-nelson/github-action-markdown-link-check](https://github.com/gaurav-nelson/github-action-markdown-link-check)

リンク切れチェックの対象外にしたい場合は、以下のHTMLコメントでリンクを囲みます。
```html
<!-- markdown-link-check-disable -->
- [sample](https://example.com)
<!-- markdown-link-check-enable-->
```

### jekyllDecent

[jekyllDecent](https://github.com/jwillmer/jekyllDecent) はこのブログで使用しているテーマです。

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
