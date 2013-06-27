package org.vectra.irc ;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.regex.Pattern;

import org.vectra.exceptions.UnknownUserException;
import org.vectra.interfaces.Addressable;
import org.vectra.interfaces.Source;
import org.vectra.interfaces.Named;
import org.vectra.interfaces.Priority;
import org.vectra.interfaces.IRCChannelStatus;
import org.vectra.irc.IRCEvent;

/**
 * @name IRCUser.java
 * @author Danny
 * 
 * This class represents a Data structure for every valid IRC full hostname
 * in the form of user!ident@host. It provides links to the parent object it 
 * also connects from. In the case that this user is from an IRCevent, this 
 * class will have a link to the IRCevent it comes from. From that IRCevent,
 * the IRCConnection can be retrieved.
 * 
 * Either IRCConnection or IRCevent must be supplied. Both cannot be null 
 * inside the same user. The parents of this user can be retrieved with either 
 * the getConnection() or the getEvent().
 */
public class IRCUser
	implements Addressable, Comparable<IRCUser>, IRCChannelStatus, Source, Named, Priority
{
	/**
	 * 
	 */
	private static final long serialVersionUID = -8820785521543901733L;

	/** Pattern object to match a valid IRC Full host */
	public static final Pattern validUserHost = Pattern.compile("(.+?)!(.+?)@(.+?)") ;
	
	/** 
	 * Nickname of the user from this object. This value 
	 * can be changed by a nickname change.
	 **/
    private String nickname ;
    
    /** Ident of the user */
    private final String ident ;
    
    /** full hostname of the user - used to parse out the address types */
    private final String hostname ;
    
    /** 
     * The IRCConnection that holds this IRCUser. If this user is bound to an
     * event, this will be null. to get the connection, call the Event's 
     * parent connection
     */
    private final IRCConnection parent ;
    
    /** If this user is bound to a IRCevent this will NOT be null */
    private final IRCEvent event ;
    
    private final ReadWriteLock lock = new ReentrantReadWriteLock(true);
    
    public IRCUser (String address, IRCEvent event)
        throws UnknownUserException, IllegalArgumentException
    {
    	if (address == null || address.length() == 0)
    		throw new IllegalArgumentException("Supplied address length is null or zero") ;
    	if (!(event instanceof IRCEvent))
    		throw new IllegalArgumentException("IRCevent linked to this user is invalid") ;
        if (! validUserHost.matcher(address.trim()).matches())
            throw new UnknownUserException("User does not match the proper format: "+address+".") ;
        
        // if connection is specified than the client is null
        this.parent = event.getConnection() ;
        this.event = event ;
        
        this.setNick(address.substring(0, address.indexOf("!")).trim()) ;
        address = address.substring(address.indexOf("!") + 1).trim() ;
        this.ident = address.substring(0, address.indexOf("@")).trim() ;
        this.hostname = address.substring(address.indexOf("@") + 1).trim() ;
    }
    
    public IRCUser (String address, IRCConnection connection)
        throws UnknownUserException, IllegalArgumentException
    {
    	if (address == null || address.length() == 0)
    		throw new IllegalArgumentException("Supplied address length is null or zero") ;
    	if (!(connection instanceof IRCConnection))
    		throw new IllegalArgumentException("IRCConnection linked to this user is invalid") ;
        if (! validUserHost.matcher(address.trim()).matches())
            throw new UnknownUserException("User does not match the proper format: "+address+".") ;
        
        // if connection is specified than the client is null
        this.parent = connection ;
        this.event = null ;
        
        this.setNick(address.substring(0, address.indexOf("!")).trim()) ;
        address = address.substring(address.indexOf("!") + 1).trim() ;
        this.ident = address.substring(0, address.indexOf("@")).trim() ;
        this.hostname = address.substring(address.indexOf("@") + 1).trim() ;
    }
    
	public int compareTo (final IRCUser user) 
	{
		return user.getProtocolAddress().equals(getProtocolAddress()) ? 1 : 0;
	}

	public boolean equals (final IRCUser user)
	{
		final String address = user.getProtocolAddress() ;
		return address.equals(getProtocolAddress()) ;
	}

	/**
	 * @return Determines whether or not the User is bound to an event or an IRCConnection
	 */
	public boolean fromIRCevent ()
	{
		return !(this.event == null) ;
	}
	
	public String getAddress() {
		return this.hostname;
	}

	/** 
	 * 
	 * @param type
	 * @return Formatted address built from the saved hostname. Returns IRC style
	 *         format for a hostname of types 1-9. Identical outputs to $address
	 *         
	 *    0: *!user@host
	 *    1: *!*user@host
	 *    2: *!*@host
	 *    3: *!*user@*.host
	 *    4: *!*@*.host
	 *    5: nick!user@host
	 *    6: nick!*user@host
	 *    7: nick!*@host
	 *    8: nick!*user@*.host
	 *    9: nick!*@*.host
	 */
	public String getAddress (int type)
	{
	    String address = "" ;
	    String[] explode = this.hostname.split("\\.") ;
	    switch (type)
	    {
	        case 1:
	            address = "*!*"+this.getIdent(true)+"@"+this.hostname ;
	        break ;
	        case 2:
	            address = "*!*@"+this.hostname ;
	        break ;
	        case 3:
	            if (explode.length == 2)
	                address = this.getAddress(1) ;
	            else
	                address = "*!*"+this.getIdent(true)+"@*"+this.hostname.substring(this.hostname.indexOf(".")).trim() ;
	        break ;
	        case 4:                
	            if (explode.length == 1)
	                address = "*!*@"+this.hostname ;
	            else
	                address = "*!*@*"+this.hostname.substring(this.hostname.indexOf(".")).trim() ;
	        break ;
	        case 5:
	            address = this.getIRCaddress() ;
	        break ;
	        case 6:
	            address = this.nickname+"!*"+this.getIdent(true)+"@"+this.hostname ;
	        break ;
	        case 7:
	            address = this.nickname+"!*@"+this.hostname ;
	        break ;
	        case 8:                
	            if (explode.length == 1)
	                address = this.nickname+"!*"+this.getIdent(true)+"@"+this.hostname ;
	            else
	                address = this.nickname+"!*"+this.getIdent(true)+"@*"+this.hostname.substring(this.hostname.indexOf(".")).trim() ;
	        break ;
	        case 9:                
	            if (explode.length == 1)
	                address = this.nickname+"!*@"+this.hostname ;
	            else
	                address = this.nickname+"!*@*"+this.hostname.substring(this.hostname.indexOf(".")).trim() ;
	        break ;
	        default:
	            address = this.getAddress(3) ;
	        break ;
	    }
	    return address ;
	}

	/**
	 * @return Returns the IRCConnection that is bound to this user. If this returns null,
	 * 	then the User is bound to an IRCevent instead.
	 */
	public IRCConnection getConnection ()
	{
		return this.parent ;
	}

	/**
	 * @return The IRCevent associated with this User. The return can be null. If the
	 * 	return is null, then the User is bound to an IRCConnection.
	 */
	public IRCEvent getEvent ()
	{
		return this.event ;
	}

	/**
     * 
     * @return The string representation of the ident of the user this object represents 
     */
    public String getIdent ()
    {
    	return this.getIdent(false);
    }
    
    /**
     *
     * @param type Boolean, when true, will attempt to strip the ~ from the ident
     * 	and return only as a single string.
     * @return The string representation of the ident of the user this object represents
     */
    public String getIdent (boolean type)
    {
        if (type && this.ident.charAt(0) == '~')
            return this.ident.substring(1).trim() ;   
        return this.ident ;
    }
    
    /**
     * @return Full address represented by this user in *!*@* IRC host
     * 	format as stored by this IRCUser
     */
    public String getIRCaddress()
    {
        return this.getNick()+"!"+this.ident+"@"+this.hostname ;   
    }
    
    public ReadWriteLock getLock() {
    	return this.lock;
    }
    
	public String getName() {
		return getNick();
	}

	/**
     * @return The current nickname associated with this User. It cannot
     * 	be null and it will always be at least one of more characters.
     */
    public String getNick ()
    {
        return this.nickname ;   
    }
    
    public String getProtocolAddress ()
    {
    	return getIRCaddress() ;    	
    }
    
    /**
     * Send an action to the user
     * 
     * @param action The message to be sent to the user
     * @throws IllegalArgumentException A message cannot be null or length zero
     */
    public void sendAction (final String action) 
    	throws IllegalArgumentException
    {
        sendAction(action, PRIORITY_NORMAL) ;
    }
    
    /**
     * Sends an action to the user.
     *
     * @param action The action to send.
     * @param encoding String encoding type. This is supplied by the IRCevent
     *                 which triggered the calling of this method
     * @throws IllegalArgumentException
     */
    public void sendAction (final String action, final byte priority)
    	throws IllegalArgumentException
    {
    	if (action == null || action.length() == 0)
    		throw new IllegalArgumentException("The outgoing message cannot be null") ;
    	
        sendCTCPCommand("ACTION " + action, priority);
    }
    
    /**
     * Sends a CTCP command to a channel or user.  (Client to client protocol).
     * 
     * Messages are sent at a default NORMAL priority
     * 
     * @param command The CTCP command to send.
     * @throws IllegalArgumentException
     */
    public void sendCTCPCommand (final String command) 
    	throws IllegalArgumentException
    {
    	sendCTCPCommand(command, PRIORITY_NORMAL) ;
    }
    
    /**
     * Sends a CTCP command to a channel or user.  (Client to client protocol).
     * 
     * @param command The CTCP command to send.
     * @param priority The priority with which a message is sent to the server
     * @throws IllegalArgumentException
     */
    public void sendCTCPCommand (final String command, final byte priority) 
    	throws IllegalArgumentException
    {
    	if (command == null || command.length() == 0)
    		throw new IllegalArgumentException("The outgoing message cannot be null") ;
    	
    	if (fromIRCevent())
    	    sendMessage("\u0001" + command + "\u0001", getEvent().getEncoding(), priority) ;
    	else 
    		sendMessage("\u0001" + command + "\u0001", priority) ;
    }
    
   
    public void sendMessage (final String message) 
		throws IllegalArgumentException
	{
		sendMessage (message, PRIORITY_NORMAL) ;
	}

	public void sendMessage (final String message, final byte priority) 
		throws IllegalArgumentException
	{
		if (message == null || message.length() == 0)
			throw new IllegalArgumentException("The outgoing message canno be null") ;
		
		if (fromIRCevent())
			getConnection().send("PRIVMSG "+getNick()+" :"+message.trim(), getEvent().getEncoding(), priority) ;
		else
			getConnection().send("PRIVMSG "+getNick()+" :"+message.trim(), priority) ;
	}

	public void sendMessage (final String message, final String encoding, final byte priority) 
		throws IllegalArgumentException
	{
		if (message == null || message.length() == 0)
			throw new IllegalArgumentException("The outgoing message canno be null") ;
			
		getConnection().send("PRIVMSG "+getNick()+" :"+message.trim(), encoding, priority) ;
	}

	public void sendNotice (final String message) 
    	throws IllegalArgumentException
    {
    	sendNotice (message, PRIORITY_NORMAL) ;
    }
    
    public void sendNotice (final String message, final byte priority) 
    	throws IllegalArgumentException
    {
    	if (message == null || message.length() == 0)
    		throw new IllegalArgumentException("The outgoing message canno be null") ;
    	
    	if (fromIRCevent())
    		getConnection().send("NOTICE "+getNick()+" :"+message.trim(), getEvent().getEncoding(), priority) ;
    	else
    		getConnection().send("NOTICE "+getNick()+" :"+message.trim(), priority) ;
    }
    
    public void sendNotice (final String message, final String encoding, final byte priority) 
    	throws IllegalArgumentException
    {
    	if (message == null || message.length() == 0)
    		throw new IllegalArgumentException("The outgoing message canno be null") ;
    		
    	getConnection().send("NOTICE "+getNick()+" :"+message.trim(), encoding, priority) ;
    }
    
    /**
	 * 
	 * @param nick A new nickname as found by a nick name change event on IRC
	 * @throws IllegalArgumentException
	 */
	public void setNick (String nick)
		throws IllegalArgumentException
	{
		if (nick == null || nick.length() == 0)
			throw new IllegalArgumentException("Cannot change nickname - data passed is null or length zero") ;
		
		this.nickname = nick.trim() ;
	}

	/** Overridden toString method */
	@Override
	public String toString ()
	{
	    return "[IRCuser "+this.getNick()+" ("+this.ident+"@"+this.hostname+")]" ;   
	}
}
