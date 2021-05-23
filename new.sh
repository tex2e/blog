#!/bin/bash -e

if [[ $# -ne 2 ]]; then
  echo "ArguemntError: wrong number of arguments (given $#, expected 2)"
  echo "./new.sh <category> <postname>"
  exit 1
fi

directory=$1
cover="cover1"

# Set category of article.
case $1 in
  latex )
    category="LaTeX" ;;
  vb.net )
    category="VB.NET" ;;
  *batch )
    directory="windowsbatch"
    category="WindowsBatch" ;;
  powershell|pwsh )
    directory="powershell"
    category="PowerShell" ;;
  crypto )
    cover="cover4" ;;
  * )
    # Uppercase first character (e.g. python => Python)
    category="$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}"
    ;;
esac

if ! [[ -e "_posts/$directory" ]]; then
  echo "Must create directory: $directory"
  exit
fi

cat > "_posts/$directory/$(date +%Y-%m-%d)-${2%.md}.md" <<EOS
---
layout:        post
title:         "This_is_Awesome"
date:          $(date +%Y-%m-%d)
category:      $category
cover:         /assets/$cover.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

preface
EOS

bundle exec jekyll build --future
