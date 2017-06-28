select rx.rx_number, tx.tx_number ,tx.service_date,patient.paaa_id as patient_identifier, patient_group.name as group_name, patient.ar_account_number,
        tp.third_party_name_en, tp_coverage.carrier_id,prescriber.praa_id as prescriber_identifier,
        case  when tx.cpaa_id is null
              then nvl(drug.trade_name_en,'') || ' ' || nvl(drug_upc.strength,'') || '' || nvl(drug_upc.strength_unit_en,'')
      else compound.name_en end as Drug_Trade_Name,
        case  when tx.cpaa_id is null
              then drug.chem_label_name_en
      else 'compound'
      end as chemical_name ,nvl(drug_upc.pack_description_en, '') as pack_description ,mms_vendor.manufacturer_code,
            drug_upc.form_cdfo,drug.din, drug.cdahfs,claim.quantity,tx.days_supply,
            (nvl(claim.cost,0) + nvl(claim.markup,0) + nvl (claim.markup2,0)) as Cost,
            claim.compound_charge, claim.fee,claim.submitted_total as total,
            nvl(claim.plan_pays,0) Tp_paid, nvl(tx.pp_total,0) as patient_paid,
            nvl(claim.previously_paid,0) as previously_paid,
            tp_main.tp_type,
            (select tp_main.tp_type from hw.tp_main tp_main,hw.tp tp,hw.tp_coverage tc,hw.patient_coverage pc, hw.claim c
                where pc.pacv_id = c.pacv_id
                  and tc.tpco_id = pc.tpco_id
                  and tp.tpaa_id = tc.tpaa_id
                  and tp.tpxx_id = tp_main.tpxx_id
                  and claim.tpcl_id <> c.tpcl_id
                  and c.tpcl_id=(select min(tpcl_id) from hw.claim c2 where c2.status_cdcs = 'ACP' and tx.txaa_id=c2.txaa_id)) as previous_tp_type
        from hw.tx tx
          left outer join hw.tx_group_info as tx_group_info on (tx_group_info.txaa_id = tx.txaa_id )
          left outer join hw.group_membership as group_membership on (group_membership.id = tx_group_info.group_membership_id)
          left outer join hw.patient_group as patient_group on (patient_group.id = group_membership.group_id)
          left outer join hw.compound as compound on (compound.cpaa_id = tx.cpaa_id)
          left outer join hw.drug_upc as drug_upc on (drug_upc.dgup_id = tx.dgup_id)
          left outer join hw.drug as drug on (drug.dgaa_id = drug_upc.dgaa_id)
          left outer join hw.mms_vendor as mms_vendor on (mms_vendor.cdmv_id = drug_upc.manufacturer_cdmv_id),
          hw.rx rx,hw.patient patient,hw.prescriber prescriber,hw.claim claim,hw.patient_coverage patient_coverage,hw.tp_coverage tp_coverage,hw.tp tp,hw.tp_main tp_main
        where rx.rxaa_id = tx.rxaa_id and patient.paaa_id = rx.paaa_id
          and prescriber.praa_id = rx.praa_id and claim.txaa_id = tx.txaa_id and patient_coverage.pacv_id = claim.pacv_id
          and tp_coverage.tpco_id = patient_coverage.tpco_id
          and tp.tpaa_id = tp_coverage.tpaa_id and tp.tpxx_id = tp_main.tpxx_id
          and patient_coverage.active_flag = 'Y' and tp_coverage.active_flag = 'Y' and claim.active_flag = 'Y'
          --and tx.service_date between '2010-11-27' and '2010-12-31'and tp.third_party_name_en like 'RENAL PROGRA%';	
          and tx.service_date between '2011-05-10' and '2011-05-11' and tp.third_party_name_en like 'ALBERTA%';
