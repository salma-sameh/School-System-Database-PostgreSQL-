-- ============================================================
-- Tiny College - 10 simple queries
-- Run AFTER tiny_college.sql, in the same database.
-- In pgAdmin, select one query at a time and press F5.
-- ============================================================

-- 1. List all professors with their department name
SELECT p.prof_num, p.prof_fname, p.prof_lname, d.dept_name
FROM professor p
JOIN department d ON d.dept_code = p.dept_code
ORDER BY p.prof_lname;

-- 2. List all students with their advisor's name
SELECT s.stu_num, s.stu_fname, s.stu_lname,
       p.prof_fname || ' ' || p.prof_lname AS advisor
FROM student s
LEFT JOIN professor p ON p.prof_num = s.prof_num
ORDER BY s.stu_lname;

-- 3. Class schedule: course, section, time, professor, room, building, semester
SELECT c.class_code, co.crs_title, c.class_section, c.class_time,
       p.prof_lname AS professor, r.room_code, b.bldg_name,
       s.semester_term || ' ' || s.semester_year AS semester
FROM class c
JOIN course   co ON co.crs_code      = c.crs_code
JOIN professor p ON p.prof_num       = c.prof_num
JOIN room      r ON r.room_code      = c.room_code
JOIN building  b ON b.bldg_code      = r.bldg_code
JOIN semester  s ON s.semester_code  = c.semester_code
ORDER BY c.class_code;

-- 4. Number of students in each department
SELECT d.dept_name, COUNT(s.stu_num) AS students
FROM department d
LEFT JOIN student s ON s.dept_code = d.dept_code
GROUP BY d.dept_name
ORDER BY students DESC, d.dept_name;

-- 5. Number of enrolled students in each class
SELECT c.class_code, co.crs_title, COUNT(e.stu_num) AS enrolled
FROM class c
JOIN course co ON co.crs_code = c.crs_code
LEFT JOIN enroll e ON e.class_code = c.class_code
GROUP BY c.class_code, co.crs_title
ORDER BY c.class_code;

-- 6. Students who got an A or A- (with the course)
SELECT s.stu_fname, s.stu_lname, co.crs_title, e.enroll_grade
FROM enroll e
JOIN student s  ON s.stu_num    = e.stu_num
JOIN class c    ON c.class_code = e.class_code
JOIN course co  ON co.crs_code  = c.crs_code
WHERE e.enroll_grade IN ('A', 'A-')
ORDER BY s.stu_lname;

-- 7. Courses with 3 or more credits, highest credits first
SELECT crs_code, crs_title, crs_credit
FROM course
WHERE crs_credit >= 3
ORDER BY crs_credit DESC, crs_title;

-- 8. All rooms with their building name and location
SELECT r.room_code, r.room_type, b.bldg_name, b.bldg_location
FROM room r
JOIN building b ON b.bldg_code = r.bldg_code
ORDER BY b.bldg_name, r.room_code;

-- 9. Each department with its school, chair and the school's dean
SELECT d.dept_name,
       sc.school_name,
       chair.prof_lname AS dept_chair,
       dean.prof_lname  AS school_dean
FROM department d
JOIN school sc          ON sc.school_code = d.school_code
LEFT JOIN professor chair ON chair.prof_num = d.prof_num
LEFT JOIN professor dean  ON dean.prof_num  = sc.prof_num
ORDER BY sc.school_name, d.dept_name;

-- 10. Enrollments that do not have a grade yet
SELECT s.stu_fname, s.stu_lname, co.crs_title, e.enroll_date
FROM enroll e
JOIN student s  ON s.stu_num    = e.stu_num
JOIN class c    ON c.class_code = e.class_code
JOIN course co  ON co.crs_code  = c.crs_code
WHERE e.enroll_grade IS NULL
ORDER BY e.enroll_date;
