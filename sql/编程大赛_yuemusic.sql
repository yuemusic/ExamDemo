--ʹ��oracle

1��
��1��ͳ��20171001��20171007�ڼ��ۼƷ���pv����100�������û�����
--list
select count(*) cnt
  from (select a.msisdn, sum(a.pv) pv --����pv
          from PAGEVISIT a, USER_INFO b
         where a.msisdn = b.msisdn
           and b.sex = '��' --����b���ж���Ů
           and a.record_day between '20171001' and '20171007' --�޶�����
         group by a.msisdn) a
 where a.pv > '100'; --pv>100

��2��ͳ��20171001��20171007�ڼ���������3���з��ʵ��û��嵥
--list
select distinct a.msisdn
  from (select a.msisdn, a.flag, count(*) cnt
          from (select a.msisdn, (a.record_day - a.rn) flag     --���ڼ����к���ͬ���ж���������
                  from (select a.*,
                               row_number() over(partition by a.msisdn order by a.record_day) as rn    --���û�������������
                          from (select distinct a.msisdn, a.record_day   --����ȡʱ������û�
                                  from PAGEVISIT a
                                 where a.record_day between '20171001' and
                                       '20171007') a) a) a
         group by a.msisdn, a.flag) a
 where a.cnt >= '3';   --���������������ڵ���3��

2��
��1��ͳ��ÿ��������н������top3���û��б�ע�����ڶ���н����ͬ���������ǰ����н��ֱ�Ϊ10��8��8��7���򷵻صĽ�����������ˣ�
���������Ϣ����������|Ա������|н��

select b.dept_name, a.name, a.salary
  from (select a.*
          from EMPLOYEE a,  --b��ɸѡ���ݹ���a��
               (select a.salary,
                       a.departmentid,
                       row_number() over(partition by a.departmentid order by salary desc) rn  --������н������
                  from (select to_char(wm_concat(a.name)) msisdn,  --����ͬн�ꡢ���ŵ�Ա�����ϳ�һ��
                               a.salary,
                               a.departmentid
                          from EMPLOYEE a
                         group by a.salary, a.departmentid) a) b
         where a.salary = b.salary
           and a.departmentid = b.departmentid
           and b.rn <= '3') a,  --�޶�н��ǰ3
       DEPARTMENT b
 where a.departmentid = b.departmentid(+);

3��
(1)	дһ�� SQL ͳ��2013-10-01����2013-10-03���ڼ䣬ÿ��ǽ�ֹ�û���ȡ���ʡ�
��� SQL ���Ӧ�������½����ȡ���ʣ�Cancellation Rate��������λС����

create table table_a as
select a.id,a.CLIEND_ID,a.DRIVER_ID,a.DEPARTMENTID,a.STATUS,a.REQUEST_AT,
(case when b.USER_ID is not null then '1' else '0' end)is_no_client,   --���ϱ�ʾ
(case when c.USER_ID is not null then '1' else '0' end)is_no_driver
from TRIPS a,
(select * from USERS b where b.banned='No' and b.ROLE='CLIENT')b,  --�ǽ�ֹ�˿�
(select * from USERS b where b.banned='No' and b.ROLE='DRIVER')c   --�ǽ�ֹ˾��
where a.CLIEND_ID=b.USER_ID(+) and a.DRIVER_ID=c.USER_ID(+)
and a.REQUEST_AT between '20131001' and '20131003';   --�޶�˾��

--list
select a.REQUEST_AT, round(a.cnt_cancel / a.cnt_all, 2) Cancellation_Rate   --����ȡ����
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
                           end) cnt_cancel,     --�ǽ�ֹ�˿�ȡ���ͷǽ�ֹ˾��ȡ��Ϊ1������Ϊ0������
                       count(*) cnt_all    --�ܼ���
                  from table_a a
                 group by a.id, a.REQUEST_AT) a
         group by a.REQUEST_AT) a;









