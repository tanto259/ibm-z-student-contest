#!/bin/sh

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2022 Drop 4"
echo "--------------------------------------"

# Specify contest data
if [ $# -eq 0 ]; then
    SEARCH="ZXP.CONTEST.Q4Y2022.TEST.GAS"
    RESULT="ZUSER.CONTEST"
    MEMBER="GAS"
else
    SEARCH=$1
    RESULT=$2
    MEMBER=$3
fi

# Remove temp file if it exists
if [ -f ~/Q4Y22/drop4-proc.txt ] ; then
    rm ~/Q4Y22/drop4-proc.txt
fi
if [ -f ~/Q4Y22/drop4-vendor.txt ] ; then
    rm ~/Q4Y22/drop4-vendor.txt
fi
if [ -f ~/Q4Y22/drop4-product.txt ] ; then
    rm ~/Q4Y22/drop4-product.txt
fi
if [ -f ~/Q4Y22/drop4-prodproc.txt ] ; then
    rm ~/Q4Y22/drop4-prodproc.txt
fi
if [ -f ~/Q4Y22/drop4-product-prodproc.txt ] ; then
    rm ~/Q4Y22/drop4-product-prodproc.txt
fi
if [ -f ~/Q4Y22/drop4-combined.txt ] ; then
    rm ~/Q4Y22/drop4-combined.txt
fi
if [ -f ~/Q4Y22/drop4-output.txt ] ; then
    rm ~/Q4Y22/drop4-output.txt
fi


# Get search key
echo "Getting sustainability process ranking"
cp "//'$SEARCH.PROC'" ~/Q4Y22/drop4-proc.txt

# Get VSAM file content
echo "Getting VSAM file data"
sed "s/?DATANAME?/$SEARCH.VENDOR/g; s#?PATH?#/z/ZUSER/Q4Y22/drop4-vendor.txt#g" ~/Q4Y22/drop4.jcl | submit -q
sed "s/?DATANAME?/$SEARCH.PRODUCT/g; s#?PATH?#/z/ZUSER/Q4Y22/drop4-product.txt#g" ~/Q4Y22/drop4.jcl | submit -q
sed "s/?DATANAME?/$SEARCH.PRODPROC/g; s#?PATH?#/z/ZUSER/Q4Y22/drop4-prodproc.txt#g" ~/Q4Y22/drop4.jcl | submit -q
sleep 5

echo "Processing data"
cp ~/Q4Y22/drop4-product.txt ~/Q4Y22/drop4-product.txt.bkp
tr -d '\r' < ~/Q4Y22/drop4-product.txt.bkp > ~/Q4Y22/drop4-product.txt
awk 'BEGIN{FS=OFS="*"}FNR==NR{a[$1]=$2;next}{print $1"|"$2"|"$3"|"$4"|"a[$4]"|"$5}' ~/Q4Y22/drop4-prodproc.txt ~/Q4Y22/drop4-product.txt > ~/Q4Y22/drop4-product-prodproc.txt
awk 'FNR==NR{a[$1]=$2;b[$1]=$3;next}{print $1"|"$2"|"$3"|"$4"|"$5"|"$6"|"a[$6]"|"b[$6]}' FS="," ~/Q4Y22/drop4-vendor.txt FS="|" ~/Q4Y22/drop4-product-prodproc.txt > ~/Q4Y22/drop4-combined.txt
rm ~/Q4Y22/drop4-product.txt.bkp
python3 ~/Q4Y22/drop4.py

# Move output to MVS
cp -O u ~/Q4Y22/drop4-output.txt "//'$RESULT($MEMBER)'"

# Print result
echo "GAS found! Output available on $RESULT($MEMBER)."