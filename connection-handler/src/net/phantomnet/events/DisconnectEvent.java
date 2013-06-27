package net.phantomnet.events;

import org.vectra.Connection;
import org.vectra.Event ;
import org.vectra.interfaces.Encoded;
import org.vectra.interfaces.Events;
import org.vectra.interfaces.Source;

public class DisconnectEvent 
	extends Event
	implements Encoded, Events, Source
{

	private final String message ;
	/**
	 * Unique serial ID
	 */
	private static final long serialVersionUID = -6956388703796537397L;
	
	public DisconnectEvent(final Connection connection) 
			throws IllegalArgumentException {
		this(connection, "UTF-8");
	}
	
	public DisconnectEvent (final Connection connection, final String encoding)
		throws IllegalArgumentException 
	{
		this (connection, "", encoding) ;
	}

	public DisconnectEvent(final Connection connection, final String message, final String encoding)
		throws IllegalArgumentException 
	{
		super(connection, encoding);	
		this.message = message.trim();
	}

	@Override
	public String getEvent() 
	{
		return "DISCONNECT";
	}

	@Override
	public String getMessage() {
		if (this.message.isEmpty())
			throw new UnsupportedOperationException() ;
		return this.message;
	}

	@Override
	public int getType() {
		return E_DISCONNECT;
	}
}
