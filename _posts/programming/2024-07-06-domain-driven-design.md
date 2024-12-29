---
layout:        post
title:         "ドメイン駆動設計 (Domain-Driven Design)"
date:          2024-07-06
category:      Programming
cover:         /assets/cover14.jpg
redirect_from: /misc/domain-driven-design
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

ドメイン駆動設計とは、ドメインの知識に焦点を当てた設計手法です。
ドメインとは領域のことで、ソフトウェア開発においてはプログラムを適用する対象となる領域のことを指します。
ソフトウェアの目的は利用者のドメインにおける何らかの問題解決です。
そのためにドメインの概念や事象を理解し、その中から問題解決に役立つものを抽出して得られた知識をソフトウェアに反映する開発手法がドメイン駆動設計です。

### ドメインモデル

**ドメインモデル**とは、ドメインの概念をモデリングして得られたモデルのことです。
ドメインモデルを中心に開発を進めることを、ドメイン駆動と言います。
ドメインの専門家は、ドメインの概念についての知識はあっても、ソフトウェアにとっての重要な知識がどれかはわかりません。
一方で、開発者はソフトウェアにとって重要な知識を判断できても、ドメインの概念についての知識がありません。
両者は協力してドメインモデルを作り上げる必要があります。
そのときに、両者が共通の認識となる**ユビキタス言語**によってクラス名やメソッド名が命名されていきます。

### ドメインオブジェクト

**ドメインオブジェクト**とは、ドメインモデルを具体的な実装に落とし込んだもののことです。
ドメインが変化したとき、その変化はドメインの概念の写像であるドメインモデルに反映されます。
そして、ドメインモデルとその実装表現であるドメインオブジェクトの両者を比較することで、自ずと修正点が浮き彫りになります。

<br>

## ソフトウェアによるモデルの表現

ドメインモデルの構成要素は、大きく分けて「エンティティ」「値オブジェクト」「サービス」の3つに分類することができます。

### エンティティ

ドメイン駆動設計における**エンティティ** (Entities) とは、特定のインスタンスに紐づかない長期にわたって生存する**同一性** (Identity) を持つドメインオブジェクトのことです。
DBやファイルなどの1レコードを表現する目的のために、エンティティは実装されます。
エンティティは可変であり、同じ属性であっても同一性（IDなど）によって区別される性質を持っています。

.NETにおいては、データベースの内容をDataTableで持つのではなく、エンティティと呼ばれるクラスを自作することで、リテラル文字でアクセスすることによる実行時エラーを回避できたり、Columns.Addなどの記載が不要になったりするメリットがあります。
実装時は、SQLなどで取得するデータの1行分が、1つのエンティティになるように設計・実装します。

```csharp
public sealed class UserEntity {
    public int Id { get; }
    public string Name { get; }
    public UserEntity(int id, string name) {
        Id = id;
        Name = name;
    }
    public bool Equals(UserEntity other) {
        return Id = other.Id;  // 同一性によってのみ比較（氏名のNameは別でもIdが一致すれば同じと判断）
    }
}
```

### 値オブジェクト

**値オブジェクト** (Value Objects) とは、同一性で識別しないで属性を持つドメインオブジェクトのことです。
システム固有の値を作る目的のために、値オブジェクトは実装されます。
値は等価性によって比較される（.NETにおけるIEquatableを実装するなど）性質を持っており、その実装表現が値オブジェクトになります。
値オブジェクト（クラス）には独自の振る舞い（メソッド）を定義することができます。

```csharp
public sealed class Reservation {
    public UserEntity User { get; }
    public ProductEntity Product { get; }
    public Reservation(User user, ProductEntity product) {
        User = user;
        Product = product;
    }
    public bool Equals(Reservation other) {
        return User.Equals(other.User) && Product.Equals(other.Product);
    }
}
```

### サービス

ドメイン駆動設計における**サービス** (Services) とは、ドメインサービスとも呼ばれ、機能や処理を提供するオブジェクトです。
値オブジェクトやエンティティに記述されると不自然な振る舞い（メソッド）はすべてドメインサービスに定義します。
また、サービスは基本的に状態を持つことはありません (Stateless)。

```csharp
public sealed class UserService {
    private IEnumerable<User> userRepository;
    public bool Exists(User user) {
        var found = userRepository.Find(user.Id);
        return (found != null);
    }
}
```

<br>

## ドメインオブジェクトのライフサイクル

### リポジトリ

ドメイン駆動設計における**リポジトリ** (Repository) とは、エンティティを永続化させたり、エンティティを検索するための問い合わせ専用のオブジェクトとして振る舞います。
具体的には、DBに対してSelectやUpdateなどのSQLクエリを発行し、取得時は結果をエンティティに格納して呼び出し元に返すメソッドを提供します。

```csharp
public interface IUserRepository {
    Option<User> Find(SearchParam searchParam);
    List<User> FindAll(SearchParam searchParam);
    void Save(User user);
}
public sealed class UserRepository : IUserRepository {
    public Option<User> Find(SearchParam searchParam) {
        // ... SELECTするSQLを実行し、条件に一致する1件のみ取得する ...
    }
    public List<User> FindAll(SearchParam searchParam) {
        // ... SELECTするSQLを実行し、条件に一致する全件を取得する ...
    }
    public void Save(User user) {
        // ... UPDATEするSQLを実行する ...
    }
}
```

### 集約

**集約** (Aggregation) とは、関連するオブジェクトのグループを一つのオブジェクトにまとめることです。
集約は変更の単位（SQLの更新でトランザクションにしないといけない範囲）で区切ることができます。

```csharp
public sealed class Group {
    public string GroupId { get; }
    public string GroupName { get; }
    public List<User> Members { get; }
    public Group(string groupId, string groupName) {
        GroupId = groupId;
        GroupName = groupName;
    }
    public void Join(User member) {
        Members.Add(member)
    }
}
```

<br>

## ドメイン層の分離

ドメインモデルを他の関心事（プレゼンテーションやデータアクセスなど）から分離する方法について説明します。

### レイヤードアーキテクチャ

**レイヤードアーキテクチャ** (Layered Architecture) とは、UIとドメインを分離させるためにいくつかの層に分けて実装する構成のことです。
ドメイン駆動設計の文脈では、以下の4つの層によって構成されるレイヤードアーキテクチャが使われます。

- **プレゼンテーション層**（UI層）
    - ユーザの操作とアプリケーションを入力の解釈と出力の表示によって結びつける役割を担う
- **アプリケーション層**
    - ユースケースを表現するための進行役として振る舞う
- **ドメイン層**
    - ソフトウェアの適用する領域で問題解決に必要な知識を表す
- **インフラストラクチャ層**
    - DB接続、API通信、ファイル読み書きなど技術的基盤へのアクセスを提供する役割を担う




<br>

### 参考文献

- [フロントエンドの複雑さに立ち向かう 〜DDDとClean Architectureを携えて〜 \| さくらのナレッジ](https://knowledge.sakura.ad.jp/36776/)
- [ドメイン駆動設計で保守性をあげたリニューアル事例 〜 ショッピングクーポンの設計紹介 - Yahoo! JAPAN Tech Blog](https://techblog.yahoo.co.jp/entry/2021011230061115/)
- [\[ 技術講座 \] Domain-Driven Designのエッセンス 第1回｜オブジェクトの広場](https://www.ogis-ri.co.jp/otc/hiroba/technical/DDDEssence/chap1.html)