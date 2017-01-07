package com.sample;

// import java.sql.*;

/*
import com.appdynamics.TaskInputArgs;
import com.appdynamics.extensions.conf.MonitorConfiguration;
import com.appdynamics.extensions.crypto.CryptoUtil;
*/

import com.google.common.base.Strings;
import com.google.common.collect.Maps;
import org.apache.log4j.Logger;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class App 
{
    /*
    private Stat stat;

    private List<String> getColumnNames(Stat stat) {

	List<String> columnNames = new ArrayList<String>();
	Metric[] metrics = stat.getMetrics();

	for (Metric metric : metrics) {
	    columnNames.add(metric.getColumnName());
	}

	return columnNames;
    }
    */
    public static void main(String args[]){
	try{
	    Class.forName("org.postgresql.Driver");
	}catch(ClassNotFoundException e){
	    e.printStackTrace();
	    System.exit(1);
	}
	Connection connection;
	Statement stmt = null;
	ResultSet rs = null;

	try{
	    connection=DriverManager.getConnection("jdbc:postgresql://localhost/sample","postgres","");

	    stmt = connection.createStatement();

	    rs = stmt.executeQuery("SELECT * FROM pg_stat_database WHERE datname = 'sample';");

	    /*
	    [(16384, 'sample', 1, 686856L, 79L, 33152L, 70569692L, 5002119449L, 122275L, 673987L, 822L, 1829L, 0L, 0L, 0L, 0L, 0.0, 0.0, datetime.datetime(2016, 12, 29, 13, 31, 38, 934981, tzinfo=psycopg2.tz.FixedOffsetTimezone(offset=540, name=None)))]
	    */
	    
	    while (rs.next()) {
		System.out.println("dataid: " + rs.getString(1));
		System.out.println("dataname: " + rs.getString(2));
		System.out.println("numblockends: " + rs.getString(3));
		System.out.println("xact-commit: " + rs.getString(4));
		System.out.println("xact-rollback: " + rs.getString(5));
		System.out.println("blks-read: " + rs.getString(6));
		System.out.println("blks-hit: " + rs.getString(7));
		System.out.println("tup-returned: " + rs.getString(8));
		System.out.println("tup-fetched: " + rs.getString(9));
		System.out.println("tup-inserted: " + rs.getString(10));
		System.out.println("tup-updated: " + rs.getString(11));
		System.out.println("tup-deleted: " + rs.getString(12));

		// i = i + 1;
	    }

	}catch(SQLException e){
	    e.printStackTrace();
	    System.exit(1);
	}
    }
    
    /*
    public static void main( String[] args )
    {
        System.out.println( "Hello World!" );
    }
    */
}
