create database exports_turnaround;
use exports_turnaround;
#drop database exports_turnaround;

create table permits_mast (
permit_no int,
date_created varchar(100),
start_date varchar(100),
permit_holder varchar(100),
permit_status varchar (50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/all_wcrl_permits_mast - Copy.csv' 
INTO TABLE permits_mast 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


create table permits_RHs (
permit_no int,
permit_holder varchar(200),
right_holder varchar(200),
season varchar(30),
species varchar(30)
);

#Name of Leibrandt: AJD had to be shortened, perhaps problem with the e in Daniel

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/access_permits - Copy.csv' 
INTO TABLE permits_RHs 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#Check the permit statuses that exist
select distinct(permit_status)
from permits_mast;

#Check species listed
select distinct(species)
from permits_rhs;

#Split the date and time columns and add to permits_mast table
select 
substring_index(date_created, ' ', 1) as day_created,
substring_index(substring_index(date_created, ' ', 2), ' ', -1) as time_created,
substring_index(start_date, ' ', 1) as day_started,
substring_index(substring_index(start_date, ' ', 2), ' ', -1) as time_started
from permits_mast;

#drop table ir_permits;

#Filter out the IR "community" right holders and permits that are expired, approved or issued that indicates completed permits
#Plus split date/time columns
create table IR_permits as
select pm.permit_no, pm.permit_holder, pm.permit_status, pr.right_holder,
substring_index(date_created, ' ', 1) as day_created,
#substring_index(substring_index(date_created, ' ', 2), ' ', -1) as time_created,
substring_index(start_date, ' ', 1) as day_started
#substring_index(substring_index(start_date, ' ', 2), ' ', -1) as time_started
from permits_mast pm right outer join permits_rhs pr using (permit_no)
where pr.right_holder LIKE '%community%' and (pm.permit_status like'%Expired%' or pm.permit_status like '%approved%' or pm.permit_status like'%issued%') and pr.species like '%WCRL%';

#Change data type of date columns to date format
update IR_permits
set day_created = str_to_date(day_created, "%d/%m/%Y");

update IR_permits
set day_started = str_to_date(day_started, "%d/%m/%Y");

#drop table commercial_permits;

create table Commercial_permits as
select pm.permit_no, pm.permit_holder, pm.permit_status, pr.right_holder,
substring_index(date_created, ' ', 1) as day_created,
#substring_index(substring_index(date_created, ' ', 2), ' ', -1) as time_created,
substring_index(start_date, ' ', 1) as day_started
#substring_index(substring_index(start_date, ' ', 2), ' ', -1) as time_started
from permits_mast pm right outer join permits_rhs pr using (permit_no)
where pr.right_holder not like '%community%' and (pm.permit_status like'%Expired%' or pm.permit_status like '%approved%' or pm.permit_status like'%issued%') and pr.species like '%WCRL%';

#Change data type of date columns to date format
update Commercial_permits
set day_created = str_to_date(day_created, "%d/%m/%Y");

update Commercial_permits
set day_started = str_to_date(day_started, "%d/%m/%Y");



#Create table of weekends, weekday holidays and DAFF closure dates for 2017 to Jan2020
create table holidays (
hol_year int,
holiday_name varchar(100),
holiday_date date
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/weekday_holidays.csv' 
INTO TABLE holidays
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#Community permits turnaround time after subtraction of weekends, holidays and company closure dates
SELECT 
    permit_no,
    permit_holder,
    day_created,
    day_started,
    #DATEDIFF(day_started, day_created) AS turnaround_with_holidayswknds,
    DATEDIFF(day_started, day_created) - COALESCE((SELECT 
                    COUNT(1)
                FROM
                    holidays
                WHERE
                    holiday_date BETWEEN day_created AND day_started),
            0) AS turnaround_without_holidayswknds
FROM
    ir_permits
group by permit_no;


#Commercial (non-community) permits turnaround time after subtraction of weekends, holidays and company closure dates
SELECT 
    permit_no,
    permit_holder,
    day_created,
    day_started,
    #DATEDIFF(day_started, day_created) AS turnaround_with_holidayswknds,
    DATEDIFF(day_started, day_created) - COALESCE((SELECT 
                    COUNT(1)
                FROM
                    holidays
                WHERE
                    holiday_date BETWEEN day_created AND day_started),
            0) AS turnaround_without_holidayswknds
FROM
    commercial_permits
group by permit_no;