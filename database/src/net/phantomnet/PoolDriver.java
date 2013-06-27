package net.phantomnet;

import java.sql.SQLException;

import net.phantomnet.sql.MySQLConfig;
import net.phantomnet.sql.MySQLConnection;
//import net.phantomnet.sql.pool.MySQLPool;
//import net.phantomnet.sql.pool.MySQLPoolHandler;
//import net.phantomnet.sql.pool.MySQLPooledConnection;

public class PoolDriver {
	public static void main(String[] args) {
		final MySQLConfig config = new MySQLConfig("localhost", "Vectra", "Vectra",
				"d6d4266573ce4c5be550ac9df5d55dd1", 3306);
		
		MySQLConnection connection = null;
		try {
			connection = MySQLConnection.createConnection(config);		
		} catch (SQLException e) {
			System.out.println(e);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try {
			    if (connection != null)
				 connection.close() ;			    
			} catch (SQLException e) {
			    System.out.println(e);
			} finally { 
				System.out.println("Closed existing database connections") ;
			}
		}
	}
}
