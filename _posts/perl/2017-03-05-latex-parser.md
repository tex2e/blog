---
layout:        post
title:         "Raku (Perl6) で LaTeX 文章の構文解析をする"
date:          2017-03-05
category:      Perl
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
    - /perl6/latex-parser
    - /raku/latex-parser
comments:      false
published:     true
---

Perl6 (Raku) では新しい機能として Grammar が導入されたので、ちょっと遊んでみました。


Grammar による構文解析
----------------------

例えば、LaTeX は

```latex
\foo{bar}
```

のような命令と、

```latex
\begin{foo}
    bar
\end{foo}
```

のようなブロック命令[^block]があり、それ以外は文章となります。
また例外的に、

```latex
{\Large Emergency request}
```

のときには `{ }` は表示されず、プログラムでいうところのスコープなるものが作られるので、注意が必要です。

これらを踏まえて、LaTeX の構造を拡張 BNF で示すと次のようになります[^bnf]。

```
TOP           ::= <exp>*
<exp>         ::= <curlybrace> | <block> | <command> | <text>
<curlybrace>  ::= { <exp>* }
<block>       ::= \\begin{ <blockname> }
                  <exp>*
                  \\end{ $<blockname> }
<command>     ::= \\ <name> <curlybrace>
<name>        ::= [\w_]+ \*?
<text>        ::= [^\\\{\}$]+
```

Grammar
----------------

詳しい話は公式のドキュメント [Grammar Tutorial](https://docs.perl6.org/language/grammar_tutorial) に書いてありますが、改めて説明すると grammar の宣言はクラスの宣言に似ており、parse というメソッドが自動的に定義されます。
この parse は与えられた文字列に対して、TOP という特別なトークンから解析を開始します。
TOP トークン以外は、regex, token, rule のいずれかを使って、トークンを定義します。
この3つの定義方法の違いは以下の通りです。

  * regex は普通の正規表現（どのオプションも指定されていない）
  * token はオプション「Ratchet」が指定された正規表現
    * `token name { ... }` は `regex name { :r ... }` と等しい
    * オプション「Ratchet」は、正規表現によるバックトラックを禁止することができる
  * rule はオプション「Ratchet」と「Sigspace」が指定された正規表現
    * `rule name { ... }` は `regex name { :r :s ... }` と等しい
    * オプション「Sigspace」は、空白も正規表現でマッチするようにすることができる

Perl6 の正規表現は Perl5 の正規表現と全く違うので、もし Perl6 の正規表現がわからないという方は [Regexes](https://docs.perl6.org/language/regexes) をご一読ください。

先ほどの拡張 BNF を Perl6 の Grammar で表すと次のようになります。

```perl6
use v6;

grammar Grammar {
    token name { <[ \w _ ]>+ \*? }

    # 式は 中かっこ か ブロック命令 か 命令 か それ以外は文章
    token exp  { <curlybrace> || <block> || <command> || <text> }

    # 文章は \ { } 以外の全ての文字
    token text { ( <-[ \\ \{ \} ]>+ ) }

    # ブロック
    rule block {
        '\begin{' $<blockname>=[<name>] '}'
        [ <exp> ]*?
        '\end{' $<blockname> '}'
    }

    # 命令
    token command {
        '\\' <name> <curlybrace>
    }

    # 中かっこ
    rule curlybrace {
        '{' <exp>* '}'
    }

    # 構文解析の開始トークン
    token TOP {
        ^
        \n*
        [ <exp> ]*
        $
    }
}

my $contents = q:to/EOS/;
\documentclass{jsarticle}
\lstset{ language = c, numbers = left }

\begin{foo}
  \begin{bar}
    nested block test
  \end{bar}

  \lstinputlisting{../src/abc.c}
\end{foo}
EOS

my $result = Grammar.parse($contents);
say $result;
```

上のコードを実行すると改行が多くて読みにくいが、階層構造が正しく解析されているのが確認できます。

```
exp => ｢\documentclass{jsarticle}
｣
  command => ｢\documentclass{jsarticle}
｣
   name => ｢documentclass｣
   curlybrace => ｢{jsarticle}
｣
    exp => ｢jsarticle｣
     text => ｢jsarticle｣
      0 => ｢jsarticle｣
```

上は出力の一部ですが、コマンド「\documentclass{jsarticle}」の名前は「documentclass」で、引数は「{jsarticle}」であることがわかります。


解析結果の JSON 化
-------------------

このままの結果を使うのも良いですが、JSON にして必要な情報だけにする方法についても説明します。

まず、流れとしては、

    LaTeX文字列 ==> Grammarで解析 ==> Actionで必要な情報だけ抜き取る ==> to-jsonでJSON化

という感じで進めていきます。

とりあえず次のような Action を作成しました。

```perl6
class Latex::Action {
    method TOP($/) {
        make $<exp>».ast;
    }
    method exp($/) {
        make $/.values[0].ast;
    }
    method text($/) {
        make $0.Str.trim;
    }
    method command($/) {
        my @arguments = $<curlybrace>;

        my %node = %{ command => $<name>.Str };
        %node<args> = @arguments».ast if @arguments.elems > 0;
        make %node;
    }
    method block($/) {
        my %node = %{ block => $<name>.Str.trim };
        %node<contents> = $<exp>».ast;
        make %node;
    }
    method curlybrace($/) {
        make { contents => $/.values.Array».ast };
    }
}
```

マッチオブジェクトには ast という木構造を作るためのメソッド(?)があるので、これを呼ぶとその下に続く構造を作る（make）することができる。

  * TOP の下には、複数の exp をもつため、それぞれの exp に対して ast を呼んでいる
  * exp の下には、中かっこ、ブロック命令、命令、文章のいずれかがあるため、それに対して ast を呼んでいる
  * text は文章であるため、前後の空白を取り除いた値を返している
  * command は、命令名（name）と引数（curlybrace）の値をもつハッシュを返している
  * block は、命令名（name）とブロックの中身（複数の exp）の値をもつハッシュを返している

この Action を Grammar でパースするときの引数に渡してあげ、made メソッドを呼び出すと Action によって作成されたオブジェクトを得るとこができます。
また、そのままでは読みにくいので、JSON::Fast の to-json を使って、整形した出力を得るには、次のようにすれば良いです。

```perl6
use JSON::Fast;

my $actions = Latex::Action;
my $json = Grammar.parse($contents, :$actions).made;
say to-json($json, :pretty);
```

このプログラムを実行すると次のJSONを得るとこができます。

```
[
  {
    "command": "documentclass",
    "args": [
      {
        "contents": [
          "jsarticle"
        ]
      }
    ]
  },
  {
    "command": "lstset",
    "args": [
      {
        "contents": [
          "language = c, numbers = left"
        ]
      }
    ]
  },
  {
    "block": "foo",
    "contents": [
      {
        "block": "bar",
        "contents": [
          "nested block test"
        ]
      },
      {
        "command": "lstinputlisting",
        "args": [
          {
            "contents": [
              "../src/abc.c"
            ]
          }
        ]
      }
    ]
  }
]
```

まとめ
-----------------

ここまで示したコードは LaTeX の構文解析を行うための簡単な例です。
この拡張版として [yalp](https://github.com/tex2e/yalp) という Perl6 で書いた LaTeX の構文解析ツールを作りましたが、これは普通の LaTeX には正しく動作しますが、命令の引数が3つ4つになると正しく動作しないので、使用時は注意して使ってください。

以上です。

-----

[^block]: 正式名称は環境 Environment
[^bnf]: この BNF では不十分で、実際の LaTeX にはコメント `%` や数式モード `$` や命令のオプション `[ ]` などもある。
