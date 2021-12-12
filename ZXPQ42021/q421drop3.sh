#!/bin/sh

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2021 Drop 3"
echo "--------------------------------------"

# Specify contest data
if [ $# -eq 0 ]; then
    SCHEMA="ZXP214"
else
    SCHEMA=$1
fi
PASSWORD="zpass"

# Remove temp file if it exists
if [ -f q421drop3-db2-output.txt ] ; then
    rm q421drop3-db2-output.txt
fi
if [ -f q421drop3-output.txt ] ; then
    rm q421drop3-output.txt
fi
if [ -f q421drop3-format.txt ] ; then
    rm q421drop3-format.txt
fi
if [ -f q421drop3-db2-password.txt ] ; then
    rm q421drop3-db2-password.txt
fi

# Get result from Db2
echo "Getting result from Db2"

sed "s/?SCHEMA?/$SCHEMA/g" ./q421drop3-password.sql > q421drop3-password.sql.tmp && mv q421drop3-password.sql.tmp q421drop3-password.sql
java com.ibm.db2.clp.db2 -f ./q421drop3-password.sql +c -z q421drop3-db2-password.txt -s -u ZUSER/$PASSWORD
sed "s/$SCHEMA/?SCHEMA?/g" ./q421drop3-password.sql > q421drop3-password.sql.tmp && mv q421drop3-password.sql.tmp q421drop3-password.sql

DB2PASS=$(sed -n -e '/^decrypt with/p' q421drop3-db2-password.txt | awk '{for (I=1;I<NF;I++) if ($I == "with") print $(I+1)}')

sed "s/?SCHEMA?/$SCHEMA/g; s/?PASS?/$DB2PASS/g" ./q421drop3.sql > q421drop3.sql.tmp && mv q421drop3.sql.tmp q421drop3.sql
java com.ibm.db2.clp.db2 -f ./q421drop3.sql +c -z q421drop3-db2-output.txt -s -u ZUSER/$PASSWORD
sed "s/$SCHEMA/?SCHEMA?/g; s/$DB2PASS/?PASS?/g" ./q421drop3.sql > q421drop3.sql.tmp && mv q421drop3.sql.tmp q421drop3.sql

# Process data
echo "Processing and validating data"
python3 ./q421drop3.py

# Move output to MVS
cp -O u q421drop3-output.txt "//'ZUSER.OUTPUT(Q421DRP3)'"

# Print result
echo "Location code found! Output available on ZUSER.OUTPUT(Q421DRP3)."