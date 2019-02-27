import os
import json
from helpers import logs_directory, docs_directory

def transform(json_string):
    data = json.loads(json_string)

    # Some records are in the old format and also stored the IP, so of no use
    # to us
    try:
        if data["context"]["ip"] == "0.0.0.0":
            es_doc = {
                "anonymousId": data["anonymousId"],
                "page": data["context"]["page"],
                "event": data["event"],
                "properties": data["properties"],
                "receivedAt": data["receivedAt"]
            }

            with open("{}/{}.json".format(docs_directory, es_doc["anonymousId"]), "w", ) as outfile:
                json.dump(json.dumps(es_doc), outfile)
    except:
        print(data)
        raise Exception("bang")

data = []
for filename in os.listdir(logs_directory):
    with open("{}/{}".format(logs_directory, filename), "r", encoding="ISO-8859-1") as f:
        for line in f:
            data.append(line)

for json_string in data:
    transform(json_string)

print("ᕕ(ᐛ)ᕗ ¡Done! ᕕ(ᐛ)ᕗ")
