#!/bin/sh

echo "  ___ ____  __  __   _____  ____  _             _            _      ____            _            _    ";
echo " |_ _| __ )|  \/  | |__  / / ___|| |_ _   _  __| | ___ _ __ | |_   / ___|___  _ __ | |_ ___  ___| |_  ";
echo "  | ||  _ \| |\/| |   / /  \___ \| __| | | |/ _\` |/ _ \ '_ \| __| | |   / _ \| '_ \| __/ _ \/ __| __|";
echo "  | || |_) | |  | |  / /_   ___) | |_| |_| | (_| |  __/ | | | |_  | |__| (_) | | | | ||  __/\__ \ |_  ";
echo " |___|____/|_|  |_| /____| |____/ \__|\__,_|\__,_|\___|_| |_|\__|  \____\___/|_| |_|\__\___||___/\__| ";
echo "                                                                                                      ";

# Get input file
if [ $# -eq 0 ]; then
    CONTROL="ZXP.CONTEST.Q4Y2022.TEST.CONTROL"
else
    CONTROL=$1
fi

# Remove temp file if it exists
if [ -f ~/Q4Y22/runpipe-control.txt ] ; then
    rm ~/Q4Y22/runpipe-control.txt
fi
if [ -f ~/Q4Y22/runpipe-setup.txt ] ; then
    rm ~/Q4Y22/runpipe-setup.txt
fi

# Get control data set
cp "//'$CONTROL'" ~/Q4Y22/runpipe-control.txt

# Process control
echo "Processing CONTROL data"
python3 ~/Q4Y22/runpipe-control.py
. ~/Q4Y22/runpipe-setup.txt

# Execute previous drops with data
echo "Executing drops"
~/Q4Y22/drop1.sh $MEADATA $MEASEARCH $RESULT $MEAMEMBER
~/Q4Y22/drop2.sh $STKSCHEMA $STKSEARCH $RESULT $STKMEMBER
~/Q4Y22/drop3.sh $GSKZFS $GSKSEARCH $RESULT $GSKMEMBER
~/Q4Y22/drop4.sh $GASSEARCH $RESULT $GASMEMBER
~/Q4Y22/drop5.sh $ASMURL $RESULT $ASMMEMBER

echo "--------------------------------------"
echo "IBM Z Student Contest - Q4 2022 Report"
echo "--------------------------------------"

echo "Printing report to $REPORT"
python3 ~/Q4Y22/runpipe-report.py $REPORT