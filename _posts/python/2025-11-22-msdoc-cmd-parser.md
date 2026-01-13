---
layout:        post
title:         "[Python] LarkでMS-DOSコマンドの構文解析"
date:          2025-11-22
category:      Python
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

一見単純に見えるMS-DOSのバッチファイル（CMDスクリプト）ですが、その裏側にはリダイレクト、変数展開、特殊文字のエスケープといった複雑なルールが隠されています。
このような独自の文法を持つテキストをプログラムで正確に扱うには、構文解析が不可欠です。
この記事では、Pythonの強力なパーサーライブラリ **Lark** を使い、MS-DOSコマンドの構文解析器（パーサー）をゼロから構築した方法を概要を説明します。

文法定義ファイル `grammar.lark` の書き方から、`if` や `for` といった制御構文、`set` や `echo` などの基本コマンド、さらには解析の難所である引数やリダイレクトの扱いまで、具体的なコード例と生成される構文木（AST）を交えながら説明していきます。

CMDファイルの「文法」を定義するために使用できるのが Python ライブラリの一つである Lark です。
なお、今回作成したCMDファイルの構文解析プログラムは以下で公開しております。

[tex2e/msdos-cmd-parser: MS-DOS Command Parser](https://github.com/tex2e/msdos-cmd-parser)

上記で公開したレポジトリについて、このトランスパイラの心臓部となるのが、`grammar.lark` ファイルです。
このファイルは、解析対象であるMS-DOSコマンド（CMD）の構文ルールを**EBNF (Extended Backus-Naur Form)** という形式で厳密に定義した「文法定義ファイル」です。

Pythonの強力なパーサーライブラリである **Lark** は、この文法定義ファイルを設計図として読み込み、CMDスクリプトを解析するためのパーサーを動的に生成します。

### 1. Larkと文法定義

Larkは、文法定義に従ってテキストを解析し、その構造をプログラムで扱いやすい**AST** (Abstract Syntax Tree / 抽象構文木) というデータ構造に変換してくれるツールです。

例えば、`SET A=1` という単純なテキストも、人間にとっては「変数Aに1を代入するコマンド」と理解できますが、プログラムにとってはただの文字列です。文法定義ファイルには、以下のようなルールが記述されています。

*   コマンドは `SET` というキーワードで始まる場合がある。
*   `SET` の後には、空白を挟んで「変数名」が来る。
*   「変数名」の後には `=` が来る。
*   `=` の後には「値」が来る。

Larkは `grammar.lark` に書かれたこれらのルールに従うことで、`SET A=1` という文字列を「`SET`コマンド」というノードに変換し、そのノードが「変数名=`A`」と「値=`1`」という子ノードを持つ、というような階層的な木構造（AST）を構築します。

後続の処理では、このASTを操作することで、元のCMDスクリプトの構造を理解できるため、C#のコードなどに変換できるようになります。

### 2. Larkの書き方

文法は主に2種類の要素で構成されます。

1.  **ルール (Rule)**：文法の構成要素
2.  **ターミナル (Terminal)**: これ以上分解できない文法の最小単位（トークン）

ルールは、他のルールやターミナルを組み合わせて定義します。Larkでは通常、小文字で命名されます。（例: `program`, `line`, `statement_if`）
ターミナルは、具体的な文字列や正規表現で定義します。Larkでは慣例的に大文字で命名されます。（例: `IF`, `SET`, `FILEPATH`）

#### 基本的なEBNF記法

`grammar.lark` を読む上で重要な記号は以下の通りです。

| 記号 | 意味                                        | 例                                                              |
| :--- | :------------------------------------------ | :-------------------------------------------------------------- |
| `:`  | ルールやターミナルを定義する                  | `program: ...`                                                  |
| `\|`  | 「または (OR)」                             | `A \| B` (AまたはB)                                                  |
| `?`  | 直前の要素が省略可能 (0回または1回)         | `NL?` (改行はあってもなくても良い)                                |
| `*`  | 直前の要素が0回以上繰り返し                 | `A*` (Aが0回以上繰り返す)                                       |
| `+`  | 直前の要素が1回以上繰り返し                 | `A+` (Aが1回以上繰り返す)                                       |
| `()` | グループ化                                  | `(A B)+` (AとBの並びが1回以上繰り返す)                           |
| `i`  | `"`の後の `i` は大文字小文字を区別しない    | `SET: "set"i`                                                   |
| `/ /`| 正規表現によるターミナル定義                | `VARIABLE_NAME: /[^=]+/`                                        |
| `->` | ルールに別名（エイリアス）を付ける            | `... -> test_not_exist` (Transformerで扱いやすくなる)           |
| `.N` | ルールの優先度を指定 (数字が大きいほど高い) | `command_rem.9: ...` (文法の曖昧さを解決するために使用)       |

#### 具体的なルールの例

Larkの構文ルールの書き方に関して、いくつか具体的なルールの例を紹介します。

##### エントリーポイント

Lark は必ず「start」ルールから始まります。

```lark
// 構文解析のエントリーポイント
?start: program

// プログラムは複数のコメント行か命令行
program: WS? (command_rem NL WS_INLINE? | line WS_INLINE? NL WS_INLINE? | emptyline)+
```

*   `?start`: 解析の開始地点。`?`を付けると、生成されるAST上でこのノードが省略（インライン化）されます。
*   `program`: スクリプト全体を表すルール。`line`（命令行）や`command_rem`（コメント行）などが1回以上繰り返される(`+`)ことで構成されると定義しています。

##### IF文

```lark
statement_if.5: IF WS_INLINE test WS_INLINE line (WS_INLINE? statement_else)?

statement_else.5: ELSE WS_INLINE statement_if
                | ELSE WS_INLINE line

IF: "if"i
ELSE: "else"i
```

*   `statement_if` ルールは、`IF` ターミナル、`test` ルール（条件式）、そして実行される `line` ルール（コマンド）から構成されることを示します。
*   `|` を使って、`else`句 (`statement_else`) が続くパターンも定義されています。`?` により`else`句は省略可能です。

##### 複雑な引数を捉える正規表現

```lark
// コマンドの引数。リダイレクト（>&|）と改行（\n）と丸括弧閉じ（)）以外の全てにマッチする
ARG_VALUE_IN_PAREN.2: /
    (    \^.                                             # キャレットによるエスケープ
        |"(^"|[^"]++)*+"                                 # 文字列の囲み
        |(?<paren>\((^\)|[^()\r\n]++|(?&paren))*+\))     # 丸括弧の囲み
        |[^^\r\n<>()&|^"12]++                            # 値
    )+
/x
```

CMDのコマンド引数は、変数展開 (`%VAR%`)、引用符、特殊文字のエスケープなどが絡み合い、非常に複雑です。このような複雑な文字列パターンを正確に捉えるために、ターミナル定義では正規表現が多用されます。
`/x` フラグは、正規表現内にコメントや空白を入れることを許可し、可読性を向上させるためのものです。

### 3. Larkの便利な機能

Larkには以下の2つの組み込みの命令が存在します。

- `%import`
- `%ignore`

`%import` は `grammar.lark` の末尾で `common.DIGIT` や `common.LETTER` をインポートするときに使われています。
これはLarkに標準で組み込まれている共通のターミナル定義を再利用するための機能です。

また、`%ignore` は指定したターミナルを解析時に無視するよう指示します。ただし、MS-DOSの文法においてはECHOなどで、空白の有無が重要な意味を持つケースが多いため、グローバルな `%ignore` は使わず、`WS_INLINE` のような空白ルールを文法内に明示的に記述する戦略を取っています。

このように `grammar.lark` は、トランスパイラの挙動を支えるための、緻密かつ可読性の高い設計図として機能しています。この文法定義があるからこそ、LarkはCMDスクリプトの構造を正確に解析し、後続の処理で扱いやすいASTへと変換することができるのです。

## 4. `grammar.lark` 詳細解説

`grammar.lark` の文法定義は、「構造」「制御フロー」「コマンド」「引数」といった主要な要素から構成されています。このセクションでは、具体的なCMDコマンドの例を交えながら、文法の中心となるルールの役割を解説していきます。

### 4.1 スクリプトの基本構造

まず、スクリプト全体の骨格を定義するルールについて説明します。

#### `program`
```lark
?start: program
program: WS? (command_rem NL ... | line NL ... | emptyline)+
```
`program` ルールは、CMDスクリプト全体の構造を定義する中心的な役割を担います。スクリプトは、`rem` で始まるコメント行 (`command_rem`)、後述するコマンドやステートメントなどの実行可能な行 (`line`)、そして空行 (`emptyline`) の3種類の行が1つ以上繰り返されることで構成されます。

例えば、以下のような環境変数をセットしてgotoするだけのMS-DOSコマンドファイルを構文解析するとします。

```batch
@echo off
rem 初期設定
set VAR=100

goto :main
```

上記の内容を構文解析すると、以下の構文解析木が出力されます。
なお、読みやすさ優先で出力結果を一部を手で修正しています。

```
program
  command_echo
    echo
  command_rem
    rem
  command_set
    set VAR=100
  emptyline
  command_goto
    goto
```

構文ルールでは初めに `?start: program` と書きましたが、解析結果は「start」から始まらずに「program」から木が構築されています。
これは、`?` をつけた場合、その要素（start）の子供が1個の要素（program）しか存在しないときに、親の要素が構文木上から省略されるためです。

続いて、「program」の要素の中には、複数の要素（command_* や emptyline など）が含まれています。
構文ルール上では複数のパターンをOR演算子 `|` で連結し、さらにそれらが連続で出現できることを意味する繰り返し記号 `+` で表現されているためです。


#### `line` と `label`
```lark
?line: command_line | statement | label
label: COLON LABEL PLUS?
```
`line` ルールは、個々の行が「コマンド (`command_line`)」「ステートメント (`statement`)」「ラベル (`label`)」のいずれかであることを示します。
`label` は、コロン (`:`) で始まり、`goto` や `call` 命令の飛び先となる目印として機能します。

例えば、以下のようなechoで出力した後にif文で条件分岐するだけのMS-DOSコマンドファイルを構文解析するとします。

```batch
:main
echo Main process
if "%VAR%"=="100" (
    goto :end
)

:end
echo End
```

上記の内容を構文解析すると、以下の構文解析木が出力されます。
なお、読みやすさ優先で出力結果を一部を手で修正しています。

```
program
  label :main
  command_echo
    echo Main process
  statement_if
    if
    test_comp
      "%VAR%" == "100"
    group
      (
      subprogram
        command_goto
          goto :end
      )
  emptyline	
  label
    :end
  command_echo
    echo End
```

### 4.2 制御フロー

次に、コマンドの実行順序を制御するためのルールを見ていきます。

#### `command_line` (コマンド連結)
```lark
?command_line: pipeline (CHAIN_OP WS_INLINE pipeline)*
CHAIN_OP: "&&" | "||" | "&"
```
`command_line` ルールは、`&&`（AND）、`||`（OR）、`&`（連続実行）といった演算子を用いて、複数のコマンドを1行に連結する構文を定義します。
`&&` は左のコマンドが成功した場合に右を実行し、`||` は失敗した場合に実行する演算子です。
また、`&` は単純に左のコマンドに続けて右を実行するための演算子です。
後述する `pipeline` は複数のコマンドをパイプラインで結合するための構文ルールですが、パイプラインがなければ1つのコマンドとなります。

例えば、以下のようなdirでCドライブの内容をファイルに保存成功したらechoするだけのMS-DOSコマンドファイルを構文解析するとします。

```batch
dir C:\ > output.txt && echo "dir command was successful."
```

上記の内容を構文解析すると、以下の構文解析木が出力されます。
なお、読みやすさ優先で出力結果を一部を手で修正しています。

```
program
  command_line
    command_oneline
      command_exe
        dir C:\ 
      redirect_stdout
        > output.txt
    &&
    command_echo
      echo "dir command was successful."
```

#### `pipeline` (パイプライン)
```lark
?pipeline: command (PIPE WS_INLINE? command)*
PIPE: "|"
```
パイプライン処理は `pipeline` ルールによって定義されます。
これは、`|` 記号を使い、あるコマンドの標準出力を別のコマンドの標準入力へと渡すための構文です。

例えば、以下のようなdirの出力結果から条件に一致する行を検索するMS-DOSコマンドファイルを構文解析するとします。

```batch
dir | find "bytes"
```

上記の内容を構文解析すると、以下の構文解析木が出力されます。

```
program
  pipeline
    command_exe
      dir
    |
    command_exe
      find
      "bytes"
```

#### `group` (コマンドのグループ化)
```lark
?command: command_oneline
        | PAREN_LEFT subprogram PAREN_RIGHT ... -> group
```

コマンドの構文ルールについて、丸括弧 `()` で囲まれていないときは、単一のコマンド `command_oneline` として解析します。
一方で、丸括弧 `()` で囲まれているときは別名の `group` ルールとして解析します。
`group` ルールは、丸括弧 `()` を用いて複数のコマンドを一つのブロックとしてまとめる構文を定義します。
この機能は、主に `if` 文や `for` 文の内部で、複数の処理を条件に応じて実行する場合などに必要です。
括弧内のコードは `subprogram` という、グループ内で完結するサブスクリプトとして解析されます。

例えば、以下のようなif文のMS-DOSコマンドファイルを構文解析するとします。

```batch
if exist file.txt (
    echo file.txt exists.
    del file.txt
)
```

上記の内容を構文解析すると、以下の構文解析木が出力されます。
なお、読みやすさ優先で出力結果を一部を手で修正しています。

```
program
  statement_if
    if
    test_exist
      exist file.txt
    group
      (
      subprogram
        command_echo
          echo file.txt exists.
        command_exe
          del file.txt
      )
```

### 4.3 ステートメント

`if` や `for` のような、より複雑なロジックを担う構文はステートメントとして定義されます。

#### `statement_if`
```lark
statement_if: IF WS_INLINE test WS_INLINE line (WS_INLINE? statement_else?)
test: ...
```
`statement_if` は、条件分岐を実現する `if` 文を定義します。
このルールでは、`else` 句が省略可能であることも示されています。
`if`文の核心は `test` ルールにあります。
ここでは `if "%A%"=="B"` のような文字列比較 (`test_comp`)、`if exist file.txt` のようなファイル存在確認 (`test_exist`)、`if defined MY_VAR` のような変数定義確認 (`test_defined`)、そして `if errorlevel 1` のような終了コード判定 (`test_errorlevel`) といった、多彩な条件式が定義されています。

例えば、以下のようなif-else文で書かれたMS-DOSコマンドファイルを構文解析するとします。

```batch
if /i "%ANSWER%" equ "YES" (
    echo OK
) else (
    echo NG
)
```

上記の内容を構文解析すると、以下の構文解析木が出力されます。
なお、読みやすさ優先で出力結果を一部を手で修正しています。

```
program
  statement_if
    if
    test_comp
      /i "%ANSWER%" equ "YES"
    group
      (
      subprogram
        command_echo
          echo OK
      )
    statement_else
      else
      group
        (
        subprogram
          command_echo
            echo NG
        )
```


#### `statement_for`
```lark
statement_for_f: FOR "/f" for_parameter IN PAREN_LEFT for_range PAREN_RIGHT DO line
statement_for_l: FOR "/l" for_parameter IN PAREN_LEFT for_range_start_step_end PAREN_RIGHT DO line
statement_for_r: FOR "/r" ...
```

ループ処理は `statement_for` によって定義されます。
CMDの `for` コマンドは非常に多機能であるため、文法定義もオプションごとに細分化されています。
例えば、`/f` オプションはファイル内容やコマンド結果を行単位で処理するための `statement_for_f`、`/l` オプションは数値範囲でループするための `statement_for_l`、`/r` オプションはディレクトリを再帰的に探索するための `statement_for_r` といったルールがそれぞれ用意されています。

例えば、以下のようなfor文で書かれたMS-DOSコマンドファイルを構文解析するとします。

```batch
rem "test.txt"の各行を処理
for /f "delims=" %%a in (test.txt) do echo LINE: %%a
```

上記の内容を構文解析すると、以下の構文解析木が出力されます。
なお、読みやすさ優先で出力結果を一部を手で修正しています。

```
program
  command_rem
    rem "test.txt"の各行を処理
  statement_for_f
    for
    /f
    "delims="
    for_parameter
      %%a
    in
    (
    for_range_filename	test.txt
    )
    do
    command_echo
      echo LINE: %%a
```

### 4.4 基本コマンド

`set` や `echo` のように頻繁に使用される基本的なコマンド群も、それぞれ専用のルールを持っています。

#### `command_set`

```lark
command_set: SET ... VARIABLE_NAME ... EQ ARG_VALUE_IN_SET?
```
`command_set` ルールは、`set` コマンドによる環境変数の代入操作を定義します。この定義には、`/a` オプションによる数値計算や `/p` オプションによるユーザー入力の受付といった派生的な使い方も含まれています。

以下はサンプルのMS-DOSコマンドファイルとその解析結果の構文木の内容です。

```batch
set MyVar=Hello World
set /a Counter=1+1
```

```
program
  command_set
    set
    MyVar
    =
    Hello World
  command_set_expr
    set
    /a
    Counter
    =
    1+1
```

#### `command_echo`

```lark
command_echo: ECHO ... ARG_VALUE_IN_PAREN? | ECHODOT ...
```
`command_echo` は、`echo` コマンドによる文字列表示を定義するルールです。
また、改行のみを出力する `echo.` という特殊なケースも `ECHODOT` という専用のルールで明確に区別して扱います。

以下はサンプルのMS-DOSコマンドファイルとその解析結果の構文木の内容です。

```batch
echo Hello
echo.
```

```
program
  command_echo
    echo
    Hello
  command_echo	echo.
```

#### `command_call` / `command_goto`

`call` と `goto` は、スクリプトの実行フローを制御する重要なコマンドです。
`call` は別のバッチファイルや、コロンで定義されたサブルーチン（ラベル）を呼び出すために使われます。
一方、`goto` は指定されたラベルへ無条件に実行をジャンプさせます。

以下はサンプルのMS-DOSコマンドファイルとその解析結果の構文木の内容です。

```batch
call :subroutine
goto :end
```

```
program
  command_call_label
    call
    label
      :subroutine
  command_goto
    goto
    :end
```

#### `command_exe`

```lark
command_exe: FILEPATH WS_INLINE ARG_VALUE_IN_PAREN?
```

これまでに挙げたどの専用ルールにも一致しないコマンドは、この汎用的な `command_exe` ルールによって「外部コマンド実行」として解釈されます。
`copy`, `del`, `xcopy` といった標準コマンドや、ユーザーが作成した独自の実行ファイルなどがこれに該当します。

```batch
copy "C:\source\data.txt" "D:\backup\"
MyApplication.exe /param1 /param2
```

以下はサンプルのMS-DOSコマンドファイルとその解析結果の構文木の内容です。

```
program
  command_exe
    copy
    "C:\source\data.txt" "D:\backup\"
  command_exe
    MyApplication.exe
    /param1 /param2
```

### 4.5 リダイレクト

```lark
?redirect: redirect_stdout | redirect_stderr
redirect_stdout: IO1_REDIRECT ... REDIRECT_TARGET
```

`redirect` ルールは、コマンドの出力をファイルなどへ切り替えるリダイレクト構文を定義します。
これには、標準出力を上書きまたは追記する `>` や `>>`、そして標準エラー出力を扱う `2>` などが含まれます。

```batch
rem 標準出力をlog.txtに上書き
dir > log.txt

rem 標準エラー出力をerror.logに追記
some_command 2>> error.log
```

```
program
  command_rem
    rem
    標準出力をlog.txtに上書き
  command_oneline
    command_exe
      dir
    redirect_stdout
      >
      log.txt
  emptyline	
  command_rem
    rem
    標準エラー出力をerror.logに追記
  command_oneline
    command_exe
      some_command
    redirect_stderr
      2>>
      error.log
```

### 4.6 最も複雑なルール：引数と値

CMD構文の解析において最大の難関となるのが、コマンドの引数部分です。なぜなら、引数の中にはリダイレクト演算子 (`>`, `<`) やコマンド連結演算子 (`&`) といった、文法上特別な意味を持つ文字が含まれうるからです。

#### `ARG_VALUE_IN_SET` / `ARG_VALUE_IN_PAREN`

```lark
ARG_VALUE_IN_SET: / ... /x
ARG_VALUE_IN_PAREN: / ... /x
```
これらのターミナルは、そうした曖昧さを解決するために作られた、非常に複雑な正規表現で定義されています。
その主な役割は、「ここからここまでが単一の引数（または `set` コマンドの値）である」という範囲を、可能な限り長く、貪欲に（greedily）読み取ることです。

この解析を実現するため、正規表現内ではいくつかの工夫が凝らされています。
まず、`^.` のようなエスケープ文字や `"(...)"` といった引用符で囲まれた部分を優先的に一つの塊として解釈します。
さらに `set` コマンドの値 (`ARG_VALUE_IN_SET`) では、SQL文でよく使われる `<>` のような記号がリダイレクトと誤認されないよう、特定のパターンが許容されています。
一般的なコマンドの引数 (`ARG_VALUE_IN_PAREN`) では、行末、リダイレクト演算子、または連結演算子の手前までを引数として切り取るように動作します。

```batch
rem ARG_VALUE_IN_PAREN が "Hello > World" 全体を引数として解釈する
echo "Hello > World"

rem ARG_VALUE_IN_SET が "select * from T where F <> 'A'" 全体を値として解釈する
set SQL="select * from T where F <> 'A'"
```

さらに、MS-DOSの動作では、丸括弧 `( )` で囲まれた部分ではコマンド引数の解釈方法が変わり、引数内に存在する丸括弧のペアは引数の一部として解釈されますが、丸括弧閉じ `)` だけのときは引数の一部として解釈されないような動作となります。
そのため、丸括弧 `( )` で囲まれていないトップレベルのコマンドに渡されるコマンドライン引数は `ARG_VALUE_IN_PAREN_TOPLEVEL` ルールで定義し、丸括弧 `( )` に囲まれているコマンドに渡されるコマンドライン引数は `ARG_VALUE_IN_PAREN` ルールとして定義しています。
コマンドも同様に、トップレベルでコマンドが呼ばれるため丸括弧を無視して解析する `command_set_toplevel` ルールと、丸括弧 `( )` の中でコマンドが呼ばれるので丸括弧を考慮して解析する `command_set` の2種類が用意されています。
ここでは set コマンドを例に説明していましたが、他のコマンドも同様です。


## 参考資料

- [tex2e/msdos-cmd-parser: MS-DOS Command Parser](https://github.com/tex2e/msdos-cmd-parser)
