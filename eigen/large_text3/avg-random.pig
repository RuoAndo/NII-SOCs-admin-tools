%default CLUSTER_NUMBER 10

S = LOAD '$SRCS-labeled' USING PigStorage(',') AS (sip:chararray, dip:chararray, bytes_sent:double, bytes_received:double, sidcount:double);

S_L = FOREACH S GENERATE
      (int)FLOOR(RANDOM() * $CLUSTER_NUMBER) AS label,
      bytes_sent,
      bytes_received,
      sidcount;

S_L_G = GROUP S_L by label;

--(4,2.088836879792197E9,2253.1747342147237,13026.606027642265)
--BUG：順番がずれるので注意

S_L_G_AVG = FOREACH S_L_G GENERATE
      group as label,
      AVG(S_L.bytes_received),
      AVG(S_L.sidcount), 
      AVG(S_L.bytes_sent);

-- S_L_G_AVG_F = FILTER S_L_G_AVG BY label == (int)FLOOR(RANDOM() * $CLUSTER_NUMBER);
S_L_G_AVG_F = FILTER S_L_G_AVG BY label == 3;

dump S_L_G_AVG_F;
STORE S_L_G_AVG_F INTO '$SRCS-avg' USING PigStorage(',');