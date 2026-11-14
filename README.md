# School System Database (PostgreSQL)

A relational database project for a fictional college, implemented using PostgreSQL. The database is based on the *Tiny College* implementation-ready UML class diagram and includes tables, relationships, constraints, sample data, and example SQL queries.

## Project Files

| File | Description |
|---|---|
| `school_system.sql` | Creates the database schema, tables, constraints, indexes, and sample data. |
| `school_system_queries.sql` | Contains 10 example SQL queries. |

## Requirements
- PostgreSQL 12 or newer (tested on PostgreSQL 16).
- pgAdmin 4 or psql.

## Getting Started

1. Create a database named `school_system`.
2. Open pgAdmin and select the Query Tool.
3. Run `school_system.sql` to create and populate the database.
4. Run queries from `school_system_queries.sql` to explore the data.

**Important:** The SQL script recreates the `public` schema using `DROP SCHEMA CASCADE`. Run it only in a dedicated or empty database.

## Database Structure

The database contains 10 tables:

- Building and Room
- School and Department
- Professor
- Course and Class
- Semester
- Student and Enroll

It uses primary keys, foreign keys, composite keys, constraints, and indexes to maintain data integrity.

## Example Queries

The project includes 10 queries covering:

- INNER JOIN and LEFT JOIN
- Multi-table JOINs
- GROUP BY and aggregate functions
- Filtering and sorting
- Handling NULL values
- Department leadership and student enrollment analysis

## Technologies
- PostgreSQL
- SQL
- pgAdmin 4

## Source
Based on the *Tiny College* implementation-ready UML class diagram (Figure 4.37) from a database design textbook.
