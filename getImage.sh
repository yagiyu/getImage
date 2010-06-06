#!/bin/sh

T=temp.tmp

if [ -z "$1" ]; then
    echo "Usage: getImage.sh [query]"
    echo
    exit
fi

mkdir -p "$1"
if [ ! -f "$1.txt" ]; then
    perl getImageURL.pl $1 > "$1.txt"
fi

for URL in `cat "$1.txt"`; do
    wget -q -O $T "$URL"
    MD5=`md5sum ${T} | cut -d ' ' -f 1`
    EXT=`echo $URL | awk -F '/' '{print $NF;}' | awk -F '.' '{print $NF;}'`
    echo "$1/$MD5.$EXT"
    mv -f "$T" "$1/$MD5.$EXT"
done
