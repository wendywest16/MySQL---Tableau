#CREATE DATABASE, TABLES AND INSERT DATA
#=====================================================
create database ORG;
use ORG;

create table worker (
worker_id int not null primary key auto_increment,
first_name varchar(25),
last_name varchar(25),
salary int(15),
joining_date datetime,
department varchar(25)
);

insert into worker
(worker_id, first_name, last_name, salary, joining_date, department) values
(001, 'Monika', 'Arora', 100000, '14-02-20 09.00.00', 'HR'),
		(002, 'Niharika', 'Verma', 80000, '14-06-11 09.00.00', 'Admin'),
		(003, 'Vishal', 'Singhal', 300000, '14-02-20 09.00.00', 'HR'),
		(004, 'Amitabh', 'Singh', 500000, '14-02-20 09.00.00', 'Admin'),
		(005, 'Vivek', 'Bhati', 500000, '14-06-11 09.00.00', 'Admin'),
		(006, 'Vipul', 'Diwan', 200000, '14-06-11 09.00.00', 'Account'),
		(007, 'Satish', 'Kumar', 75000, '14-01-20 09.00.00', 'Account'),
		(008, 'Geetika', 'Chauhan', 90000, '14-04-11 09.00.00', 'Admin'),
        (009, 'Wendy', 'West', 100000, '14-02-20 09.00.00', 'AB');

CREATE TABLE bonus (
    worker_ref_id INT,
    bonus_amount INT(10),
    bonus_date DATETIME,
    FOREIGN KEY (worker_ref_id)
        REFERENCES worker (worker_id)
        ON DELETE CASCADE
);

INSERT INTO Bonus 
	(worker_ref_id, bonus_amount, bonus_date) VALUES
		(001, 5000, '16-02-20'),
		(002, 3000, '16-06-11'),
		(003, 4000, '16-02-20'),
		(001, 4500, '16-02-20'),
		(002, 3500, '16-06-11');

CREATE TABLE Title (
	worker_ref_id INT,
	worker_title CHAR(25),
	affected_from DATETIME,
	FOREIGN KEY (worker_ref_id)
		REFERENCES worker(worker_id)
        ON DELETE CASCADE
);

INSERT INTO Title 
	(worker_ref_id, worker_title, affected_from) VALUES
 (001, 'Manager', '2016-02-20 00:00:00'),
 (002, 'Executive', '2016-06-11 00:00:00'),
 (008, 'Executive', '2016-06-11 00:00:00'),
 (005, 'Manager', '2016-06-11 00:00:00'),
 (004, 'Asst. Manager', '2016-06-11 00:00:00'),
 (007, 'Executive', '2016-06-11 00:00:00'),
 (006, 'Lead', '2016-06-11 00:00:00'),
 (003, 'Lead', '2016-06-11 00:00:00');
 
 #========================================================
 #RUN QUERIES
 #========================================================
 
 #Upper case
 select upper(first_name) from worker;
 
 #Unique values
 select distinct(department) from worker;
 
 #Number of letters per word in the unique values
 select distinct length(department) from worker;
 
 #Replace letters
 select replace (first_name, 'a', 'x' ) from worker;
 
 
 #First 3 characters from a field name
 select substring(first_name,1,3) from worker;
 
 #Find the position of the letter ‘A’ in the first name column for name ‘Amitabh’ 
 select instr(first_name, binary 'a') from worker where first_name = 'Amitabh';
 
 #Remove white spaces in front of names
 select rtrim(first_name) from worker;
 
#Remove white spaces at the end of names
select ltrim(department) from worker;

#Even rows
select * from worker where mod(worker_id,2)=0;

#Odd rows
select * from worker where mod(worker_id,2) <> 0;

#Sum all entries minus distinct entries
select count(department) - count(distinct department) from worker;

#Word with maximum and minimum number of letters. If more than one min/max word, choose what comes first alphabetically 
SELECT DISTINCT
    (department), LENGTH(department) AS nr_letters
FROM
    worker
WHERE
    LENGTH(department) = (SELECT 
            MAX(LENGTH(department))  #Or MIN
        FROM
            worker)
ORDER BY department ASC
LIMIT 1; 

#Find words with letters using LIKE
#Words that start with certain letters
SELECT 
    first_name
FROM
    worker
WHERE
    first_name LIKE 'a%'
        OR first_name LIKE 'w%';

#Words that end with certain letters
SELECT 
    first_name
FROM
    worker
WHERE
    first_name LIKE '%y'
        OR first_name LIKE '%a';

#Words that start and end with certain letters
SELECT 
    first_name
FROM
    worker
WHERE
    first_name LIKE 'w%y';
    
