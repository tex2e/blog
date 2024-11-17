#!/bin/bash -eu

# /opt/homebrew/opt/ruby/bin/bundle install
# /opt/homebrew/opt/ruby/bin/bundle update

{
  BUNDLE=bundle
  if [ -f /opt/homebrew/opt/ruby/bin/bundle ]; then
    BUNDLE=/opt/homebrew/opt/ruby/bin/bundle
  fi

  # ビルドのみ
  if [[ "${1:-}" =~ ^build ]]; then
    "$BUNDLE" exec jekyll build --future
    exit
  fi

  # ビルドしてからサーバ起動
  if [[ "${1:-}" =~ ^re ]]; then
    "$BUNDLE" exec jekyll build --future
    shift
  fi

  # Start Server

  # ホットリロード高速化対応
  EXTRA_ARGS=
  if [ $# -ge 1 ]; then
    if [[ $1 =~ ^[0-9]+$ ]]; then
      EXTRA_ARGS+="--limit_posts $1"
      shift
    fi
  fi

  "$BUNDLE" exec jekyll server --incremental --livereload --future $EXTRA_ARGS
  # --limit_posts 1
  # --port 4001
}
