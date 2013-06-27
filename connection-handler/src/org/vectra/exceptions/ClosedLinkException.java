package org.vectra.exceptions;

import org.vectra.interfaces.Encoded;

public class ClosedLinkException
    extends Exception
    implements Encoded
{
	private static final long serialVersionUID = 7935476486817698477L;
	
	private final long time ;
	private final String encoding ;
    
    public ClosedLinkException (final String error)
    {
        this(error, "UTF-8");
    }
    
    public ClosedLinkException (final String error, final String encoding)
    {
        super(error) ;
        this.time = System.currentTimeMillis() ;
        this.encoding = encoding.trim();
    }
    
    public long getTime() {
    	return time;
    }
    
    public String getEncoding() {
    	return encoding;
    }
}