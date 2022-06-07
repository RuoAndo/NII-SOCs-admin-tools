from pymongo import MongoClient
from pymongo import DESCENDING
from pymongo import ASCENDING

class MongoFindSample(object):

    def __init__(self, dbName, collectionName):
        self.client = MongoClient()
        self.db = self.client[dbName] 
        self.collection = self.db.get_collection(collectionName)

    def find_one(self, projection=None,filter=None, sort=None):
        return self.collection.find_one(projection=projection,filter=filter,sort=sort)

    def find(self, projection=None,filter=None, sort=None):
        return self.collection.find(projection=projection,filter=filter,sort=sort)

mongo = MongoFindSample('test', 'test')
findOne = mongo.find_one()
print('-----------------find_One-----------------')
print(type(findOne))
print(findOne)

find = mongo.find()
print('-------------------find-------------------')
print(type(find))
for doc in find:
    print(doc)
