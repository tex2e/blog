---
layout:        post
title:         "[Ruby] Rake入門"
date:          2016-09-24
category:      Ruby
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---

MakeのRuby版である「Rake」の使い方について説明します。

## Install Rake

rakeはrubyのライブラリです。なので、まずrubyがすでにインストールされている必要があります。
rubyのインストールについては省略します。

rakeのインストール

```
$ gem install rake
```

## Execute Rake

rakeを実行するためには、Rakefileがあるディレクトリに移動してから次のコマンドを打ちます。

```
$ rake <taskname>
```

taskname を省略すると、defaultタスクが実行されます。


## Rake Tasks

rakeが行うタスクはRakefileに記述します。Rakefileがなければ「Rakefile」という名前のファイルを作成します。
Rakefileに書くことのできるタスクは次のようなものがあります。

name           | Description
:------------- | :-------------
task           | 一番基本となるタスク
rule           | 拡張子を指定してファイルを作成するためのタスク
multitask      | 複数の事前条件を並列で行うタスク
file           | ファイルを作成するためのタスク
directory      | ディレクトリを作成するためのタスク
clean, clobber | 定数 CLEAN, CLOBBER に含まれるファイルを削除するタスク（`require 'rake/clean'` が必要）


## Task

一番基本となるタスク。タスクの処理内容や、依存関係を書くことができる。

```ruby
# タスクの定義
task :taskA do
  # taskAが行う処理
end

# 前提条件を持つタスク
task :taskB => :taskA do
  # taskAが実行された後、taskBが実行される
end

# 前提条件のみ
task :taskC => [:taskA, :taskB]

# 複数の前提条件を持つタスク
task :taskD => [:taskA, :taskB] do
  # taskAとtaskBが実行された後、taskDが実行される
end

# task関数の前にdesc関数を置くことで、そのタスクの説明をする
desc 'sample task E'
task :taskE do
  # taskEが行う処理
end

# defaultを定義すると、タスク名を指定しないでrakeを実行した場合の動作を指定できる
task :default => :taskA
```

関数 task で定義したタスク名（ここでは taskA や taskB ...など）は、rakeコマンドを実行する際にも使える。

``` bash
$ rake taskA        # タスク :taskA を実行
$ rake taskD taskE  # タスク :taskD と :taskE を実行
$ rake              # タスク :default を実行
```

## Rule

拡張子を指定してファイルを作成するためのタスク。

``` ruby
rule '.html' => '.md' do |t|
  sh "pandoc -s #{t.source} -o #{t.name}"
end
```


## Multitask

タスクをより高速に実行できるように、依存する複数のタスクを並列して処理するタスク。

```ruby
multitask :task => [:taskA, :taskB, :taskC] do
  puts 'Every task is completed!'
end
```

**注意**

複数のタスクを並列して処理するので、
「あるタスクを一番最初に実行する」とか
「このタスクは一番最後に終了させる」というのは指定できない。
実行する順番を指定する必要がある場合は、前述のtaskを使用すること。


## File

ファイルを作成するためのタスク。基本的には必ず、依存するファイルを伴う

```ruby
file 'report.dvi' => 'report.tex' do |t|
  sh "latex #{t.source}"
end
```


## Directory

ディレクトリを作成するためのタスク。

```ruby
directory 'path/to/dir'  # ディレクトリ path/to/dir/ が存在しなければ、作成する

file 'config.yml' => 'path/to/dir' do |t|
  sh "some-command > path/to/dir/config.yml"
end
```


## Cleaning Task

rakeによって作られた中間ファイルや生成ファイルを削除するためのタスクは `rake/clean` に定義されています。
これらを利用するには、まず `require 'rake/clean'` をRakefileに追加します。

`rake/clean` には `CLEAN` と `CLOBBER` という2つの定数と、
`clean` と `clobber` という2つのタスクが定義されています。

**定数**

- CLEAN : 中間ファイルのリスト
- CLOBBER : 生成ファイルのリスト

CLEAN や CLOBBER の初期値は、何も登録されていません。これらへファイルを追加するには次のようなコードを書きます。

``` ruby
require 'rake/clean'
# => rake clean と rake clobber が使えるようになる

# 中間ファイル
CLEAN.include("output/*.dvi")
CLEAN.include("output/*.log")
CLEAN.include("output/*.aux")

# 生成ファイル
CLOBBER.include("output/*.pdf")
```

**タスク**

- clean : 定数 CLEAN に追加されたファイルを削除するタスク
- clobber : 定数 CLEAN と CLOBBER に追加されたファイルを削除するタスク

Rakefileに `require 'rake/clean'` と書いた上で、
`rake clean` もしくは `rake clobber` とコマンドを入力すると、
指定した中間ファイル・生成ファイルが削除されます。


## Modules included

### FileUtils

FileUtils にはシェル上での操作を行う関数が定義されています。
さらに rake は FileUtils に新たな関数をいくつか追加しています。
特に重要なのは `sh` で、引数の文字列をシステムコマンドとして実行する関数です。

``` ruby
sh "python foo.py"  # 引数の文字列 "python foo.py" を出力してから、foo.pyファイルをpythonで実行する
```

rake は実行時に FileUtils モジュールを require しているので、
FileUtils を新たに require する必要はありません。
FileUtils の詳細は rake の説明から離れるので、興味があれば FileUtils モジュールを参照してください。

### Rake::FileList

### Rake::Task

### Rake::MakefileLoader

- load(filename)

与えられた Makefile をロードします。
