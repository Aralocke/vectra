package org.vectra.exceptions;

public class ConnectionFailedException
	extends Exception
{
	protected long time ;
	public static final long serialVersionUID = 3 ;
	public ConnectionFailedException (final String error)
	{
		super(error) ;
		this.time = System.currentTimeMillis() ;
	}
}