import os
import json
from elasticsearch import Elasticsearch
from helpers import docs_directory

path_to_es_credentials = os.path.join(
    os.path.dirname(os.path.realpath(__file__)), "../es_credentials.json"
)

es_credentials = json.load(open(path_to_es_credentials))

es = Elasticsearch(
    es_credentials["url"],
    http_auth=(es_credentials["username"], es_credentials["password"]),
)

try:
    for filename in os.listdir(docs_directory):
        with open("{}/{}".format(docs_directory, filename), "r", encoding="ISO-8859-1") as f:
            data = json.loads(json.load(f))
            res = es.index(
                index="search_logs", id=data["messageId"], doc_type="search_log", body=data
            )
except Exception as e:
    raise Exception(e)
