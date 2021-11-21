-- create tables

DROP TABLE student;
CREATE TABLE student (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE course CASCADE;
CREATE TABLE course (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE roster CASCADE;
CREATE TABLE roster (
    id SERIAL,
    student_id INTEGER REFERENCES student(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
    role INTEGER,
    UNIQUE(student_id, course_id),
    PRIMARY KEY(id)
);

-- populate tables

INSERT INTO student (name) VALUES ('Emlyn');
INSERT INTO student (name) VALUES ('Abdulmalik');
INSERT INTO student (name) VALUES ('Kian');
INSERT INTO student (name) VALUES ('Muhsin');
INSERT INTO student (name) VALUES ('Niraj');
INSERT INTO student (name) VALUES ('Denise');
INSERT INTO student (name) VALUES ('Cory');
INSERT INTO student (name) VALUES ('Irfa');
INSERT INTO student (name) VALUES ('Jaskaran');
INSERT INTO student (name) VALUES ('Tabitha');
INSERT INTO student (name) VALUES ('Katia');
INSERT INTO student (name) VALUES ('Daniella');
INSERT INTO student (name) VALUES ('Hafswa');
INSERT INTO student (name) VALUES ('Nicolas');
INSERT INTO student (name) VALUES ('Rob');

INSERT INTO course (title) VALUES ('si106');
INSERT INTO course (title) VALUES ('si110');
INSERT INTO course (title) VALUES ('si206');

INSERT INTO roster (student_id, course_id, role) VALUES (1, 1, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (2, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (3, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (4, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (5, 1, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (6, 2, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (7, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (8, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (9, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (10, 2, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (11, 3, 1);
INSERT INTO roster (student_id, course_id, role) VALUES (12, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (13, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (14, 3, 0);
INSERT INTO roster (student_id, course_id, role) VALUES (15, 3, 0);

-- test

SELECT student.name, course.title, roster.role
    FROM student
    JOIN roster ON student.id = roster.student_id
    JOIN course ON roster.course_id = course.id
    ORDER BY course.title, roster.role DESC, student.name;

