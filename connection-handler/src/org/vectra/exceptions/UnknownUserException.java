package org.vectra.exceptions;

public class UnknownUserException
    extends Exception
{
    protected long time ;
    public static final long serialVersionUID = 7 ;
    public UnknownUserException (final String error)
    {
        super(error) ;
        this.time = System.currentTimeMillis() ;
    }
}
