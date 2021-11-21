-- In this assignment, we will create a table of documents and then produce a
-- GIN-based text[] reverse index for those documents that identifies each
-- document which contains a particular word using SQL.

------------------------------------------------------------------------------

-- create table
DROP TABLE IF EXISTS docs03 CASCADE;
CREATE TABLE docs03 (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);
SELECT * FROM docs03;

-- create gin reversed index
DROP INDEX array03;
-- CREATE INDEX array03 ON docs03 USING gin(to_tsvector('english', doc));
-- CREATE INDEX array03 ON docs03 USING gin(string_to_array(lower(doc), ' ') array_ops);
CREATE INDEX array03 ON docs03 USING gin(string_to_array(lower(doc), ' ') array_ops);

-- insert docs
INSERT INTO docs03 (doc) VALUES
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

SELECT * FROM docs03;

-- insert more lines
INSERT INTO docs03 (doc)
SELECT 'Neon ' || generate_series(10000, 20000);

SELECT COUNT(*) FROM docs03;

------------------------------------------------------------------------------

-- test query

SELECT id, doc FROM docs03 WHERE '{conversation}' <@ string_to_array(lower(doc), ' ');
EXPLAIN SELECT id, doc FROM docs03 WHERE '{conversation}' <@ string_to_array(lower(doc), ' ');

