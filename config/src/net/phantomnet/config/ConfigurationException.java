package net.phantomnet.config;

import java.util.logging.Level;

public class ConfigurationException 
	extends Exception {

	/**
	 * Unique ID
	 */
	private static final long serialVersionUID = -4183732652664650929L;

	private final long time = System.currentTimeMillis() ;
	
	private final Level level;
	
	public ConfigurationException (final String error) {
		this(error, Level.SEVERE) ;
	}
	
	public ConfigurationException (final String error, final Level level) {
		super(error) ;
		this.level = level;
	}
	
	public Level getLevel() {
		return this.level;
	}
	
	public long getTime() {
		return this.time;
	}	
}
