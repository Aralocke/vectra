package net.phantomnet.sql.pool;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.IdentityHashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import net.phantomnet.sql.MySQLConfig;
import net.phantomnet.sql.pool.MySQLPooledConnection;

public final class MySQLPoolHandler 
{
	/**
	 * Contains a thread safe reference to the next Integer ID
	 */
	private final AtomicInteger counter = new AtomicInteger() ;
	
	/**
     * Maps a Connection to an ID
     */
    private final Map<MySQLPooledConnection, Integer> connections = new IdentityHashMap<MySQLPooledConnection, Integer> () ;
    
    /**
     * Maps an ID to a connection
     */
    private final Map<Integer, MySQLPooledConnection> ids = new HashMap<Integer, MySQLPooledConnection>() ;
    
    /**
     * Object to synchronize the class on
     */
    private final Object lock = new Object() ;
    
    /**
     * Contains a working reference to the MySQL Pool object that 
     * the instance of this class belongs too.
     */
	private MySQLPool pool;
    
	public void addConnection (final MySQLPooledConnection connection, final Integer id)
	    throws IllegalArgumentException {
	    synchronized (lock) {
	        if (connections.containsKey(connection))
	            throw new IllegalArgumentException("Supplied connection is already active") ;
	        if (ids.containsKey(id))
	        	throw new IllegalArgumentException("Supplied id is already active") ;
	        // register the connection with the pool
	        try {
				getPool().advertise(connection) ;
			} catch (InterruptedException e) {}
	        // register the connection
	        connections.put(connection,  id) ;
	        // register the ID
	        ids.put(id, connection) ;	        
	    }   	
	}
	
	public MySQLPooledConnection createConnection (final MySQLConfig config)
		throws IllegalStateException, SQLException
	{    	
		if (getPool() == null)
			throw new IllegalStateException("The parent pool cannot reference null") ;
		
		Connection connection = null;
		try {
			Class.forName("com.mysql.jdbc.Driver").newInstance() ;   		
			connection = DriverManager.getConnection("jdbc:mysql://"+config.getHost()+":"+config.getPort()+"/"+
					config.getName(), config.getUser(), config.getPass()) ;
			
			final int id = counter.getAndIncrement();
			// If connection is closed, move one
			// save the var to null - by now an 
			// exception should be thrown anyhow
			if (connection.isClosed())
				connection = null;
			else // if it succeeded add it to the class
				addConnection(new MySQLPooledConnection(id, connection, getPool(), config), id) ;
		} catch (SQLException e) {
			throw e; // If an SQLException occurs, throw it
		} catch (Exception e) {} // otherwise ignore the exception and move on
		if (connection != null)
			return getConnection(counter.get() - 1);
		return null;
	}

	public MySQLPooledConnection getConnection (final int id)
	    throws IllegalArgumentException {
	    if (id < 0)
	        throw new IllegalArgumentException("Supplied id cannot be less than zero") ;
        
        synchronized (lock) {
            return ids.get(id);
        }
    }

	public ArrayList<MySQLPooledConnection> getConnections () {
	    synchronized (lock) {
	        return new ArrayList<MySQLPooledConnection>(connections.keySet()) ;
	    }
	}

	public Collection<Integer> getConnectionIDs () {
	    synchronized (lock) {
	        return new LinkedList<Integer>(ids.keySet()) ;
	    }
	}
	
	public MySQLPool getPool () {
		synchronized (lock) {
			return this.pool;
		}
	}

	public int getName (final MySQLPooledConnection connection) {
	    synchronized (lock) {
	        return connections.get(connection);
	    }
	}

	public int getPoolSize() {
		return getConnections().size();
	}
	
	public void removeConnection (final MySQLPooledConnection connection)
        throws IllegalArgumentException
    {               
        synchronized (lock)
        {
            if (!connections.containsKey(connection))
                throw new IllegalArgumentException("Supplied connection is not active") ;
            
            final int id = connection.getID() ;
            
            if (!ids.containsKey(id))
                throw new IllegalArgumentException("Supplied id is not active") ;
    
            // remove the connection
            connections.remove(connection) ;
            // remove the ID
            ids.remove(id) ;
        }
    }
    
    public void removeConnection (final Integer id)
        throws IllegalArgumentException
    {
        synchronized (lock)
        {
            final MySQLPooledConnection connection = getConnection(id) ;
            if (connection != null)
                removeConnection(connection) ;
        }
    }
    
    public void setPool (final MySQLPool pool) 
    	throws IllegalArgumentException {
    	if (pool == null)
    		throw new IllegalArgumentException("The supplied MySQLPool cannot be null") ;
    	
    	synchronized (lock) {
    		this.pool = pool;
    	}
    }
}
