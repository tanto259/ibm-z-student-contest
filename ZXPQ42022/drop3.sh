#!/bin/sh

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2022 Drop 3"
echo "--------------------------------------"

# Specify contest data
if [ $# -eq 0 ]; then
    ZFS="/z/zxp-contest/q4y22/test/"
    SEARCH="ZXP.CONTEST.Q4Y2022.TEST.GSK"
    RESULT="ZUSER.CONTEST"
    MEMBER="GSK"
else
    ZFS=$1
    SEARCH=$2
    RESULT=$3
    MEMBER=$4
fi

# Remove temp file if it exists
if [ -f ~/Q4Y22/drop3-vendors.txt ] ; then
    rm ~/Q4Y22/drop3-vendors.txt
fi
if [ -f ~/Q4Y22/drop3-search-key.txt ] ; then
    rm ~/Q4Y22/drop3-search-key.txt
fi
if [ -f ~/Q4Y22/drop3-orders.txt ] ; then
    rm ~/Q4Y22/drop3-orders.txt
fi
if [ -f ~/Q4Y22/drop3-output.txt ] ; then
    rm ~/Q4Y22/drop3-output.txt
fi

# Get search key
echo "Getting search key"
cp "//'$SEARCH'" ~/Q4Y22/drop3-search-key.txt
SEARCHKEY=$(openssl enc -base64 -d -in ~/Q4Y22/drop3-search-key.txt)

# Looping through filesystem
echo "Looping through filesystem"
for FILE in $ZFS.master/.vendors/.* ; do
    if grep -q $SEARCHKEY $FILE; then
        grep $SEARCHKEY $FILE >> ~/Q4Y22/drop3-vendors.txt
        NAME="${FILE#$ZFS.master/.vendors/.}"
        CODE=$(echo $NAME | tr 'A-Za-z' 'N-ZA-Mn-za-m')
        # Looping through to find order ID for vendors
        while IFS= read -r LINE; do
            ORDER="${LINE#$ZFS}"
            ORDER="${ORDER%/*}"
            echo $ORDER >> ~/Q4Y22/drop3-orders.txt
        done <$ZFS.master/$CODE
    fi
done

# Sort output file
sort -r -o ~/Q4Y22/drop3-orders.txt ~/Q4Y22/drop3-orders.txt
sort -o ~/Q4Y22/drop3-vendors.txt ~/Q4Y22/drop3-vendors.txt

# Get 5 highest order ID
cp ~/Q4Y22/drop3-orders.txt ~/Q4Y22/drop3-orders.txt.bak
head -n 5 ~/Q4Y22/drop3-orders.txt.bak > ~/Q4Y22/drop3-orders.txt
cp ~/Q4Y22/drop3-orders.txt ~/Q4Y22/drop3-orders.txt.bak

rm ~/Q4Y22/drop3-orders.txt

# Get the order transaction for each ID
while IFS= read -r LINE; do
    TRAN=$(cat $ZFS.master/.history/$LINE | tr -d "[:blank:]")
    echo $LINE":"$TRAN >> ~/Q4Y22/drop3-orders.txt 
done <~/Q4Y22/drop3-orders.txt.bak

rm ~/Q4Y22/drop3-orders.txt.bak

# Append file together
cat ~/Q4Y22/drop3-vendors.txt ~/Q4Y22/drop3-orders.txt > ~/Q4Y22/drop3-output.txt

# Move output to MVS
cp -O u ~/Q4Y22/drop3-output.txt "//'$RESULT($MEMBER)'"

# Print result
echo "GSK found! Output available on $RESULT($MEMBER)."