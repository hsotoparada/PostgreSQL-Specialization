# In this assignment, we will retrieve data from the PokeAPI and store it in a database

# -------------------------------------------------------------------------------------

import psycopg2
import hidden
import time
import myutils
import requests
import json

# Load the secrets
secrets = hidden.secrets()

conn = psycopg2.connect(host=secrets['host'],
        port=secrets['port'],
        database=secrets['database'],
        user=secrets['user'],
        password=secrets['pass'],
        connect_timeout=3)

cur = conn.cursor()

# create table
sql_1 = 'DROP TABLE IF EXISTS pokeapi CASCADE;'

sql_2 = '''
CREATE TABLE IF NOT EXISTS pokeapi
(id INTEGER, body JSONB);
'''

print(sql_1)
print(sql_2)
cur.execute(sql_1)
cur.execute(sql_2)
conn.commit()

# populate table
# loop through and retrieve json data for urls ending in 1..100 and store it in pokeapi table
initial_url = 'https://pokeapi.co/api/v2/pokemon/'
for i in range(1, 101):
# for i in range(1, 3):
    url = f"{initial_url}{i}"
    print('=== Url is', url)
    response = requests.get(url)
    text = response.text
    js = json.loads(text)
    # stuff = js.get(link, None)
    # print('=== Text is', text)
    # status = response.status_code
    # sql = 'UPDATE swapi SET id=%s, body=%s;'
    sql = 'INSERT INTO pokeapi (id, body) VALUES (%s, %s);'
    # sql = 'INSERT INTO pokeapi (id) VALUES (%s);'
    # sql = 'UPDATE pokeapi (id, body) VALUES ( %s, %s );'
    # row = cur.execute(sql, (str(i)))
    row = cur.execute(sql, (str(i), text))
    # row = cur.execute(sql, (i, js))

conn.commit()


# Check to see if we have urls in the table, if not add starting points
# for each of the object trees
sql_1 = 'SELECT COUNT(*) FROM pokeapi;'
sql_2 = 'SELECT * FROM pokeapi LIMIT 2;'

cur.execute(sql_1)
cur.execute(sql_2)
conn.commit()

print('Closing database connection...')
cur.close()

