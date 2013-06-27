package net.phantomnet.sql.pool;

import java.sql.Connection;
import java.sql.SQLException;

import net.phantomnet.sql.MySQLConfig;
import net.phantomnet.sql.MySQLConnection;

public class MySQLPooledConnection 
	extends MySQLConnection
{	
	private final int id;
	private final MySQLPool parent;
	private final long age = System.currentTimeMillis();
	private boolean isMarked = false ;
	
	public MySQLPooledConnection(int id, final Connection connection, final MySQLPool parent, final MySQLConfig config)
			throws IllegalArgumentException {
		super(connection, config);
		
		if (parent == null)
			throw new IllegalArgumentException("The parent MySQL Pool cannot be null") ;
		
		this.parent = parent;
		this.id = id;
	}
	
	public final void close() 
		throws SQLException {		
		try {
			super.close();
		} catch (SQLException e) {
			throw e; // pass it on
		} finally {
			// mark the connection so a call to advertise() 
			// won't activate it
			mark();
			// remove from the pool
			getPool().getHandler().removeConnection(getID()) ;
			// remove from the pool queue
			getPool().remove(this) ;	
		}		
	}
	
	public boolean equals (final MySQLPooledConnection connection) {
		return getID() == connection.getID();
	}
	
	public long getAge() {
		return System.currentTimeMillis() - this.age;
	}
	
	public int getID() {
		return this.id;
	}
	
	public final MySQLPool getParent() {
		return this.parent;
	}
	
	public final MySQLPool getPool() {
		return getParent();
	}
	
	public boolean inPool() {
		return getParent().getList().contains(this) ;
	}
	
	public synchronized final boolean isMarked() {
		return this.isMarked;
	}
	
	public synchronized final void mark() {
		mark (!isMarked()) ;		
	}
	
	public synchronized final void mark(final boolean status) {
		this.isMarked = status;		
	}
	
	public final void release ()
		throws InterruptedException {
		if (!isMarked())
			getParent().advertise(this);
	}
	
	public final void safeClose() 
	{
		try {
			this.close();
		} catch (SQLException e) {
			// ignore
		}
	}
}
