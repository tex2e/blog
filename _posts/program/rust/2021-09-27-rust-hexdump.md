---
layout:        post
title:         "Rustで16進数ダンプ (Hexdump)"
date:          2021-09-27
category:      Program
cover:         /assets/cover14.jpg
redirect_from: /rust/hexdump
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Rust で Uint8 の配列 [u8] を16進数ダンプ (hexdump) するための方法について説明します。

まず、一番簡単な方法は map と collect を組み合わせて、各要素を16進数にしてから文字列として結合する方法です。

```rust
let buff: [u8; 8] = [0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF];
println!("Result: {}", buff.iter().map(|x| format!("{:02X}", x)).collect::<String>());
// => Result: 0123456789ABCDEF
```

しかし、バイト列が長くなると読みにくいので hexdump 形式で出力する関数を実装します。

- 関数 get_hex_rep() : Uint8の配列から16進数表示の文字列を作成する
- 関数 get_ascii_representation() : Uint8の配列からASCII文字による表示を作成する
- 関数 hexdump() : Hexdump形式で出力する

```rust
fn get_hex_rep(byte_array: &[u8]) -> String {
    let build_string_vec: Vec<String> = byte_array.iter().enumerate()
        .map(|(i, val)| {
            if i == 7 { format!("{:02x} ", val) }
            else { format!("{:02x}", val) }
        }).collect();
    build_string_vec.join(" ")
}

fn get_ascii_representation(byte_array: &[u8]) -> String {
    let build_string_vec: Vec<String> = byte_array.iter().map(|num| {
        if *num >= 32 && *num <= 126 { (*num as char).to_string() }
        else { '.'.to_string() }
    }).collect();
    build_string_vec.join("")
}

fn hexdump(byte_array: &[u8]) {
    let mut offset = 0;
    while offset < byte_array.len() {
        let mut length = 16;
        if byte_array.len() - offset < 16 {
            length = byte_array.len() - offset;
        }
        println!("{:08x}: {:49} {:16}",
                 offset,
                 get_hex_rep(&byte_array[offset..offset+length]),
                 get_ascii_representation(&byte_array[offset..offset+length]));
        offset += 16;
    }
}
```

hexdump 関数の使い方は以下のような感じになります。
出力結果は左側に offset、中央に16進数文字列、右側にASCII文字列が表示されます。

```rust
fn main() {
    let buff: [u8; 8*5+3] = [
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF,
        0x11, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF,
        0x21, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF,
        0x31, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF,
        0x41, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF,
        0x51, 0x23, 0x45,
    ];
    println!("Hexdump:");
    hexdump(&buff);
    // => 00000000: 01 23 45 67 89 ab cd ef  11 23 45 67 89 ab cd ef  .#Eg.....#Eg....
    // => 00000010: 21 23 45 67 89 ab cd ef  31 23 45 67 89 ab cd ef  !#Eg....1#Eg....
    // => 00000020: 41 23 45 67 89 ab cd ef  51 23 45                 A#Eg....Q#E
}
```

コンパイルと実行は次のコマンドで行います。

```bash
rustc test.rs && ./test
```

Rust で Hexdump するプログラムは HTTP/3, QUIC の Rust 実装である quiche で送受信データや暗号化データについてデバッグをするときに役に立ちました。
Rust で書かれたネットワークプロトコルの実装とかを解読する際の助けになればと思います。

以上です。

#### 参考文献

- [Writing a Hex Dump Utility in Rust \| by Trent May \| Medium](https://trentmay.medium.com/writing-a-hex-dump-utility-in-rust-e98b3355e530)
- [Rust でバイト列を16進数な文字列に変換する（Hex dump in Rust） - Qiita](https://qiita.com/benki/items/3a1baf90bbb744bd5b86)
