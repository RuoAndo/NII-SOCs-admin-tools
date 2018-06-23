import pymongo

# mongodb へのアクセスを確立
client = pymongo.MongoClient('localhost', 27017)

# データベースを作成 (名前: my_database)
db = client.my_database

# コレクションを作成 (名前: my_collection)
co = db.my_collection

# なんか適当に保存
co.insert_one({"test": 3})

# 全部とってくる
for data in co.find():
    print(data)
