#!/bin/bash -eu

# /opt/homebrew/opt/ruby/bin/bundle install

{
  BUNDLE=bundle
  if [ -f /opt/homebrew/opt/ruby/bin/bundle ]; then
    BUNDLE=/opt/homebrew/opt/ruby/bin/bundle
  fi

  if [[ "${1:-}" =~ ^build ]]; then
    "$BUNDLE" exec jekyll build --future
    exit
  fi

  if [[ "${1:-}" =~ ^re ]]; then
    "$BUNDLE" exec jekyll build --future
  fi

  "$BUNDLE" exec jekyll server -I --livereload --future
  # --limit_posts 1
  # --port 4001
}
