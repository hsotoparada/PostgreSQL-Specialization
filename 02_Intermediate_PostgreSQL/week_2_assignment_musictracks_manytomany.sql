-- Musical Track Database plus Artist: many-to-many relationship

-- This application will read an iTunes library in comma-separated-values (CSV)
-- and produce properly normalized many-to-many tables relating tracks to artists.
-- We also use the ALTER TABLE command to adjust the schema of the
-- tables after we have finished processing.

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
    title TEXT,
    artist TEXT,
    album TEXT,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    count INTEGER,
    rating INTEGER,
    len INTEGER,
    PRIMARY KEY(id)
);
SELECT * FROM track;

DROP TABLE IF EXISTS artist CASCADE;
CREATE TABLE artist (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);
SELECT * FROM artist;

DROP TABLE IF EXISTS tracktoartist CASCADE;
CREATE TABLE tracktoartist (
    id SERIAL,
    track TEXT,
    track_id INTEGER REFERENCES track(id) ON DELETE CASCADE,
    artist TEXT,
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);
SELECT * FROM tracktoartist;

------------------------------------------------------------------------------

-- populate tables

-- load csv data into track_raw table
-- csv first line: Another One Bites The Dust,Queen,Greatest Hits,55,100,217
\copy track(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;
SELECT * FROM track LIMIT 10;

-- add entries to lookup tables

INSERT INTO album (title) SELECT DISTINCT album FROM track;
UPDATE track SET album_id = (
    SELECT album.id FROM album WHERE album.title = track.album
);
SELECT * FROM album LIMIT 10;

INSERT INTO tracktoartist (track, artist) SELECT DISTINCT title, artist FROM track;
SELECT * FROM tracktoartist LIMIT 10;

INSERT INTO artist (name) SELECT DISTINCT artist FROM track;
SELECT * FROM artist LIMIT 10;

-- add foreign keys to unesco_raw table

UPDATE tracktoartist SET track_id = (
    SELECT track.id FROM track WHERE track.title = tracktoartist.track
);

UPDATE tracktoartist SET artist_id = (
    SELECT artist.id FROM artist WHERE artist.name = tracktoartist.artist
);

SELECT * FROM tracktoartist LIMIT 10;

------------------------------------------------------------------------------

-- delete reduntant fields from tables

ALTER TABLE track DROP COLUMN album;
ALTER TABLE track DROP COLUMN artist;
SELECT * FROM track LIMIT 10;

ALTER TABLE tracktoartist DROP COLUMN track;
ALTER TABLE tracktoartist DROP COLUMN artist;
SELECT * FROM tracktoartist LIMIT 10;

------------------------------------------------------------------------------

-- test

SELECT track.title, album.title, artist.name
FROM track
JOIN album ON track.album_id = album.id
JOIN tracktoartist ON track.id = tracktoartist.track_id
JOIN artist ON tracktoartist.artist_id = artist.id
ORDER BY track.title
LIMIT 3;

