---
layout:        post
title:         "WebAssemblyで32bit整数配列をC言語で処理する"
date:          2020-08-09
category:      JavaScript
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

WebAssemblyを使って、整数配列の演算処理だけをC言語にやらせて、残りはJavaScript側でレンダリングなどの処理をすれば、ブラウザでのページ内処理が高速化できるようになると思ったので、wasmの実験とEmscriptenコンパイラのインストールの備忘録について書きます。

### Emscriptenのインストール

WSLのUbuntu上で行いました。
インストールに必要なコマンドは git と python です。

```bash
$ git clone https://github.com/emscripten-core/emsdk.git
$ cd emsdk
$ ./emsdk install latest
$ ./emsdk activate latest
```

Emscriptenの最新版を有効にしたら、出力に従って以下のコマンドを実行し、実行ファイルへのPATHを通します。

```bash
$ source "/path/to/emsdk_env.sh"
```

コマンドプロンプトを開くたびに毎回上記のコマンドを実行したくない場合は、以下をbash_profileに追加しておきましょう（バージョンは適宜置き換えてください）。

```bash
export PATH="$PATH:/path/to/emsdk"
export PATH="$PATH:/path/to/emsdk/upstream/emscripten"
export PATH="$PATH:/path/to/emsdk/node/12.18.1_64bit/bin"
```

最後にemccコマンドがインストールされたか確認します。

```bash
$ emcc -v
emcc (Emscripten gcc/clang-like replacement + linker emulating GNU ld) 1.40.1
```

<br>
### C言語で整数配列を編集する関数

Emscriptenのコンパイラが用意できたら、C言語の実装を用意します。
main関数はwasmファイル読み込み時に一回だけ実行されるため、初期化処理を書くことができます。

Cで定義した関数をJavaScript側で使用するには `EMSCRIPTEN_KEEPALIVE` をC言語の関数名の前に追加します。
Emscripten がコンパイル時に関数名を忘れないように (関数名が生き続ける(keep-aliveする)ように) するためのマクロです。
このマクロを追加しないでExportする別の方法としては、コンパイル時のオプションに `-s "EXPORTED_FUNCTIONS=['_mulBy2', '_main']"` を追加する方法もあります。

JavaScriptから呼び出す関数の定義では、C++の名前修飾(Name Mangling)を回避するために、必ずC言語を使います。C++の場合は `extern "C"` の中でJavaScriptから呼び出す関数を定義します。

以下の実装では mulBy2 という関数を定義しました。
与えられた配列の要素 (整数) の値を2倍にする関数です。

```c
// main.c

#include <stdio.h>
#include <emscripten/emscripten.h>

int main(int argc, char **argv) {
  printf("Hello WASM World\n");
}

#ifdef __cplusplus
extern "C" {
#endif

void EMSCRIPTEN_KEEPALIVE mulBy2(int* a, int len)
{
  for (int i = 0; i < len; i++) {
    a[i] *= 2;
  }
}

#ifdef __cplusplus
}
#endif
```

<br>
### コンパイル

emccコマンドで main.c をコンパイルし、wasm.js を生成します。
オプションは以下の通りです。

- `-o 出力ファイル` : 出力ファイルの設定。～.js か ～.html を指定します
- `-s WASM=1` : .wasmファイルを生成します。このオプションはなくても結果は同じになります
- `-s NO_EXIT_RUNTIME=1` : main関数が終了してもランタイムを終了しません
- `-s EXTRA_EXPORTED_RUNTIME_METHODS=[...]` : ランタイムメソッドをExportします (JavaScript側のModuleで使用するメソッドを列挙します)

エクスポートするランタイムメソッドについて、
配列のポインターに値を設定したり取得したりするときは `getValue` と `setValue` が必要になります。

```bash
$ emcc -o wasm.js main.c -s WASM=1 -s NO_EXIT_RUNTIME=1 \
  -s "EXTRA_EXPORTED_RUNTIME_METHODS=['getValue', 'setValue']"
```

<br>
### JavaScript

最新のChromeでは標準でWASMが使用できます(2020年8月現在)。
以下のJavaScriptでは、まず`_malloc`でメモリを用意し、そこに`Module.setValue`で値を設定し、Cで定義した関数名の先頭にアンダースコアをつけた`Module._mulBy2`を呼び出して要素を2倍にし、最後に`Module.getValue`で値を取得しています。

```html
<!doctype html>
<html lang=en-us>
<head>
  <meta charset=utf-8>
  <meta content="text/html; charset=utf-8" http-equiv=Content-Type>
  <title>Hello WASM World!</title>
</head>
<body>
  <button class=mybutton>Run mulBy2</button><br>
  <script>
    document.querySelector(".mybutton").addEventListener("click", (function () {

      // 配列のメモリを用意
      var nByte = 4;
      var length = 20;
      var buffer = Module._malloc(length * nByte);

      // 配列の値を設定 (array=0,1,2...,19)
      for (var i = 0; i < length; i++) {
        Module.setValue(buffer + i*nByte, i, 'i32');
      }

      // C言語の関数の呼び出し (各要素2倍)
      Module._mulBy2(buffer, length);

      // 配列の値を取得 (array=0,2,4...,38)
      for (var i = 0; i < length; i++) {
        console.log(Module.getValue(buffer + i*nByte, 'i32'));
      }

      // 配列のメモリ解放
      Module._free(buffer);

    }));
  </script>
  <script async src=wasm.js></script>
</body>
</html>
```

ローカルでWebサーバを立ち上げて (Pythonを使えば `python -m http.server` でポート8000でWebサーバが起動します)、HTMLのボタンをクリックすると、コンソールのログに以下が出力されます。

```output
0
2
4
6
8
10
:
38
```

<br>
### JavaScriptのInt32Arrayクラスを使う方法

`Module.setValue` と `Module.getValue` を使わないで、JavaScriptの型クラスである Int32Array を使うこともできます。


```html
<!doctype html>
<html lang=en-us>
<head>
  <meta charset=utf-8>
  <meta content="text/html; charset=utf-8" http-equiv=Content-Type>
  <title>Hello WASM World!</title>
</head>
<body>
  <button class=mybutton>Run mulBy2</button><br>
  <script>
    document.querySelector(".mybutton").addEventListener("click", (function () {
      var input_array = new Int32Array([20, 2, -5, 77, -34]);
      var nByte = input_array.BYTES_PER_ELEMENT;
      var length = input_array.length;
      var ptr = Module._malloc(length * nByte);

      Module.HEAP32.set(input_array, ptr / nByte);

      Module._mulBy2(ptr, length);

      var output_array = new Int32Array(Module.HEAP32.buffer, ptr, length);
      console.log('input_array: ', input_array);
      console.log('output_array:', output_array);

      Module._free(ptr);
    }));
  </script>
  <script async src=wasm.js></script>
</body>
</html>
```

実行時のコンソールログの結果は次のようになります。

```output
input_array:  Int32Array(5) [20, 2, -5, 77, -34]
output_array: Int32Array(5) [40, 4, -10, 154, -68]
```


#### 参考

- [WASM Tutorial](https://marcoselvatici.github.io/WASM_tutorial/)
- [preamble.js — Emscripten 1.40.1 documentation](https://emscripten.org/docs/api_reference/preamble.js.html)
- [C/C++からWebAssemblyにコンパイルする - WebAssembly \| MDN](https://developer.mozilla.org/ja/docs/WebAssembly/C_to_wasm)
- [WebAssemblyでC++とJavaScript間のやり取り - Qiita](https://qiita.com/soramimi_jp/items/1b7ed0ddcefb0f4a7172)
