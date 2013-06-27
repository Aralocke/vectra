package org.vectra.modules;

import net.phantomnet.events.LogonEvent;

import org.vectra.Connection;
import org.vectra.Event;
import org.vectra.Module;
import org.vectra.irc.IRCBotConfig;
import org.vectra.irc.IRCConnection;

public class AutoModeOnConnect
	extends Module {

	public AutoModeOnConnect(final Integer id) {
		super("AutoModeOnConnect", id, E_LOGON, PACK_CORE, "", false);
	}

	@Override
	public boolean matches(final Event event) {
		return true;
	}

	@Override
	public void beforeExecution(Event event) {}

	@Override
	public void execute(final Event event) {
		final IRCConnection connection = (IRCConnection) event.getConnection();
		final LogonEvent ircEvent = (LogonEvent) event;
		if ((connection instanceof Connection) && (ircEvent instanceof Event)) {
			if (!connection.isDisconnected()) {
				final IRCBotConfig config = connection.getConfig();
				if (config.getAutoModes().isEmpty()) {
					connection.changeMode(config.getNick(), IRCBotConfig.DEFAULT_MODES, event.getEncoding());
				} else {
					connection.changeMode(config.getNick(), config.getAutoModes(), event.getEncoding());
				}
			}
		}
	}

	@Override
	public void afterExecution(Event event) {}

	@Override
	public Module getInstance() {
		return new AutoModeOnConnect(getID());
	}
}
