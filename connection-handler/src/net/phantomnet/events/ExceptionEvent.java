package net.phantomnet.events;

import org.vectra.Connection;
import org.vectra.interfaces.Source;

public class ExceptionEvent 
	implements Source {

	private static final long serialVersionUID = 1115366717039652175L;
	private final Connection connection ;
	private final Exception exception;
	
	public ExceptionEvent(final Connection connection, final Exception exception)
			throws IllegalArgumentException {
		this.connection = connection;
		this.exception = exception;
	}
	
	public Connection getConnection() {
		return this.connection;
	}	
	
	public Exception getException() {
		return this.exception;
	}
}
