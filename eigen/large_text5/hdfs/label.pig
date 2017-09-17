%default CLUSTER_NUMBER 10

S = LOAD '$SRCS' USING PigStorage(',') AS (sip:chararray, dip:chararray, bytes_sent:double, bytes_received: double, sidcount:double);

-- dump S

labeled = FOREACH S GENERATE
               (int)FLOOR(RANDOM() * $CLUSTER_NUMBER) AS label,
               sip,
               dip,
               bytes_sent,
               bytes_received,
               sidcount;

-- dump labeled;
STORE labeled INTO '$SRCS-labeled' USING PigStorage(',');



