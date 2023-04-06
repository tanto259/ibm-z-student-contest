//DROP1    JOB 
//*-------------------------------------------------------*/
//*  EXECUTE ISPF COMMAND IN THE BACKGROUND               */
//*-------------------------------------------------------*/
//* https://www.ibm.com/docs/en/zos/2.4.0?topic=environment-sample-batch-job
//*
//ISPFBACK EXEC PGM=IKJEFT01,DYNAMNBR=25,REGION=1024K
//*- - ALLOCATE PROFILE, PANELS, MSGS, PROCS, AND TABLES -*/
//ISPPROF  DD RECFM=FB,LRECL=80,SPACE=(TRK,(2,2,2))
//ISPPLIB  DD DSN=ISP.SISPPENU,DISP=SHR
//ISPMLIB  DD DSN=ISP.SISPMENU,DISP=SHR
//ISPSLIB  DD DSN=ISP.SISPSENU,DISP=SHR
//         DD DSN=ISP.SISPSLIB,DISP=SHR
//ISPTLIB  DD RECFM=FB,LRECL=80,SPACE=(TRK,(1,0,1))
//         DD DSN=ISP.SISPTENU,DISP=SHR
//ISPTABL  DD RECFM=FB,LRECL=80,SPACE=(TRK,(1,0,1))
//*
//*- - ALLOCATE ISPF LOG DATA SET  - - - - - - - - - - - -*/
//ISPLOG   DD SYSOUT=*,RECFM=FB,LRECL=133
//*
//*- - ALLOCATE DIALOG PROGRAM AND TSO COMMAND LIBRARIES -*/
//ISPLLIB  DD DSN=ZUSER.LOAD,DISP=SHR
//SYSEXEC  DD DSN=ISP.SISPEXEC,DISP=SHR
//SYSPROC  DD DSN=ZUSER.CONTEST,DISP=SHR
//         DD DSN=ISP.SISPCLIB,DISP=SHR
//*
//*- - ALLOCATE TSO BACKGROUND OUTPUT AND INPUT DS - - - -*/
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
  PROFILE PREFIX(ZUSER)         
  ISPSTART CMD(%DROP1 '?DATA?')        
/*