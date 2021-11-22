-- Unesco Heritage Sites: many-to-one relationship

-- In this assignment we will read some Unesco Heritage Site data in
-- comma-separated-values (CSV) format and produce properly normalized tables.

------------------------------------------------------------------------------

-- create tables

DROP TABLE IF EXISTS unesco_raw CASCADE;
CREATE TABLE unesco_raw (
    name TEXT,
    description TEXT,
    justification TEXT,
    year INTEGER,
    longitude FLOAT,
    latitude FLOAT,
    area_hectares FLOAT,
    category TEXT,
    category_id INTEGER,
    state TEXT,
    state_id INTEGER,
    region TEXT,
    region_id INTEGER,
    iso TEXT,
    iso_id INTEGER
);
SELECT * FROM unesco_raw;

DROP TABLE IF EXISTS unesco CASCADE;
CREATE TABLE unesco (
    id SERIAL,
    name TEXT,
    description TEXT,
    justification TEXT,
    year INTEGER,
    longitude FLOAT,
    latitude FLOAT,
    area_hectares FLOAT,
    category_id INTEGER REFERENCES category(id) ON DELETE CASCADE,
    state_id INTEGER REFERENCES state(id) ON DELETE CASCADE,
    region_id INTEGER REFERENCES region(id) ON DELETE CASCADE,
    iso_id INTEGER REFERENCES iso(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);
SELECT * FROM unesco;

DROP TABLE IF EXISTS category CASCADE;
CREATE TABLE category (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);
SELECT * FROM category;

DROP TABLE IF EXISTS state CASCADE;
CREATE TABLE state (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);
SELECT * FROM state;

DROP TABLE IF EXISTS region CASCADE;
CREATE TABLE region (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);
SELECT * FROM region;

DROP TABLE IF EXISTS iso CASCADE;
CREATE TABLE iso (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);
SELECT * FROM iso;

------------------------------------------------------------------------------

-- populate tables

-- load csv data into unesco_raw table
\copy unesco_raw(name,description,justification,year,longitude,latitude,area_hectares,category,state,region,iso) FROM 'whc-sites-2018-small.csv' WITH DELIMITER ',' CSV HEADER;

-- SELECT * FROM unesco_raw LIMIT 10;
SELECT name, year, longitude, latitude, area_hectares, category, category_id, state, state_id, region, region_id, iso, iso_id
FROM unesco_raw LIMIT 10;

-- add entries to lookup tables

INSERT INTO category(name) SELECT DISTINCT category FROM unesco_raw;
SELECT * FROM category;

INSERT INTO state(name) SELECT DISTINCT state FROM unesco_raw;
SELECT * FROM state LIMIT 10;

INSERT INTO region(name) SELECT DISTINCT region FROM unesco_raw;
SELECT * FROM region;

INSERT INTO iso(name) SELECT DISTINCT iso FROM unesco_raw;
SELECT * FROM iso LIMIT 10;

-- add foreign keys to unesco_raw table

UPDATE unesco_raw SET category_id = (
    SELECT category.id FROM category WHERE category.name = unesco_raw.category
);

UPDATE unesco_raw SET state_id = (
    SELECT state.id FROM state WHERE state.name = unesco_raw.state
);

UPDATE unesco_raw SET region_id = (
    SELECT region.id FROM region WHERE region.name = unesco_raw.region
);

UPDATE unesco_raw SET iso_id = (
    SELECT iso.id FROM iso WHERE iso.name = unesco_raw.iso
);

SELECT name, year, longitude, latitude, area_hectares, category, category_id, state, state_id, region, region_id, iso, iso_id
FROM unesco_raw LIMIT 10;

-- copy corresponding data from unesco_raw table to unesco table, effectively dropping the un-normalized redundant fields
INSERT INTO unesco(name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id)
SELECT name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id
FROM unesco_raw;

SELECT name, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id
FROM unesco LIMIT 10;

------------------------------------------------------------------------------

-- test

SELECT unesco.name, year, category.name, state.name, region.name, iso.name
FROM unesco
JOIN category ON unesco.category_id = category.id
JOIN iso ON unesco.iso_id = iso.id
JOIN state ON unesco.state_id = state.id
JOIN region ON unesco.region_id = region.id
ORDER BY state.name, unesco.name
LIMIT 3;

