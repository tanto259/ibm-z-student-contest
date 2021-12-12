#!/bin/sh

echo "  ___ ____  __  __   _____  ____  _             _            _      ____            _            _    ";
echo " |_ _| __ )|  \/  | |__  / / ___|| |_ _   _  __| | ___ _ __ | |_   / ___|___  _ __ | |_ ___  ___| |_  ";
echo "  | ||  _ \| |\/| |   / /  \___ \| __| | | |/ _\` |/ _ \ '_ \| __| | |   / _ \| '_ \| __/ _ \/ __| __|";
echo "  | || |_) | |  | |  / /_   ___) | |_| |_| | (_| |  __/ | | | |_  | |__| (_) | | | | ||  __/\__ \ |_  ";
echo " |___|____/|_|  |_| /____| |____/ \__|\__,_|\__,_|\___|_| |_|\__|  \____\___/|_| |_|\__\___||___/\__| ";
echo "                                                                                                      ";

# Get input file
if [ $# -eq 0 ]; then
    FILE="/z/zxp-contest/.zxp214.sample/setup.txt"
else
    FILE=$1
fi

# Remove temp file if it exists
if [ -f q421drop5-setup.txt ] ; then
    rm q421drop5-setup.txt
fi
if [ -f q421drop5-output.txt ] ; then
    rm q421drop5-output.txt
fi
if [ -f q421drop5-valid-vendors.txt ] ; then
    rm q421drop5-valid-vendors.txt
fi
if [ -f q421drop5-location-list.txt ] ; then
    rm q421drop5-location-list.txt
fi

# Edit invalid char
sed 's/^/export /g; s/=/="/g; s/$/"/g' $FILE > q421drop5-setup.txt

# Get path backup and process input variables
echo "Processing input variables"
. ./q421drop5-setup.txt

# Execute previous drops with data
echo "Executing drops"
./q421drop1.sh $zDSN
./q421drop2.sh $zPATH
./q421drop3.sh $zSCHEMA
./q421drop4.sh $zURL

# Remove previous report
if [ -d $zREPORT ] ; then
    rm -rf $zREPORT
fi

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2021 Drop 5"
echo "--------------------------------------"

# Process input
echo "Process current data"
awk 'BEGIN{FS=OFS=","}NR==FNR{a[$2]=$1;next}{print $1","$2","a[$2]}' q421drop1-vendor-output.txt q421drop1-uuid-output.txt > q421drop5-valid-vendors.txt
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$4;b[$1]=$5;next}{print $1","$2","$3","$4","$5","a[$3]","b[$3]}' FS="," q421drop4-location.txt FS="|" q421drop3-format.txt > q421drop5-location-list.txt

# Process report
echo "Making a vehicle requirement report"
python3 ./q421drop5.py

# Move report to folder
mkdir $zREPORT
mv q421-report.html $zREPORT

# Move output to MVS
cp -O u q421drop5-output.txt "//'ZUSER.$zOUTPUT'"

# Print result
echo "Report and output created! Output available on ZUSER.$zOUTPUT."
echo "Report available on $zREPORT/q421-report.html."
