---
layout:        post
title:         "Vue.js 入門"
date:          2021-03-13
category:      Javascript
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

Vue.js の使い方についての説明兼、自分用の備忘録です。

### 使用するHTML

バージョンは2021/03/13時点での最新を使っています。

```html
<!DOCTYPE html>
<html>

<head>
  <meta charset="UTF-8">
  <title>Vue.js Example</title>
  <script src="https://cdn.jsdelivr.net/npm/vue@2.6.12/dist/vue.js"></script>
</head>

<body>
  <!-- ここにHTMLとVueのスクリプトを記述します -->
</body>
</html>
```

{% raw %}
### データを表示する `{{ }}`
{% endraw %}

{% raw %}

データの表示は `{{ データ }}` または、`v-text` を使います。
HTMLをそのまま表示したい場合は `v-html` を使います。

```html
<body>
  <div id="app">
    <button>{{ message }}</button>
    <p>{{ price * 1.1 }}円</p>
    <p v-text="book.title"></p>
  </div>

  <script>
    new Vue({
      el: "#app",
      data: {
        message: "Hello Vue!",
        price: 1000,
        book: {title: "My Book"},
      }
    })
  </script>
</body>
```
{% endraw %}


### HTMLタグの属性とつなぐ v-bind

属性値にデータを使用する場合は `v-bind` を使います。
なお、v-bind はよく使われるため、省略することができます。

```html
<body>
  <div id="app">
    <a v-bind:href="url">リンクA</a>
    <a :href="url2">リンクB</a>
    <p :style="{fontSize: mySize}">Hello World!</p>
    <p :class="{hidden: myHidden}">Visible or Hidden</p>
  </div>

  <script>
    new Vue({
      el: "#app",
      data: {
        url: "path/to/file.html",
        url2: "https://example.com",
        mySize: "20px",
        myHidden: true,
      }
    })
  </script>
</body>
```


### 入力フォームとつなぐ v-model

ユーザからの入力をVueに反映させるときは v-model を使います。
以下ではテキストボックス、チェックボックス、ドロップダウンリストの例です。

{% raw %}
```html
<body>
  <div id="app">
    <input v-model="inputText" />
    <p>入力内容：{{inputText}}</p>
    <p>入力長　：{{inputText.length}}</p>

    <label><input type="checkbox" v-model="myCheckbox">有効化</label>
    <p>チェック：{{myCheckbox}}</p>

    <select v-model="myCity">
      <option disabled value="">選択してください</option>
      <option value="A">A市</option>
      <option value="B">B市</option>
      <option value="C">C市</option>
    </select>
    <p>選択値　：{{myCity}}</p>

    <input v-model.lazy="inputText2" />
    <p>入力内容：{{inputText2}}</p>
  </div>

  <script>
    new Vue({
      el: "#app",
      data: {
        inputText: "",
        inputText2: "",
        myCheckbox: false,
        myCity: "",
      }
    })
  </script>
</body>
```
{% endraw %}

また、v-model には修飾子があり、入力値や入力方法を指定することができます。

- `v-model.lazy="データ名"` : フォーカスが外れたときに反映
- `v-model.number="データ名"` : 入力を数値として扱う
- `v-model.trim="データ名"` : 前後の空白を自動的に削除


### イベントとつなぐ v-on

v-on を使うことでマウスやキーボードを入力したときの処理を書くことができます。
なお、v-on には省略記法があり、@ に置き換えることができます。

{% raw %}
```html
<body>
  <div id="app">
    <button v-on:click="incrementCount">増やす</button><br>
    <button     @click="decrementCount">減らす</button><br>
    <button v-on:click="incrementCount(10)">10増やす</button>
    <p>{{count}}回</p>
  </div>

  <script>
    new Vue({
      el: "#app",
      data: {
        count: 0,
      },
      methods: {
        incrementCount: function (value) {
          if (Number.isInteger(value)) {
            this.count += value;
          } else {
            this.count += 1;
          }
        },
        decrementCount: function () {
          if (this.count > 0) {
            this.count -= 1;
          }
        }
      }
    })
  </script>
</body>
```
{% endraw %}


### 条件によって表示する v-if

