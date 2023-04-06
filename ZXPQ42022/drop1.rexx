/* REXX */
PARSE ARG DATA
ADDRESS TSO
/* Get lookup table */
/* Flags for file i/o */
EOFFLAG=2
RETURN_CODE=0
/* Open lookup table */
"FREE FI(indd)"
"ALLOC FI(indd) SHR REU",
    "DA('"DELSTR(DELSTR(DATA,LENGTH(DATA),1),1,1)"($LOOKUP$)')"
"EXECIO 0 DISKR indd (OPEN"
DO WHILE(RETURN_CODE \= EOFFLAG)
    "EXECIO 1 DISKR indd"
    RETURN_CODE=RC
    IF RETURN_CODE=0 THEN
        DO
            /* Check to see which member is MEA */
            PARSE PULL CONTENT
            CODESTART=POS('|',CONTENT)+1
            CODEEND=POS('|',CONTENT,CODESTART)
            CODELEN=CODEEND-CODESTART
            CODE=SUBSTR(CONTENT,CODESTART,CODELEN)
            SAY CODESTART CODEEND CODE
            IF COMPARE(CODE,"MEA")=0 THEN
                DO
                    MEMCODE=SUBSTR(CONTENT,1,CODESTART-2)
                END
            ELSE NOP
        END
    ELSE NOP
END
"EXECIO 0 DISKR indd (FINIS"
/* Set cmd dest to ISPF services */
ADDRESS ISPEXEC
/* Initialize a data set list */
"LMINIT DATAID(DATAID) DATASET("DATA") ENQ(SHR)"
/* Open the data set list in read only */
"LMOPEN DATAID("DATAID") OPTION(INPUT)"
/* Set counter */
MEA=1
/* Run through the member, get the stats */
DO WHILE RC=0
    "LMMLIST DATAID("DATAID")",
        "OPTION(LIST) MEMBER(MEMBER) STATS(YES)"
    IF RC=8 THEN LEAVE
    /* Get the lists of eligible member */
    /* https://www.ibm.com/docs/en/zos/2.4.0?topic=member-parameters */
    IF COMPARE(STRIP(MEMBER), '$LOOKUP$') \= 0 THEN
    DO
        STARTAT=POS('@',STRIP(MEMBER))+1
        ENDAT=POS('@',STRIP(MEMBER),STARTAT+1)
        LENAT=ENDAT-STARTAT
        SAY STARTAT ENDAT STRIP(MEMBER) MEMCODE
        IF COMPARE(SUBSTR(STRIP(MEMBER),STARTAT,LENAT),MEMCODE)=0 THEN
            IF COMPARE(STRIP(ZLUSER),"ZXP")=0 THEN
                DO
                    ASSEMBLY.MEA=STRIP(MEMBER)
                    MEA=MEA+1
                END
            ELSE NOP
    END
END
/* Set length of stem */
ASSEMBLY.0 = MEA-1
/* Free data sets association */
"LMFREE DATAID("DATAID")"
/* Set cmd dest to USS syscall */
CALL SYSCALLS 'ON'
ADDRESS SYSCALL
/* Open valid member output */
PATH='/z/ZUSER/Q4Y22/drop1-valid-members.txt'
"OPEN" PATH O_RDWR+O_CREAT+O_APPEND 660
FD=RETVAL
DO I=1 TO ASSEMBLY.0
    REC=ASSEMBLY.I || ESC_N
    "WRITE" FD "REC" LENGTH(REC)
END
"CLOSE" FD