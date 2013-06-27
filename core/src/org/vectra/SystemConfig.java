package org.vectra;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.xml.parsers.ParserConfigurationException;

import org.vectra.components.NetworkConfig;
import org.xml.sax.SAXException;

import net.phantomnet.config.Configuration;
import net.phantomnet.config.ConfigurationException;
import net.phantomnet.sql.MySQLConfig;

public final class SystemConfig {	
	
	private static final AtomicInteger idGenerator = new AtomicInteger();
	
	private static final AtomicInteger familyIdGenerator = new AtomicInteger();
	
	private Configuration configuration = null ;
	
	private final ReadWriteLock lock = new ReentrantReadWriteLock(true);
	
	/**
	 * Configuration Variables 
	 */
	
	private final List<BotConfig> botlist = new LinkedList<BotConfig>();
	
	private String dbhost = null;
	private String dbuser = null;
	private String dbpass = null;
	private String dbname = null;
	private int dbport = 0;
	private Map<String, ArrayList<String>> interfaces = new TreeMap<String, ArrayList<String>>();

	private int maxbots = 1;

	private List<String> moduleList = new ArrayList<String>(1);

	private List<NetworkConfig> networks = new ArrayList<NetworkConfig>();

	private int poolSize = 0;
	
	private int reloadLevel = 0;

	public SystemConfig() throws IllegalArgumentException {
		this(Configuration.DEFAULT_XML_FILE);
	}
	
	public SystemConfig(String configFile) throws IllegalArgumentException {
		this(Configuration.DEFAULT_XML_FILE, Configuration.DEFAULT_XSD_FILE);
	}
	
	public SystemConfig(String configFile, String xsdFile) throws IllegalArgumentException {	
		if (configFile == null || configFile.isEmpty())
			throw new IllegalArgumentException("Cannot use supplied configuration file :: Null or Length Zero");
		if (!configFile.endsWith(".xml"))
			throw new IllegalArgumentException("Cannot use supplied configuration file :: Config files must be XML Files");
		if (xsdFile == null || xsdFile.isEmpty())
			throw new IllegalArgumentException("Cannot use supplied schema file :: Null or Length Zero filename");
		if (!xsdFile.endsWith(".xsd"))
			throw new IllegalArgumentException("Cannot use supplied schema file :: schema files must be XSD Files");
		this.configuration = new Configuration(configFile, xsdFile);	
		System.out.println("SystemConfig started using files:\n\t"+getConfiguration().getConfigFile()+"\n\t"+getConfiguration().getSchemaFile());
	}
	
	public Configuration getConfiguration() {
		this.lock.readLock().lock();
		try {
			return this.configuration;
		} finally {
			this.lock.readLock().unlock();
		}
	}
	
	public MySQLConfig getMySQLConfig() {
		this.lock.readLock().lock();
		try {
			return new MySQLConfig(this.dbhost, this.dbname, this.dbuser, this.dbpass, this.dbport);
		} finally {
			this.lock.readLock().unlock();
		}		
	}
	
	public static int getNewFamilyID() {
		return Math.abs(familyIdGenerator.getAndIncrement());
	}

	public static int getNewSequentialID() {
		return Math.abs(idGenerator.getAndIncrement());
	}
	
	public String getSQLHost() {
		this.lock.readLock().lock();
		try {
			return this.dbhost;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public String getSQLName() {
		this.lock.readLock().lock();
		try {
			return this.dbname;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public String getSQLPass() {
		this.lock.readLock().lock();
		try {
			return this.dbpass;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public int getSQLPort() {
		this.lock.readLock().lock();
		try {
			return this.dbport;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public String getSQLUser() {
		this.lock.readLock().lock();
		try {
			return this.dbuser;
		} finally {
			this.lock.readLock().unlock();
		}
	}
	
	private synchronized void cleanup() {		
		System.out.println("\tStage 5.1 :: Cleaning interface list");
		for (ArrayList<String> a : this.interfaces.values())
			a.trimToSize();
	}
	
	private synchronized void clear() {
		System.out.println("\tStage 2.1 :: Clearing interfaces list");
		this.interfaces.clear();
		System.out.println("\tStage 2.2 :: Clearing botlist");
		this.botlist.clear();
		System.out.println("\tStage 2.3 :: Clearing networks list");
		this.networks.clear();
		System.out.println("\tStage 2.4 :: Clearing module list");
		this.moduleList.clear();
	}

	private synchronized void parse() throws ConfigurationException {
				
	}
	
	public void rehash() {
		System.out.println("rehash() initiated");
		this.lock.writeLock().lock();
		System.out.println("WriteLock obtained");
		try {			
			System.out.println("Stage 1 :: Rehash");
			getConfiguration().rehash();
			System.out.println("Stage 2 :: Clear");
			clear();
			System.out.println("Stage 3 :: Parse in-memory configuration");
			parse(); 
			System.out.println("Stage 4 :: Generate BotConfigs");
			// generate();
			System.out.println("Stage 5 :: Cleanup");
			cleanup();			
		} catch (final ConfigurationException e) {
			Logger.getLogger("net.phantomnet").log(Level.INFO, e.getMessage(), e);
		} catch (IllegalArgumentException e) {
			Logger.getLogger("net.phantomnet").log(Level.INFO, e.getMessage(), e);
		} catch (IOException e) {
			Logger.getLogger("net.phantomnet").log(Level.INFO, e.getMessage(), e);
		} catch (ParserConfigurationException e) {
			Logger.getLogger("net.phantomnet").log(Level.INFO, e.getMessage(), e);
		} catch (SAXException e) {
			Logger.getLogger("net.phantomnet").log(Level.INFO, e.getMessage(), e);
		} finally {
			System.out.println("Releasing writelock");
			this.lock.writeLock().unlock();
			System.out.println("WriteLock released");
		}
		System.out.println("rehash() completed");
	}
}
