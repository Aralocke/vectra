package org.vectra;
import java.net.InetSocketAddress ;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import net.phantomnet.config.ConfigBlock;
import net.phantomnet.config.ConfigurationException;

import org.vectra.interfaces.Source;
import org.vectra.interfaces.IRCd ;

public abstract class BotConfig
    implements Source, IRCd
{
    /**
	 * Unique ID
	 */
	private static final long serialVersionUID = -7084595259458130369L;	
	
	/**
     * Default Ident - The framework is named Vectra so it is only fitting 
     * that the default ident represent the framework name.
     */
    public static final String DEFAULT_IDENT = "Vectra" ;
    
    /**
     * The bot's identity to the server. SHort of a chgident by an oper, 
     * this will never change throughout a connection. Note that this 
     * is usd inside an IdentServer when it is created. If the Ident 
     * server successfully is created on port 113 this ident is then 
     * used to identify to the server
     */
    private String ident = DEFAULT_IDENT ;

	/**
     * Defines the state of this Config as an administrator connection
     * Admin connections cannot be deleted, will always try to reconnect,
     * and can only be chosen at construction
     */
    private final boolean isAdministrator ;
    
    /**
     * final id - used to identify this botconfig to the parent IRCconfig
     */
    private final int id ;
    
    /**
     * This id represents which config block this bot belongs to. Configuration
     * blocks are able to specify the number of clones to connect
     */
    private final int familyId ;
    
    /**
     * Controls whether or not to queue up based on the identd server
     */
    private boolean useIdentd;
    
    /**
     * Counter used to count the reconnect attempts when connecting to a server
     */
    private int reconnectCount = 0 ;
    
    /**
     * Server port - the port on the IRCd which we connect to. 
     * This is different from the local port which is ignore din the IP binding 
     * procedure.
     */
    protected int serverPort ;
    
    /**
     * The parent IRCConnection that this BotConfig is currently representing
     * Contains all run time information for the IRCConnection
     */
    private Connection connection ;
   
    /**
     * String based representation of the bind address with which this 
     * bot will use. Note that it can be in either the v4, v6, of DNS form.
     */
    private String bindAddress ;
    
    /**
     * The network of which we are currently connected to
     * This chan be set upon creation of the BotConfig, but note that it 
     * WILL be overriden by the server given one in raw 005 by the IRCd 
     * on connect. An error will be raised if they do not match as a fraud 
     * prevention mechanism
     */
    private String network = "" ;
    
    /** 
     * Stores the runtime information for identifying to Network Services
     */
    private String password = "";
    
    /**
     * The server we are technically connected to.
     * This will be overriden by the RAW 005 message sent by the IRCd when 
     * it identifies itself. The IRCconfig will attempt to set it upon creation 
     * of this object, but it will be changed upon connection
     */
    private String server = "" ;
    
    /**
     * Server list that the bot may connect to
     * This is set by the IRCconfig upon creation of the object
     * From this list, a random server is chosen each time a bot needs to connect
     */
    private String[] servers = {} ;
    
    /**
     * The configDirectives Map contains any configuration specific values that 
     * is not explicitly called for by the BitConfig class. This allows for passing
     * of parameters to modules and such, that aren't explicitly used in each Bot.
     */
    private Map<String, String> configDirectives = new HashMap<String, String>();
    
    /**
     * A list of Module names that this Bot will be allowed to use. This works in 
     * connection with DneyModules. If this list is NOT empty, only modules 
     * specified will be allowed.
     */
    private List<String> allowModules = new LinkedList<String>();
    
    /**
     * A lit of module names that this bot is NOT allowed to use. It works in connection
     * with AllowModules. If this list is NOT empty, all modules but those specified here
     * will be allowed.
     */
    private List<String> denyModules = new LinkedList<String>(); 
    
    /**
     * Lock object used by this BotConfig to retain synchronization across all threads
     */
    private final ReadWriteLock lock = new ReentrantReadWriteLock(true) ;
    
    public BotConfig (final int id, final int familyId)
    	throws IllegalArgumentException
    {
        this(id, familyId, false) ;
    }
    
    public BotConfig (final int id, final int familyId, final boolean administrator)
    	throws IllegalArgumentException
    {
        this(id, familyId, administrator, "") ;
    }
    
    public BotConfig (final int id, final int familyId, final String bindAddress)
    	throws IllegalArgumentException
    {    
    	this(id, familyId, false, bindAddress);
    }

    public BotConfig (final int id, final int familyId, final boolean administrator, final String bindAddress)
    	throws IllegalArgumentException
    {    	
        this.bindAddress = bindAddress ;
        this.id = id ;
        this.familyId = familyId;
        this.isAdministrator = administrator;
    }
    
    public void addDirective(final String key, final String value) {
    	if (key == null || key.isEmpty())
    		throw new IllegalArgumentException("Key value cannot be null or empty");
    	if (value == null)
    		throw new IllegalArgumentException("Value cannot be null");
    	
    	this.lock.writeLock().lock();
        try {
        	 this.configDirectives.put(key, value);
        } finally {
             this.lock.writeLock().unlock();
        }
    }
    
    public void allowModule(final String module) {
    	if (module == null || module.isEmpty())
    		throw new IllegalArgumentException("Module names cannot be null or length zero");
    	this.allowModules.add(module.trim());
    }
    
    public void allowModules(final String modules) {
    	if (modules == null || modules.isEmpty())
    		throw new IllegalArgumentException("Module names cannot be null or length zero");
    	List<String> moduleList = StrUtils.split(modules, ' ');
    	this.allowModules.addAll(moduleList);
    }
    
    public boolean checkModule(final String module) {
    	// System.out.println("Checking if "+module+" is allowed");
    	if (this.allowModules.isEmpty())
    		return this.denyModules.contains(module) == false;
    	return this.allowModules.contains(module) == false;
    }
    
    public void denyModule(final String module) {
    	if (module == null || module.isEmpty())
    		throw new IllegalArgumentException("Module names cannot be null or length zero");
    	this.denyModules.add(module.trim());
    }
    
    public void denyModules(final String modules) {
    	if (modules == null || modules.isEmpty())
    		throw new IllegalArgumentException("Module names cannot be null or length zero");
    	List<String> moduleList = StrUtils.split(modules, ' ');
    	this.denyModules.addAll(moduleList);
    }
    
    /**
     * 
     * @return An available server from the server pool to connect to
     * @throws IllegalStateException Thrown when the available server list is empty or null
     */
    public String getAvailableServer ()
        throws IllegalStateException
    {
        this.lock.readLock().lock();
        try {
            if (this.servers == null || this.servers.length == 0)
                throw new IllegalStateException("Cannot find available server :: Stored server list is empty") ;
            if (this.servers.length > 1) // grab a random server from available
                return this.servers[ (int) ((int) (Math.random() * 10) % this.servers.length) ] ;
            return this.servers[0].trim() ;
        } finally {
            this.lock.readLock().unlock();
        }
    }
    
    /**
     * 
     * @return Retrieve the bind IP set by the IRCconfig. This value can be null or an empty string depending on what was set
     */
    public final String getBindAddress ()
    {
        this.lock.readLock().lock();
        try {
        	 if (this.bindAddress == null)
        		 return "" ;
             return this.bindAddress ;
        } finally {
             this.lock.readLock().unlock();
        }
    }
    
    /**
	 * 
	 */
	public final String getConnID ()
	{
		if (isAdministrator())
			return "Administrator" ;
		return new String(getNetwork()+"::"+getID()) ;    	
	}

	/**
     * 
     * @return Return the parent IRCConnection that this BotConfig is currently bound to. This value will be null when the BotConfig is awaiting reconnection.
     */
    public Connection getConnection ()
    {
        this.lock.readLock().lock();
        try {
            return this.connection ;
        } finally {
            this.lock.readLock().unlock();
        }
    }
    
    public String getDirective (final String key) {
    	if (key == null || key.isEmpty())
    		throw new IllegalArgumentException("Key value cannot be null or empty");
    	
    	this.lock.writeLock().lock();
        try {
        	 return this.configDirectives.get(key);
        } finally {
             this.lock.writeLock().unlock();
        }
    }
    
    /**
     * 
     * @return Returns the unique numeric ID of this BotConfig as determined by the IRCconfig when this object was created
     */
    public final int getID ()
    {
        this.lock.readLock().lock();
        try {
             return this.id ;
        } finally {
             this.lock.readLock().unlock();
        }
    }
    
	/**
	 * Value will remain constant unless rehashed by the IRCconfig or unless a change is detected during execution
	 * @return Returns the identity of the bot. This cannot be changed except by an IRC operator on some IRCd's.
	 */
	public final String getIdent ()
	{
	    this.lock.readLock().lock();
	    try {
	    	 if (this.ident == null)
	    		 return DEFAULT_IDENT ;
	         return this.ident ;
	    } finally {
	         this.lock.readLock().unlock();
	    }
	}
    
    /**
     * The value used for the bind IP is set by the IRCconfig upon creation. This value cannot be changed due to runtime synchronization of the interfaces for use
     * @return returns an InetSocketAddress object for the specified bind ip
     */
    public final InetSocketAddress getInetBindAddress ()
    {
        this.lock.readLock().lock();
        try {
             return new InetSocketAddress(this.bindAddress, 0) ;
        } finally {
             this.lock.readLock().unlock();
        }
    }
    
    /**
     * If this is being called during a reconnect, the setServer() must be called first, otherwise this will provide an InetSocketAddress to the last server
     * @return An InetSocketAddress to the currently saved server
     */
    public final InetSocketAddress getInetServerAddress ()
    {
        this.lock.readLock().lock();
        try {
             return new InetSocketAddress(this.server, this.serverPort) ;
        } finally {
             this.lock.readLock().unlock();
        }
    }
    
    public final int getFamilyID ()
    {
        this.lock.readLock().lock();
        try {
             return this.familyId ;
        } finally {
             this.lock.readLock().unlock();
        }
    }
    
    /**
     * This value is overridden at run time by the RAW 005 output NETWORK=*
     * If the values differ when the IRCd sends the RAW 005 then an error will be thrown to alert possible malicious use 
     * @return The current network saved in this object
     */
    public final String getNetwork ()
    {
        this.lock.readLock().lock();
        try {
            return this.network ;
        } finally {
            this.lock.readLock().unlock();
        }
    }
    
    /**
     * Password used to identify the bot to a server
     * @return The password used to identify a bot to the server.
     */
    public String getPassword() {
		return this.password;
	}
    
    /**
     * Another method of retrieving this value is through the IRCConnection if it is connected.
     * @return Returns the server port used to connect.
     */
    public final int getPort ()
    {
        this.lock.readLock().lock();
        try {
            return this.serverPort ;
        } finally {
            this.lock.readLock().unlock();
        }
    }
    
    /**
     * This count is resent when an IRCConnection bound successfully connects to an IRCd
     * @return The current number of connect retries to the specific network
     */
    public final int getReconnectCount ()
    {
        this.lock.readLock().lock();
        try {
            return this.reconnectCount ;
        } finally {
            this.lock.readLock().unlock();
        }
    }
    
    /**
     * Prior to connecting to an IRCd this could be null or empty. Do NOT rely on until after a successful connection.
     * @return The current server this Bot is connected to
     */
    public final String getServer ()
    {
        this.lock.readLock().lock();
        try {
             return this.server ;
        } finally {
             this.lock.readLock().unlock();
        }
    }
    
    public final int incrementReconnectCount ()
    {
        this.lock.writeLock().lock();
        try {
            return ++this.reconnectCount ;
        } finally {
            this.lock.writeLock().unlock();
        }
    }
    
    /**
     * Administrator connections are complete connections except
     * they also maintain all logging facilities as the primary 
     * connection, they cannot be deleted, and will always attempt 
     * to reconnect.
     * 
     * @return The state of isAdministrator
     */
    public final boolean isAdministrator() {
    	return this.isAdministrator;
    }
    
    public void resetReconnectCount() {
    	this.lock.writeLock().lock();
        try {
            this.reconnectCount = 0 ;
        } finally {
            this.lock.writeLock().unlock();
        }		
	}
    
    protected final void setBindAddress(final String address) {
    	if (address == null || address.isEmpty())
    		throw new IllegalArgumentException("New Bindaddress cannot be null");
    	
    	this.lock.writeLock().lock();
        try {
        	this.bindAddress = address.trim();
        } finally {
            this.lock.writeLock().unlock();
        }
    }
    
    /**
     * 
     * @param connection The IRCConnection associated with this BotConfig
     * @throws IllegalArgumentException when the connection is null
     */
    public final void setConnection (Connection connection)
        throws IllegalArgumentException
    {
        if (connection == null)
            throw new IllegalArgumentException("Supplied address is null or empty") ;
        
        this.lock.writeLock().lock();
        try {
            this.connection = connection ;
        } finally {
            this.lock.writeLock().unlock();
        }
    }
    
	/**
	 * 
	 * @param ident The identity string that the bot will use when connecting. 
	 *                      This will also be used by an IdentServer object to identify 
	 *                          to the ircd when connecting
	 * @throws IllegalArgumentException when the supplied string is null or empty
	 */
	public final void setIdent (String ident)
	    throws IllegalArgumentException
	{
	    if (ident == null || ident.length() == 0)
	        throw new IllegalArgumentException("Supplied ident is null or empty") ;
	    
	    this.lock.writeLock().lock();
	    try {
	        this.ident = ident.trim() ;
	    } finally {
	        this.lock.writeLock().unlock();
	    }
	}
    
    /**
     * 
     * @param network The name of the network this bot is connecting to. Will be 
     *            called again during the initial stages of a connection to an irc server.
     * @throws IllegalArgumentException when the supplied string is null or empty
     */
    public final void setNetwork (String network)
        throws IllegalArgumentException
    {
        if (network == null || network.length() == 0)
            throw new IllegalArgumentException("Supplied network is null or empty") ;
        
        this.lock.writeLock().lock();
        try {
            this.network = network.trim() ;
        } finally {
            this.lock.writeLock().unlock();
        }
    }
    
    public final void setPassword (String password)
        throws IllegalArgumentException
    {
        if (password == null || password.length() == 0)
            throw new IllegalArgumentException("Supplied password is null or empty") ;
        
        this.lock.writeLock().lock();
        try {
            this.password = password.trim() ;
        } finally {
            this.lock.writeLock().unlock();
        }
    }
    
    /**
     * Set the available servers for this Config to use while connecting 
     * @param servers An array of strings representing either the DNS hostname
     *            or the IP address of a server with which a Connection can be made
     * @throws IllegalArgumentException when the Array is empty or null
     */
    public final void setServers (String[] servers)
        throws IllegalArgumentException
    {
        if (servers == null || servers.length == 0)
            throw new IllegalArgumentException("Passed server list is null or contains no servers") ;
        
        this.lock.writeLock().lock() ;
        try {
            this.servers = servers ;
        } finally {
            this.lock.writeLock().unlock() ;
        }
    }
    
    /**
     * When the port is zero, the default IRCd port shall be used
     * @param port The port this bot should connect to
     */
    public void setServerPort (int port)
    {           
        this.lock.writeLock().lock();
        try {
            this.serverPort = port ;
        } finally {
            this.lock.writeLock().unlock();
        }
    }
    
    /**
     * This can be used by an IRCconfig to set the initial server to connect to.
     * However upon connecting to an IRCd this will be changed by the RAW 005
     * mode on the server to reflect the actual server name.
     * 
     * @param server The current server this bot is connect(ing|ed) to
     * @throws IllegalArgumentException when the supplied string is null or empty
     */
    public final void setServer (String server)
        throws IllegalArgumentException
    {
        if (server == null || server.length() == 0)
           throw new IllegalArgumentException("Supplied server is null or empty") ;
        
        this.lock.writeLock().lock();
        try {
            this.server = server.trim() ;
        } finally {
            this.lock.writeLock().unlock();
        }
    }
    
    public abstract void update(final ConfigBlock block) throws IllegalArgumentException, ConfigurationException;
    
    public boolean useIdentd() {
        this.lock.readLock().lock();
        try {
            return this.useIdentd ;
        } finally {
            this.lock.readLock().unlock();
        }
    }
    
    public void useIdentd(final boolean status) {
        this.lock.writeLock().lock();
        try {
            this.useIdentd = status;
        } finally {
            this.lock.writeLock().unlock();
        }
    }
    
    /**
     * Asses the validity of the configuration.
     * This is called before a new Connection is made to verify that basic information
     * is properly set in the config to avoid catastrophic errors.
     * 
     * @return boolean if the config is valid
     * @throws IllegalStateException When the config is seen as invalid an Exception
     * 		                         is thrown as an alert of what went wrong.
     */
    public final boolean validate ()
    	throws IllegalStateException
    {
    	if (getNetwork() == null)
    		throw new IllegalStateException("Supplied Network is null") ;
    	if (getServer() == null) // check for a server to connect to
    		throw new IllegalStateException("Server address is null") ;
    	
    	return true ;
    }
}
