export to 'queryResult.txt' OF DEL
select cdst,(select province_cdpr 
  from store, address 
    where store.gead_id = address.gead_id ) as province_cdpr,
          (select count(*) from rx_transfer 
            where rx_transfer.store_type_id = 'CHAIN'
                and rx_transfer.transfer_date between CURRENT DATE -8 DAYS and CURRENT DATE -2 DAYS) Store_type_chain,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id 
            and rx_transfer.store_type_id = 'CHAIN' and (rx.total_quantity_auth - rx.quantity_dispensed) > 0
            and rx.quantity_dispensed > 0 and rx.previous_fill_status_cdrf not in ('DISC') 
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE -2 DAYS) Store_type_chain_fillable,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id 
            and rx_transfer.store_type_id = 'CHAIN' and (rx.total_quantity_auth - rx.quantity_dispensed) = 0
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_chain_depleted,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_type_id = 'CHAIN' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) > 0 and rx.quantity_dispensed = '0.00'
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_chain_logged,
          (select count(*) from rx_transfer where rx_transfer.store_type_id = 'IND' 
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_ind,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_type_id = 'IND' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) > 0 and rx.quantity_dispensed > 0 and rx.previous_fill_status_cdrf not in ('DISC')
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_ind_fillable,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_type_id = 'IND' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) = 0
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_ind_depleted,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_type_id = 'IND'
            and (rx.total_quantity_auth - rx.quantity_dispensed) > 0 and rx.quantity_dispensed = '0.00'
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_ind_logged,
          (select count(*) from rx_transfer where rx_transfer.store_type_id = 'SDM' 
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_SDM,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_type_id = 'SDM' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) > 0 and rx.quantity_dispensed > 0 and rx.previous_fill_status_cdrf not in ('DISC')
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_sdm_fillable,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_type_id = 'SDM' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) = 0 
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_sdm_depleted,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_type_id = 'SDM' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) > 0 and rx.quantity_dispensed = '0.00' 
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_sdm_logged,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and (rx.total_quantity_auth - rx.quantity_dispensed) > 0
            and rx.quantity_dispensed > 0 and rx.previous_fill_status_cdrf not in ('DISC')
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) TOTAL_FILLABLE,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and (rx.total_quantity_auth - rx.quantity_dispensed) = 0 
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) TOTAL_DEPLETED,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and (rx.total_quantity_auth - rx.quantity_dispensed) > 0  
            and rx.quantity_dispensed = '0.00' 
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) TOTAL_LOGGED,
          (select count(*) from rx_transfer where rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Total,
          (select count(*) from rx_transfer where rx_transfer.store_type_id = 'FOOD' 
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_food,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_type_id = 'FOOD' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) > 0 and rx.quantity_dispensed > 0 and rx.previous_fill_status_cdrf not in ('DISC')
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_food_fillable,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_type_id = 'FOOD' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) = 0 
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_food_depleted,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_type_id = 'FOOD' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) > 0 and rx.quantity_dispensed = '0.00'
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_food_logged,
          (select count(*) from rx_transfer where rx_transfer.store_name like '%TARG%' 
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_targ,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_name like '%TARG%' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) > 0 and rx.quantity_dispensed > 0 and rx.previous_fill_status_cdrf not in ('DISC')
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_targ_fillable,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_name like '%TARG%' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) = 0
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_targ_depleted,
          (select count(*) from rx_transfer,rx where rx.rxaa_id = rx_transfer.rxaa_id and rx_transfer.store_name like '%TARG%' 
            and (rx.total_quantity_auth - rx.quantity_dispensed) > 0 and rx.quantity_dispensed = '0.00'
            and rx_transfer.transfer_date between CURRENT DATE-8 DAYS and CURRENT DATE-2 DAYS) Store_type_targ_logged
    from store;


