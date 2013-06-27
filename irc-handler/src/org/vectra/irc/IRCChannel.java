package org.vectra.irc ;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date ;
import java.util.Iterator ;
import java.util.TreeMap ;
import java.util.regex.Pattern ;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import org.vectra.interfaces.Actionable;
import org.vectra.interfaces.Destination;
import org.vectra.interfaces.Messagable;
import org.vectra.interfaces.Named;
import org.vectra.interfaces.Noticable;
import org.vectra.interfaces.Source;
import org.vectra.interfaces.Priority;
import org.vectra.irc.exceptions.UserConflictException;

public class IRCChannel
	implements Actionable, Source, Destination, Messagable, Named, Noticable, Iterable<IRCChannelUser>, Priority
{
	/**
	 * Unique ID
	 */
	private static final long serialVersionUID = 5112409552560527936L;
	public static final Pattern validChannel = Pattern.compile("[&#](.+?)") ;
	private final int time ;
	private Date channelCreation ;
	private Date topicSet ;
	private String topic ;
	private String topicSetter ;
    private final ArrayList<String> modes = new ArrayList<String>(1) ;
    private final String channel ;
    private final TreeMap<String, IRCChannelUser> userList ;
    private final IRCConnection connection ;
    private final ReadWriteLock lock = new ReentrantReadWriteLock(true);
    
    public IRCChannel (final String channel, final IRCConnection connection)
        throws IllegalArgumentException
    {
    	if (channel == null || channel.length() < 1)
    		throw new IllegalArgumentException("Channel is improperly formatted") ;
    	
        if (! validChannel.matcher(channel).matches())
            throw new IllegalArgumentException("Invalid channel sent to constructor: "+channel+".") ;
        
        if (connection == null || connection.isDisconnected())
    		throw new IllegalArgumentException("Supplied IRCConnection is null or disconnected") ;
        
        this.connection = connection ;
        this.time = IRCUtils.time() ;
        this.channel = channel.trim() ;
        this.userList = new TreeMap<String, IRCChannelUser>(connection.getConfig().getCaseMappingComparator()) ;
    }
    
    public void addMode(final String modeList) {
    	if (modeList.isEmpty())
    		return;
    	for (int i = 0; i < modeList.length(); i++)
    		addMode(modeList.charAt(i));
    }
    
    public void addMode(final char mode) {
    	getLock().writeLock().lock();
    	try {
    		//if (getModes().indexOf(mode) == -1)
    		//	this.modes = new String(this.modes+""+mode);
    	} finally {
    		getLock().writeLock().unlock();
    	}
    }
    
    public void addUser (final IRCChannelUser user) 
    	throws IllegalArgumentException, UserConflictException
    {
    	if (user == null)
    		throw new IllegalArgumentException("The user cannot be null to add to a channel list") ;
    	
    	this.lock.writeLock().lock() ;
        try {
        	if (this.userList.containsKey(user.getProtocolAddress()))
        		throw new UserConflictException("User "+user.getNick()+"!"+user.getProtocolAddress()+" already exists in channel "+getName()+" access list") ;
        	this.userList.put(user.getProtocolAddress(), user) ;
        } finally {
        	this.lock.writeLock().unlock() ;
        }
    }
    
    /**
	    * Set the topic for a channel.
	    * 
	    * @param topic The new topic for the channel.
	    * @param encoding String encoding type. This is supplied by the IRCevent
	     *                 which triggered the calling of this method
	    * @throws IllegalArgumentException
	    */
	   public final void changeTopic (String topic, String encoding) 
		   throws IllegalArgumentException
	   {
		   if (topic == null || topic.length() < 1)
			   throw new IllegalArgumentException("Supplied topic is null or length zero") ;
		   
	       getConnection().send("TOPIC " + this.channel + " :" + topic, encoding, PRIORITY_LOW);
	   }

	public Date getChannelAge ()
    {    	
    	this.lock.readLock().lock() ;
        try {
        	return this.channelCreation ;
        } finally {
        	this.lock.readLock().unlock() ;
        }
    }
    
    public IRCConnection getConnection ()
    {    	
    	this.lock.readLock().lock() ;
        try {
        	return this.connection ;
        } finally {
        	this.lock.readLock().unlock() ;
        }
    }

	public int getJoinTime ()
    {
    	return this.getJoinTime(false);
    }
    
    public int getJoinTime (boolean duration)
    {    	
    	this.lock.readLock().lock() ;
        try {
        	if (this.time == 0)
        		return 0 ;
        	if (duration)
        		return IRCUtils.time() - this.time ;
        	return this.time ;
        } finally {
        	this.lock.readLock().unlock() ;
        }
    }
    
    public String getKey() {
    	if (!hasKey())
    		return "";
    	// TODO key processing
    	return "";
    }
    
    public ReadWriteLock getLock() {
    	return this.lock;
    }
    
    public String getModes ()
    {    	
    	this.lock.readLock().lock() ;
        try {
        	if (this.modes.size() == 0)
        		return "";
        	final StringBuffer buffer = new StringBuffer("+");
        	for (final String mode : this.modes)
        		if (mode.length() == 1) { // no parameter
        			buffer.append(mode);
        		} else { // it has a parameter .. we don't want that
        			buffer.append(mode.substring(0, mode.indexOf(' ')).trim());
        		}
        	
        	return buffer.toString().trim();
        } finally {
        	this.lock.readLock().unlock() ;
        }
    }
    
    public String getName ()
    {
    	return this.channel ;
    }
    
    public String getTopic ()
    {    	
    	this.lock.readLock().lock() ;
        try {
        	if (this.topic == null)
        		return "";
        	return this.topic ;
        } finally {
        	this.lock.readLock().unlock() ;
        }
    }
    
    public Date getTopicSetTime ()
	{    	
		this.lock.readLock().lock() ;
	    try {
	    	return this.topicSet ;
	    } finally {
	    	this.lock.readLock().unlock() ;
	    }
	}

	public String getTopicSetter ()
    {    	
    	this.lock.readLock().lock() ;
        try {
        	if (this.topic == null)
        		return "";
        	return this.topicSetter ;
        } finally {
        	this.lock.readLock().unlock() ;
        }
    }
	
    public IRCChannelUser getUser(final String hostname) {
		if (hostname == null || hostname.isEmpty())
			throw new IllegalArgumentException("supplied hostname cannot be null or length zero");
		return this.userList.get(hostname.trim());
	}
	
	public IRCChannelUser getUserByNick(final String nickname) {
		if (nickname == null || nickname.isEmpty())
			throw new IllegalArgumentException("supplied hostname cannot be null or length zero");
		
		for (final IRCChannelUser user : this.userList.values())
			if (user.getNick().equalsIgnoreCase(nickname.trim()))
				return this.userList.get(user.getProtocolAddress());
		return null;
	}
    
    public Collection<IRCChannelUser> getUsers ()
    {
    	this.lock.readLock().lock() ;
    	try {
    		return this.userList.values() ;
    	} finally {
    		this.lock.readLock().unlock() ;
    	}
    }
    
    public boolean hasKey() {
    	return this.modes.indexOf('k') > 0;
    }
    
    public Iterator<IRCChannelUser> iterator ()
    {
    	return this.getUsers().iterator();
    }
    
    /**
     * Kicks a user from a channel.
     * 
     * @param channel The channel to kick the user from.
     * @param nick    The nick of the user to kick.
     * @param encoding String encoding type. This is supplied by the IRCevent
     *                 which triggered the calling of this method
     * @throws IllegalArgumentException
     */
    public final void kick (String nick, String encoding) 
    	throws IllegalArgumentException
    {
	   	this.kick(nick, "", encoding) ;
    }


    /**
     * Kicks a user from a channel, giving a reason.
     * 
     * @param nick    The nick of the user to kick.
     * @param reason  A description of the reason for kicking a user.
     * @param encoding String encoding type. This is supplied by the IRCevent
     *                 which triggered the calling of this method
     * @throws IllegalArgumentException
     */
    public final void kick (String nick, String reason, String encoding) 
    	throws IllegalArgumentException
    {
    	if (nick == null || nick.length() < 1)
    		throw new IllegalArgumentException("Supplied nickname is null or length zero") ;
    	
    	if (reason == null)
    		this.kick(nick, encoding) ;
    	
    	getConnection().send("KICK " + this.channel + " " + nick + " :" + reason, encoding, PRIORITY_NORMAL) ;
    }
    
    public void removeMode(final char modeChar) {
    	getLock().writeLock().lock();
    	try {
    		for (final String mode : this.modes)
    			if (mode.charAt(0) == modeChar)
    				this.modes.remove(mode);    			
    	} finally {
    		getLock().writeLock().unlock();
    	}
    }
    
    public void removeMode(final String modeList) {
    	if (modeList.isEmpty())
    		return;
    	for (int i = 0; i < modeList.length(); i++)
    		removeMode(modeList.charAt(i));
    }
    
    public IRCUser removeUser (final IRCUser user) 
    	throws IllegalArgumentException, UserConflictException
    {
    	if (user == null)
    		throw new IllegalArgumentException("The user cannot be null to remove from a channel list") ;
    	
    	this.lock.writeLock().lock() ;
        try {
        	if (!this.userList.containsKey(user.getProtocolAddress()))
        		throw new UserConflictException("User "+user.getNick()+"!"+user.getProtocolAddress()+" does not exist in the "+getName()+" access list.") ;
        	this.userList.remove(user.getProtocolAddress()) ;
        	return user;
        } finally {
        	this.lock.writeLock().unlock() ;
        }
    }
    
    /**
     * Sends an action to the channel or to a user.
     *
     * @param action The action to send.
     * @param encoding String encoding type. This is supplied by the IRCevent
     *                 which triggered the calling of this method
     * @throws IllegalArgumentException
     */
    public final void sendAction (String action, String encoding) 
    {
        this.sendCTCPCommand("ACTION " + this.channel, encoding);
    }   
    
    /**
     * Sends a CTCP command to a channel or user.  (Client to client protocol).
     * 
     * @param command The CTCP command to send.
     * @param encoding String encoding type. This is supplied by the IRCevent
     *                 which triggered the calling of this method
     * @throws IllegalArgumentException
     */
    public final void sendCTCPCommand (String command, String encoding) 
    	throws IllegalArgumentException
    {
        this.sendMessage("\u0001" + command + "\u0001", encoding) ;
    }
    
    /**
    * Send a public PRIVMSG to a channel
    * @param message The message to send.
    * @param encoding String encoding type. This is supplied by the IRCevent
     *                 which triggered the calling of this method
    * @throws IllegalArgumentException
    */
   public final void sendMessage(String message, String encoding) 
	   throws IllegalArgumentException
   {
	   if (message == null || message.length() < 1)
		   throw new IllegalArgumentException("Supplied message is null or length zero") ;
	   
	   getConnection().send("PRIVMSG " + this.channel + " :" + message, encoding, PRIORITY_NORMAL) ;
   }
   
   /**
    * Sends a notice to the channel or to a user.
    *
    * @param notice The notice to send.
    * @param encoding String encoding type. This is supplied by the IRCevent
     *                 which triggered the calling of this method
    * @throws IllegalArgumentException
    */
   public final void sendNotice (String notice, String encoding) 
	   throws IllegalArgumentException
   {
	   if (notice == null || notice.length() < 1)
		   throw new IllegalArgumentException("Supplied notice is null or length zero") ;
	   
	   getConnection().send("NOTICE " + this.channel + " :" + notice, encoding, PRIORITY_NORMAL) ;
   }   
 
	public void sendMessage(String message) 
		throws IllegalArgumentException 
	{
		sendMessage(message, PRIORITY_NORMAL) ;
	}
	
	public void sendMessage(String message, byte priority)
		throws IllegalArgumentException 
	{
		sendMessage(message, "UTF-8", priority) ;
	}
	
	public void sendMessage(String message, String encoding, byte priority)
		throws IllegalArgumentException 
	{
		if (message == null || message.length() == 0)
    		throw new IllegalArgumentException("The outgoing message canno be null") ;
    		
    	getConnection().send("PRIVMSG "+getName()+" :"+message.trim(), encoding, priority) ;
	}
	
	public void sendAction(String action) 
		throws IllegalArgumentException 
	{
		sendAction(action, PRIORITY_NORMAL) ;
	}
	
	public void sendAction(String action, byte priority)
		throws IllegalArgumentException 
	{
		sendAction(action, "UTF-8", PRIORITY_NORMAL) ;
	}
	
	public void sendAction(String action, String encoding, byte priority)
		throws IllegalArgumentException 
	{
		if (action == null || action.length() == 0)
    		throw new IllegalArgumentException("The outgoing message cannot be null") ;
    	
        sendCTCPCommand("ACTION " + action, encoding, priority);
	}
	
	public void sendCTCPCommand(String command) 
		throws IllegalArgumentException 
	{
		sendCTCPCommand(command, PRIORITY_NORMAL) ;
	}

	public void sendCTCPCommand(String command, byte priority)
		throws IllegalArgumentException 
	{
		sendCTCPCommand(command, "UTF-8", priority) ;
	}
	
	public void sendCTCPCommand(String command, String encoding, byte priority)
		throws IllegalArgumentException 
	{
		if (command == null || command.length() == 0)
    		throw new IllegalArgumentException("The outgoing message cannot be null") ;
    	
    	sendMessage("\u0001" + command + "\u0001", encoding, priority) ;
	}

	public void sendNotice(String message) 
		throws IllegalArgumentException 
	{
		sendNotice(message, PRIORITY_NORMAL) ;
	}

	public void sendNotice(String message, byte priority)
		throws IllegalArgumentException 
	{
		sendNotice(message, "UTF-8", priority) ;
	}

	public void sendNotice(String message, String encoding, byte priority)
		throws IllegalArgumentException 
	{
		if (message == null || message.length() == 0)
    		throw new IllegalArgumentException("The outgoing message cannot be null") ;
    		
    	getConnection().send("NOTICE "+getName()+" :"+message.trim(), encoding, priority) ;
	}
	
	public void setChannelAge(Date creationDate) {		
		if (creationDate == null)
			creationDate = new Date(System.currentTimeMillis());		
		getLock().writeLock().lock();
		try {
			this.channelCreation = creationDate;
		} finally {
			getLock().writeLock().unlock();
		}
	}

	public void setModes(final String modes) {
	   getLock().writeLock().lock();
	   try {
		   for (int i = 0; i < modes.length(); i++) {
			   final char mode = modes.charAt(i);
			   if (mode == '+' || mode == '-')
				   continue;
			   this.modes.add(String.valueOf(mode));
		   }
	   } finally {
		   getLock().writeLock().unlock();
	   }
    }
	
	public void setTopic(final String topic) {
		setTopic(topic, "", new Date(System.currentTimeMillis()));
	}
	
	public void setTopic(final String topic, final String topicSetter) {
		setTopic(topic, topicSetter, new Date(System.currentTimeMillis()));
	}
	
	public void setTopic(String topic, String topicSetter, final Date topicSet) {
		if (topic == null)
			topic = "";
		if (topicSetter == null)
			topicSetter = "";
		getLock().writeLock().lock();
		try {
			this.topic = topic.trim();
			this.topicSetter = topicSetter.trim();
			this.topicSet = topicSet;
		} finally {
			getLock().writeLock().unlock();
		}
	}
	
	public void setTopicDate(Date topicDate) {		
		if (topicDate == null)
			topicDate = new Date(System.currentTimeMillis());		
		getLock().writeLock().lock();
		try {
			this.topicSet = topicDate;
		} finally {
			getLock().writeLock().unlock();
		}
	}
	
	public void setTopicSetter(String topicSetter) {		
		if (topicSetter == null)
			topicSetter = "";		
		getLock().writeLock().lock();
		try {
			this.topicSetter = topicSetter.trim();
		} finally {
			getLock().writeLock().unlock();
		}
	}

	public String toString ()
	{
	    this.lock.readLock().lock() ;
	    try {
	    	return "[IRCChannel "+this.channel+" (Modes: "+this.modes+")]" ;
	    } finally {
	    	this.lock.readLock().unlock() ;
	    }
	}	
	
	public boolean userIsOnChannel (final String user)
	{
	    this.lock.readLock().lock() ;
	    try {
	    	return this.userList.containsKey(user.trim()) ;
	    } finally {
	    	this.lock.readLock().unlock() ;
	    }
	}	
}
