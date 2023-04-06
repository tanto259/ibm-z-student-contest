### IBM Z Student Contest, September 2022

The IBM Z Student Contest on September 2022 challenges us to solve a series of problems and obtain the correct solution based on a given input.

To use the solution, copy over all the files to a folder called `Q4Y22` in your UNIX System Services directory, and execute `runpipe.sh`. The shell script can accept an argument containing the fully qualified name of a sequential data set which lists out a series of variables for the input data. Alternatively, if no argument is provided, it will defaults to the test data provided.

You will then need to replace all occurance of `ZUSER` with your ID, and `zpass` with your password. 

A copy of the input file can be found below:
```
PREFIX=ZXP.CONTEST.Q4Y2022.TEST
KEYS=MEA,STK,GSK,GAS,ASM
RESULTS=DSN(CONTEST(SPDS,FB,80))
PIPELINE=SHELL(~/Q4Y22/runpipe.sh)
MEADATA=DSN(DATA)
MEARESULTS=CONTEST(MEA)
STKDATA=SQL(ZXP422.STK*)
STKRESULTS=CONTEST(STK)
GSKDATA=ZFS(/z/zxp-contest/q4y22/test/)
GSKRESULTS=CONTEST(GSK)
GASDATA=DSN(GAS.PRODUCT,GAS.VENDOR,GAS.PRODPROC,GAS.PROC)
GASRESULTS=CONTEST(GAS)
ASMDATA=URL(http://192.86.32.12:1880/Q4Y22/<type|mea-code>[/<set-id>])
ASMRESULTS=CONTEST(ASM)
REPORT=ZFS(~/Q4Y22/report/q4y22.md)
```

The script will create a Markdown report at the USS directory specified by `REPORT`.

| Files         | Description   |
| ------------- | ------------- |
| drop1.jcl | JCL which will run ISPF Command provided |
| drop1.py | Python script which processes data for Drop 1 |
| drop1.rexx | REXX script which obtains data sets information from ISPF |
| drop1.sh | Shell script which executes Drop 1 to obtain information on the MEA data |
| drop2-password.sql | SQL which will look for the Db2 password on the metadata of the schema |
| drop2.py | Python script which processes data for Drop 2 |
| drop2.sh | Shell script which executes Drop 2 by accessing Db2 via the command line processor |
| drop2.sql | SQL which looks for the necessary data for Drop 2 |
| drop3.sh | Shell script which executes Drop 3 by looping through the provided ZFS directory |
| drop4.jcl | JCL which run IDCAMS and DFSORT to take VSAM data | 
| drop4.py | Python script which processes data for Drop 4 | 
| drop4.sh | Shell script which executes Drop 4 |
| drop5.py | Python script which processes data for Drop 5 by operating on the provided API | 
| drop5.sh | Shell script which executes Drop 5 |
| runpipe-control.py | Python script which take in the input data and process them |
| runpipe-report.py | Python script which combine all the previous output to produce a Markdown report |
| runpipe.sh | Shell script which executes Drop 1 until 5, along with the runpipe scripts |