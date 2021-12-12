-- Set command options for Db2 CLP to remove output to sysout
UPDATE COMMAND OPTIONS USING DisplayOutput OFF
UPDATE COMMAND OPTIONS USING StripHeaders ON
-- Connect to the Db2 instance
CONNECT TO 204.90.115.200:5040/DALLASC
-- Set encryption password
SET ENCRYPTION PASSWORD = '?PASS?'
-- Pull corresponding data
SELECT V.VID, '"'||V.VNAME||'"', E.EID, '"'||E.ENAME||'"', '"'||DECRYPT_CHAR(L.LCODE)||'"' \
    FROM ?SCHEMA?.VENDORS V, ?SCHEMA?.ENGINEERS E, ?SCHEMA?.LOCATORS L \
    WHERE V.VID = E.VID AND E.EID = L.EID \
    GROUP BY V.VID, V.VNAME, E.EID, E.ENAME, L.LCODE \
    ORDER BY V.VID, E.EID
-- Stop Db2 CLP
TERMINATE
