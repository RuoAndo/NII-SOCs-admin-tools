package com.sample;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Host;
import com.datastax.driver.core.Metadata;
import com.datastax.driver.core.Session;
import com.datastax.driver.core.*;
import static java.lang.System.out;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
	String serverIP = "127.0.0.1";
	String keyspace = "system";

	Cluster cluster = Cluster.builder()
	    .addContactPoints(serverIP)
	    .build();

	Session session = cluster.connect(keyspace);
       
	String cqlStatement = "SELECT * from system.schema_keyspaces;";
	ResultSet resultSet = session.execute(cqlStatement);

	for (Row row : resultSet)
	    System.out.println(row);

    }
}
