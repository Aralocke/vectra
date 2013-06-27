package org.vectra;

import java.util.ArrayList;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import net.phantomnet.sql.MySQLConfig;
import org.vectra.irc.IRCBotConfig;

public final class Config {
	// MySQL Information
	private static final String dbhost = "localhost" ;
	private static final String dbuser = "Vectra" ;
	private static final String dbpasswd = "d6d4266573ce4c5be550ac9df5d55dd1" ;
	private static final String dbname = "Vectra" ;
	private static final int dbport = 3306;
	
	public static MySQLConfig getMySQLConfig() {
		return new MySQLConfig(dbhost, dbname, dbuser, dbpasswd, dbport) ;
	}
	
	// BotConfig Related information
	private static final AtomicInteger idGenerator = new AtomicInteger();
	
	private static final AtomicInteger familyIdGenerator = new AtomicInteger();
	
	public static int getNewSequentialID() {
		return Math.abs(idGenerator.getAndIncrement());
	}
	
	public static int getNewFamilyID() {
		return Math.abs(familyIdGenerator.getAndIncrement());
	}
	
	// interval to check for inactive connections
	public final static TimeUnit CHECK_INTERVAL_UNIT = TimeUnit.MILLISECONDS;
	public final static long CONNECTION_CHECK_INTERVAL = 60000;
	
	// Create the individual BotCOnfigs that will be loaded
	private final static ArrayList<BotConfig> botConfigs = new ArrayList<BotConfig>();
	
	
	static {
		// this is where we register the administrator connection 
		// if only one bot is needed, the administrator can function
		// as a full bot, but also provides access to all logging
		// utilities needed
		final IRCBotConfig config3 = new IRCBotConfig(getNewSequentialID(), getNewFamilyID(), true, 
		    "2001::4");
		config3.setNick("Vectra") ;
		config3.setIdent("Vectra") ;
		config3.setRealName("Vectra");
		config3.setAutoModes("+piBT");
		config3.setNetwork("SwiftIRC") ;
		config3.setAutoJoin("#vectra");
		config3.setServers(new String[] {"intrepid.il.us.swiftirc.net", "lunas.fr.eu.swiftirc.net"}) ;
		config3.setStaffChannel("#vectra") ;
		config3.setLogChannel("#vectra") ;
		config3.setServerPort(6667);
		config3.setPassword("abcdefgh") ;
		config3.denyModule("OperOnConnect");		
		config3.useIdentd(true);
		botConfigs.add(config3) ;
		
		final IRCBotConfig config4 = new IRCBotConfig(getNewSequentialID(), getNewFamilyID(), 
		    "2001::4");
		config3.setNick("Vectra") ;
		config3.setIdent("Vectra") ;
		config3.setRealName("Vectra");
		config3.setAutoModes("+piBT");
		config3.setNetwork("synIRC") ;
		config3.setAutoJoin("#vectra");
		config3.setServers(new String[] {"atlantis.synirc.net", "destiny.synirc.net"}) ;
		config3.setStaffChannel("#vectra") ;
		config3.setLogChannel("#vectra") ;
		config3.setServerPort(6667);
		config3.setPassword("abcdefgh") ;
		config3.denyModule("OperOnConnect");		
		config3.useIdentd(true);
		botConfigs.add(config4) ;
		
		botConfigs.trimToSize();
	}
	
	public static ArrayList<BotConfig> getBotConfigs() {
		return botConfigs;
	}
}
