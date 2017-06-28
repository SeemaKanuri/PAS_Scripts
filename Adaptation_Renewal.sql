export to 'queryResult.txt' OF DEL
select (select cdst from hw.store ) store_number,tx.tx_number, claim.din_pin,tx.tx_status_cdts,tx.service_date
  from hw.tx tx , hw.claim claim
  where tx.txaa_id = claim.txaa_id
   -- and (tx.service_date < DATE('05/19/2013') and tx.service_date > DATE('06/15/2013'))
   and (tx.service_date < DATE('08/03/2012') and tx.service_date > DATE('06/25/2012'))
    and claim.din_pin in ('66124873', '66124872', '66124798', '66124787', '66124760', '66124831', '66124768', '66124769', 
                          '66124794', '66124764', '66124789', '66124790', '66127902', '66124767', '66124834', '66124832', 
                          '66124782', '66124784', '66124785', '66124773', '66124793', '66124758', '66124792', '66124796', '66124797');
 
export to 'queryResult.txt' OF DEL
select (select cdst from hw.store ), tx.tx_number, drug.din, tx.service_date,prescriber.last_name, prescriber.first_name ,
        tx.tx_status_cdts,intervention.cdiv,tx.tx_status_cdts,intervention.description_en
  from hw.tx tx ,hw.rx rx,hw.prescriber prescriber,hw.drug_upc drug_upc,hw.drug drug,hw.claim claim,hw.claim_intervention claim_intervention,hw.intervention intervention
  where tx.rxaa_id = rx.rxaa_id and rx.praa_id = prescriber.praa_id
    and tx.dgup_id = drug_upc.dgup_id and drug_upc.dgaa_id = drug.dgaa_id
    and tx.txaa_id = claim.txaa_id and claim.tpcl_id = claim_intervention.tpcl_id
    and claim_intervention.cdiv_id = intervention.cdiv_id 
    and (tx.service_date > DATE('05/19/2013') and tx.service_date < DATE('06/15/2013'))
    and intervention.cdiv_id in ( '4540000','4520000','4550000','4530000','4510000','4590000','4560000');
