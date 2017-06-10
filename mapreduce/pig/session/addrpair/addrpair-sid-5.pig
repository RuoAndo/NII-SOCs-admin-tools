-- STEP5: ORDER

F_D_2 = LOAD 'tmp-F_D' USING PigStorage(',') AS (d:chararray, s:chararray, count:long);

F_D_O = ORDER F_D_2 BY count DESC;
STORE F_D_O INTO 'tmp-sid-freq' USING PigStorage(',');