# installing maven

from epel-apache-maven

<pre>
sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install -y apache-maven
mvn --version
</pre>

creating maven template project.

<pre>
mvn archetype:generate \
      -DarchetypeArtifactId=maven-archetype-quickstart \
      -DinteractiveMode=false \
      -DgroupId=com.sample \
      -DartifactId=hello
</pre>

compile and execute.

<pre>
mvn compile
java -cp target/classes/ com.sample.App
</pre>

adding dependencies.

<pre>
<xmp>

  <name>hello</name>
  <url>http://maven.apache.org</url>

  <build>
  <plugins>
        <plugin>
	<groupId>org.codehaus.mojo</groupId>
	<artifactId>exec-maven-plugin</artifactId>
	<configuration>
	<mainClass>com.sample.App</mainClass>
	</configuration>
	</plugin>
  </plugins>
  </build>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>

    <dependency>
        <groupId>com.datastax.cassandra</groupId>
	  <artifactId>cassandra-driver-core</artifactId>
	    <version>2.1.3</version>
    </dependency>

    <dependency>
        <groupId>com.datastax.cassandra</groupId>
	  <artifactId>cassandra-driver-mapping</artifactId>
	    <version>2.1.2</version>
    </dependency>

    <dependency>
    <groupId>log4j</groupId>
    <artifactId>log4j</artifactId>
    <version>1.2.17</version>
    </dependency>

    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-log4j12</artifactId>
      <version>1.4.2</version>
    </dependency>

  </dependencies>
</project>

</xmp>
</pre>

mvn exec:java.

<pre>
[INFO] --- exec-maven-plugin:1.5.0:java (default-cli) @ hello ---
log4j:WARN No appenders could be found for logger (com.datastax.driver.core.SystemProperties).
log4j:WARN Please initialize the log4j system properly.
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
Row[test, true, org.apache.cassandra.locator.SimpleStrategy, {"replication_factor":"2"}]
Row[system, true, org.apache.cassandra.locator.LocalStrategy, {}]
Row[system_traces, true, org.apache.cassandra.locator.SimpleStrategy, {"replication_factor":"2"}]
</pre>