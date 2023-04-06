#!/bin/sh

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2022 Drop 5"
echo "--------------------------------------"

# Specify contest data
if [ $# -eq 0 ]; then
    URL="http://192.86.32.12:1880/Q4Y22/"
    RESULT="ZUSER.CONTEST"
    MEMBER="ASM"
else
    URL=$1
    RESULT=$2
    MEMBER=$3
fi

# Remove temp file if it exists
if [ -f ~/Q4Y22/drop5-output.txt ] ; then
    rm ~/Q4Y22/drop5-output.txt
fi
if [ -f ~/Q4Y22/drop5-raw-output.txt ] ; then
    rm ~/Q4Y22/drop5-raw-output.txt
fi


# Process data
echo "Processing data"
python3 ~/Q4Y22/drop5.py $URL

# Move output to MVS
cp -O u ~/Q4Y22/drop5-output.txt "//'$RESULT($MEMBER)'"

# Print result
echo "Assembly done! Output available on $RESULT($MEMBER)."