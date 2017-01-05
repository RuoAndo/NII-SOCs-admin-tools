# JDBC

installing JDBC driver.

<pre>
bash# apt-get install libpostgresql-jdbc-java
bash# apt-get install libpg-java
</pre>

setting classpath.

<pre>
CLASSPATH=$CLASSPATH:/usr/share/java/postgresql-jdbc3-9.2.jar
CLASSPATH=$CLASSPATH:/usr/share/java/postgresql-jdbc4-9.2.jar
export CLASSPATH
</pre>

executing SELECT * FROM pg_stat_database WHERE datname = 'sample';.

<pre>
bash# javac DBStat.java
bash# java DBStat
sample
</pre>