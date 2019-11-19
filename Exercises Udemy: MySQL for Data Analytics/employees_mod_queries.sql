use employees_mod;

#Visualisation of the number of employees employed since 1990, separated by gender and department
#t_employees, t_dept_emp and t_departments required

SELECT 
    YEAR(t1.hire_date) AS calendar_year,
    t2.dept_no,
    t2.dept_name,
    t1.gender,
    COUNT(t1.gender) AS number_of_employees
FROM
    t_employees t1
        INNER JOIN
    (SELECT 
        a1.emp_no, a1.dept_no, a2.dept_name
    FROM
        t_dept_emp a1
    INNER JOIN t_departments a2 ON a1.dept_no = a2.dept_no) AS t2 ON t1.emp_no = t2.emp_no
GROUP BY calendar_year , t2.dept_no , t1.gender
ORDER BY calendar_year;


#Visualisation of the number of managers employed since 1990, separated by gender and department
#t_employees, t_dept_manager and t_departments required
SELECT 
    YEAR(t3.hire_date) AS calendar_year,
    t4.dept_no,
    t4.dept_name,
    t3.gender,
    COUNT(t3.gender) AS number_of_managers
FROM
    t_employees t3
        INNER JOIN
    (SELECT 
        a3.emp_no, a3.dept_no, a4.dept_name
    FROM
        t_dept_manager a3
    INNER JOIN t_departments a4 ON a3.dept_no = a4.dept_no) AS t4 ON t3.emp_no = t4.emp_no
GROUP BY calendar_year , t4.dept_no , t3.gender
ORDER BY calendar_year;


#Visualisation of the average salary of employees since 1990, separated by gender and department
#t_employees, t_salaries, t_dept_emp and t_departments required
SELECT 
    YEAR(t5.hire_date) AS calendar_year,
    t6.dept_no,
    t6.dept_name,
    t5.gender,
    ROUND(AVG(t5.salary), 2) AS average_salary
FROM
    (SELECT 
        a5.emp_no, a5.gender, a5.hire_date, a6.salary
    FROM
        t_employees a5
    INNER JOIN t_salaries a6 ON a5.emp_no = a6.emp_no) AS t5
        INNER JOIN
    (SELECT 
        a7.emp_no, a7.dept_no, a8.dept_name
    FROM
        t_dept_manager a7
    INNER JOIN t_departments a8 ON a7.dept_no = a8.dept_no) AS t6 ON t5.emp_no = t6.emp_no
GROUP BY calendar_year , t6.dept_no , t5.gender
ORDER BY calendar_year;