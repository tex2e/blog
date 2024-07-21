---
layout:        post
title:         "[Rails] Herokuにpushするときにsqlite3でエラーが起こる"
date:          2016-04-12
category:      Ruby
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from: /rails/rails-on-heroku
comments:      false
published:     true
---

RailsをHerokuにpushする際に、gemfileにsqlite3を入れているとpushに失敗する問題について。

問題
--------

`git push heroku master`を実行すると複数のgemがインストールされるが、
「An error occurred while installing sqlite3 (1.3.11), and Bundler cannot continue.」
と言われて失敗する。

    $ git push heroku master
    Counting objects: 103, done.
    Delta compression using up to 8 threads.
    Compressing objects: 100% (93/93), done.
    Writing objects: 100% (103/103), 26.64 KiB | 0 bytes/s, done.
    Total 103 (delta 22), reused 0 (delta 0)
    remote: Compressing source files... done.
    remote: Building source:
    remote:
    remote: -----> Ruby app detected
    remote: -----> Compiling Ruby/Rails
    remote: -----> Using Ruby version: ruby-2.2.4
    remote: -----> Installing dependencies using bundler 1.11.2
    remote:        Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin -j4 --deployment
    remote:        ...
    remote:        ...
    remote:        An error occurred while installing sqlite3 (1.3.11), and Bundler cannot
    remote:        continue.
    remote:        Make sure that `gem install sqlite3 -v '1.3.11'` succeeds before bundling.
    remote:  !
    remote:  !     Failed to install gems via Bundler.
    remote:  !
    remote:  !     Detected sqlite3 gem which is not supported on Heroku.
    remote:  !     https://devcenter.heroku.com/articles/sqlite3
    remote:  !
    remote:
    remote:  !     Push rejected, failed to compile Ruby app
    remote:
    $


解決方法
--------

Gemfileのsqlite3を development と test 環境のときだけ使用するようにして、
production 環境（herokuのデプロイ環境）では pg (postgreSQL) を使用するように指定します。

```ruby
# ...

# Use sqlite3 as the database for Active Record
gem 'sqlite3', :group => [:development, :test]
# Use postgreSQL as the database for Active Record
gem 'pg', :group => :production

# ...
```

Railsアプリがデータベースを使う場合は、`config/database.yml`の
production環境のadapterを

    adapter: sqlite3

から

    adapter: postgresql

に変更します。

detabaseの名前も変更すると、`config/database.yml`は最終的には次のような感じになります。

```yml
default: &default
  adapter: sqlite3
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: db/development.sqlite3

test:
  <<: *default
  database: db/test.sqlite3

production:
  <<: *default
  adapter: postgresql
  database: db/production.postgresql
```


その他
------

さらに詳しい情報は、公式のドキュメント
[SQLite on Heroku](https://devcenter.heroku.com/articles/sqlite3)
を参照してください。
