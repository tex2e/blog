#!/bin/bash -e

if [[ $# -ne 2 ]]; then
  echo "ArguemntError: wrong number of arguments (given $#, expected 2)"
  echo "./new.sh <category> <postname>"
  exit 1
fi

directory=$1

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
  pentest-enum* )
    directory="pentest-enumeration"
    category="Pentest Enumeration" ;;
  pentest-foothold )
    category="Pentest Foothold" ;;
  pentest-escalation )
    category="Pentest Escalation" ;;
  pentest-misc )
    category="Pentest Misc" ;;
  * )
    # Uppercase first character (e.g. python => Python)
    category="$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}"
    ;;
esac

cat > "_posts/$directory/$(date +%Y-%m-%d)-${2%.md}.md" <<EOS
---
layout:        post
title:         "This_is_Awesome"
date:          $(date +%Y-%m-%d)
category:      $category
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

preface
EOS

bundle exec jekyll build --future
