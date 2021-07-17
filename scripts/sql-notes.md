
## Copy sectional summaries from newreturn table (2020,2021 censuses)
```
insert into short_count
select r.object_id,r.census_id,
       y_5_m+y_5_f+y_5_p+y_5_s+
       y_6_m+y_6_f+y_6_p+y_6_s+
       y_7_m+y_7_f+y_7_p+y_7_s+
       y_8_m+y_8_f+y_8_p+y_8_s
       ,1,now(),'127.0.0.1'
  from newreturn r, summary s, object o
 where r.census_id=s.census_id and s.status='approved' and
       r.object_id=s.object_id and r.object_id = o.object_id and
       o.objecttype_id = 10
union
select r.object_id,r.census_id,
       y_13_m+y_13_f+y_13_p+y_13_s+
       y_14_m+y_14_f+y_14_p+y_14_s+
       y_15_m+y_15_f+y_15_p+y_15_s+
       y_16_m+y_16_f+y_16_p+y_16_s+
       y_17_m+y_17_f+y_17_p+y_17_s
       ,1,now(),'127.0.0.1'
  from newreturn r, summary s, object o
 where r.census_id=s.census_id and s.status='approved' and
       r.object_id=s.object_id and r.object_id = o.object_id and
       o.objecttype_id = 13
union
select r.object_id,r.census_id,
       y_7_m+y_7_f+y_7_p+y_7_s+
       y_8_m+y_8_f+y_8_p+y_8_s+
       y_9_m+y_9_f+y_9_p+y_9_s+
       y_10_m+y_10_f+y_10_p+y_10_s
       ,1,now(),'127.0.0.1'
  from newreturn r, summary s, object o
 where r.census_id=s.census_id and s.status='approved' and
       r.object_id=s.object_id and r.object_id = o.object_id and
       o.objecttype_id = 11
union
select r.object_id,r.census_id,
       y_10_m+y_10_f+y_10_p+y_10_s+
       y_11_m+y_11_f+y_11_p+y_11_s+
       y_12_m+y_12_f+y_12_p+y_12_s+
       y_13_m+y_13_f+y_13_p+y_13_s+
       y_14_m+y_14_f+y_14_p+y_14_s
       ,1,now(),'127.0.0.1'
  from newreturn r, summary s, object o
 where r.census_id=s.census_id and s.status='approved' and
       r.object_id=s.object_id and r.object_id = o.object_id and
       o.objecttype_id = 12; 
```
## Generate report for Peter...
```
select o.object_id,
       if( o.__index like '0690e4000064%', '10000003',
       if( o.__index like '0690e40000c8%', '10000133',
       if( o.__index like '0690e400012c%', '10000004',
       if( o.__index like '0690e4000190%', '10000005','10000001')))) as x_id,
       if( o.__index like '0690e4000064%', 'England',
       if( o.__index like '0690e40000c8%', 'Wales',
       if( o.__index like '0690e400012c%', 'Northern Ireland',
       if( o.__index like '0690e4000190%', 'Scotland','Other')))) as x_name,
       r.username as r_id, r.name as r_name,
       c.username as c_id, c.name as c_name,
       d.username as d_id, d.name as d_name,
       g.username as g_id, g.name as g_name,
       o.username as   id, o.name,
       ot.name as type,
       c20.yp_count as `Jan 2020`,
       c21.yp_count as `Jan 2021`,
       c22.yp_count as `Oct 2021`,
       c22.updated_at as updated
  from (((
         (select distinct object_id from short_count) a,
	 objecttype ot, object o, object g,
         object d, object c, object r
       ) left join short_count c20 on o.object_id = c20.object_id and c20.census_id = 20
       ) left join short_count c21 on o.object_id = c21.object_id and c21.census_id = 21
       ) left join short_count c22 on o.object_id = c22.object_id and c22.census_id = 22
 where o.parent_id = g.object_id and g.parent_id = d.object_id and d.parent_id = c.object_id and
       c.parent_id = r.object_id and ot.objecttype_id = o.objecttype_id and
       o.objecttype_id in (10,11,12,13) and o.object_id = a.object_id
 order by x_name,r_name,c_name,d_name,g_name,name;
```
