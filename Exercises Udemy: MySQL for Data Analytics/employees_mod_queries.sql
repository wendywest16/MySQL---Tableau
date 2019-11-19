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
