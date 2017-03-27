REGISTER piggybank.jar
REGISTER pigUDF.jar
DEFINE CombinedLogLoader org.apache.pig.piggybank.storage.apachelog.CombinedLogLoader();
DEFINE SearchTermExtract org.apache.pig.piggybank.evaluation.util.apachelogparser.SearchTermExtractor();
DEFINE pigDateExtract pigUDF.pigDateExtractor();

accesslog_extract = LOAD 'accesslog.txt' USING CombinedLogLoader AS (
 remoteAddr, remoteIdent, user, time, method, uri, protocol, status, bytes, referer, userAgent
)
;

accesslog_edit = FOREACH accesslog_extract GENERATE
 time, referer
;

-- dump accesslog_edit

accesslog_google = FILTER accesslog_edit BY
 referer MATCHES '.*google.*'
;

accesslog_query = FOREACH accesslog_google GENERATE
 pigDateExtract((chararray)time),
 SearchTermExtract(referer) AS query   
;

STORE accesslog_query INTO 'output';