package org.vectra.exceptions;

public class AlreadyOnChannelException
    extends Exception
{
    protected long time ;
    public static final long serialVersionUID = 1 ;
    public AlreadyOnChannelException (final String error)
    {
        super(error) ;
        this.time = System.currentTimeMillis() ;
    }
}
