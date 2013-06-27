package org.vectra;

import java.io.InputStream ;
import java.io.OutputStream ;
import java.io.IOException ;
import java.net.Inet6Address;
import java.net.Socket ;
import java.net.InetAddress ;
import java.net.InetSocketAddress ;
import java.net.SocketException ;
import java.nio.channels.SocketChannel ;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import net.phantomnet.events.ConnectEvent;
import net.phantomnet.events.DisconnectEvent;
import net.phantomnet.events.ExceptionEvent;
import net.phantomnet.events.LogonEvent;
import net.phantomnet.nio.InetHandler;
import net.phantomnet.observer.ConnectionObserver;
import net.phantomnet.observer.DisconnectObserver;
import net.phantomnet.observer.ExceptionObserver;
import net.phantomnet.observer.LogonObserver;

import org.vectra.Event;
import org.vectra.EventQueue;
import org.vectra.exceptions.ConnectionFailedException;

public abstract class Connection {
	/**
	 * IRC max buffer length is 512 bytes of input per single line
	 */
	public static final int BUFFER_LEN = 512 ;
	
	/**
	 * Byte representation of a new line (\n) character for use in the
	 * Reader and writer classes that are self-contained.
	 */
	public static final byte NEW_LINE = (byte) '\n' ;
	
	/**
	 * Byte representation of the line feed (\r) character for use in 
	 * the Reader and Writer classes self-contained in this Connection.
	 */
	public static final byte LINE_FEED = (byte) '\r' ;
	
	/**
	 * This class wraps around the actual Java Socket API
	 * While this class is used to control the higher level controls for 
	 * IRC, the Java socket API provides all connections to an external 
	 * server.
	 */
    protected Socket socket ;
    
    /**
     * Socket channel for the Java Socket API that is contained in this
     * class.
     */
    protected SocketChannel channel ;
    
    /**
     * String representation of the IP address used to bind sockets to.
     * Once set this will persist throughout the existance of this object.
     */
    protected final String bindAddress ;
    
    /**
     * InetAddress of the current socket object's bind values.
     * This represents the Local InetAddress object from the passed socket
     * or the created socket through this class.
     */
    protected InetAddress localAddress ;
    
    /**
     * InetAddress of the current socket object's connection values.
     * This represents the Remote InetAddress object from the passed socket
     * or the created socket through this class's connect() method.
     */
    protected InetAddress remoteAddress ;
    
    /**
     * Output stream of the current socket
     * Any attempts to use this object without first calling the connect()
     * method will result in IllegalStateException's being thrown.
     */
    protected OutputStream output ;   
    
    /**
     * Input stream of the current socket
     * Any attempts to use this object without first calling the connect()
     * method will result in IllegalStateException's being thrown.
     */
    protected InputStream input ;
    
    /**
     * BotConfig for this bot
     * A BotConfig is persistant between all connections and is saved globally.
     */
    protected BotConfig config ;
    
    protected final PriorityBlockingQueue<Message> messageQueue = new PriorityBlockingQueue<Message>() ;
    
    protected boolean isConnecting ;
    protected boolean isDisconnected ;
    protected boolean reconnect ;
    protected final int bindPort ;
    protected int uptime ;
    protected int lastPing;
    protected int lastRead ;
    protected int lastWrite ;
    protected short reconnectCount;
    
    protected transient final ReadWriteLock lock = new ReentrantReadWriteLock(true);
  
    public Connection ()
        throws IOException, SocketException
    {
    	this("", 0) ;
    }
    
    public Connection (final String bindAddress, final int bindPort) 
        throws IOException, SocketException, IllegalArgumentException
    {
    	if (bindAddress == null)
        	throw new IllegalArgumentException("Supplied bindAddress is null") ;
        
        this.bindAddress = bindAddress.trim() ;
        this.bindPort = bindPort ;        
    }
    
    public Connection (final Socket socket)
        throws IOException, SocketException
    {
        this.socket = socket ;
        
        if (!socket.isBound())
           this.setReuseAddress(true) ;
        
        this.bindAddress = this.socket.getLocalAddress().getHostAddress() ;
        this.bindPort    = this.socket.getLocalPort() ;
        this.localAddress = this.socket.getLocalAddress() ;
        
        this.channel = socket.getChannel() ;
        
        this.input = this.socket.getInputStream() ;
        this.output = this.socket.getOutputStream() ;
    } 
    
