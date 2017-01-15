#!/bin/sh

# adapted from: https://gist.github.com/richellis/09ccd6060d4e7ac7717d8767a2e27d39

set -e

source="./DotfileWatcher/menu-bar.pdf"
target="./DotfileWatcher"

if [ ! -x "$(command -v convert)" ]
    then
        echo "Executable 'convert' not found in path. Please install ImageMagick."
elif [ ! -x "$(command -v gs)" ]
    then
        echo "Executable 'gs' not found in path. Please install GhostScript."
else
    echo "Creating icons from $source into $target/Assets.xcassets/AppIcon.appiconset/..."

    for i in 16 32 64 128 256 512 1024
        do
            echo "Creating $i px icon"
            convert -density 400 $source -scale $ix$i ./$target/Assets.xcassets/AppIcon.appiconset/appicon_$i.png
    done

    echo "Created app icon files, writing Contents.json file..."

    echo '{"images":[
{\n"size":"16x16",\n"idiom":"mac",\n"filename":"appicon_16.png",\n"scale":"1x"\n},
{\n"size":"16x16",\n"idiom":"mac",\n"filename":"appicon_32.png",\n"scale":"2x"\n},
{\n"size":"32x32",\n"idiom":"mac",\n"filename":"appicon_32.png",\n"scale":"1x"\n},
{\n"size":"32x32",\n"idiom":"mac",\n"filename":"appicon_64.png",\n"scale":"2x"\n},
{\n"size":"128x128",\n"idiom":"mac",\n"filename":"appicon_128.png",\n"scale":"1x"\n},
{\n"size":"128x128",\n"idiom":"mac",\n"filename":"appicon_256.png",\n"scale":"2x"\n},
{\n"size":"256x256",\n"idiom":"mac",\n"filename":"appicon_256.png",\n"scale":"1x"\n},
{\n"size":"256x256",\n"idiom":"mac",\n"filename":"appicon_512.png",\n"scale":"2x"\n},
{\n"size":"512x512",\n"idiom":"mac",\n"filename":"appicon_512.png",\n"scale":"1x"\n},
{\n"size":"512x512",\n"idiom":"mac",\n"filename":"appicon_1024.png",\n"scale":"2x"\n}\n],
"info":{\n"version":1,\n"author":"xcode"\n}\n}' > "./$target/Assets.xcassets/AppIcon.appiconset/Contents.json"

    echo "Complete!"
fi
