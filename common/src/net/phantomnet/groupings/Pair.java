package net.phantomnet.groupings;

import net.phantomnet.Groupable;

public class Pair<K, V>
	implements Groupable<K, V>
{

	/**
	 * Unique identifier
	 */
	private static final long serialVersionUID = -1362549133518866165L;
	
	private final K key ;
	
	private final V value ;
	
	public Pair (final K key, final V value)
	{
		this.key = key ;
		this.value = value ;
	}

	public K getKey() 
	{
		return key;
	}

	public V getValue() 
	{
		return value;
	}
	
	public String toString ()
	{
		return "[Pair <"+getKey()+", "+getValue()+">]" ;
	}
}
