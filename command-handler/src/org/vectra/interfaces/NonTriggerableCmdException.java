package org.vectra.interfaces;

public class NonTriggerableCmdException
	extends IllegalStateException
{
    protected long time ;
    public static final long serialVersionUID = 1 ;
    public NonTriggerableCmdException (final String error)
    {
        super(error) ;
        this.time = System.currentTimeMillis() ;
    }
}
