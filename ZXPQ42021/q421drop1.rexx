/* REXX */
PARSE ARG CONTEST
/* Set cmd dest to ISPF services */
ADDRESS ISPEXEC
/* Initialize a data set list */
"LMINIT DATAID(DATAID) DATASET("CONTEST") ENQ(SHR)"
/* Open the data set list in read only */
"LMOPEN DATAID("DATAID") OPTION(INPUT)"
/* Set counter */
ASM=1
VHC=1
PRT=1
/* Run through the member, get the stats */
DO WHILE RC=0
    "LMMLIST DATAID("DATAID")",
        "OPTION(LIST) MEMBER(MEMBER) STATS(YES)"
    IF RC=8 THEN LEAVE
    /* Get the lists of eligible member */
    /* https://www.ibm.com/docs/en/zos/2.4.0?topic=member-parameters */
    IF COMPARE(SUBSTR(STRIP(MEMBER),1,4),"ASM@")=0 THEN
        DO
            ASSEMBLY.ASM=SUBSTR(STRIP(MEMBER),5,3)
            ASM=ASM+1
        END
    ELSE
        IF COMPARE(SUBSTR(STRIP(MEMBER),1,5),"PART$")=0 THEN
                IF COMPARE(ZLVERS,"01")=0 THEN
                    DO
                        PARTS.PRT=SUBSTR(STRIP(MEMBER),6,1)
                        PRT=PRT+1
                    END
                ELSE NOP
        ELSE
            IF COMPARE(STRIP(ZLUSER),"MAKER")=0 THEN
                DO
                    VEHICLE.VHC=STRIP(MEMBER)
                    VHC=VHC+1
                END
            ELSE NOP
END
/* Set length of stem */
ASSEMBLY.0 = ASM-1
PARTS.0 = PRT-1
VEHICLE.0 = VHC-1
/* Free data sets association */
"LMFREE DATAID("DATAID")"
/* Move back to TSO */
ADDRESS TSO
/* Check available parts */
UUID_VALID=0
VNID_VALID=0
DO I=1 TO PARTS.0
    /* Flags for file i/o */
    EOFFLAG=2
    RETURN_CODE=0
    /* Open each parts data set member */
    "FREE FI(indd)"
    "ALLOC FI(indd) SHR REU",
        "DA('"DELSTR(DELSTR(CONTEST,LENGTH(CONTEST),1),1,1)"(PART$"PARTS.I")')"
    "EXECIO 0 DISKR indd (OPEN"
    /* Get header */
    "EXECIO 1 DISKR indd"
    PARSE PULL HEADER
    /* Get location of part uuid */
    PARTSTR=POS('part',HEADER)+4+1
    PARTEND=POS('|',HEADER,PARTSTR)
    PARTLEN=PARTEND-PARTSTR
    UUIDLEN=X2D(SUBSTR(HEADER,PARTSTR,PARTLEN))
    /* Get offset for part */
    PARTOFFSET=1
    TEMPPARTSTR=POS('|',HEADER)+1
    DO WHILE (COMPARE(TEMPPARTSTR,PARTSTR)\=0)
        TEMPPARTEND=POS('|',HEADER,TEMPPARTSTR)
        TEMPPARTLEN=TEMPPARTEND-TEMPPARTSTR
        TEMPUUIDLEN=X2D(SUBSTR(HEADER,TEMPPARTSTR,TEMPPARTLEN))
        PARTOFFSET=PARTOFFSET+TEMPUUIDLEN
        TEMPPARTSTR=POS('|',HEADER,TEMPPARTEND+1)+1
    END
    /* Get location of part vendor */
    VENDSTR=POS('vendor',HEADER)+6+1
    VENDEND=POS('|',HEADER,VENDSTR)
    VENDLEN=VENDEND-VENDSTR
    VNIDLEN=X2D(SUBSTR(HEADER,VENDSTR,VENDLEN))
    /* Get offset for part vendor */
    VENDOFFSET=1
    TEMPVENDSTR=POS('|',HEADER)+1
    DO WHILE (COMPARE(TEMPVENDSTR,VENDSTR)\=0)
        TEMPVENDEND=POS('|',HEADER,TEMPVENDSTR)
        TEMPVENDLEN=TEMPVENDEND-TEMPVENDSTR
        TEMPVNIDLEN=X2D(SUBSTR(HEADER,TEMPVENDSTR,TEMPVENDLEN))
        VENDOFFSET=VENDOFFSET+TEMPVNIDLEN
        TEMPVENDSTR=POS('|',HEADER,TEMPVENDEND+1)+1
    END
    /* Check supplying vendor */
    DO WHILE(RETURN_CODE \= EOFFLAG)
        "EXECIO 1 DISKR indd"
        RETURN_CODE=RC
        IF RETURN_CODE=0 THEN
            DO
                PARSE PULL PARTSID
                VEID=SUBSTR(PARTSID,VENDOFFSET,VNIDLEN)
                PRID=SUBSTR(PARTSID,PARTOFFSET,UUIDLEN)
                IF COMPARE(SUBSTR(VEID,1,2),"38")=0 THEN
                    DO
                        UUID_VALID=UUID_VALID+1
                        UUID.UUID_VALID=PRID
                        VNID_VALID=VNID_VALID+1
                        VNID.VNID_VALID=VEID
                    END
                ELSE
                    IF COMPARE(SUBSTR(VEID,3,2),"38")=0 THEN
                        DO
                            UUID_VALID=UUID_VALID+1
                            UUID.UUID_VALID=PRID
                            VNID_VALID=VNID_VALID+1
                            VNID.VNID_VALID=VEID
                        END
                    ELSE
                        IF COMPARE(SUBSTR(VEID,5,2),"38")=0 THEN
                            DO
                                UUID_VALID=UUID_VALID+1
                                UUID.UUID_VALID=PRID
                                VNID_VALID=VNID_VALID+1
                                VNID.VNID_VALID=VEID
                            END
                        ELSE NOP
            END
        ELSE NOP
    END
    /* Close file */
    "EXECIO 0 DISKR indd (FINIS"
