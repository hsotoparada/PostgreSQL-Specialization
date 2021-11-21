DROP TABLE make;
DROP TABLE model;

CREATE TABLE make (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE model (
    id SERIAL,
    name VARCHAR(128),
    make_id INTEGER REFERENCES make(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);

INSERT INTO make (name) VALUES ('Ferrari');
INSERT INTO make (name) VALUES ('GMC');
INSERT INTO model (name, make_id) VALUES ('California', 1);
INSERT INTO model (name, make_id) VALUES ('California T', 1);
INSERT INTO model (name, make_id) VALUES ('Enzo Ferrari', 1);
INSERT INTO model (name, make_id) VALUES ('Envoy 2WD', 2);
INSERT INTO model (name, make_id) VALUES ('Envoy 4WD', 2);

SELECT * FROM make;
SELECT * FROM model;

SELECT make.name, model.name
    FROM model
    JOIN make ON model.make_id = make.id
    ORDER BY make.name LIMIT 5;

