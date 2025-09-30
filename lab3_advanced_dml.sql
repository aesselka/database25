--Part A: Database and Table Setup
--1. Create database and tables
create database advanced_lab;
create table employees(
    emp_id serial primary key,
    first_name varchar(100),
    last_name varchar(100),
    department varchar(100),
    salary integer,
    hire_date date,
    status varchar(100) default 'Active'
);
drop table if exists departments;
create table departments(
    dept_id serial primary key ,
    dept_name varchar(100),
    budget integer,
    manager_id integer
);
create table projects(
    project_id serial primary key ,
    project_name varchar(100),
    dept_id integer references departments(dept_id),
    start_date date,
    end_date date,
    budget integer
);
--Part B Advanced INSERT Operations
--insert with column specification
--2
insert into employees (emp_id,first_name,last_name,department)
values (default,'Assel','Bazhikey','IT');
--3
insert into employees (emp_id,first_name,last_name,department,hire_date)
values (DEFAULT,'Dariya','Yergaliyeva','PR','2023-09-09');
--4
insert into departments(dept_name, budget, manager_id)
values
    ('Engineering',20000,1),
    ('HR',3000,2),
    ('Sales', 1500, 3);
--5
insert into employees(emp_id,first_name,last_name,department,salary,hire_date)
values (default,'Anel','Yeraliyeva','HR',5000*1.1,current_date);
--6
create temp table temp_employees as
    select * from employees where department='IT';
--Part C: Complex UPDATE Operations
--7
update employees
set salary=salary*1.10
where department='Sales';
--8
update employees
set status='Senior'
where salary>6000 and hire_date<'2020-01-01';
--9
update employees
set department=case
    when salary>8000 then 'Management'
    when salary between 50000 and 80000 then 'Senior'
    else 'Junior'
end
where salary>30000;
--10
update employees
set department=default
where status='Inactive';
--11
update departments
set budget=budget+(select(avg(employees.salary)*0.20) from employees where employees.department=departments.dept_name)
where exists (select 1 from employees where employees.department=departments.dept_name);
--12
update employees
set salary=salary*1.15 , status='Promoted'
where department='Sales';
--Part D: Advanced DELETE Operations
--13
delete from employees
where status='Terminated';
--14
delete from employees
where salary<4000 and hire_date>'2023-01-01' and department is NULL;
--15
delete from departments
where dept_id not in(
    select distinct cast(department as integer)
    from employees where department is not null);--надо исправить
--16
delete from projects
where end_date<'2023-01-01'
returning *;
-- Part E: Operations with NULL Values
--17
insert into employees(emp_id,first_name,last_name,department,salary,hire_date)
values (default,'Bek','Wolf',null,null,current_date);
--18
update employees
set department='Unassigned'
where department is null;
--19
delete from employees
where salary is null or department is null;
--Part F: RETURNING Clause Operations
--20
insert into employees(first_name, last_name, department, salary, hire_date)
values ('Aikosha','Bazhikey','IT',50000,current_date)
returning emp_id,first_name || ' ' || last_name as full_name;
--21
update employees
set salary=salary+5000
where department='IT'
returning emp_id, salary-5000 as old_salary , salary as new_salary;
--22
delete from employees
where hire_date<'2020-01-01'
returning *;
--Part G: Advanced DML Patterns
--23
insert into employees (first_name, last_name, department, salary, hire_date)
select 'Aidyn','Aliya','IT',45000,current_date
where not exists(
    select 1 from employees where first_name='Aidyn' and last_name='Aliya'
);
--24
update employees
set salary =salary*
            case
                when departments.budget >100000 then 1.10
                else 1.05
            end
from departments
where employees.department= departments.dept_name;
--25
insert into employees (first_name, last_name, department, salary, hire_date)
values ('Anel','ri','HR',30000,'2021-06-01'),
       ('Jungkook','Jung','IT',50000,'2021-07-01'),
       ('Taehyung','Kim','Management',15000,'2021-08-01'),
       ('Jimin','Kim','HR',40000,'2021-09-01'),
       ('Eunwoo','Min','IT',36000,'2021-10-01');
update  employees
set salary=salary*1.10
where salary >=30000;
--26
create table employee_archive as
    select * from employees where status='Inactive';
--move
insert into employee_archive
select * from employees where status='Inactive';
delete from employees where status='Inactive';
--27
update projects
set end_date=end_date+ interval '30 days'
where budget >50000 and dept_id in (
    select dept_id from employees
                   group by dept_id
                   having count(*)>3
    )
