---
layout:        post
title:         "Javaでコレクション・Streamの操作"
date:          2020-07-25
category:      Java
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Java でコレクションとStream関連の関数・メソッドの一覧


#### リストに追加 (add, addAll)

```java
Collection<String> list = new ArrayList<>();

list.add("abc");
list.add("def");
System.out.println(list); // => [abc, def]

list.addAll(Arrays.asList("ghi", "jkl"));
System.out.println(list); // => [abc, def, ghi, jkl]
```

#### 値の設定と取得 (set, get)

```java
ArrayList<String> list = new ArrayList<>(Arrays.asList("abc", "def", "ghi"));
list.set(1, "123");
System.out.println(list); // => [abc, 123, ghi]

System.out.println(list.get(1)); // => 123
System.out.println(list.get(2)); // => ghi
```

#### リストのフィルター (removeIf)

```java
ArrayList<String> list = new ArrayList<>(Arrays.asList("aaa", "bb", "cccc", "d"));
list.removeIf(s -> s.length() < 3);
System.out.println(list); // => [aaa, cccc]
```

#### リストに値が含まれているか (contains)

```java
ArrayList<String> list = new ArrayList<>(Arrays.asList("aaa", "bb", "cccc", "d"));
System.out.println(list.contains("bb")); // => true
System.out.println(list.contains("dd")); // => false
```

#### リスト内の検索 (indexOf)

```java
ArrayList<String> list = new ArrayList<>(Arrays.asList("aaa", "bb", "cccc", "d"));
System.out.println(list.indexOf("cccc")); // => 2
System.out.println(list.indexOf("dddd")); // => -1
```

#### イテレータによる反復 (iterator)

```java
Collection<String> list = new ArrayList<>(Arrays.asList("aaa", "bb", "cccc", "d"));
Iterator<?> iterator = list.iterator();
while (iterator.hasNext()) {
    String elem = (String)iterator.next();
    System.out.println(elem);
}
// => aaa
// => bb
// => cccc
// => d
```

#### リストから一部分を抽出 (subList)

```java
ArrayList<String> list = new ArrayList<>(Arrays.asList("abc", "def", "ghi"));
System.out.println(list.subList(1, 3)); // => [def, ghi]
```

<br>
### マップ (Map)

#### マップの要素の設定 (put)

```java
Map<String, String> map = new HashMap<>();
map.put("apple", "りんご");
map.put("orange", "みかん");
System.out.println(map); // => {orange=みかん, apple=りんご}
```

#### 他のマップの要素を取り込む (putAll)

```java
Map<String, String> map1 = new HashMap<>();
map1.put("apple", "りんご");

Map<String, String> map2 = new HashMap<>();
map2.put("orange", "みかん");
map2.put("pear", "なし");

map2.putAll(map1);

System.out.println(map2);
```

#### マップの要素の取得 (get, getOrDefault)

```java
Map<String, String> map = new HashMap<>();
map.put("apple", "りんご");
map.put("orange", "みかん");

System.out.println(map.get("apple")); // => りんご
System.out.println(map.get("banana")); // => null
System.out.println(map.getOrDefault("banana", "該当なし")); // => 該当なし
```

#### マップの全キー・全要素の取得 (keySet, values)

HashMap はマップに追加した順番が保持されます

```java
Map<String, String> map = new HashMap<>();
map.put("apple", "りんご");
map.put("orange", "みかん");
map.put("pear", "なし");

System.out.println(map.keySet()); // => [orange, apple, pear]
System.out.println(map.values()); // => [みかん, りんご, なし]
```

LinkedHashMap はマップに追加した順番が保持されます

```java
Map<String, String> map = new LinkedHashMap<>();
map.put("apple", "りんご");
map.put("pear", "なし");
map.put("orange", "みかん");

System.out.println(map.keySet()); // => [apple, pear, orange]
System.out.println(map.values()); // => [りんご, なし, みかん]
```


<br>
### Stream

#### コレクションからStreamを生成 (stream)

```java
List<String> list = Arrays.asList("apple", "pear", "orange");
Stream<String> stream = list.stream();

stream.forEach(System.out::println);
// => apple
// => pear
// => orange
```

#### 配列からStreamを生成 (stream)

```java
String[] inputs = {"apple", "pear", "orange"};
Stream<String> stream = Arrays.stream(inputs);

stream.forEach(System.out::println);
// => apple
// => pear
// => orange
```

#### 無限の長さのStreamを生成 (iterate, generate)

```java
int sum = IntStream.iterate(1, n -> n+1).limit(10).sum();
System.out.println(sum); // => 55

Random rand = new Random();
Stream.generate(() -> rand.nextInt(100)).limit(5).forEach(System.out::println);
// => 59
// => 72
// => 37
// => 95
// => 96
```

#### Streamの要素のフィルタリング (filter)

```java
List<String> list = Arrays.asList("apple", "pear", "orange");
list.stream().filter(x -> x.length() >= 5).forEach(System.out::println);
// => apple
// => orange
```

#### Streamの要素のソート (sorted)

```java
List<String> list = Arrays.asList("apple", "pear", "orange");
list.stream().sorted().forEach(System.out::println);
// => apple
// => orange
// => pear

list.stream().sorted(Comparator.reverseOrder()).forEach(System.out::println);
// => pear
// => orange
// => apple
```

#### Streamの要素の変換 (map)

```java
List<String> list = Arrays.asList("apple", "pear", "orange");
list.stream().map(x -> x + "!").forEach(System.out::println);
// => apple!
// => pear!
// => orange!

list.stream().map(x -> x.length()).forEach(System.out::println);
// => 5
// => 4
// => 6

Stream.of(1,2,3,4,5).map(x -> "*".repeat(x)).forEach(System.out::println);
// => *
// => **
// => ***
// => ****
// => *****
```

#### Streamの最小・最大・合計 (min, max, sum)

```java
List<Integer> list = new ArrayList<>(Arrays.asList(3,1,4,1,5,9,2));

System.out.println(list.stream().max((a, b) -> a.compareTo(b)));
// => Optional[9]
System.out.println(list.stream().min((a, b) -> a.compareTo(b)));
// => Optional[1]
```

#### Streamの要素が条件を満たすか判定 (anyMatch, allMatch, noneMatch)

```java
List<Integer> list = new ArrayList<>(Arrays.asList(3,1,4,1,5,9,2));
System.out.println(list.stream().anyMatch(n -> (n > 5))); // => true
System.out.println(list.stream().allMatch(n -> (n > 5))); // => false
System.out.println(list.stream().noneMatch(n -> (n <= 0))); // => true
```

#### Streamでグルーピング (collect + groupingBy)

文字列の長さでグルーピングする例：

```java
String[] input = {"aaa", "bb", "cccc", "ddd", "ee"};
Map<Object, List<String>> map =
        Arrays.stream(input).collect(Collectors.groupingBy(x -> x.length()));
System.out.println(map);
// => {2=[bb, ee], 3=[aaa, ddd], 4=[cccc]}
```
