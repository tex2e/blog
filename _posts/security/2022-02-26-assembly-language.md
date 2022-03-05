---
layout:        post
title:         "アセンブリ言語を読むための基礎知識"
date:          2022-02-26
category:      Security
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

アセンブリ言語について勉強したときの備忘録です。レジスタとアセンブリの命令とその意味について説明します。

## レジスタ
CPUにはレジスタが含まれており、アセンブリの命令の処理結果を保存したりするために使用します。

### EAX
- Accumulator Register
- 関数の戻り値を格納するために使うことが多い
- 命令の引数で指定しなくても使うことがある
- 各レジスタ名：
    - RAX (Register AX) : 64bit
    - EAX (Extend AX) : 32bit
    - AX : 16bit
    - AL : AXの最下位8bit (右側)
    - AH : AXの最上位8bit (左側)

### EBX
- Base Address Register
- 相対メモリ空間を表すときに、基準（ベース）となるアドレスが格納されることがある
- 各レジスタ名：
    - RBX (Register BX) : 64bit
    - EBX (Extend BX) : 32bit
    - BX : 16bit
    - BL : BXの最下位8bit (右側)
    - BH : BXの最上位8bit (左側)

### ECX
- Count Register
- 一部の命令では引数で指定しなくてもカウントとして使う
- ループをする rep 命令は、ECX の値が 0 以外なら引数で指定したアドレスへ移動し、ECX の値を 1 減らす
- 各レジスタ名：
    - RCX (Register CX) : 64bit
    - ECX (Extend CX) : 32bit
    - CX : 16bit
    - CL : CXの最下位8bit (右側)
    - CH : CXの最上位8bit (左側)

### EDX
- Data Register
- 計算結果データの一時記憶に使う
- 剰余を求める idiv 命令では、商を eax, 余りを edx に格納する
- 各レジスタ名：
    - RDX (Register DX) : 64bit
    - EDX (Extend DX) : 32bit
    - DX : 16bit
    - DL : DXの最下位8bit (右側)
    - DH : DXの最上位8bit (左側)

### ESI
- Source Register
- 文字列操作の命令などでコピー元（ソース）となるデータへのポインタを格納する
- 文字列操作の movsb 命令は、
- 各レジスタ名：
    - RSI (Register SI) : 64bit
    - ESI (Extend SI) : 32bit
    - SI : 16bit
    - SIL : SIの最下位8bit (右側)

### ESP
- Stack Pointer Register
- スタックを管理するポインタで、常にスタックのトップアドレスを格納する
- 各レジスタ名：
    - ESP : 32bit

### EBP
- Stack Base Pointer Register
- スタックを管理するポインタで、常にスタックのベースアドレスを格納する
- 各レジスタ名：
    - EBP : 32bit

### EFLAGレジスタ
- 32bitのレジスタで、各ビットがフラグとして意味を持つ
- 上位16bit：
  - 21 : ID (Identification flag) : 識別フラグ
  - 20 : VIP (Virtual Interrupt Pending flag) : 仮想割込み保留フラグ
  - 19 : VIF (Virtual Interrupt flag) : 仮想割込みフラグ
  - 18 : AC (Alignment Check flag) : メモリのアライメントチェックの有無
  - 17 : VM (Virtual-8086 Mode flag) : 仮想8086モード (16bit x86命令) の有無
  - 16 : RF (Resume Flag) : 再開フラグ
- 下位16bit：
  - 14 : NT (Nested Task flag) : 1なら割り込みや例外処理で開始したタスク
  - 13,12 : IOPL (I/O Privilege Level) : 現在実行しているプログラムのI/O特権レベル
  - 11 : OF (Overflow Flag) : 符号付き演算で桁あふれの有無
  - 10 : DF (Direction Flag) : 文字列操作で0なら次のアドレス、1なら前のアドレスを示す
  - 9 : IF (Interrupt Flag) : 割り込み許可。1なら割り込み可能
  - 8 : TF (Trap Flag) : シングルステップの許可（デバッグ用）
  - 7 : SF (Sign Flag) : 演算の結果が負数のとき1
  - 6 : **ZF** (Zero Flag) : 演算結果が0のとき1、それ以外のとき0
  - 4 : AF (Auxiliary carry Flag) : 演算の結果、下位4bitから上位4bitへ桁上がりしたとき1
  - 2 : PF (Parity Flag) : 演算の結果、各ビットで1となるビットの合計が偶数のとき1
  - 0 : CF (Carry Flag) : 演算の結果、桁上がりや桁下がりしたとき1

<br>

## 命令
CPUは、命令を1つずつフェッチして (fetch)、解析して (decode)、実行します (execute)。
実行した結果は、レジスタなどに保存 (store) します。