データの値によって表示・非表示を切り替えるときは、v-if, v-else を使います。

```html
<body>
  <div id="app">
    <label><input type="checkbox" v-model="myFlag">有効化</label>
    <p v-if="myFlag">有効</p>
    <p v-else>無効</p>
  </div>

  <script>
    new Vue({
      el: "#app",
      data: {
        myFlag: false,
      }
    })
  </script>
</body>
```


### 繰り返し表示する v-for

v-for を使うと配列からHTMLが繰り返し生成されます。

{% raw %}
```html
<body>
  <div id="app">
    <ul>
      <li v-for="item in todos">{{ item }}</li>
    </ul>
    <table>
      <thead>
        <tr>
          <th>本</th><th>値段</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="book in books">
          <td>{{ book.name }}</td><td>{{ book.price }}円</td>
        </tr>
      </tbody>
    </table>
  </div>

  <script>
    new Vue({
      el: "#app",
      data: {
        todos: [
          'やること1', 'やること2', 'やること3'
        ],
        books: [
          { name: '技術書JavaScript', price: 3000 },
          { name: '技術書Node.js', price: 3500 },
          { name: '技術書C++', price: 3900 },
        ],
      },
    })
  </script>
</body>
```
{% endraw %}


### データを使って別の計算をする computed

データの値から別のデータに加工・計算するときは、computed を使います。
入力とつなぐ v-model と組み合わせるのが一般的です。

{% raw %}
```html
<body>
  <div id="app">
    <input type="number" v-model.number="price">円 ×
    <input type="number" v-model.number="count">個
    <p>　　価格：{{ totalPrice }}</p>
    <p>税込価格：{{ totalPriceIncludeTax }}</p>
  </div>

  <script>
    new Vue({
      el: "#app",
      data: {
        price: 100,
        count: 1
      },
      computed: {
        totalPrice: function() {
          return this.price * this.count;
        },
        totalPriceIncludeTax: function() {
          return parseFloat(this.totalPrice * 1.1).toFixed(0);
        }
      }
    })
  </script>
</body>
```
{% endraw %}


### データの変化を監視する watch

watchを使うことで、入力によってデータが変化したときに行う処理を定義できます。

```html
<body>
  <div id="app">
    <textarea v-model="inputText"></textarea>
    <p v-if="hasForbiddenStr">数字は入力できません</p>
  </div>

  <script>
    new Vue({
      el: "#app",
      data: {
        inputText: "",
        hasForbiddenStr: false,
      },
      watch: {
        inputText: function() {
          this.hasForbiddenStr = (/[0-9]/.test(this.inputText));
        }
      }
    })
  </script>
</body>
```


### 部品にまとめる component

HTMLテンプレートとデータを一つの部品（component）にすることができます。

{% raw %}
```html
<body>
  <div id="app">
    <my-component></my-component>
    <my-component></my-component>
    <my-component></my-component>
  </div>

  <script>
    Vue.component('my-component', {
      template: '<div>{{ count }} <button v-on:click="addCount(1)">1増やす</button></div>',
      data: function() {
        return {
          count: 0
        }
      },
      methods: {
        addCount: function(value) {
          this.count += value;
        }
      }
    })

    new Vue({
      el: "#app",
    })
  </script>
</body>
```

component を v-for で複数個生成することもできます。
そのときは v-bind:key で一意になるキーを指定して、渡す値をプロパティ経由で component 側に渡します。

```html
<body>
  <div id="app">
    <my-component v-for="item in items"
                  v-bind:key="item.name"
                  v-bind:product-name="item.name"
                  v-bind:product-price="item.price"></my-component>
  </div>

  <script>
    Vue.component('my-component', {
      template: '<div>{{ productName }}: {{ productPrice }}円 × {{ count }}個</div>',
      props: {
        productName: String,
        productPrice: Number,
      },
      data: function () {
        return {
          count: 1
        }
      },
    })

    new Vue({
      el: "#app",
      data: {
        items: [
          { name: '商品A', price: 3000 },
          { name: '商品B', price: 4000 },
          { name: '商品C', price: 5000 },
        ],
      }
    })
  </script>
</body>
```
{% endraw %}

以上です。
