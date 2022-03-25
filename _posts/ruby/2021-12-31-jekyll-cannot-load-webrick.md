---
layout:        post
title:         "Jekyllを実行した時に bundler: failed to load command: jekyll, `require': cannot load such file -- webrick (LoadError) が出るときの対処法"
date:          2021-12-31
category:      Ruby
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Jekyllを実行した時に bundler: failed to load command: jekyll, `require': cannot load such file -- webrick (LoadError) のエラー出たので、Gemfile に webrick を追加したらサーバ起動が成功するようになりました。

MacOS を Big Sur 11 から Monterey 12 にアップグレードした際に、ruby のバージョンが変わったので、bundle install したら github-pages のインストールが失敗するようになってしまいました。
そこで、使用するRubyをシステムのRuby (ver 2.6, /usr/bin/ruby) から brew でインストールした最新のRuby (ver 3.0, /opt/homebrew/opt/ruby/bin/ruby) に変更すると bundle install で github-pages がインストール成功するようになりました。
しかし、/opt/homebrew/opt/ruby/bin/bundle exec jekyll server でWebサーバを起動しようとすると、「cannot load such file – webrick (LoadError)」になってしまいました。
エラー内容で検索すると、解決方法が英語で書かれていたので[^1]、`bundle add webrick` コマンドを実行してみると、問題なくWebサーバ (webrick) が起動するようになりました。

```bash
$ /opt/homebrew/opt/ruby/bin/bundle add webrick
$ /opt/homebrew/opt/ruby/bin/bundle install
$ /opt/homebrew/opt/ruby/bin/bundle exec jekyll server
```

結論としては webrick も Gemfile に追加する必要があった、ということでした。

#### 補足：エラー発生時の環境
M1 Macを使用しており、システムのrubyが2.6、brew経由でインストールしたrubyが3.0です。
```bash
$ uname -a
Darwin imac.local 21.2.0 Darwin Kernel Version 21.2.0: Sun Nov 28 20:29:10 PST 2021; root:xnu-8019.61.5~1/RELEASE_ARM64_T8101 arm64

$ ruby --version
ruby 2.6.8p205 (2021-07-07 revision 67951) [universal.arm64e-darwin21]

$ /opt/homebrew/opt/ruby/bin/ruby --version
ruby 3.0.3p157 (2021-11-24 revision 3fb7d2cadc) [arm64-darwin21]

$ /opt/homebrew/opt/ruby/bin/bundle --version
Bundler version 2.2.32
```

#### 補足：エラー全文
Webサーバ起動時にエラー「cannot load such file -- webrick (LoadError)」が発生していました。
```txt
~]$ /opt/homebrew/opt/ruby/bin/bundle exec jekyll server
Configuration file: /path/to/blog/_config.yml
            Source: /path/to/blog
       Destination: /path/to/blog/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
       Jekyll Feed: Generating feed for posts
                    done in 3.288 seconds.
 Auto-regeneration: enabled for '/path/to/blog'
bundler: failed to load command: jekyll (/path/to/blog/vendor/bundle/ruby/3.0.0/bin/jekyll)
/path/to/blog/vendor/bundle/ruby/3.0.0/gems/jekyll-3.9.0/lib/jekyll/commands/serve/servlet.rb:3:in `require': cannot load such file -- webrick (LoadError)
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/jekyll-3.9.0/lib/jekyll/commands/serve/servlet.rb:3:in `<top (required)>'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/jekyll-3.9.0/lib/jekyll/commands/serve.rb:184:in `require_relative'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/jekyll-3.9.0/lib/jekyll/commands/serve.rb:184:in `setup'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/jekyll-3.9.0/lib/jekyll/commands/serve.rb:102:in `process'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/jekyll-3.9.0/lib/jekyll/commands/serve.rb:93:in `block in start'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/jekyll-3.9.0/lib/jekyll/commands/serve.rb:93:in `each'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/jekyll-3.9.0/lib/jekyll/commands/serve.rb:93:in `start'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/jekyll-3.9.0/lib/jekyll/commands/serve.rb:75:in `block (2 levels) in init_with_program'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/mercenary-0.3.6/lib/mercenary/command.rb:220:in `block in execute'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/mercenary-0.3.6/lib/mercenary/command.rb:220:in `each'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/mercenary-0.3.6/lib/mercenary/command.rb:220:in `execute'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/mercenary-0.3.6/lib/mercenary/program.rb:42:in `go'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/mercenary-0.3.6/lib/mercenary.rb:19:in `program'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/gems/jekyll-3.9.0/exe/jekyll:15:in `<top (required)>'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/bin/jekyll:25:in `load'
	from /path/to/blog/vendor/bundle/ruby/3.0.0/bin/jekyll:25:in `<top (required)>'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/cli/exec.rb:58:in `load'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/cli/exec.rb:58:in `kernel_load'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/cli/exec.rb:23:in `run'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/cli.rb:478:in `exec'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/vendor/thor/lib/thor/command.rb:27:in `run'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/vendor/thor/lib/thor/invocation.rb:127:in `invoke_command'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/vendor/thor/lib/thor.rb:392:in `dispatch'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/cli.rb:31:in `dispatch'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/vendor/thor/lib/thor/base.rb:485:in `start'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/cli.rb:25:in `start'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/gems/3.0.0/gems/bundler-2.2.32/exe/bundle:49:in `block in <top (required)>'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/3.0.0/bundler/friendly_errors.rb:103:in `with_friendly_errors'
	from /opt/homebrew/Cellar/ruby/3.0.3/lib/ruby/gems/3.0.0/gems/bundler-2.2.32/exe/bundle:37:in `<top (required)>'
	from /opt/homebrew/opt/ruby/bin/bundle:23:in `load'
	from /opt/homebrew/opt/ruby/bin/bundle:23:in `<main>'
```

以上です。


---

[^1]: [When Jekyll runs, it will prompt an error. Cannot load such file — webrick (LoadError) \| ProgrammerAH](https://programmerah.com/when-jekyll-runs-it-will-prompt-an-error-cannot-load-such-file-webrick-loaderror-41724/)
