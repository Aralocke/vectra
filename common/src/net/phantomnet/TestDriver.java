package net.phantomnet;
import java.util.List;

import org.vectra.* ;

public class TestDriver {

	public static void main(String[] args) {
		System.runFinalization();
		System.gc();
		
		try
		{
			final long start = System.nanoTime() ;
			// ----------------------------------------------
			final String a = "abc 123 def  456 ghi 789 " ;
			final List<String> list = StrUtils.split(a, ' ') ;
			System.out.println("list contains "+list.size()+" elements") ;
			for (int i = 0; i < list.size(); i++)
				System.out.println(i+") "+list.get(i)) ;
			// ----------------------------------------------
			final long stop = System.nanoTime() ;
			System.out.println("Execution took "+(stop - start)+"ns") ;
		} catch (Throwable t) {
			
		} finally {
			
		}
	}

}