#Letters in certain parts of the word
SELECT 
    first_name
FROM
    worker
WHERE
    first_name LIKE '_e%';

#Ends with 'a' letter and words has 6 letters

select first_name from worker where first_name like '_____a';

#Find words with letters using REGEXP
# https://www.oreilly.com/library/view/mysql-cookbook/0596001452/ch04s08.html
# https://www.guru99.com/regular-expressions.html
# '^ starts with'
# [^abcd] does not contain
# 'ends with $'
# '' contains anywhere in text
# ^..n letter x at a specific part of the word
# '^[aeiou]|er$' starts with a vowel OR ends with er

SELECT 
    first_name
FROM
    worker
WHERE
    first_name REGEXP '^[wa]' and first_name REGEXP '[yn]$';

#Order by letters in a word and by another column
SELECT 
    first_name, salary
FROM
    worker
WHERE
    salary >= 100000
ORDER BY right(first_name, 3) asc, worker_id asc; #order by last three letters in a word


#Between values and concat
SELECT 
    first_name, salary
FROM
    worker
WHERE
    salary between 80000 and 100000;
   
#Between values and concat   
SELECT 
    concat(first_name, ' ', last_name) as worker_name, salary
FROM
    worker
WHERE
    salary >=50000 and salary <=100000;
    
#Values from a month and year within a date
select first_name from worker where year(joining_date) =2014 and month (joining_date) = 2;

#Extract year, month or day from a date field
select first_name, year(joining_date) as join_year,
month(joining_date) as join_month,
day(joining_date) as join_day
from worker;

#Count
select count(first_name) from worker where department = 'Admin';

select department, count(worker_id) as nr_of_workers from worker 
group by department
order by nr_of_workers desc;

#Inner join
select * from worker w join title t on w.worker_id = t.worker_ref_id where t.worker_title = 'manager';

SELECT DISTINCT
    (first_name), t.worker_title
FROM
    worker w
        JOIN
    title t ON w.worker_id = t.worker_ref_id
        AND t.worker_title IN ('manager');

#Find duplicate records
SELECT 
    worker_title, affected_from
FROM
    title
GROUP BY worker_title , affected_from
HAVING COUNT(*) > 1;

#Clone or create new table from existing table, with records
select * into workerclone from worker;

#Clone or create new table from existing table, no records
select * into workerclone from worker where 1=0;

create table workerclone like worker;

#Current date 
select curdate();

#Current date and time
select now();

#Top 5 records
select first_name from worker 
order by first_name asc
limit 5;

#nth highest record from a table. 5th record
select first_name from worker order by first_name asc limit 4,1; #n-1 so 5-1 = 4

select salary from worker group by salary order by salary asc limit 4,1;

#Second highest. Not by order but by value
select max(salary) from worker
where salary not in (select max(salary) from worker);

#Fetch records that are identical
select distinct(w.worker_id), w.first_name, w.salary 
from worker w, worker w1 
where w.salary=w1.salary and w.worker_id != w1.worker_id;

#Show duplicates between two tables with union all. Or show same record twice from same table
select w.first_name, w.department from worker w where w.department = 'HR'
union all
select w1.first_name, w1.department from worker w1 where w1.department = 'HR';

#First 50% of records
select * from worker
where worker_id <= (select count(worker_id)/2 from worker);

#Show records with less than a certain number
select department, count(worker_id) as nr_of_workers from worker
group by department
having count(worker_id) < 5;

#First row record
select * from worker where worker_id = (select min(worker_id) from worker);

#Last record in a table
select * from worker where worker_id = (select max(worker_id) from worker);

#Last 5 records
SELECT * FROM Worker WHERE WORKER_ID <=5
UNION
SELECT * FROM (SELECT * FROM Worker W order by W.WORKER_ID DESC) AS W1 WHERE W1.WORKER_ID <=5;

#Highest value (including ties/duplicates) within each cetagory
#First put together a table of the highest values. Then link those to all workers to see which workers 
#have these highest values

SELECT 
    w.DEPARTMENT, w.FIRST_NAME, w.Salary
FROM
    (SELECT 
        MAX(Salary) AS TotalSalary, DEPARTMENT
    FROM
        Worker
    GROUP BY DEPARTMENT) AS TempNew
        INNER JOIN
    Worker w ON TempNew.DEPARTMENT = w.DEPARTMENT
        AND TempNew.TotalSalary = w.Salary;

#3 Highest values
select salary from worker group by salary order by salary desc limit 3;

SELECT DISTINCT
    Salary
FROM
    worker a
WHERE
    3 >= (SELECT 
            COUNT(DISTINCT Salary)
        FROM
            worker b
        WHERE
            a.Salary <= b.Salary)
