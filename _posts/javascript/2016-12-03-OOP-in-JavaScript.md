---
layout:        post
title:         "OOP in JavaScript"
date:          2016-12-03
category:      Javascript
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

JavaScriptにおけるオブジェクト指向のまとめ

目次
-------

- ES5
    - [クラスの定義](#class)
    - [コンストラクタ、フィールド、メソッド](#constructor)
    - [クラスメソッド、クラス変数](#class-method)
    - [アクセス権](#access)
    - [継承](#extends)
- ES6
    - [クラスの定義](#es6-class)
    - [コンストラクタ、メソッド](#es6-constructor)
    - [クラスメソッド](#es6-class-method)
    - [継承](#es6-extends)
- ES7
    - [クラス変数](#es7-class-field)


ES5でのクラス定義
===============

<a name="class"></a>

クラスの定義
-----------

JavaScriptでいうクラスとは、関数のことです。

```js
var ClassName = function () {};

foo = new ClassName();
```

なので、`new` キーワードを使わなくても関数を呼び出すことは可能ですが、
`this` の参照がグローバル空間全体で共有されてしまいます。

ここでは、`new` を使って関数を呼び出すことを __インスタンス化する__ と呼ぶことにします。


<a name="constructor"></a>

コンストラクタ、フィールド、メソッド
------------------------------

- コンストラクタは、クラス名を持つ変数に代入する関数に書きます
- メソッドの定義は `クラス名.prototype.メソッド名`
- フィールドの定義は `this.フィールド名`
- 同じクラスのメソッドを参照するときは `this.メソッド名`
- 全てのメンバは public

```js
// コンストラクタ
var Point = function (x, y) {
    this.x = x;
    this.y = y;
};

// メソッドの定義
Point.prototype.toString = function () {
    return "(" + this.x + ", " + this.y + ")";
};


p1 = new Point(1, 2);
p1.toString(); // => "(1, 2)"
```


<a name="class-method"></a>

クラスメソッド、クラス変数
------------------------------

JavaScriptは全てのオブジェクトが連想配列なので、
クラス（つまり関数オブジェクト）に新しいインデックスを作成することで、クラスメソッド・クラス変数を実現させます。

```js
// コンストラクタ
var User = function () {
    User.userCount += 1;
}

// クラス変数
User.userCount = 0;

// クラスメソッド
User.getUserCount = function () {
    return User.userCount;
}


new User();
new User();
User.getUserCount(); // => 2
```


<a name="access"></a>

アクセス権
-----------

通常の方法だとメンバは全てパブリックですが、
クラスを定義するときにクロージャ（即時実行関数）を使うことで、変数は局所変数となり、
プライベートなメンバを作ることができます。

protected は JavaScript にはありません。

```js
// コンストラクタ
var User = (function () {
    var _age; // クロージャの局所変数であるため、外部からは見えない

    // コンストラクタ
    var User = function (name, age) {
        // 名前はpublicに、年齢はprivateにする
        this.name = name;
        _age = age;
    }

    User.prototype.getAge = function () {
        // クロージャの内部からは、アクセスできる
        return _age;
    };

    return User;
}());

var alice = new User("Alice", 20);
alice.name; // => "Alice"
alice.age;  // => undefined
alice.getAge(); // => 20
```


<a name="extends"></a>

継承
------------------

「継承する」をJavaScriptで言い換えると「クラスAに存在する全てのメンバをクラスBにコピーする」
ということです。ここでは、継承を行うための関数`extend`の実装例と使い方を紹介します。

```js
// CoffeeScript 1.10 より
// Usage: extend(SubClass, SuperClass)
var extend = function (child, parent) {
    for (var key in parent) {
        if ({}.hasOwnProperty.call(parent, key)) child[key] = parent[key];
    }
    function ctor() {
        this.constructor = child;
    }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype; // 親クラスへの参照を__super__に残しておく
    return child;
};

// Animalクラス
var Animal = function (name, age) {
    this.name = name;
    this.age = age;
}
Animal.prototype.getName = function () { return this.name };
Animal.prototype.getAge  = function () { return this.age };

// PersonクラスはAnimalクラスを継承する
var Person = function (name, age, address) {
    Person.__super__.constructor(name, age);
    this.address = address;
}
extend(Person, Animal);
Person.prototype.sayHello = function () { return "hello!" };


alice = new Person("Alice", 20);
alice.getName();  // => "Alice"
alice.sayHello(); // => "hello!"
```


ES6でのクラス定義
==================

<a name="es6-class"></a>

クラスの定義
-----------

- クラスを定義するためのキーワード `class` がES6から導入されました
- `class` は無名クラスを作ることができます（`function` が無名関数を作れるのと同様に）

```js
class ClassName {
    constructor() {}
}

var foo = new ClassName();
```

```js
var ClassName = class {
    constructor() {}
}

var foo = new ClassName();
```


<a name="es6-constructor"></a>

コンストラクタ、メソッド
------------------------------

- コンストラクタは、`constructor` メソッドに定義する

```js
class Point {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }

    toString() {
        return "(" + this.x + ", " + this.y + ")";
    }
}

point = new Point(1, 2);
point.toString(); // => "(1, 2)"
```


<a name="es6-class-method"></a>

クラスメソッド
------------------------------

- クラスメソッドを定義するためのキーワード `static` がES6で追加されました

```js
class Point {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }

    static distance(a, b) {
        const dx = a.x - b.x;
        const dy = a.y - b.y;
        return Math.sqrt(dx*dx + dy*dy);
    }
}

const p1 = new Point(3, 4);
const p2 = new Point(15, 20);
Point.distance(p1, p2); // => 20
```


<a name="es6-extends"></a>

継承
------------------

- 継承をするためのキーワード `extends` がES6で追加されました
- スーパークラスを参照するときは `super` キーワードを使います

```js
class Point {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }
}

class Point3D extends Point {
    constructor(x, y, z) {
        super(x, y);
        this.z = z;
    }
}

point3d = new Point3D(1, 2, 3);
point3d.x; // => 1
point3d.y; // => 2
point3d.z; // => 3
```



ES7でのクラス定義
==================

基本はES6と同じです。


<a name="es7-class-field"></a>

クラス変数
-----------------

class構文内で、クラス変数が宣言できるようになる予定です。
（2016年8月時点では Stage2 なので確定ではない）

```js
// Class Instance Fields
class ClassWithoutInits {
    myProp;
}

class ClassWithInits {
    myProp = 42;
}
```
