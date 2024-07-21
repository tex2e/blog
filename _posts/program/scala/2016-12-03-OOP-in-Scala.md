---
layout:        post
title:         "[Scala] オブジェクト指向プログラミング"
date:          2016-12-03
category:      Program
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from: /scala/OOP-in-Scala
comments:      false
published:     true
---

Scalaにおけるオブジェクト指向のまとめ

目次
-------

- [クラスの定義](#class)
- [コンストラクタ、フィールド、メソッド](#constructor)
- [クラスメソッド、クラス変数](#class-method)
- [アクセス権](#access)
- [オーバーロード](#overload)
- [演算子の定義](#operator)
- [継承、オーバーライド](#extends)
- [抽象クラス](#abstract)
- [インターフェース](#interface)
- [拡張メソッド](#extender)


<a name="class"></a>

クラスの定義
-----------

- `class` というキーワードでクラスを宣言
- `new クラス名()` でインスタンスの生成

Scala

```scala
class Foo

val foo = new Foo
```


<a name="constructor"></a>

コンストラクタ、フィールド、メソッド
------------------------------

- コンストラクタ専用の関数はなく、クラス宣言のブロックそのものがコンストラクタとなる
- コンストラクタ（つまりクラス内）で宣言された変数はフィールドとなる
- コンストラクタ（つまりクラス内）で定義された関数はメソッドとなる
- フィールド、メソッドともにデフォルトで public となる

```scala
class Point(var x: Int, var y: Int) {
  def add(other: Point) = {
    new Point(this.x + other.x, this.y + other.y)
  }

  override def toString(): String = "(" + x + ", " + y + ")"
}

val p1 = new Point(3, 4)
val p2 = new Point(1, 5)
println( p1.add(p2) ) // => "(4, 9)"
```

ここでは、クラスのコンストラクタで引数を受け取るのと同時に public なフィールドとして宣言しています。
Java プログラマにも読みやすいように Point クラスのフィールド宣言部を書き下すと次のような感じになります。

```scala
class Point(_x: Int, _y: Int) {
  // フィールドの定義
  var x: Int = _x
  var y: Int = _y

  // メソッド定義
  // ...
}
```


<a name="class-method"></a>

クラスメソッド、クラス変数
------------------------------

Scala はクラスで static なメンバを宣言する方法はありません。
代わりに、コンパニオンオブジェクトを使ってクラスメソッド・クラス変数を実装します。

- __object__ キーワードを使って宣言されたオブジェクトは、シングルトンオブジェクトになります
- __コンパニオンオブジェクト__（__companion object__）とは、
  特定のクラスとクラス名を共有するシングルトンオブジェクトのことです


```scala
class User(val name: String, val age: Int) {
  User.incrementUserCount
}

// コンパニオンオブジェクトの定義
object User {
  private var userCount: Int = 0
  def getUserCount() = this.userCount
  private def incrementUserCount() = this.userCount += 1
}

println(User.getUserCount) // => 0
new User("Alice", 20)
new User("Bob", 22)
println(User.getUserCount) // => 2
```


<a name="access"></a>

アクセス権
-----------

アクセス権は public と private と protected の3種類があります。

- 修飾子を何もつけない場合は public
- `private` 修飾子をつけると private
- `protected` 修飾子をつけると protected

```scala
class User(
  val name: String,
  private val age: Int
) {
  def public_function() = "public function"
  private def private_function() = "private function"
}

val alice = new User("Alice", 20)
println(alice.name) // => "Alice"
println(alice.age)  // => error
```


<a name="overload"></a>

オーバーロード
-------------

Scalaではパターンマッチ（オーバーロード）ができます。

```scala
def foo(x: Int) = x + 1
def foo(x: String) = x + "1"

println(foo(123))   // => 124
println(foo("123")) // => 1231
```


<a name="operator"></a>

演算子の定義
-----------------

技術的には Scala には演算子というものはなく、全て関数です。
したがって、次の文字から始まる関数は定義することが可能です

    | ^ & < > ! ? : + - * / %

これらの記号から始まる場合は、その後に記号を付け加えて新しい関数を作ることもできます。

```scala
import scala.math

class Point(val x: Int, val y: Int) {
  // add
  def +(other: Point) = {
    new Point(x + other.x, y + other.y);
  }

  // compare
  def <~>(other: Point): Int = {
    val this_distance  = math.sqrt(math.pow(      x, 2) + math.pow(      y, 2))
    val other_distance = math.sqrt(math.pow(other.x, 2) + math.pow(other.y, 2))
    if (this_distance > other_distance) return  1
    if (this_distance < other_distance) return -1
    return 0
  }

  override def toString(): String = "(" + x + ", " + y + ")"
}

val p1 = new Point(1, 2)
val p2 = new Point(3, 4)
println(p1 + p2) // => "(4, 6)"
println(p1 <~> p2) // => "-1"
```

単項演算子（unary）は `unary_` を演算子の先頭に付けて定義します。
単項演算子は下の4種類があります。

- `unary_+`, `unary_-`, `unary_!`, `unary_~`

```scala
class Point(val x: Int, val y: Int) {
  // add
  def +(other: Point) = {
    new Point(x + other.x, y + other.y);
  }

  // unary_minus
  def unary_- = new Point(-x, -y)

  override def toString(): String = "(" + x + ", " + y + ")"
}

val p1 = new Point(1, 2)
println(-p1) // => "(-1, -2)"
```


<a name="extends"></a>

継承、オーバーライド
------------------

- `extends` キーワードで継承を行います
- オーバーライドをするときは `override` 修飾子を宣言の先頭に付けます

```scala
class Super {
  def foo() = println("Super's method foo()")
}

class Sub extends Super {
  override def foo() = {
    println("Sub's method foo()")
    super.foo
  }
}

val sub = new Sub
sub.foo
// => "Sub's method foo()"
// => "Super's method foo()"
```

親クラスがコンストラクタに引数を取る場合は、継承するときにそれを明示的に示す必要があります。

```scala
class Human(val name: String)

class Man(override val name: String) extends Human(name)
```


<a name="abstract"></a>

抽象クラス
------------------

- `abstract class` でクラスを宣言すると、抽象クラスになります
- 抽象クラスのコンストラクタで `val` などを使ってインスタンス変数を宣言することはできないようです

```scala
abstract class AbstractMusic(music: String) {
  def play()
  def stop()
}

class Music(val music: String) extends AbstractMusic(music) {
  override def play() = println("play music: " + music)
  override def stop() = println("stop music: " + music)
}

val music = new Music("humpty dumpty")
music.play // => "play music: humpty dumpty"
music.stop // => "stop music: humpty dumpty"
```


<a name="interface"></a>

インターフェース
------------------

- Scala には Java のインターフェースのようなものがあります。__トレイト__（__Trait__）です。
- ただし、トレイトは、他のトレイトを継承するだけでなく、他のクラスを継承することもできます
- `with トレイト名` と書くことで、そのトレイトをクラスに組み込むことができます。

```scala
// 挨拶をする（SayGreeting）トレイト
trait SayGreeting {
  val name: String
  def niceToMeetYou() = "Nice to meet you! My name is " + name
}

// 生物（Creature）クラス
class Creature

// 人間（Human）クラス
class Human(override val name: String) extends Creature with SayGreeting

println( (new Human("Alice")).niceToMeetYou )
```

`with トレイト名` をインスタンスの生成時に使うことで、インスタンスに対してデコレートすることもできます。

```scala
// 抽象クラスのCheck
abstract class Check {
  def check(): String = "Checked Application Details... "
}

// それぞれのトレイトは抽象クラスCheckを継承する
trait CreditCheck extends Check {
  override def check(): String = "Checked Credit... " + super.check()
}
trait EmploymentCheck extends Check {
  override def check(): String = "Checked Employment... " + super.check()
}
trait CriminalRecordsCheck extends Check {
  override def check(): String = "Checked Criminal Records... " + super.check()
}

// インスタンス化のときのトレイトの利用は、スタックのように積み上がっていく
val apartmentApplication = new Check with CreditCheck with CriminalRecordsCheck
println(apartmentApplication.check)
// => Checked Criminal Records... Checked Credit... Checked Application Details...

val employmentCheck = new Check with CriminalRecordsCheck with EmploymentCheck
println(employmentCheck.check)
// => Checked Employment... Checked Criminal Records... Checked Application Details...
```


<a name="extender"></a>

拡張メソッド
------------------

- 既存のデータ型に対して、拡張メソッドを加えるには implicit conversions を使う
- `implicit` キーワードを使い、`implicit def 関数名(変換前の型) = new 変換後の型(変換前の型)` と書くことで、
  暗黙的な型変換が行われるようになる

```scala
import java.util._
import scala.language.implicitConversions

class DateHelper(number: Int) {
  def days(when: String): Date = {
    var date = Calendar.getInstance()
    when match {
      case "ago"      => date.add(Calendar.DAY_OF_MONTH, -number)
      case "from_now" => date.add(Calendar.DAY_OF_MONTH,  number)
      case _          => date
    }
    date.getTime()
  }
}

// 暗黙的な型変換の宣言
implicit def Int2DateHelper(number: Int) = new DateHelper(number)

val ago = "ago"
val from_now = "from_now"

// Int型には days というメソッドはないので、
// 暗黙的に DateHelper型に変換されて days メソッドが呼び出される
println(2 days ago)
println(5 days from_now)
```

コンパニオンオブジェクトを使うと、もう少し綺麗に書くことができます。

```scala
import java.util._
import scala.language.implicitConversions

class DateHelper(number: Int) {
  def days(when: String): Date = {
    var date = Calendar.getInstance()
    when match {
      case DateHelper.ago      => date.add(Calendar.DAY_OF_MONTH, -number)
      case DateHelper.from_now => date.add(Calendar.DAY_OF_MONTH,  number)
      case _                   => date
    }
    date.getTime()
  }
}

object DateHelper {
  val ago = "ago"
  val from_now = "from_now"
  implicit def Int2DateHelper(number: Int) = new DateHelper(number)
}


import DateHelper._

println(2 days ago)
println(5 days from_now)
```
