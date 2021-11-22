-- In this assignment we will create a table and add a stored procedure to it.

------------------------------------------------------------------------------

DROP TABLE pg4e_debug;

CREATE TABLE pg4e_debug (
    id SERIAL,
    query VARCHAR(4096),
    result VARCHAR(4096),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id)
);

CREATE TABLE pg4e_result (
    id SERIAL,
    link_id INTEGER UNIQUE,
    score FLOAT,
    title VARCHAR(4096),
    note VARCHAR(4096),
    debug_log VARCHAR(8192),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

SELECT query, result, created_at FROM pg4e_debug;
SELECT * FROM pg4e_result;
