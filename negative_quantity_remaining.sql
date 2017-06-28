export to 'queryResult.txt' OF DEL

select (select cdst from hw.store) as store, hw.tx.tx_number,hw.tx.tx_status_cdts,hw.tx.service_date,
hw.drug.trade_name_en,hw.tx.remaining_quantity, hw.rx.fill_status_cdrf as rx_Status,
        case when hw.rx.fill_status_cdrf in ('DISC','CAN','TFR')
        then 'INACTIVE'
        else 'ACTIVE'
        end  as Status_type
from hw.drug,hw.tx,hw.drug_upc,hw.rx
where hw.drug_upc.dgup_id = hw.tx.dgup_id
and hw.drug_upc.dgaa_id=hw.drug.dgaa_id
and hw.tx.rxaa_id = hw.rx.rxaa_id
and hw.tx.remaining_quantity < 0;