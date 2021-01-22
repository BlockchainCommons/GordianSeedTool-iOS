#!zsh

SOURCE=${PWD}/AppIcon.png
TARGET_DIR=${PWD}/AppIcon.appiconset

convert_icon() (
    SIZE=$1
    NAME=$2

    convert -resize ${SIZE}x${SIZE} ${SOURCE} ${TARGET_DIR}/${NAME}.png
)

convert_icon 40 icon-40
convert_icon 80 icon-40@2x
convert_icon 120 icon-40@3x
convert_icon 120 icon-60@2x
convert_icon 180 icon-60@3x
convert_icon 72 icon-72
convert_icon 144 icon-72@2x
convert_icon 76 icon-76
convert_icon 152 icon-76@2x
convert_icon 167 icon-83.5@2x
convert_icon 50 icon-small-50
convert_icon 100 icon-small-50@2x
convert_icon 29 icon-small
convert_icon 58 icon-small@2x
convert_icon 87 icon-small@3x
convert_icon 57 icon
convert_icon 114 icon@2x
convert_icon 1024 ios-marketing
convert_icon 40 notification-icon@2x
convert_icon 60 notification-icon@3x
convert_icon 20 notification-icon~ipad
convert_icon 40 notification-icon~ipad@2x
