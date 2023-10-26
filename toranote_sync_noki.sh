#!/bin/bash
#TORA clear
cd /var/script_sql

mysql --defaults-extra-file=.mysql/.my.toranote.cnf  << EOR

use toranote_real;
delete a from product_noki_sync as a where a.product_code is not null ;
EOR
echo $kyou."delete  product_noki_sync on OC is finished"
#
date  >> /tmp/update_noki.txt
DB_GUFU='master_plus';
DB_TORA='toranote_real';

HOST_GUFU='';
USER_GUFU='';
PASS_GUFU='';

HOST_TORA='';
USER_TORA='';
PASS_TORA='';

mysql -h $HOST_GUFU -u $USER_GUFU --password=$PASS_GUFU -D $DB_GUFU --execute='SET NAMES utf8;select a.product_code,b.delivery_flg,
case when c.num_nanko_a > 0 then c.num_nanko_a
     when c.num_trusco > 0 and b.price_supplier_id = 41 then c.num_trusco
     when c.num_supplier > 0 and b.supplier_num = 1 then c.num_supplier
     else 0 end as quantity
from dt_change_on_dfhonten as a
join dt_price_supplier as b
on a.product_code = b.product_code
join api.stock_list as c
on a.product_code = c.product_code
where a.status = 0
and a.type = 4
and b.is_live = 1'| sed ':a; s/\(^\|\t\)NULL\(\t\|$\)/\1\\N\2/; t a' > /tmp/update_noki.csv;
mysql -h $HOST_TORA -u $USER_TORA --password=$PASS_TORA -D $DB_TORA --execute='LOAD DATA LOCAL INFILE "/tmp/update_noki.csv" REPLACE INTO TABLE product_noki_sync CHARACTER SET "utf8" IGNORE 1 LINES';

date  >> /tmp/update_noki.txt

#TORA update
cd /var/script_sql

mysql --defaults-extra-file=.mysql/.my.toranote.cnf  << EOR

use toranote_real;
	update
	toranote_real.oc_product as a
	join toranote_real.product_noki_sync as b
	on a.model = b.product_code
	set a.quantity = b.quantity,a.delivery_flg= b.delivery_flg,a.elastic_status = 0,a.cloud_status = 0
	where (a.quantity != b.quantity or a.delivery_flg != b.delivery_flg);
EOR
echo $kyou."toranote_sync_noki_update on OC is finished"

#GUFU update flag
cd /var/script_sql

mysql --defaults-extra-file=.mysql/.my.vn.cnf  << EOR

use master_plus_sp;
	update
	master_plus.dt_change_on_dfhonten as a
	set a.status = 1

	where a.type = 4 and a.status = 0;

EOR
nowdate=`date`;
echo $nowdate." toranote_sync_noki_update_flag done "
echo finished ;
