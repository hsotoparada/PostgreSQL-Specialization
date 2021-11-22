# In this assignment we will insert tweets into an Elasticsearch NoSQL database 
# and perform a search.

# ------------------------------------------------------------------------------


from datetime import datetime
from elasticsearch import Elasticsearch
from elasticsearch import RequestsHttpConnection
import hidden

secrets = hidden.elastic()

es = Elasticsearch(
    [secrets['host']],
    http_auth=(secrets['user'], secrets['pass']),
    url_prefix = secrets['prefix'],
    scheme=secrets['scheme'],
    port=secrets['port'],
    connection_class=RequestsHttpConnection,
)
indexname = secrets['user']

# Start fresh
# https://elasticsearch-py.readthedocs.io/en/master/api.html#indices
res = es.indices.delete(index=indexname, ignore=[400, 404])
print("Dropped index")
print(res)

res = es.indices.create(index=indexname)
print("Created the index...")
print(res)

# # several tweets
#
# tweets = [
#     'value in y Then we ask Python to print out the value',
#     'Even though we are typing these commands into Python one line at a time',
#     'Python is treating them as an ordered sequence of statements with later',
#     'statements able to retrieve data created in earlier statements We are',
#     'writing our first simple paragraph with four sentences in a logical and'
#     # 'Elasticsearch: cool. bonsai cool.',
# ]
#
# for tweet in tweets:
#     doc = {
#         'author': 'user',
#         'type' : 'tweet',
#         'text': tweet,
#         'timestamp': datetime.now(),
#     }
#
#     # Note - you can't change the key type after you start indexing documents
#     res = es.index(index=indexname, id='abc', body=doc)
#     print('Added document...')
#     print(res['result'])

# one tweet

tweet = '''
value in y Then we ask Python to print out the value
Even though we are typing these commands into Python one line at a time
Python is treating them as an ordered sequence of statements with later
statements able to retrieve data created in earlier statements We are
writing our first simple paragraph with four sentences in a logical and
'''

doc = {
    'author': 'user',
    'type' : 'tweet',
    'text': tweet,
    'timestamp': datetime.now(),
}

# Note - you can't change the key type after you start indexing documents
res = es.index(index=indexname, id='abc', body=doc)
print('Added document...')
print(res['result'])


res = es.get(index=indexname, id='abc')
print('Retrieved document...')
print(res)

# Tell it to recompute the index - normally it would take up to 30 seconds
# Refresh can be costly - we do it here for demo purposes
# https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-refresh.html
res = es.indices.refresh(index=indexname)
print("Index refreshed")
print(res)

# Read the documents with a search term
# https://www.elastic.co/guide/en/elasticsearch/reference/current/query-filter-context.html
x = {
  "query": {
    "bool": {
      "must": {
        "match": {
          "text": "sequence"
        }
      },
      "filter": {
        "match": {
          "type": "tweet"
        }
      }
    }
  }
}

res = es.search(index=indexname, body=x)
print('Search results...')
print(res)
print()
print("Got %d Hits:" % len(res['hits']['hits']))
for hit in res['hits']['hits']:
    s = hit['_source']
    print(f"{s['timestamp']} {s['author']}: {s['text']}")


