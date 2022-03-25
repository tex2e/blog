---
layout:        post
title:         "C言語 メモリ処理系関数一覧"
date:          2020-08-11
category:      C
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

### malloc()

構文 : `malloc(要素数 * sizeof(型))`

- malloc()はプログラムの実行中にメモリを確保するために使用します。
- 確保したメモリの初期化はされません。
- メモリ確保に失敗したときはNULLポインタを返します。
- 確保したメモリは必ずfree()で解放してあげましょう。

```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main()
{
    char *mem_allocation;
    // 動的メモリ確保
    mem_allocation = malloc(20 * sizeof(char));
    if (mem_allocation == NULL) {
        printf("メモリ確保失敗\n");
    } else {
        strcpy(mem_allocation, "Sample text");
    }
    printf("格納した文字列 : %s\n", mem_allocation );
    // => Sample text
    free(mem_allocation);
}
```

### calloc()

構文 : `calloc(要素数, sizeof(型))`

- calloc()はメモリ確保でmalloc()関数と同じです。
- calloc()は割り当てられたメモリをゼロに初期化します。

```c
#include <stdio.h>
#include <stdlib.h>

int main()
{
    char *mem_allocation;
    // 動的メモリ確保 (0で初期化)
    mem_allocation = calloc(20, sizeof(char));
    if (mem_allocation == NULL) {
        printf("メモリ確保失敗\n");
    } else {
        mem_allocation[0] = 't';
        mem_allocation[1] = 'e';
        mem_allocation[2] = 's';
        mem_allocation[3] = 't';
    }
    printf("格納した文字列 : %s\n", mem_allocation);
    free(mem_allocation);
    // => test
}
```

### realloc()

構文 : `realloc(ポインタ, 要素数 * sizeof(型))`

- realloc()関数は、malloc()やcalloc()で確保したメモリのサイズを変更します。
- 以前確保したメモリの位置からサイズを拡張できるときは、そこから拡張します。
- 拡張するのに十分なスペースがないときは、別のアドレスに確保しなおしてから、古いポインタを解放します。

```c
#include <stdio.h>
#include <stdlib.h>

int main()
{
    char *mem_allocation;
    // 動的メモリ確保
    mem_allocation = malloc(20 * sizeof(char));
    if (mem_allocation == NULL) {
        printf("メモリ確保失敗\n");
        return 1;
    }
    // 動的メモリ再確保
    mem_allocation = realloc(mem_allocation, 40 * sizeof(char));
    if (mem_allocation == NULL) {
        printf("メモリ確保失敗\n");
        return 1;
    }
    free(mem_allocation);
}
```


### memset()

構文 : `memset(ポインタ, 要素の整数値, 要素数 * sizeof(型))`

- メモリを確保し、その領域の各バイトをNULLまたはその他の値に初期化します。

```c
#include <stdio.h>
#include <stdlib.h>

int main()
{
    int i;
    char *a = malloc(5 * sizeof(char));

    // 配列の要素を全て0に設定
    memset(a, 0, 5*sizeof(char));

    for (i = 0; i < 5; ++i) {
        printf("a[%d] = %d,", i, a[i]);
    }
    // => a[0] = 0, a[1] = 0, a[2] = 0, a[3] = 0, a[4] = 0,
    free(a);
}
```

### memcpy()

構文 : `memcpy(コピー先ポインタ, コピー元ポインタ, 長さ)`

- あるメモリから別のメモリに指定されたバイト数をコピーします。

```c
#include <stdio.h>
#include <string.h>

int main()
{
    char str1[10] = "Sample";
    char str2[10] = {0};
    if (memcpy(str2, str1, strlen(str1))) {
        printf("コピー元: %s\nコピー先: %s\n", str1, str2);
        // => コピー元: Sample
        // => コピー先: Sample
    } else {
        printf("Error while coping str1 into str2.\n");
    }
}
```

### memmove()

- あるメモリから別のメモリに指定されたバイト数だけコピーしたり、同じメモリ上でコピーしたりします。
- memcpyは非破壊的なコピー（コピー元とコピー先が別）なのに対して、memmoveは破壊的なコピー（コピー元とコピー先が同じメモリ上）でも正しく動作します。

```c
#include <stdio.h>
#include <string.h>

int main()
{
    char str[20] = "abc,def";

    printf("memmove()実行前\n");
    printf("%s\n", str);
    // => abc,def

    if (memmove(str+4, str, strlen(str))) {
        printf("memmove()実行後\n");
        printf("%s\n", str);
        // => abc,abc,def
    } else {
        printf("エラー発生\n");
    }
}
```


### memcmp()

構文 : `memcmp(文字列1, 文字列2, 長さ)`

- 2つの文字列から指定されたバイト数を比較します。
- 返り値は以下のようになります。
  - 文字列1 > 文字列2 のとき、正の値
  - 文字列1 = 文字列2 のとき、0
  - 文字列1 < 文字列2 のとき、負の値

```c
#include <stdio.h>
#include <string.h>

int main()
{
    char str1[5] = "test";
    char str2[5] = {'t', 'e', 's', 't', '\0'};
    if (memcmp(str1, str2, 5*sizeof(char)) == 0) {
        printf("str1とstr2は同じです。\n");
    } else {
        printf("str1とstr2は異なります。\n");
    }
    // => str1とstr2は同じです。
}
```


### memchr()

構文 : `memchr(文字列, 検索文字, 文字列長)`

- 文字列の中で指定した文字の最初に出現する場所を探します。

```c
#include <stdio.h>
#include <string.h>

int main()
{
    char *ptr;
    char str[] = "test";
    ptr = memchr(str, 's', strlen(str));
    if (ptr != NULL) {
        printf("文字「s」の場所: ", ptr - str + 1);
    } else {
        printf("文字「s」は見つかりませんでした。");
    }
    // => 文字「s」の場所: 3
}
```


#### 参考

- [C dynamic memory allocation](https://fresh2refresh.com/c-programming/c-dynamic-memory-allocation/)
- [C Buffer manipulation functions](https://fresh2refresh.com/c-programming/c-buffer-manipulation-function/)
