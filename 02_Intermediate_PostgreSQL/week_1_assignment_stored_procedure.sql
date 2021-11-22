-- In this assignment we will create a table and add a stored procedure to it.

------------------------------------------------------------------------------

DROP TABLE keyvalue;

CREATE TABLE keyvalue (
    id SERIAL,
    key VARCHAR(128) UNIQUE,
    value VARCHAR(128) UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id)
);

SELECT * FROM keyvalue;

-- stored procedure

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON keyvalue
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

