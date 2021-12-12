#!/bin/sh

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2021 Drop 2"
echo "--------------------------------------"

# Specify contest data
if [ $# -eq 0 ]; then
    ZFS="/z/zxp-contest/20211015"
else
    ZFS=$1
fi

# Remove temp file if it exists
if [ -f q421drop2-output.txt ] ; then
    rm q421drop2-output.txt
fi
if [ -f q421drop1-final-output.txt ] ; then
    rm q421drop1-final-output.txt
fi

# Looping through filesystem and deciphering filename
echo "Looping through filesystem and deciphering filename"
# Give time for first drop to be done
sleep 15
# Check that the first drop has finished
if [ -f q421drop1-uuid-output.txt ] ; then
    awk 'BEGIN{FS=OFS=","}NR==FNR{a[$2]=$1;next}{print $1","$2","a[$2]}' q421drop1-vendor-output.txt q421drop1-uuid-output.txt > q421drop1-final-output.txt
    while IFS=, read -r ASM UUID VID; do
        find $ZFS/vendors/$VID/agents/.$VID/ -type f -exec basename {} \; | while read FILENAME; do
            # Translate cipher
            CODE=$(echo $FILENAME | tr '0987654321zyxwvutsrqponmlkj@' 'abcdefghijklmnopqrstuvwxyz -')
            CODE=${CODE#"."}
            # Translate NATO alphabet
            CODE=$(echo $CODE | sed -e 's/$/ /' -e 's/\([^ ]\)[^ ]* /\1/g' -e 's/^ *//' | tail -c -9 | tr '[:lower:]' '[:upper:]')
            # Print to output file
            echo $CODE >> q421drop2-output.txt
        done
    done <q421drop1-final-output.txt
else
    find $ZFS/vendors/* -perm 1700 -type d | while read DIRECTORY ; do
        # Get vendor id
        VENDORID=$(echo $DIRECTORY | tail -c -7)
        # Loop through files in directory
        find $DIRECTORY/agents/.$VENDORID/ -type f -exec basename {} \; | while read FILENAME; do
            # Translate cipher
            CODE=$(echo $FILENAME | tr '0987654321zyxwvutsrqponmlkj@' 'abcdefghijklmnopqrstuvwxyz -')
            CODE=${CODE#"."}
            # Translate NATO alphabet
            CODE=$(echo $CODE | sed -e 's/$/ /' -e 's/\([^ ]\)[^ ]* /\1/g' -e 's/^ *//' | tail -c -9 | tr '[:lower:]' '[:upper:]')
            # Print to output file
            echo $CODE >> q421drop2-output.txt
        done
    done
fi

# Sort output file
sort -r -o q421drop2-output.txt q421drop2-output.txt

# Move output to MVS
cp -O u q421drop2-output.txt "//'ZUSER.OUTPUT(Q421DRP2)'"

# Print result
echo "Engineers found! Output available on ZUSER.OUTPUT(Q421DRP2)."