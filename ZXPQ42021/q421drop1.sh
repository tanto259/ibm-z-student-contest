#!/bin/sh

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2021 Drop 1"
echo "--------------------------------------"

# Specify contest data
if [ $# -eq 0 ]; then
    DATASET="ZXP.CONTEST.Q42021.SOURCE"
else
    DATASET=$1
fi

# Remove temp file if it exists
if [ -f q421drop1-vendor-output.txt ] ; then
    rm q421drop1-vendor-output.txt
fi
if [ -f q421drop1-output.txt ] ; then
    rm q421drop1-output.txt
fi
if [ -f q421drop1-uuid-output.txt ] ; then
    rm q421drop1-uuid-output.txt
fi

# Move rexx to MVS
cp -O u q421drop1.rexx "//'ZUSER.SOURCE(Q421DRP1)'"

# Submit job to get ISPF statistics of members in data set
echo "Submitting REXX to get ISPF statistics and process data"
sed "s/?DATASET?/$DATASET/g" ./q421drop1.jcl | submit -q

# Print result
echo "Vehicle obtained! Output available on ZUSER.OUTPUT(Q421DRP1)."