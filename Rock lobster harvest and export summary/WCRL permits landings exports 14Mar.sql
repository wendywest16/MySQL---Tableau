create database WCRL_per_lan_exp;
use WCRL_per_lan_exp;

#===================================================================
#drop table permits;
#Vessels removed since IR lists too many vessels on each permit without a clear structure

create table permits (
season varchar(10) not null,
sector varchar(5) not null,
permit_number int(7) not null unique,
right_number varchar(20),
permit_status varchar(30) not null,
quota_code int
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/WCRLN O IR SS 17-18 18-19 permits_novessels.csv' 
INTO TABLE permits 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#===================================================================
drop table landings;

create table landings (
right_number varchar(20),
quota_code int,
currently_active enum ('Yes', 'No'),
granted_appeal enum ('TRUE', 'FALSE'),
sector varchar(5) not null,
allocation_1718 float(8,2),
overcatch_1617 float(5,1),
final_allocation_1718 float(8,2),
allocation_1819 float(8,2),
overcatch_1718 float(5,1),
final_allocation_1819 float(8,2),
landings_1718 float(8,2),
percentage_caught_1718 float(5,2),
landings_1819 float(8,2),
percentage_caught_1819 float(5,2),
nearshore_zone varchar(3),
allocation34_1718 decimal(8,2),
allocation7_1718 decimal(8,2),
allocation8_1718 decimal(8,2),
allocation11_1718 decimal(8,2),
allocation34_1819 decimal(8,2),
allocation7_1819 decimal(8,2),
allocation8_1819 decimal(8,2),
allocation11_1819 decimal(8,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/WCRLN O IR SS 17-18 18-19 landings.csv' 
INTO TABLE landings 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

update landings set nearshore_zone = 'F' where nearshore_zone = 'F12' or nearshore_zone = 'F13' or nearshore_zone = 'F14';
#===================================================================

#drop table landings_offshore;

create table landings_offshore (
season varchar(10) not null,
quota_code int,
vessel_id int,
vessel_name varchar(50),
area_nr int,
mass_kg decimal (5,1)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/WCRLO 17-18 18-19 landings.csv' 
INTO TABLE landings_offshore 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
#===================================================================

create table vessels_active (
season varchar(10) not null,
sector varchar(5) not null,
vessel_active varchar(10)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/WCRL vessels active 1718 1819.csv' 
INTO TABLE vessels_active 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
#===================================================================

#drop table exports;

create table exports (
permit_number int,
valid_from varchar(10), #must insert as string first and then convert to date
valid_to varchar(10), #must insert as string first and then convert to date
season varchar(10) not null,
export_date varchar(10), #must insert as string first and then convert to date
export_country varchar(30),
permit_serial int,
frozenwhole_kg decimal(7,2),
live_kg decimal(7,2),
tails_kg decimal(7,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/WCRL exports 17-18 18-19.csv' 
INTO TABLE exports 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

update exports set valid_from = str_to_date(valid_from, '%d-%b-%Y');
update exports set valid_to = str_to_date(valid_to, '%d-%b-%Y');
update exports set export_date = str_to_date(export_date, '%d-%b-%Y');
#===================================================================

#######PERMITS#####

#Checked right numbers in permits table that aren't listed in landings table. These permits weren't approved/issued
select p.right_number, p.permit_status
from permits p left outer join landings l on p.right_number = l.right_number
where l.right_number is null;

#Number of right holders with permits 
select p.season, 
p.sector, 
if(count(distinct p.right_number) = 1, 0, count(distinct p.right_number)) as nr_rightholders_withpermits, #Its counting the blank values as a row -> 1. To avoid blank values as 1, make them 0
if(count(distinct p.quota_code) = 1, 0, count(distinct p.quota_code))  as nr_IR_withpermits
from permits p 
where p.permit_status like '%expired%' or p.permit_status like '%approved%' or p.permit_status like'%issued%'
group by p.season, p.sector;

#Number of right holders that harvested. Safe to assume those who harvested had permits too
select l.sector, 
sum(l.landings_1718 > 0) as nr_rightholders_IR_harvested1718,
sum(l.landings_1819 > 0) as nr_rightholders_IR_harvested1819
from landings l
where l.landings_1718 > 0 or l.landings_1819 > 0
group by l.sector;

#Number of WCRLN, WCRLO, SSF right holders with permit and no landings
select p.season, 
p.sector, 
if(count(distinct p.right_number) = 1, 0, count(distinct p.right_number)) as nr_rightholders_withpermits_noharvest #Its counting the blank values of IR right numbers as a row -> 1. To avoid blank values as 1, make them 0
from permits p join landings l on p.right_number = l.right_number
where p.season = '2017-2018' and l.landings_1718 = 0 and (p.permit_status like '%expired%' or p.permit_status like '%approved%' or p.permit_status like'%issued%')
group by p.season, p.sector
having nr_rightholders_withpermits_noharvest
union all
select p.season, 
p.sector, 
if(count(distinct p.right_number) = 1, 0, count(distinct p.right_number)) as nr_rightholders_withpermits_noharvest #Its counting the blank values of IR right numbers as a row -> 1. To avoid blank values as 1, make them 0
from permits p join landings l on p.right_number = l.right_number
where p.season = '2018-2019' and l.landings_1819 = 0 and (p.permit_status like '%expired%' or p.permit_status like '%approved%' or p.permit_status like'%issued%')
group by p.season, p.sector
having nr_rightholders_withpermits_noharvest;

#Number of IR with permit and no landings. They use cancelled permits too! WTF?! Poor fisheries management!!
select p.season, 
p.sector, 
count(distinct p.quota_code) as nr_IR_withpermits_noharvest 
from permits p join landings l on p.quota_code = l.quota_code
where p.season = '2017-2018' and l.landings_1718 = 0 and (p.permit_status like '%expired%' or p.permit_status like '%approved%' or p.permit_status like'%issued%' or p.permit_status like'%cancelled%')
group by p.season, p.sector
union all
select p.season, 
p.sector, 
count(distinct p.quota_code) as nr_IR_withpermits_noharvest 
from permits p join landings l on p.quota_code = l.quota_code
where p.season = '2018-2019' and l.landings_1819 = 0 and (p.permit_status like '%expired%' or p.permit_status like '%approved%' or p.permit_status like'%issued%' or p.permit_status like'%cancelled%')
group by p.season, p.sector;

#Number of WCRLN, WCRLO, SSF right holders with no permit. 
#NB: Some couldn't apply for a permit in 1718 because they waited for appeal result
select '2017-2018' as season,
l.sector, 
count(l.right_number) as nr_rightholders_nopermit
from landings l left outer join 
(select * from permits where season = '2017-2018' and (permit_status like '%expired%' or permit_status like '%approved%' or permit_status like'%issued%')) as p1718  #Only search for one season's permits at a time
on l.right_number = p1718.right_number
where p1718.right_number is null and l.granted_appeal = 'FALSE'
group by l.sector
union all
select '2018-2019' as season,
l.sector,
count(l.right_number) as nr_rightholders_nopermit
from landings l left outer join 
(select * from permits where season = '2018-2019' and (permit_status like '%expired%' or permit_status like '%approved%' or permit_status like'%issued%')) as p1819
on l.right_number = p1819.right_number
where p1819.right_number is null
group by l.sector;

#Number of IR with no permit. 
#Only IR in 1718, not IRO
#Includes IR communities that were only created in 18/19 season. Include column to show only active from 18/19
select '2017-2018' as season,
l.sector,
count(l.quota_code) as nr_IR_nopermit
from (select * from landings where sector = 'IR') as l 
left outer join 
(select * from permits where season = '2017-2018' and (permit_status like '%expired%' or permit_status like '%approved%' or permit_status like'%issued%' or permit_status like'%cancelled%')) as pIR1718  #Only search for one season's permits at a time
on l.quota_code = pIR1718.quota_code
where pIR1718.quota_code is null
union all
select '2018-2019' as season,
l.sector,
count(l.quota_code) as nr_IR_nopermit
from (select * from landings where sector = 'IR' or sector = 'IRO') as l 
left outer join 
(select * from permits where season = '2018-2019' and (permit_status like '%expired%' or permit_status like '%approved%' or permit_status like'%issued%' or permit_status like'%cancelled%')) as pIR1819  #Only search for one season's permits at a time
on l.quota_code = pIR1819.quota_code
where pIR1819.quota_code is null
group by l.sector;

#Number of vessels active
select season,
sector,
count(distinct vessel_active) as nr_activevessels
from vessels_active
group by season, sector;

#===================================================================

#######LANDINGS#####

#Landings per area, per sector WCRLN, IR, IRO, SSF, SSFO
select sector, nearshore_zone,
sum(allocation_1718) as allocations_1718,
sum(landings_1718) as landings_1718,
concat(round((sum(landings_1718) * 100)/sum(allocation_1718),2), '%') AS percentage_1718_caught,
sum(allocation_1819) as allocations_1819,
sum(landings_1819) as landings_1819,
concat(round((sum(landings_1819) * 100)/sum(allocation_1819),2), '%') AS percentage_1819_caught
from landings
where sector like '%WCRLN%' or sector like '%IR%' or sector like '%SSF%' and nearshore_zone != ''
group by sector, nearshore_zone
order by sector, nearshore_zone asc;

#Landings per area WCRLO
create table WCRLO_landings_area (
select season, 
sum(if(area_nr = '3' or area_nr = '4', WCRLO_landings, 0)) as landings_34,
sum(if(area_nr = '7', WCRLO_landings, 0)) as landings_7,
sum(if(area_nr = '8', WCRLO_landings, 0)) as landings_8,
sum(if(area_nr = '11', WCRLO_landings, 0)) as landings_11
from (select season, area_nr, 
sum(mass_kg) as WCRLO_landings
from landings_offshore 
group by season, area_nr
order by season, area_nr asc) as WCRLO_landings_allareas
group by season
);

create table WCRLO_allocs (
select '2017-2018' as season,
sum(allocation34_1718) as allocation_3n4,
sum(allocation7_1718) as allocation_7,
sum(allocation8_1718) as allocation_8,
sum(allocation11_1718) as allocation_11
from landings
where sector like '%WCRLO%'
union all
select '2018-2019' as season,
sum(allocation34_1819) as allocation_3n4,
sum(allocation7_1819) as allocation_7,
sum(allocation8_1819) as allocation_8,
sum(allocation11_1819) as allocation_11
from landings
where sector like '%WCRLO%'
);

alter table WCRLO_landings_area 
add column allocation34 int,
add column allocation7 int,
add column allocation8 int,
add column allocation11 int;

update WCRLO_landings_area t1
inner join wcrlo_allocs t2 using(season)
set t1.allocation34 = t2.allocation_3n4, t1.allocation7 = t2.allocation_7, t1.allocation8 = t2.allocation_8, t1.allocation11 = t2.allocation_11;

select season, 
landings_34, landings_7, landings_8, landings_11, allocation34, allocation7, allocation8, allocation11,
concat(round((landings_34 * 100)/allocation34, 2), '%') AS percentage_34_caught,
concat(round((landings_7 * 100)/allocation7, 2), '%') AS percentage_7_caught,
concat(round((landings_8 * 100)/allocation8, 2), '%') AS percentage_8_caught,
concat(round((landings_11 * 100)/allocation11, 2), '%') AS percentage_11_caught
from wcrlo_landings_area
group by season;

#===================================================================

#######EXPORTS#####

#Duplicate the exports table
create table exports1 like exports;

insert into exports1
select * from exports;

#Check country names listed
select export_country
from exports1
group by export_country;

#Country called 'Gala' is unknown. Change to blank
update exports1
set export_country = ''
where export_country = 'Gala';


#Update country names
update exports1
set export_country = 'China'
where export_country = 'Beijing, China' or 
export_country =  'Beijing' or 
export_country = 'Guangzhou' or 
export_country = 'Guangzhou, China' or 
export_country = 'Xiamen, China' or 
export_country = 'Shanghai' or 
export_country = 'Shangha' or 
export_country = 'Shanghai, China' ;

update exports1
set export_country = 'Hong Kong, China'
where export_country = 'Hong Kong' or export_country =  'Kong Kong';

update exports1
set export_country = 'Vietnam'
where export_country = 'Hanoi, Vietnam';

update exports1
set export_country = 'Italy'
where export_country = 'Venice, Italy' or export_country = 'Venice' or export_country = 'Napoli, Italy';

update exports1
set export_country = 'Taiwan'
where export_country = 'Taipei, Taiwan' or export_country = 'Taipei';

update exports1
set export_country = 'Japan'
where export_country = 'Osaka, Japan';


#Amount exported per country per season
select season, export_country, 
sum(frozenwhole_kg) as frozen_exported,
sum(live_kg) as live_exported,
sum(tails_kg) as tails_exported
from exports1
group by season, export_country
order by season, live_exported desc;

#Unpivot table to get column of product types
#Include Lat and Long position for curved lines on interactive map
select season, export_country, sum(frozenwhole_kg) as kg_exported, 'frozen_whole' descrip, 'South Africa' supplier
from exports1
group by season, export_country
union all
select season, export_country, sum(live_kg) as kg_exported, 'live' descrip, 'South Africa' supplier
from exports1
group by season, export_country
union all
select season, export_country, sum(tails_kg) as kg_exported, 'tails' descrip,'South Africa' supplier
from exports1
group by season, export_country;


