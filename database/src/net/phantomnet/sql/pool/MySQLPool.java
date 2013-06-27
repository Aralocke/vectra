package net.phantomnet.sql.pool;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.logging.Level;
import java.util.logging.Logger;

import net.phantomnet.sql.MySQLConfig;

public final class MySQLPool 
{
	private final ReadWriteLock lock = new ReentrantReadWriteLock(true);
	private final LinkedBlockingQueue<MySQLPooledConnection> available = new LinkedBlockingQueue<MySQLPooledConnection>();
	private final MySQLPoolHandler handler;
	private MySQLConfig config;
	private Thread controller;
	private int poolSize ;
	
	public MySQLPool (int poolSize, final MySQLConfig config, final MySQLPoolHandler handler)
		throws SQLException
	{
		this.handler = handler;
		this.config = config;
		getHandler().setPool(this);
		setPoolSize(poolSize);
		setController(new MySQLPoolController(this)) ;
	}	

	public void advertise (final MySQLPooledConnection connection) 
		throws InterruptedException {
		getLock().writeLock().lock();
		try {
			this.available.put(connection) ;
		} finally {
			getLock().writeLock().unlock();
		}
	}
	
	public MySQLConfig getConfig() {
		return this.config;
	}	
	
	public MySQLPooledConnection getConnection()
		throws InterruptedException {
		getLock().readLock().lock();
		try {
			return this.available.take();
		} finally {
			getLock().readLock().unlock();
		}
	}
	
	public MySQLPoolHandler getHandler() {
		return this.handler;
	}
	
	public Thread getController() {
		getLock().readLock().lock();
		try {
			return this.controller;
		} finally {
			getLock().readLock().unlock();
		}
	}
	
	public Collection<MySQLPooledConnection> getList() {
		getLock().readLock().lock();
		try {
			final MySQLPooledConnection[] list = new MySQLPooledConnection[this.available.size()] ;			
			return new ArrayList<MySQLPooledConnection>(Arrays.asList(this.available.toArray(list)));
		} finally {
			getLock().readLock().unlock();
		}
	}
	
	public ReadWriteLock getLock() {
		return this.lock;
	}
	
	public int getPoolSize() {
		getLock().readLock().lock();
		try {
			return this.poolSize;
		} finally {
			getLock().readLock().unlock();
		}
	}
	
	public void remove (final MySQLPooledConnection connection) {
		getLock().writeLock().lock();
		try {
			@SuppressWarnings("unused")
			final boolean deleted = this.available.remove(connection) ;	
		} finally {
			getLock().writeLock().unlock();
		}	
	}
	
	public void setController (final MySQLPoolController controller) {
		getLock().writeLock().lock();
		try {
			this.controller = new Thread(controller);
			this.controller.start();
		} finally {
			getLock().writeLock().unlock();
		}		
	}

	public void setPoolSize (int poolSize) {
		getLock().writeLock().lock();
		try {
			this.poolSize = poolSize;
		} finally {
			getLock().writeLock().unlock();
		}
	}
	
	public void shutdown() 
		throws SQLException {
		if (getController() != null)
			getController().interrupt();
		
		for (final MySQLPooledConnection connection : getHandler().getConnections()) {
			try {
				connection.close();
				Logger.getLogger("net.phantomnet.mysql").log(Level.INFO, "Connection #"+connection.getID()+" has now been closed.");
			} catch (SQLException e) {
				Logger.getLogger("net.phantomnet.mysql").log(Level.WARNING, e.getMessage(), e);
				throw e;
			}
		}			
	}
	
	public String toString() {
		return "[MySQLPool Connections: "+getHandler().getConnections().size()+" Available: "+getList().size()+"]" ;
	}
	
}
