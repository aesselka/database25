drop table if exists products cascade;
-- task1.1 Basic CHECK Constraint
create table employees(
                          employee_id serial primary key,
                          first_name text,
                          last_name text,
                          age integer check(age between 18 and 65),
                          salary numeric check(salary>0),
                          hire_data date,
                          manager_id integer,
                          email text
);
--Task 1.2: Named CHECK Constraint
create table products_catalog(
                                 product_id serial primary key,
                                 product_name text,
                                 regular_price numeric check(regular_price>0),
                                 discount_price numeric check(discount_price>0 and discount_price<regular_price),
                                 constraint valid_discount check(discount_price>0 and discount_price<regular_price)
);
--Task 1.3: Multiple Column CHECK
create table bookings(
                         booking_id serial primary key,
                         check_in_date date,
                         check_out_date date check(check_in_date<check_out_date),
                         num_guests integer check (num_guests between 1 and 10)
);
--Task 1.4: Testing CHECK Constraints valid data
insert into employees(employee_id,first_name,last_name,age,salary,hire_data,manager_id,email)
values (1,'Assel','Bazhikey',30,5000,'2025-04-03',null,'a.bazhikey@gmail.com');
insert into products_catalog (product_id, product_name, regular_price, discount_price)
values (1, 'Laptop', 1000, 800);
insert into bookings(booking_id,check_in_date,check_out_date,num_guests)
values(1,'2025-03-05','2025-05-05',2);
--2 invalid data
insert into employees (employee_id, first_name, last_name, age, salary,hire_data,manager_id,email)
values (2, 'Egor', 'Fedorov', 14, -800,'2025-06-07',null,'egor@gmail.com');
insert into products_catalog (product_id, product_name, regular_price, discount_price)
values (2, 'Magnit', -11, 900);
insert into bookings (booking_id, check_in_date, check_out_date, num_guests)
values (2, '2025-10-15', '2025-10-10', 15);
--Part 2: NOT NULL Constraints
--Task 2.1: NOT NULL Implementation
create table customers (
                           customer_id serial primary key,
                           email text not null,
                           phonr text,
                           registration_date date not null
);
--Task 2.2: Combining Constraints
create table inventory(
                          item_id serial primary key ,
                          item_name text not null,
                          quantity integer not null check(quantity >=0),
                          unit_price numeric not null check(unit_price>0),
                          last_updated timestamp not null
);
--Task 2.3: Testing NOT NULL
insert into customers(customer_id,email,phonr,registration_date)
values (1,'customer@example.com','123-123-2321','2025-09-08');
--invalid
insert into customers (customer_id, email, phonr, registration_date)
values (2, NULL, '987-654-3210', '2022-06-15');
--Part 3: UNIQUE Constraints
--Task 3.1: Single Column UNIQUE
create table users(
                      user_id serial primary key ,
                      username text unique ,
                      email text unique ,
                      created_at timestamp
);
--Task 3.2: Multi-Column UNIQUE
create table course_enrollment(
                                  enrollment_id serial primary key ,
                                  student_id integer,
                                  course_code text,
                                  semester text,
                                  unique (student_id, course_code, semester)
);
--Task 3.3: Named UNIQUE Constraints
alter table users
    add constraint unique_username unique (username);
alter table users
    add constraint unique_email unique (email);
--. Test by trying to insert duplicate usernames and emails
insert into users(user_id,username,email,created_at)
values(1, 'Assel', 'assel@example.com', CURRENT_TIMESTAMP);
--error
insert into users(user_id,username,email,created_at)
values(2, 'Assel', 'assel@example.com', CURRENT_TIMESTAMP);
--Part 4: PRIMARY KEY Constraints
create table departments(
                            dept_id serial primary key ,
                            dept_name text not null,
                            location text
);
--Insert at least 3 departments and attempt to:
-- Вставляем 3 департамента
insert into departments (dept_id, dept_name, location)
values
    (1, 'Sales', 'New York'),
    (2, 'Marketing', 'Los Angeles'),
    (3, 'IT', 'San Francisco');

--Insert a duplicate dept_id
insert into departments(dept_id,dept_name, location)
values(1,'Finance','Chicago');
--Insert a NULL dept_id
insert into departments(dept_id,dept_name, location)
values(null,'Opp','New York');
--Task 4.2: Composite Primary Key
create table student_courses(
                                student_id integer ,
                                course_id integer,
                                enrollment_date date,
                                grade text,
                                primary key (student_id,course_id)
);
--Task 4.3: Comparison Exercise
-- The difference between UNIQUE and PRIMARY KEY
-- 1.PRIMARY KEY:
-- Uniqueness and Not Null:PRIMARY KEY constraint guarantees that all values are unique and cannot be NULL.
-- One per Table: A table can have only one primary key
-- UNIQUE column can be NULL (although in PostgreSQL, only one NULL value is allowed in a column with a UNIQUE constraint).
--2. Single
--A single column uniquely identifies each record (e.g., ID).
--Composite:A combination of student_id and course_id to uniquely identify a student-course enrollment.
--3.There can only be one primary key per table, as each record must be uniquely identified by one method.
--Multiple unique constraints unique ensures uniqueness, but cannot be the primary identifier.
-- Multiple columns can also have a unique constraint
--Part 5: FOREIGN KEY Constraints
--Task 5.1: Basic Foreign Key
create table employees_dept(
                               emp_id integer primary key ,
                               emp_name text not null,
                               dept_id integer,
                               hire_date date,
                               foreign key (dept_id) references departments(dept_id)
);
--Inserting employees with valid dept_id
insert into employees_dept(emp_id, emp_name, dept_id, hire_date)
values (1,'Assel',1,'2025-03-10');
insert into employees_dept(emp_id, emp_name, dept_id, hire_date)
values(2,'Jane',2,'2025-04-05');
--Task 5.2: Multiple Foreign Keys
create table authors
(
    author_id   integer primary key,
    author_name text not null,
    country     text
);
create table publishers(
                           publisher_id integer primary key,
                           publisher_name text not null,
                           city text
);
create table books(
                      book_id integer primary key ,
                      title text not null,
                      author_id integer,
                      publisher_id integer,
                      publisher_year integer,
                      isbn text unique ,
                      foreign key (author_id) references authors(author_id),
                      foreign key (publisher_id) references publishers(publisher_id)
);
insert into authors (author_id, author_name, country)
values (1, 'J.K. Rowling', 'United Kingdom');

