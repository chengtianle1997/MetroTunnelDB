truncate table metrodb.dataraw;
truncate table metrodb.dataconv;
truncate table metrodb.datadisp;
truncate table metrodb.imageraw;
truncate table metrodb.imagedisp;
truncate table metrodb.dataoverview;
truncate table metrodb.tandd;
DELETE FROM metrodb.detectrecord WHERE RecordID=1;
DELETE FROM metrodb.detectrecord WHERE RecordID=2;
DELETE FROM metrodb.detectrecord WHERE RecordID=3;
DELETE FROM metrodb.detectrecord WHERE RecordID=4;
-- truncate table metrodb.dataoverview;
-- truncate table metrodb.line;
-- truncate table metrodb.detectdevice;
-- truncate table metrodb.detectrecord;

