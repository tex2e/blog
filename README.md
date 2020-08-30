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
- `photoswipe: true` : 画像の拡大を有効にする
- `syntaxhighlight: false` : シンタックスハイライトを無効にしてページレンダリングを高速化する（特に数学、英語、雑文の記事での読み込み速度の高速化）
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


### 環境構築手順

Ubuntu

```
sudo apt install build-essential git ruby ruby-dev zlib1g-dev
gem install bundler
git clone git@github.com:tex2e/blog.git
cd blog
bundle install
```

#### alias

blogのディレクトリに移動して、エディタを開き、ブラウザでページを開いて、サーバを立ち上げる一連の処理をする `blog` コマンド (エイリアス) を定義しておくと、気づいたときにすぐに記事が書けて便利です。

```
alias blog="cd ~/path/to/blog; open http://localhost:4000/blog/; ./server.sh &"
```

#### latexによる画像作成

事前に latex + standalone の環境を構築します（参照：[texlive2020(basic)のインストール on WSL](https://tex2e.github.io/blog/latex/texlive2020-in-wsl)）。
その上で、ImageMagickをインストールします。

```
sudo apt-get install imagemagick
```

ImageMagickは脆弱性への対策としてPDFがデフォルトでは入力できませんが、入力PDFは自分で作成したもののみを使用するため、ImageMagickのポリシーを変更しても問題ないです（他で使用しないことが前提ですが）。
/etc/ImageMagick-6/policy.xml のポリシーを変更して、PDFをpngに変換できるようにします。

```
<policymap>
  ...
  <!-- disable ghostscript format types -->
  <policy domain="coder" rights="none" pattern="PS" />
  <policy domain="coder" rights="none" pattern="PS2" />
  <policy domain="coder" rights="none" pattern="PS3" />
  <policy domain="coder" rights="none" pattern="EPS" />
  <!-- <policy domain="coder" rights="none" pattern="PDF" /> -->
  <policy domain="coder" rights="none" pattern="XPS" />
</policymap>
```

platex, standalone, ImageMagick の3つを用意することで tex から画像を生成できるようになります。

レポジトリの一番上のディレクトリで以下のコマンドを叩くと、更新日時が新しい tex から png を作成します。

```
make png
```

特定のtexに対応する画像のみを生成したいときは以下のコマンドを叩きます。

```
cd media/post/tikz
make path/to/file.tex
```



<br>

-----

jekyllDecent について：

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
