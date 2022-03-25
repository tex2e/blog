---
layout:        post
title:         "VB.NET でコレクション"
date:          2020-05-22
category:      VB.NET
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
# sitemap: false
# feed:    false
---

VB.NET でコレクション関連の関数・メソッドの一覧

### System.Collections.Generic

#### リストのソート (Sort)

```vb.net
Dim list1 As New List(Of String)({"ccc", "dd", "aaaa", "b"})

'辞書順
list1.Sort()
Console.WriteLine(String.Join(" ", list1)) ' => aaaa b ccc dd

'文字列長順
list1.Sort(Function(s1, s2) s1.Length.CompareTo(s2.Length))
Console.WriteLine(String.Join(" ", list1)) ' => b dd ccc aaaa
```

#### リストの検索 (Find)

```vb.net
Dim list1 As New List(Of String)({"a", "bb", "ccc", "dd", "e"})

Dim find As String = list1.Find(Function(s) s.Length = 2)
Console.WriteLine("Find:    {0}", find) ' => bb

Dim findAll As List(Of String) = list1.FindAll(Function(s) s.Length = 2)
Console.WriteLine("FindAll: {0}", String.Join(" ", findAll)) ' => bb dd
```

#### ディクショナリにキー・値が含まれるか (ContainsKey, ContainsValue)

{% raw %}
```vb.net
Dim list1 As New Dictionary(Of String, Integer) From {{"apple", 100}, {"banana", 200}}

Console.WriteLine(list1.ContainsKey("apple")) ' => True
Console.WriteLine(list1.ContainsValue(200))   ' => True
```
{% endraw %}

#### リストの末尾にリストを追加 (AddRange)

```vb.net
Dim list1 As New List(Of String)({"a", "b", "c", "d"})
Dim list2 As New List(Of String)({"e", "f", "g"})

list1.AddRange(list2)

Console.WriteLine(String.Join(" ", list1)) ' => a b c d e f g
```

#### コレクションの平均・合計 (Average, Sum)

```vb.net
Dim list1 As New List(Of String)({"aaa", "bb", "cccc", "d"})

Console.WriteLine("{0}", list1.Average(Function(s) s.Length)) ' => 2.5
Console.WriteLine("{0}", list1.Sum(Function(s) s.Length))     ' => 10
```

#### Enumeratorによる反復 (list.GetEnumerator)

```vb.net
Dim list1 As New List(Of Integer)({1, 2, 3})

Dim enumerator As List(Of Integer).Enumerator = list1.GetEnumerator()
While enumerator.MoveNext
    Console.WriteLine(enumerator.Current)
End While
```

#### 要素が条件を満たすか (All, Any)

```vb.net
Dim list1 As New List(Of String)({"Hello", "world", "!"})

Console.WriteLine(list1.All(Function(s) s.Length >= 3)) ' => False
Console.WriteLine(list1.All(Function(s) s.Length >= 1)) ' => True
Console.WriteLine(list1.Any(Function(s) s.Length = 3)) ' => False
Console.WriteLine(list1.Any(Function(s) s.Length = 1)) ' => True
```

#### ディクショナリから値取得 (TryGetValue)

{% raw %}
```vb.net
Dim list1 As New Dictionary(Of String, Integer) From {{"apple", 100}, {"banana", 200}}
Dim value As Integer
Dim result As Boolean

'インデクサ (キーが存在しないときはエラー)
value = list1("apple")
Console.WriteLine(value) ' => 100

'TryGetValue (キーが存在しないときはFalseを返す)
result = list1.TryGetValue("cherry", value)
If result Then Console.WriteLine(value)
```
{% endraw %}

#### 和差積集合 (Union, Except, Intersect)

```vb.net
Dim list1 As New List(Of String)({"a", "b", "c", "d"})
Dim list2 As New List(Of String)({"b", "c", "f"})

Dim union     = list1.Union(list2) '和集合
Dim except    = list1.Except(list2) '差集合
Dim intersect = list1.Intersect(list2) '積集合

Console.WriteLine("Union:     " + String.Join(" ", union))     ' => a b c d f
Console.WriteLine("Except:    " + String.Join(" ", except))    ' => a d
Console.WriteLine("Intersect: " + String.Join(" ", intersect)) ' => b c
```

#### コレクションを配列にコピー (CopyTo)

```vb.net
Dim list1 As New List(Of String)({"Hello", "world", "!"})
Dim list2() As String = {"a", "b", "c", "d", "e", "f", "g"}

list1.CopyTo(list2, arrayIndex:=2)
Console.WriteLine(String.Join(" ", list2)) ' => a b Hello world ! f g
```

#### コレクションの連結 (Concat)

```vb.net
Dim list1 As New List(Of String)({"Hello", "world", "!"})
Dim list2 As New List(Of String)({"a", "b", "c"})

Dim list3 As IEnumerable(Of String) = list1.Concat(list2)
For Each item As String In list3
    Console.Write("{0} ", item)
Next
' => Hello world ! a b c
```

#### Listの作成と要素追加 (Add)

```vb.net
Dim list1 As New List(Of Integer)
list1.Add(1)
list1.Add(2)
list1.Add(3)

For Each i As Integer In list1
    Console.WriteLine(i)
Next
```

#### ディクショナリの生成 (Dictionary)

{% raw %}
```vb.net
Dim list1 As New Dictionary(Of String, Integer) From {{"apple", 100}, {"banana", 200}}
list1.Add("cherry", 300)

For Each key As String In list1.Keys
    Console.WriteLine("{0}: {1}", key, list1(key))
Next
' => apple: 100
' => banana: 200
' => cherry: 300
```
{% endraw %}

#### 要素ごとに処理 (ForEach)

```vb.net
Dim total As Integer = 0
Dim list1 As New List(Of Integer)({1, 2, 3, 4})

list1.ForEach(Sub(num) total += num)
Console.WriteLine(total) ' => 10
```

#### コレクションのフィルタ (Where)

```vb.net
Dim list1 As New List(Of String)({"aaa", "bb", "cccc", "d"})
Dim list2 As IEnumerable(Of String) = list1.Where(Function(s) s.Length >= 3)

Console.WriteLine(String.Join(" ", list2)) ' => aaa cccc
```

#### コレクションの最小・最大 (Min, Max)

```vb.net
Dim list1 As New List(Of String)({"aaa", "bb", "cccc", "d"})

Console.WriteLine("Min: {0}", list1.Min(Function(s) s.Length)) ' => Min: 1
Console.WriteLine("Max: {0}", list1.Max(Function(s) s.Length)) ' => Max: 4
```

