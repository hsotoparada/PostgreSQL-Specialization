-- The GIN (General Inverted Index) thinks about columns that contain arrays
-- A GIN needs to know what kind of data will be in the arrays
-- arrays_ops (_text_ops for PostgreSQL 9) means that it is expecting
-- text[] (array of strings) and WHERE clauses will use array operators (like <@)

-- create table
DROP TABLE IF EXISTS docs CASCADE;
CREATE TABLE docs (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);
SELECT * FROM docs;

-- create gin reversed index
DROP INDEX gin1;
CREATE INDEX gin1 ON docs USING gin(string_to_array(doc, '') array_ops);

-- insert docs
INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');
SELECT * FROM docs;

-- insert more lines
INSERT INTO docs (doc)
SELECT 'Neon ' || generate_series(10000, 20000);
SELECT COUNT(*) FROM docs;

------------------------------------------------------------------------------

-- query
-- the <@ if "is contained within" or "intersection" from set theory
SELECT id, doc FROM docs WHERE '{learn}' <@ string_to_array(doc, ' ');

-- you don't wanna see: Seq Scan --> index was not activated
-- you wanna see: Heap Scan, Recheck, Index Scan --> query sucessfully uses created index
-- you might need to wait a bit until the index catches up to the inserts
EXPLAIN SELECT id, doc FROM docs WHERE '{learn}' <@ string_to_array(doc, ' ');

------------------------------------------------------------------------------

-- query using ts_vector() and ts_query() language-aware functions
-- to_tsvector(): returns a list of words that represent the document.
-- to_tsquery(): returns a list of words with operators to representations
-- various logical combinations of word much like Google's Advanced Search.

-- ts_vector is an special "array" of stemmed words, passed through a stop-word
-- filter + positions within the document
SELECT to_tsvector('english', 'This is SQL and Python and other fun teaching stuff');
SELECT to_tsvector('english', 'More people should learn SQL from UMSI');
SELECT to_tsvector('english', 'UMSI also teaches Python and also SQL');

-- ts_query is an "array" of lower case, stemmed words with
-- stop words removed plus logical operators $ = and, ! = not, | = or
SELECT to_tsquery('english', 'teaching');
SELECT to_tsquery('english', 'teaches');
SELECT to_tsquery('english', 'and');
SELECT to_tsquery('english', 'SQL');
SELECT to_tsquery('english', 'Teach | teaches | teaching | and | the | if');

-- plaintext just pulls out the keywords
SELECT plainto_tsquery('english', 'SQL Python');
SELECT plainto_tsquery('english', 'Teach teaches teaching and the if');

-- a phrase is words that come in order
SELECT phraseto_tsquery('english', 'SQL Python');

-- is a query inside of a text vector
SELECT to_tsquery('english', 'teaching') @@
    to_tsvector('english', 'UMSI also teaches Python and also SQL');

-- query on docs table
SELECT id, doc FROM docs WHERE
    to_tsquery('english', 'learn') @@ to_tsvector('english', doc);

DROP INDEX gin1;
-- CREATE INDEX gin1 ON docs USING gist(to_tsvector('english', doc));
CREATE INDEX gin1 ON docs USING gin(to_tsvector('english', doc));
EXPLAIN SELECT id, doc FROM docs WHERE
    to_tsquery('english', 'learn') @@ to_tsvector('english', doc);

