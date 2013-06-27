package org.vectra.irc ;

import java.io.IOException ;
import java.io.OutputStream;
import java.net.SocketException ;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CoderResult;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.TreeMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.logging.Level;
import java.util.logging.Logger;

import net.phantomnet.events.*;
import net.phantomnet.groupings.Pair;

import org.vectra.ArrayUtils;
import org.vectra.BotConfig;
import org.vectra.Connection;
import org.vectra.Event;
import org.vectra.Message;
import org.vectra.StrUtils;
import org.vectra.exceptions.ClosedLinkException;
import org.vectra.exceptions.ConnectionFailedException;
import org.vectra.exceptions.SocketTimeoutException;
import org.vectra.exceptions.UnknownUserException;
import org.vectra.interfaces.IRCChannelStatus;
import org.vectra.interfaces.IRCEvents;
import org.vectra.interfaces.Named;
import org.vectra.interfaces.Priority;
import org.vectra.irc.IRCChannel;
import org.vectra.irc.IRCEvent;
import org.vectra.irc.casemapping.CasemappingASCII;
import org.vectra.irc.exceptions.ChannelConflictException;
import org.vectra.irc.exceptions.UserConflictException;
import org.vectra.irc.observer.*;

public class IRCConnection 
    extends Connection
    implements IRCChannelStatus, IRCEvents, Iterable<IRCChannel>, Named, Priority
{  
	private IRCBotConfig config ;
	
	private IRCIgnoreList ignoreList ;
	
	private IRCUserList userList ;
	
    private TreeMap<String, IRCUser> internalAccessList ;
    
    private boolean isLoggedOn;

	private int lastCheck = IRCUtils.time();

	private int lastPing;

	private final ReadWriteLock lock = new ReentrantReadWriteLock(true);
	
	private Thread readerThread;	
	
	private static final long serialVersionUID = 1L;
	
	private IRCUser me = null ;
	
	private String modes = "";
	
	/**
     * Permanent TreeMap representing the channels currently in use by this bot
     * Upon disconnecting, this map will remain active preserving channels it holds.
     * When this BotConfig successfully reconnects to a server, it will attempt to 
     * auto-rejoin all channels it previously existed it before exiting the IRC server
     */
    private TreeMap<String, IRCChannel> channelList = new TreeMap<String, IRCChannel>() ;
	
	/**
	 * Stores all permanent information regarding the IRC server we 
	 * are currently connected to. All information is gathered from
	 * the RAW 004 and 005
	 */
	private IRCConfig serverConfig ;

	public IRCConnection (final IRCBotConfig config, final IRCIgnoreList ignoreList, final IRCUserList userList)
        throws IOException, SocketException
    {
        super(config.getBindAddress(), 0) ; 
        this.setIgnoreList(ignoreList);
        this.setConfig(config) ;        
        this.setReconnectStatus(true) ;
        this.setConnecting(false) ;
        this.setDisconnected(false) ;
        this.onStart() ; 
        this.userList = userList;
        this.uptime = 0 ;
        this.lastRead = 0 ;
        this.lastWrite = 0 ;
        this.isLoggedOn = false;
        this.serverConfig = null;
    }    
   
	public void addChannel (final IRCChannel channel) 
    	throws ChannelConflictException 
    {
    	this.lock.writeLock().lock();
    	try {
    		if (getChannelMap().containsKey(channel.getName()))
    			throw new ChannelConflictException("Attempting to join a channel already in the internal list");
    		getChannelMap().put(channel.getName(), channel) ;
    	} finally {
    		this.lock.writeLock().unlock();
    	}
    }

	/**
	 * Attempt to change the current nick (nickname) of the bot when it
	 * is connected to an IRC server.
	 *
	 * @param newNick The new nick to use.
	 * @param encoding String encoding type. This is supplied by the IRCevent
	 *                 which triggered the calling of this method
	 * @throws IllegalArgumentException
	 */
	public final void changeNick (String newNick, String encoding)
		throws IllegalArgumentException
	{
		if (newNick == null || newNick.length() == 0)
			throw new IllegalArgumentException("Supplied new nickname is null or empty") ;
		
	    this.send("NICK " + newNick, encoding, PRIORITY_MEDIUM) ;
	}

	/**
	 * Set the mode of a channel.
	 * 
	 * @param channel  The channel on which to perform the mode change.
	 * @param mode     The new mode to apply to the channel.  This may include
	 *                 zero or more arguments if necessary.
	 * @param encoding String encoding type. This is supplied by the IRCevent
	 *                 which triggered the calling of this method
	 * 
	 * @throws IllegalArgumentException
	 */
	public final void changeMode (String target, String mode, String encoding) 
		throws IllegalArgumentException
	{
		if (target == null || target.length() < 2)
			throw new IllegalArgumentException("Cannot set mode :: target is null or length <2") ;
		
		if (mode == null || mode.length() < 2)
			throw new IllegalArgumentException("Cannot set mode :: mode string is to short or null") ;
		
	    this.send("MODE " + target + " " + mode, encoding, PRIORITY_MEDIUM);
	}
	
	private void checkPermChannels(final IRCEvent event) {
		// don't trigger if uptime is less than 60 seconds
		if ((IRCUtils.time() - this.uptime) < 60)
			return ;
		if (isDisconnected())
			return ;
		if (getConfig().isAdministrator()) {
			final String logChannel = getConfig().getLogChannel();
			if (!onChannel(logChannel)) {
				joinChannel(logChannel, event.getEncoding());
				Logger.getLogger("org.vectra.connectionstatus").log(Level.CONFIG, "CHECKPERM "+logChannel, new Object[] {event, logChannel}) ;
			}
		}
		final String staffChannel = getConfig().getStaffChannel();
		if (!onChannel(staffChannel)) {
			joinChannel(staffChannel, event.getEncoding());
			Logger.getLogger("org.vectra.connectionstatus").log(Level.CONFIG, "CHECKPERM "+staffChannel, new Object[] {event, staffChannel}) ;
		}
		// check for staff channel
	}

	public void connect ()
        throws ConnectionFailedException
    {
    	connect (config.getAvailableServer(), 6667) ;
    }

	public void connect (String remoteAddress, int remotePort)
        throws ConnectionFailedException
    {    
    	super.lock.writeLock().lock();
		try {
	        try {
	        	// call the socket_connect
	            super.socket_connect(remoteAddress, remotePort) ;
	            // set the connection status to connecting
	            this.setConnecting(true) ;
	            // call the onConnect event
	            this.onConnect() ;
	        } catch (Exception e) {
	            this.onConnectFail(e) ;
	        }
		} finally {
			super.lock.writeLock().unlock();
		} 
    }
    
    public final void close ()
    {
        super.lock.writeLock().lock();
		try {
			this.lock.writeLock().lock();
			try	{
				if (this.readerThread != null) {
					this.readerThread.interrupt();
					this.readerThread = null ;
				}
			} finally {
				this.lock.writeLock().unlock();
			}
	        super.socket_close() ;
	        this.socket = null ; 
		} finally {
			super.lock.writeLock().unlock();
			this.setDisconnected(true) ;
	        this.setConnecting(false) ;
		} 

		// attempt to initiate a soft reconnect 
		if (getReconnectStatus() && getConfig().getReconnectCount() == 0) {
			passEvent(new DisconnectEvent(this, "UTF-8"));
		}
    }

	public final IRCChannel getChannelByName (final String channelName)
	{
		this.lock.readLock().lock() ;
	    try {
	        return getChannelMap().get(channelName.trim()) ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}
	
	public final TreeMap<String, IRCChannel> getChannelMap () {
        this.lock.readLock().lock();
        try {
            return this.channelList ;
        } finally {
            this.lock.readLock().unlock();
        }
    }

	/**
     * 
     * @return Returns an ArrayList of the IRCChannel's currently occupied by this bot
     * @see IRCChannel
     */
    public final List<String> getChannels () {
        this.lock.readLock().lock();
        try {
            return new ArrayList<String>(this.channelList.keySet()) ;
        } finally {
            this.lock.readLock().unlock();
        }
    } 
    
    /**
	 * 
	 * @return Returns the number of channels that this Bot currently holds
	 */
	public final int getChannelCount () {
	    return getChannels().size() ;
	}

	public List<IRCChannel> getCommonChannels (final IRCUser user)
	{
		final ArrayList<IRCChannel> list = new ArrayList<IRCChannel>() ;
		for (final IRCChannel channel : getChannelMap().values())
			if (channel.getUsers().contains(user))
				list.add(channel) ;
		return list ;
	}

	public final IRCBotConfig getConfig ()
	{
	    this.lock.readLock().lock() ;
	    try {
	        return (IRCBotConfig) this.config ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}
	
	public TreeMap<String, IRCUser> getIAL ()
	{
		this.lock.readLock().lock();
		try {
			return this.internalAccessList ;
		} finally {
			this.lock.readLock().unlock();
		}
	}
	
	public IRCIgnoreList getIgnoreList () {
		return this.ignoreList ;
	}
	
	public IRCConfig getIRCConfig () {
		return this.serverConfig ;	   
	}
	
	public String getModes() {
		this.lock.readLock().lock() ;
		try {
			return this.modes;
		} finally {
			this.lock.readLock().unlock() ;
		}
	}

	public String getName() {
		return getConfig().getName();
	}

	public Thread getReaderThread() 
	{		
		this.lock.readLock().lock() ;
		try {
			return readerThread;
		} finally {
			this.lock.readLock().unlock() ;
		}
	}
	
	public IRCUserList getUserList() {
		return this.userList;
	}
	
	public void ialAdd (final IRCUser user)
		throws IllegalArgumentException
	{
		if (user == null)
			throw new IllegalArgumentException("Supplied user is null or invalid") ;
		
		getIAL().put(user.getProtocolAddress(), user) ;
	}

	public boolean ialContains (String hostMask)
		throws IllegalArgumentException
	{
		if (hostMask == null || hostMask.length() < 3)
			throw new IllegalArgumentException("Supplied hostmask is null or invalid") ;
		if (! IRCUser.validUserHost.matcher(hostMask).matches())
			throw new IllegalArgumentException("Supplied hostmask is invalid") ;
		
		return getIAL().containsKey(hostMask) ;
	}

	public void ialRemove (String hostMask)
		throws IllegalArgumentException
	{
		if (hostMask == null || hostMask.length() < 5)
			throw new IllegalArgumentException("Supplied hostmask is null or invalid") ;
		if (! IRCUser.validUserHost.matcher(hostMask).matches())
			throw new IllegalArgumentException("Supplied hostmask is invalid") ;
		
		getIAL().remove(hostMask) ;
	}

	/**
	 * Joins a channel.
	 * @param channel The name of the channel to join.
	 * @param encoding String encoding type. This is supplied by the IRCevent
	 *                 which triggered the calling of this method
	 * @throws IllegalArgumentException
	 */
	public final void joinChannel (String channel, String encoding)
		throws IllegalArgumentException
	{
		if (channel == null || channel.length() < 1)
			throw new IllegalArgumentException("Cannot join channel :: channel is null or length 0") ;
		
		if (! IRCChannel.validChannel.matcher(channel).matches())
			throw new IllegalArgumentException("Cannot join channel :: improperly formatted channel") ;
		
	    this.send("JOIN " + channel, encoding, PRIORITY_MEDIUM) ;
	}

	/**
	 * Joins a channel with a key.
	 * 
	 * @param channel The name of the channel to join.
	 * @param key The key that will be used to join the channel.
	 * @param encoding String encoding type. This is supplied by the IRCevent
	 *                 which triggered the calling of this method
	 * @throws IllegalArgumentException
	 */
	public final void joinChannel (String channel, String key, String encoding) 
		throws IllegalArgumentException
	{   	
		if (key == null || key.length() < 1)
			throw new IllegalArgumentException("Cannot join channel :: supplied key is null or length 0") ;
		
	    this.joinChannel(channel + " " + key.trim(), encoding) ;
	}

	/**
	 * Sends an invitation to join a channel.  
	 * 
	 * @param nick    The nick of the user to invite
	 * @param channel The channel you are inviting the user to join.
	 * @param encoding String encoding type. This is supplied by the IRCevent
	 *                 which triggered the calling of this method
	 * @throws IllegalArgumentException
	 */
	public final void invite (String nick, String channel, String encoding) 
		throws IllegalArgumentException
	{
		if (channel == null || channel.length() < 1)
			throw new IllegalArgumentException("Cannot invite :: channel is null or length 0") ;
		
		if (! IRCChannel.validChannel.matcher(channel).matches())
			throw new IllegalArgumentException("Cannot invite :: improperly formatted channel") ;
		
		if (nick == null || nick.length() < 1)
			throw new IllegalArgumentException("Cannot invite :: nick is null or length 0") ;
		
	    this.send("INVITE " + nick + " :" + channel, encoding, PRIORITY_LOW);
	}

	public Iterator<IRCChannel> iterator() {
		return getChannelMap().values().iterator() ;
	}
	
    private void observe(final IRCInviteEvent event) {
    	for (final IRCInviteObserver observer : inviteObservers)
			try {
				observer.observeInvite(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
    	passEvent(event);
	}

	private void observe(final IRCJoinEvent event) {
    	for (final IRCJoinObserver observer : joinObservers)
			try {
				observer.observeJoin(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
    	passEvent(event);
	}
    
    private void observe(final IRCKickEvent event) {
    	for (final IRCKickObserver observer : kickObservers)
			try {
				observer.observeKick(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
    	passEvent(event);
	}
    
    private void observe(final IRCNickChangeEvent event) {
    	for (final IRCNickChangeObserver observer : nicknameObservers)
			try {
				observer.observeNicknameChange(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
    	passEvent(event);
	}
    
    private void observe(final IRCPartEvent event) {
    	for (final IRCPartObserver observer : partObservers)
			try {
				observer.observePart(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
    	passEvent(event);
	}
    
    private void observe(final IRCQuitEvent event) {
    	for (final IRCQuitObserver observer : quitObservers)
			try {
				observer.observeQuit(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
    	passEvent(event);
	}
    
    private void observe(final IRCRawEvent event) {
    	for (final IRCRawNumericObserver observer : rawObservers)
			try {
				observer.observeRaw(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
    	passEvent(event);
	}
    
    private void observe(final IRCTopicEvent event) {
    	for (final IRCTopicObserver observer : topicObservers)
			try {
				observer.observeTopicChange(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
    	passEvent(event);
	}
    
    public boolean onChannel(final String channel) {
		if (channel == null || channel.isEmpty())
			return false;
		return getChannelMap().containsKey(channel) ;
	}

	protected final void onConnect () 
	{
		this.lock.writeLock().lock() ;
		try
		{
			this.serverConfig = new IRCConfig(this);
			this.channelList = new TreeMap<String, IRCChannel>(new CasemappingASCII());
			this.internalAccessList = new TreeMap<String, IRCUser>(new CasemappingASCII());
			this.uptime = IRCUtils.time() ;
			this.readerThread = new Thread(new Reader(), "Reader Thread") ;
			this.readerThread.start();
			super.getConfig().resetReconnectCount();
			observe(new ConnectEvent(this));
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}

	protected void onConnectFail (Exception e)
	    throws ConnectionFailedException
	{    	
		this.setDisconnected(true) ;
	    this.setConnecting(false) ;
	    
	    super.lock.readLock().lock();
		try {
			if (this.remoteAddress == null)
	            throw new ConnectionFailedException("Failed to connect to server: "+e.getMessage()) ;
	        throw new ConnectionFailedException("Failed to connect to "+this.remoteAddress.getCanonicalHostName()+": "+e) ;
		} finally {
			super.lock.readLock().unlock();
		}        
	}

	protected void onDisconnect ()
	{		
		this.setDisconnected(true) ;
		this.setConnecting(false) ;
		this.setNick(null);
		// Removed channelList clear because onLogon we will
		// attempt to rejoin these channels
		//if (this.channelList != null)
		//	this.channelList.clear();
		// We use clear because it is more intensive to
		// remove, then rebuild constantly...
		if (this.internalAccessList != null)
			this.internalAccessList.clear();
		this.serverConfig = null;
		observe(new DisconnectEvent(this));
	}	

	protected void onError(Event event, String error) { }
	
	protected void onLogon(final LogonEvent event) {
		if (event == null)
			return ;
		
		this.lock.writeLock().lock();
		try {
			// Create a Copy for now
			final Collection<IRCChannel> channels = this.channelList.values();
			// clear the existing list
			this.channelList.clear();
			// attempt to rejoin all old channels
			final short maxTargets = getIRCConfig().getMaxTargets();
			final ArrayList<String> list = new ArrayList<String>(1);
			for (final IRCChannel channel : channels) {
				// since it has a key we have to join it seperately
				if (channel.hasKey()) {
					joinChannel(channel.getName(), channel.getKey(), event.getEncoding());
				} else {
					// add to a list that we will send as 
					//many joins at once if we can
					list.add(channel.getName());
				}
				if (list.size() >= maxTargets) {
					joinChannel(ArrayUtils.implode(",", list), event.getEncoding());
					list.clear();
				}
			}
			// join any remaining channels
			if (list.size() > 0) 
				joinChannel(ArrayUtils.implode(",", list), event.getEncoding());
			list.clear();			
		} finally {
			this.lock.writeLock().unlock();
		}
	}

	protected void onPing (Event event) 
	{
		this.lock.writeLock().lock() ;
		try {
			this.lastPing = IRCUtils.time() ;
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}

	protected void onPong () {		
		this.lock.writeLock().lock() ;
		try {
			this.lastPing = 0;
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}

	protected final void onRead () {
		this.lock.writeLock().lock() ;
		try {
			this.lastRead = IRCUtils.time() ;
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}

	protected final void onStart () {};

	protected final void onWrite () {
		this.lock.writeLock().lock() ;
		try {
			this.lastWrite = IRCUtils.time() ;
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}

	/**
	 * Parts a channel.
	 *
	 * @param channel The name of the channel to leave.
	 * @param encoding String encoding type. This is supplied by the IRCevent
	 *                 which triggered the calling of this method
	 * @throws IllegalArgumentException
	 */
	public final void partChannel (String channel, String encoding) 
		throws IllegalArgumentException
	{
		if (channel == null || channel.length() < 1)
			throw new IllegalArgumentException("Cannot part channel :: channel is null or length 0") ;
		
		if (! IRCChannel.validChannel.matcher(channel).matches())
			throw new IllegalArgumentException("Cannot part channel :: improperly formatted channel") ;
		
	    this.send("PART " + channel, encoding, PRIORITY_MEDIUM) ;
	}

	/**
	 * Parts a channel, giving a reason.
	 *
	 * @param channel The name of the channel to leave.
	 * @param reason The reason for parting the channel.
	 * @param encoding String encoding type. This is supplied by the IRCevent
	 *                 which triggered the calling of this method
	 * @throws IllegalArgumentException
	 */
	public final void partChannel (String channel, String reason, String encoding) 
		throws IllegalArgumentException
	{
		if (reason == null || reason.length() < 1)
			this.partChannel(channel, encoding) ;
		
	    this.partChannel(channel + " :" + reason, encoding) ;
	}

	private void process (final byte[] buffer, String raw, String encoding)
		throws ClosedLinkException, SocketTimeoutException
	{
		if (buffer == null || buffer.length == 0) 
			return ;		
		try {
			final IRCEvent event = new IRCEvent(raw, encoding, this) ;
	    	if (event.getType() == E_PING) {
	            this.send("PONG :"+event.getMessage(), event.getEncoding(), PRIORITY_EMERGENCY) ;
	            this.onPing(event) ;
	        } else if (event.getType() == E_PONG) {
	            this.lastPing = IRCUtils.time() ;
	            this.onPong() ;
	        } else if (event.getType() == E_ERROR) {                   
	            final String error = raw.substring(raw.indexOf(":", raw.indexOf(":")) + 1).trim() ;
	            this.onError(event, error) ;
	            throw new ClosedLinkException(error, encoding) ;
	        } else if (event.getType() == E_RAW) {
	        	processEvent(new IRCRawEvent(event)) ;
	        } else {	        	
	        	try {
	        		// We only want to add to the IAL on a Privmsg, CTCP, Action, or Notice
	        		if ((event.getUser() instanceof IRCUser) &&
	        				(event.getType() == E_PRIVMSG || event.getType() == E_NOTICE || 
	        				    event.getType() == E_ACTION || event.getType() ==  E_CTCP))		        	
		        		if (!ialContains(event.getUser().getProtocolAddress()))
		        			ialAdd(event.getUser()) ;	        			        			
	        	} finally {
	        		// verify we are on permenant channels
	        		if (this.isLoggedOn) {
	        			if ((IRCUtils.time() - this.lastCheck) > 60) {
	        				checkPermChannels(event);
	        				if (this.lastPing == 0) {
	        					send("PING activitycheck", event.getEncoding(), PRIORITY_HIGH);
		        				this.lastPing = IRCUtils.time();
	        				}	        				
	        			}
	        			if (this.lastPing != 0 && (IRCUtils.time() - this.lastPing) > 90) {
	        				throw new SocketTimeoutException("Connection to the server has failed :: Ping timeout ["+
	        					(IRCUtils.time() - this.lastPing)+"secs]") ;
	        			}
	        		}
	        		if (event.getType() == E_PRIVMSG || event.getType() == E_NOTICE || event.getType() == E_ACTION
	        				|| event.getType() == E_CTCP) {
	        			// explicit pass here
	        			// these are the most common events and will not get processed here
	        			// pass them to the module system and get out of dodge fast
	    				// System.out.println(event);
	        			if (!getIgnoreList().matches(event.getUser().getProtocolAddress()))
	        				passEvent(event) ;		            	
	        		} else if (event.getType() == E_JOIN) {
	            		IRCChannel channel = getChannelByName(event.getTarget()) ;
	            		if (channel == null)
	            			channel = new IRCChannel(event.getTarget(), this) ;
	            		processEvent(new IRCJoinEvent(event, channel)) ;
	            	} else if (event.getType() == E_NICK) {
	            		processEvent(new IRCNickChangeEvent(event)) ;
	            	} else if (event.getType() == E_PART) {
	            		final IRCChannel channel = getChannelByName(event.getTarget()) ;
	            		processEvent(new IRCPartEvent(event, channel)) ;
	            	} else if (event.getType() == E_KICK) {
	            		final IRCChannel channel = getChannelByName(event.getTarget()) ;
	            		processEvent(new IRCKickEvent(event, channel)) ;
	            	} else if (event.getType() == E_QUIT) {
	            		processEvent(new IRCQuitEvent(event)) ;
	            	} else if (event.getType() == E_INVITE) {
	            		IRCChannel channel = getChannelByName(event.getMessage()) ;
	            		if (channel == null)
	            			channel = new IRCChannel(event.getMessage(), this) ;
	            		processEvent(new IRCInviteEvent(event, channel));	            	
	            	} else if (event.getType() == E_MODE || event.getType() == E_USERMODE) {
	            		processEvent(new IRCModeEvent(event));
	            	} else if (event.getType() == E_TOPIC) {
	            		IRCChannel channel = getChannelByName(event.getTarget()) ;
	            		if (channel == null)
	            			channel = new IRCChannel(event.getTarget(), this) ;
	            		processEvent(new IRCTopicEvent(event, channel));
	            	} else {
	            		// pass event to the module queue - it is unhandled by the Connection
	            		// let modules handle it individually
	            		passEvent(event) ;
	            	}	        		
	        	} // finally
	        } // else
		}// try
		catch (final ClosedLinkException e) {
			throw e ;
		} catch (final SocketTimeoutException e) {
			throw e ;
		} catch (Exception e) {
			Logger.getLogger("org.vectra.connectionerror").log(Level.CONFIG, e.getMessage(), e) ;
		} finally {}
	}

	private void processEvent(final IRCInviteEvent event) {
		Logger.getLogger("org.vectra.connectionstatus").log(Level.CONFIG, "INVITE "+event.getChannel().getName(), new Object[] {event, event.getChannel()}) ;
		observe(event);
	}

	private void processEvent (final IRCJoinEvent event) 
		throws ChannelConflictException, IllegalArgumentException, UserConflictException
	{    	
		final boolean itsMe ;	
		this.lock.readLock().lock() ;
		try {
			itsMe = getConfig().areEquivalent(event.getUser().getNick(), this.me.getNick()) ;			
		} finally {
			this.lock.readLock().unlock() ;
		}
			
		if (itsMe) {
			addChannel(event.getChannel()) ;
			send("MODE "+event.getChannel().getName(), event.getEncoding()) ;
			send("WHO "+event.getChannel().getName(), event.getEncoding()) ;
			Logger.getLogger("org.vectra.connectionstatus").log(Level.CONFIG, "JOIN "+event.getChannel().getName(), new Object[] {event, event.getChannel()}) ;
		} else {
			if (event.getChannel() instanceof IRCChannel)
				event.getChannel().addUser((IRCChannelUser) event.getUser()) ;
		}  
		observe(event);
	}

	private void processEvent (final IRCKickEvent event)
		throws ChannelConflictException, UserConflictException
	{    	
		final boolean itsMe ;	
		
		final String kickedUser = event.getMessage().substring(0, event.getMessage().indexOf(' ')).trim();
		
		this.lock.readLock().lock() ;
		try {
			itsMe = getConfig().areEquivalent(kickedUser, this.me.getNick()) ;			
		} finally {
			this.lock.readLock().unlock() ;
		}
		
		if (itsMe) {
			removeChannel(event.getChannel().getName());
			Logger.getLogger("org.vectra.connectionstatus").log(Level.CONFIG, "KICK "+event.getChannel().getName(), new Object[] {event, event.getChannel()}) ;
		} else {
			event.getChannel().removeUser(event.getUser()) ;
			if (!userHasCommonChannels(event.getUser()))
				ialRemove(event.getUser().getProtocolAddress()) ;		
		} // else
		observe(event);
	}

	private void processEvent(final IRCModeEvent event) {
		final boolean itsMe ;	
		
		this.lock.readLock().lock() ;
		try {
			itsMe = getConfig().areEquivalent(event.getTarget(), this.me.getNick()) ;			
		} finally {
			this.lock.readLock().unlock() ;
		}
		
		if (itsMe) {
			this.lock.writeLock().lock();
			try {
				setModes(IRCUtils.changeModes(getModes(), event.getMessage()));
			} finally {
				this.lock.writeLock().unlock();
			}
		} else {
			final List<String> modeOffsets = StrUtils.split(event.getMessage(), ' ');
			final IRCChannel channel = getChannelByName(event.getTarget());		
			final List<String> parsedModes = getIRCConfig().processChannelModes(modeOffsets);
			
			for (final String mode : parsedModes) {
				if (getIRCConfig().getChannelStatusModes().indexOf(mode.charAt(1)) != -1) {
					final IRCChannelUser affected = channel.getUserByNick(mode.substring(3));
					if (affected != null) {
						affected.getLock().writeLock().lock();
						try {
							String channelModes = affected.getModes();
							if (mode.charAt(0) == '+') {
								// Adding a mode; some servers don't do redundancy
								// elimination so we must do so here
								if (channelModes.indexOf(mode.charAt(1)) == -1)
									channelModes += Character.toString(mode.charAt(1));
							} else if (mode.charAt(0) == '-') {
								channelModes = channelModes.replace(Character.toString(mode.charAt(1)), "");
							}
							affected.setModes(channelModes);
						} finally {
							affected.getLock().writeLock().unlock();
						}
					}
				} else if (mode.indexOf(' ') == -1 || StrUtils.split(getIRCConfig().channelModeCategories, ',').get(0).indexOf(mode.charAt(1)) == -1) {
					// This mode affects the channel as a whole and has either:
					// * no parameter;
					// * a parameter, but the mode is not a +beI-type mode.
					if (mode.charAt(0) == '+')
						channel.addMode(mode.substring(1));
					else if (mode.charAt(0) == '-')
						channel.removeMode(mode.charAt(1));
				}
			}
		} // else
	}

	private void processEvent (final IRCNickChangeEvent event) 
		throws UserConflictException
	{   	
		this.lock.writeLock().lock();
		try {
			if (getConfig().areEquivalent(event.getUser().getNick(), this.me.getNick())) {
	    		// We changed our nickname
	    		Logger.getLogger("org.vectra.connectionstatus").log(Level.CONFIG, getConfig().getConnID()+" :: Changed nickname from "+this.me.getNick()+" to "+event.getMessage()+".") ;
	    		this.me.setNick(event.getMessage());
	    	} 
			
			for (final IRCChannel channel : getChannelMap().values()) {
				channel.getLock().writeLock().lock();
				try {
					IRCUser toRename = null;
					try {
						toRename = channel.removeUser(event.getUser()) ;
					} catch (UserConflictException e) {}
					
					if (toRename != null) {
						toRename.getLock().writeLock().lock();
						try {
							toRename.setNick(event.getTarget()) ;
						} finally {
							toRename.getLock().writeLock().unlock();
						} 
						channel.addUser((IRCChannelUser) toRename) ;							
					}
				} finally {
					channel.getLock().writeLock().unlock();
				}
			}
			ialRemove(event.getUser().getProtocolAddress()) ;
			observe(new IRCNickChangeEvent(event));
		} finally {
			this.lock.writeLock().unlock();
		}
	}

	private void processEvent (final IRCPartEvent event)
		throws ChannelConflictException, UserConflictException
	{    	
		final boolean itsMe ;	
		
		this.lock.readLock().lock() ;
		try {
			itsMe = getConfig().areEquivalent(event.getUser().getNick(), this.me.getNick()) ;			
		} finally {
			this.lock.readLock().unlock() ;
		}
		
		if (itsMe) {
			removeChannel(event.getChannel().getName());
			Logger.getLogger("org.vectra.connectionstatus").log(Level.CONFIG, "PART "+event.getChannel().getName(), new Object[] {event, channel}) ;
		} else {
			event.getChannel().removeUser(event.getUser()) ;
			if (!userHasCommonChannels(event.getUser()))
				ialRemove(event.getUser().getProtocolAddress()) ;		
		} // else
		observe(event);
	}

	private void processEvent (final IRCQuitEvent event)
	{
		final List<IRCChannel> common = getCommonChannels(event.getUser()) ;
		if (common.size() == 0)
			ialRemove(event.getUser().getProtocolAddress()) ;
		
		for (final IRCChannel commonChannel : common)
		{
			try {
				final IRCChannel chan = getChannelByName(commonChannel.getName()) ;
				if (chan instanceof Named)
	    			chan.removeUser(event.getUser()) ; 
			} catch (UserConflictException e) {}    			
		} // for loop
		observe(event);
	}

	private void processEvent(final IRCRawEvent event) 
		throws IllegalArgumentException, UnknownUserException
	{
		final String[] rawArray = StrUtils.split(event.getMessage(), ' ').toArray(new String[] {}) ;		
		
		IRCChannel channel = null;
		
		switch (event.getNumeric())
		{
			case 1:
				// we need the last token
				final String me = rawArray[rawArray.length - 1].trim();
				this.me = new IRCUser(me, this);
			break;
			case 4: // network handshake
				// set our nickname, as seen by the server
				this.me.setNick(event.getTarget()) ;
				// set the official server name
				// this isn't necesarily the same as the hostname
				getIRCConfig().serverName = rawArray[0].trim() ;
				// save the supported usermodes of the server
				getIRCConfig().supportedUserModes = rawArray[2].trim() ;
				// save the supported channel modes of the server
				getIRCConfig().supportedChannelModes = rawArray[3].trim() ;
				break;
			case 5:
				final ArrayList<Pair<String, String>> list = IRCUtils.parseToPair(event.getMessage()) ;
				for (final Pair<String, String> setting : list)
				{
					if (setting.getKey().equals("AWAYLEN"))
						getIRCConfig().maxAwayLength = Short.parseShort(setting.getValue());
					else if (setting.getKey().equals("CASEMAPPING"))
						getIRCConfig().caseMapping = setting.getValue();
					else if (setting.getKey().equals("CHANNELLEN"))
						getIRCConfig().maxChannelLength = Short.parseShort(setting.getValue());
					else if (setting.getKey().equals("CHANMODES"))
						getIRCConfig().channelModeCategories = setting.getValue();
					else if (setting.getKey().equals("CHANTYPES"))
						getIRCConfig().channelPrefixes = setting.getValue();
					else if (setting.getKey().equals("KICKLEN"))
						getIRCConfig().maxKickLength = Short.parseShort(setting.getValue());
					else if (setting.getKey().equals("MAXCHANNELS"))
						getIRCConfig().channelLimit = Short.parseShort(setting.getValue());
					else if (setting.getKey().equals("MAXTARGETS")) 
						getIRCConfig().maxTargets = Short.parseShort(setting.getValue());	
					else if (setting.getKey().equals("MAXLIST")) {
						final String[] limitTokens = setting.getValue().split(",");
						for (final String limitToken : limitTokens) {
							if (limitToken.startsWith("b:"))
								getIRCConfig().banListLength = Short.parseShort(limitToken.substring(2));
							else if (limitToken.startsWith("e:"))
								getIRCConfig().banExemptionListLength = Short.parseShort(limitToken.substring(2));
							else if (limitToken.startsWith("I:"))
								getIRCConfig().inviteListLength = Short.parseShort(limitToken.substring(2));
						}
					} else if (setting.getKey().equals("MODES"))
						getIRCConfig().modesPerLine = Byte.parseByte(setting.getValue());
					else if (setting.getKey().equals("NAMESX"))
						send("PROTOCTL NAMESX", event.getEncoding());
					else if (setting.getKey().equals("NETWORK"))
						getIRCConfig().network = setting.getValue();
					else if (setting.getKey().equals("NICKLEN"))
						getIRCConfig().maxNicknameLength = Short.parseShort(setting.getValue());
					else if (setting.getKey().equals("PREFIX"))
						getIRCConfig().modePrefixes = new String(setting.getValue());					
					else if (setting.getKey().equals("TOPICLEN"))
						getIRCConfig().maxTopicLength = Short.parseShort(setting.getValue());					
					else if (setting.getKey().equals("UHNAMES")) {
						getIRCConfig().uNamesSupported = true;
						send("PROTOCTL UHNAMES", event.getEncoding());
					}			
				}
				break;
			case 376: // End of MOTD
			case 422: // End of MOTD - File not found
				if (!isDisconnected()) {
					send("MODE "+this.me.getNick(), event.getEncoding());
					this.isLoggedOn = true;
					observe(new LogonEvent(IRCConnection.this, event.getEncoding())) ;
				}
				break;
			case 221: 
				// My modes
				// In response to request during RAW 422
				setModes(rawArray[1]) ;
				break;
			case 324:
				// Channel modes
				channel = getChannelByName(rawArray[0].trim()) ;
				if (channel != null) 
					channel.setModes(rawArray[1].trim());				
				break;
			case 329:
				// Channel creation date
				channel = getChannelByName(rawArray[0].trim()) ;
				if (channel != null) {
					try {
						final long time = Long.parseLong(rawArray[1].trim());
						channel.setChannelAge(new Date(time * 1000));
					} catch (final Exception e) {
						channel.setChannelAge(new Date(System.currentTimeMillis()));
					}
				}
				break;
			case 332:
				// Topic
				String topic = event.getMessage().substring(event.getMessage().indexOf(' ')).trim() ;
				channel = getChannelByName(rawArray[0].trim()) ;
				if (channel != null) {
					if (topic.startsWith(":"))
						topic = topic.substring(1).trim();
					channel.setTopic(topic);					
				}										
				break;
			case 333:
				// Topic Setter details
				channel = getChannelByName(rawArray[0].trim()) ;
				if (channel != null) 					
					try {
						channel.setTopicSetter(rawArray[1].trim());						
						final long time = Long.parseLong(rawArray[2].trim());
						channel.setTopicDate(new Date(time * 1000));
					} catch (final Exception e) {
						channel.setTopicDate(new Date(System.currentTimeMillis()));
					}
				break;
			case 315:
				// End of /WHO
				break;
			case 352:
				// /WHO response
				final String host = rawArray[4]+"!"+rawArray[1].trim()+"@"+rawArray[2].trim();
				channel = getChannelByName(rawArray[0].trim()) ;				
							
				if (channel != null)
					try {
						final String channelModes = getIRCConfig().parseChannelStatusModes(rawArray[5]);
						// System.out.println(rawArray[5]+"="+channelModes);
						channel.addUser(new IRCChannelUser(host, channelModes, channel)) ;
					} catch (UserConflictException e) {
						
					} catch (UnknownUserException e) {
						
					}
				break;
			default:
				System.out.println(event);
				break;
		}
		observe(event);
	}

	private void processEvent(final IRCTopicEvent event) {
		final IRCChannel channel = event.getChannel();
		try {
			// set the new topic
			channel.setTopic(event.getMessage(), event.getUser().getNick()); 
		} catch (final Exception e) {} 
		finally {    		
	    	observe(event);
		}
	}

	/**
	 * Quits from the IRC server.
	 * Providing we are actually connected to an IRC server, the
	 * onDisconnect() method will be called as soon as the IRC server
	 * disconnects us.
	 * 
	 * @param encoding String encoding type. This is supplied by the IRCevent
	 *                 which triggered the calling of this method
	 * @throws IllegalArgumentException
	 */
	public final void quitServer (String encoding) 
		throws IllegalArgumentException
	{
	    this.quitServer("", encoding);
	}

	/**
	 * Quits from the IRC server with a reason.
	 * Providing we are actually connected to an IRC server, the
	 * onDisconnect() method will be called as soon as the IRC server
	 * disconnects us.
	 *
	 * @param reason The reason for quitting the server.
	 * @param encoding String encoding type. This is supplied by the IRCevent
	 *                 which triggered the calling of this method
	 * @throws IllegalArgumentException
	 */
	public final void quitServer(String reason, String encoding) 
	    throws IllegalArgumentException
	{
		if (reason == null)
			throw new IllegalArgumentException("Cannot quit server :: reason supplied is null") ;
		
	    this.send("QUIT :" + reason.trim(), encoding, PRIORITY_EMERGENCY);
	}

	public final int read (final byte[] buffer, int start, int stop)
	{    	
	    try
	    {              
	        //super.lock.writeLock().lock();
	        try {
	        	return this.socket_read(buffer, start, stop) ;
	        } catch (IOException e) {
	        	throw e ;
	        } catch (Exception e) {
	        }// finally {
	        //	super.lock.writeLock().unlock();
	       // }
	    } catch (Exception e) {
	    	Logger.getLogger("org.vectra.connectionerror").log(Level.WARNING, e.getMessage(), e) ;
	        this.close() ;
	        this.onDisconnect() ;
	    } finally {
	    	if (!this.isDisconnected())
	    		this.onRead() ;
	    }
	    return 0 ;
	}
	
	private void removeChannel (final String channel) 
    	throws ChannelConflictException 
    {
    	this.lock.writeLock().lock();
    	try {
    		if (!getChannelMap().containsKey(channel))
    			throw new ChannelConflictException("Channel "+channel+" does not exist in the internal list");
    		getChannelMap().remove(channel) ;
    	} finally {
    		this.lock.writeLock().unlock();
    	}
    }

	public final void send (String str)
    	throws IllegalArgumentException
    {
    	this.send (str, "UTF-8", PRIORITY_NORMAL) ;
    }
    
    public final void send (String str, String encoding)
    	throws IllegalArgumentException
    {
    	this.send (str, encoding, PRIORITY_NORMAL) ;
    }
    
    public final void send (String str, final byte priority)
    	throws IllegalArgumentException
    {
    	this.send (str, "UTF-8", priority) ;
    }
    
    public final void send (String message, String encoding, final byte priority)
    	throws IllegalArgumentException
    {
    	if (message == null || message.length() < 5)
    		throw new IllegalArgumentException("Message cannot be null or length zero");
    	if (message.indexOf('\0') >= 0 || message.indexOf('\r') >= 0 || message.indexOf('\n') >= 0)
			throw new IllegalArgumentException("message contains characters unsupported on IRC: " + message);
    	if (isDisconnected())
			throw new IllegalStateException();
    	
		this.messageQueue.offer(new IRCMessage (message, encoding, priority, this)) ; 	
    }
	
	public final void setConfig (final IRCBotConfig config) {
		this.lock.writeLock().lock();
		try {
			this.config = config ;
			super.setConfig((BotConfig)config);
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}
	
	public final void setModes (final String modes) {
		this.lock.writeLock().lock();
		try {
			this.modes = modes.trim();
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}
	
	private void setNick(final String nickname) {
		this.lock.writeLock().lock();
		try {
			if (this.me == null)
				throw new IllegalStateException("not connected or have not reached RAW 001");
			this.me.setNick(nickname);
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}
	
	public void setIgnoreList(final IRCIgnoreList ignoreList) {
		if (ignoreList == null)
			throw new IllegalArgumentException("IgnoreList reference cannot be null");
		this.lock.writeLock().lock();
		try {
			this.ignoreList = ignoreList ;
		} finally {
			this.lock.writeLock().unlock() ;
		}		
	}

	public String toString ()
	{
		return "[IRCConnection ("+getConfig().getConnID()+") :: "+this.me.getNick()+
				" :: Modes: none :: Channels: "+getChannelCount()+" :: IAL: "+getIAL().size()+"]" ;
	}

	public boolean userHasCommonChannels (final IRCUser user) 
		throws IllegalArgumentException
	{
		return userHasCommonChannels(user.getProtocolAddress());
	}

	public boolean userHasCommonChannels (final String user)
		throws IllegalArgumentException 
	{
		for (final IRCChannel channel : getChannelMap().values())
			if (channel.userIsOnChannel(user))
				return true ;
		return false;
	}

	public final void write (final Message message)
		throws IllegalArgumentException, IllegalStateException, NullPointerException
	{ }

	private final transient CopyOnWriteArrayList<IRCInviteObserver> inviteObservers = new CopyOnWriteArrayList<IRCInviteObserver>();

	private final transient CopyOnWriteArrayList<IRCJoinObserver> joinObservers = new CopyOnWriteArrayList<IRCJoinObserver>();

	private final transient CopyOnWriteArrayList<IRCKickObserver> kickObservers = new CopyOnWriteArrayList<IRCKickObserver>();

	private final transient CopyOnWriteArrayList<IRCNickChangeObserver> nicknameObservers = new CopyOnWriteArrayList<IRCNickChangeObserver>();

	private final transient CopyOnWriteArrayList<IRCPartObserver> partObservers = new CopyOnWriteArrayList<IRCPartObserver>();

	private final transient CopyOnWriteArrayList<IRCQuitObserver> quitObservers = new CopyOnWriteArrayList<IRCQuitObserver>();

	private final transient CopyOnWriteArrayList<IRCRawNumericObserver> rawObservers = new CopyOnWriteArrayList<IRCRawNumericObserver>();

	private final transient CopyOnWriteArrayList<IRCTopicObserver> topicObservers = new CopyOnWriteArrayList<IRCTopicObserver>();

	private final class Reader 
		implements IRCEvents, Runnable
	{
		public Thread writer = null ;
	
		public void run ()
		{
			try
			{	
				if (writer == null) {
					writer = new Thread(new Writer(), "Writer thread") ;
					writer.start();
					isLoggedOn = false;
				}
				try
				{ 				
					send("NICK "+config.getNick(), PRIORITY_EMERGENCY) ;
					send("USER "+config.getIdent()+" 0 * :"+config.getRealName(), PRIORITY_EMERGENCY) ;
	                
	                final CharsetDecoder utf8 = Charset.forName("UTF-8").newDecoder();
					final CharsetDecoder iso88591 = Charset.forName("ISO-8859-1").newDecoder();
	
					final CharBuffer cb = CharBuffer.allocate(BUFFER_LEN);
	                
	                final byte[] buffer = new byte[BUFFER_LEN] ;
	                // String raw ;
	                int read, count = 0, nextSearch = 0 ;
	                
	                // wait until we read a complete line from the reader
	                boolean completeLine = false ;	                
	                
	 				while ((read = read(buffer, count, BUFFER_LEN - count)) > 0) 
					{
	 					// count the current bytes read
	 					count += read ;
	 					// find the newline character
	 					int newLine = bfind(buffer, nextSearch, count, NEW_LINE) ;
	 					// only proceed into the loop if the NEW_LINE char exists
	 					// inside the buffer
	 					while (newLine > 0)
	 					{
	 						// Complete line will only be true when we have to 
	 						// handle ignored data
	 						if (completeLine)
	 						{
	 							// use try catch to ensure that no errors during 
	 							// processing are found
	 							try
	 							{
	 								final byte[] data = new byte[newLine + 1] ;
	 								System.arraycopy(buffer, 0, data, 0, data.length) ;
	 								// TODO add in features for ignored data handling
	 							}
	 							catch (ArrayStoreException e) {}
	 							catch (IndexOutOfBoundsException e) {}
	 							catch (NullPointerException e) {}
	 							// using try/finally ensures that even if there is an
	 							// error during processing - we continue to handle data
	 							// properly after this point
	 							finally { completeLine = false ; }
	 						}
	 						else
	 						{
	 							final byte[] rawLine = new byte[newLine + 1];
								System.arraycopy(buffer, 0, rawLine, 0, rawLine.length) ;
								// the line still contains the \r
								int lineLength = newLine ;
								if (lineLength > 0 && buffer[lineLength - 1] == LINE_FEED)
									lineLength-- ;
								// index contains the length of the line we will actually 
								// process. if the buffer[index-1] == LINE_FEED the \r
								// will be removed by further manipulating the byte array
								
								// Credit to Looce/Cynthia at RuneScript for the ByteBuffer
								// and decoding idea
								final ByteBuffer bb = ByteBuffer.wrap(buffer, 0, lineLength) ;
								String line = decode(bb, cb, utf8), encoding;
								if (line == null) 
								{
									line = decode(bb, cb, iso88591);
									encoding = "ISO-8859-1";
								} 
								else
								{
									encoding = "UTF-8";
								}
								
								// pass the line to the event processor
								process (buffer, line, encoding) ;
	 						}
	 						
	 						System.arraycopy(buffer, newLine + 1, buffer, 0, count - newLine - 1);
							count -= newLine + 1;
							nextSearch = 0;
							// Continue the loop
							// look for the new line again
							newLine = bfind(buffer, nextSearch, count, NEW_LINE);
	 					} // while (newLine != -1)
	 					
	 					// if the \n is not in the recieved bytes
	 					if (newLine == -1) 
	     				{
	 						// if the current number of read bytes is equal to
	 						// buff_len but no NEW_LINE was found - Ignore the 
	 						// buffer and keep reading
							if (count == BUFFER_LEN) 
							{
								// tell the system we have a full buffer
								completeLine = true;
								// reset to count to zero to read
								// more bytes
								count = 0;
							} 
							else 
								// no new line was found yet
								// keep reading into the buffer until we find the 
								// new line or exceed the buffer maximum
								nextSearch = count;
						}
	 					
					} // while ((read = read(buffer, count, BUFFER_LEN - count)) > 0) 				
					// once we get here the reader will kill itself and the thread(s) it holds
				} catch (ClosedLinkException e) {
		        	throw e;	        	
		        } catch (SocketTimeoutException e) {
		        	throw e;	
		        } catch (Exception e) { 
		        	throw e;		        	
		        } finally {
					if (writer != null)
						writer.interrupt() ;
					writer = null ;
				}
			}
	        catch (ClosedLinkException e) {
	        	Logger.getLogger("org.vectra.connectionerror").log(Level.WARNING, e.getMessage(), e) ;	        	
	        } catch (SocketTimeoutException e) {
	        	Logger.getLogger("org.vectra.connectionerror").log(Level.WARNING, e.getMessage(), e) ;
	        } catch (Exception e) { 
	        	Logger.getLogger("org.vectra.connectionerror").log(Level.INFO, e.getMessage(), e) ;	        	
	        } finally {
				try {
					// if we catch a ClosedLinkException we need to close
	    			// the writer and null it
	    			if (writer != null)
						writer.interrupt() ;
					writer = null ;
	    			// Proceed to shut down the socket here
	    			if (IRCConnection.this != null) {
	    				IRCConnection.this.close() ;
	    			}
	    			// CLose the reader thread
	    			Thread.currentThread().interrupt() ;
	    			IRCConnection.this.readerThread = null;
				} catch (NullPointerException e) {
					// ignore here
				}
			}
			Logger.getLogger("org.vectra.connectionerror").log(Level.CONFIG, "Reader for "+getConfig().getConnID()+" has stopped.") ;
		}
		
		private int bfind (final byte[] data, final int start, final int end, final byte search) 
		{
			for (int i = start; i < end; i++)
				if (data[i] == search)
					return i;
			return -1;
		}
		
		// method by Looce/Cynthia of RuneScript
		private String decode(final ByteBuffer bb, final CharBuffer cb, final CharsetDecoder cd) 
		{
			bb.rewind();
			cb.limit(cb.capacity());
			cb.rewind();
			cd.reset();
			final CoderResult cr = cd.decode(bb, cb, true);
			if (cr.isError())
				return null;
			return cb.flip().toString();
		}
	}

	private final class Writer
		implements Runnable 
	{
		public void run ()
		{    		
			try
			{
				final OutputStream output = socket.getOutputStream() ;
				while (true) 
				{	
					final IRCMessage message = (IRCMessage) messageQueue.take() ;
					// TODO flood controller						
					try
			        {  						
						final byte[] buffer = message.getBuffer();
		            	output.write(buffer) ;
		            	// send LINE_FEED
		            	output.write((byte)'\r');
		            	// send NEW_LINE
		            	output.write((byte)'\n');
		            	// Flush the output stream
		            	output.flush();
		            	// attempt to call onWrite
		            	onWrite() ;
			        } catch (IOException e) {
		            	Logger.getLogger("org.vectra.connectionerror").log(Level.INFO, e.getMessage(), e) ; 
			            close() ; 
			            onDisconnect() ;
			        } catch (Exception e) { 
			        	System.out.println(e) ;
			        	Logger.getLogger("org.vectra.connectionerror").log(Level.INFO, e.getMessage(), e) ;
			        } finally {
			        	//if (! isDisconnected()) 
			        	//	onWrite() ;			        	
			        }     
				} 
			} catch (final IOException e) {
				//ignore 
			} catch (final IllegalStateException ise) {
				// ignore
			} catch (final NullPointerException npe) {
				// ignore
			} catch (final InterruptedException ie) {
				// ignore
			} // try
		} // public void run ()    	
	}		
}