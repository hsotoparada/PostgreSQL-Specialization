# In this assignment, we will write a Python program to insert a sequence of
# 300 pseudorandom numbers into a database table named pythonseq

import psycopg2
import hidden
import time

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
sql = 'DROP TABLE IF EXISTS pythonseq CASCADE;'
print(sql)
cur.execute(sql)

sql = 'CREATE TABLE pythonseq (iter INTEGER, val INTEGER);'
print(sql)
cur.execute(sql)

conn.commit() # Flush it all to the DB server

# generate series of numbers in sequences
number = 693028
for i in range(300) :
    count = i+1
    print(count, number)
    # value = int((value * 22) / 7) % 1000000
    sql = 'INSERT INTO pythonseq (iter, val) VALUES (%s, %s);'
    cur.execute(sql, (count, number))
    if count % 50 == 0: conn.commit()
    # if count % 100 == 0 : time.sleep(1)
    number = int((number * 22) / 7) % 1000000

conn.commit()

# query
sql = "SELECT * FROM pythonseq LIMIT 20;"
print(sql)
cur.execute(sql)
conn.commit()

# close connection to DB server
cur.close()

