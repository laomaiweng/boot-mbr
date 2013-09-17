#!/bin/sh


TARGET="test.img"
MBR="`echo *.S | sed -e 's/\.S\>//g'`"


if [ -z "$1" ]
then
    echo "Available MBRs: $MBR"
    exit 0
fi

FOUND=false
for m in $MBR
do
    if [ "$1" = "$m" ]
    then
        set -e
        make $1
        objdump -M addr16,data16,att-mnemonic -d $1.o > $1.lst
        hexdump -C -s 0x7c00 $1.mbr
        dd if=$1.mbr bs=512 count=1 skip=$((0x7c00/512)) conv=notrunc of=$TARGET
        FOUND="true"
    fi
done

if [ "$FOUND" = "false" ]
then
    echo "Available MBRs: $MBR"
fi


## EOF ##
