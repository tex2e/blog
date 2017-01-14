---
layout:        post
title:         "github-pages が Ruby2.4 で使えない問題"
menutitle:     "github-pages が Ruby2.4 で使えない問題"
date:          2017-01-10
tags:          Programming Language Ruby
category:      Ruby
author:        tex2e
cover:         /assets/cover2.jpg
redirect_from:
comments:      false
published:     true
comments:      false
---

（この問題は gem 提供側の対応によって、すでに解決している問題です。）


問題
-------------------

Ruby2.4 以降で発生する問題で、
Jekyll で生成したサイトの Gemfile に

```ruby
gem 'github-pages'
```

などと書いて `bundle install` とコマンドを打つと、json という gem でエラーを吐くようになった。


解決方法
-------------------

結論をいうと（2017年1月10日現在）、
Gemfile で json のバージョン 1.8.5 を github から取ってくれば良い。
ちなみに 1.8.5 は、まだ Rubygems に公開されていない。

```ruby
gem 'json', github: 'flori/json', branch: 'v1.8'
gem 'github-pages'
```

追加（2017年1月12日）：Rubygems に 1.8.5 の json がリリースされたので、
この問題はもう発生しない。


原因
-------------------

原因としては、github-pages という gem の依存関係にある。

```
github-pages = 113
└── activesupport = 4.2.7
    └── json ~> 1.7
```

- github-pages は Ruby2.1 でも使えるように activesupport 5.x を使いたがらない。
- activesupport 5.x は Ruby2.2.2 以降でしか使えない。
- json 2.x はどのRubyのバージョンでも動くが、多くの依存されている gem のバージョン指定は
`~> 1.7` となっていて永遠に 2.x にならない。

---


（おまけ）エラー全文
-------------------

