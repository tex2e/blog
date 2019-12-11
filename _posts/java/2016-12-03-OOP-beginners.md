---
layout:        post
title:         "Object Oriented Programming"
date:          2016-12-03
category:      Java
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

オブジェクト指向プログラミング教育用の資料

目次
-------

- [はじめに](#preface)
- [オブジェクト指向とは](#introduce)
- [オブジェクトとは](#object)
- [クラスとは](#class)
- [自作クラス](#build-class)
- [コンストラクタとは](#constructor)
- [thisキーワード](#this)
- [オーバーロード](#overload)
- [アクセス権](#access)
- [クラスメソッドとクラス変数](#static)
- [継承とは](#extends)
- [オーバーライドとは](#override)
- [インターフェースとは](#interface)
- [抽象クラスとは](#abstract)

<a name="preface"></a>

はじめに
-------

このドキュメントは、オブジェクト指向を教えるために用意した資料です。
このドキュメントが新米プログラマの教育担当の方の役に立てば、との思いで作成しております。
fork や pull request は自由にしてもらっても構いません。
新出単語は __太字__ で表しています。

<a name="introduce"></a>

オブジェクト指向とは
-----------------

#### 背景

オブジェクト指向が登場する以前、ソフトウェアに対する需要はまだ少なく、
大規模なものでも十分なお金と時間をかけることができました。

しかし、その後私達の生活のあらゆる部分にコンピュータが使われるようになり、
ソフトウェアに対する需要は高まりました。
そのため、品質の良いソフトウェアを短期間でより多く開発しなくてはならない状況になりました。
そして「面倒なプログラミングの作業を楽にしたい」という要望が増えました。

結果として、__オブジェクト指向言語__ と、
それを用いた開発方法、つまり __オブジェクト指向設計手法__ が生まれたのです。

#### 現在

今では、有名なプログラミング言語の大半はオブジェクト指向が使えるようになりました。
つまり、この世にあるほとんどのソフトウェアはオブジェクト指向で書かれているとも言えます。

<a name="object"></a>

オブジェクトとは
--------------

フィールドやメソッドを持つものを __オブジェクト__ と呼びます。

__フィールド__ とはオブジェクトが持つ「情報を保存する場所」のことを指します。フィールドは「変数」に似ています。
__メソッド__ とは、オブジェクトが持つ「情報を処理する場所」のことを指します。メソッドは、「関数」に似ています。

また、オブジェクトのフィールドとメソッドをまとめて __メンバ__（member）と呼ぶことにします。

#### 具体例

次のスニペットは、フィールドとメソッドの使い方を示したものです。

Java

~~~ java
// x は座標（オブジェクト）のフィールド
point.x

// size() は配列（オブジェクト）のメソッド
array.size()
~~~

<a name="class"></a>

クラスとは
---------

オブジェクトのフィールドとメソッドを定義したものを __クラス__ と呼びます。
Javaには多くのクラスがすでに定義されています。
String、ArrayやArrayListなどの大文字から始まる型の名前は全てクラスです。

また、クラスを元にしてできた新たなオブジェクトを __インスタンス__ と呼び、
`new`してインスタンスを作ることを __インスタンスの生成__ または __インスタンス化__ と呼びます。

#### 具体例

Java

~~~ java
// 変数ary は Arrayクラス のインスタンス
Array[] ary = new Array[5];

// 変数str は Stringクラス のインスタンス
String str = new String("apple");

// Stringクラスにおける、別のインスタンスの生成方法（推奨）
String str = "apple";
~~~

<a name="build-class"></a>

自作クラス
---------

クラスは自分で作成することもできます。
説明のために、ここでは座標を表すためのPointクラスを作成していきます。

#### フィールドの定義例

はじめに、フィールドのみで構成される簡単なPointクラスを定義します。

Main.java

~~~ java
package your_package_name;

public class Main {
    public static void main(String[] args) {
        Point point = new Point();
        point.x = 3;
        point.y = 4;
        System.out.println(point.x); //=> 3
        System.out.println(point.y); //=> 4
    }
}

// クラスの定義
class Point {
    // フィールドの定義
    public int x;
    public int y;
}
~~~

フィールドへの代入は `point.x = 3` 、フィールドへのアクセスは `point.x` のようにします。


#### メソッドの定義例

次に、フィールドである座標と原点との距離を返す関数 distance を作成します。
原点との距離は、公式 √(x^2 + y^2) を使います。

Main.java

~~~ java
package your_package_name;

public class Main {
    public static void main(String[] args) {
        Point point = new Point();
        point.x = 3;
        point.y = 4;
        System.out.println(point.distance()); //=> 5.0
    }
}

// クラスの定義
class Point {
    // フィールドの定義
    public int x;
    public int y;

    // メソッドの定義
    double distance() {
        return Math.sqrt(x*x + y*y);
    }
}
~~~


<a name="constructor"></a>

コンストラクタとは
---------------

演算子`new`でインスタンス化するための処理は、
__コンストラクタ__ と呼ばれるメソッドを定義することによって行われます。

コンストラクタを定義することで、
インスタンス化する際に `new Point(3, 4)` のように引数を渡して初期化を行うことができます。

Main.java

~~~ java
package your_package_name;

public class Main {
    public static void main(String[] args) {
        Point point = new Point(3, 4);
        System.out.println(point.distance()); //=> 5.0
    }
}

class Point {
    public int x;
    public int y;

    // コンストラクタの定義
    Point(int _x, int _y) {
        x = _x;
        y = _y;
    }

    double distance() {
        return Math.sqrt(x*x + y*y);
    }
}
~~~

コンストラクタを用いたことにより、インスタンスの初期化が楽になりました。


<a name="this"></a>

thisキーワード
-------------

__this__ キーワードを使うことで、フィールドの変数と関数の引数の変数を、区別することができます。
セクション「[コンストラクタ](#constructor)」のコンストラクタ定義部分のコードと比較しながら見てください。

Java

~~~ java
class Point {
    public int x;
    public int y;

    // コンストラクタの定義
    Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    // ...
}
~~~


<a name="overload"></a>

オーバーロード
------------

関数名は同じだが、引数の数または種類が異なる関数を定義することを、
__オーバーロード__ もしくは多重定義と呼びます。

#### 具体例

原点からの距離を求める関数 `distance()` があります。
それに加えて、引数に Point型 の変数を与えると、
自分の座標と引数の座標との距離を返す関数 `distance(Point other)` を定義します。
関数 distance におけるオーバーロードの例です。

Main.java

~~~ java
package your_package_name;

public class Main {
    public static void main(String[] args) {
        Point point = new Point(3, 4);
        Point otherPoint = new Point(15, 20);

        System.out.println(point.distance()); //=> 5.0
        System.out.println(point.distance(otherPoint)); //=> 20.0
    }
}

class Point {
    public int x;
    public int y;

    // ...

    // 自分の座標と原点との距離を求める
    double distance() {
        return Math.sqrt(x*x + y*y);
    }

    // 自分の座標と他の座標との距離を求める
    double distance(Point other) {
        double xDiff = this.x - other.x;
        double yDiff = this.y - other.y;
        double dist = Math.sqrt(
            Math.pow(xDiff, 2) +
            Math.pow(yDiff, 2)
        );
        return dist;
    }
}
~~~

2点間の距離は、公式 √((x1 - x2)^2 + (y1- y2)^2) を使います。



<a name="access"></a>

アクセス権
---------

__アクセス修飾子__ を使うことでフィールドやメソッドのアクセス権を制御することができます。

アクセス修飾子は __public__, 記述なし(__default__), __protected__, __private__ の4種類あります。
下に行くほどアクセス権が厳しくなります。

- `public variable;`
- `public function() { ... }`
    - 同一パッケージ、外部パッケージからアクセスできる（どこからでもアクセスできる）
- `variable;`
- `function() { ... }`
    - 同一パッケージからのみアクセスできる
- `protected variable;`
- `protected function() { ... }`
    - 同一パッケージ、自クラス、自クラスのサブクラスのみからアクセスできる
- `private variable;`
- `private function() { ... }`
    - 自クラスからのみアクセスできる

#### 具体例

フィールドやメソッドにおけるアクセス権の検証

Main.java

~~~ java
package your_package_name;

public class Main {
    public static void main(String[] args) {
        AccessTest accessTest = new AccessTest();

        System.out.println(accessTest.public_var);
        System.out.println(accessTest.default_var);
        System.out.println(accessTest.protected_var);
        System.out.println(accessTest.private_var); // エラー発生!

        accessTest.public_func();
        accessTest.default_func();
        accessTest.protected_func();
        accessTest.private_func(); // エラー発生!
    }
}

class AccessTest {
    // 順に public, (default), protected, private

    public int public_var = 1;
    int default_var = 1;
    protected int protected_var = 1;
    private int private_var = 1;

    public void public_func() {}
    void default_func() {}
    protected void protected_func() {}
    private void private_func() {}
}
~~~

public, (default), protected 修飾子をつけると、
クラスの外からアクセスされるべきでないフィールドの中身が書き換えられてしまったり、
クラス内でしか使わないメソッドがクラスの外から勝手に起動させられたりするので、
基本的に全て private にして、公開する機能だけ public にしましょう。

クラス内のメンバは全て private または public にするのが一般的なので、
ここでは public, (default), protected 修飾子の使い分けを説明しません。（説明が面倒くさい）

また、クラスにも public修飾子 または (default)修飾子 をつけることができます。

- `public class ClassName { ... }`
    - このパッケージが、外部のパッケージに使われる際に、このクラスにアクセスできる
    - 同一パッケージ内からもアクセスできる
- `class ClassName { ... }`
    - このパッケージが、外部のパッケージに使われる際に、このクラスにアクセスでき __ない__
    - 同一パッケージ内からはアクセスできる



<a name="static"></a>

クラスメソッドとクラス変数
-----------------------

メソッドに __static__ 修飾子を付けると、そのメソッドはクラスにとって唯一のメソッドとなり、
インスタンスの生成しなくてもそのメソッドを使うことができます。
クラスにとって唯一のメソッドのことを、__クラスメソッド__ と呼ぶことにします。
なお、クラスメソッドは特性上、staticでないフィールドやメソッドにはアクセスできません。

フィールドに __static__ 修飾子を付けると、そのフィールドはクラスにとって唯一のフィールドとなり、
インスタンスを生成しなくてもそのフィールドを使うことができます。
クラスにとって唯一のフィールドのことを、__クラス変数__ と呼ぶことにします。

#### 具体例

現在のユーザ数を記録する クラス変数 userNum と現在のユーザ数を返す クラスメソッド  getUserNum を持つクラス User を作成する

Main.java

~~~ java
package your_package_name;

public class Main {
    public static void main(String[] args) {
        System.out.println(User.getUserNum()); //=> 0
        User user1 = new User();
        User user2 = new User();
        User user3 = new User();
        System.out.println(User.getUserNum()); //=> 3
    }
}

class User {
    private static int userNum = 0;

    static int getUserNum() {
        return userNum;
    }

    // Userのインスタンスが生成されるごとに ユーザ数 を +1 する
    User() {
        userNum++;
    }
}
~~~

デストラクタがある言語は、
「Userのインスタンスが消される（メモリから解放される）ごとに ユーザ数 を -1 する」
という処理があってもいいでしょう。



<a name="extends"></a>

継承とは
-------

あるクラスの性質を引き継いでクラスを作ることを __継承__ と呼びます。
継承元になった親クラスを __スーパークラス__、継承した子クラスを __サブクラス__ と呼びます。

スーパークラスを継承することによって、
そのクラスの public または protected なフィールドとメソッドが
サブクラスで使えるようになります。

#### 具体例

次に、Pointクラスは2次元の座標しか扱えないので、
このクラスを継承して3次元座標を扱えるPoint3Dクラスを作成します。

さらに、3次元空間における原点からの距離を返す関数 distance3d を新たにPoint3Dクラスで定義します。

Main.java

~~~ java
package your_package_name;

public class Main {
    public static void main(String[] args) {
        Point3D point3d = new Point3D(3, 4, 5);
        System.out.println(point3d.distance()); //=> 5
        System.out.println(point3d.distance3d()); //=> 7.07...
    }
}

class Point {
    public int x;
    public int y;

    Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    double distance() {
        return Math.sqrt(x*x + y*y);
    }
}

// Pointクラス を継承した Point3Dクラス の定義
class Point3D extends Point {
    public int z;

    // コンストラクタの定義
    Point3D(int x, int y, int z) {
        super(x, y);  //< スーパークラスのコンストラクタを呼んでいる
        this.z = z;
    }

    // Point3dクラスで、新しいメソッドの定義
    double distance3d() {
        return Math.sqrt(x*x + y*y + z*z);
    }
}
~~~




<a name="override"></a>

オーバーライドとは
----------------

スーパークラスから継承したメソッドを再定義することを __オーバーライド__ と呼びます。

#### 具体例

スーパークラスの関数 distance をサブクラスでオーバーライドする例です。

Java

~~~ java
class Point {
    public int x;
    public int y;

    // ...

    double distance() {
        return Math.sqrt(x*x + y*y);
    }
}

class Point3D extends Point {
    public int z;

    // ...

    // スーパークラスから継承したメソッドを再定義（上書き）する
    @Override
    double distance() {
        return Math.sqrt(x*x + y*y + z*z);
    }
}
~~~

オーバーライドをする関数の前に `@Override` を追加します。
この`@`から始まる注釈を __アノテーション__ と呼びます。
アノテーションは付けなくてもオーバーライドはできますが、
これを付けるとコンパイラに「このメソッドはオーバーライドするんだよ」と伝えることができます。

アノテーションを加えることで、次のような利点があります。

- コンパイル時に、正しくオーバーライドできていないときには、警告してくれる
- どのメソッドがオーバーライドしているのか、視覚的に分かりやすい

補足）英語で上書きは「overwrite」ですが、オーバーライドの綴りは「override」です。



<a name="interface"></a>

インターフェースとは
-----------------

オブジェクトのメソッド名を「規定」するためのものを __インターフェース__ と呼びます。
また、そのインターフェースの規定に従ってクラスを作ることを、
（クラスの）__インターフェースを実装する__ といいます。

インターフェースには、__抽象メソッド__ を定義します。
抽象メソッドとは中身のない名前だけのメソッドのことです。
__abstract__ 修飾子を付けることで抽象メソッドを作ることができます。

以下のリストは、インターフェースにおける修飾子のルールです。

- インターフェースのメソッドは必ず抽象メソッドとなるため、
abstract修飾子 が自動で付けられます。
abstract修飾子は明示的に記述してもいいです（筆者推奨）

- また、インターフェースにフィールドを与えることもできますが、
そのフィールドは必ず唯一の定数となるため、static修飾子 と final修飾子 が自動で付けられます。
staticとfinal修飾子は明示的に記述してもいいです（筆者推奨）

- さらに、全てのメンバは必ず public となるため、public修飾子 が自動で付けられます。
public修飾子は明示的に記述してもいいです（筆者推奨）

#### インターフェースの定義例

USBに接続するためのインターフェースの定義例です。

Java

~~~ java
// USBInterface という interface の定義
interface USBInterface {
    // 変数の定義例
    public static final float USB_VERSION = 3.0;

    // メソッドの規定
    public abstract boolean connectUSB();
    public abstract boolean disconnectUSB();
}
~~~

#### インターフェースの実装例

インターフェースの抽象メソッドを実装するのは、インターフェースを実装するクラスです。
「インターフェースを実装する」というのは、抽象メソッドをオーバーライドするような感覚です。

インターフェースを実装する場合は、そのインターフェースの全ての抽象メソッドを実装しないと、警告されます。

この例では Printer は USB接続を行うものとします。

Java

~~~ java
interface USBInterface {
    public static final float USB_VERSION = 3.0;
    public abstract boolean connectUSB();
    public abstract boolean disconnectUSB();
}

// Printerクラス は USBInterface を実装する
class Printer implements USBInterface {
    public boolean connectUSB() {
        // USB接続を行う具体的な処理
        // ...
    }

    public boolean disconnectUSB() {
        // USB接続を切断する具体的な処理
        // ...
    }

    public boolean print(PDF pdf) {
        // pdfファイルを印刷する具体的な処理
        // ...
    }

    // ...
}
~~~

ここまで読まれた方は、
「なんでインターフェースを定義する必要があるの？
インターフェース定義している暇があったら、さっさと実装しろよ（怒）」
と思うかもしれません。
この例では Printer しか使っていないので、そう感じるかもしれません。

では、次の例を考えてみてください。USB接続を行うものはたくさんあります。
外部記憶装置、入力装置、出力装置など。
それらは全てクラスで実装されているのですが、
それぞれが独自にUSBに接続するメソッドを定義していたらどうでしょう。
あるクラスでは `connectUSB()`、別のクラスでは `connect()`、
また別のクラスでは `startConnection()` など。
これらを使うプログラマとしては、全てのクラスの全てのメソッドを把握する必要があり、とても大変です。

そこで、interface を使うとどうなるでしょうか。
プログラマは、使いたいクラスが USBInterface を実装しているか確認するだけで、どのメソッド名を使えばいいのかすぐに理解できるようになります。
また、これから USB接続の処理を実装しようとしているプログラマに、
必要となるメソッドの名前を示唆してくれます。

インターフェースの利点を生かした設計技法は、デザインパターン（別紙：未作成）で詳しく扱いたいと思います。

### ポリモーフィズムとは（補足）

__ポリモーフィズム__（多態性）とは、違うクラスでも同名のメソッドを定義しようという「考え方」です。
これはインターフェースを利用することで、簡単に実現できます。

この例では、Animalインターフェース を使ってポリモーフィズムを実現しました

Main.java

~~~ java
package your_package_name;

public class Main {
    public static void main(String[] args) {
        invokeCall(new Dog());
        invokeCall(new Cat());
    }

    // 引数のオブジェクトに対して call() メソッドを呼び出す
    static void invokeCall(Animal animal) {
        System.out.println(animal.call());
    }
}

// 動物（Animal）は鳴く（call）
interface Animal {
    public abstract String call();
}

class Dog implements Animal {
    // 犬は「ワンワン」と鳴く
    public String call() {
        return "bow, wow!";
    }
}

class Cat implements Animal {
    // 猫は「ミャオ」と鳴く
    public String call() {
        return "meow";
    }
}
~~~

ポリモーフィズムにする利点は、次のようなものがあります。

- メソッド名が統一されているので、覚えやすい・使いやすい
- 決まったメソッドを呼び出すだけなので、条件分岐が不必要になる
（あるインスタンスはDogクラスなのかCatクラスなのか条件分岐で確認する必要がなくなる）


<a name="abstract"></a>

抽象クラスとは
------------

__抽象クラス__ では、抽象メソッドと、中身のあるメソッドの両方を定義することができます。

抽象クラスを使うには、継承される必要があります。（抽象メソッドはオーバーライドされる必要があるため）

抽象メソッドを定義するには、abstract修飾子を付けます。

#### 具体例

このクラスは、ファイルの入出力における、
典型的な try-catch-finally文 を抽象クラスを使ってテンプレート化したものです。

Main.java

~~~ java
// 抽象クラスabstractFileTemplate の定義
abstract class abstractFileTemplate {
    // 保存するテキスト
    protected StringBuilder text;

    // 中身のあるメソッド
    public final void save() {
        try {
            fileOpen();
            write();
        } catch (IOException e) {
            catchException(e);
        } finally {
            fileClose();
        }
    }

    // 抽象メソッド
    protected abstract void fileOpen() throws IOException;
    protected abstract void write() throws IOException;
    protected abstract void catchException(Exception e);
    protected abstract void fileClose();
}
~~~

抽象クラスを使いたいクラスは、`extends`キーワードで抽象クラスを継承します。

~~~ java
// 抽象クラスabstractFileTemplate
abstract class abstractFileTemplate {
    // 抽象メソッドなどの定義
    // ...
}


// 抽象クラスを継承した FileTemplateクラス
class FileTemplate extends abstractFileTemplate {
    FileTemplate(StringBuilder text) {
        this.text = text;
    }

    // 抽象メソッドのオーバーライドなど
    @Override
    protected void fileOpen() throws FileNotFoundException {
        // ファイルオープンの具体的な処理
    }

    @Override
    protected void write() throws IOException {
        // ファイルへの書き込みの具体的な処理
    }

    @Override
    protected void catchException(Exception e) {
        // キャッチした例外に対する具体的な処理
    }

    @Override
    protected void fileClose() {
        // ファイルクローズの具体的な処理
    }
}
~~~

このクラスのインスタンスがファイルの保存をしたいときは `fileTemplate.save()` と書きます。

抽象クラスを使う利点は、次のようなものがあります。

- 複数ある似たようなクラスのロジックを、共通化することができる
- 抽象クラスで処理の流れを形作ることができる
