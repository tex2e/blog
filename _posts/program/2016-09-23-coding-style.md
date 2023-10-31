---
layout:        post
title:         "Coding Style Guide"
date:          2016-09-23
category:      Program
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from: /misc/coding-style
comments:      false
published:     true
---

どの言語でも言えるコーディングスタイルのまとめ

Naming Conventions
------------------

### 全般

変数名などの名前は基本的に省略しない。他のプログラマが読んでもわかるように命名すること。
ただし、慣例的に省略されるもの（HTTPなど）は省略形を使う。

名前を決める際は、最初に英文を作って、定冠詞（a,the）や省略可能な単語（thatなど）を省くことで、
すっきりとした変数名になる（と思う）


### 変数名

書き方は、キャメルケースとスネークケースの2通りがある

- `camelCaseVar`（ java や c# や javascript など）
- `snake_case_var`（ ruby や python や c など）

変数はできるだけ、名詞にする

- `userName`（利用者名）
- `drop_pos`（落下位置）（\*「a drop」で名詞）

真偽値（boolean）の場合は、先頭に is, has, can などを付けて疑問系にする

- `isBudgetLimited = true`（予算が限られているか = はい）
- `can_use_camera = false`（カメラ機能が使えるか = いいえ）

配列の場合は、末尾に s を付けて複数形にする

- `members = ["Alice", "Bob"]`


### 定数名

書き方は、すべて大文字で、単語区切りはアンダースコアを使う

- `UPPER_CASE_CONST`


### 関数名

書き方は、キャメルケースとパスカルケースとスネークケースの3通りがある

- `camelCaseFunc()`（ java や javascript など）
- `PascalCaseFunc()`（ c# など）
- `snake_case_func()`（ ruby や python や c など）

基本的に、動詞から書き始める

- `getAge()`（年齢を取得 → 整数を返す）
- `getUsers()`（利用者の一覧を取得 → 配列やリストを返す）
- `CheckPhoneNumber()`（電話番号を確認する → 真偽値を返す）
- `send_email_to(alice)`（引数の人にメールを送る）

検索を行う関数

- find\*, search\*

生成を行う関数

- make\*, create\*, generate\*, build\*

状態の確認を行う関数

- check\*, validate\*, contain\*, include\*, exist\*



### クラス名・モジュール名・インターフェース名

書き方は、パスカルケース

- `PascalCaseClass`

インターフェースの名前は、先頭に`I`を付けたり、`-able`の形にすることがある

- `IEnumerable`（ c# のコレクションのインターフェース）
- `Enumeration`（ java のコレクションのインターフェース）



Functions
---------

- 関数内では、if文をネストさせてはいけない。__ガード節__（guard clause）を使う。
- 引数が複数行になる場合は、改行後にインデントを2つ以上置く

~~~ java
void func(String argument1, int argument2, int argument3,
        Object argument4, Object argument5) {
    doSomething();
}
~~~


Statements
----------

- 制御構文と関数名を区別するため、制御構文の後には空白を一つ入れる
    - 制御構文 : 空白を入れる (例：`if (true)`)
    - 関数 : 空白を入れない (例：`func()`)

#### if 文

- 条件式が複数行になる場合は、改行後にインデントを2つ以上置く

~~~ java
if ((condition1 && condition2)
        || (condition3 && condition4)
        ||!(condition5 && condition6)) {
    doSomething();
}
~~~

- 単純な if-else なら、三項演算子（条件演算子）を使う

~~~ java
result = (score >= 60) ? "success" : "failure";
~~~

#### for 文

- インクリメント（もしくはデクリメント）を強調したいときは、for文を使う

#### while 文

- 条件によっては無限ループになることを強調したいときは、while文を使う

#### do-while 文

- __do-while 文は無くてもプログラミングができるので、使わない__
（条件を最初に書いたほうが、コードを直線的に読むことができるため）

~~~ java
// No
do {
    input_num = gets(stdin);
} while (!validate(input_num));

// Yes
while (true) {
    input_num = gets(stdin);
    if (validate(input_num)) break;
}
~~~


#### switch 文

- if 文を大量に並んでしまう場合は、switch 文に書き直せないか検討する
- 明示的に、次のcase文に突入させたい場合は、そのcase文の終わりに `// falls through` とコメントする

~~~ java
switch (condition) {
    case ABC:
        process1();
        // falls through
    case DEF:
        process2();
        break;
    case GHI:
        process3();
        break;
    default:
        process4();
}
~~~

- 変数に対して、どのクラスのインスタンスなのか調べるために switch 文を使っている場合は、
ポリモーフィズムで書き換えられないか検討すること

- Python のように switch 文がないプログラミング言語では、if-elseif-else 文を大量に並べる代わりに、
Dict（連想配列）を使うとスマートに書ける

```python
wday = 1

# No
if wday == 0:
    do_something1()
elif wday == 1:
    do_something1()
elif wday == 2:
    do_something2()
# continues...

# Yes
wday_abbrs = {0: "Sun", 1: "Mon", 2: "Tue", ...}
wday_abbr = wday_abbrs[wday]
```


Classes
-------

クラスの中での定義の順番

1. クラス定数
2. publicフィールド
3. protectedフィールド
4. privateフィールド
5. コンストラクタ
6. publicメソッド
7. protectedメソッド
8. privateメソッド


See also
--------

- [Ruby - ruby-style-guide](https://github.com/bbatsov/ruby-style-guide)
- [Python - PEP8](https://www.python.org/dev/peps/pep-0008/)
- [Google Style Guides](https://github.com/google/styleguide)
- [JavaScript - ja_JP](https://github.com/cou929/Japanese-Translation-of-Google-JavaScript-Style-Guide/blob/master/index.rst)
- [Java - Oracle](http://www.oracle.com/technetwork/java/codeconventions-150003.pdf)
- [C# - Coding Standards for .NET](http://se.inf.ethz.ch/old/teaching/ss2007/251-0290-00/project/CSharpCodingStandards.pdf)
- [C Coding Standard](http://users.ece.cmu.edu/~eno/coding/CCodingStandard.html)
- [GNU Coding Standards](https://www.gnu.org/prep/standards/standards.pdf)
