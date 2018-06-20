--使用oracle

1、
（1）统计20171001至20171007期间累计访问pv大于100的男性用户数。
--list
select count(*) cnt
  from (select a.msisdn, sum(a.pv) pv --汇总pv
          from PAGEVISIT a, USER_INFO b
         where a.msisdn = b.msisdn
           and b.sex = '男' --关联b表判断男女
           and a.record_day between '20171001' and '20171007' --限定日期
         group by a.msisdn) a
 where a.pv > '100'; --pv>100

（2）统计20171001至20171007期间至少连续3天有访问的用户清单
--list
select distinct a.msisdn
  from (select a.msisdn, a.flag, count(*) cnt
          from (select a.msisdn, (a.record_day - a.rn) flag     --日期减序列号相同的判断连续访问
                  from (select a.*,
                               row_number() over(partition by a.msisdn order by a.record_day) as rn    --按用户排序，增加序列
                          from (select distinct a.msisdn, a.record_day   --先提取时间段内用户
                                  from PAGEVISIT a
                                 where a.record_day between '20171001' and
                                       '20171007') a) a) a
         group by a.msisdn, a.flag) a
 where a.cnt >= '3';   --连续访问天数大于等于3天

2、
（1）统计每个部门中薪酬排名top3的用户列表（注：存在多人薪酬相同的情况，如前四人薪酬分别为10万，8万，8万，7万，则返回的结果包含此四人）
输出以下信息：部门名称|员工姓名|薪酬

select b.dept_name, a.name, a.salary
  from (select a.*
          from EMPLOYEE a,  --b表筛选数据关联a表
               (select a.salary,
                       a.departmentid,
                       row_number() over(partition by a.departmentid order by salary desc) rn  --按部门薪酬排序
                  from (select to_char(wm_concat(a.name)) msisdn,  --将相同薪酬、部门的员工整合成一列
                               a.salary,
                               a.departmentid
                          from EMPLOYEE a
                         group by a.salary, a.departmentid) a) b
         where a.salary = b.salary
           and a.departmentid = b.departmentid
           and b.rn <= '3') a,  --限定薪酬前3
       DEPARTMENT b
 where a.departmentid = b.departmentid(+);

3、
(1)	写一段 SQL 统计2013-10-01日至2013-10-03日期间，每天非禁止用户的取消率。
你的 SQL 语句应返回如下结果，取消率（Cancellation Rate）保留两位小数。

create table table_a as
select a.id,a.CLIEND_ID,a.DRIVER_ID,a.DEPARTMENTID,a.STATUS,a.REQUEST_AT,
(case when b.USER_ID is not null then '1' else '0' end)is_no_client,   --带上表示
(case when c.USER_ID is not null then '1' else '0' end)is_no_driver
from TRIPS a,
(select * from USERS b where b.banned='No' and b.ROLE='CLIENT')b,  --非禁止乘客
(select * from USERS b where b.banned='No' and b.ROLE='DRIVER')c   --非禁止司机
where a.CLIEND_ID=b.USER_ID(+) and a.DRIVER_ID=c.USER_ID(+)
and a.REQUEST_AT between '20131001' and '20131003';   --限定司机

--list
select a.REQUEST_AT, round(a.cnt_cancel / a.cnt_all, 2) Cancellation_Rate   --计数取消率
  from (select a.REQUEST_AT,
               sum(a.cnt_cancel) cnt_cancel,
               sum(a.cnt_all) cnt_all
          from (select a.id,
                       a.REQUEST_AT,
                       sum(case
                             when a.is_no_client = '1' and
                                  a.STATUS = 'CANCELLED_BY_CLIENT' then
                              '1'
                             when a.is_no_driver = '1' and
                                  a.STATUS = 'CANCELLED_BY_DRIVER' then
                              '1'
                             else
                              '0'
                           end) cnt_cancel,     --非禁止乘客取消和非禁止司机取消为1，其余为0，计数
                       count(*) cnt_all    --总计数
                  from table_a a
                 group by a.id, a.REQUEST_AT) a
         group by a.REQUEST_AT) a;









