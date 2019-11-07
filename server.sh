#!/bin/bash

if [[ "$1" =~ ^build ]]; then
  bundle exec jekyll build --future
  exit
fi

if [[ "$1" =~ ^re ]]; then
  bundle exec jekyll build --future
fi

bundle exec jekyll server -I --livereload --future

# --limit_posts 1
