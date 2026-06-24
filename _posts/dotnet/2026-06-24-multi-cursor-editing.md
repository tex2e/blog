---
layout:        post
title:         "Visual Studioのマルチカーソル機能のカスタマイズ"
date:          2026-06-24
category:      Dotnet
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

VSCodeなどのエディタではマルチカーソル機能で複数箇所を同時に編集することができます。
しかし、Visual Studio 2022以降では、マルチカーソル機能を使用して「Ctrl + D」を押した際、単語の選択ではなく行の複製（Duplicate）がされてしまう問題が発生することがあります。これは、主にキーボードショートカットの割り当て競合が原因です。

以下の手順で「Ctrl+D」にマルチカーソル機能が割り当たっていることを確認し、必要に応じて変更してください。

### キーボードショートカットの確認・変更

「Ctrl+D」が行の複製に割り当てられている可能性があるため、これを解除または変更します。

1. Visual Studio 上部メニューの [ツール] (Tools) > [オプション] (Options) を開く。
2. [環境] (Environment) > [キーボード] (Keyboard) を選択。
3. キーボード を押下し、従来のオプションダイアログを開く
4. 「以下の文字列を含むコマンドを表示」欄に **Edit.Duplicate（編集.複製）** と入力。
5. 下のショートカット一覧に Ctrl+D があれば、選択して [削除] (Remove) をクリック。
6. 次に、マルチカーソル（次の一致を選択）のコマンドを探す。
    - コマンド名: **Edit.SelectionNextMatch (編集.次の一致にキャレットを挿入)**
7. これに Ctrl+D が割り当たっていることを確認する。

[OK] をクリックして設定を閉じる。

<figure>
<img src="{{ site.baseurl }}/media/post/dotnet/multi-cursor-editing-EditDuplicate.png" />
<figcaption>Edit.Duplicateの設定画面</figcaption>
</figure>

<figure>
<img src="{{ site.baseurl }}/media/post/dotnet/multi-cursor-editing-InsertNextMatchingCaret.png" />
<figcaption>Edit.SelectionNextMatchの設定画面</figcaption>
</figure>

以上です。
