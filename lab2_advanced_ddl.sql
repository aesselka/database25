--Task1
CREATE DATABASE university_main
    OWNER CURRENT_USER
    TEMPLATE template0
    ENCODING 'UTF8';
CREATE DATABASE university_archive
    CONNECTION LIMIT 50
    TEMPLATE template0;
CREATE DATABASE university_test
    IS_TEMPLATE TRUE
    CONNECTION LIMIT 10;

CREATE TABLESPACE student_data
    LOCATION '/Users/aesselka/data/courses';
CREATE TABLESPACE course_data
    LOCATION '/Users/aesselka/data/courses';
CREATE DATABASE university_distributed
    TEMPLATE template0
    TABLESPACE student_data
    ENCODING 'LATIN9';
-- Part 2: Complex Table Creation
-- Task 2.1: University Management System
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa DECIMAL(4,2),
    graduation_year SMALLINT
);

CREATE TABLE professors (
                            professors_id SERIAL PRIMARY KEY,
                            first_name VARCHAR(50),
                            last_name VARCHAR(50),
                            email VARCHAR(100),
                            office_number VARCHAR(20),
                            hire_date DATE,
                            salary DECIMAL(12,2),
                            is_tenured BOOLEAN,
                            years_experience INTEGER
);
CREATE TABLE courses (
                         course_id SERIAL PRIMARY KEY,
                         course_code CHAR(8),
                         course_title VARCHAR(100),
                         description TEXT,
                         credits SMALLINT,
                         max_enrollment INTEGER,
                         course_fee DECIMAL(4,2),
                         is_online BOOLEAN,
                         created_at TIMESTAMP WITHOUT TIME ZONE
);
--Task 2.2: Time-based and Specialized Tables
CREATE TABLE сlass_schedule (
                                schedule_id SERIAL PRIMARY KEY,
                                course_id INTEGER,
                                professor_id INTEGER,
                                classroom VARCHAR(20),
                                class_date DATE,
                                start_time TIMESTAMP WITHOUT TIME ZONE,
                                end_time timestamp without time zone,
                                duration interval
);
CREATE TABLE student_records (
                                 record_id SERIAL PRIMARY KEY,
                                 student_id INTEGER,
                                 course_id INTEGER,
                                 semester VARCHAR(20),
                                 year INTEGER,
                                 grade CHAR(2),
                                 attendance_percentage decimal(5,1),
                                 submission_timestamp TIMESTAMP WITHOUT TIME ZONE,
                                 last_updated timestamp without time zone
);
--Part 3: Advanced ALTER TABLE Operations
--Task 3.1: Modifying Existing Tables
--Modify	students	table:
Alter table students
    add column middle_name VARCHAR(30);
Alter table students
    add column student_status VARCHAR(20);
Alter table students
    alter column phone type VARCHAR(20);
Alter table students
    alter column student_status set default 'ACTIVE';
Alter table students
    alter column gpa set default 0.00;
--Modify	professors	table:
Alter table professors
    add column department_code char(5);
Alter table professors
    add column research_area text;
Alter table professors
    alter column years_experience type smallint;
Alter table professors
    alter column is_tenured set default false;
Alter table professors
    add column last_promotion_date date;
-- check
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'professors';
--Modify	courses	table:
alter table courses
    add column prerequisite_level INTEGER;
alter table courses
    add column difficulty_level smallint;
alter table courses
    alter column course_code type varchar(10);
alter table courses
    alter column credits set default 3;
alter table courses
    add column lab_required boolean default false;
--Task 3.2: Column Management Operations
--For	class_schedule	table:
ALTER class_schedule
    add column room_capacity integer;
ALTER TABLE class_schedule
    drop COLUMN duration;
ALTER TABLE class_schedule
    add COLUMN session_type varchar(15);
ALTER TABLE class_schedule
    alter COLUMN classroom type varchar(30);
ALTER TABLE class_schedule
    add COLUMN equipment_needed text;
--For	student_records	table:
ALTER TABLE student_records
    add COLUMN extra_credit_points decimal(5,1);
ALTER TABLE student_records
    alter COLUMN grade type varchar(5);
ALTER TABLE student_records
    alter COLUMN extra_credit_points set  default 0.0;
ALTER TABLE student_records
    add COLUMN final_exam_date DATE;
ALTER TABLE student_records
    drop COLUMN last_updated;
--Part 4: Table Relationships and Management
--Task 4.1: Additional Supporting Tables
create table departments(
                            department_id serial primary key ,
                            department_name varchar(100),
                            department_code char(5),
                            building varchar(50),
                            phone varchar(15),
                            budget decimal(12,2),
                            established_year integer
);
create table library_books(
                              book_id serial primary key ,
                              isbn char(13),
                              title varchar(200),
                              author varchar(100),
                              publisher varchar(100),
                              publication_date date,
                              price decimal(4,2),
                              is_available boolean,
                              acquisition_timestamp timestamp without time zone
);
create table student_book_loans(
                                   loan_id serial primary key ,
                                   student_id integer,
                                   book_id integer,
                                   loan_date date,
                                   due_date date,
                                   return_date date,
                                   fine_amount decimal(4,2),
                                   loan_status varchar(20)
);
--Task 4.2: Table Modifications for Integration
--1 Add	foreign	key	columns
alter table professors
    add column department_id integer;
alter table students
    add column advisor_id integer;
alter table courses
    add column department_id integer;
--2 create lookup tables
create table grade_scale(
                            grade_id serial primary key ,
                            letter_grade char(2),
                            min_percentage decimal(5,1),
                            max_percentage decimal(5,1),
                            gpa_points decimal(4,2)
);
create table semester_calendar(
                                  semester_id serial primary key ,
                                  semester_name varchar(20),
                                  academic_year integer,
                                  start_date date,
                                  end_date date,
                                  registration_deadline timestamp with time zone,
                                  is_current boolean
);
-- Part 5: Table Deletion and Cleanup
-- Task 5.1: Conditional Table Operations
--1
drop table if exists student_book_loans;
drop table if exists library_books;
drop table if exists grade_scale;
--2
create table grade_scale(
                            grade_id serial primary key ,
                            letter_grade char(2),
                            min_percentage decimal(5,1),
                            max_percentage decimal(5,1),
                            gpa_points decimal(4,2),
                            description  text
);
--3
drop table if exists semester_calendar cascade;
create table semester_calendar(
                                  semester_id serial primary key ,
                                  semester_name varchar(20),
                                  academic_year integer,
                                  start_date date,
                                  end_date date,
                                  registration_deadline timestamp with time zone,
                                  is_current boolean
);
--Task 5.2: Database Cleanup
drop database if exists university_test;
drop database if exists university_distributed;
create database university_backup TEMPLATE university_main;
