#!/bin/bash

if [[ "$1" =~ ^re ]]; then
  bundle exec jekyll build
fi

bundle exec jekyll server -I --livereload --future

# --limit_posts 1
