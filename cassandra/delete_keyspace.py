import logging
import sys

argvs = sys.argv                                                                                                         
ksname = argvs[1] 

log = logging.getLogger()
log.setLevel('DEBUG')
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(name)s: %(message)s"))
log.addHandler(handler)

from cassandra import ConsistencyLevel
from cassandra.cluster import Cluster
from cassandra.query import SimpleStatement

KEYSPACE = ksname


def main():
    cluster = Cluster(['127.0.0.1'])
    session = cluster.connect()

    session.execute("DROP KEYSPACE " + KEYSPACE)

if __name__ == "__main__":
    main()
