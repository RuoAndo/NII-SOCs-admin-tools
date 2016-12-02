# cassandra-cli 
Connected to: "Test Cluster" on 127.0.0.1/9160
Welcome to Cassandra CLI version 2.0.17

The CLI is deprecated and will be removed in Cassandra 2.2.  Consider migrating to cqlsh.
CQL is fully backwards compatible with Thrift data; see http://www.datastax.com/dev/blog/thrift-to-cql3

Type 'help;' or '?' for help.
Type 'quit;' or 'exit;' to quit.

[default@unknown] show keyspaces;           

Keyspace: test:
  Replication Strategy: org.apache.cassandra.locator.SimpleStrategy
  Durable Writes: true
    Options: [replication_factor:2]

デフォルトで作成されるkeyspaceはsystem, system-tracesの２つ

Keyspace: system:
  Replication Strategy: org.apache.cassandra.locator.LocalStrategy
  Durable Writes: true
    Options: []
  Column Families:
    ColumnFamily: IndexInfo
    "indexes that have been completed"
      Key Validation Class: org.apache.cassandra.db.marshal.UTF8Type
      Default column value validator: org.apache.cassandra.db.marshal.BytesType
      Cells sorted by: org.apache.cassandra.db.marshal.UTF8Type
      GC grace seconds: 0
      Compaction min/max thresholds: 4/32
      Read repair chance: 0.0
      DC Local Read repair chance: 0.0
      Populate IO Cache on flush: false
      Replicate on write: true
      Caching: KEYS_ONLY
      Default time to live: 0
      Bloom Filter FP chance: 0.01
      Index interval: 128
      Speculative Retry: 99.0PERCENTILE
      Built indexes: []
      Compaction Strategy: org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy
      Compression Options:
        sstable_compression: org.apache.cassandra.io.compress.LZ4Compressor
    ColumnFamily: NodeIdInfo
    "counter node IDs"
      Key Validation Class: org.apache.cassandra.db.marshal.UTF8Type
      Default column value validator: org.apache.cassandra.db.marshal.BytesType
      Cells sorted by: org.apache.cassandra.db.marshal.TimeUUIDType
      GC grace seconds: 0
      Compaction min/max thresholds: 4/32
      Read repair chance: 0.0
      DC Local Read repair chance: 0.0
      Populate IO Cache on flush: false
      Replicate on write: true
      Caching: KEYS_ONLY
      Default time to live: 0
      Bloom Filter FP chance: 0.01
      Index interval: 128
      Speculative Retry: 99.0PERCENTILE
      Built indexes: []
      Compaction Strategy: org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy
      Compression Options:
        sstable_compression: org.apache.cassandra.io.compress.LZ4Compressor
    ColumnFamily: hints
    "hints awaiting delivery"
      Key Validation Class: org.apache.cassandra.db.marshal.UUIDType
      Default column value validator: org.apache.cassandra.db.marshal.BytesType
      Cells sorted by: org.apache.cassandra.db.marshal.CompositeType(org.apache.cassandra.db.marshal.TimeUUIDType,org.apache.cassandra.db.marshal.Int32Type)
      GC grace seconds: 0
      Compaction min/max thresholds: 4/32
      Read repair chance: 0.0
      DC Local Read repair chance: 0.0
      Populate IO Cache on flush: false
      Replicate on write: true
      Caching: KEYS_ONLY
      Default time to live: 0
      Bloom Filter FP chance: 0.01
      Index interval: 128
      Speculative Retry: 99.0PERCENTILE
      Built indexes: []
      Compaction Strategy: org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy
      Compaction Strategy Options:
        enabled: false
      Compression Options:
        sstable_compression: org.apache.cassandra.io.compress.LZ4Compressor
    ColumnFamily: schema_keyspaces
    "keyspace definitions"
      Key Validation Class: org.apache.cassandra.db.marshal.UTF8Type
      Default column value validator: org.apache.cassandra.db.marshal.BytesType
      Cells sorted by: org.apache.cassandra.db.marshal.UTF8Type
      GC grace seconds: 604800
      Compaction min/max thresholds: 4/32
      Read repair chance: 0.0
      DC Local Read repair chance: 0.0
      Populate IO Cache on flush: false
      Replicate on write: true
      Caching: KEYS_ONLY
      Default time to live: 0
      Bloom Filter FP chance: 0.01
      Index interval: 128
      Speculative Retry: 99.0PERCENTILE
      Built indexes: []
      Column Metadata:
        Column Name: durable_writes
          Validation Class: org.apache.cassandra.db.marshal.BooleanType
        Column Name: strategy_options
          Validation Class: org.apache.cassandra.db.marshal.UTF8Type
        Column Name: strategy_class
          Validation Class: org.apache.cassandra.db.marshal.UTF8Type
      Compaction Strategy: org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy
      Compression Options:
        sstable_compression: org.apache.cassandra.io.compress.LZ4Compressor
