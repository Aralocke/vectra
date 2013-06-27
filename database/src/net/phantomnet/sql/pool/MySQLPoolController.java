package net.phantomnet.sql.pool;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

public class MySQLPoolController
	implements Runnable {

	public static final long SLEEP_TIME = 60000;
	private final MySQLPool pool;
	private final long sleepTime ;
	
	public MySQLPoolController (final MySQLPool pool) {
		this(SLEEP_TIME, pool) ;
	}
	
	public MySQLPoolController (final long sleepTime, final MySQLPool pool) {
		this.pool = pool;
		this.sleepTime = sleepTime;
	}
	
	public MySQLPool getPool() {
		return this.pool;
	}
	
	public long getSleepTime() {
		return this.sleepTime;
	}
	
	@SuppressWarnings("unused")
	public void run() {
		boolean isRunning = true;
		while (isRunning) {
			final ArrayList<MySQLPooledConnection> connections = getPool().getHandler().getConnections();
			
			if (connections.size() > 0) {
				for (final MySQLPooledConnection connection : connections) {
					if (!connection.isActive()) {
						Logger.getLogger("net.phantomnet.mysql").log(Level.INFO, "Removing stale connection #"+connection.getID()) ;
						try {
							connection.close();
						} catch (SQLException e) {
							// ignore - we're closing anyhow
						} finally {
							// remove from the pool
							getPool().getHandler().removeConnection(connection.getID()) ;
							// remove from the pool queue
							getPool().remove(connection) ;							
						}
					} // if
				} // for
			} // if
			
			while (getPool().getHandler().getConnections().size() < getPool().getPoolSize())
				try { // create a new replacement		
					final MySQLPooledConnection connection = getPool().getHandler().createConnection(getPool().getConfig()) ;	
					// getPool().getHandler().createConnection(getPool().getConfig()) ;
					//System.out.println("\t"+getPool()) ;
					//if (connection == null)
					//	System.out.println("Failed to create a new Connection");
					Logger.getLogger("net.phantomnet.mysql").log(Level.CONFIG, "Created a new connection ("+
							getPool().getHandler().getConnections().size()+"/"+getPool().getPoolSize()+")");
				} catch (SQLException e) {
					Logger.getLogger("net.phantomnet.mysql").log(Level.WARNING, e.getMessage(), e);
				} finally {
					try { // sleep after creating (or failing) on new connections - don't spam the server
						Thread.sleep(1000) ;
					} catch (InterruptedException e) {}
				}
			
			try {
				Thread.sleep(getSleepTime());
			} catch (InterruptedException e) {}
		}
		//System.out.println("Controller has exited") ;
	}// run()

}
