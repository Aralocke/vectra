package org.vectra.exceptions;

public class SocketTimeoutException
    extends Exception
{
    protected long time ;
    public static final long serialVersionUID = 6 ;
    public SocketTimeoutException (final String error)
    {
        super(error) ;
        this.time = System.currentTimeMillis() ;
    }
}