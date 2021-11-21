-- In this assignment, we will create a table of documents and then produce a
-- reverse index for those documents that identifies each document which
-- contains a particular word using SQL.

------------------------------------------------------------------------------

-- create tables

DROP TABLE IF EXISTS docs01 CASCADE;
CREATE TABLE docs01 (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);
SELECT * FROM docs01;

DROP TABLE IF EXISTS invert01 CASCADE;
CREATE TABLE invert01 (
    keyword TEXT,
    doc_id INTEGER REFERENCES docs01(id) ON DELETE CASCADE
);
SELECT * FROM invert01;

-- insert docs

INSERT INTO docs01 (doc) VALUES
('Even though we are typing these commands into Python one line at a time'),
('Python is treating them as an ordered sequence of statements with later'),
('statements able to retrieve data created in earlier statements We are'),
('writing our first simple paragraph with four sentences in a logical and'),
('It is the nature of an interpreter to be able to have'),
('an interactive conversation as shown above A compiler'),
('needs to be handed the entire program in a file and then it runs a'),
('process to translate the highlevel source code into machine language'),
('and then the compiler puts the resulting machine language into a file'),
('If you have a Windows system often these executable machine language');

SELECT * FROM docs01;

-- create reverse index

INSERT INTO invert01 (doc_id, keyword)
SELECT DISTINCT id, s.keyword AS keyword
FROM docs01 as D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
ORDER BY id;

-- test

-- SELECT * FROM invert01;
SELECT keyword, doc_id FROM invert01 ORDER BY keyword, doc_id LIMIT 10;