END
/* Set length of the supplied parts */
UUID.0=UUID_VALID
VNID.0=VNID_VALID
/* Check parts required for assembly */
ASM_VALID=0
DO I=1 TO ASSEMBLY.0
    /* Flags for file i/o */
    EOFFLAG=2
    RETURN_CODE=0
    CTR=0
    VALID=0
    /* Open each assembly data set member */
    "FREE FI(indd)"
    "ALLOC FI(indd) SHR REU",
       "DA('"DELSTR(DELSTR(CONTEST,LENGTH(CONTEST),1),1,1)"(ASM@"ASSEMBLY.I")')"
    "EXECIO 0 DISKR indd (OPEN"
    /* Loop each required parts of assembly */
    DO WHILE (RETURN_CODE \= EOFFLAG)
        "EXECIO 1 DISKR indd"
        RETURN_CODE=RC
        IF RETURN_CODE=0 THEN
            DO
                PARSE PULL ASMUUID
                CTR=CTR+1
                DO J=0 TO UUID.0
                    IF (COMPARE(UUID.J,ASMUUID)=0) THEN
                        DO
                            VALID=VALID+1
                            LEAVE
                        END
                    ELSE NOP
                END
            END
        ELSE NOP
    END
    /* Check if assembly can be fulfilled */
    IF (CTR = VALID) THEN
        DO
            ASM_VALID=ASM_VALID+1
            ASID.ASM_VALID=ASSEMBLY.I
        END
    ELSE NOP
    /* Close file */
    "EXECIO 0 DISKR indd (FINIS"
