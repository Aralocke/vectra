package net.phantomnet.sql;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import net.phantomnet.groupings.Pair;

public class MySQLConnection 
{
	private final Connection connection ;
	private final MySQLConfig config;
	
	public MySQLConnection (final Connection connection, final MySQLConfig config)
		throws IllegalArgumentException
	{
		if (!(connection instanceof java.sql.Connection))
			throw new IllegalArgumentException("The parent connection must be of the type java.sql.Connection") ;
		
		this.connection = connection;
		this.config = config;
	}	
	
	public void close() 
		throws SQLException 
	{
		try {
			getConnection().close();
		} catch (SQLException e) {
			throw e;
		}
	}
	
	public MySQLConnection createConnection() 
		throws IllegalStateException, SQLException, Exception {
		if (!isActive())
			throw new IllegalStateException("Cannot create a child connection because this connection is not connected");
		
		return MySQLConnection.createConnection(getConfig());
	}
	
	public static MySQLConnection createConnection (final MySQLConfig config)
    	throws SQLException, Exception
    {    	
    	Connection connection = null;
    	try {
    		Class.forName("com.mysql.jdbc.Driver").newInstance() ;   		
    		connection = DriverManager.getConnection("jdbc:mysql://"+config.getHost()+":"+config.getPort()+"/"+
    				config.getName(), config.getUser(), config.getPass()) ;

    		if (connection.isClosed())
    			connection = null;
    	} catch (SQLException e) {
    		throw e; // If an SQLException occurs, throw it
    	} catch (Exception e) {
    		// otherwise ignore the exception and move on
    		throw e;
    	} 
		if (connection != null) 
			//System.out.printf("Successfully connected as %s@%s:%s to database %s.\n", config.getUser(), 
			//		config.getHost(), config.getPort(), config.getName());
			return new MySQLConnection(connection, config);		
		return null;    	  	
    }
	
	public int execute (final String query)
		throws IllegalArgumentException, SQLException {

		if (query == null || query.length() < 7)
			throw new IllegalArgumentException("The qury cannot be null or length less than 7");

		final Statement statement = getConnection().createStatement();
		try {
			return statement.executeUpdate(query.trim()) ;
		} finally {
			statement.close();
		}
	}
	
	public Connection getConnection () {
		return this.connection ;
	}
	
	public MySQLConfig getConfig ()	{
		return this.config;
	}
	
	public int insert(final String table, ArrayList<Pair<String, String>> keyValues) 
		throws IllegalArgumentException, SQLException 
	{
		if (table == null || table.length() < 1)
			throw new IllegalArgumentException("The table name must be one character or more") ;
		if (keyValues.size() < 1)
			throw new IllegalArgumentException("The values list must contain at least one pair of keys and values.");
		
		final String header = "INSERT INTO `"+getConfig().getName()+"`.`"+table.trim()+"`" ;
		final StringBuilder keys = new StringBuilder();
		final StringBuilder values = new StringBuilder();
		for (int i = 0; i < keyValues.size(); i++)
		{
			final Pair<String, String> pair = keyValues.get(i);
			if (i == 0) {				
				if (i == (keyValues.size() - 1)) { // first and only
					keys.append("`"+pair.getKey()+"`");
					values.append("`"+pair.getValue()+"`") ;
				} else { // first and not alone
					keys.append("`"+pair.getKey());
					values.append("`"+pair.getValue()) ;
				}
			} else {
				if (i > 0 && i < (keyValues.size() - 1)) { // add the commas
					keys.append("`, `");
					values.append("`, `");
				}
				if (i == (keyValues.size() - 1)) { // last
					keys.append(pair.getKey()+"`");
					values.append(pair.getValue()+"`");
				} else { // middle keys
					keys.append(pair.getKey());
					values.append(pair.getValue());
				}
			} // else
		} // for
		return execute(header+" ("+keys.toString()+") VALUES ("+values.toString()+")");
	}
	
	public int insert(final String table, List<ArrayList<Pair<String, String>>> values)
		throws IllegalArgumentException, SQLException 
	{
		if (values.size() < 2)
			insert(table, values.get(0)) ;
		if (table == null || table.length() < 1)
			throw new IllegalArgumentException("The table name must be one character or more") ;
		
		final StringBuilder sb = new StringBuilder("INSERT INTO `"+getConfig().getName()+"`.`"+table.trim()+"` ");
		
		return execute(sb.toString());
	}
	
	public boolean isActive () {
		final String query = "/* ping */ SELECT 1" ;
		ResultSet result = null ;
        Statement statement = null;
        try {
        	statement = getConnection().createStatement();
            result = statement.executeQuery(query) ; 
            return true;
        } catch (SQLException e) {
        	return false;
        } finally {
        	try {
        		if (result != null)
            		result.close();
        		if (statement != null)
        			statement.close();
        	} catch (Exception e) {}
        }
	}	
	
	public PreparedStatement prepareStatement (final String query)
		throws SQLException {
		return getConnection().prepareStatement(query) ;
	}
	
	public void safeClose() 
	{
		try {
			getConnection().close();
		} catch (SQLException e) {
			// ignore
		}
	}
	
    public ResultSet select (String query)
    {
        ResultSet result = null ;
        Statement statement = null;
        try {        
        	statement = getConnection().createStatement();
            result = statement.executeQuery(query) ;            
        } catch (Exception e) { 
        	result = null;
        } finally {
        	if (result != null)
        		try {
        			if (!result.next())
            			result.close() ; 
        		} catch (Exception e) {}
        } try {
        	return result.isClosed() ? null : result ;
        } catch (Exception e) {
        	return null;
        } finally {
        	try {
        		if (statement != null)
            		statement.close();
        	} catch (Exception e) {
        		// ignore
        	}
        }
    }
    
    public int update(final String table, ArrayList<Pair<String, String>> settings, 
    		ArrayList<Pair<String, String>> where) {
		return 0;
	}
}
