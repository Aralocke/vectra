package net.phantomnet.config;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import net.phantomnet.config.interfaces.Parent;
import net.phantomnet.config.interfaces.Source;
import net.phantomnet.observer.Event;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;

public class Configuration implements Parent, Source {
	
	public static final String DEFAULT_BASE_DIRECTORY = "..";
	
	public static final String DEFAULT_CONFIG_DIRECTORY = "config";
	
	public static final String DEFAULT_XML_FILE = "config.xml";
	
	public static final String DEFAULT_XSD_FILE = "config.xsd";
	
	private String configFile = DEFAULT_XML_FILE;
	
	private String xsdFile = DEFAULT_XSD_FILE;
	
	private final ReadWriteLock lock = new ReentrantReadWriteLock(true) ;
	
	private final Map<String, String> variableCache = new HashMap<String, String>();
	
	private ConfigFile _configFile ;
	
	public Configuration() throws IllegalArgumentException {
		this(DEFAULT_XML_FILE);
	}
	
	public Configuration(String configFile) throws IllegalArgumentException {
		this(configFile, DEFAULT_XSD_FILE);
	}

	public Configuration (String configFile, String xsdFile) throws IllegalArgumentException {
		if (configFile == null || configFile.isEmpty())
			throw new IllegalArgumentException("Cannot use supplied configuration file :: Null or Length Zero");
		if (!configFile.endsWith(".xml"))
			throw new IllegalArgumentException("Cannot use supplied configuration file :: Config files must be XML Files");
		if (xsdFile == null || xsdFile.isEmpty())
			throw new IllegalArgumentException("Cannot use supplied schema file :: Null or Length Zero filename");
		if (!xsdFile.endsWith(".xsd"))
			throw new IllegalArgumentException("Cannot use supplied schema file :: schema files must be XSD Files");
		// Sets the schema file used to validate the XML - default is config.xsd
		setSchemaFile(xsdFile);		
		// set the XML configuration file - default is config.xml
		setConfigFile(configFile);
	}
	
	public void addVariable(final String name, final String value) {
		if (name != null && !name.isEmpty())
			this.variableCache.put(name, ((value == null)?"":value));
	}
	
	public String getConfig() {		
		this.lock.readLock().lock();
		try {
			return this.configFile;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public File getConfigFile() {
		return new File(rootDirectory()+getConfig());
	}

	public Parent getParent() {
		return null;
	}

	public String getSchema() {
		this.lock.readLock().lock();
		try {
			return this.xsdFile;
		} finally {
			this.lock.readLock().unlock();
		}
	}

	public File getSchemaFile() {
		return new File(rootDirectory()+getSchema());
	}
	
	public String getSource() {		
		return getConfig();
	}

	public Map<String, String> getVariables() {
		return new HashMap<String, String>(this.variableCache);
	}
	
	public void rehash() throws ConfigurationException, IllegalArgumentException, IOException, ParserConfigurationException, SAXException {		
		// first thing is to validate the XML
		System.out.println("\tStage1.1 :: Validating config file against "+getSchemaFile());
		validate();
		// clear the existing variables list
		System.out.println("\tStage1.2 :: Clearing variable cache");
		this.variableCache.clear();
		// create a new configuration object
		System.out.println("\tStage1.3 :: Creating a new ConfigFile for "+getConfigFile());
		this._configFile = new ConfigFile(getConfigFile(), this);
		// hash the file
		System.out.println("\tStage1.4 :: Rehashing in-memory config file");
		this._configFile.rehash();
		// grab the variable list
		System.out.println("\tStage1.5 :: Retrieving all variables from ConfigFile");
		this.variableCache.putAll(
			this._configFile.getVariables()
		);
		System.out.println("\tStage1 :: Completed successfully!");
	}

	public static final String rootDirectory()	{
		try {
			return new File(DEFAULT_BASE_DIRECTORY+"/").getCanonicalPath() + File.separator;
		} catch (Exception e) {
			return "."+File.separator;
		}		
	}

	public final void setConfigFile(String filename) {
		if (filename == null || filename.isEmpty())
			throw new IllegalArgumentException("Supplied filename cannot be null or empty");
		if (!filename.endsWith(".xml"))
			throw new IllegalArgumentException("Configuration file must be an xml file type");
		
		this.lock.writeLock().lock();
		try {
			this.configFile = filename.trim();
		} finally {
			this.lock.writeLock().unlock();
		}
	}
	
	public final void setSchemaFile(String filename) {
		if (filename == null || filename.isEmpty())
			throw new IllegalArgumentException("Supplied filename cannot be null or empty");
		if (!filename.endsWith(".xsd"))
			throw new IllegalArgumentException("Schema file must be an xsd file type");
		
		this.lock.writeLock().lock();
		try {
			this.xsdFile = filename.trim();
		} finally {
			this.lock.writeLock().unlock();
		}
	}
	
	public void triggerEvent(final Event event)
		throws ConfigurationException {
		
	}

	public final boolean validate() throws IOException, SAXException, ParserConfigurationException {		
		// parse an XML document into a DOM tree
		final DocumentBuilder parser = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        // create the XML document object		
		final Document document = parser.parse(getConfigFile());
		// create a SchemaFactory capable of understanding WXS schemas
		final SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
		// load a WXS schema, represented by a Schema instance
		final Schema schema = factory.newSchema(new StreamSource(getSchemaFile()));
		// create a Validator instance, which can be used to validate an instance document
		final Validator validator = schema.newValidator();
		// validate the DOM tree	    
		validator.validate(new DOMSource(document));
		return true;
	}
}
