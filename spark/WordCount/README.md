# Wordcount

<pre>

hadoop@h-gpu05:~/nii-cyber-security-admin/spark/WordCount$ cat build.sbt
name := "WordCount"
version := "0.1"
scalaVersion := "2.11.12"
libraryDependencies ++=
Seq("org.apache.spark" %% "spark-core" % "2.2.0"
)
hadoop@h-gpu05:~/nii-cyber-security-admin/spark/WordCount$ sbt 'run build.sbt'

(name,1)
(scalaVersion,1)
(2,1)
(libraryDependencies,1)
(apache,1)
(version,1)
(11,1)
20/12/11 20:02:51 INFO SparkUI: Stopped Spark web UI at http://192.168.76.216:4040
20/12/11 20:02:51 INFO MapOutputTrackerMasterEndpoint: MapOutputTrackerMasterEndpoint stopped!
20/12/11 20:02:51 INFO MemoryStore: MemoryStore cleared
20/12/11 20:02:51 INFO BlockManager: BlockManager stopped
20/12/11 20:02:51 INFO BlockManagerMaster: BlockManagerMaster stopped
20/12/11 20:02:51 INFO OutputCommitCoordinator$OutputCommitCoordinatorEndpoint: OutputCommitCoordinator stopped!
20/12/11 20:02:51 INFO SparkContext: Successfully stopped SparkContext
20/12/11 20:02:51 WARN FileSystem: exception in the cleaner thread but it will continue to run
- - 
[success] Total time: 5 s, completed Dec 11, 2020 8:02:51 PM   
					
</pre>