### 代入処理
- mov : 値代入
    - `mov ecx,1` : ECX = 1
    - `mov eax,00401000` : ECX = 00401000
    - `mov eax,[esi]` : EAX = ESI[0]
    - `mov eax,[esi+1]` : EAX = ESI[1]  (1byteの配列のとき)
    - `mov eax,[esi+2]` : EAX = ESI[2]  (1byteの配列のとき)
    - `mov eax,[esi+4]` : EAX = ESI[1]  (4byteの配列のとき)
    - `mov eax,[esi+8]` : EAX = ESI[2]  (4byteの配列のとき)
    - `mov [00401000],1` : アドレス00401000に1を格納する
- lea : 実効アドレスの代入
    - `lea eax, [edi+4]` : アドレス上で計算をする例。この場合 EAX = EDI + 4 と同じ意味になる

### 演算処理
- add : 加算
    - `add esp,8` : レジスタESPの値を +8 する
    - `add esp,FFFFFFB0h` : ESPの値を -80 する (補数表現で 00000050h = 80d)
- sub : 減算
    - `sub eax,2` : レジスタEAXの値を -2 する
    - `sub eax,ebx` : EAX -= EBX
- imul : 乗算
    - `imul ecx` : EAX = EAX * ECX
    - `imul edx,ebx` : EDX = EDX * EBX
    - `imul edx,ebx,1Ch` : EDX = EBX * 1Ch (28d)
- idiv : 除算剰余算
    - `idiv ecx` : EAX = EAX / ECX, EDX = EAX % ECX
- and : 論理積
- or  : 論理和
- xor : 排他的論理和
    - `xor eax,eax` : EAX に 0 を格納する
- not : 論理否定
- shl : 左論理シフト
    - `shl eax,4` : EAX <<= 4 (EAX *= 16 と同じ)
- shr : 右論理シフト
    - `shr eax,4` : EAX >>= 4 (EAX /= 16 と同じ)
- inc : インクリメント
    - `inc ebx` : EBX += 1
    - `inc [ebx+eax]` : EBX[EAX] += 1
- dec : デクリメント
    - `dec ebx` : EBX -= 1

### 文字列処理
- movsb / movsw / movsd : 文字列操作。ESIのアドレス参照値をEDIのアドレスへ Byte / Word (2byte) / Dword (4byte) 単位でコピーする。rep 命令と組み合わせて使う
- rep : movs系のループ命令。ECX の値が 0 以外なら引数で指定したアドレスへ移動し、ECX の値を 1 減らす
    - `rep movsb` : ESI から EDI へ文字列をコピーする
- cmpsb / cmpsw / cmpsd : 文字列比較
- repe : cmps系のループ処理。ECX の値が 0 または ZF==0 以外なら引数で指定したアドレスへ移動し、ECX の値を 1 減らす
- repne : cmps系のループ処理。ECX の値が 0 または ZF==1 以外なら引数で指定したアドレスへ移動し、ECX の値を 1 減らす

### 分岐命令
- cmp : 2つの引数を比較して結果をZFに格納する。2つが一致するときZF=1、それ以外ZF=0
    - `cmp eax,2` : EAX が 2 のときZF=1。後続のジャンプ命令と組み合わせて使う
- test : 2つの引数の論理積を求めて結果をZFに格納する。2つの論理積が0のときZF=1
    - `test eax,eax` : EAX が 0 のときZF=1。後続のジャンプ命令と組み合わせて使う
- jmp : 引数のアドレスへ移動する
    - `jmp 00402000` : アドレス 00402000 へ移動する
- je : ZF==1のとき、引数のアドレスへ移動する
- jne / jnz : ZF==0のとき、引数のアドレスへ移動する
- jl : 直前のcmp命令で第1引数<第2引数のとき、引数のアドレスへ移動する
- jg : 直前のcmp命令で第1引数>第2引数のとき、引数のアドレスへ移動する
- jle : 直前のcmp命令で第1引数<=第2引数のとき、引数のアドレスへ移動する
- jge : 直前のcmp命令で第1引数>=第2引数のとき、引数のアドレスへ移動する
- jcxz : CXの値が0のとき、引数のアドレスへ移動する
- jecxz : ECXの値が0のとき、引数のアドレスへ移動する

### 繰り返し処理
- for (EBX=1; EBX<10; EBX++)
    ```
    mov ebx,1       ; EBX=1
    本体の処理
    inc ebx         ; EBX++
    cmp ebx,10      ; EBX<10
    jl 00402000     ; 条件を満たすとき、本体の処理の1行目へ移動する
    ```
