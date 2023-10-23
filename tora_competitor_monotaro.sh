#!/bin/bash
date  >> /tmp/competitor_monotaro.txt
DB_GCP='price_check';
DB_TORA='tora_real';

HOST_GPC='';
USER_GPC='';
PASS_GPC='';

HOST_TORA='';
USER_TORA='';
PASS_TORA='';

mysql -h $HOST_GPC -u $USER_GPC --password=$PASS_GPC -D $DB_GCP --execute='SET NAMES utf8;SELECT product_code,review_count,up_date FROM competitor_monotaro WHERE  up_date > NOW() - INTERVAL 1 MONTH' | sed ':a; s/\(^\|\t\)NULL\(\t\|$\)/\1\\N\2/; t a' > /tmp/competitor_monotaro.csv;
mysql -h $HOST_TORA -u $USER_TORA --password=$PASS_TORA -D $DB_TORA --execute='LOAD DATA LOCAL INFILE "/tmp/competitor_monotaro.csv" REPLACE INTO TABLE competitor_monotaro CHARACTER SET "utf8" IGNORE 1 LINES';

date  >> /tmp/competitor_monotaro.txt
