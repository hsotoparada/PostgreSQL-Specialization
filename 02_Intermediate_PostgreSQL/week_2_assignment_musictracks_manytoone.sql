-- Musical Tracks: many-to-one relationship

-- This application will read an iTunes library in comma-separated-values (CSV)
-- format and produce a properly normalized tables

------------------------------------------------------------------------------

-- create tables

DROP TABLE IF EXISTS album CASCADE;
CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);
SELECT * FROM album;

DROP TABLE IF EXISTS track CASCADE;
CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    len INTEGER,
    rating INTEGER,
    count INTEGER,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    UNIQUE(title, album_id),
    PRIMARY KEY(id)
);
SELECT * FROM track;

DROP TABLE IF EXISTS track_raw CASCADE;
CREATE TABLE track_raw (
    title TEXT,
    artist TEXT,
    album TEXT,
    album_id INTEGER,
    count INTEGER,
    rating INTEGER,
    len INTEGER
);
SELECT * FROM track_raw;

-- populate tables

-- load csv data into track_raw table
-- csv first line: Another One Bites The Dust,Queen,Greatest Hits,55,100,217
\copy track_raw(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;

SELECT * FROM track_raw LIMIT 10;

-- insert all distinct albums into album table (creating their primary keys)
INSERT INTO album(title) SELECT DISTINCT album FROM track_raw;

SELECT * FROM album;


-- set the album_id in track_raw table
UPDATE track_raw SET album_id = (
    SELECT album.id FROM album WHERE album.title = track_raw.album
);

SELECT * FROM track_raw LIMIT 10;

-- copy corresponding data from track_raw table to track table, effectively dropping the artist and album text fields
INSERT INTO track(title, len, rating, count, album_id)
SELECT title, len, rating, count, album_id
FROM track_raw;

SELECT * FROM track LIMIT 10;

-- test

SELECT track.title, album.title
FROM track
JOIN album ON track.album_id = album.id
ORDER BY track.title LIMIT 3;

