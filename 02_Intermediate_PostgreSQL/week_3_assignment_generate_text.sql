-- In this assignment we will create a table named bigtext with a single TEXT column named content.
-- Insert 100000 records with numbers starting at 100000

------------------------------------------------------------------------------

-- create table

DROP TABLE IF EXISTS bigtext;
CREATE TABLE bigtext (
    content TEXT
);
SELECT * FROM bigtext;

INSERT INTO bigtext (content)
SELECT (
    'This is record number ' ||
    generate_series(100000, 200000-1) ||
    ' of quite a few text records.'
);
SELECT * FROM bigtext LIMIT 10;
SELECT COUNT(*) FROM bigtext;

