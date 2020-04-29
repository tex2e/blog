#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "ArguemntError: wrong number of arguments (given $#, expected 2)"
  echo "./new.sh <category> <postname>"
  exit 1
fi

# Set category of article.
case $1 in
  latex )
    category="LaTeX" ;;
  * )
    # Uppercase first character (e.g. python => Python)
    category="$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}"
    ;;
esac

cat > _posts/$1/$(date +%Y-%m-%d)-${2:-post}.md <<EOS
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
# sitemap: false
# feed:    false
---

preface
EOS

bundle exec jekyll build --future
