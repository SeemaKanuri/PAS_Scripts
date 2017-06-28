echo "Please enter store number (4 digits: 0123): "
read store_num
echo "Please enter Patient Last Name (CAPITAL): "
read  ptlastname
echo "Please enter Patient paaa_id: "
read  paaa_id

grep_string="$store_num|$paaa_id|$ptlastname"

cp /h/newstuff/purge_5.4.2/backup/purgerecords.txt.gz tmp_records.txt.gz
gunzip tmp_records.txt.gz

#echo "grep $grep_string tmp_records.txt > grep_result.txt"

grep "^$grep_string" tmp_records.txt >grep_result.txt

. /home/db2inst1/sqllib/db2profile;
#query_store="unload to './report_store.txt' delimiter ','"
query_store="export to './report_store.txt' OF DEL"
query_store="$query_store select store.cdst,address.city,address.province_cdpr,address.country,address.postal_code, "
query_store="$query_store address.primary_phone_no,address.fax_no,address.line_one,address.line_two current "
query_store="$query_store from hw.store store join hw.address address on store.gead_id=address.gead_id;"
echo "connect to HWNG_DB;" > getreport.sql
echo $query_store >> getreport.sql
echo ""     >>       getreport.sql


#query_patient="unload to './report_Patient.txt' delimiter ','"
query_patient="export to './report_Patient.txt' OF DEL"
query_patient="$query_patient select pt.paaa_id,pt.last_name,pt.first_name,pt.middle_name,pt.birthday,pt.gender_code, "
query_patient="$query_patient address.city,address.province_cdpr,address.country,address.postal_code, "
query_patient="$query_patient address.primary_phone_no,address.line_one,address.line_two "
query_patient="$query_patient  from hw.patient pt join hw.patient_address patient_address on pt.paaa_id=patient_address.paaa_id "
query_patient="$query_patient  join hw.address address on patient_address.gead_id=address.gead_id "
query_patient="$query_patient where pt.last_name='${ptlastname}'"
query_patient="$query_patient  and pt.paaa_id=${paaa_id};"

echo $query_patient >> getreport.sql
echo ""     >>       getreport.sql

##########  create tmp_result table  #################

#query_result="$query_result DECLARE GLOBAL TEMPORARY TABLE tmp_result (store BIGINT,paaa_id BIGINT,last_name VARCHAR(20),"
query_create="$query_create create table wasadmin.tmp_result ( store VARCHAR(5) , paaa_id BIGINT, last_name VARCHAR(20) ,"
query_create="$query_create middle_name VARCHAR(20),first_name VARCHAR(20),birthday DATE,rxaa_id BIGINT,rx_number INTEGER,"
query_create="$query_create fill_status_cdrf VARCHAR(5),number_of_refills INTEGER,quantity_dispensed DECIMAL,"
query_create="$query_create authorized_tx_qty DECIMAL,total_quantity_auth DECIMAL,authorized_days_supply INTEGER,"
query_create="$query_create expiry_date DATE,written_date DATE,create_datetime TIMESTAMP,last_update_datetime TIMESTAMP,"
query_create="$query_create praa_id BIGINT,txaa_id BIGINT,tx_number INTEGER,tx_status_cdts VARCHAR(5),tx_quantity DECIMAL,"
query_create="$query_create service_date DATE,days_supply INTEGER,billing_quantity DECIMAL,remaining_quantity DECIMAL,"
query_create="$query_create refills_remaining INTEGER,pp_total DECIMAL,tp_paid_total DECIMAL,pg_adjusted_total DECIMAL,"
query_create="$query_create sa_total DECIMAL,dgup_id BIGINT,cpaa_id BIGINT,tpsf_id BIGINT, "
query_create="$query_create sig_description_store_language VARCHAR(2048) ) ;				"
#query_create="$query_create WITH REPLACE ON COMMIT PRESERVE ROWS;"
query_create="$query_create 											"

echo $query_create >> getreport.sql
echo ""     >>       getreport.sql

