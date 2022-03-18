---
layout:        post
title:         "ブログ記事を書いてCPEを申請する"
date:          2022-03-18
category:      Security
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    true
# sitemap: false
# feed:    false
---

[(ISC)² Japan の CPEクレジット](https://japan.isc2.org/member_cpecredit.html) に書かれているCPE付与対象活動のガイドラインを読むと、専門的なブログを執筆した場合、「専門的な活動による貢献」のカテゴリ (グループA) で10CPEクレジットを得ることができます。
ここでは、ブログ記事によるCPEの申請手順について説明します。

ISC2 準会員は年に 15 CPE を獲得する必要があります。
今回申請する対象のブログ記事は、[Dirty Pipeの脆弱性をSELinuxで緩和する](https://tex2e.github.io/blog/linux/dirty-pipe) です。
まず ISC2 のページにログインして、Dashboard から「View Details」を選択します。

<figure>
<img src="{{ site.baseurl }}/media/post/cissp/cissp-cpe-blog1.png" width=650px />
</figure>

まずは、[CPE Handbook](https://www.isc2.org/cpe-handbook) に一通り目を通しておきましょう。
次に記事を書き始めて日付と、書き終えた日付を入力して「Continue」を選択します。

<figure>
<img src="{{ site.baseurl }}/media/post/cissp/cissp-cpe-blog2.png" width=650px />
</figure>

カテゴリは「Contributions to the Profession (専門的な活動による貢献)」を選択し、ブログ記事を書いたので「Writing, Researching, Publishing」を選択します。

<figure>
<img src="{{ site.baseurl }}/media/post/cissp/cissp-cpe-blog3.png" width=650px />
</figure>

続いて、タイトルは日本語そのままを入力し、書き物の種類は「Professional Blog (専門的なブログ)」、書き物への関与方法は「Sole Author (単著)」、出版社はないのでブログのURLを書き、出版年はブログ記事を公開した年を記入します。
最後に、0.25単位で最大40CPEを申請できますが、CPE Handbook の Contributions to the Profession の CPE Rules に従って、10 CPE を入力します。

<figure>
<img src="{{ site.baseurl }}/media/post/cissp/cissp-cpe-blog4.png" width=650px />
</figure>

エビデンスの提出はブログ記事の場合は不要です。例えば、パネルディスカッションやプレゼンテーションの場合は準備に使用した資料などを、エビデンスとして添付して提出します。
「Save & Continue」を押して次に進みます。

<figure>
<img src="{{ site.baseurl }}/media/post/cissp/cissp-cpe-blog5.png" width=650px />
</figure>

申請するCPEがどのドメインの範囲のものかを選択します。
自分の書いた内容は Security Operations (セキュリティの運用) に近いので、これを選択しました。
迷ったら、CISSP ドメインガイドブックを確認しましょう。
「Save & Continue」を押して次に進みます。

<figure>
<img src="{{ site.baseurl }}/media/post/cissp/cissp-cpe-blog6.png" width=650px />
</figure>

提出前の確認画面になります。
問題がなければ「Submit CPE」で提出します。

<figure>
<img src="{{ site.baseurl }}/media/post/cissp/cissp-cpe-blog7.png" width=650px />
</figure>

提出した翌朝に確認したら、10 CPE が加わり、更新に必要な CPE の数が 4 に減りました。

<figure>
<img src="{{ site.baseurl }}/media/post/cissp/cissp-cpe-blog8.png" width=650px />
</figure>

普段からブログを書いている人は、CPE獲得において有利だと思います。

以上です。

### 参考文献
- [Qiitaの記事を書いてCPEを申請する - Qiita](https://qiita.com/toshikawa/items/9cefe7e685d058f19b19)
