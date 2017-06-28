--begin;
export to '/h/silverstream/tmp/existng_HS_nusers.txt' OF DEL
select * from hw.appuser where scur in ('HS-NKIS','HS-RELK','HS-MRES','HS-GMAU');
delete from hw.appuser where scur in ('HS-NKIS','HS-RELK','HS-MRES','HS-GMAU');

--DECLARE GLOBAL TEMPORARY TABLE tmp_users like hw.appuser WITH REPLACE ON COMMIT PRESERVE ROWS;
create table  wasadmin.tmp_users AS ( SELECT * FROM hw.appuser) WITH NO DATA;

insert into wasadmin.tmp_users (select * from hw.appuser appuser where scur='-1');
import from users3.txt OF DEL modified by coldel0x7c insert into wasadmin.tmp_users;

insert into hw.appuser (select * from wasadmin.tmp_users);
rollback;
drop table wasadmin.tmp_users;

