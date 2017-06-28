export to 'queryResult.txt' OF DEL
SELECT hw.tx.tx_number as TX_number,
(SELECT hw.store_preference.value from hw.store_preference where cdsp='STORE_EHR_JURISDICTION') as STORE_PROV,
(SELECT cdst from hw.store where active_flag='Y')as STORE_number,
hw.tp_special_service_fee.pseudo_din as DIN_PIN,hw.rx.sig_code as SIG,hw.tx.tx_quantity as TX_QTY,
hw.rx.written_date as WRITTEN_DATE,hw.tx.pg_adjusted_total as TOTAL_COST,hw.tx.pg_markup1 as MARKUP1,
hw.tx.pg_markup2 as MARKUP2,hw.tx.pg_fee as TOTAL_FEE,hw.tx.pg_adjusted_ssf as TOTAL_SSFEE,
hw.tx.pp_total as TOTAL_PAID,hw.prescriber.last_name as PRESCRIBER_LAST_NAME,
hw.prescriber.first_name as PRESCRIBER_FIRST_NAME,hw.prescriber.license_no as PRESCRIBER_LICENSE_number
FROM hw.tx
INNER JOIN hw.tp_special_service_fee ON hw.tx.tpsf_id=hw.tp_special_service_fee.tpsf_id
INNER JOIN hw.tx_sig ON hw.tx.txsg_id=hw.tx_sig.txsg_id
INNER JOIN hw.rx ON hw.tx.rxaa_id=hw.rx.rxaa_id
INNER JOIN hw.prescriber ON hw.rx.praa_id=hw.prescriber.praa_id
WHERE hw.tp_special_service_fee.tpaa_id='9999' and hw.tp_special_service_fee.active_flag='Y'
--and hw.tx.service_date > DATE('11/03/2013') and hw.tx.service_date < DATE('11/30/2013') ;
and hw.tx.service_date > DATE('05/03/2013') and hw.tx.service_date < DATE('06/17/2013') ;
