package org.vectra.exceptions;

public class NoBindHostException
    extends IllegalStateException
{
    protected long time ;
    public static final long serialVersionUID = 8 ;
    public NoBindHostException (final String error)
    {
        super(error) ;
        this.time = System.currentTimeMillis() ;
    }
}

