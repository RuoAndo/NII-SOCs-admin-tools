sessiona = LOAD '$DIRAVG' USING PigStorage(',') AS (dip:chararray, sip:chararray, avg:long);

sessions = LOAD '$DIRSID' USING PigStorage(',') AS (dip:chararray, sip:chararray, sid:long);

A = FOREACH sessiona GENERATE                                    
	   	   dip as dip,
		   sip as sip,
		   avg as avg;

-- dump A; 

S = FOREACH sessions GENERATE                                    
	   	   dip as dip,
		   sip as sip,
		   sid as sid;

-- dump S;

J = join A by (dip, sip) LEFT OUTER, S by (dip, sip); 
-- dump J;

K = FOREACH J GENERATE
    	    $0,
	    $1,
	    $2,
	    $5;

-- dump K;
STORE K INTO '$OUTPUTDIR' USING PigStorage(',');
