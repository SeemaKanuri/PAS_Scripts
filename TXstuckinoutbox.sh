

. /home/db2inst1/sqllib/db2profile

db2 connect to HWNG_DB 2>&1 >/dev/null;



cd /home/wasadmin

current_date=`date '+%Y%m%d'`
format_date=`date '+%m/%d/%Y'`

# 20131010  --- Ravi Mandalapu To cleanup most of the tx stuck in outbox scenarios

(rm outboxtxes_$current_date 2>&1) >/dev/null
(rm txesinoutbox.sql 2>&1) >/dev/null
(rm outboxtxesold_$current_date 2>&1) >/dev/null
(rm txesinoutboxold.sql 2>&1) >/dev/null

# To cleanup logs and files 7 days or older
find . -type f -name "outboxtxes*.log" -mtime +7 -exec rm -f {} \;
find . -type f -name "outboxtxesold_*" -mtime +7 -exec rm -f {} \;
find . -type f -name "outboxtxes_*" -mtime +7 -exec rm -f {} \;

# Txes stuck in outbox for older than 30 days


echo "export to '/home/wasadmin/outboxtxesold_tmp' OF DEL select tx_number from hw.tx where tx_status_cdts = 'OUT' and tx_adjudication_status_cdta = 'ACC' and tx_source_cdts not in ('BAF') and service_date < current date - 30 days;" >> txesinoutboxold.sql

(chmod 666  txesinoutboxold.sql 2>&1) >/dev/null

#(dbaccess hw txesinoutboxold.sql 2>&1) >/dev/null
db2 -tvf txesinoutboxold.sql >/dev/null 2>&1;


sed  "s/|//g" outboxtxesold_tmp  >outboxtxesold
(rm outboxtxesold_tmp 2>&1) >/dev/null




# Txes stuck in outbox for today

echo "export to '/home/wasadmin/outboxtxes_tmp' OF DEL select tx_number from hw.tx where tx_status_cdts = 'OUT' and tx_adjudication_status_cdta = 'ACC' and tx_source_cdts not in ('BAF') and service_date = current date - 1 DAY;" >> txesinoutbox.sql

(chmod 666  txesinoutbox.sql 2>&1) >/dev/null

#(dbaccess hw txesinoutbox.sql 2>&1) >/dev/null
db2 -tvf txesinoutbox.sql >/dev/null 2>&1;



sed  "s/|//g" outboxtxes_tmp  >outboxtxes_export
(rm outboxtxes_tmp 2>&1) >/dev/null




for i in `cat outboxtxesold`
do

  if [ -r /4680/adx_idt1/private_cnf/$i.CNF ]
then
      echo "delete from hw.port_process_coupler where tx_id in ( select txaa_id from hw.tx where tx_number = $i );" >> txoutupdateold.sql
      echo "delete from hw.tx_lock where txaa_id in ( select txaa_id from hw.tx where tx_number = $i );" >> txoutupdateold.sql
      echo "delete from hw.adjudication_lock where adju_id in (select adju_id from hw.adjudication where txaa_id in (select txaa_id from hw.tx where tx_number = $i));           " >> txoutupdateold.sql
      echo "delete from hw.adjudication where txaa_id in ( select txaa_id from hw.tx where tx_number = $i ); " >> txoutupdateold.sql
      echo "update hw.tx set tx_status_cdts = 'CMPT' where tx_adjudication_status_cdta = 'ACC' and tx_status_cdts = 'OUT' and tx_source_cdts not in ('BAF') and tx_number = $i;" >> txoutupdateold.sql
      (chmod 666 txoutupdateold.sql 2>&1) >/dev/null
      #(dbaccess hw txoutupdateold.sql 2>&1) >/dev/null
      db2 -tvf txoutupdateold.sql 2>&1 >/dev/null


      echo "Updated tx to complete older than 30 days Tx:$i" >> outboxtxesold.log
      (rm txoutupdateold.sql 2>&1) >/dev/null
  else
      echo "User never scanned the Tx:$i" >> outboxtxesold.log
  fi
