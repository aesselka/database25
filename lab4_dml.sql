--Database schema
drop table if exists projects;
CREATE TABLE employees (
                           employee_id SERIAL PRIMARY KEY,
                           first_name VARCHAR(50),
                           last_name VARCHAR(50),
                           department VARCHAR(50),
                           salary NUMERIC(10,2),
                           hire_date DATE,
                           manager_id INTEGER,
                           email VARCHAR(100)
);
CREATE TABLE projects (
                          project_id SERIAL PRIMARY KEY,
                          project_name VARCHAR(100),
                          budget NUMERIC(12,2),
                          start_date DATE,
                          end_date DATE,
                          status VARCHAR(20)
);
CREATE TABLE assignments (
                             assignment_id SERIAL PRIMARY KEY,
                             employee_id INTEGER REFERENCES employees(employee_id),
                             project_id INTEGER REFERENCES projects(project_id),
                             hours_worked NUMERIC(5,1),
                             assignment_date DATE
);
--insert sample data
INSERT INTO employees (first_name, last_name, department,
                       salary, hire_date, manager_id, email) VALUES
                                                                 ('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
                                                                  'john.smith@company.com'),
                                                                 ('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
                                                                  'sarah.j@company.com'),
                                                                 ('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
                                                                  'mbrown@company.com'),
                                                                 ('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
                                                                  'emily.davis@company.com'),
                                                                 ('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
                                                                 ('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
                                                                  'lisa.a@company.com');

INSERT INTO projects (project_name, budget, start_date,
                      end_date, status) VALUES
                                            ('Website Redesign', 150000, '2024-01-01', '2024-06-30',
                                             'Active'),
                                            ('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
                                             'Active'),
                                            ('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
                                             'Completed'),
                                            ('Database Migration', 120000, '2024-01-10', NULL, 'Active');

INSERT INTO assignments (employee_id, project_id,
                         hours_worked, assignment_date) VALUES
                                                            (1, 1, 120.5, '2024-01-15'),
                                                            (2, 1, 95.0, '2024-01-20'),
                                                            (1, 4, 80.0, '2024-02-01'),
                                                            (3, 3, 60.0, '2024-03-05'),
                                                            (5, 2, 110.0, '2024-02-20'),
                                                            (6, 3, 75.5, '2024-03-10');

--Part1: Basic Select Queries
--task 1.1
select first_name || ' ' || last_name as full_name, employees.department,salary from employees;
--task1.2
select distinct department from employees;
--task1.3
select project_name,budget,
case
    when budget>150000 then 'Large'
    when budget between 100000 and 150000 then 'Medium'
    else 'Small'
end as budget_category
from projects;
--task1.4
select first_name || ' ' || last_name as full_name,
       coalesce(email,'No email provided') as email
from employees;
--Part 2: WHERE Clause and Comparison Operators
--task2.1
select * from employees where hire_date> '2020-01-01';
--task2.2
select * from employees where salary between 60000 and 70000;
--task2.3
select * from employees where last_name like 'S%' or last_name like 'J%';
--task2.4
select * from employees where manager_id is not null and department='IT';
--Part 3: String and Mathematical Functions
--task 3.1
select
    upper(first_name || ' ' || last_name) as full_name,
    length(last_name) as last_name_length,
    substring(email, 1, 3) as email_substring
from employees;
--task 3.2
select
    first_name || ' ' || last_name as full_name,
    salary * 12 as annual_salary,
    round(salary/12,2) as monthly_salary,
    round(salary*0.10,2) as raise_amount
from employees;
--task 3.3
select format('Project:%%s-budget:$%%.2f-Status:%s',project_name,budget,status) as project_detail
from projects;
--task3.4
select
    first_name || ' ' || last_name as full_name,
    extract(year from age(hire_date)) as years_company
from employees;
--Part 4: Aggregate Functions and GROUP BY
--task 4.1
select department ,avg(salary) as average_salary
from employees
group by department;
--task4.2
select project_name,sum(hours_worked) as total_hours_worked
from projects
join assignments a on projects.project_id = a.project_id
group by project_name;
--task4.3
select department, count(*) as num_employees
from employees
group by department
having count(*) > 1;
--task4.4
select
    max(salary) as max_salary,
    min(salary) as min_salary,
    sum(salary) as sum_salary
from employees;
--Part 5: Set Operations
--task 5.1
select employee_id, first_name || ' ' || last_name as full_name,salary
from employees
where salary>65000
union
select employee_id, first_name || ' ' || last_name as full_name,salary
from employees
where hire_date>'2020-01-01';
--task5.2
select employee_id ,first_name || ' ' || last_name as full_name,salary
from employees
where department='IT'
intersect
select employee_id ,first_name || ' ' || last_name as full_name,salary
from employees
where salary >65000;
--task 5.3
select s.employee_id, s.first_name || ' ' || s.last_name as full_name
from employees s
except
select e.employee_id, e.first_name || ' ' || e.last_name as full_name
from employees e
join assignments a on e.employee_id = a.employee_id;
--Part 6: Subqueries
--task 6.1
select employee_id, first_name || ' ' || last_name as full_name
from employees e
where exists(
    select 1 from assignments where e.employee_id= employee_id
);
--task 6.2
select first_name || ' ' || last_name as full_name
from employees
where employee_id in (
    select employee_id
    from assignments
    join projects p on assignments.project_id = p.project_id
    where status='Active'
    );
--task6.3
select first_name || ' ' || last_name as full_name
from employees
where salary >any(
    select salary from employees where department='Sales'
    );
--Part 7: Complex Queries
--task 7.1
select first_name || ' ' || last_name as full_name,
       department,
       avg(a.hours_worked)as avg_hours_worked,
       rank() over(partition by department order by salary desc) as rank_within_department
from employees
join assignments a on employees.employee_id = a.employee_id
group by first_name, last_name, department;
--task7.2
select p.project_name,
       sum(a.hours_worked) as total_hours,
       count(distinct a.employee_id) as num_employees
from projects p
join assignments a on p.project_id = a.project_id
group by project_name
having sum(hours_worked) > 150;
--task7.3
select department ,
       count(*) as total_employee,
       avg(salary) as average_salary,
       greatest(first_name || ' ' || last_name) as highest_paid
from employees
group by first_name, last_name,department ;

