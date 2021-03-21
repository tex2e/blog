---
layout:        post
title:         "ImageMagicでExifのOrientationから画像を適切に回転する"
date:          2020-03-29
category:      Shell
cover:         /assets/cover1.jpg
redirect_from: /misc/mogrify-auto-orient
comments:      true
published:     true
latex:         false
# sitemap: false
# draft:   true
---

iPadで撮影した画像を別のところに取り込むときに、Exifの関係で画像が回転されてしまうので、ExifのOrientationを削除して、適切な向きに画像を回転するには ImageMagic の `mogrify` コマンドを使います。

`mogrify -auto-orient` で Exif の Orientation を読んで画像を適切な方向に回転します。

```bash
$ identify -verbose SAMPLE.JPG | grep -E 'Geometry|Orient'
  Geometry: 2592x1936+0+0
  Orientation: RightTop
    exif:Orientation: 6

$ mogrify -auto-orient SAMPLE.JPG

$ identify -verbose SAMPLE.JPG | grep -E 'Geometry|Orient'
  Geometry: 1936x2592+0+0
  Orientation: TopLeft
    exif:Orientation: 1
```

`identify` コマンドを使うと画像の「幅x高さ」と「Orientation情報」を確認できます。

以上です。
