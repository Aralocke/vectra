package net.phantomnet.events;

import org.vectra.Connection;
import net.phantomnet.events.ConnectEvent;
import org.vectra.interfaces.Events;
import org.vectra.interfaces.Source;

public class LogonEvent
	extends ConnectEvent
	implements Events, Source {

	private static final long serialVersionUID = -1988221432430843210L;
	
	public LogonEvent(final Connection connection)
		throws IllegalArgumentException {
		super(connection, "UTF-8");		
	}

	public LogonEvent(final Connection connection, final String encoding)
		throws IllegalArgumentException {
		super(connection, encoding);		
	}

	@Override
	public String getEvent() {
		return "LOGON";
	}

	@Override
	public String getMessage() {
		throw new UnsupportedOperationException();
	}

	@Override
	public int getType() {
		return E_LOGON;
	}

}