    public abstract void close() ;

	public abstract void connect (String remoteAddress, int remotePort) throws ConnectionFailedException ;

	public BotConfig getConfig ()
	{
	    this.lock.readLock().lock() ;
	    try {
	        return this.config ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public final String getHostname ()
	{
	    this.lock.readLock().lock() ;
	    try {
	        if (this.socket == null)
	            return null ;
	        return this.socket.getInetAddress().getHostName() ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public final InputStream getInputStream ()
		throws IllegalStateException
	{
		this.lock.readLock().lock() ;
	    try {
	        if (this.socket == null || !this.socket.isConnected())
	            throw new IllegalStateException("Socket is not connected") ;
	        return this.input;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public final int getLastPing ()
	{
		this.lock.readLock().lock();
		try {
			return this.lastPing ;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public final int getLastRead ()
	{
		return this.getLastRead (false) ;
	}

	public final int getLastRead (boolean duration)
	{
		this.lock.readLock().lock();
		try {
			// before a safe connect is initiated lastRead is set to 0
			if (this.lastRead == 0)
				return 0 ;
			// return the actual duration in seconds
			if (duration)
				return time() - this.lastRead ;
			// return unix style timestamp
			return this.lastRead ;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public final int getLastWrite ()
	{
		return this.getLastRead (false) ;
	}

	public final int getLastWrite (boolean duration)
	{
		this.lock.readLock().lock();
		try 
		{
			// before a safe connect is initiated lastWrite is set to 0
			if (this.lastWrite == 0)
				return 0 ;
			// return the actual duration in seconds
			if (duration)
				return time() - this.lastWrite ;
			// return unix style timestamp 
			return this.lastWrite ;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public final int getLocalPort ()
	{	    
	    this.lock.readLock().lock() ;
	    try {
	        if (this.socket == null)
	            return 0 ;
	        return this.socket.getLocalPort() ;         
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public final OutputStream getOutputStream ()
		throws IllegalStateException
	{
		this.lock.readLock().lock() ;
	    try {
	        if (this.socket == null || !this.socket.isConnected())
	            throw new IllegalStateException("Socket is not connected") ;
	        return this.output;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public final int getPort ()
	{
	    this.lock.readLock().lock() ;
	    try {
	        if (this.socket == null)
	            return 0 ;
	        return this.socket.getPort() ;
	    } finally {
	            this.lock.readLock().unlock();
	    }
	}

	public final boolean getReconnectStatus ()
	{
		this.lock.readLock().lock();
		try {
			return this.reconnect ;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public final int getUptime ()
	{
		return this.getUptime(false) ;
	}

	public final int getUptime (boolean duration)
	{
		this.lock.readLock().lock();
		try 
		{
			// before a safe connect is initiated uptime is set to 0
			if (this.uptime == 0)
				return 0 ;
			// return the actual duration in seconds of actual uptime
			if (duration)
				return time() - this.uptime ;
			// return unix style timestamp of when this socket connected
			return this.uptime ;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public final boolean isBound ()
	{        
	    this.lock.readLock().lock() ;
	    try {
	        if (this.socket == null)
	            return false ;
	        return this.socket.isBound() ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public final boolean isClosed ()
	{
	    this.lock.readLock().lock() ;
	    try {
	        if (this.socket == null)
	            return false ;
	        return this.socket.isClosed() ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public boolean isConnected ()
	{
	    this.lock.readLock().lock() ;
	    try {
	        if (this.socket == null)
	            return false ;
	        return this.socket.isConnected() ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public final boolean isConnecting ()
	{
		this.lock.readLock().lock();
		try {
			return this.isConnecting ;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public final boolean isDisconnected ()
	{        
		this.lock.readLock().lock();
		try {
			return this.isDisconnected ;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public final boolean isInputClosed ()
	{
	    this.lock.readLock().lock() ;
	    try {
	        if (this.socket == null)
	            return false ;
	        return this.socket.isInputShutdown() ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public final boolean isOutputClosed ()
	{
	    this.lock.readLock().lock() ;
	    try {
	        if (this.socket == null)
	            return false ;
	        return this.socket.isOutputShutdown() ;
	    } finally {
	        this.lock.readLock().unlock();
	    }
	}

	public void linkConnectionObserver(final ConnectionObserver observer) {
		connectionObservers.add(observer);
	}

	public void linkDisconnectObserver(final DisconnectObserver observer) {
		disconnectObservers.add(observer);
	}

	public void linkExceptionObserver(final ExceptionObserver observer) {
		exceptionObservers.add(observer);
	}

	public void linkLogonObserver(final LogonObserver observer) {
		logonObservers.add(observer);
	}

	protected abstract void onConnectFail (Exception e) throws ConnectionFailedException ;
    protected abstract void onDisconnect () ;
    protected abstract void onError(Event event, String error) ;
    protected abstract void onLogon(LogonEvent event);
    protected abstract void onPing(Event event) ;
    protected abstract void onPong() ;
    protected abstract void onStart() ;
    protected abstract void onRead () ;    
    protected abstract void onConnect () ;
    protected abstract void onWrite () ; 
    
    private final transient CopyOnWriteArrayList<ConnectionObserver> connectionObservers = new CopyOnWriteArrayList<ConnectionObserver>();
    
    protected void observe(final ConnectEvent event) {
    	for (final ConnectionObserver observer : connectionObservers)
			try {
				observer.observeConnection(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
    	passEvent(event);
	}
    
    private final transient CopyOnWriteArrayList<DisconnectObserver> disconnectObservers = new CopyOnWriteArrayList<DisconnectObserver>();

	
	protected void observe(final DisconnectEvent event) {
		for (final DisconnectObserver observer : disconnectObservers)
			try {
				observer.observeDisconnect(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
		passEvent(event);
	}
	
	protected void observe (final Event event) {};
	
	private final transient CopyOnWriteArrayList<ExceptionObserver> exceptionObservers = new CopyOnWriteArrayList<ExceptionObserver>();
	
	protected void observe(final ExceptionEvent event) {
		for (final ExceptionObserver observer : exceptionObservers)
			observer.observeException(event);			
	}
	
	private final transient CopyOnWriteArrayList<LogonObserver> logonObservers = new CopyOnWriteArrayList<LogonObserver>();
	
	protected void observe(final LogonEvent event) {
		for (final LogonObserver observer : logonObservers)
			try {
				observer.observeLogon(event);
			} catch (final Exception e) {
				observe(new ExceptionEvent(this, e));
			}
		passEvent(event);
	}

	public final void passEvent (final Event event)
	{
		try {
			EventQueue.addEvent(event) ;
		} catch (InterruptedException e) {
			// ignore
		}
	}

	public abstract int read (final byte[] buffer, int offset, int length) ;

	public final void setReuseAddress (boolean bool)
	    throws IOException
	{        
	    this.lock.writeLock().lock();
	    try {
	         if (this.socket != null)
	            this.socket.setReuseAddress(bool) ;
	    } finally {
	         this.lock.writeLock().unlock();
	    }
	}

	public final void setKeepAlive (boolean bool)
	    throws IOException
	{
	    this.lock.writeLock().lock();
	    try {
	        if (this.socket != null)
	            this.socket.setKeepAlive(bool) ;
	    } finally {
	        this.lock.writeLock().unlock();
	    }
	}

	public final void setConfig (BotConfig config)
	{
		this.lock.writeLock().lock();
		try {
			this.config = config ;
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}

	public final void setConnecting (boolean status)
	{
		this.lock.writeLock().lock() ;
		try {
	    	this.isConnecting = status ;
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}

	public final void setDisconnected (boolean status)
	{
		this.lock.writeLock().lock() ;
		try {
			this.isDisconnected = status ;
			if (!status)
				this.isConnecting = false;
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}

	public final void setReconnectStatus (boolean status)
	{
		this.lock.writeLock().lock() ;
		try {
	    	this.reconnect = status ;
		} finally {
			this.lock.writeLock().unlock() ;
		}
	}

	public synchronized void socket_bind (final String address, final int port)
	    throws IOException
	{
		System.out.printf("socket_bind(%s, %d)\n", address, port);
	    this.socket.bind(new InetSocketAddress(address, port)) ;
	}

	public synchronized void socket_connect (final String remoteAddress, final int remotePort) 
		throws IllegalStateException, IOException
	{       
	    if (this.socket != null && this.socket.isConnected())
	    	throw new IllegalStateException("Unable to create new socket. Operation currently in progress") ;	    
	    // Create a new socket object
	    //this.socket = new Socket() ;
	    // bind the socket to the supplied local info
	    //if (getConfig().getBindAddress().length() > 0)
	    //	this.socket_bind(getConfig().getBindAddress(), 0) ;
	    // Create a new InetSocketAddress 
    
	    // handle binding (Fix in place for IPv6 addresses)
	    if (getConfig().getBindAddress().length() > 0) {
	    	final InetSocketAddress localAddr = new InetSocketAddress(getConfig().getBindAddress(), 0);	    	
	    	final boolean ipv6 = localAddr.getAddress() instanceof Inet6Address ? true : false;
	    	// The remote interface
	    	final InetAddress remoteInetAddr = InetHandler.getInetAddress(remoteAddress, ipv6); 	    	
		    // if this triggers - DNS lookup failed to work
		    if (remoteInetAddr == null) {}    	
		    System.out.println("Chosen address: "+remoteInetAddr);
		    InetSocketAddress remoteAddr = new InetSocketAddress(remoteInetAddr, getConfig().getPort()) ;        
		    // save the remote InetSocketAddress
		    this.remoteAddress = remoteAddr.getAddress() ;
		    System.out.println("Connecting to "+remoteAddr.getAddress().getHostAddress()+":"+remoteAddr.getPort()+
	    			" via ("+localAddr.getAddress().getHostAddress()+")");
	    	this.socket = new Socket(remoteAddr.getAddress(), remoteAddr.getPort(), localAddr.getAddress(), localAddr.getPort()) ;
	    } else {
	    	InetSocketAddress remoteAddr = new InetSocketAddress(remoteAddress, getConfig().getPort()) ; 
	    	this.socket = new Socket(remoteAddr.getAddress(), remoteAddr.getPort()) ;
	    }
	    // System.out.printf("socket_connect(%s, %d)\n", remoteAddress, remotePort);	   
	    // connect the socket
	    //this.socket.connect(remoteAddr) ;
	    // save the output stream
	    this.output = this.socket.getOutputStream() ;
	    // save the input stream
	    this.input = this.socket.getInputStream() ;
	    // we are no longer disconnected - state is now set at isConnecting
	    setDisconnected(false);
	    // we're in the connection process
		setConnecting(true);
		// clean the message queue
		this.messageQueue.clear();
	}

	public synchronized final void socket_close ()
	{
	    try {
	        this.input.close() ;
	        this.output.close() ;
	        this.socket.close() ;
	    } catch (IOException e) {
	    	// ignore
	    } finally {
	    	setDisconnected(true);
	    	setConnecting(false);
	    }
	}

	public final void socket_write (final byte[] buffer)
	    throws IOException
	{
	    if (this.output == null)
	        this.output = this.socket.getOutputStream() ;
	    
	    if (!this.isConnected())
	        throw new IOException("write() called on an inactive socket.") ;
	    
	    if (this.isOutputClosed())
	        throw new IOException("write() called but the output buffer is closed.") ;
	    
	    if (buffer.length == 0)
	        throw new IOException("write() called howeveer the output buffer length is 0.") ;
	    
	    this.output.write(buffer) ;
	}

	public final int socket_read (byte[] buffer, int offset, int length)
	    throws IOException
	{
	    if (this.input == null)
	        this.input = this.socket.getInputStream() ;
	    
	    if (!this.isConnected())
	        throw new IOException("read() called on an inactive socket.") ;
	
	    if (this.isInputClosed())
	        throw new IOException("read() called but the input buffer is closed.") ;   
	
	    if (this.isOutputClosed())
	        throw new IOException("write() called but the output buffer is closed.") ;   
	    
	    return this.input.read(buffer, offset, length) ;
	}
	
	public static final int time() {
		return (int)(System.currentTimeMillis() / 1000) ;
	}

	public void unlinkConnectionObserver(final ConnectionObserver observer) {
		connectionObservers.remove(observer);
	}

	public void unlinkDisconnectObserver(final DisconnectObserver observer) {
		disconnectObservers.remove(observer);
	}

	public void unlinkExceptionObserver(final ExceptionObserver observer) {
		exceptionObservers.remove(observer);
	}

	public void unlinkLogonObserver(final LogonObserver observer) {
		logonObservers.remove(observer);
	}

	public abstract void write(Message message) throws IllegalArgumentException, IllegalStateException, NullPointerException ;
	
}