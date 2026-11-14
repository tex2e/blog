---
layout:        post
title:         "ImageMagicでExifのOrientationから画像を適切に回転する"
type:          How-To
description:   "ImageMagickのmogrify -auto-orientコマンドでExifのOrientation情報をもとに画像を適切な向きへ回転・修正する方法を解説します。"
tags:          [shell, imagemagick, exif, image-processing]
status:        stable
stale_after:   2024-03-21T00:00:00Z
generated:
  by:          human:tex2e
  at:          2020-03-31T01:40:12Z
date:          2020-03-29
category:      Shell
cover:         /assets/cover14.jpg
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