#query_result="$query_result insert into session.tmp_result (select (select cdst from store) store,"
query_insert="$query_insert insert into wasadmin.tmp_result(select (select cdst from hw.store) store,"
query_insert="$query_insert pt.paaa_id,pt.last_name, pt.middle_name, pt.first_name, pt.birthday,"
query_insert="$query_insert rx.rxaa_id,rx.rx_number,rx.fill_status_cdrf,rx.number_of_refills,rx.quantity_dispensed,"
query_insert="$query_insert rx.authorized_tx_qty,rx.total_quantity_auth,rx.authorized_days_supply,rx.expiry_date,"
query_insert="$query_insert rx.written_date,rx.create_datetime,rx.last_update_datetime,rx.praa_id,"
query_insert="$query_insert tx.txaa_id,tx.tx_number,tx.tx_status_cdts,tx.tx_quantity,tx.service_date,tx.days_supply,"
query_insert="$query_insert tx.billing_quantity,tx.remaining_quantity,tx.refills_remaining,tx.pp_total,tx.tp_paid_total,"
query_insert="$query_insert tx.pg_adjusted_total,tx.sa_total,tx.dgup_id,tx.cpaa_id,tx.tpsf_id,tx_sig.sig_description_store_language"
query_insert="$query_insert from hw.patient pt,hw.rx rx,hw.tx tx,hw.tx_sig tx_sig"
query_insert="$query_insert where rx.rxaa_id=-1 and rx.paaa_id =pt.paaa_id and tx.rxaa_id=rx.rxaa_id and tx.txsg_id=tx_sig.txsg_id);"
#query_insert="$query_insert where rx.rxaa_id=282540286 and rx.paaa_id =pt.paaa_id and tx.rxaa_id=rx.rxaa_id and tx.txsg_id=tx_sig.txsg_id);"

echo $query_insert >> getreport.sql
echo ""     >>       getreport.sql 

###########  Load data from grep_result.txt to tmp_result table #####################

#echo "load from './grep_result.txt' insert into tmp_result;" >> getreport.sql
#echo "import from './grep_result.txt'OF DEL insert into session.tmp_result;" >> getreport.sql
echo "import from './grep_result.txt' OF DEL insert into wasadmin.tmp_result;" >> getreport.sql
echo ""     >>       getreport.sql

###########  Unload data from tmp_result table to report_result.txt #####################

#query_result="unload to './report_result.txt' delimiter ','"
query_result="$query_result export to './report_result.txt' OF DEL"
query_result="$query_result select tmp_result.tx_number, tmp_result.rx_number, tmp_result.service_date, tmp_result.tx_quantity, tmp_result.dgup_id,"
query_result="$query_result drug.din,drug.trade_name_en,drug.chem_label_name_en,"
query_result="$query_result tmp_result.pg_adjusted_total,tmp_result.pp_total,"
query_result="$query_result nvl(tmp_result.tp_paid_total,tmp_result.pg_adjusted_total-tmp_result.pp_total),"
query_result="$query_result tmp_result.sa_total,"
query_result="$query_result prescriber.last_name,prescriber.first_name,"
query_result="$query_result trim(replace(compound.name_en,',','')) compound_name_en,trim(service_type.st_description_en)"
query_result="$query_result from wasadmin.tmp_result tmp_result left join hw.drug_upc drug_upc on tmp_result.dgup_id=drug_upc.dgup_id"
query_result="$query_result left join hw.drug drug on drug_upc.dgaa_id=drug.dgaa_id"
query_result="$query_result left join hw.compound compound on tmp_result.cpaa_id=compound.cpaa_id"
query_result="$query_result left join hw.tp_special_service_fee tp_special_service_fee on tmp_result.tpsf_id=tp_special_service_fee.tpsf_id"
query_result="$query_result left join hw.service_type service_type on tp_special_service_fee.cdstyp=service_type.cdstyp,"
query_result="$query_result hw.prescriber prescriber where tmp_result.praa_id=prescriber.praa_id;"

#query_result="$query_result drop table wasadmin.tmp_result;"

echo $query_result >> getreport.sql
echo ""     >>       getreport.sql

query_drop="$query_drop drop table wasadmin.tmp_result;"

echo $query_drop >> getreport.sql
echo ""     >>       getreport.sql


#dbaccess hw getreport.sql 2>&1

db2 -tvf getreport.sql >/dev/null 2>&1; 

#############  Generate Report     ##############

# Escape & l 1 O = Landscape
# Escape & k 2 S = Compressed
# echo "${ESC}&l1O${ESC}&k2S" > ${UPTMP}/tempreport.$$


awk -F"," '
 {
       gsub(/\x027/,"","")
       print "&k2S"
       print "                         Patient Medical History Report" 
       print ""
       print "Printed: " $10  "                                 Page: 1"
       print "====================================================================================="
       print "SHOPPERS DRUG MART " $1  
       print $8 " " $9                                        
       print $2 "," $3 "," $5 " " $4                                        
       print "Phone:" $6 "         Fax:" $7             
       print "====================================================================================="
       print "Patient name and address:" 

   
}' report_store.txt >report.txt

