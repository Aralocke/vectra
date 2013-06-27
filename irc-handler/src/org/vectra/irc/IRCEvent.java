package org.vectra.irc;
import org.vectra.exceptions.UnknownUserException;
import org.vectra.interfaces.Encoded;
import org.vectra.interfaces.Source;
import org.vectra.interfaces.IRCEvents;
import org.vectra.irc.IRCConnection;
import org.vectra.irc.IRCUser;
import org.vectra.Event;

public class IRCEvent    
    extends Event
    implements Encoded, Source, IRCEvents
{
	/**
	 * Unique ID
	 */
	private static final long serialVersionUID = 534668825072239379L;
	private final IRCConnection connection ;
	private final IRCUser user ;
    private final String raw ;
    private final String message ;
    private final String target ;
    private final String event ;
    private int type ; 
    private int numeric ;
    
    public IRCEvent (final IRCEvent event)
    {
    	super(event.getConnection(), event.getEncoding()) ;
    	this.connection = event.getConnection() ;
    	this.user = event.getUser() ;
    	this.raw = event.getRaw() ;
    	this.event = event.getEvent();
    	this.message = event.getMessage();
    	this.target = event.getTarget();
    	this.type = event.getType();
    	this.numeric = event.getNumeric();
    }

    public IRCEvent(String raw, String encoding, IRCConnection connection)
    	throws IllegalArgumentException
    {
    	super(connection, encoding) ;
    	this.connection = connection;
        this.raw = IRCUtils.stripCodes(raw.trim()) ;
        // Remove starting colon
        if (this.raw.startsWith(":"))
            raw = this.raw.substring(1).trim() ;

        final String[] rawArray = raw.split(" ") ;
        
        IRCUser user = null ;
        int type = -1, numeric = 0 ;
        String event = null ;
        String message = null ;
        String target = null ;
        
        if (rawArray[0].equals("PING") || rawArray[0].equals("PONG") || rawArray[0].equals("ERROR")) 
        {
        	event = rawArray[0].trim() ;
        	type = numType(event) ;
        	message = raw.substring(raw.indexOf(":")+1).trim();
        } 
        else 
        {
        	// Step one - Parse out a user
        	try
        	{
        		user = new IRCUser(rawArray[0], this) ;
        	} catch (final UnknownUserException e) {
        		// Check for a usermode
        		if (rawArray[1].equals("MODE") && IRCUser.validUserHost.matcher(rawArray[0]).matches())
        		{
        			event = "USERMODE" ;
        			type = numType(event) ;
        			try {
						user = new IRCUser(rawArray[0]+"!*@*", this) ;
					} catch (UnknownUserException e1) {
						user = null ;
					}
        		}
        		else if (rawArray[1].equals("NOTICE"))
                {
                    type  = E_SNOTICE ; 
                    event = stringEvent(type) ;
                    user  = null ;
                }
                else
                {
                    // failed to find a user - not a user event
                    user = null ;
                    // Proceed to parse for other events   
                }
        	} finally {
        		raw = raw.substring(raw.indexOf(" ")).trim() ;
        	}
        }
        
        // Step two - Check for and parse a RAW
        try {
            type    = Integer.parseInt(rawArray[1].trim()) ;
            numeric = type ;
            event   = "RAW" ;
            type    = numType(event) ;
        } catch (NumberFormatException e) {
            // Not a RAW numeric so take the textual representation and run with it
            if (event == null)
            {
                event = rawArray[1].trim() ;
                type  = numType(event) ; 
            }
        } finally {
        	raw = raw.substring(raw.indexOf(" ")).trim() ;
        }
        
        if (type == E_JOIN || type == E_PART || type == E_QUIT)
        {   
        	if (type == E_PART)
        	{
        		target = (raw.split(" ").length > 1) ? raw.substring(0, raw.indexOf(" ")).trim() : raw.trim() ; 
        		message = raw.substring(raw.indexOf(" ")+1).trim() ;
        		// parse out the colon signifying a part message
        		// otherwise set the message as the channel
        		message = (message.startsWith(":")) ? message.substring(1).trim() : target;
        	}
        	else
        	{
        		message = (raw.startsWith(":")) ? raw.substring(1).trim() : raw.trim() ;
        		target = (type == E_QUIT) ? user.getNick() : message ;
        	}
            
        }
        else if (type != E_ERROR && type != E_PING && type != E_PONG)
        {
        	// grab the target from the first parameter
        	target = raw.substring(0, raw.indexOf(" ")).trim() ;
        	// parse out the now saved target
        	raw = raw.substring(raw.indexOf(" ")).trim() ;
        	// grab the message 
        	message = (raw.startsWith(":")) ? raw.substring(1) : raw ;
        }
        
        if (target == null && user != null)
        	target = user.getNick();
        
        // handle ctcp/actions now
        if (message.charAt(0) == '\u0001')
        {
        	if (message.trim().startsWith("ACTION")) {
        		event = "ACTION" ;
        		type = E_ACTION ;
        		message = message.trim().substring(message.trim().indexOf(' ')) ;
        	} else {
        		event = "CTCP" ;
        		type = E_CTCP ;
        	}
        }
        
        this.type = type ;
        this.numeric = numeric ;
        this.event = event ;
        this.message = message.trim() ;
        this.target = target ;
        this.user = user ;
    }    
    
    public int getType ()
    {
    	return this.type ;
    }
    
    public int getNumeric ()
    {
    	return this.numeric ;
    }
    
    public String getEvent ()
    {
    	return this.event ;
    }
    
    public String getMessage ()
    {
    	return this.message ;
    }
    
    public String getRaw ()
    {
    	return this.raw ;
    }
    
    public String getTarget ()
    {
    	return this.target ;
    }
    
    public IRCUser getUser()
    {
    	return this.user ;
    }
    
    public boolean hasNumeric ()
    {
    	return this.type == E_RAW ;
    }
    
    public IRCConnection getConnection ()
    {
    	return this.connection ;
    }
    
    public String toString()
    {
    	StringBuilder string = new StringBuilder("[IRCEvent ::") ;
        if (getType() == E_PING)
        	string.append(" PING ["+E_PING+"] | Message: "+getMessage());
        else if (this.type == E_RAW)
        	string.append(" RAW ["+E_RAW+"] | NUMERIC: "+getNumeric()+" | TARGET: "+getTarget()+" | MESSAGE => "+getMessage()) ;
        else
        	string.append(" "+getEvent()+" ["+getType()+"] | TARGET: "+getTarget()+" | MESSAGE: "+getMessage()) ;
        if (this.user != null)
        	string.append(" | USER: "+this.user) ;
        return string.append("]").toString();
    }
   
    public static int numType (String event)
    {
        if (event == null || event.isEmpty())
        	return -1 ;
        if (event.equalsIgnoreCase("ACTION"))  
            return E_ACTION ; 
        if (event.equalsIgnoreCase("BAN"))  
            return E_BAN ; 
        if (event.equalsIgnoreCase("INVITE"))  
            return E_INVITE ; 
        if (event.equalsIgnoreCase("JOIN"))  
            return E_JOIN ;
        if (event.equalsIgnoreCase("KICK"))  
            return E_KICK ; 
        if (event.equalsIgnoreCase("MODE"))  
            return E_MODE ; 
        if (event.equalsIgnoreCase("NICK"))  
            return E_NICK ; 
        if (event.equalsIgnoreCase("NOTICE"))  
            return E_NOTICE ; 
        if (event.equalsIgnoreCase("NOTIFY"))  
            return E_NOTIFY ; 
        if (event.equalsIgnoreCase("PART"))  
            return E_PART ;
        if (event.equalsIgnoreCase("QUIT"))  
            return E_QUIT ; 
        if (event.equalsIgnoreCase("SERVERMODE"))  
            return E_SERVERMODE ; 
        if (event.equalsIgnoreCase("SNOTICE"))  
            return E_SNOTICE ; 
        if (event.equalsIgnoreCase("TOPIC"))  
            return E_TOPIC ; 
        if (event.equalsIgnoreCase("UNBAN"))  
            return E_UNBAN ; 
        if (event.equalsIgnoreCase("UNOTIFY"))  
            return E_UNOTIFY ; 
        if (event.equalsIgnoreCase("USERMODE"))  
            return E_USERMODE ;  
        return Event.numType(event) ;
    }
    
    public static String stringEvent (int event)
    {
        String numType = "" ;
        switch (event)
        {
            case E_ACTION: 
                numType = "ACTION" ; 
            break ;
            case E_BAN: 
                numType = "BAN" ; 
            break ;
            case E_INVITE: 
                numType = "INVITE" ; 
            break ;
            case E_JOIN: 
                numType = "JOIN" ;
            break ;
            case E_KICK: 
                numType = "KICK" ; 
            break ;
            case E_MODE: 
                numType = "MODE" ; 
            break ;
            case E_NICK: 
                numType = "NICK" ; 
            break ;
            case E_NOTICE: 
                numType = "NOTICE" ; 
            break ;
            case E_NOTIFY: 
                numType = "NOTIFY" ; 
            break ;
            case E_PART: 
                numType = "PART" ; 
            break ;
            case E_QUIT:
               numType = "QUIT" ;
            break ;
            case E_SERVERMODE: 
                numType = "SERVERMODE" ; 
            break ;
            case E_SNOTICE: 
                numType = "SNOTICE" ; 
            break ;
            case E_TOPIC: 
                numType = "TOPIC" ; 
            break ;
            case E_UNBAN: 
                numType = "UNBAN" ; 
            break ;
            case E_UNOTIFY: 
                numType = "UNNOTIFY" ; 
            break ;
            case E_USERMODE: 
                numType = "USERMODE" ; 
            break ;   
            default: 
                numType = Event.stringEvent(event) ; 
            break ;
        }
        return numType ;
    }   
}
