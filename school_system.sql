-- ------------------------------------------------------------
-- 1. Tables (circular foreign keys are added later with ALTER)
-- ------------------------------------------------------------
CREATE TABLE building (
    bldg_code     VARCHAR(10)  PRIMARY KEY,
    bldg_name     VARCHAR(50)  NOT NULL,
    bldg_location VARCHAR(50)
);

CREATE TABLE room (
    room_code VARCHAR(10) PRIMARY KEY,
    room_type VARCHAR(50),
    bldg_code VARCHAR(10) NOT NULL
        REFERENCES building (bldg_code) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE school (
    school_code VARCHAR(10) PRIMARY KEY,
    school_name VARCHAR(80) NOT NULL UNIQUE,
    prof_num    INTEGER UNIQUE            -- dean (FK added below)
);

CREATE TABLE department (
    dept_code   VARCHAR(10) PRIMARY KEY,
    dept_name   VARCHAR(80) NOT NULL UNIQUE,
    school_code VARCHAR(10) NOT NULL
        REFERENCES school (school_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    prof_num    INTEGER UNIQUE            -- chair (FK added below)
);

CREATE TABLE professor (
    prof_num       INTEGER PRIMARY KEY,
    dept_code      VARCHAR(10) NOT NULL
        REFERENCES department (dept_code) ON UPDATE CASCADE ON DELETE RESTRICT
        DEFERRABLE INITIALLY DEFERRED,
    prof_specialty VARCHAR(50),
    prof_rank      VARCHAR(30),
    prof_lname     VARCHAR(30) NOT NULL,
    prof_fname     VARCHAR(30) NOT NULL,
    prof_initial   CHAR(1),
    prof_email     VARCHAR(100) UNIQUE
);

-- Circular references: dean of a school, chair of a department
ALTER TABLE school
    ADD CONSTRAINT fk_school_dean
    FOREIGN KEY (prof_num) REFERENCES professor (prof_num)
    ON UPDATE CASCADE ON DELETE SET NULL
    DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE department
    ADD CONSTRAINT fk_department_chair
    FOREIGN KEY (prof_num) REFERENCES professor (prof_num)
    ON UPDATE CASCADE ON DELETE SET NULL
    DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE course (
    crs_code        VARCHAR(10) PRIMARY KEY,
    dept_code       VARCHAR(10) NOT NULL
        REFERENCES department (dept_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    crs_title       VARCHAR(80) NOT NULL,
    crs_description TEXT,
    crs_credit      NUMERIC(3,1) CHECK (crs_credit > 0)
);

CREATE TABLE semester (
    semester_code       VARCHAR(10) PRIMARY KEY,
    semester_year       INTEGER NOT NULL CHECK (semester_year BETWEEN 1900 AND 2100),
    semester_term       VARCHAR(10) NOT NULL
        CHECK (semester_term IN ('Fall', 'Spring', 'Summer', 'Winter')),
    semester_start_date DATE NOT NULL,
    semester_end_date   DATE NOT NULL,
    CHECK (semester_end_date > semester_start_date)
);

CREATE TABLE class (
    class_code    INTEGER PRIMARY KEY,
    class_section VARCHAR(5) NOT NULL,
    class_time    VARCHAR(30),
    crs_code      VARCHAR(10) NOT NULL
        REFERENCES course (crs_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    prof_num      INTEGER NOT NULL
        REFERENCES professor (prof_num) ON UPDATE CASCADE ON DELETE RESTRICT,
    room_code     VARCHAR(10) NOT NULL
        REFERENCES room (room_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    semester_code VARCHAR(10) NOT NULL
        REFERENCES semester (semester_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    UNIQUE (crs_code, class_section, semester_code)
);

CREATE TABLE student (
    stu_num     INTEGER PRIMARY KEY,
    dept_code   VARCHAR(10) NOT NULL
        REFERENCES department (dept_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    stu_lname   VARCHAR(30) NOT NULL,
    stu_fname   VARCHAR(30) NOT NULL,
    stu_initial CHAR(1),
    stu_email   VARCHAR(100) UNIQUE,
    prof_num    INTEGER                   -- advisor
        REFERENCES professor (prof_num) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE enroll (
    class_code   INTEGER NOT NULL
        REFERENCES class (class_code) ON UPDATE CASCADE ON DELETE CASCADE,
    stu_num      INTEGER NOT NULL
        REFERENCES student (stu_num) ON UPDATE CASCADE ON DELETE CASCADE,
    enroll_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    enroll_grade CHAR(2) CHECK (enroll_grade IN
        ('A','A-','B+','B','B-','C+','C','C-','D','F','W','I')),
    PRIMARY KEY (class_code, stu_num)
);
-- ------------------------------------------------------------
-- 2. Indexes on foreign keys (PostgreSQL does not create them)
-- ------------------------------------------------------------
CREATE INDEX idx_room_bldg        ON room (bldg_code);
CREATE INDEX idx_department_school ON department (school_code);
CREATE INDEX idx_professor_dept   ON professor (dept_code);
CREATE INDEX idx_course_dept      ON course (dept_code);
CREATE INDEX idx_class_course     ON class (crs_code);
CREATE INDEX idx_class_prof       ON class (prof_num);
CREATE INDEX idx_class_room       ON class (room_code);
CREATE INDEX idx_class_semester   ON class (semester_code);
CREATE INDEX idx_student_dept     ON student (dept_code);
CREATE INDEX idx_student_advisor  ON student (prof_num);
CREATE INDEX idx_enroll_student   ON enroll (stu_num);

-- ------------------------------------------------------------
-- 3. Sample data (everything runs in one transaction so the
--    deferred circular foreign keys are checked at COMMIT)
-- ------------------------------------------------------------
BEGIN;

INSERT INTO building VALUES
 ('KOM',  'Kommers Hall',  'North Campus'),
 ('SCI',  'Science Hall',  'East Campus');

INSERT INTO room VALUES
 ('KOM101', 'Classroom', 'KOM'),
 ('KOM205', 'Lab',       'KOM'),
 ('SCI110', 'Lecture',   'SCI');

INSERT INTO school VALUES
 ('BUS', 'School of Business Administration', NULL),
 ('A&S', 'College of Arts & Sciences',        NULL);

INSERT INTO department VALUES
 ('ACCT', 'Accounting',       'BUS', NULL),
 ('CIS',  'Computer Info. Systems', 'BUS', NULL),
 ('MATH', 'Mathematics',      'A&S', NULL);

INSERT INTO professor VALUES
 (101, 'CIS',  'Database Systems', 'Professor',  'Smith',  'John',  'A', 'jsmith@tinycollege.edu'),
 (102, 'ACCT', 'Auditing',         'Associate',  'Brown',  'Linda', 'M', 'lbrown@tinycollege.edu'),
 (103, 'MATH', 'Statistics',       'Professor',  'Wilson', 'Karen', 'R', 'kwilson@tinycollege.edu');

UPDATE school     SET prof_num = 102 WHERE school_code = 'BUS';
UPDATE school     SET prof_num = 103 WHERE school_code = 'A&S';
UPDATE department SET prof_num = 102 WHERE dept_code = 'ACCT';
UPDATE department SET prof_num = 101 WHERE dept_code = 'CIS';
UPDATE department SET prof_num = 103 WHERE dept_code = 'MATH';

INSERT INTO course VALUES
 ('CIS-1101', 'CIS',  'Intro to Databases', 'Relational model and SQL', 3.0),
 ('ACCT-201', 'ACCT', 'Principles of Accounting', 'Financial accounting basics', 3.0),
 ('MATH-101', 'MATH', 'Calculus I', 'Limits, derivatives, integrals', 4.0);

INSERT INTO semester VALUES
 ('FALL26', 2026, 'Fall',   '2026-09-01', '2026-12-20'),
 ('SPR27',  2027, 'Spring', '2027-01-15', '2027-05-30');

INSERT INTO class VALUES
 (10012, '1', 'MWF 8:00-8:50',  'ACCT-201', 102, 'KOM101', 'FALL26'),
 (10013, '2', 'MWF 9:00-9:50',  'CIS-1101', 101, 'KOM205', 'FALL26'),
 (10014, '1', 'TTh 10:00-11:15','MATH-101', 103, 'SCI110',  'FALL26');

INSERT INTO student VALUES
 (324257, 'CIS',  'Smithson', 'Anne',  'K', 'asmithson@student.tc.edu', 101),
 (324258, 'ACCT', 'Brewer',   'Juan',  'T', 'jbrewer@student.tc.edu',   102),
 (324259, 'MATH', 'Hassan',   'Omar',  NULL,'ohassan@student.tc.edu',   103);

INSERT INTO enroll VALUES
 (10012, 324258, '2026-08-20', 'A'),
 (10013, 324257, '2026-08-21', 'B+'),
 (10013, 324259, '2026-08-22', NULL),
 (10014, 324259, '2026-08-22', 'A-');

COMMIT;

-- ------------------------------------------------------------
-- 4. Example query: class schedule with professor, room, building
-- ------------------------------------------------------------
-- SELECT c.class_code, co.crs_title, c.class_section, c.class_time,
--        p.prof_lname, r.room_code, b.bldg_name, s.semester_term, s.semester_year
-- FROM class c
-- JOIN course   co ON co.crs_code = c.crs_code
-- JOIN professor p ON p.prof_num  = c.prof_num
-- JOIN room      r ON r.room_code = c.room_code
-- JOIN building  b ON b.bldg_code = r.bldg_code
-- JOIN semester  s ON s.semester_code = c.semester_code;
