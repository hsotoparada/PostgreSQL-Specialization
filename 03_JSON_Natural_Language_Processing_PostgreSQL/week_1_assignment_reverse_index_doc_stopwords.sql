-- In this assignment, we will create a table of documents and then produce a
-- reverse index with stop words for those documents that identifies each document
-- which contains a particular word using SQL.

------------------------------------------------------------------------------

-- create tables

DROP TABLE IF EXISTS docs02 CASCADE;
CREATE TABLE docs02 (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);
SELECT * FROM docs02;

DROP TABLE IF EXISTS invert02 CASCADE;
CREATE TABLE invert02 (
    keyword TEXT,
    doc_id INTEGER REFERENCES docs02(id) ON DELETE CASCADE
);
SELECT * FROM invert02;

DROP TABLE IF EXISTS stop_words;
CREATE TABLE stop_words (
    word TEXT UNIQUE
);

-- insert docs and stop words

INSERT INTO stop_words (word) VALUES
('i'), ('a'), ('about'), ('an'), ('are'), ('as'), ('at'), ('be'),
('by'), ('com'), ('for'), ('from'), ('how'), ('in'), ('is'), ('it'), ('of'),
('on'), ('or'), ('that'), ('the'), ('this'), ('to'), ('was'), ('what'),
('when'), ('where'), ('who'), ('will'), ('with');

SELECT * FROM stop_words;

INSERT INTO docs02 (doc) VALUES
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

SELECT * FROM docs02;

-- create reverse index

INSERT INTO invert02 (doc_id, keyword)
SELECT DISTINCT id, s.keyword AS keyword
FROM docs02 as D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY id;

-- test

-- SELECT * FROM invert02;
SELECT keyword, doc_id FROM invert02 ORDER BY keyword, doc_id LIMIT 10;

