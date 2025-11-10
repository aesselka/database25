drop table if exists projects cascade;
--Part 1: Database Setup (Use Lab 6 Tables)
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
--Part 2: Creating Basic Views
--Exercise 2.1: Simple View Creation
create view employee_details as
select e.emp_name,e.salary,d.dept_name,d.location
from employees e
join departments d on e.dept_id = d.dept_id;
--Exercise 2.2: View with Aggregation
create view dept_statistics as
select d.dept_name, count(e.emp_id) as emp_count,avg(e.salary) as avg_salary,
       max(e.salary) as max_salary,min(e.salary) as min_salary
from departments d
left join employees e on d.dept_id = e.dept_id
group by d.dept_name;
--Exercise 2.3: View with Multiple Joins
create view project_overview as
select p.project_name, p.budget,d.dept_name,d.location, count(e.emp_id) as team_size
from projects p
left join departments d on p.dept_id = d.dept_id
left join employees e on d.dept_id = e.dept_id
group by p.project_name, p.budget, d.dept_name, d.location ;
--Exercise 2.4: View with Filtering
create view high_earners as
    select e.emp_name,e.salary,d.dept_name
from employees e
join departments d on e.dept_id = d.dept_id
where e.salary>55.000;
--Part 3: Modifying and Managing Views
--Exercise 3.1: Replace a View
create or replace view employee_details as
select e.emp_name ,e.salary,d.dept_name,d.location,
    case
        when e.salary > 60000 then 'high'
        when e.salary > 50000 then 'medium'
        else 'standard'
    end as salary_grade
from employees e
join departments d using(dept_id);
--Exercise 3.2: Rename a View
alter view high_earners rename to top_performers;
--Exercise 3.3: Drop a View
create view temp_view as
select emp_id, salary
from employees
where salary<50000;
drop view temp_view;
--Part 4: Updatable Views
--Exercise 4.1: Create an Updatable View
create view employee_salaries as
select emp_id, emp_name, dept_id, salary
from employees;
---Exercise 4.2: Update Through a View
update employee_salaries
set salary = 52000
where emp_name = 'john smith';
--Exercise 4.3: Insert Through a View
insert into employee_salaries (emp_id, emp_name, dept_id, salary)
values (6, 'alice johnson', 102, 58000);
--Exercise 4.4: View with CHECK OPTION
create view it_employees as
    select dept_id,emp_id,emp_name,salary
from employees
where dept_id=101
with local check option;
-- This should fail
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
--Part 5: Materialized Views
--Exercise 5.1: Create a Materialized View
create materialized view dept_summary_mv as
    select d.dept_id,d.dept_name,count(e.emp_id),
           coalesce(count(e.salary),0) as total_salaries,
           count(p.project_id) as total_projects,
           coalesce(count(p.budget),0) as total_pro_budget
from departments d
left join projects p on d.dept_id = p.dept_id
left join employees e on d.dept_id = e.dept_id
group by d.dept_id, d.dept_name
with data;
--Exercise 5.2: Refresh Materialized View
insert into employees(emp_id,emp_name,dept_id,salary)
values(8,'charlie brown',101,540000);
select * from dept_summary_mv;
refresh materialized view dept_summary_mv;
select * from dept_summary_mv;
--Exercise 5.3: Concurrent Refresh
create unique index dept_summary_mv_idx on dept_summary_mv (dept_id);
refresh materialized view concurrently dept_summary_mv;
--Exercise 5.4: Materialized View with NO DATA
create materialized view projects_stats_nv as
    select p.project_name,p.budget,d.dept_name,count(e.emp_id) as emp_count
