package org.vectra.interfaces;

import java.util.regex.Pattern ;

public interface IRCModes 
{
	public static final Pattern modeMatcher = Pattern.compile("[+-][a-zA-Z]+") ;
}
