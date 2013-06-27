package org.vectra;

import java.util.Collection;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.logging.Level;
import java.util.logging.Logger;

import net.phantomnet.events.DisconnectEvent;
import net.phantomnet.observer.DisconnectObserver;

import org.vectra.ConnectionManager ;
import org.vectra.Core ;
import org.vectra.exceptions.ConnectionFailedException;

public class ConnectionHandler 
	implements DisconnectObserver, Runnable
{
	public static final int MAX_RECONNECT = 99 ;
	
	public void run ()
	{
		Logger.getLogger("net.phantomnet").log(Level.INFO, "ConnectionHandler started. Now monitoring "+ConnectionManager.getConnections().size()+" connections.") ;
		try
		{
			while (Core.isRunning())
			{
				try {
					final DisconnectEvent event = disconnectQueue.poll(Config.CONNECTION_CHECK_INTERVAL, Config.CHECK_INTERVAL_UNIT);
					if (event != null) {
						final Connection connection = event.getConnection();
						reconnect(connection);						
					}
				} catch (InterruptedException e) {}
				
				// Grab the known connections from the COnnectionManager
				final Collection<Connection> connections = ConnectionManager.getConnections() ;
				// debug output
				// System.out.println("Running cleanup and maintenance on "+ConnectionManager.getConnections().size()+" connections.") ;
				// Move on if the list is empty
				if (connections.size() == 0)
					continue ;
				// loop through the connection handling any issues
				for (final Connection connection : connections) {
					// Check for reconnect attempts first
					//System.out.println("Connection "+connection.getConfig().getConnID()+" is "+
					//   (connection.isDisconnected()?"Disconnected":"Connected"));
					if (connection.isDisconnected()) {
						reconnect(connection);
					} // if (connection.isD ...
				} // for (final Conn  ...
			} // while (Core.isR ...
		} catch (Exception e) {
			// ignore
		}
		System.out.println("Connection Handler has ended.");
	}
	
	private void reconnect (final Connection connection) 
	{
		final String connID = connection.getConfig().getConnID() ;
		// Max reconnect attempts for now is a static number
		if (connection.getConfig().getReconnectCount() > MAX_RECONNECT)
		{							
			System.out.println("Removing connection with ConnID: "+connID) ;
			// pass the connection ID to the ConnectionManager
			ConnectionManager.removeConnection(connection.getConfig().getConnID()) ;
		} // if (connection.getC ...
		else
		{
			System.out.println("Attempting to reconnect "+connID+" this is attempt #"+connection.getConfig().incrementReconnectCount()) ;
			try {
				// port from the config
				final int port = connection.getConfig().getPort() ;
				// new random server from the config
				final String server = connection.getConfig().getAvailableServer() ;
				// initiate a connection
				connection.connect(server, port) ;
				// if we reach this point, no exception was thrown on connection
			} catch (IllegalStateException e) {
				System.out.println("EXCEPTION :: "+e) ;
			} catch (ConnectionFailedException e) {
				System.out.println("EXCEPTION :: "+e) ;
			}
		} //else
	}

	private final LinkedBlockingQueue<DisconnectEvent> disconnectQueue = new LinkedBlockingQueue<DisconnectEvent>();
	
	public void observeDisconnect(final DisconnectEvent event) {
		System.out.println("Disconnect observed!");
		disconnectQueue.offer(event);
	}
}
