#!/bin/sh

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2021 Drop 4"
echo "--------------------------------------"

# Specify contest data
if [ $# -eq 0 ]; then
    URL="https://zxp-support.mybluemix.net/contest/4q21/contact-sheet"
else
    URL=$1
fi

# Remove temp file if it exists
if [ -f q421drop4-output.txt ] ; then
    rm q421drop4-output.txt
fi
if [ -f q421drop4-location.txt ] ; then
    rm q421drop4-location.txt
fi

# Process data
echo "Processing and validating locator"
python3 ./q421drop4.py $URL

# Move output to MVS
cp -O u q421drop4-output.txt "//'ZUSER.OUTPUT(Q421DRP4)'"

# Print result
echo "Location coordinate found! Output available on ZUSER.OUTPUT(Q421DRP4)."