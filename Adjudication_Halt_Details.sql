select cdst as Store_NO,a.province_cdpr as province,
  (select count(*) from hw.tx_exception,hw.tx 
    where hw.tx_exception.txaa_id = hw.tx.txaa_id and hw.tx_exception.tx_exception_cdte = 'ATE' 
      and (service_date > DATE('08/05/2012') and service_date < DATE('09/01/2012'))) as pd1_AugtoSep2012,
  (select count(*) from hw.tx_exception,hw.tx 
    where hw.tx_exception.txaa_id = hw.tx.txaa_id and hw.tx_exception.tx_exception_cdte = 'ATE' 
      and (service_date > DATE('05/13/2012') and service_date < DATE('06/09/2012'))) as pd2_MaytoJun2012,
  (select count(*) from hw.tx_exception,hw.tx 
    where hw.tx_exception.txaa_id = hw.tx.txaa_id and hw.tx_exception.tx_exception_cdte = 'ATE' 
      and (service_date < DATE('08/07/2011') and service_date > DATE('09/03/2011'))) as pd3_AugtoSep2012
  from hw.store s,hw.address a where s.gead_id = a.gead_id;