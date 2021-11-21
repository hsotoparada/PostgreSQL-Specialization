-- create table
DROP TABLE IF EXISTS docs CASCADE;
CREATE TABLE docs (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);
SELECT * FROM docs;

-- insert docs
INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');
SELECT * FROM docs;

-- break document column into one row per word + primary key
SELECT DISTINCT id, s.keyword AS keyword
FROM docs as D, unnest(string_to_array(D.doc, ' ')) s(keyword)
ORDER BY id;

-- lower case it all
SELECT DISTINCT id, s.keyword AS keyword
FROM docs as D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
ORDER BY id;

-- create GIN table
DROP TABLE IF EXISTS docs_gin CASCADE;
CREATE TABLE docs_gin (
    keyword TEXT,
    doc_id INTEGER REFERENCES docs(id) ON DELETE CASCADE
);
SELECT * FROM docs_gin;

-- stopwords
DROP TABLE IF EXISTS stop_words CASCADE;
CREATE TABLE stop_words (
    word TEXT unique
);

INSERT INTO stop_words (word) VALUES ('is'), ('this'), ('and');

-- throw out words in stop word list
SELECT DISTINCT id, s.keyword AS keyword
FROM docs as D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY id;

-- put stop-word free list into the GIN
INSERT INTO docs_gin (doc_id, keyword)
SELECT DISTINCT id, s.keyword AS keyword
FROM docs as D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
WHERE s.keyword NOT IN (SELECT word FROM stop_words)
ORDER BY id;

SELECT * FROM docs_gin;

-- queries

-- one-word query
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = lower('UMSI');

-- multi-word query
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword =
    ANY(string_to_array(lower('Meet fun people'), ' '));

-- stop-word query
SELECT DISTINCT doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword = lower('and');

-- stemming

-- We can make the index even smaller by only storing the "stems" of words
-- This simple approach makes a "dictionary" of word -> stem

DROP TABLE IF EXISTS docs_stem CASCADE;
CREATE TABLE docs_stem (
    word TEXT,
    stem TEXT
);
INSERT INTO docs_stem (word, stem) VALUES
('teaching', 'teach'), ('teaches', 'teach');
SELECT * FROM docs_stem;

-- Add the stems into a sub-query as third column (may or may not exist)
SELECT id, keyword, stem FROM (
SELECT DISTINCT id, s.keyword AS keyword
FROM docs as D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

-- If the stem is there, use it
SELECT id,
CASE WHEN stem IS NOT NULL THEN stem ELSE keyword END AS awesome,
keyword, stem FROM (
SELECT DISTINCT id, s.keyword AS keyword
FROM docs as D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

-- If the stem is there, use it instead of keyword
-- We use COALESCE function, which returns the first non-null element in a list
SELECT id, COALESCE(stem, keyword) AS keyword
FROM (
    SELECT DISTINCT id, s.keyword AS keyword
    FROM docs as D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

-- Insert only the stems into docs_gin table
DELETE FROM docs_gin;

INSERT INTO docs_gin (doc_id, keyword)
SELECT id, COALESCE(stem, keyword)
FROM (
    SELECT DISTINCT id, s.keyword AS keyword
    FROM docs as D, unnest(string_to_array(lower(D.doc), ' ')) s(keyword)
    WHERE s.keyword NOT IN (SELECT word FROM stop_words)
) AS K
LEFT JOIN docs_stem AS S ON K.keyword = S.word;

SELECT * FROM docs_gin;

-- simple query
SELECT COALESCE(
    (SELECT stem FROM docs_stem WHERE word=lower('SQL')),
    lower('SQL')
);
SELECT COALESCE(
    (SELECT stem FROM docs_stem WHERE word=lower('teaching')),
    lower('teaching')
);

-- Handling the stems in queries. Use the keyword if there is no stem
SELECT DISTINCT id, doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword =
COALESCE(
    (SELECT stem FROM docs_stem WHERE word=lower('SQL')),
    lower('SQL')
);

-- Prefer the stem over the actual keyword
SELECT DISTINCT id, doc FROM docs AS D
JOIN docs_gin AS G ON D.id = G.doc_id
WHERE G.keyword =
COALESCE(
    (SELECT stem FROM docs_stem WHERE word=lower('teaching')),
    lower('teaching')
);

