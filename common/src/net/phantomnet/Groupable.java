package net.phantomnet;

import java.io.Serializable;

public interface Groupable<K, V> 
	extends Serializable
{
	public K getKey() ;
	
	public V getValue() ;
}