done




for i in `cat outboxtxes`
do
  if [ -r /4680/adx_idt1/$i.HWN ]
  then
     echo "User need to scan the Tx:$i " >> outboxtxes.log
  



  elif [ -r /h/silverstream/pos/archive/$i.HWN -a -r /4680/adx_idt1/private_cnf/$i.CNF ]
  then
       cp -p /4680/adx_idt1/private_cnf/$i.CNF /4680/adx_idt1/
       echo "Moved CNF file to /4680/adx_idt1 directory because store already scanned the Tx:$i" >> outboxtxes.log





  elif [ -r /h/silverstream/pos/failed/$i.CNF ]
  then
      echo "delete from hw.port_process_coupler where tx_id in ( select txaa_id from hw.tx where tx_number = $i );" >> txoutupdate.sql
      echo "delete from hw.tx_lock where txaa_id in ( select txaa_id from hw.tx where tx_number = $i );" >> txoutupdate.sql
      echo "delete from hw.adjudication_lock where adju_id in (select adju_id from hw.adjudication where txaa_id in (select txaa_id from hw.tx where tx_number = $i));           " >> txoutupdate.sql
      echo "delete from hw.adjudication where txaa_id in ( select txaa_id from hw.tx where tx_number = $i ); " >> txoutupdate.sql
      echo "update hw.tx set tx_status_cdts = 'CMPT' where tx_adjudication_status_cdta = 'ACC' and tx_status_cdts = 'OUT' and tx_source_cdts not in ('BAF') and tx_number = $i;" >> txoutupdate.sql
      (chmod 666 txoutupdate.sql 2>&1) >/dev/null
      #(dbaccess hw txoutupdate.sql 2>&1) >/dev/null
      db2 -tvf txoutupdate.sql 2>&1 >/dev/null

      echo "HWNG bug scenarios tx updated to complete status Tx:$i " >> outboxtxes.log
     (rm txoutupdate.sql 2>&1) >/dev/null





  elif [ -r /4680/adx_idt1/private_cnf/$i.CNF ]
  then
      if [ ! -r /h/silverstream/pos/archive/$i.HWN ]
           then
          echo "delete from hw.port_process_coupler where tx_id in ( select txaa_id from hw.tx where tx_number = $i );" >> txoutold.sql
          echo "delete from hw.tx_lock where txaa_id in ( select txaa_id from hw.tx where tx_number = $i );" >> txoutold.sql
          echo "delete from hw.adjudication_lock where adju_id in (select adju_id from hw.adjudication where txaa_id in (select txaa_id from hw.tx where tx_number = $i)); " >> txoutold.sql
          echo "delete from hw.adjudication where txaa_id in ( select txaa_id from hw.tx where tx_number = $i ); " >> txoutold.sql
          echo "update hw.tx set tx_status_cdts = 'CMPT' where tx_adjudication_status_cdta = 'ACC' and tx_status_cdts = 'OUT' and tx_source_cdts not in ('BAF') and tx_number = $i;" >> txoutold.sql
          (chmod 666 txoutold.sql 2>&1) >/dev/null
          #(dbaccess hw txoutold.sql 2>&1) >/dev/null
          db2 -tvf txoutold.sql 2>&1 >/dev/null


	  echo "Store scanned the tx and no HWN file moved tx status to complete Tx:$i" >> outboxtxes.log
          (rm txoutold.sql 2>&1) >/dev/null
          else
          echo "User never scanned the Tx:$i" >> outboxtxes.log
      fi
  fi
done


mv outboxtxesold outboxtxesold_$current_date
mv outboxtxes.log outboxtxes$current_date.log
mv outboxtxesold.log outboxtxesold$current_date.log
#mv outboxtxes outboxtxes_$current_date
mv outboxtxes_export outboxtxes_$current_date
