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
./new.sh で新規記事を作成します。
カテゴリ名は /_posts 以下のディレクトリ名にします。
以下はPythonカテゴリに「print-helloworld.md」というMarkdownファイルを作成する例です。
```
./new.sh python print-hellowolrd
```

新規作成するとページ上部のメタデータ設定用の変数が自動生成されます。
各変数の意味と書き方は以下の通りです。
- `cover: /assets/cover1.jpg` : ヘッダー画像
- `redirect_from: /PATH` : 変更元のPATHからこのページにリダイレクトする
- `comments: true` : Disqusによるコメント投稿を有効にする
- `published: false` : ページを非公開にする
- `latex: true` : 数式レンダリングを許可する
- `photoswipe: true` : 画像の拡大を有効にする
- `sitemap: false` : sitemap.xmlにリンクを追加しない (検索エンジンから少しだけ見つかりにくくなる)
- `feed: false` : feed.xmlにリンクを追加しない (RSSで更新情報を知らせない)

#### 固定ページの作成
/_pages 以下にMarkdownファイルを作成します。
各固定ページのメタデータの設定で `permalink: /PATH` と書くことで、指定したパスにページを配置できます。

#### サーバの起動
./server.sh を使ってサーバの起動をします。
Rubyを新しくインストールした際は `bundle install` の実行が必要です。
```
./server.sh
```

上記コマンドの内部でjekyllコマンドを呼ぶ際に、以下の開発用のオプションを有効にしています：
- `--incremental` (`-I`) : 差分だけをビルドするので、ビルド時間が高速化されます
- `--livereload` : ページが編集されたら自動的にブラウザも更新します (ライブリロード)
- `--future` : 公開の日付が未来になっている記事も公開します

<br>

### 環境構築手順
WSL (Ubuntu) を使用する場合：
1. Windows Subsystem for Linuxを有効化し、Ubuntuをインストール
2. Ubuntuで以下コマンドを実行
```
sudo apt install build-essential git ruby ruby-dev zlib1g-dev
gem install bundler
git clone git@github.com:tex2e/blog.git
cd blog
bundle install
bundle update   # バージョンアップ作業時
```

Windows を使用する場合：
1. RubyInstallerでインストール
2. 再起動（環境変数PATHにruby, gem, bundleなどのパスを追加）
3. PowerShellで以下コマンドを実行
```
git clone git@github.com:tex2e/blog.git
cd blog
bundle install
```

#### Alias
エディタ起動、ブラウザ起動、Webサーバを立ち上げる処理をまとめた `blog` コマンドを定義しておくと、すぐに記事が書けて便利です。
```
alias blog="cd ~/path/to/blog; open http://localhost:4000/blog/; ./server.sh &"
```

#### LaTeXによる画像作成
事前に latex + standalone の環境を構築します（参照：[texlive2020(basic)のインストール on WSL](https://tex2e.github.io/blog/latex/texlive2020-in-wsl)）。
その上で、ImageMagickをインストールします。
```
sudo apt-get install imagemagick
```

ImageMagickは脆弱性への対策としてデフォルトではPDFが入力できませんが、入力PDFは自分で作成したものだけを使用するとし、ImageMagickのポリシーを変更します。
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

#### カテゴリー別にカバーを変更する
カテゴリー別にカバー画像を変更したい場合は、grep と sed を組み合わせて一括置換します。

Linux :
```bash
grep -rl 'cover:         /assets/cover1.jpg' _posts/python | xargs sed -i "" 's|/assets/cover1.jpg|/assets/cover14.jpg|g'
```
MacOS :
```bash
grep -rl 'cover:         /assets/cover1.jpg' _posts/python | xargs sed -i "" 's|/assets/cover1.jpg|/assets/cover14.jpg|g'
```

また、新規記事作成時に使用する ./new.sh 内の変数 cover を引数の directory によって変える処理の追加も必要です。

<br>

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

<br>

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
