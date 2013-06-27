package net.phantomnet.observer;

import java.util.EventListener;


/**
 * Observer is used to build an event driven frame work. In the case of IRC
 * each event that occurs that affects the state or status of the bot can
 * be processed as an observation and thus sent to a child of this class.
 * 
 * The goal of an observer should be to take Events (ConnectEvent, LogonEvent, etc)
 * and handle them appropriately. Handling could involve passing the event on to the
 * eventQueue or in the case of the DisconnectEvent can be used to alert observers
 * that a connection has disconnected.
 * 
 * This framework provides access to functionality that can only be derived form 
 * cross thread communication which is expressly forbidden by design. The Observer
 * allows passing of data between threads which is the ONLY method of allowing such
 * shared behaviors as a coordinated InviteSystem and a command and control system 
 * across all bots and theads.
 * 
 * All Observers must inherit from this class.
 * 
 * @author Danny
 *
 */

public interface Observer extends EventListener {}
