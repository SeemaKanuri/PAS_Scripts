DECLARE GLOBAL TEMPORARY TABLE table_temp1 (Count1 BIGINT) WITH REPLACE ON COMMIT PRESERVE ROWS;

insert into session.table_temp1 (select count(*) as Count1 from hw.appuser where active_flag = 'Y'
    and ((pharmacist_license_no is null and pharmacist_license_prov is not null) or (pharmacist_license_no is not null  and pharmacist_license_prov is null))
    and role_cdur='PH_ASSIST');


export to 'queryResult.txt' OF DEL

select (select cdst from hw.store)as store,(select Count1 from session.table_temp1) as count1, count(*) as count2 from hw.appuser where active_flag = 'Y'
and default_pharmacist_flag = 'Y';