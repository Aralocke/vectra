package org.vectra;
import org.vectra.interfaces.Color ;
import org.vectra.interfaces.Events;
import org.vectra.interfaces.Source;

public abstract class Event
    implements Events, Source, Color
{
    /**
	 * Unique ID
	 */
	private static final long serialVersionUID = -7533867757195297567L;
	
	protected final Connection connection ;
    protected final String encoding ;
    
    public Event (final Connection connection, final String encoding)
        throws IllegalArgumentException
    {
        //if (connection == null || !connection.isConnected())
        //    throw new IllegalArgumentException("Supplied connection is null or disconnected") ;
        if (encoding == null | encoding.length() == 0)
            throw new IllegalArgumentException("Supplied type of encoding is null or length zero") ;
        
        this.connection = connection ;
        this.encoding = encoding ;
    }
    
    public Connection getConnection ()
    {
        return this.connection ;
    }
    
    public final String getEncoding ()
    {
        return this.encoding ;          
    }
    
    public abstract String getEvent () ;
    
    public abstract String getMessage () ;
 
    public abstract int getType () ;
    
    public static int numType (String event) 
    {
        if (event == null || event.isEmpty())
        	return -1 ;
        if (event.equalsIgnoreCase("CONNECT"))  
        	return E_CONNECT ; 
        if (event.equalsIgnoreCase("ERROR"))  
        	return E_ERROR; 
        if (event.equalsIgnoreCase("LOGON"))  
        	return E_LOGON; 
        if (event.equalsIgnoreCase("PING"))  
        	return E_PING ;
        if (event.equalsIgnoreCase("PONG"))  
        	return E_PONG ; 
        if (event.equalsIgnoreCase("PRIVMSG"))  
        	return E_PRIVMSG ; 
        if (event.equalsIgnoreCase("RAW"))  
        	return E_RAW ; 
        if (event.equalsIgnoreCase("START"))  
        	return E_START ; 
        return -1 ;
    }
    
    public static String stringEvent (int event) 
    {
    	String numType = "" ;
    	switch (event)
        {
            case E_CONNECT: 
                numType = "CONNECT" ; 
            break ;
            case E_ERROR: 
                numType = "ERROR" ; 
            break ;
            case E_LOGON: 
                numType = "LOGON" ; 
            break ;
            case E_PING: 
                numType = "PING" ; 
            break ;
            case E_PONG: 
                numType = "PONG" ; 
            break ;
            case E_PRIVMSG: 
                numType = "PRIVMSG" ; 
            break ;
            case E_RAW: 
                numType = "RAW" ; 
            break ;
            case E_START: 
                numType = "START" ; 
            break ;
            default: 
                numType = "UNKNOWN" ; 
            break ;
        }
        return numType ;
    }
}
