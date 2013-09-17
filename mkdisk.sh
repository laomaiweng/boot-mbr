#!/bin/sh
#man mkdiskimage
#man syslinux

if [ -z "$1" -o "$1" = "--help" -o "$1" = "-h" ]
then
    echo "USAGE: ${0##*/} FILE"
    echo
    echo "  Creates a 16M disk image with 1 head, 63 sectors/track"
    echo " and an MS-DOS MBR into FILE."
    echo " Prints the first partition offset to stdout."

    exit 0
fi

mkdiskimage -o "$1" -M 16 1 63

