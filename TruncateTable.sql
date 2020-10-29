truncate table metrodb.dataraw;
truncate table metrodb.dataconv;
truncate table metrodb.datadisp;
truncate table metrodb.imageraw;
truncate table metrodb.imagedisp;
DELETE FROM metrodb.detectrecord WHERE RecordID=1;
DELETE FROM metrodb.detectrecord WHERE RecordID=2;
-- truncate table metrodb.dataoverview;
-- truncate table metrodb.line;
-- truncate table metrodb.detectdevice;
-- truncate table metrodb.detectrecord;