### スタック処理
- push : スタックの一番上に、4byteの値を追加する
    - `push ebx` : EBX の値をスタックに追加する
    - スタックポインタ ESP のアドレス値を -4 する（スタックに値を追加するたびにトップアドレスは小さいアドレス値になる）
- pop : スタックの一番上から、4byteの値を取得して削除する
    - `pop ebx` : スタックの一番上の値を EBX に格納して、スタックから削除する
    - スタックポインタ ESP のアドレス値を +4 する

### 関数呼び出し
- call : 引数のアドレスを関数として呼び出す。自身の次のアドレスをスタックにpushし、その後に引数のアドレスへ移動する
    - `call 00402000` : アドレス 00402000 の関数を呼び出す
    - アドレスに移動したら、呼び出し元のベースポインタの値をスタックに追加し、ベースポインタ EBP に、スタックポインタ ESP の値を格納する
        ```
        push ebp      ; 呼び出し元のベースポインタの退避
        mov ebp,esp   ; スタックポインタの値をベースポインタとして使用
        関数本体の処理
        ```
- retn : 関数の最後に呼ばれる命令。スタックの最上位に格納されているアドレスに移動する
    - 呼び出し元に戻り前に、ベースポインタ EBP の値を復元する
        ```
        関数本体の処理
        pop ebp       ; ベースポインタの復元
        retn          ; 呼び出し元のアドレスへ移動
        ```
    - 一般的な関数は、結果を EAX に格納することが多い
- 関数の呼び出し時や戻り時には、EBP と ESP を操作する
- 関数本体の処理開始時の ebp は、呼び出し元関数の EBP が格納されていること
- 関数本体の処理開始時の [ebp+4] は、CALLが追加した戻りアドレスが格納されていること
- 関数に引数を渡すときは、逆順にpushすること
    ```
    push 56h
    push 34h
    push 12h
    call 00402000           ; f(12h,34h,56h) を実行する
    ```
- 関数本体の処理開始時の関数の引数は、[ebp+8], [ebp+12], ... で取得することができる
- 関数本体の処理開始時の関数のローカル変数は、[ebp-4], [ebp-8], ... で取得することができる
- 関数内で引数を消費しない場合は、スタックに残り続けるので、自分で ESP を操作して整合性を保つ
    ```
    push 34h       ; スタックに追加(-4byte)
    push 12h       ; スタックに追加(-4byte)
    call 00402000  ; 関数呼び出し
    add esp,8      ; スタックポインタの移動(+8byte)
    ```
- 関数内でレジスタを使用する際は、関数呼び出し元へ汚染しないように、使用する前にpushして使用後にpopする
    ```
    push ebp
    mov ebp,esp
    push ebx        ; 呼び出し元のレジスタEBXの退避
    関数でレジスタebxを使う処理
    pop ebx         ; 呼び出し元のレジスタEBXの復元
    pop ebp
    retn
    ```

### Windows API

- 命名規則：
  - 基本的にAPI名はキャメルケース (CopyFileなど)
  - 末尾に「Ex」が付く場合は拡張版を表す (CopyFileExなど)
  - 最末尾に「A」が付く場合は、ANSI規格のマルチバイト (char型) に対応して日本語が使える
  - 最末尾に「W」が付く場合は、ワイド文字 (wide_t型) に対応してUnicodeが使える (FindFirstFileNameWなど)
- 不明なWindows API は「API名 msdn」で検索する
- 静的解析で注目すべきAPI：
  - ファイル操作：
    - CreateFile
    - DeleteFile
    - WriteFile
    - MoveFile
  - 通信：
    - send
    - recv
    - connect
    - HttpOpenRequest
    - InternetReadFile
    - URLDownloadToFile
  - プロセス操作：
    - CreateProcess
    - CreateThread
    - CreateToolhelp32Snapshot
    - Process32First
    - Process32Next
    - StartService
    - Winexec
    - ShellExecute
  - インジェクション：
    - CreateRemoteThread
    - WriteProcessMemory
    - SetWindowsHookEx
  - キーロガー：
    - GetAsyncKeyState
    - GetKeyState
  - レジストリ：
    - RegOpenKey
    - RegSetValue
    - RegCloseKey

### その他
- 不明な命令は「命令名 intel」などで検索する。Intelの公式資料が一番正確
    - 公式のアセンブラのリファレンス : [https://software.intel.com/en-us/articles/intel-sdm](https://software.intel.com/en-us/articles/intel-sdm)
    - 次の見出しまでスクロール : Four-Volume Set of Intel® 64 and IA-32 Architectures Software Developer’s Manuals
    - 次のPDFを参照する : 『Intel® 64 and IA-32 architectures software developer's manual combined volumes 2A, 2B, 2C, and  2D: Instruction set reference, A-Z』

以上です。
