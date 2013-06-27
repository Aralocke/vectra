package org.vectra;

import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.util.concurrent.atomic.AtomicInteger;

import org.vectra.interfaces.Encoded;
import org.vectra.interfaces.Source;
import org.vectra.interfaces.Priority;

public abstract class Message 
	implements Encoded, Source, Priority, Comparable<Message>
{
	/**
	 * Unique ID
	 */
	private static final long serialVersionUID = -6856614457147981669L;
	
	protected final int comparable = number.getAndIncrement() ;
	protected final String message ;
	protected final String encoding ;
	protected final byte priority ;
	protected static final AtomicInteger number = new AtomicInteger() ;
	
	public Message (final String message, final String encoding, final byte priority)
	{
		this.message = message.trim() ;
		this.encoding = encoding.trim() ;
		this.priority = priority ;
	}
	
	public byte[] getBuffer ()
	{
		// Create a charset based on the encoding of the IRCmessage
		final Charset charset = Charset.forName(this.encoding) ;
		// the byte buffer converts the string back into an encoded
		// stream of bytes that we will eventually send
		final ByteBuffer bb = charset.encode(CharBuffer.wrap(this.message)) ;
		// Create a new buffer to set the \r\n
		//final byte[] buffer = new byte[bb.remaining() + 2] ;
		final byte[] buffer = new byte[bb.remaining()] ;
		// fill teh buffer with the bytes remaining in the ByteBuffer
		bb.get(buffer, 0, bb.remaining()) ;
		// add the line feed
		//buffer[buffer.length - 2] = Connection.LINE_FEED ;
		// add the new line
		//buffer[buffer.length - 1] = Connection.NEW_LINE ;		
		return buffer ;
	}
	
	public int getNumber ()
	{
		return this.comparable ;
	}
	
	public String getEncoding ()
	{
		return this.encoding ;
	}
	
	public String getMessage ()
	{
		return this.message ;
	}
	
	public byte getPriority ()
	{
		return this.priority ;
	}
	
	public abstract int compareTo (final Message other) ;
}
