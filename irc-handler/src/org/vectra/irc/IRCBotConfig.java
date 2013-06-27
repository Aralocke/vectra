package org.vectra.irc;

import java.util.Comparator;
import java.util.List;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import net.phantomnet.config.ConfigBlock;
import net.phantomnet.config.ConfigurationException;

import org.vectra.BotConfig;
import org.vectra.Connection;
import org.vectra.StrUtils;
import org.vectra.irc.casemapping.CasemappingASCII;
import org.vectra.interfaces.Source;
import org.vectra.interfaces.Named;

public final class IRCBotConfig 
	extends BotConfig
	implements Source, Named
{
	
	/**
	 * Unique Identifier
	 */
	private static final long serialVersionUID = 4054448099815792497L;
    
    /**
     * Default Modes
     * Modes +pB - Automatically set the privacy and Bot recognition modes. 
     * Please note that these modes are default to the unreal32 IRCd
     */
    public static final String DEFAULT_MODES = "+pB" ;
    
    /**
     * Default name - The framework is named Vectra so it is only fitting that 
     * the default ident represent the framework name.
     */
    public static final String DEFAULT_NICK = "Vectra" ;
    
    /**
     * Default gecos - The real name used to identify the bot to the server. 
     * set automatically on connect with the initial identification commands.
     */
    public static final String DEFAULT_GECOS = "Vectra Java IRC Framework" ;
    
    /**
     * Default port - 6667
     */
    public static final int DEFAULT_PORT = 6667 ;
    
    /**
     * A configurable backup nickname used when trying to connect in
     * case the current nick is in use
     */
    private String altnickname = "";
    
    /**
     * Channels by which to automatically join upon successfully connecting to 
     * an IRCd
     */
    private String autoJoin = "" ;    
    
    /**
     * Default modes to automatically set to this bot upon successfully 
     * connecting to an IRCd
     */
    private String autoModes = DEFAULT_MODES ;
    
    /**
	 * Override the parent BotConfig's connection variable to be
	 * an IRCConnection because this is an IRC Specific class
	 */
	private IRCConnection connection ;	
    
    /**
     * These modes are set by the server when connecting and via the
     * AutoModes procedures
     */
    private String modeString = "" ;
    
    /**
     * Default nickname used to connect to the server
     * This does not check if it already exists - merely holds the String 
     * name given by the IRCconfig
     */
    private String nick = DEFAULT_NICK ;    
    
    /**
     * GECOS used to identify this bot to the server. It is sent upon connection. 
     * Some IRCd's allow it to be changed during the length of the connection
     */
    private String realName = DEFAULT_GECOS ;
    
    /**
     * IRC staff channel that this bot will not be permitted to part.
     * The bots will automatically join this channel and attempt to continually 
     * rejoin these channels upon kick/part/etc
     */
    private String staffChannel = "" ;
    
    private String logChannel = "";
    
    /**
     * Lock object used by this BotConfig to retain synchronization across all threads
     */
    private final ReadWriteLock lock = new ReentrantReadWriteLock(true) ;

	public IRCBotConfig (final int id, final int familyId) 
		throws IllegalArgumentException
	{
		this(id, familyId, false) ;	
	}
	
	public IRCBotConfig (final int id, final int familyId, final boolean administrator) 
		throws IllegalArgumentException
	{
		this(id, familyId, administrator, "") ;	
	}
	
	public IRCBotConfig (final int id, final int familyId, final String bindAddress) 
		throws IllegalArgumentException
	{
		this(id, familyId, false, bindAddress) ;	
	}

	public IRCBotConfig (final int id, final int familyId, final boolean administrator, final String bindAddress) 
		throws IllegalArgumentException
	{
		super(id, familyId, administrator, bindAddress);
	}
	
	public boolean areEquivalent(final String label1, final String label2) {
		return getCaseMappingComparator().compare(label1, label2) == 0;
	}
	
	public final String getAltNick ()
    {
        this.lock.readLock().lock();
        try {
            if (this.altnickname == null || this.altnickname.isEmpty())
               return "" ;
            return this.altnickname ;
        } finally {
            this.lock.readLock().unlock();
        }
    }
    
    /**
     * 
     * @return Returns the auto join channels. Will return null if the auto join channels are empty
     */
    public final String getAutoJoin ()
    {
        this.lock.readLock().lock();
        try {
            if (this.autoJoin != null && this.autoJoin.length() > 0)
               return this.autoJoin ;
            return null ;
        } finally {
            this.lock.readLock().unlock();
        }
    }
    
    /**
     * 
     * @return Returns the mode string set on this bot upon successfully connecting to the IRCd. This will return null if the auto modes are empty
     * @see SysConfig
     */
    public final String getAutoModes ()
    {
        this.lock.readLock().lock();
        try {
            if (this.autoModes != null && this.autoModes.length() > 0)
               return this.autoModes ;
            return DEFAULT_MODES ;
        } finally {
            this.lock.readLock().unlock();
        }
    }    
    
    public Comparator<String> getCaseMappingComparator() {		
		final String caseMapping = getConnection().getIRCConfig().getCaseMapping().toLowerCase();
		if (caseMapping.equals("ascii"))
			return new CasemappingASCII();
		return null ;
	}    

	public IRCConnection getConnection ()
	{
		this.lock.readLock().lock();
	    try {
	        return this.connection ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public String getLogChannel() {
		this.lock.readLock().lock();
	    try {
	    	if (!isAdministrator())
	    		return this.staffChannel;
	    	if (this.logChannel == null || this.logChannel.isEmpty())
	    		return this.staffChannel ;
	    	return this.logChannel;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}
	
	public String getModes ()
	{
		this.lock.readLock().lock();
	    try {
	        return this.modeString ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public String getName ()
	{
		// return the BotConfig COnnID if we 
		// are not yet connected
		if (!(getConnection() instanceof Connection))
			return getConnID() ;
		if (!getConnection().isConnected())
			return getConnID() ;
		return getNick() ;
	}

	/**
	 * This value may differ from the actual one prior to connecting. When a bot connects, the final nickname will
	 * be saved in this object.
	 * @return Returns the currently saved nickname 
	 */
	public final String getNick ()
	{
	    this.lock.readLock().lock();
	    try {
	    	if (this.nick != null && this.nick.length() > 0)
	            return this.nick ;
	         return DEFAULT_NICK ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	/**
	 * This value identifies the bot to the server. Some IRCd's allow for this to be changed through the /setname command (unreal32)
	 * @return The GECOS sent when connecting
	 */
	public final String getRealName ()
	{
	    this.lock.readLock().lock();
	    try {
	    	if (this.realName != null && this.realName.length() > 0)
	    		return this.realName ;
	    	return DEFAULT_GECOS ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	/**
	 * This single channel will ALWAYS be one of the N channels a bot occupies regardless of any other factor
	 * @return Staff CHannel associated with this bot
	 */
	public final String getStaffChannel ()
	{
	    this.lock.readLock().lock();
	    try {
	         return this.staffChannel ;
	    } finally {
	         this.lock.readLock().unlock();
	    }
	}
	
	public void setAlternateNickname(final String nickname) {
		if (nickname == null || nickname.isEmpty())
			throw new IllegalArgumentException("alt nickname cannot be null");
		this.lock.writeLock().lock();
	    try {
	        this.altnickname = nickname.trim() ;
	    } finally {
	        this.lock.writeLock().unlock();
	    }
	}

	/**
	 * 
	 * @param channels array of channels to automatically join when connecting to the IRCd
	 * @throws IllegalArgumentException when the supplied array is null or empty
	 */
	public final void setAutoJoin (String channels)
	    throws IllegalArgumentException
	{
	    if (channels == null || channels.length() == 0)
	        throw new IllegalArgumentException("Supplied list is null or empty") ;
	    
	    this.lock.writeLock().lock();
	    try {
	        this.autoJoin = channels.trim() ;
	    } finally {
	        this.lock.writeLock().unlock();
	    }
	}

	/**
	 * 
	 * @param modes Auto modes to be executed on this bot when successfully connecting to an IRCd
	 * @throws IllegalArgumentException when the supplied mode string is null or empty
	 */
	public final void setAutoModes (String modes)
	    throws IllegalArgumentException
	{
	    if (modes == null || modes.length() == 0)
	        throw new IllegalArgumentException("Supplied mode list is null or empty") ;
	    //if (!modeMatcher.matcher(modes).matches())
	    //    throw new IllegalArgumentException("Incorrect mode sequence") ;
	    
	    this.lock.writeLock().lock();
	    try {
	        this.autoModes = modes.trim() ;
	    } finally {
	        this.lock.writeLock().unlock();
	    }
	}	

	public void setConnection (final IRCConnection connection)
	{
		this.lock.writeLock().lock();
	    try {
	        this.connection = connection ;
	    } finally {
	        this.lock.writeLock().unlock();
	    }
	}

	public String setLogChannel(final String channel) {
		if (!isAdministrator())
			throw new IllegalStateException("This bot is not set as an administrator, and therefore cannot have a logchannel");
		
		this.lock.writeLock().lock();
	    try {
	        return this.logChannel ;
	    } finally {
	        this.lock.writeLock().unlock();
	    }
	}	

	/**
	 * 
	 * @param nickname The nickname representing this IRCConnection
	 * @throws IllegalArgumentException when the supplied string is null or empty
	 */
	public final void setNick (String nickname)
	    throws IllegalArgumentException
	{
	    if (nickname == null || nickname.length() == 0)
	        throw new IllegalArgumentException("Supplied nickname is null or empty") ;
	    
	    this.lock.writeLock().lock();
	    try {
	        this.nick = nickname.trim() ;
	    } finally {
	        this.lock.writeLock().unlock();
	    }
	}

	/**
	 * 
	 * @param gecos The real name that should be used when connecting to an IRCd
	 * @throws IllegalArgumentException when the supplied string is null or empty
	 */
	public final void setRealName (String gecos)
	    throws IllegalArgumentException
	{
	    if (gecos == null || gecos.length() == 0)
	        throw new IllegalArgumentException("Supplied gecos is null or empty") ;
	    
	    this.lock.writeLock().lock();
	    try {
	        this.realName = gecos.trim() ;
	    } finally {
	        this.lock.writeLock().unlock();
	    }
	}

	/**
	 * When the port is zero, the default IRCd port shall be used
	 * @param port The port this bot should connect to
	 */
	public final void setServerPort (int port)
	{           
	    this.lock.writeLock().lock();
	    try {
	        if (port == 0)
	            this.serverPort = DEFAULT_PORT ;
	        else
	            this.serverPort = port ;
	    } finally {
	        this.lock.writeLock().unlock();
	    }
	}

	/**
     * This setting forces a bot to ALWAYS occupy or attempt to occupy a channel.
     * Used improperly this will force a JOIN command to be sent to the server at 
     * repeated intervals until a successful join has occurred.
     * 
     * @param channel The staff channel that the bot should always be occupying
     * @throws IllegalArgumentException when the supplied string is null or empty
     */
    public final void setStaffChannel (String channel)
        throws IllegalArgumentException
    {
        if (channel == null || channel.length() == 0)
            throw new IllegalArgumentException("Supplied channel is null or empty") ;
        
        this.lock.writeLock().lock();
        try {
            this.staffChannel = channel.trim() ;
        } finally  {
            this.lock.writeLock().unlock();
        }
    }
    
    @Override
	public void update(final ConfigBlock block) 
			throws IllegalArgumentException, ConfigurationException {
		if (block == null)
			throw new IllegalArgumentException("Supplied block cannot be null");
		// many options should not (cannot) be changed while currently connected actively
		final boolean isActive = getConnection() == null ? false : true;
		// we first begin with the non-session specific ones		
		List<String> options;
		String option = block.getPropertyValue("network");
		if (option != null)
			if (isActive) {
				throw new ConfigurationException("A newtork cannot be changed during runtime");
			} else {
				setNetwork(option);
			}
		option = block.getPropertyValue("realname");
		if (option != null) 
			setRealName(option.trim());			
		option = block.getPropertyValue("autojoin");
		if (option != null) 
			setAutoJoin(option.trim());		
		option = block.getPropertyValue("automodes");
		if (option != null) 
			setAutoModes(option.trim());	
		option = block.getPropertyValue("altnickname");
		if (option != null)
			setAlternateNickname(option);
		option = block.getPropertyValue("allowmodules");
		if (option != null)
			if (option.length() > 0) {
				options = StrUtils.split(option, ',');
				for (final String module : options)
					allowModule(module);
			}
		option = block.getPropertyValue("bindip");
		if (option != null)
			setBindAddress(option);
		option = block.getPropertyValue("denymodules");
		if (option != null)
			if (option.length() > 0) {
				options = StrUtils.split(option, ',');
				for (final String module : options)
					allowModule(module);
			}
		option = block.getPropertyValue("ident");
		if (option != null) 
			setIdent(option.trim());
		option = block.getPropertyValue("logchannel");
		if (option != null)
			setLogChannel(option);		
		option = block.getPropertyValue("nickname");
		if (option != null)
			setNick(option);
		option = block.getPropertyValue("password");
		if (option != null)
			setPassword(option);
		option = block.getPropertyValue("server");
		if (option != null) // will override the default round-robin chooser
			setServers(new String[]{option.trim()});
		option = block.getPropertyValue("realname");
		if (option != null)
			setRealName(option);
		// handle custom directives
		// Nicknames should not be updated except during run time
		
	}

	public String toString()
	{
		return "[IRCBotConfig "+getConnID()+"]";
	}
}
