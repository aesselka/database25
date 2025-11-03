drop table if exists projects cascade ;
--Task Part 1: Database Setup
--1.1
create table employees(
    emp_id int primary key,
    emp_name varchar(50),
    dept_id int,
    salary decimal(10,2)
);
create table departments(
    dept_id int primary key ,
    dept_name varchar(50),
    location varchar(50)
);
create table projects(
    project_id int primary key ,
    project_name varchar(50),
    dept_id int,
    budget decimal(10,2)
);
--1.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);
INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (101, 'IT', 'Building A'),
                                                           (102, 'HR', 'Building B'),
                                                           (103, 'Finance', 'Building C'),
                                                           (104, 'Marketing', 'Building D');
INSERT INTO projects (project_id, project_name, dept_id,
                      budget) VALUES
                                  (1, 'Website Redesign', 101, 100000),
                                  (2, 'Employee Training', 102, 50000),
                                  (3, 'Budget Analysis', 103, 75000),
                                  (4, 'Cloud Migration', 101, 150000),
                                  (5, 'AI Research', NULL, 200000);

--Part 2: CROSS JOIN Exercises
    --Exercise 2.1: Basic CROSS JOIN
select e.emp_name , d.dept_name
from employees e cross join departments d;
--Exercise 2.2: Alternative CROSS JOIN Syntax
    --a)
select e.emp_name , d.dept_name
from employees e , departments d;
    --b)
select e.emp_name , d.dept_name
from employees e inner join departments d on true;
    --Exercise 2.3: Practical CROSS JOIN
select e.emp_name , p.project_name
from employees e cross join projects p;
--Part 3: INNER JOIN Exercises
    --Exercise 3.1: Basic INNER JOIN with ON
select e.emp_name, d.dept_name, d.location
from employees e inner join departments d on e.dept_id=d.dept_id;
    --Exercise 3.2: INNER JOIN with USING
select emp_name,dept_name,location
from employees
inner join departments using(dept_id);
    --Exercise 3.3: NATURAL INNER JOIN
select emp_name,dept_name,location
from employees
natural inner join departments;
    --Exercise 3.4: Multi-table INNER JOIN
select emp_name,dept_name,project_name
from employees
inner join departments using(dept_id)
inner join projects using(dept_id);
--Part 4: LEFT JOIN Exercises
    --Exercise 4.1: Basic LEFT JOIN
select e.emp_id ,e.dept_id as emp_dept, d.dept_id as dept_dept, d.dept_name
from employees e
left join departments d on d.dept_id=e.dept_id;
    --Exercise 4.2: LEFT JOIN with USING
select emp_id ,dept_id as emp_dept, dept_id as dept_dept, dept_name
from employees
left join departments using(dept_id);
    --Exercise 4.3: Find Unmatched Records
select emp_name ,dept_id
from employees
left join departments using(dept_id)
where dept_id is null;
    --Exercise 4.4: LEFT JOIN with Aggregation
select d.dept_name, count(e.emp_id) as employee_count
from departments d
left join employees e on d.dept_id = e.dept_id
group by d.dept_name ,d.dept_id
order by employee_count desc;
--Part 5: RIGHT JOIN Exercises
    --Exercise 5.1: Basic RIGHT JOIN
select e.emp_id, d.dept_name
from employees e
right join departments d on e.dept_id = d.dept_id;
    --Exercise 5.2: Convert to LEFT JOIN
select e.emp_name , d.dept_name
from departments d
left join employees e on d.dept_id = e.dept_id;
    --Exercise 5.3: Find Departments Without Employees
select d.dept_name,d.location
from employees e
right join departments d on e.dept_id = d.dept_id
where emp_id is null;
--Part 6: FULL JOIN Exercises
    --Exercise 6.1: Basic FULL JOIN
select e.emp_name ,e.dept_id as emp_dept , d.dept_id as dept_dept, d.dept_name
from employees e
full join departments d on e.dept_id=d.dept_id;
    --Exercise 6.2: FULL JOIN with Projects
select dept_name ,project_name
from projects p
full join departments d on p.dept_id = d.dept_id;
    --Exercise 6.3: Find Orphaned Records
select case
    when e.emp_id is null then 'Department without employees'
    when d.dept_id is null then 'Employee without department'
    else 'Matched'
end as record_status, e.emp_name, d.dept_name
from employees e
full join departments d on e.dept_id = d.dept_id
where e.emp_id is null or d.dept_id=d.dept_id;
--Part 7: ON vs WHERE Clause
    --Exercise 7.1: Filtering in ON Clause (Outer Join)
select e.emp_name,d.dept_name,e.salary
from employees e
left join departments d on e.dept_id = d.dept_id and d.location='Building A';
    --Exercise 7.2: Filtering in WHERE Clause (Outer Join)
select e.emp_name,d.dept_name ,e.salary
from employees e
left join departments d on e.dept_id = d.dept_id
where d.location='Building A';
    --Exercise 7.3: ON vs WHERE with INNER JOIN
select e.emp_name, d.dept_name,e.salary
from employees e
inner join departments d on e.dept_id = d.dept_id and d.location='Building A';

select e.emp_name, d.dept_name,e.salary
from employees e
inner join departments d on e.dept_id = d.dept_id where d.location='Building A';
--Part 8: Complex JOIN Scenarios
    --Exercise 8.1: Multiple Joins with Different Types
select d.dept_name,e.emp_name,e.salary,p.project_name,p.budget
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
order by d.dept_name , e.emp_name;
    --Exercise 8.2: Self Join
alter table employees add column manager_id int;
    --update
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;
    --self join
select e.emp_name as employee,
       m.emp_name as manager
from employees e
left join employees m on e.manager_id=m.emp_id;
    --Exercise 8.3: Join with Subquery
select d.dept_name , avg(e.salary) as average_salary
from departments d
inner join employees e using(dept_id)
group by d.dept_id,d.dept_name
having avg(e.salary) >50000;

--Lab questions
-- 1. inner join give only matches, left join give all left table and matches.;
-- 2. testing and generating;
-- 3. for outer joins on keeps unmatched rows,where filter them;
-- 4. it will give 5*10=50;
-- 5.автоматический join all columns with the same names;
-- 6.unintended columns may give incorrect  results;
-- 7.select * from b right join a on a.id=b.id;
-- 8. when u need all unmatched left and right rows