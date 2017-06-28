DECLARE GLOBAL TEMPORARY TABLE tmp1 (patient_id BIGINT) WITH REPLACE ON COMMIT PRESERVE ROWS;
insert into session.tmp1 (select group_membership.patient_id from hw.group_membership group_membership
  where group_membership.group_id in (select patient_group.id from hw.patient_group patient_group where active_flag='Y'));

create index session.ndx_tmp1_patient_id on session.tmp1 (patient_id);

DECLARE GLOBAL TEMPORARY TABLE tmp2 (paaa_id BIGINT) WITH REPLACE ON COMMIT PRESERVE ROWS;
insert into session.tmp2 (select pt.paaa_id as paaa_id from hw.patient pt 
  where pt.active_flag='Y' and pt.birthday <= DATE('01/01/1943') 
    and pt.paaa_id not in (select tmp1.patient_id from session.tmp1 tmp1));
create index session.bdx_tmp2_paaa_id on session.tmp2 (paaa_id);


DECLARE GLOBAL TEMPORARY TABLE tmp3 (no_of_chronic_rx INTEGER, paaa_id BIGINT) WITH REPLACE ON COMMIT PRESERVE ROWS;
insert into session.tmp3 (select count(rx.rxaa_id) no_of_chronic_rx, tmp2.paaa_id paaa_id
  from hw.rx rx
    join session.tmp2 as tmp2 on tmp2.paaa_id=rx.paaa_id
    join hw.tx as tx on rx.rxaa_id=tx.rxaa_id
    join hw.drug_upc as drug_upc on tx.dgup_id=drug_upc.dgup_id
    join hw.drug as drug on drug_upc.dgaa_id=drug.dgaa_id
  where tx.service_date > DATE('10/01/2012')
    and drug.din in (select din from hw.meds_check_din_list)
    and tx.tx_number !=0 and tx.tx_status_cdts !='CAN'
  group by tmp2.paaa_id
  having count(rx.rxaa_id) >=5);
  
create index session.ndx_tmp3_paaa_id on session.tmp3 (paaa_id);


export to queryResult.csv OF DEL
select (select store.cdst from hw.store store  ) Store_No, pt.last_name, pt.middle_name, pt.first_name, pt.birthday, 
        tmp3.no_of_chronic_rx, pt.gender_code,address.line_one, address.line_two, address.city,
        address.province_cdpr,address.country,address.postal_code, address.primary_phone_no
  from hw.patient pt join session.tmp3 tmp3 on pt.paaa_id=tmp3.paaa_id
    join hw.patient_address as patient_address on pt.paaa_id=patient_address.paaa_id
    join hw.address as address on patient_address.gead_id=address.gead_id;
