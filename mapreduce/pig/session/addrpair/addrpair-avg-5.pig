-- STEP5: ORDER

F_D_2 = LOAD 'tmp-F_D' USING PigStorage(',') AS (d:chararray, s:chararray, avgbytes:long);

F_D_O = ORDER F_D_2 BY avgbytes DESC;
STORE F_D_O INTO 'tmp-avg-bytes' USING PigStorage(',');