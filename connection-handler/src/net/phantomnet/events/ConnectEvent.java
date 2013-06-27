package net.phantomnet.events;

import org.vectra.Connection;
import org.vectra.Event ;
import org.vectra.interfaces.Events;
import org.vectra.interfaces.Source;

public class ConnectEvent 
	extends Event
	implements Events, Source
{

	/**
	 * Unique serial ID
	 */
	private static final long serialVersionUID = -6956388703796537397L;

	public ConnectEvent (final Connection connection) 
		throws IllegalArgumentException 
	{
		super(connection, "UTF-8");
	}
	public ConnectEvent(final Connection connection, final String encoding)
		throws IllegalArgumentException 
	{
		super(connection, encoding);	
	}

	@Override
	public String getEvent() 
	{
		return "CONNECT";
	}

	@Override
	public String getMessage() {
		throw new UnsupportedOperationException() ;
	}

	@Override
	public int getType() {
		return E_CONNECT;
	}
}
