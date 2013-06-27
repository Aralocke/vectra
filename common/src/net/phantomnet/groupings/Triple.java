package net.phantomnet.groupings;

public class Triple<K, V, S>
	extends Pair<K, V>
{

	/**
	 * Unique serialized ID
	 */
	private static final long serialVersionUID = 2243637962160859559L;
	
	private final S secondary ;

	public Triple (final K key, final V value, final S secondary) 
	{
		super(key, value);	
		this.secondary = secondary ;
	}
	
	public S getSecond ()
	{
		return this.secondary ;
	}
	
	public String toString ()
	{
		return "[Triple <"+getKey()+" :: "+getValue()+", "+getSecond()+">]" ;
	}
}
