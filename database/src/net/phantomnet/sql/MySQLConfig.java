package net.phantomnet.sql;

import java.io.Serializable;

public final class MySQLConfig 
	implements Serializable
{

	/**
	 * Unique Class ID
	 */
	private static final long serialVersionUID = 5740855090377451474L;
	
	/**
	 * The value containing the most frequent default Database Host name; localhost.
	 */
	public static final String DEFAULT_HOST = "localhost";
	
	/**
	 * The value containing the most frequent default Database Port; 3306.
	 */
	public static final int DEFAULT_PORT = 3306;  
	
	private final int dbport ;
	private final String dbname ;
	private final String dbuser ;
	private final String dbpass ;
	private final String dbhost ;
	
	public MySQLConfig (final String dbname, final String dbuser, final String dbpass)
		throws IllegalArgumentException
	{
		this (DEFAULT_HOST, dbname, dbuser, dbpass) ;
	}
	
	public MySQLConfig (final String dbhost, final String dbname, final String dbuser, 
			final String dbpass)
		throws IllegalArgumentException
	{
		this (dbhost, dbname, dbuser, dbpass, DEFAULT_PORT) ;
	}
	
	public MySQLConfig (final String dbhost, final String dbname, final String dbuser, 
			final String dbpass, final int dbport)
		throws IllegalArgumentException
	{
		if (dbhost == null || dbhost.length() < 3)
			throw new IllegalArgumentException("The database host cannot be null or length less than 3") ;
		if (dbname == null || dbname.length() < 1)
			throw new IllegalArgumentException("The database name cannot be null or length less than 1") ;
		if (dbuser == null || dbuser.length() < 1)
			throw new IllegalArgumentException("The database user cannot be null or length less than 1") ;
		if (dbpass == null)
			throw new IllegalArgumentException("The database host cannot be null") ;
		if (dbport > 65553 || dbport < 0)
			throw new IllegalArgumentException("The database port must be between 65,553 and zero") ;
		
		this.dbhost = dbhost.trim();
		this.dbname = dbname.trim();
		this.dbuser = dbuser.trim();
		this.dbpass = dbpass.trim();
		this.dbport = dbport;
	}
	
	public String getHost () {
		return this.dbhost;
	}
	
	public String getName () {
		return this.dbname;
	}
	
	public String getPass () {
		return this.dbpass;
	}
	
	public int getPort () {
		return this.dbport;
	}

	public String getUser () {
		return this.dbuser;
	}
}
