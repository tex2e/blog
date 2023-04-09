---
layout:        post
title:         "awkでCSVのN番目の列だけを置換する"
date:          2023-04-07
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

CSVのN番目の列だけを置換する方法について説明します。
LinuxのBashでCSVのN番目の列だけを置換するには、awkコマンドを使います。

```bash
awk -F "," '{OFS=","; gsub(/置換前/, "置換後", $N); print $0}' ファイル名
```

<br>

### CSVのN番目を置換する

例えば、データがカンマ（,）で区切られているCSVファイルに対して、6列目の内容を空白に置き換えたい場合は、以下のシェルスクリプトを実行します。

```bash
for filename in *.csv; do
  awk -F "," '{OFS=","; gsub(/.*/, "", $6); print $0}' "$filename" > "$filename.replaced.csv"
done
```

awkコマンドを使って、-F（入力時の区切り文字）とOFS変数（出力時のフィールド区切り文字）の両方にカンマ（,）を指定します。
各行は `{ }` の中で評価されるため、gsub関数を使って、6番目の内容 `$6` を正規表現で置換します。
最後に置換済みの全体の内容 `$0` を print で出力します。

### タブ区切りのN番目を置換する

例えば、データがタブで区切られているDATファイルに対して、6列目の内容を空白に置き換えたい場合は、以下のシェルスクリプトを実行します。

```bash
for filename in *.dat; do
  awk -F "\t" '{OFS="\t"; gsub(/.*/, "", $6); print $0}' "$filename" > "$filename.replaced.dat"
done
```

awkコマンドを使って、-F（入力時の区切り文字）とOFS変数（出力時のフィールド区切り文字）の両方にタブ（\t）を指定します。

以上です。
