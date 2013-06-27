package org.vectra.modules;
import net.phantomnet.events.ConnectEvent;

import org.vectra.Event;
import org.vectra.Module;
import org.vectra.interfaces.Source;
import org.vectra.irc.IRCConnection;

public class OperOnConnect
	extends Module {

	public OperOnConnect(final Integer id) {
		super("OperOnConnect", id, E_LOGON, PACK_CORE, "", false);
	}
	
	@Override
	public OperOnConnect getInstance() {
		return new OperOnConnect(getID());
	}

	@Override
	public boolean matches(final Event event) {
		final ConnectEvent connectionEvent = (ConnectEvent) event;
		final IRCConnection connection = (IRCConnection) connectionEvent.getConnection();
		return ((connectionEvent instanceof Source) && (connection instanceof IRCConnection));
	}

	@Override
	public void beforeExecution(Event event) {
		
	}

	@Override
	public void execute(Event event) {
		final ConnectEvent connectionEvent = (ConnectEvent) event;
		final IRCConnection connection = (IRCConnection) connectionEvent.getConnection();
		
		if ((connectionEvent instanceof Source) && (connection instanceof IRCConnection)) {
			final String operName = connection.getConfig().getDirective("oper_name");
			final String operPass = connection.getConfig().getDirective("oper_pass");
			if ((operName != null && !operName.isEmpty()) && (operPass != null && !operPass.isEmpty())) {
				connection.send("OPER "+operName+" "+operPass, PRIORITY_EMERGENCY) ;
			}
		}
	}

	@Override
	public void afterExecution(Event event) {
		
	}

}
