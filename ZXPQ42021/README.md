### IBM Z Student Contest, October 2021

The IBM Z Student Contest on October 2021 challenges us to solve a series of problems and obtain the correct solution based on a given input.

To use the solution, copy over all the files to your UNIX System Services directory, and execute `q421drop5.sh`. The shell script can accept an argument containing the path to an input file which lists out a series of variables for the input data. Alternatively, if no argument is provided, it will defaults to the test data provided.

You will then need to replace all occurance of `ZUSER` with your ID, and `zpass` with your password. Additionally, you will need to provide an API key for [Mapbox](https://www.mapbox.com/) on `q421drop5.py` for the dynamic map feature.

A copy of the input file can be found below:
```
zDSN=ZXP.CONTEST.Q42021.SOURCE
zPATH=/z/zxp-contest/20211015
zSCHEMA=ZXP214
zURL=https://zxp-support.mybluemix.net/contest/4q21/contact-sheet
zOUTPUT=OUTPUT(Q421DRP5)
zREPORT=q421report
```

The script will create a member as specified on `zOUTPUT`, and an HTML report at the USS directory specified by `zREPORT`.

| Files         | Description   |
| ------------- | ------------- |
| q421drop1.jcl | JCL which will run ISPF Command provided |
| q421drop1.rexx | REXX script which obtains data sets information from ISPF |
| q421drop1.sh | Shell script which executes Drop 1 to obtain information on the craftable vehicle |
| q421drop2.sh | Shell script which executes Drop 2 by looping through the provided ZFS directory |
| q421drop3-password.sql | SQL which will look for the Db2 password on the metadata of the schema |
| q421drop3.py | Python script which processes data for Drop 3 |
| q421drop3.sh | Shell script which executes Drop 3 by accessing Db2 via the command line processor |
| q421drop3.sql | SQL which looks for the necessary data for Drop 3 |
| q421drop4.py | Python script which processes data for Drop 4 by operating on the provided API | 
| q421drop4.sh | Shell script which executes Drop 4 |
| q421drop5.py | Python script which combine all the previous output to produce an HTML report |
| q421drop5.sh | Shell script which executes Drop 1 until 5 |

