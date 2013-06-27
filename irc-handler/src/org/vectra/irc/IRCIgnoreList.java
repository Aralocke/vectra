package org.vectra.irc;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.regex.Pattern;

import org.vectra.InternalList;
import org.vectra.Wildcard;

public class IRCIgnoreList 
	extends InternalList<String>
{
	public static final Pattern MATCHER = Pattern.compile("(.+)!(.+)@(.+)") ;
	
	public IRCIgnoreList () {
		super(MATCHER);
	}
	
	/**
	 * Returns the first wildCard match against the given valid IRC hostmask. This method
	 * only returns the first method found, this means that there may still be other matching 
	 * entries so if this is being used to find the number of matches, use getAll()
	 */
	public final String get(final String hostMask) 	
		throws IllegalArgumentException 
	{
		validate(hostMask);
		final Iterator<String> it = iterator();
		while (it.hasNext()) {
			final String wildCard = it.next();
			if (Wildcard.matches(wildCard, hostMask))
				return wildCard;
		}			
		return null;
	}
	
	/**
	 * Returns a list of all wildCard strings that match the given valid IRC hostmask. The
	 * collection will contain any wildcard match that will match the hostname so it is a 
	 * good idea to use this feature carefully.
	 */
	public Collection<String> getAll(String hostMask) 
		throws IllegalArgumentException 
	{
		validate(hostMask);
		final Collection<String> list = new ArrayList<String>();
		final Iterator<String> it = iterator();
		while (it.hasNext()) {
			final String wildCard = it.next();
			if (Wildcard.matches(wildCard, hostMask))
				list.add(wildCard);
		}
		return list;
	}
	
	/**
	 * Linear search through the built in list that will check if the specified valid
	 * IRC hostmask matches an entry inside the IgnoreList. This uses the built-in 
	 * wildcard matching provided in the Common package. 
	 */
	public final boolean matches (final String hostMask) 
		throws IllegalArgumentException 
	{		
		validate(hostMask);
		final Iterator<String> it = iterator();
		while (it.hasNext()) 
			if (Wildcard.matches(it.next(), hostMask))
				return true;		
		return false;
	}

	/**
	 * Removes all entries that match the given IRC hostmask. As an example if given *!*@*
	 * all entries in the list would be remove as this matches everything.
	 */
	public int removeMatches(String hostMask) 	
		throws IllegalArgumentException 
	{
		validate(hostMask);
		final Collection<String> list = getAll(hostMask);
		for (final String wildCard : list)
			remove(wildCard);
		return list.size();
	}

	public final boolean validate (final String hostmask)
		throws IllegalArgumentException
	{
		if (hostmask == null || hostmask.length() < 5)
			throw new IllegalArgumentException("Invalid IRC host mask :: supplied hostmask is null or to short") ;
		if (!getMatcher().matcher(hostmask).matches())
			throw new IllegalArgumentException("Invalid IRC host mask") ;
		return true ;
	}
}
