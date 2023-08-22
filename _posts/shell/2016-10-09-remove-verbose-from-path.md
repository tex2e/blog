---
layout:        post
title:         "冗長なパス foo/bar/../lib を foo/lib に変換する"
date:          2016-10-09
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

シェルスクリプトで複数の変数に代入されたパスをつなげたときに、冗長なパスになってしまうのを修正したい（foo/bar/../lib を foo/lib にしたい）。
ということがあったので、その解決法について説明します。


問題
---------------

複数のパスをつなげたときに冗長なパスが作られてしまい、見た目が悪いです。
ただし、動作自体は問題なく動きます。
例えば `ls /usr/local/bin/../..` と `ls /usr` は同じ結果になります。

問題になるのは、そのパスを出力させるときに読みづらいという点です。


解決方法
---------------

私が作った次の関数 `remove_verbose` を使えば解決する。

```bash
function remove_verbose {
  local path=$1
  local stack=()
  local from_root=$( [[ $path == /* ]] && echo "yes" || echo "no" )

  IFS='/'
  set -- $path

  for dir in $@; do
    case $dir in
      "." )
        # if encounter ".", current dir, next.
        continue
        ;;
      ".." )
        # if encounter "..", parent dir, pop.
        local n=$(( ${#stack[@]} - 1 ))
        unset stack[$n]
        stack=( ${stack[@]} )
        ;;
      * )
        # otherwise, push
        stack+=( $dir )
        ;;
    esac
  done

  # print non-verbose path
  path=
  path+=$(test $from_root == "yes" && echo "/")
  path+=$(echo "${stack[@]}" | awk 'OFS="/" { $1=$1; print }')

  if [[ "$path" == "" ]]; then
    echo "."
  else
    echo "$path"
  fi
}

remove_verbose "/usr/local/bin/../../lib"        # => /usr/lib
remove_verbose "/usr/local/bin/../../.."         # => /
remove_verbose "foo/a/b/c/d/../../../../bar/baz" # => foo/bar/baz
remove_verbose "foo/./././bar/baz"               # => foo/bar/baz
remove_verbose "foo/.."                          # => .
remove_verbose "foo/../../../bar"                # error!
```

やってることは、与えられたパスを "/" で区切って配列に一つずつ代入し、
".." が見つかったら配列の最後の要素を pop して、
最後の配列に残った要素を "/" で連結させて、出力しています。

ただ、`foo/../../../bar` のように、現在のディレクトリより上に行こうとすると、
配列の pop で失敗してしまいます。


参照
---------------

[シェルスクリプトで配列へのpush/pop](http://lake-michigan.hatenablog.com/entry/20110419/1303207600)
