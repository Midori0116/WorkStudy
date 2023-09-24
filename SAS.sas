
/*  名寄せ */

/*   論文：  https://www.sas.com/content/dam/SAS/ja_jp/doc/event/sas-user-groups/usergroups11-b-10.pdf   */

/*  例6 */
options mprint;
libname mtest "c:\temp\mtest";
/* 照合処理 SQL 生成マクロ定義 */
%macro matching(lv, cond);
/*mtest にある企業リスト A と企業リスト B の照合用データセット（acorplist, bcorplist）を接合する */
/* 管理用 ID（aid, bid） */
 create table mtest.linkab&lv. as select a.aid, b.bid from mtest.acorplist as a, mtest.bcorplist as b where &cond.;
 select count(*) into :lnkcnt from mtest.linkab&lv.;
 %if &lnkcnt = 0 %then %do;
 %put NOTE: Skip delete process. Lv.= &lv ;
 %end;
 %else %do;
 delete from mtest.acorplist where aid in (select unique aid from mtest.linkab&lv.);
 delete from mtest.bcorplist where bid in (select unique bid from mtest.linkab&lv.);
 %end;
%mend;

/* 照合実行 */
proc sql stimer noprint;
 %matching(01, %str(a.name =b.name and a.addr =b.addr and a.tel=b.tel))
 %matching(02, %str(a.name =b.name and a.addr =b.addr ))
 %matching(03, %str(a.name_key=b.name_key and a.addr_key=b.addr_key and a.tel=b.tel))
 %matching(04, %str(a.name_key=b.name_key and a.addr_key=b.addr_key ))
 /* (中略) */
 %matching(15, %str(a.name =b.name and (a.addr eqt b.addr or b.addr eqt a.addr)))
 /* (中略) */
 %matching(30, %str(a.name_key=b.name_key))
quit;
/* 照合結果を統合する instert 文実行用マクロ定義 */
%macro makeInsertSql(lvstart, lvend);
 %do lv=&lvstart %to &lvend;
 %let lvz=%sysfunc(putn(&lv, z2.));
 insert into mtest.linkab_log select unique bid, aid, &lv. as lv from mtest.linkab&lvz.;
 %end;
%mend;
/* 照合結果の統合 */
proc sql stimer;
 create table mtest.linkab_log as select bid, aid, 1 as lv from mtest.linkab01;
 %makeInsertSql(2, 30)
 create table mtest.linkab_log_cnt as
 select l.aid, l.bid, lv, acount, bcount from mtest.linkab_log as l,
 (select aid, count(*) as acount from mtest.linkab_log group by aid) as a,
 (select bid, count(*) as bcount from mtest.linkab_log group by bid) as b
 where l.aid=a.aid and l.bid=b.bid
 ;
quit;
/* 照合レベル別接続結果件数の出力 */
proc freq data=mtest.linkab_log_cnt; tables lv; where acount=1 and bcount=1; run; /* 1 対 1 の接続 */
proc freq data=mtest.linkab_log_cnt; tables lv; where acount>1 or bcount>1; run; /* 1 対 1 でない接続 */ 
  
