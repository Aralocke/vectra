package org.vectra;

import java.util.Collection;
import java.util.Iterator;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.CopyOnWriteArrayList ;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.regex.Pattern;
/**
 * This class provides an extensible framework for maintaining internal synchronized
 * lists used by the Core system. An absract implementation of validate must be 
 * created whether or not it is actually used. Boolean false from Validate will force 
 * an IllegalArgumentException to be sent on a return of false.
 * 
 * This class was primarily designed to be the extensible backbone for uses like
 * an internal ignore list, or an internal access list where all data is checked
 * against wildcard based strings.
 * 
 * @author Danny
 *
 */
public abstract class InternalList<T>
    implements Iterable<T>
{
	/**
	 * Pattern matcher used by validate()
	 */
	private final Pattern matcher ;
	
    /**
     * Maintain a synced list of all active ignores
     */
    private final CopyOnWriteArrayList<T> list = new CopyOnWriteArrayList<T>() ;
    
    /**
     * Automatically whenever an entry with expiration >0 is added a timer will
     * be created to call remove
     */
    private final Timer expirationTimer = new Timer("IgnoreList auto-remove list", true) ;
    
    /**
     * Lock object used to synchronize this class
     */
    private final ReadWriteLock lock = new ReentrantReadWriteLock() ;
    
    public InternalList (final Pattern matcher) {
    	this.matcher = matcher ;
    }
    
    /**
     * Add a string to the internal list maintained by this class with no expiration
     * 
     * @param string String that will match against the validate() method
     * @throws IllegalArgumentException Thrown when the string is null, or length zero,
     *         or if the string fails to match against validate
     */
    public void add (T o) throws IllegalArgumentException {
        add(o, 0) ;
    }
    
    /**
     * Adds a string to the internal list that will match against the internal validator.
     * Given a time it will be automatically removed when it expires. If the time >0 it will
     * expire in current_time + seconds. An expiration of zero will not be removed.
     * 
     * @param string String that will match against the validate() method
     * @param expiration Time in which this entry will be removed
     * @throws IllegalArgumentException Thrown when the string is null, or length zero,
     *         or if the string fails to match against validate
     */
    public void add (final T o, long expiration)
        throws IllegalArgumentException
    {
        if (!validate(o))
            throw new IllegalArgumentException("passed value failed to validate") ;
        
        if (expiration < 0)
            throw new IllegalArgumentException("expiration must be greater or equal to 0") ;
        
        this.lock.writeLock().lock();
        try {
            this.list.add(o) ;
            if (expiration > 0) {
                this.expirationTimer.schedule(new TimerTask() {
                        public void run () {
                            remove(o) ;
                        }
                    }, 
                    expiration) ;
            }
        } finally {
        	this.lock.writeLock().unlock();
        }
    }
    
    public void addAll(final Collection<T> c) {
    	addAll(c, 0);
    }
    
    public void addAll(final Collection<T> c, long duration) {
    	if (c.size() == 0)
    		return;
    	for (final T entry : c)
    		try {
    			validate(entry);
    			add(entry, duration);
    		} catch (final Exception e) {}
    }
    
    /**
     * Checks if the string exists inside the interal list by iterating through
     * the list. Boolean true is returned when the string matches a wildcard 
     * saved inside the internal list.
     * 
     * @param string String that will match against the validate() method
     * @return true if the string exists inside the internal list
     * @throws IllegalArgumentException Thrown when the string is null, or length zero,
     *         or if the string fails to match against validate
     */
    public boolean contains (T o) throws IllegalArgumentException {
        if (!validate(o))
            throw new IllegalArgumentException("passed string failed to validate") ;   
        this.lock.readLock().lock() ;
        try {            
        	return this.list.contains(o) ;
        } finally {
            this.lock.readLock().unlock() ;
        }        
    }
    
    public abstract Collection<T> getAll (T o) throws IllegalArgumentException ;
    
    public abstract T get (T o) throws IllegalArgumentException;
    
    
    /**
     * This iterator doesn't need to be synchronized on because of the internal properties
     * of the list that it is made up with. See javadocs for more information.
     * 
     * @returns Iterator<String> The iterator of the internal list.
     */
    public Iterator<T> iterator ()
    {
        this.lock.readLock().lock() ;
        try {
            return this.list.iterator() ;
        } finally {
            this.lock.readLock().unlock() ;
        }
    }
    
    /**
     * Removes all list entries that will match the given string. This could match one
     * or more entries but could potentially waste time if the entry does not have an
     * entry because the list must be traversed linearly.
     * 
     * @param string String that will match against the validate() method
     * @throws IllegalArgumentException Thrown when the string is null, or length zero,
     *         or if the string fails to match against validate
     */
    public void remove (T o)
        throws IllegalArgumentException
    {
        if (!validate(o))
            throw new IllegalArgumentException("passed string failed to validate") ;        
               
        this.lock.writeLock().lock() ;
        try {            
            this.list.remove(o) ;
        } finally {
            this.lock.writeLock().unlock() ;
        }
    }
    
    /**
     * @return The matching pattern used to validate an addition to the internal database
     */
    public final Pattern getMatcher() {
    	return this.matcher ;
    }
    
    /**
     * Provides validation for the entire list. This method is called during each 
     * of the primary add, remove, and get. This method provides match-text functionality.
     * 
     * @param string String to match against
     * @return boolean. It is recommended to return an IllegalStateException on failure
     *         rather than just true/false as the exception will pass through to the 
     *         initial caller method
     * @throws IllegalArgumentException
     */
    public abstract boolean validate (T o) throws IllegalArgumentException ;
}