insert into authors (author_id, author_name, country)
values (2, 'George Orwell', 'United Kingdom');

insert into publishers (publisher_id, publisher_name, city)
values (1, 'Bloomsbury', 'London');

insert into publishers (publisher_id, publisher_name, city)
values (2, 'Secker & Warburg', 'London');

insert into books (book_id, title, author_id, publisher_id, publisher_year, isbn)
values (1, 'Harry Potter and the Philosopher', 1, 1, 1997, '9780747532699');

insert into books (book_id, title, author_id, publisher_id, publisher_year, isbn)
values (2, 'Nineteen Eighty-Four', 2, 2, 1949, '9780451524935');
--Task 5.3: ON DELETE Options
-- task 5.3: creating categories and products_fk tables with delete constraints
create table categories (
                            category_id integer primary key,
                            category_name text not null
);
create table products_fk (
                             product_id integer primary key,
                             product_name text not null,
                             category_id integer,
                             foreign key (category_id) references categories on delete restrict
);
create table orders (
                        order_id integer primary key,
                        order_date date not null
);
create table order_items (
                             item_id integer primary key,
                             order_id integer,
                             product_id integer,
                             quantity integer check (quantity > 0),
                             foreign key (order_id) references orders on delete cascade,
                             foreign key (product_id) references products_fk
);
--Try to delete a category that has products (should fail with RESTRICT)
insert into categories(category_id, category_name)
values (1,'Electronics');
insert into products_fk(product_id, product_name, category_id)
values(1,'Smart',1);
delete from categories where category_id=1;
--Delete an order and observe that order_items are automatically deleted (CASCADE)
insert into orders (order_id, order_date)
values (1, '2025-10-14');
insert into order_items (item_id, order_id, product_id, quantity)
values (1, 1, 1, 2);

delete from orders where order_id = 1;
--Part 6: Practical Application
--Task 6.1: E-commerce Database Design
create table customers1 (
                            customer_id serial primary key,
                            email text not null,
                            phonr text,
                            registration_date date not null
);
create table products1(
                          product_id serial primary key ,
                          name text,
                          description text,
                          price integer,
                          stock_quantity integer
);
create table orders1(
                        order_id serial primary key ,
                        order_date date,
                        total_amount integer,
                        status integer
);
create table order_details(
                              order_detail_id serial primary key ,
                              order_id integer,
                              foreign key (order_id) references orders(order_id),
                              product_id integer,
                              foreign key (product_id) references products1(product_id),
                              quantity integer,
                              unit_price integer
);
--. At least 5 sample records per table
-- Insert sample customers
insert into customers (name, email, phone, registration_date)
values
    ('Assel', 'assel@example.com', '1234567890', '2023-01-15'),
    ('Anel', 'anel@example.com', '0987654321', '2023-02-20'),
    ('Dariya', 'dariya@example.com', '1112233445', '2023-03-25'),
    ('George', 'george@example.com', '5556677889', '2023-04-30'),
    ('Charlie', 'charlie@example.com', '2223334445', '2023-05-10');

insert into products (name, description, price, stock_quantity)
values
    ('trt', 'A smooth wireless mouse', 25.99, 50),
    ('Keyboard', 'A mechanical keyboard', 55.00, 30),
    ('Laptop', 'A high-performance laptop', 1200.00, 15),
    ('Monitor', '24-inch LED monitor', 200.00, 25),
    ('USB Cable', 'A high-speed USB cable', 10.00, 100);

insert into orders (customer_id, order_date, total_amount, status)
values
    (1, '2023-05-15', 200.00, 'shipped'),
    (2, '2023-06-10', 1200.00, 'pending'),
    (3, '2023-07-20', 55.00, 'delivered'),
    (4, '2023-08-25', 25.99, 'processing'),
    (5, '2023-09-10', 300.00, 'shipped');


insert into order_details (order_id, product_id, quantity, unit_price)
values
    (1, 1, 2, 25.99),
    (1, 2, 1, 55.00),
    (2, 3, 1, 1200.00),
    (3, 4, 1, 200.00),
    (4, 5, 3, 10.00);
--Test queries demonstrating that all constraints work correctly
--valid
insert into products (name, description, price, stock_quantity)
values ('Smartphone', 'Latest smartphone with amazing features', 699.99, 10);
--invalid
insert into products (name, description, price, stock_quantity)
values ('Faulty Product', 'A product with incorrect pricing', -50.00, 5);

