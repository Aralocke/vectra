package org.vectra.exceptions;

public class NotOnChannelException
    extends Exception
{
    protected long time ;
    public static final long serialVersionUID = 5 ;
    public NotOnChannelException (final String error)
    {
        super(error) ;
        this.time = System.currentTimeMillis() ;
    }
}