awk -F"," '
{
  gsub(/\x027/,"",$0)
  print $3 "," $2 " " $4 > "ptname.txt"
  print $3 "," $2 " " $4  
  print $12 " " $13 
  print $7 "," $8 "," $10 " " $9
  print "Phone:" $11 "          DOB: " $5

}' report_Patient.txt >>report.txt


ptname="`cat ptname.txt`"

lc=20

awk -F"," -vlc="${lc}" -vptname="${ptname}" '
BEGIN {
  tottot=0.0
  totpatpays=0.0
  totinspays=0.0
  totwaive=0.0
  pc=1

  print "====================================================================================="
  print "Service    Qty      Trade Name                    Total   Patient  Insurance   Waived"
  print "Rx         DIN                                    $         Pays$      Pays$   Pays$"
  print "Tx                  Prescriber                                                     "
  print "====================================================================================="

}
{
  gsub(/\x027/,"",$0)
  $9=0+$9
  $10=0+$10
  $11=0+$11
  $12=0+$12


  if ($5!="")
  {
     printf "%10s %-8.8s %-25.25s %9.2f %9.2f %9.2f %9.2f\n", $3, $4, $7, $9, $10, $11, $12  

     printf "%10d %-8.8s %-25.25s  \n", $2, $6, $8 
  
  } else if ($15=="")
  {
    printf "%10s %-8.8s %-25.25s %9.2f %9.2f %9.2f\n", $3, $4, $16, $9, $10, $11, $12  
    printf "%10d %-8.8s   \n", $2, $6 
  } else
  {
    printf "%10s %-8.8s %-25.25s %9.2f %9.2f %9.2f\n", $3, $4, $15, $9, $10, $11, $12 
    printf "%10d %-8.8s    \n", $2, $6 
  }


  printf "%10d          %-25.25s\n", $1, $13","$14 
  print   "-------------------------------------------------------------------------------------"
  tottot+=$9
  totpatpays+=$10
  totinspays+=$11
  totwaive+=$12

  lc+=4
  if (lc>=50)
  {
    pc++
    print "\x00c" 
    printf "Medical History Report for: %-40s  Page:%d\n", ptname, pc
    print "====================================================================================="
    print "Service    Qty      Trade Name                    Total   Patient  Insurance   Waived"
    print "Rx         DIN                                    $         Pays$      Pays$   Pays$" 
    print "Tx                  Prescriber                                                      " 
    print "=====================================================================================" 
    lc=5
  }

}
END {
   print "=====================================================================================" 
   printf "%10s %-8s %-25s %9.2f %9.2f  %9.2f %8.2f\n", "", "", "", tottot, totpatpays, totinspays,totwaive  
}
 ' report_result.txt >>report.txt


echo "=====================================================================================" >>report.txt
echo " " >>report.txt

echo "THIS PATIENT MEDICAL HISTORY REPORT ONLY CONTAINS AVAILABLE RECORDS FROM PURGE ARCHIVES." >>report.txt
#echo "THIS REPORT COULD POSSIBLY MISS COMPOUND OR SPECIAL SERVICE FEE PRESCRIPTIONS INFORMATION." >>report.txt
echo "THIS REPORT COULD POSSIBLY CONTAIN CONVERTED PRESCRIPTIONS FROM OTHER IT SYSTEM." >> report.txt
echo "PAYMENT INFORMATION OF CONVERTED PRESCRIPTIONS MAY NOT BE ACCURATE." >> report.txt
echo "IT DEPARTMENT CAN NOT ENSURE THE ACCURACY OF ALL INFORMATION ON THE REPORT, " >>report.txt
echo "PLEASE VERIFY ALL INFORMATION WITH PRESCRIPTION ORIGINAL PHYSICAL COPIES." >> report.txt
echo "PLEASE MAKE PROFESSIONAL JUDGEMENT ON THE PROPER USAGE OF THIS REPORT." >>report.txt

echo " " >>report.txt
echo " " >>report.txt
echo "                    Pharmacist Signature:_________________________" >>report.txt

filename=report_${ptlastname}_${paaa_id}.`date '+%Y%m%d'`
mv report.txt  $filename
rm tmp_records.txt
rm report_result.txt
rm report_Patient.txt
rm report_store.txt
rm getreport.sql
rm ptname.txt
rm grep_result.txt

echo "Please use the following command to print report on rxlaser1: "
echo "lp -d rxlaser1 -o raw report.txt"
echo
echo