```
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

current directory:
/usr/local/lib/ruby/gems/2.4.0/gems/json-1.8.3/ext/json/ext/generator
/usr/local/opt/ruby/bin/ruby -r ./siteconf20170110-3713-3l8m0e.rb extconf.rb
creating Makefile

current directory:
/usr/local/lib/ruby/gems/2.4.0/gems/json-1.8.3/ext/json/ext/generator
make "DESTDIR=" clean

current directory:
/usr/local/lib/ruby/gems/2.4.0/gems/json-1.8.3/ext/json/ext/generator
make "DESTDIR="
compiling generator.c
generator.c:861:25: error: use of undeclared identifier 'rb_cFixnum'
    } else if (klass == rb_cFixnum) {
                        ^
generator.c:863:25: error: use of undeclared identifier 'rb_cBignum'
    } else if (klass == rb_cBignum) {
                        ^
generator.c:975:5: warning: division by zero is undefined [-Wdivision-by-zero]
    rb_scan_args(argc, argv, "01", &opts);
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2143:9: note:
expanded from macro 'rb_scan_args'
        rb_scan_args0(argc,argvp,fmt,\
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2329:8: note:
expanded from macro 'rb_scan_args0'
                     rb_scan_args_verify(fmt, varc), vars)
                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2201:11: note:
expanded from macro 'rb_scan_args_verify'
        verify = rb_scan_args_verify_count(fmt, varc); \
                 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see
all)
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2167:6: note:
expanded from macro 'rb_scan_args_count_hash'
     rb_scan_args_count_block(fmt, ofs, varc, vari) : \
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2162:6: note:
expanded from macro 'rb_scan_args_count_block'
     rb_scan_args_count_end(fmt, ofs, varc, vari) : \
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2158:12: note:
expanded from macro 'rb_scan_args_count_end'
    ((vari)/(!fmt[ofs] || rb_scan_args_bad_format(fmt)))
           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
generator.c:975:5: warning: division by zero is undefined [-Wdivision-by-zero]
    rb_scan_args(argc, argv, "01", &opts);
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2143:9: note:
expanded from macro 'rb_scan_args'
        rb_scan_args0(argc,argvp,fmt,\
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2329:8: note:
expanded from macro 'rb_scan_args0'
                     rb_scan_args_verify(fmt, varc), vars)
                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2201:11: note:
expanded from macro 'rb_scan_args_verify'
        verify = rb_scan_args_verify_count(fmt, varc); \
                 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see
all)
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2167:6: note:
expanded from macro 'rb_scan_args_count_hash'
     rb_scan_args_count_block(fmt, ofs, varc, vari) : \
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2163:6: note:
expanded from macro 'rb_scan_args_count_block'
     rb_scan_args_count_end(fmt, ofs+1, varc, vari+1))
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2158:12: note:
expanded from macro 'rb_scan_args_count_end'
    ((vari)/(!fmt[ofs] || rb_scan_args_bad_format(fmt)))
           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
generator.c:975:5: warning: division by zero is undefined [-Wdivision-by-zero]
    rb_scan_args(argc, argv, "01", &opts);
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2143:9: note:
expanded from macro 'rb_scan_args'
        rb_scan_args0(argc,argvp,fmt,\
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2329:8: note:
expanded from macro 'rb_scan_args0'
                     rb_scan_args_verify(fmt, varc), vars)
                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2201:11: note:
expanded from macro 'rb_scan_args_verify'
        verify = rb_scan_args_verify_count(fmt, varc); \
                 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see
all)
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2168:6: note:
expanded from macro 'rb_scan_args_count_hash'
     rb_scan_args_count_block(fmt, ofs+1, varc, vari+1))
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2162:6: note:
expanded from macro 'rb_scan_args_count_block'
     rb_scan_args_count_end(fmt, ofs, varc, vari) : \
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2158:12: note:
expanded from macro 'rb_scan_args_count_end'
    ((vari)/(!fmt[ofs] || rb_scan_args_bad_format(fmt)))
           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
generator.c:975:5: warning: division by zero is undefined [-Wdivision-by-zero]
    rb_scan_args(argc, argv, "01", &opts);
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2143:9: note:
expanded from macro 'rb_scan_args'
        rb_scan_args0(argc,argvp,fmt,\
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2329:8: note:
expanded from macro 'rb_scan_args0'
                     rb_scan_args_verify(fmt, varc), vars)
                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2201:11: note:
expanded from macro 'rb_scan_args_verify'
        verify = rb_scan_args_verify_count(fmt, varc); \
                 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see
all)
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2167:6: note:
expanded from macro 'rb_scan_args_count_hash'
     rb_scan_args_count_block(fmt, ofs, varc, vari) : \
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2162:6: note:
expanded from macro 'rb_scan_args_count_block'
     rb_scan_args_count_end(fmt, ofs, varc, vari) : \
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2158:12: note:
expanded from macro 'rb_scan_args_count_end'
    ((vari)/(!fmt[ofs] || rb_scan_args_bad_format(fmt)))
           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
generator.c:975:5: warning: division by zero is undefined [-Wdivision-by-zero]
    rb_scan_args(argc, argv, "01", &opts);
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2143:9: note:
expanded from macro 'rb_scan_args'
        rb_scan_args0(argc,argvp,fmt,\
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2329:8: note:
expanded from macro 'rb_scan_args0'
                     rb_scan_args_verify(fmt, varc), vars)
                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2201:11: note:
expanded from macro 'rb_scan_args_verify'
        verify = rb_scan_args_verify_count(fmt, varc); \
                 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
note: (skipping 4 expansions in backtrace; use -fmacro-backtrace-limit=0 to see
all)
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2167:6: note:
expanded from macro 'rb_scan_args_count_hash'
     rb_scan_args_count_block(fmt, ofs, varc, vari) : \
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2162:6: note:
expanded from macro 'rb_scan_args_count_block'
     rb_scan_args_count_end(fmt, ofs, varc, vari) : \
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2158:12: note:
expanded from macro 'rb_scan_args_count_end'
    ((vari)/(!fmt[ofs] || rb_scan_args_bad_format(fmt)))
           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
generator.c:975:5: warning: division by zero is undefined [-Wdivision-by-zero]
    rb_scan_args(argc, argv, "01", &opts);
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2143:9: note:
expanded from macro 'rb_scan_args'
        rb_scan_args0(argc,argvp,fmt,\
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2329:8: note:
expanded from macro 'rb_scan_args0'
                     rb_scan_args_verify(fmt, varc), vars)
                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2201:11: note:
expanded from macro 'rb_scan_args_verify'
        verify = rb_scan_args_verify_count(fmt, varc); \
                 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
note: (skipping 5 expansions in backtrace; use -fmacro-backtrace-limit=0 to see
all)
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2167:6: note:
expanded from macro 'rb_scan_args_count_hash'
     rb_scan_args_count_block(fmt, ofs, varc, vari) : \
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2162:6: note:
expanded from macro 'rb_scan_args_count_block'
     rb_scan_args_count_end(fmt, ofs, varc, vari) : \
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/local/Cellar/ruby/2.4.0/include/ruby-2.4.0/ruby/ruby.h:2158:12: note:
expanded from macro 'rb_scan_args_count_end'
    ((vari)/(!fmt[ofs] || rb_scan_args_bad_format(fmt)))
           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
6 warnings and 2 errors generated.
make: *** [generator.o] Error 1

make failed, exit code 2

Gem files will remain installed in
/usr/local/lib/ruby/gems/2.4.0/gems/json-1.8.3 for inspection.
Results logged to
/usr/local/lib/ruby/gems/2.4.0/extensions/x86_64-darwin-16/2.4.0/json-1.8.3/gem_make.out

An error occurred while installing json (1.8.3), and Bundler cannot
continue.
Make sure that `gem install json -v '1.8.3'` succeeds before bundling.
```
