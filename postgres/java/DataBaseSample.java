import java.sql.*;

public class DataBaseSample{
    public static void main(String args[]){
	try{
	    Class.forName("org.postgresql.Driver");
	}catch(ClassNotFoundException e){
	    e.printStackTrace();
	    System.exit(1);
	}
	Connection connection;
	try{
	    connection=DriverManager.getConnection("jdbc:postgresql://localhost/sample","postgres","");
	}catch(SQLException e){
	    e.printStackTrace();
	    System.exit(1);
	}
    }
}
