package org.vectra.irc.exceptions;

public class ChannelConflictException 
	extends Exception {

	/**
	 * Unique ID
	 */
	private static final long serialVersionUID = 4236509612160678017L;
	private final long time ;
	
	public ChannelConflictException () {
		super();
		this.time = System.currentTimeMillis();
	}
	
	public ChannelConflictException(final String message, final Throwable cause) {
		super(message, cause);
		this.time = System.currentTimeMillis();
	}

	public ChannelConflictException(final String message) {
		super(message);
		this.time = System.currentTimeMillis();
	}

	public ChannelConflictException(final Throwable cause) {
		super(cause);
		this.time = System.currentTimeMillis();
	}
	
	public long getTime() {
		return this.time;
	}
}
