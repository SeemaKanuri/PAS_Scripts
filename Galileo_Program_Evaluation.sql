--DECLARE GLOBAL TEMPORARY TABLE tmp_grpid (group_id VARCHAR(20)) WITH REPLACE ON COMMIT PRESERVE ROWS;
create table wasadmin.tmp_grpid (group_id VARCHAR(20));

--insert into session.tmp_grpid (select group_id from hw.tp_coverage tp_coverage where group_id='-1');
--insert into wasadmin.tmp_grpid (select group_id from hw.tp_coverage tp_coverage where group_id='-1');
insert into wasadmin.tmp_grpid (select group_id from hw.tp_coverage tp_coverage where group_id= '156570' );

--import from '/h/silverstream/tmp/GRP_ID_PAM_SODEN.txt' of del insert into session.tmp_grpid;
import from '/h/silverstream/tmp/GRP_ID_PAM_SODEN.txt' of del insert into wasadmin.tmp_grpid;



--DECLARE GLOBAL TEMPORARY TABLE tmp_din (din_pin VARCHAR(20)) WITH REPLACE ON COMMIT PRESERVE ROWS;
create table wasadmin.tmp_din (din_pin VARCHAR(20));

--insert into session.tmp_din (select din_pin from hw.claim_transmission claim_transmission where din_pin='-1');
--insert into wasadmin.tmp_din (select din_pin from hw.claim_transmission claim_transmission where din_pin='-1');
insert into wasadmin.tmp_din (select din_pin from hw.claim_transmission claim_transmission where din_pin='66999990' );

--import from '/h/silverstream/tmp/DIN_PIN_PAM_SODEN.txt' of del insert into session.tmp_din;
import from '/h/silverstream/tmp/DIN_PIN_PAM_SODEN.txt' of del insert into  wasadmin.tmp_din;



DECLARE GLOBAL TEMPORARY TABLE tmp2 (tx_number INTEGER,txaa_id BIGINT, paaa_id BIGINT,din_pin VARCHAR(20),group_id VARCHAR(20)) WITH REPLACE ON COMMIT PRESERVE ROWS;

insert into session.tmp2 (select tx.tx_number, tx.txaa_id, patient_coverage.paaa_id,claim_transmission.din_pin,tp_coverage.group_id
  from hw.tx tx, hw.claim claim, hw.claim_transmission claim_transmission, hw.patient_coverage patient_coverage, hw.tp_coverage tp_coverage, hw.tp tp, hw.tp_main tp_main
    where tx.txaa_id=claim.txaa_id
      and claim.pacv_id=patient_coverage.pacv_id
      and tp_coverage.tpco_id=patient_coverage.tpco_id
      and tp.tpaa_id=tp_coverage.tpaa_id
      and tp_main.tpxx_id=tp.tpxx_id
      and claim.tpcl_id = claim_transmission.tpcl_id
      and claim_transmission.claim_status_cdcs='ACP' and tp_main.code='BCE' and tp_coverage.carrier_id='11'
      and tx.service_date between '10/01/2012' and '03/31/2013'
      and claim_transmission.din_pin in (select din_pin from wasadmin.tmp_din)
      and tp_coverage.group_id in (select group_id from wasadmin.tmp_grpid));

export to 'New_Pam_Result.txt' OF DEL select distinct (select cdst from hw.store) as store_no,patient.paaa_id,patient.first_name, patient.last_name, patient.gender_code, patient.birthday,
address.primary_phone_no, address.alternate_phone_no, address.line_one , address.line_two as street, address.city, address.province_cdpr, address.postal_code,
address.country,tmp2.din_pin,tmp2.group_id
from hw.patient patient, hw.address address, session.tmp2 tmp2, hw.patient_address patient_address
where tmp2.paaa_id=patient.paaa_id and patient_address.paaa_id=patient.paaa_id and patient_address.gead_id=address.gead_id;

drop table wasadmin.tmp_din;
drop table wasadmin.tmp_grpid;
