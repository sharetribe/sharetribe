#!/bin/bash
# usage:
#  ./compose-email-image.sh listing-email-variant-150x100.jpg author-thumbnail-48x48.jpg listing-with-avatar.png

# 1. make rounded corners
convert "$1" \( +clone -alpha extract \
\( -size 4x4 xc:black -draw 'fill white circle 4,4 4,0' -write mpr:arc +delete \) \
\( mpr:arc \) -gravity northwest -composite \
\( mpr:arc -flip \) -gravity southwest -composite \
\( mpr:arc -flop \) -gravity northeast -composite \
\( mpr:arc -rotate 180 \) -gravity southeast -composite \) \
-alpha off -compose CopyOpacity -composite listing-image-rounded.png

# 2. cut circle from avatar
convert "$2" -alpha set \( +clone -distort DePolar 0 -virtual-pixel HorizontalTile -background None -distort Polar 0 \) -compose Dst_In -composite -trim +repage avatar-circle.png

# 3. create white circle for border
convert xc:none -background transparent -fill white -extent 64x54 -draw 'circle 32,27 32,2' white-circle.png

# 4. compose avatar and circle border
composite -compose Over -gravity center avatar-circle.png white-circle.png avatar-bordered.png

# 5. combine listing and author
convert listing-image-rounded.png -gravity southwest -background transparent -extent 150x116 l-s.png
composite -compose Over -gravity northeast avatar-bordered.png l-s.png "$3"
