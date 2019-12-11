---
layout:        post
title:         "OOP in Java"
date:          2016-12-03
category:      Java
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

Javaにおけるオブジェクト指向のまとめ

目次
-------

- [クラスの定義](#class)
- [コンストラクタ、フィールド、メソッド](#constructor)
- [クラスメソッド、クラス変数](#class-method)
- [アクセス権](#access)
- [オーバーロード](#overload)
- [継承、オーバーライド](#extends)
- [抽象クラス](#abstract)
- [インターフェース](#interface)
- [ジェネリックス](#generics)


<a name="class"></a>

クラスの定義
-----------

- `class` というキーワードでクラスを宣言
- `new クラス名()` でインスタンスの生成

```java
class Foo {}

Foo foo = new Foo();
```


<a name="constructor"></a>

コンストラクタ、フィールド、メソッド
------------------------------

- クラス名と同名の関数を宣言するとコンストラクタになります
 （コンストラクタの返り値は書かない）
- フィールドとメソッドのアクセス修飾子を省略した場合は、
  同一パッケージからアクセスできるメンバとなります

```java
class Point {
    public int x;
    public int y;

    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public Point add(Point other) {
        return new Point(this.x + other.x, this.y + other.y);
    }

    public String toString() {
        return "(" + this.x + ", " + this.y + ")";
    }
}


public class Main {
    public static void main(String[] args) {
        Point p1 = new Point(1, 2);
        Point p2 = new Point(3, 4);
        System.out.println( p1.add(p2) );
    }
}
```


<a name="class-method"></a>

クラスメソッド、クラス変数
------------------------------

- クラスメソッドは `static` 修飾子を使います
- クラス変数も `static` 修飾子を使います

```java
class User {
    // staticフィールド
    private static int userNum = 0;

    // staticメソッド
    public static int getUserNum() {
        return userNum;
    }

    public User() {
        userNum++;
    }
}


public class Main {
    public static void main(String[] args) {
        System.out.println(User.getUserNum()); //=> 0
        User user1 = new User();
        User user2 = new User();
        System.out.println(User.getUserNum()); //=> 2
    }
}
```


<a name="access"></a>

アクセス権
-----------

アクセス修飾子は public と private と protected の3種類あります。
アクセス修飾子を省略した場合は、同一パッケージからアクセスできるようになります。
なので、基本的には全てのメンバにアクセス修飾子をつけるのが、混乱が少なくて良いと思います。


<a name="overload"></a>

オーバーロード
-------------

同じ名前のメソッドを定義することでオーバーロードすることができます。

```java
class Sample {
    public static int foo(int x) {
        return x + 1;
    }
    public static String foo(String x) {
        return x + "1";
    }
}

public class Main {
    public static void main(String[] args) {
        System.out.println( Sample.foo(123) );   // => 124
        System.out.println( Sample.foo("123") ); // => 1231
    }
}
```


<a name="extends"></a>

継承、オーバーライド
------------------

- 継承をするには `class 子クラス extends 親クラス` と書きます
- 親クラスへの参照は `super` を使います
- オーバーライドをするには、`@Override` アノテーションをメソッド宣言の前に付けます

```java
class Point {
    public int x;
    public int y;

    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public String toString() {
        return "(" + this.x + ", " + this.y + ")";
    }
}

class Point3D extends Point {
    public int z;

    public Point3D(int x, int y, int z) {
        super(x, y);
        this.z = z;
    }

    @Override
    public String toString() {
        return "(" + this.x + ", " + this.y + ", " + this.z + ")";
    }
}


public class Main {
    public static void main(String[] args) {
        System.out.println( new Point(1, 2) );      // => "(1, 2)"
        System.out.println( new Point3D(1, 2, 3) ); // => "(1, 2, 3)"
    }
}
```


<a name="abstract"></a>

抽象クラス
-----------------------

抽象クラス・抽象メソッドを定義するには、`abstract` キーワードを付けます。

```java
// 抽象クラスの定義
abstract class AbstractMusic {
    public abstract void play();
    public abstract void stop();
}

class Music extends AbstractMusic {
    @Override
    public void play() {
        System.out.println("play!");
    }

    @Override
    public void stop() {
        System.out.println("stop!");
    }
}


public class Main {
    public static void main(String[] args) {
        Music music = new Music();
        music.play(); // => "play!"
    }
}
```


<a name="interface"></a>

インターフェース
-----------------------

インターフェースを定義するには、`interface` キーワードを付けます。

```java
interface USBInterface {
    public static final float USB_VERSION = 3.0;
    public abstract boolean connectUSB();
    public abstract boolean disconnectUSB();
}

// Printerクラス は USBInterface を実装する
class Printer implements USBInterface {
    public boolean connectUSB() {
        // ...
    }

    public boolean disconnectUSB() {
        // ...
    }

    public boolean print(PDF pdf) {
        // ...
    }
}
```

また、Java8ではインターフェースに「デフォルトメソッド」を定義できるようになりました。

```java
interface GreetingInterface {
    default String sayHello() {
        return "Hello Java8!";
    }
}

class GreetingInterfaceImpl implements GreetingInterface {}


class Main {
    public static void main(String[] args) {
        System.out.println(new GreetingInterfaceImpl().sayHello());
        // => Hello Java8!
    }
}
```

<a name="generics"></a>

ジェネリックス
------------------

- ジェネリックを定義するには、`class クラス名<仮の型名>` と書きます
- 型を制限することもできます
    - `<仮の型名 extends 他のクラス名>` と書けば、他のクラスを派生しているクラスに限定することができます
    - `<仮の型名 super 他のクラス名>` と書けば、他のクラスが継承しているクラスに限定することができます
- 型を制限するときは、クラス名だけでなく、インターフェース名で指定することも可能です

```java
// Rangeクラスは、上界と下界を持つ範囲クラス
// T型はComparableインターフェースに限定
class Range<T extends Comparable<T>> {
    T begin;
    T end;

    public Range(T begin, T end) {
        if (begin.compareTo(end) > 0) {
            throw new RuntimeException("Range: warning: *begin* must be less than *end*");
        }
        this.begin = begin;
        this.end   = end;
    }

    public boolean include(T item) {
        return (item.compareTo(begin) >= 0 && item.compareTo(end) < 0);
    }
}


public class Main {
    public static void main(String[] args) {
        Range<Integer> intRange = new Range<Integer>(new Integer(1), new Integer(9));
        System.out.println(intRange.include(5)); // => true

        Range<String> stringRange = new Range<String>("a", "e");
        System.out.println(stringRange.include("c")); // => true
        System.out.println(stringRange.include("z")); // => false
    }
}
```
