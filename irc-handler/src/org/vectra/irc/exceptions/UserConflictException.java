package org.vectra.irc.exceptions;

public class UserConflictException 
	extends Exception {

	/**
	 * Unique ID
	 */
	private static final long serialVersionUID = -8607730237196799669L;
	private final long time ;
	
	public UserConflictException () {
		super();
		this.time = System.currentTimeMillis();
	}
	
	public UserConflictException(final String message, final Throwable cause) {
		super(message, cause);
		this.time = System.currentTimeMillis();
	}

	public UserConflictException(final String message) {
		super(message);
		this.time = System.currentTimeMillis();
	}

	public UserConflictException(final Throwable cause) {
		super(cause);
		this.time = System.currentTimeMillis();
	}
	
	public long getTime() {
		return this.time;
	}
}
