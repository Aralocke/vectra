package org.vectra.irc;
import org.vectra.Message;
import org.vectra.interfaces.Destination;
import org.vectra.interfaces.Encoded;
import org.vectra.irc.IRCConnection;

public final class IRCMessage
	extends Message	
	implements Destination, Encoded
{
	/**
	 * Unique ID
	 */
	private static final long serialVersionUID = 3396177685756317383L;
	
	private final IRCConnection connection ;
	
	public IRCMessage (final String message, final String encoding, IRCConnection connection)
	{
		super (message, encoding, PRIORITY_NORMAL) ;
		this.connection = connection ;
	}
	
	public IRCMessage (final String message, final String encoding, final byte priority, IRCConnection connection)
	{
		super (message, encoding, priority) ;
		this.connection = connection ;
	}
	
	public IRCConnection getConnection()
	{
		return this.connection ;
	}
	
	public String toString ()
	{
		return "[IRCMessage Encoding: "+getEncoding()+" | Message: "+getMessage()+"]" ;
	}

	@Override
	public int compareTo (final Message other) 
	{
		if (this.priority != other.getPriority())
			return priority - other.getPriority() ;
		return other.getNumber() - this.getNumber() ;
	}
}
