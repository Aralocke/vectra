package net.phantomnet;

import java.util.Collection;

public class ArrayUtils 
{	
    public final static <V> String implode (String thread, Collection<V> collection)
	{
		return implode(thread, collection.toArray()) ;
	}
	
	public final static <V> String implode (String thread, V[] haystack)
	{
		StringBuilder str = new StringBuilder() ;
		for (int i = 0; i < haystack.length; i++)
		{
			if (i == 0)
				str.append(haystack[i].toString()) ;
			else if (i == (haystack.length - 1))
				str.append(haystack[i].toString()) ;
			else
				str.append(thread+""+haystack[i].toString().trim()) ;
		}
		return str.toString() ;
	}
	
	public final static void reverse (Object[] a) 
	{
		for (int i = 0; i < a.length; i++) {
			final Object temp = a[i];
			a[i] = a[(a.length -1) - i];
			a[(a.length -1) - i] = temp;
		}
	}
}