ORDER BY a.Salary DESC;

#3 Lowest values
select salary from worker group by salary order by salary asc limit 3;

SELECT DISTINCT
    Salary
FROM
    worker a
WHERE
    3 >= (SELECT 
            COUNT(DISTINCT Salary)
        FROM
            worker b
        WHERE
            a.Salary >= b.Salary)
ORDER BY a.Salary DESC;

#Sum
select department, sum(salary) from worker group by department;

#Highest values per person
select first_name, salary from worker 
where salary = (select max(salary) from worker);

#Lower case
select lower(first_name) from worker;

#Upper case
select upper(first_name) from worker;

#Add or subtract hours, days, months, years to a date

SELECT CURDATE();
SELECT DATE_ADD(CURDATE(), INTERVAL 6 HOUR) result;

SELECT DATE_ADD(CURDATE(), INTERVAL -2 day) result; #OR
SELECT DATE_SUB(CURDATE(), INTERVAL 2 DAY) result;

SELECT DATE_ADD('2019-13-09', INTERVAL 2 day) result;

#Combine day, month year into one date field
#Helpful functions https://dev.mysql.com/doc/refman/8.0/en/date-and-time-functions.html#function_str-to-date

SELECT
STR_TO_DATE(CONCAT(yourYearColumName,'-',LPAD(yourMonthColumName,2,'00'),'-',LPAD(yourDayColumName,2,'00')), '%Y-%m-%d') as anyVariableName from yourTableName;

#IN and NOT IN 
select first_name from worker where department in ('HR');

select first_name from worker where department not in ('HR');

#Subquery using WHERE EXISTS
SELECT first_name FROM worker WHERE EXISTS 
(SELECT worker_title FROM title 
WHERE worker_id = worker_ref_id and worker_title = "Manager");

#Part of the text left of the second "."
select substring_index("www.bytescout.com", ".", 2);

select substring_index(first_name, "n", 1) from worker;

#Ranking
select worker_id, first_name, department, salary, dense_rank() over (partition by department order by salary) as ranking
from worker;

#sum/avg/count/min/max etc. of groups into a new column
select worker_id, first_name, department, salary,
sum(salary) over() as total_salaries,
sum(salary) over (partition by department) as total_department_salaries
from worker;

#=============================================
create table product_sales (
product_line varchar(25),
order_year int(4),
order_value int(4)
);

insert into product_sales
(product_line, order_year, order_value) values
('cheese', 2017, 5),
('cheese', 2018, 7),
('cheese', 2019, 10),
('bread', 2017, 3),
('bread', 2018, 2),
('bread', 2019, 8);

#=============================================

#LAG() function to access data of a previous row from the current row in the same result set
select product_line, order_year, order_value, 
lag(order_value, 1, 0) over (partition by product_line order by order_year) as previous_order_value, #1 row before, 0 values if null
order_value - lag(order_value, 1, 0) over (partition by product_line order by order_year) as order_diff
from product_sales;

#LEAD() function to access data of the next row from the current row in the same result set
select product_line, order_year, order_value, 
lead(order_value, 1, 0) over (partition by product_line order by order_year) as next_order_value, #1 row before, 0 values if null
lead(order_value, 1, 0) over (partition by product_line order by order_year) - order_value as order_diff
from product_sales;

#PERCENT_RANK 
select product_line, order_value, 
round(percent_rank() over (partition by product_line order by order_value desc), 2) as percentage_rank
from product_sales;

#==================================
#Euclidean distance between two coordinates (lat_n and long_w)
select round(
    sqrt(power(min(lat_n)-max(lat_n),2) + 
         power(min(long_w)-max(long_w),2)),4)
from station;

#==================================
create table triangle_sides (
A int(4),
B int(4),
C int(4)
);

insert into triangle_sides
(A, B, C) values
(20, 20, 23),
(20, 20, 20),
(20, 21, 22),
(13, 14, 30);

select
A, B, C,
case
when A = B and B = C then 'equilateral'
when A = B and A != C then 'isosceles'
when A = C and A != B then 'isosceles'
when B = C and B != A then 'isosceles'
when A + B <= C then 'not a triangle' 
when A + C <= B then 'not a triangle' 
when C + B <= A then 'not a triangle' 
else 'scalene'
end as type_of_triangle
from triangle_sides;


#The order listing the types of triangles is important
SELECT CASE 
WHEN A + B <= C OR A + C <= B OR B + C <= A THEN 'Not A Triangle' 
WHEN A = B AND B = C THEN 'Equilateral' 
WHEN A = B OR B = C OR A = C THEN 'Isosceles' 
ELSE 'Scalene' 
END 
FROM TRIANGLES;
