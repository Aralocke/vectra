package org.vectra;

import java.util.Collection;
import java.util.HashMap;
import java.util.IdentityHashMap;
import java.util.LinkedList;
import java.util.Map;

public class ConnectionManager 
{
	/**
     * Maps a Connection to an ID
     */
    private static final Map<Connection, String> connections = new IdentityHashMap<Connection, String> () ;
    
    /**
     * Maps an ID to a connection
     */
    private static final Map<String, Connection> ids = new HashMap<String, Connection>() ;
    
    /**
     * Object to synchronize the class on
     */
    private static final Object lock = new Object() ;
    
    public static final void addConnection (final Connection connection, String id)
        throws IllegalArgumentException
    {
        synchronized (lock)
        {
            if (connections.containsKey(connection))
                    throw new IllegalArgumentException("Supplied connection is already active") ;
            if (ids.containsKey(id))
                    throw new IllegalArgumentException("Supplied id is already active") ;
            
            // register the connection
            connections.put(connection,  id) ;
            // register the ID
            ids.put(id, connection) ;
            
            // name the thread below here
        }
    }
    
    public static final void removeConnection (final Connection connection)
        throws IllegalArgumentException
    {               
        synchronized (lock)
        {
            if (! connections.containsKey(connection))
                throw new IllegalArgumentException("Supplied connection is not active") ;
            
            final String id = getName(connection) ;
            
            if (id == null || ! ids.containsKey(id))
                throw new IllegalArgumentException("Supplied id is not active") ;
    
            // remove the connection
            connections.remove(connection) ;
            // remove the ID
            ids.remove(id) ;
        }
    }
    
    public static final void removeConnection (final String id)
        throws IllegalArgumentException
    {
        synchronized (lock)
        {
            final Connection connection = getConnection(id) ;
            if (connection != null)
                removeConnection(connection) ;
        }
    }
    
    public static final Connection getConnection (String id)
        throws IllegalArgumentException
    {
        if (id == null || id.length() == 0)
            throw new IllegalArgumentException("Supplied id is null or length zero") ;
        
        synchronized (lock) 
        {
            return ids.get(id);
        }
    }

    public static String getName (final Connection connection) 
    {
        synchronized (lock) 
        {
            return connections.get(connection);
        }
    }
    
    public static final Collection<Connection> getConnections ()
    {
        synchronized (lock) 
        {
            return new LinkedList<Connection>(connections.keySet()) ;
        }
    }
    
    public static final Collection<String> getConnectionIDs ()
    {
        synchronized (lock) 
        {
            return new LinkedList<String>(ids.keySet()) ;
        }
    }
}