from projects p
left join departments d on p.dept_id = d.dept_id
left join employees e on d.dept_id = e.dept_id
group by p.project_name, p.budget, d.dept_name
with no data;
--Part 6: Database Roles
--Exercise 6.1: Create Basic Roles
create role analyst;
create role data_viewer login password 'viewer123';
create user report_user with password 'report456';
--Exercise 6.2: Role with Specific Attributes
create role db_creator with createdb login password 'creator789';
create role user_manager with createrole  login password 'manager101';
create role admin_user with superuser login  password 'admin999';
--Exercise 6.3: Grant Privileges to Roles
grant select on employees,departments,projects to analyst;
grant all privileges on employee_details to data_viewer;
grant select ,insert on employees to report_user;
--Exercise 6.4: Create Group R oles
create role hr_team;
create role finance_team;
create role it_team;
create user hr_user1 password 'hr001';
create user hr_user2 password 'hr002';
create user finance_user1 password 'fin001';
grant hr_user1,hr_user2 to hr_team;
grant finance_user1 to finance_team;
grant select,update on employees to hr_team;
grant select on dept_statistics to finance_team;
--Exercise 6.5: Revoke Privileges
revoke update on employees from hr_team;
revoke hr_team from h2_user2;
revoke all privileges on employee_details from data_viewer;
--Exercise 6.6: Modify Role Attributes
alter role analyst login password 'analyst123';
alter role user_manager with superuser;
alter role analyst with password null;
alter role data_viewer with connection limit 5;
--Part 7: Advanced Role Management
--Exercise 7.1: Role Hierarchies
create role read_only;
grant select on all tables in schema public to read_only;
create role junior_analyst with password 'junior123';
create role senior_analyst with password 'senior123';
grant read_only to junior_analyst,senior_analyst;
grant insert,update on employees to senior_analyst;
--Exercise 7.2: Object Ownership
create role project_manager with login password 'pm123';
alter view dept_statistics owner to project_manager;
alter table projects owner to project_manager;
--Exercise 7.3: Reassign and Drop Roles
create role temp_owner with login;
create  table temp_table (id int);
alter table temp_table owner to temp_owner;
reassign owned by temp_owner to postgres;
drop owned by temp_owner;
drop role temp_owner;
--Exercise 7.4: Row-Level Security with Views
create view hr_employee_view as
    select * from employees
        where dept_id=102;
grant select on hr_employee_view to hr_team;
create view finance_employee_view as
    select emp_id,emp_name,salary from employees;
grant select on finance_employee_view to finance_team;
--Part 8: Practical Scenarios
--Exercise 8.1: Department Dashboard View
create view dept_dashboard as
    select d.dept_name,d.location,
           round(avg(e.salary),0) as average_salary,
           count(p.project_id) as count_project,
           count(budget) as total_budget,
           round(coalesce(sum(p.budget)/nullif(count(e.emp_id),0),0),2) as budget_per_employee
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
group by d.dept_name, d.location;
--Exercise 8.2: Audit View
alter table projects add column created_date timestamp default current_timestamp;
create view high_budget_projects as
    select project_name,budget
from projects
where budget>75000;
create view high_budget_projectss as
select project_name,budget,dept_name,created_date,
case
    when budget>150000 then 'Critical Review Required'
    when budget>10000 then 'Management Approval Needed'
    else 'Standard Process'
end as approval_status
from projects
left join departments d on projects.dept_id = d.dept_id
where budget>75000;
--Exercise 8.3: Create Access Control System
--Level 1 - Viewer Role:
create role viewer_role;
grant select on all tables in schema public to viewer_role;
grant select on all views in schema public to viewer_role;
--Level 2 - Entry Role:
create role entry_role;
grant viewer_role to entry_role;
grant insert on employees,projects to entry_role;
--Level 3 - Analyst Role:
create role analyst_role;
grant entry_role to analyst_role;
grant update on employees,projects to analyst_role;
--Level 4 - Manager Role:
create role manager_role;
grant analyst_role to manager_role;
grant delete on employees,projects to manager_role;
--create users
create user alice with password 'alice123';
create user bob with password 'bob123';
create user charlie with password 'charlie123';
grant viewer_role to alice;
grant analyst_role to bob;
grant manager_role to charlie;


