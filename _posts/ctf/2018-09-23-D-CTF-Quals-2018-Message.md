---
layout:        post
title:         "D-CTF Quals 2018 Message Writeup"
menutitle:     "D-CTF Quals 2018 Message Writeup"
date:          2018-09-23
tags:          CTF
category:      CTF
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

課題内容：

> Message (Misc)
>
> I just typed this secret message with my new encoding algorithm. \\
> Author: Lucian Nitescu

message.txtの中身：

```
wsxcvasdfghrfvbnhytqwertymnbvcdrtghuzxcvbnwsxcdeasdfghzaqwdrtgbzxcvbn qwertywsxqwertynbvcxswefrqwertyiuyhnbvqwertywsxcvfrasdfghzaqwdrtgbzxcvbn qwertywsxasdfghiuyhnbvasdfgh zxcvbnytrfvcxqwertywsxasdfghzaqwdrtgbqwertymnbvccdertgzxcvbnedcvbasdfghefvtzxcvbn asdfghwsxcfezxcvbnedcvbgtasdfghzaqwdrtgbqwertyxsweftynhzxcvbnjmyizxcvbn zxcvbnrtyuihnzxcvbnwsxcdeasdfghrgnygcqwertyrtyuihnasdfgh qwertyqazxcdewzxcvbnredcfzxcvbn zxcvbnwertyfvzxcvbnrfvgyhnasdfghwsxcdeqwerty qwertynbvcxswefrzxcvbnmnbvcdrtghuzxcvbnrfvqwertyxsweftgbqwertyrtyuihnqwertywsxasdfghxsweftgbzxcvbncvgredasdfgh asdfghgrdxcvbzxcvbnxsweftbgasdfghwsxcfeqwerty ...
```


## Writeup

とりあえず換字式暗号を考えたので（実際は違うが）、頻度解析して見ると：

```
v  ( 7.2%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1008
r  ( 6.5%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 918
c  ( 6.5%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 910
e  ( 6.3%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 885
f  ( 6.1%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 861
t  ( 5.8%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 814
b  ( 5.7%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 804
x  ( 5.7%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 796
w  ( 5.6%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 784
d  ( 5.6%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 783
n  ( 5.2%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 738
y  ( 5.0%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 711
g  ( 5.0%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 702
s  ( 4.9%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 687
h  ( 4.6%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 654
z  ( 3.5%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 493
q  ( 3.3%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 464
a  ( 3.1%) : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 437
   ( 1.3%) : ▇▇▇▇▇▇ 181
u  ( 1.2%) : ▇▇▇▇▇▇ 168
i  ( 0.8%) : ▇▇▇▇ 119
m  ( 0.5%) : ▇▇ 77
0  ( 0.1%) : ▏ 12
k  ( 0.1%) : ▏ 10
j  ( 0.1%) : ▏ 9
.  ( 0.1%) : ▏ 8
,  ( 0.1%) : ▏ 8
5  ( 0.0%) : ▏ 7
1  ( 0.0%) : ▏ 6
3  ( 0.0%) : ▏ 6
9  ( 0.0%) : ▏ 5
8  ( 0.0%) : ▏ 5
6  ( 0.0%) : ▏ 4
7  ( 0.0%) : ▏ 4
4  ( 0.0%) : ▏ 4
'  ( 0.0%) : ▏ 2
{  ( 0.0%) : ▏ 1
2  ( 0.0%) : ▏ 1
}  ( 0.0%) : ▏ 1
\n ( 0.0%) : ▏ 1
```

「{」と「}」が1回ずつ現れているので、{} があるあたりにフラグがあると予想。
数字も少ないが何個か含まれていることが確認できるので、この辺を grep なりで調べる。

数字と数字の間には5,6文字のアルファベットがあり、これを取り除くと 1500 や 1960 が現れるので、
余分なゴミが含まれていると考えて、「qwerty」「zxcvbn」「asdfgh」を削除した。

```
asdfgh1qwerty5zxcvbn0asdfgh0qwertyiuyhnbvzxcvbn,qwerty
zxcvbn1qwerty9qwerty6zxcvbn0asdfghytrfvcxqwerty
```

同様に、数字と数字の間にある複数回出現する文字列があったのでこれも取り除いた。
取り除いた文字列をまとめていると、
**キーボード上での特定の動き**（直線、三角形、四角形）を表していることがわかった。

- qwerty → -
- zxcvbn → -
- asdfgh → -
- zsefvcx → △
- grdxcvb → △
- wsxcde → □
- rfvbhg → 6?
- redcf → o?
- qazxcdew → □
- trfvg → o?
- ewsxc → C
- trfvb → C
- edcvgr → D
- qazxds → 6
- yhnmku → D
- xsweftgb → M
- iuyhnbv → S
- wsxcvfre → □
- ytrfvcx → S
- rtyuihn → T
- edcvbgt → U
- zaqwdvfr → N
- wsxcfe → D
- wertyfv → T
- rfvgyhn → N
- wdcft → V
- wertyfv → T

フラグは `DCTF{` で始まるので、{ がある部分の前の部分と比較すると、対応関係がわかる。
これより「qwerty」「asdfgh」「zxcvbn」は完全に必要ないことが確認できる。

```
# before
qwertywsxcfeasdfghtrfvbasdfghrtyuihnzxcvbnredcfqwerty{

# after
qwerty  -
wsxcfe  D
asdfgh  -
trfvb   C
asdfgh  -
rtyuihn T
zxcvbn  -
redcf   F
qwerty  -
{
```

D-CTFの過去のWriteupとかを読むと `DCTF{ [0-9a-f]* }` という形式が多いので、
{} の中には a〜f の文字があると仮定して文字を当てはめると、下の表になる。

- zsefvcx → A
- xcvbgrd → A
- grdxcvb → A
- rfvbhg → b
- trfvb → C
- redcv → C
- edcvgr → D
- yhnmku → D
- wsxcfe → D
- edcvrf → E
- wsxcde → E
- redcf → F
- trfvg → F

表を元にフラグを作っていくと：

```
wsxcfe  D
trfvb   C
rtyuihn T
redcf   F
{
rfvbhg  b
66
edcvrf  e
redcv   c
zsefvcx a
xcvbgrd a
grdxcvb a
90
zsefvcx a
edcvgr  d
05
yhnmku  d
redcf   f
5
wsxcfe  d
zsefvcx a
wsxcfd  b
33
edcvgr  d
71
grdxcvb a
8
trfvg   f
70934408
redcf   f
3
zsefvcx a
5847
zsefvcx a
4
ewsxc   c
5
trfvb   c
38
edcvgr  d
qazxds  b
75891
rfvbhg  b
0
trfvg   f
0
wsxcde  e
32
}
```

結果は

```
DCTF{b66ecaaa90ad05df5dab33d71a8f70934408f3a5847a4c5c38db75891b0f0e32}
```
