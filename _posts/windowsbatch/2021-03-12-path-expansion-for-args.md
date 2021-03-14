---
layout:        post
title:         "バッチファイルの引数の文字列置換・パス展開"
date:          2021-03-12
category:      WindowsBatch
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

バッチファイルの引数の文字列置換・パス展開の一覧について説明します。

### 番号付き変数の展開

| 変数 | 説明 | 例
|---+---+---
| `%1` | 渡された1番目の引数 | C:\path\to\file.txt
| `%~1` | 周りの「"」の除去
| `%~d1%` | ドライブ名 (Drive) | C:
| `%~p1%` | フォルダパス (Path) | \path\to
| `%~dp1%` | ドライブ名＋フォルダパス | C:\path\to
| `%~f1%` | フルパス (Full path) | C:\path\to\file.txt
| `%~n1%` | 拡張子なしファイル名 (Name) | file
| `%~x1%` | 拡張子 (eXtension) | .txt
| `%~nx1%` | ファイル名＋拡張子 | file.txt
| `%~s1%` | 短縮名 (Short) (存在時のみ) | C:\path\to\file.txt
| `%~a1%` | ファイル属性 | `--a------`
| `%~t1%` | 更新時間 | 2021/03/12 17:38
| `%~z1%` | ファイルサイズ(byte) | 849

なお、`%~a1` で表示した内容はそれぞれ以下の意味を持ちます。

| ファイル属性                    | 表記
|------------------------------+------------
| FILE_ATTRIBUTE_DIRECTORY     | `d--------`
| FILE_ATTRIBUTE_READONLY      | `-r-------`
| FILE_ATTRIBUTE_ARCHIVE       | `--a------`
| FILE_ATTRIBUTE_HIDDEN        | `---h-----`
| FILE_ATTRIBUTE_SYSTEM        | `----s----`
| FILE_ATTRIBUTE_COMPRESSED    | `-----c---`
| FILE_ATTRIBUTE_OFFLINE       | `------o--`
| FILE_ATTRIBUTE_TEMPORARY     | `-------t-`
| FILE_ATTRIBUTE_REPARSE_POINT | `--------l`
| FILE_ATTRIBUTE_NORMAL        | `---------`


使用例：

```batch
rem 実行時引数の場合
echo %1
echo %~d1%
echo %~p1%
echo %~dp1%
echo %~f1%
echo %~n1%
echo %~x1%
echo %~nx1%
echo %~s1%
echo %~a1%
echo %~t1%
echo %~z1%

rem 変数にファイル名を格納している場合
for %%i in (%FilePath%) do set DATA=%%~di
for %%i in (%FilePath%) do set DATA=%%~pi
for %%i in (%FilePath%) do set DATA=%%~dpi
for %%i in (%FilePath%) do set DATA=%%~fi
for %%i in (%FilePath%) do set DATA=%%~ni
for %%i in (%FilePath%) do set DATA=%%~xi
for %%i in (%FilePath%) do set DATA=%%~nxi
for %%i in (%FilePath%) do set DATA=%%~si
for %%i in (%FilePath%) do set DATA=%%~ai
for %%i in (%FilePath%) do set DATA=%%~ti
for %%i in (%FilePath%) do set DATA=%%~zi
```

### 変数の文字列置換

| 変数 | 説明
|---+---
| %PATH:str1=str2% | 変数内の文字列1を文字列2に置換
| %PATH:~5,7% | 変数内の5文字目から7文字を抽出
| %PATH:~7,-2% | 変数内の7文字目から後ろから3文字目までを抽出

使用例：

```batch
set SCRIPT=Hello, world!

echo %SCRIPT%                    & rem "Hello, world!"
echo %SCRIPT:world=Windows%      & rem "Hello, Windows!"
echo %SCRIPT:~2,3%               & rem "llo"
echo %SCRIPT:~7,-1%              & rem "world"
```

以上です。

### 参考文献

- [Variable substitutions in cmd.exe](http://cplusplus.bordoon.com/cmd_exe_variables.html)
- [Parameters / Arguments - Windows CMD - SS64.com](https://ss64.com/nt/syntax-args.html)
