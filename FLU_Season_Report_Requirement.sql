export to 'queryResult_tmp.txt' OF DEL
select  (select province_cdpr from hw.address address where gead_id in(select gead_id from hw.store)) as province,
(select cdst from hw.store)as store_number,b.service_date,c.din_pin, count(c.din_pin)
from hw.tx b, hw.claim c
where b.txaa_id=c.txaa_id
--and b.service_date between (CURRENT DATE-7 DAYS) and (CURRENT DATE-1 DAYS)
and b.service_date between (CURRENT DATE-1825 DAYS) and (CURRENT DATE-1 DAYS)
and b.tx_status_cdts='CMPT'
--and c.din_pin in (  '05666602', '05666603', '05666659', '05666601', '05666644', '05666759', '05666701', '05666646')
and c.din_pin in ( '02240114', '05666644')
group by b.service_date,c.din_pin
order by b.service_date,c.din_pin;

