import java.sql.*;

public class DBStat{
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
	    while (rs.next()) {
		System.out.println(rs.getString(2));
		// i = i + 1;
	    }
	   

	}catch(SQLException e){
	    e.printStackTrace();
	    System.exit(1);
	}
    }
}
