package org.vectra.exceptions;

public class InvalidChannelException
    extends Exception
{
    protected long time ;
    public static final long serialVersionUID = 4 ;
    public InvalidChannelException (final String error)
    {
        super(error) ;
        this.time = System.currentTimeMillis() ;
    }
}