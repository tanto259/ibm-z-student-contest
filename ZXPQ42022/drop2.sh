#!/bin/sh

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2022 Drop 2"
echo "--------------------------------------"

# Specify contest data
if [ $# -eq 0 ]; then
    SCHEMA="ZXP422"
    SEARCH="ZXP.CONTEST.Q4Y2022.TEST.STK"
    RESULT="ZUSER.CONTEST"
    MEMBER="STK"
else
    SCHEMA=$1
    SEARCH=$2
    RESULT=$3
    MEMBER=$4
fi
PASSWORD="zpass"

# Remove temp file if it exists
if [ -f ~/Q4Y22/drop2-db2-output.txt ] ; then
    rm ~/Q4Y22/drop2-db2-output.txt
fi
if [ -f ~/Q4Y22/drop2-output.txt ] ; then
    rm ~/Q4Y22/drop2-output.txt
fi
if [ -f ~/Q4Y22/drop2-raw-output.txt ] ; then
    rm ~/Q4Y22/drop2-raw-output.txt
fi
if [ -f ~/Q4Y22/drop2-search-key.txt ] ; then
    rm ~/Q4Y22/drop2-search-key.txt
fi
if [ -f ~/Q4Y22/drop2-db2-password.txt ] ; then
    rm ~/Q4Y22/drop2-db2-password.txt
fi

# Get result from Db2
echo "Getting result from Db2"

sed "s/?SCHEMA?/$SCHEMA/g" ~/Q4Y22/drop2-password.sql > ~/Q4Y22/drop2-password.sql.tmp && mv ~/Q4Y22/drop2-password.sql.tmp ~/Q4Y22/drop2-password.sql
java com.ibm.db2.clp.db2 -f ~/Q4Y22/drop2-password.sql +c -z ~/Q4Y22/drop2-db2-password.txt -s -u ZUSER/$PASSWORD
sed "s/$SCHEMA/?SCHEMA?/g" ~/Q4Y22/drop2-password.sql > ~/Q4Y22/drop2-password.sql.tmp && mv ~/Q4Y22/drop2-password.sql.tmp ~/Q4Y22/drop2-password.sql

DB2PASS=$(sed -n -e '/^key:/p' ~/Q4Y22/drop2-db2-password.txt | awk -F":" '{print (NF>1)? $NF : ""}' | awk '{$1=$1};1')

# Get search key
echo "Getting search key"
cp "//'$SEARCH'" ~/Q4Y22/drop2-search-key.txt
SEARCHKEY=$(openssl enc -base64 -d -in ~/Q4Y22/drop2-search-key.txt)

sed "s/?SCHEMA?/$SCHEMA/g; s/?PASS?/$DB2PASS/g; s/?KEY?/$SEARCHKEY/g" ~/Q4Y22/drop2.sql > ~/Q4Y22/drop2.sql.tmp && mv ~/Q4Y22/drop2.sql.tmp ~/Q4Y22/drop2.sql
java com.ibm.db2.clp.db2 -f ~/Q4Y22/drop2.sql +c -z ~/Q4Y22/drop2-db2-output.txt -s -u ZUSER/$PASSWORD
sed "s/$SCHEMA/?SCHEMA?/g; s/$DB2PASS/?PASS?/g; s/$SEARCHKEY/?KEY?/g" ~/Q4Y22/drop2.sql > ~/Q4Y22/drop2.sql.tmp && mv ~/Q4Y22/drop2.sql.tmp ~/Q4Y22/drop2.sql

# Process data
echo "Processing and validating data"
python3 ~/Q4Y22/drop2.py

# Move output to MVS
cp -O u ~/Q4Y22/drop2-output.txt "//'$RESULT($MEMBER)'"

# Print result
echo "STK found! Output available on $RESULT($MEMBER)."