END
/* Set length of valid assembly */
ASID.0=ASM_VALID
/* Check each vehicle */
DO I=1 TO VEHICLE.0
    /* Flags for file i/o */
    EOFFLAG=2
    RETURN_CODE=0
    CTR=0
    VALID=0
    VEHICLE.I.0=0
    /* Open each vehicle data set member */
    "FREE FI(indd)"
    "ALLOC FI(indd) SHR REU",
        "DA('"DELSTR(DELSTR(CONTEST,LENGTH(CONTEST),1),1,1)"("VEHICLE.I")')"
    "EXECIO 0 DISKR indd (OPEN"
    /* Loop each required assembly of vehicle */
    DO WHILE (RETURN_CODE \= EOFFLAG)
        "EXECIO 1 DISKR indd"
        RETURN_CODE=RC
        IF RETURN_CODE=0 THEN
            DO
                PARSE PULL VHL
                VHLASM=SUBSTR(VHL,9)
                CTR=LENGTH(VHLASM)/3
                DO J=0 TO CTR-1
                    DO K=1 TO ASID.0
                        IF (COMPARE(ASID.K,SUBSTR(VHLASM,1+J*3,3))=0) THEN
                            DO
                                VALID=VALID+1
                                /* Check if there is multiple same assembly */
                                EXISTS='N'
                                DO L=1 TO VEHICLE.I.0
                                    IF (COMPARE(ASID.K,VEHICLE.I.L)=0) THEN
                                        DO
                                            EXISTS='Y'
                                            LEAVE
                                        END
                                    ELSE NOP
                                END
                                IF (COMPARE(EXISTS,'N')=0) THEN
                                    DO
                                        CNT=VEHICLE.I.0+1
                                        VEHICLE.I.CNT=ASID.K
                                        VEHICLE.I.0=CNT
                                    END
                                ELSE NOP
                                LEAVE
                            END
                        ELSE NOP
                    END
                END
            END
        ELSE NOP
    END
    /* Check if assembly can be fulfilled */
    IF (CTR = VALID) THEN
        DO
            /* Get vehicle */
            CHOSEN.1=X2C(VEHICLE.I)" "
            CNT=VEHICLE.I.0
            DO J=1 TO CNT-1
                CHOSEN.1=CHOSEN.1""VEHICLE.I.J","
            END
            CHOSEN.1=CHOSEN.1""VEHICLE.I.CNT
            DO J=1 TO CNT
                FINASM.J=VEHICLE.I.J
            END
            FINASM.0=CNT
            /* Close file */
            "EXECIO 0 DISKR indd (FINIS"
            /* Break out of function */
            LEAVE
        END
    ELSE NOP
    /* Close file */
    "EXECIO 0 DISKR indd (FINIS"
END
/* Open output file */
"FREE FI(outdd)"
"ALLOC FI(outdd) DA('ZUSER.OUTPUT(Q421DRP1)') SHR REU"
"EXECIO 1 DISKW outdd (STEM CHOSEN."
"EXECIO 0 DISKW outdd (FINIS"
/* Set cmd dest to USS syscall */
CALL SYSCALLS 'ON'
ADDRESS SYSCALL
/* Open output file */
PATH='/z/zuser/q421drop1-output.txt'
"OPEN" PATH O_RDWR+O_CREAT+O_TRUNC 660
FD=RETVAL
REC=CHOSEN.1 || ESC_N
"WRITE" FD "REC" LENGTH(REC)
"CLOSE" FD
/* Open vendor ID file */
PATH='/z/zuser/q421drop1-vendor-output.txt'
"OPEN" PATH O_RDWR+O_CREAT+O_APPEND 660
FD=RETVAL
DO I=1 TO UUID.0
    REC="000"SUBSTR(VNID.I,8,1)""SUBSTR(VNID.I,10,1)""SUBSTR(VNID.I,12,1)
    REC=REC","UUID.I || ESC_N
    "WRITE" FD "REC" LENGTH(REC)
END
"CLOSE" FD
/* Open assembly ID file */
PATH='/z/zuser/q421drop1-uuid-output.txt'
"OPEN" PATH O_RDWR+O_CREAT+O_APPEND 660
FD=RETVAL
DO I=1 TO FINASM.0
    SAY FINASM.I
    /* Flags for file i/o */
    EOFFLAG=2
    RETURN_CODE=0
    CTR=0
    VALID=0
    /* Open each assembly data set member */
    ADDRESS TSO
    "FREE FI(indd)"
    "ALLOC FI(indd) SHR REU",
        "DA('"DELSTR(DELSTR(CONTEST,LENGTH(CONTEST),1),1,1)"(ASM@"FINASM.I")')"
    "EXECIO 0 DISKR indd (OPEN"
    /* Loop each required parts of assembly */
    DO WHILE (RETURN_CODE \= EOFFLAG)
        "EXECIO 1 DISKR indd"
        RETURN_CODE=RC
        IF RETURN_CODE=0 THEN
            DO
                PARSE PULL ASMUUID
                REC=FINASM.I","ASMUUID || ESC_N
                ADDRESS SYSCALL
                "WRITE" FD "REC" LENGTH(REC)
                ADDRESS TSO
            END
        ELSE NOP
    END
    /* Close file */
    "EXECIO 0 DISKR indd (FINIS"
END
ADDRESS SYSCALL
"CLOSE" FD