-- In this assignment we will create a regular expression to retrieve a subset
-- data from the purpose column of the taxdata table in the readonly database
-- (access details below).
--
-- The regular expression should meet the following criteria:
-- Lines that end with a period. (don't forget to escape)
--
-- As an example (not the solution to this assignment), if you were looking for
-- lines where the very first character was an upper case character letter you
-- would run the following query:
-- SELECT purpose FROM taxdata WHERE purpose ~ '^[A-Z]' ORDER BY purpose DESC LIMIT 3;

------------------------------------------------------------------------------

-- create regex

SELECT purpose
FROM taxdata
WHERE purpose ~ '.\.$' ORDER BY purpose DESC LIMIT 3;

