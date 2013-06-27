package org.vectra.components ;

import org.vectra.Connection;
import org.vectra.exceptions.ConnectionFailedException;

import java.net.Inet6Address;
import java.net.InetSocketAddress;
import java.net.ServerSocket ;
import java.net.Socket ;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import java.io.BufferedReader ;
import java.io.BufferedWriter ;
import java.io.IOException;
import java.io.InputStreamReader ;
import java.io.OutputStreamWriter ;

public class IdentServer
    extends Thread {	
	
	public final static short IDENTD_PORT = 113;
	
	private static IdentServer instance;
	private static boolean isRunning = false;
    private static final LinkedBlockingQueue<Connection> identdQueue = new LinkedBlockingQueue<Connection>();
    
    public IdentServer() {
    	setName("[IdentD-Server not listening (Queue: "+identdQueue.size()+")]");
    	isRunning = true;
    }
    
    public static IdentServer getInstance() {
    	if (instance == null)
    		instance = new IdentServer();
    	instance.start();
    	return instance;
    }
    
    private void identdServer(final Socket socket, final Connection connection) {
    	if (socket == null || !socket.isConnected())
    		return ;
    	
    	try {
			final BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream())) ;
			final BufferedWriter output = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream())) ;
			
			String line = input.readLine() ;
            if (line != null)
            {
                System.out.println("*** Ident request recieved: "+line) ;
                line = line + " : USERID : UNIX : "+connection.getConfig().getIdent() ;
                output.write(line +"\r\n") ;
                output.flush() ;
                System.out.println("*** Ident reply sent: "+line) ;
                output.close() ;
            }
		} catch (Exception e) {} 
    	finally {
    		// connecting to the ircd
			try {
				final String remoteAddress = socket.getInetAddress().getHostAddress();
				System.out.println("Connecting to the ircd...");
				connection.connect(remoteAddress, connection.getConfig().getPort());
			} catch (ConnectionFailedException e) {
				System.out.println("ConnectionFailedException :: "+e) ;
			}
    		try { 
    			socket.close(); 
    		} catch (Exception e) {} ;    		
    	}
    }
    
    public static int getQueueSize() {
    	return identdQueue.size();
    }
    
    public static final void queue(final Connection connection, final String server, final short port) {
    	if (!isRunning) {
    		try {
				connection.connect(server, port) ;
			} catch (ConnectionFailedException e) {
				System.out.println("ConnectionFailedException :: "+e) ;
			}
    	} else {
    		System.out.println("Queuing "+connection.getConfig().getConnID()+" for the identd server.");
    		try {
    			identdQueue.put(connection);
    		} catch (final InterruptedException e) {}
    	}    	
    }
    
    // method has both static and instantiated properties 
    public void run() {
    	try {
    		while (isRunning) {
    			Connection connection = null;
    			try {
					connection = identdQueue.poll(60000, TimeUnit.MILLISECONDS);
				} catch (final InterruptedException e) {}
    			// only reason connection would be null is because queue is now empty
    			if (connection == null) {
    				// queue is empty
    			} else {
    				final String listenAddr = connection.getConfig().getBindAddress();
    				final InetSocketAddress localAddr = new InetSocketAddress(listenAddr, IDENTD_PORT);
    				try {
    					System.out.println("[IdentD-Server listening on "+localAddr.getHostName()+":"+localAddr.getPort()+" (Queue: "+identdQueue.size()+")]");
    					// Create a ServerSocket on IDENTD_PORT
						final ServerSocket listener = new ServerSocket(IDENTD_PORT, 0, localAddr.getAddress());
						// AUtomatically shutdown after 60 seconds
						System.out.println("Setting timeout to 60seconds...");
						listener.setSoTimeout(60000);
						// set the reuse address flag
						System.out.println("Setting reuse address status");
						listener.setReuseAddress(true);
						// set the Thread name
						setName("[IdentD-Server listening on "+localAddr.getHostName()+":"+localAddr.getPort()+" (Queue: "+identdQueue.size()+")]");
						// begin listening for connections
						System.out.println("Listening for connections on "+localAddr.getHostName()+":"+localAddr.getPort());
						final Socket socket = listener.accept();
     					// pass to the server handler
						identdServer(socket, connection);						
						// close the listening socket
						listener.close();
						System.out.println("[IdentD-Server stopped]");						
					} catch (IOException e) {
						System.out.println("IDENTD ERROR - "+e);						
						setName("[IdentD-Server not listening (Queue: "+identdQueue.size()+")]");
					} finally {						
						
					}
    			}
    		} // while (isRunning)
    	} finally {
    		// static variable - must be set to false to restart identd process
    		isRunning = false;
    	}
    }
    
    public static void shutdown() {
    	isRunning = false;
    }
    
    public final static void startup() {
    	getInstance();
    }
}
