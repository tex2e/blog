---
layout:        post
title:         "CPUID命令を利用してCPUがAES-NIに対応しているか確認する方法"
date:          2026-04-26
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

現代の多くの x86/x86_64 CPU には、AES暗号化および復号の処理を高速化するためのハードウェアアクセラレータである AES-NI (Advanced Encryption Standard New Instructions) が搭載されています。
AES-NI を利用することで、ソフトウェアのみの処理に比べて数倍から数十倍の速度向上が期待できます。
この記事では、C言語から「CPUID命令」を利用して、実行環境のCPUが AES-NI をサポートしているかプログラムから動的に判定する方法を説明します。

### CPUIDを利用した判定プログラム

x86系CPUでは、`CPUID` 命令を実行することで、CPUのベンダー名、モデル、対応している機能フラグなどの情報を取得できます。
GCCやClangでは、`<cpuid.h>` ヘッダに含まれる組み込み関数 `__get_cpuid` を使用するのが最も簡単です。

#### 実装例 (check_aes.c)

```c
#include <stdio.h>
#include <cpuid.h>

/**
 * CPUがAES-NIをサポートしているか確認する
 * @return サポートしていれば1、そうでなければ0
 */
int check_cpu_support_aes()
{
    unsigned int eax, ebx, ecx, edx;
    
    // 機能番号1 (EAX=1) を指定してプロセッサ情報と機能フラグを取得
    // 成功した場合は 1 が返る
    if (__get_cpuid(1, &eax, &ebx, &ecx, &edx)) {
        /**
         * ECXレジスタのビット25が AES-NI のサポートフラグ
         * 参照: Intel 64 and IA-32 Architectures Software Developer's Manual
         */
        return (ecx & (1 << 25)) != 0;
    }
    
    return 0; // 取得失敗時
}

int main(void)
{
    if (check_cpu_support_aes()) {
        printf("Result: AES-NI is supported.\n");
    } else {
        printf("Result: AES-NI is NOT supported.\n");
    }
    return 0;
}
```

### コンパイルと実行

以下のコマンドでコンパイルできます。
特別なライブラリのリンクは不要です。

```bash
gcc check_aes.c -o check_aes
```

プログラムを実行して結果を確認します。

```bash
./check_aes
```

出力が `AES-NI is supported.` であれば、そのCPUではハードウェアによるAES高速化が利用可能です。
OpenSSL などのライブラリも内部で同様のチェックを行い、利用可能な場合は自動的に AES-NI を使用するようになっています。


### (補足) コマンドラインで確認する方法

プログラムを書かずに、OSのコマンドで手っ取り早く確認する方法もあります。

Linux の場合、 `/proc/cpuinfo` の `flags` 項目を確認します。

```bash
grep -o "aes" /proc/cpuinfo
```

`aes` という文字列が表示されれば対応しています。

プログラムの中で暗号化処理を最適化したい場合、今回紹介した `__get_cpuid` を用いた判定を入れることで、環境に応じた最適なアルゴリズムの選択が可能になります。

以上です。
