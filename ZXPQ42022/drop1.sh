#!/bin/sh

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2022 Drop 1"
echo "--------------------------------------"

# Specify contest data
if [ $# -eq 0 ]; then
    DATA="ZXP.CONTEST.Q4Y2022.TEST.DATA"
    SEARCH="ZXP.CONTEST.Q4Y2022.TEST.MEA"
    RESULT="ZUSER.CONTEST"
    MEMBER="MEA"
else
    DATA=$1
    SEARCH=$2
    RESULT=$3
    MEMBER=$4
fi

# Remove temp file if it exists
if [ -f ~/Q4Y22/drop1-valid-members.txt ] ; then
    rm ~/Q4Y22/drop1-valid-members.txt
fi
if [ -f ~/Q4Y22/drop1-raw-output.txt ] ; then
    rm ~/Q4Y22/drop1-raw-output.txt
fi
if [ -f ~/Q4Y22/drop1-output.txt ] ; then
    rm ~/Q4Y22/drop1-output.txt
fi

# Move rexx to MVS
cp -O u ~/Q4Y22/drop1.rexx "//'$RESULT(DROP1)'"

# Submit job to get ISPF statistics of members in data set
echo "Submitting REXX to get ISPF statistics"
sed "s/?DATA?/$DATA/g" ~/Q4Y22/drop1.jcl | submit -q
sleep 3

# Process valid members
python3 ~/Q4Y22/drop1.py $DATA $SEARCH

cp -O u ~/Q4Y22/drop1-output.txt "//'$RESULT($MEMBER)'"

# Print result
echo "MEA obtained! Output available on $RESULT($MEMBER)."