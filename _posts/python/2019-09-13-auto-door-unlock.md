---
layout:        post
title:         "研究室の自動開錠システムを作った話"
date:          2019-09-13
category:      Python
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
photoswipe:    true
---

研究室の自動開錠システムを後輩と協力して作ったので、そのシステム概要について少しお話したいと思います。

きっかけとしては、その昔、情技研 (情報技術研究部) に所属していた時 [^1] に先輩が研究室のドアをNFCのカードリーダを使って開錠できるシステムを作られたので、見せて頂いたことがありました。
そのシステムの実際の様子が動画として上がっています ([Suicaで解錠 -- Facebook](https://www.facebook.com/falcon.8823/videos/646548402082287/)) 。

時は流れて5年後、その先輩とは別の研究室に入りましたが、研究室で後輩とお話している中で、研究室のドアを鍵を使わないで開錠できたら面白いよね、みたいな話が上がってきました。
話が盛り上がったついでに実際に実装してみようということになりました (ノリと勢い) 。
役割分担としては、僕がRFCリーダとFelicaカードを買ってPythonでRFCリーダを使ってカードの認証周りを実装し、後輩がRaspberry Piとかドアに固定するための材料とかを買って、組み立てとか開錠ログ収集周りの実装とか、サーボモータを動作させるプログラムなども実装をしてくれました。

実際に完成したシステムの動作している様子です。撮影には別の後輩が協力してくれました。

<blockquote class="twitter-tweet tw-align-center"><p lang="ja" dir="ltr">研究室の自動解錠システム (完成版) <a href="https://t.co/1wywkXnlOK">pic.twitter.com/1wywkXnlOK</a></p>&mdash; まこ (@tex2e) <a href="https://twitter.com/tex2e/status/1141619729322299392?ref_src=twsrc%5Etfw">June 20, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

ちなみに弊学の情報科のドアは閉めると自動ロックされるタイプで、解錠するシステムだけ実装すれば良いので、施錠するシステムがない分、実装が少し楽です。

最初は機材を固定するために養生テープを使っていたので見た目が良くなかったのですが、ドアには磁石が付くことを利用して、自宅にあった磁石とかを持ってきて養生テープを全部磁石に置き換えていきました。
もちろんRaspberry Piに影響が出ないように考慮しています。

完成したあとで、Raspberry Piを再起動しても自動開錠システムが自動的に起動するように、systemdでプロセス再起動の設定をしたり、自分のノートパソコンとLANケーブルで接続できるようにRaspberry PiのethXを固定のローカルIPアドレスにしたり、自分の公開鍵を入れて秒でsshログインできるようにしたりしました。

システムの詳細部分を写真に撮りましたので、何かの参考になればと思います。

<div class="album">
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img1.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img2.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img3.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img4.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img5.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img12.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img13.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img6.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img7.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img8.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img10.jpg" />
      <figcaption></figcaption>
   </figure>
   <figure>
      <img src="{{ site.baseurl }}/media/post/auto-door-unlock/img11.jpg" />
      <figcaption></figcaption>
   </figure>
</div>


システムのソースコードは [fjt-lab/auto-door-unlock -- GitHub](https://github.com/fjt-lab/auto-door-unlock) に上げていますので、興味のある方は参考にしてください。

### 参考記事

- [RaspberryPiで！SONYのPaSoRi（RC-S380）で（NFC）Felica情報を読み取る！ - KOKENSHAの技術ブログ](https://kokensha.xyz/raspberry-pi/raspberrypi-sony-pasori-rc-s380-read-nfc-felica/)
- [Raspberry PiにNFCリーダを接続してSuicaを読み取る - Qiita](https://qiita.com/undo0530/items/89540a03252e2d8f291b)
- [RaspberryPiでNFCタグを使ってみる - uepon日々の備忘録](https://uepon.hatenadiary.com/entry/2018/06/12/223307)
- [RaspberryPi Zeroでサーボモータを動かす](https://web.archive.org/web/20180814203032/http://hara.jpn.com/_default/ja/Topics/RaspPi_Motor.html)
- [［後半］(本当の)0からNFCでカギで操作するソフトを作る。](https://eleken.jp/archives/1886)
- [2014年【開発】FeliCaオートロック -- falcon's diary](https://web.archive.org/web/20210120230802/https://blog.falconsrv.net/portfolio/2014%E5%B9%B4)
- [Amazon - SG5010 デジタルサーボ - ラジコン・ドローン 通販](https://www.amazon.co.jp/TOWER-PRO-%E3%82%BF%E3%83%AF%E3%83%BC%E3%83%97%E3%83%AD-SG5010-%E3%83%87%E3%82%B8%E3%82%BF%E3%83%AB%E3%82%B5%E3%83%BC%E3%83%9C/dp/B01LXJ8Y0Z)
- [Amazon - ソニー SONY 非接触ICカードリーダー/ライター PaSoRi RC-S380 - ソニー(SONY) - 外付メモリカードリーダー 通販](https://www.amazon.co.jp/%E3%82%BD%E3%83%8B%E3%83%BC-SONY-%E9%9D%9E%E6%8E%A5%E8%A7%A6IC%E3%82%AB%E3%83%BC%E3%83%89%E3%83%AA%E3%83%BC%E3%83%80%E3%83%BC-PaSoRi-RC-S380/dp/B00948CGAG)


---

[^1]: 部活として情技研には所属していたがほとんど顔を出していないので、世間でいうところの幽霊部員である。 大きな理由としては、部の多くを寮生が占めていたので輪に入りづらかったというのと、部活のスケジュールが寮生向けだったからであり、自宅で勉強した方が効率が良いと感じたからである。
