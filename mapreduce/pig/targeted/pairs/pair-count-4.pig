FF = LOAD 'tmp-FF' USING PigStorage(',') AS (tid:long, aname:chararray, dip:chararray, sip:chararray);

-- dump FF;

H = GROUP FF BY (dip, sip); 

--dump H;

C = FOREACH H GENERATE
	    FF.aname,
    	    COUNT(FF.tid) as tidcount,
	    FLATTEN(FF.dip),
	    FLATTEN(FF.sip);

--dump C;

DC = DISTINCT C;
dump DC;                            