Keyspace: system_traces:
  Replication Strategy: org.apache.cassandra.locator.SimpleStrategy
  Durable Writes: true
    Options: [replication_factor:2]
  Column Families:
Keyspace: test:
  Replication Strategy: org.apache.cassandra.locator.SimpleStrategy
  Durable Writes: true
    Options: [replication_factor:2]

# python create_keyspace.py test
2016-12-02 00:54:28,977 [DEBUG] cassandra.cluster: Connecting to cluster, contact points: ['127.0.0.1']; protocol version: 4
2016-12-02 00:54:28,977 [DEBUG] cassandra.io.asyncorereactor: Validated loop dispatch with cassandra.io.asyncorereactor._AsyncorePipeDispatcher
2016-12-02 00:54:28,977 [DEBUG] cassandra.pool: Host 127.0.0.1 is now marked up
2016-12-02 00:54:28,977 [DEBUG] cassandra.cluster: [control connection] Opening new connection to 127.0.0.1
2016-12-02 00:54:28,977 [DEBUG] cassandra.connection: Not sending options message for new connection(16886544) to 127.0.0.1 because compression is disabled and a cql version was not specified
2016-12-02 00:54:28,977 [DEBUG] cassandra.connection: Sending StartupMessage on <AsyncoreConnection(16886544) 127.0.0.1:9042>
2016-12-02 00:54:28,978 [DEBUG] cassandra.connection: Sent StartupMessage on <AsyncoreConnection(16886544) 127.0.0.1:9042>
2016-12-02 00:54:28,978 [DEBUG] cassandra.io.asyncorereactor: Starting asyncore event loop
2016-12-02 00:54:28,979 [DEBUG] cassandra.connection: Defuncting connection (16886544) to 127.0.0.1: <Error from server: code=000a [Protocol error] message="Invalid or unsupported protocol version: 4">
2016-12-02 00:54:28,979 [DEBUG] cassandra.io.asyncorereactor: Closing connection (16886544) to 127.0.0.1
2016-12-02 00:54:28,979 [DEBUG] cassandra.io.asyncorereactor: Closed socket to 127.0.0.1
2016-12-02 00:54:28,979 [WARNING] cassandra.cluster: Downgrading core protocol version from 4 to 3 for 127.0.0.1. To avoid this, it is best practice to explicitly set Cluster(protocol_version) to the version supported by your cluster. http://datastax.github.io/python-driver/api/cassandra/cluster.html#cassandra.cluster.Cluster.protocol_version
2016-12-02 00:54:28,980 [DEBUG] cassandra.connection: Not sending options message for new connection(16886928) to 127.0.0.1 because compression is disabled and a cql version was not specified
2016-12-02 00:54:28,980 [DEBUG] cassandra.connection: Sending StartupMessage on <AsyncoreConnection(16886928) 127.0.0.1:9042>
2016-12-02 00:54:28,980 [DEBUG] cassandra.connection: Sent StartupMessage on <AsyncoreConnection(16886928) 127.0.0.1:9042>
2016-12-02 00:54:28,984 [DEBUG] cassandra.connection: Defuncting connection (16886928) to 127.0.0.1: <Error from server: code=000a [Protocol error] message="Invalid or unsupported protocol version: 3">
2016-12-02 00:54:28,984 [DEBUG] cassandra.io.asyncorereactor: Closing connection (16886928) to 127.0.0.1
2016-12-02 00:54:28,984 [DEBUG] cassandra.io.asyncorereactor: Closed socket to 127.0.0.1
2016-12-02 00:54:28,987 [WARNING] cassandra.cluster: Downgrading core protocol version from 3 to 2 for 127.0.0.1. To avoid this, it is best practice to explicitly set Cluster(protocol_version) to the version supported by your cluster. http://datastax.github.io/python-driver/api/cassandra/cluster.html#cassandra.cluster.Cluster.protocol_version
2016-12-02 00:54:28,988 [DEBUG] cassandra.connection: Not sending options message for new connection(16886544) to 127.0.0.1 because compression is disabled and a cql version was not specified
2016-12-02 00:54:28,988 [DEBUG] cassandra.connection: Sending StartupMessage on <AsyncoreConnection(16886544) 127.0.0.1:9042>
2016-12-02 00:54:28,988 [DEBUG] cassandra.connection: Sent StartupMessage on <AsyncoreConnection(16886544) 127.0.0.1:9042>
2016-12-02 00:54:28,990 [DEBUG] cassandra.connection: Got ReadyMessage on new connection (16886544) from 127.0.0.1
2016-12-02 00:54:28,991 [DEBUG] cassandra.cluster: [control connection] Established new connection <AsyncoreConnection(16886544) 127.0.0.1:9042>, registering watchers and refreshing schema and topology
2016-12-02 00:54:29,000 [DEBUG] cassandra.cluster: [control connection] Refreshing node list and token map using preloaded results
2016-12-02 00:54:29,001 [INFO] cassandra.policies: Using datacenter 'datacenter1' for DCAwareRoundRobinPolicy (via host '127.0.0.1'); if incorrect, please specify a local_dc to the constructor, or limit contact points to local cluster nodes
2016-12-02 00:54:29,001 [DEBUG] cassandra.cluster: [control connection] Finished fetching ring info
2016-12-02 00:54:29,001 [DEBUG] cassandra.cluster: [control connection] Rebuilding token map due to topology changes
2016-12-02 00:54:29,022 [DEBUG] cassandra.metadata: user types table not found
2016-12-02 00:54:29,022 [DEBUG] cassandra.metadata: user functions table not found
2016-12-02 00:54:29,022 [DEBUG] cassandra.metadata: user aggregates table not found
2016-12-02 00:54:29,031 [DEBUG] cassandra.cluster: Control connection created
2016-12-02 00:54:29,032 [DEBUG] cassandra.pool: Initializing new connection pool for host 127.0.0.1
2016-12-02 00:54:29,032 [DEBUG] cassandra.connection: Not sending options message for new connection(139680121352656) to 127.0.0.1 because compression is disabled and a cql version was not specified
2016-12-02 00:54:29,032 [DEBUG] cassandra.connection: Sending StartupMessage on <AsyncoreConnection(139680121352656) 127.0.0.1:9042>
2016-12-02 00:54:29,032 [DEBUG] cassandra.connection: Sent StartupMessage on <AsyncoreConnection(139680121352656) 127.0.0.1:9042>
2016-12-02 00:54:29,036 [DEBUG] cassandra.connection: Got ReadyMessage on new connection (139680121352656) from 127.0.0.1
2016-12-02 00:54:29,040 [DEBUG] cassandra.connection: Not sending options message for new connection(139680121353360) to 127.0.0.1 because compression is disabled and a cql version was not specified
2016-12-02 00:54:29,040 [DEBUG] cassandra.connection: Sending StartupMessage on <AsyncoreConnection(139680121353360) 127.0.0.1:9042>
2016-12-02 00:54:29,040 [DEBUG] cassandra.connection: Sent StartupMessage on <AsyncoreConnection(139680121353360) 127.0.0.1:9042>
2016-12-02 00:54:29,042 [DEBUG] cassandra.connection: Got ReadyMessage on new connection (139680121353360) from 127.0.0.1
2016-12-02 00:54:29,044 [DEBUG] cassandra.pool: Finished initializing new connection pool for host 127.0.0.1
2016-12-02 00:54:29,044 [DEBUG] cassandra.cluster: Added pool for host 127.0.0.1 to session
2016-12-02 00:54:29,044 [INFO] root: creating keyspace...
2016-12-02 00:54:29,088 [DEBUG] cassandra.connection: Message pushed from server: <EventMessage(event_type=u'SCHEMA_CHANGE', trace_id=None, event_args={'keyspace': u'test', 'change_type': u'CREATED', 'target_type': 'KEYSPACE'}, stream_id=-1)>
2016-12-02 00:54:29,092 [DEBUG] cassandra.cluster: Refreshing schema in response to schema change. {'keyspace': u'test', 'change_type': u'CREATED', 'target_type': 'KEYSPACE'}
2016-12-02 00:54:29,092 [DEBUG] cassandra.cluster: [control connection] Waiting for schema agreement
2016-12-02 00:54:29,102 [DEBUG] cassandra.cluster: [control connection] Schemas match
2016-12-02 00:54:29,107 [DEBUG] cassandra.metadata: user types table not found
2016-12-02 00:54:29,107 [INFO] root: setting keyspace...
2016-12-02 00:54:29,110 [DEBUG] cassandra.io.asyncorereactor: Waiting for event loop thread to join...
2016-12-02 00:54:29,210 [DEBUG] cassandra.io.asyncorereactor: Asyncore event loop ended
2016-12-02 00:54:29,228 [DEBUG] cassandra.io.asyncorereactor: Event loop thread was joined
2016-12-02 00:54:29,253 [DEBUG] cassandra.cluster: Shutting down Cluster Scheduler
2016-12-02 00:54:29,289 [DEBUG] cassandra.cluster: Shutting down control connection
2016-12-02 00:54:29,289 [DEBUG] cassandra.io.asyncorereactor: Closing connection (16886544) to 127.0.0.1
2016-12-02 00:54:29,289 [DEBUG] cassandra.io.asyncorereactor: Closed socket to 127.0.0.1
2016-12-02 00:54:29,289 [DEBUG] cassandra.io.asyncorereactor: Closing connection (139680121352656) to 127.0.0.1
2016-12-02 00:54:29,290 [DEBUG] cassandra.io.asyncorereactor: Closed socket to 127.0.0.1
2016-12-02 00:54:29,290 [DEBUG] cassandra.io.asyncorereactor: Closing connection (139680121353360) to 127.0.0.1
2016-12-02 00:54:29,290 [DEBUG] cassandra.io.asyncorereactor: Closed socket to 127.0.0.1