D = LOAD '$SC' USING PigStorage(',') AS (srcu:long, dstu:long, nses:long);

--dump D;

D_G = GROUP D BY (srcu, dstu);

-- dump D_G;

K = FOREACH D_G GENERATE    	   
    FLATTEN(D.srcu),
    FLATTEN(D.dstu),
    SUM(D.nses);

K_D = DISTINCT K;
dump K_D;

STORE K_D INTO 'dump-$SC' USING PigStorage(',');