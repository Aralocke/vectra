package org.vectra.irc;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import net.phantomnet.events.IRCPartEvent;
import net.phantomnet.events.IRCQuitEvent;
import net.phantomnet.groupings.Pair;

import org.vectra.StrUtils;
import org.vectra.irc.observer.IRCPartObserver;
import org.vectra.irc.observer.IRCQuitObserver;

public class IRCUserList
	implements IRCQuitObserver, IRCPartObserver {

	private final Map<String, Pair<Integer, String>> cachedUserList = new HashMap<String, Pair<Integer, String>>();
	
	private final Map<String, String> activeUsers = new HashMap<String, String>();
	
	private int lastRehash = 0;
	
	private final String userFile ;
	
	/**
     * Lock object used to synchronize this class
     */
    private final ReadWriteLock lock = new ReentrantReadWriteLock() ;
	
	public IRCUserList(final File dataFile) 
		throws FileNotFoundException, IllegalArgumentException 
	{
		if (dataFile == null)
			throw new IllegalArgumentException("Supplied user's file cannot be null");
		this.userFile = dataFile.getAbsolutePath();
		rehash(false);
	}
	
	public int getCachedUserCount() {
		this.lock.readLock().lock();
		try {
			return this.cachedUserList.size();
		} finally {
			this.lock.readLock().unlock();
		}
	}
	
	public String getPassword(final String userName) 
		throws IllegalArgumentException 
	{
		if (userName == null || userName.isEmpty())
			throw new IllegalArgumentException("usernames cannot be null or length zero") ;
		final Pair<Integer, String> pair = this.cachedUserList.get(userName.trim());
		if (pair == null)
			return null;
		return pair.getValue();
	}
	
	public int getRank(final String userName) 
		throws IllegalArgumentException 
	{
		if (userName == null || userName.isEmpty())
			throw new IllegalArgumentException("usernames cannot be null or length zero") ;
		final Pair<Integer, String> pair = this.cachedUserList.get(userName.trim());
		if (pair == null)
			return 0;
		return pair.getKey();
	}
	
	public String getUser(final String hostMask) 
		throws IllegalArgumentException 
	{
		if (hostMask == null || hostMask.isEmpty())
			throw new IllegalArgumentException("Hostmask cannot be null or length zero") ;
		return this.activeUsers.get(hostMask.trim());
	}
	
	public int getLastRehash() {
		this.lock.readLock().lock();
		try {
			return IRCUtils.time() - this.lastRehash;
		} finally {
			this.lock.readLock().unlock();
		}
	}
	
	public boolean isLoggedIn(final IRCUser user)
		throws IllegalArgumentException 
	{
		return isLoggedIn(user.getProtocolAddress()) ;
	}
	
	public boolean isLoggedIn(final String hostMask)
		throws IllegalArgumentException 
	{
		if (hostMask == null || hostMask.isEmpty())
			throw new IllegalArgumentException("Hostmask cannot be null or length zero") ;
		return this.activeUsers.containsKey(hostMask.trim());
	}
	
	public boolean login (final IRCUser user, final String username, final String password) {
		// the username can't be empty
		if (username == null || username.isEmpty())
			return false;
		// the password can't be empty 
		if (password == null || password.isEmpty() || password.length() != 32)
			return false;
		// double check that a login isn't already available
		final String existingUser = this.activeUsers.get(user.getProtocolAddress());
		if (existingUser != null) {
			if (existingUser.equals(username))
				return true; 
			else
				return false;
		}			
		// grab the data for the requested user
		final Pair<Integer, String> pair = this.cachedUserList.get(username.trim());
		// in case it is null issue the failed login
		if (pair == null)
			return false;
		// hash the supplied password
		final String hash = IRCUtils.md5(password);
		// if the hashed password equals the saved password hash
		final boolean successfulLogin = hash.equals(pair.getValue());
		// if a successfulLogin failed just return that
		if (!successfulLogin)
			return false;
		// save the successful login in the activeUsers list
		this.activeUsers.put(user.getProtocolAddress(), username);
		// login succeeded
		return true;
	}

	public void observePart(final IRCPartEvent event) throws Exception {

	}

	public void observeQuit(final IRCQuitEvent event) throws Exception {
		final IRCUser user = event.getUser();
		// the user quit so we remove them from the login list
		this.activeUsers.remove(user.getProtocolAddress());
	}
	
	public void rehash(final boolean withThread) 
		throws FileNotFoundException 
	{
		// Step one: verify user file still exists
		final File cacheFile = new File(this.userFile);
		if (!cacheFile.exists())
			throw new FileNotFoundException("Cannot initiate rehash: File "+this.userFile+" not found!");
		// Step two: Set the write lock - as of this point it must complete
		this.lock.writeLock().lock();
		// Step three: clear the cachedUsers' list
		this.cachedUserList.clear();
		// Step four: initiate the thread to rehash
		if (withThread)
			new Rehash().start();
		else
			new Rehash().run();
	}
	
	private final class Rehash 
		extends Thread 
	{
		public void run() {
			lastRehash = IRCUtils.time();
			try {
				final File cacheFile = new File(userFile);
				final Scanner input = new Scanner(cacheFile);
				while (input.hasNext()) {
					final String line = input.nextLine();
					final List<String> data = StrUtils.split(line, ':');
					if (data.size() == 3) 						
						try {
							cachedUserList.put(data.get(0), new Pair<Integer, String>(Integer.parseInt(data.get(1)), data.get(2)));
						} catch (final Exception e) {
							cachedUserList.put(data.get(0), new Pair<Integer, String>(0, data.get(2)));
						}				
				}
			} catch (Exception e) {

			} finally {
				lock.writeLock().unlock();
			}
		} //run()
	} // subclass Rehash
	
}
