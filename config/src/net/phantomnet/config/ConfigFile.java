package net.phantomnet.config;

import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import net.phantomnet.config.interfaces.Named;
import net.phantomnet.config.interfaces.Parent;
import net.phantomnet.config.interfaces.Source;

public class ConfigFile
	implements Named, Parent, Source {
	
	/**
	 * String representation of the absolute path of this ConfigFile.
	 * The file represented by this bath will always exist and never 
	 * be null.
	 */
	private final String source ;
	
	/**
	 * Internal lock maintained by this ConfigFile. While rarely used,
	 * the writeLock will only ever be employed during creation. All 
	 * other calls including that of getChildren() will use the readLock()
	 * explicitly to maintain a single value.
	 */
	private final ReadWriteLock lock = new ReentrantReadWriteLock(true);

	/**
	 * Collection of ConfigBlock's that exists inside the ConfigFile
	 */
	private final Collection<ConfigBlock> blocks = new LinkedList<ConfigBlock>();
	
	/**
	 * An internal list containing all stand-alone properties inside the "primary" root block
	 */
	private final Collection<ConfigProperty> properties = new LinkedList<ConfigProperty>();
	
	/**
	 * Contains the variable list as set in the config file
	 * The config file allows for custom variables to be set
	 * and declared to be used later on.
	 * 
	 * All variables are surrounded by brackets when referenced.
	 * Such form would be {variable} inside a string
	 */
	private final HashMap<String, String> variables = new HashMap<String, String>();
	
	private final Configuration parent ;
	
	private final ConfigBlock rootBlock;
	
	public ConfigFile (final File file, final Configuration parent) 
		throws ConfigurationException, IllegalArgumentException, IOException, ParserConfigurationException, SAXException 
	{
		if (file == null) 
			throw new IllegalArgumentException("The supplied file Cannot be null");
		if (!file.exists())
			throw new IllegalArgumentException("Supplied configuration file does not exist");
		
		this.source = file.getCanonicalPath().trim();
		
		final Element root = getRootElement();
		if (root == null) 
			throw new ConfigurationException("Root element is null");
		if (!root.getNodeName().equals("config"))
			throw new ConfigurationException("The root element must be named \"config\"");
		
		this.parent = parent;
		// we need to save a root node to the "config" node
		// This is because any lingering ConfigProperty's need a
		// parent that is a block
		this.rootBlock = new ConfigBlock(root, this);
	}
	
	public void addVariable(final String name, final String variable) {
		// pass the variable up to the configuration wrapper
		getParent().addVariable(name, variable);
		// add the variable to this configfile
		this.variables.put(name, variable);
	}
	
	/**
	 * @param Node node
	 * @return encapsulation level of the current node - how many blocks it exists inside
	 */
	public static final int findLevel (Node node)
	{
		int level = 0 ;
		if (node.getParentNode() == null)
			return 1 ;
		
		for (Node previous = node.getParentNode(); previous != null; level++)		
			previous = previous.getParentNode() ;
		
		return ((level - 1) >= 0) ? level - 1 : 0 ;
	}
	
	/**
	 * @param element - Element containing a name and value
	 * @param position - integer position of the node in the node list to grab
	 * @return ConfigItem containing the name and value of an element node or null if position is to large
	 */
	public static final Map<String, ConfigAttribute> getAttributes (Node element, String source) {		
		final Map<String, ConfigAttribute> map = new HashMap<String, ConfigAttribute>(1);
		if (element == null || !element.hasAttributes())
			return map;
		final NamedNodeMap attributes = element.getAttributes();
		for (int i = 0; i < attributes.getLength(); i++) {
			final Node node = attributes.item(i);
			if (node.getNodeType() == Node.ATTRIBUTE_NODE)
				map.put(node.getNodeName(), new ConfigAttribute(node.getNodeName(), node.getNodeValue(), source));
		}
		return map;
	}

	public static final int getAttributeCount (final Node root) {
		int count = 0;
    	for (Node node = root.getFirstChild(); node != null;) {
			Node nextNode = node.getNextSibling() ;
			if (node.getNodeType() == Node.ATTRIBUTE_NODE) 
				count++;
			node = nextNode ;
		}
    	return count;
    }

	/**
	 * @param NodeList list
	 * @return The count of ELEMENT_NODE types in the node list
	 */
	public static final int getChildCount(final NodeList list)
	{
		int count = 0 ;
		for (int i = 0; i < list.getLength(); i++)
			if (list.item(i).getNodeType() == Node.ELEMENT_NODE)
				count++ ;
		return count ;
	}
	
	public ReadWriteLock getLock() {
		return this.lock;
	}

	public String getName() {
		return new File(getSource()).getName();
	}
	
	/**
	 * @param element - Element containing a name and value
	 * @param position - integer position of the node in the node list to grab
	 * @return ConfigItem containing the data from the node
	 */
	public static ConfigProperty getNode (Element element, int position)
	{
		int count = element.getAttributes().getLength() ;
		// Prevents IndexOutOfBoundsException
		if ((count - 1) <= position)
			return null ;
		
	    //Node node = ((Node) element.getChildNodes().item(position)) ;
	    return null;
	}

	/**
	 * @param NodeList node
	 * @return String based representation of the node type
	 */
	public static final String getNodeType (Node node)
	{
		return getNodeType(node.getNodeType()) ;
	}

	/** 
	 * @param type - integer representing the type of element a Node is
	 * @return String based representation of the node type
	 */
	public static final String getNodeType (int type)
	{
	    String node = null ;
	    switch (type)
	    {
	        case Node.ATTRIBUTE_NODE :
	            node = "Attribute Node" ;
	        break ;
	        case Node.CDATA_SECTION_NODE :
	            node = "Cdata Section Node" ;
	        break ;
	        case Node.COMMENT_NODE :
	            node = "Comment Node" ;
	        break ;
	        case Node.DOCUMENT_FRAGMENT_NODE :
	            node = "Document Fragment Node" ;
	        break ;
	        case Node.DOCUMENT_NODE :
	            node = "Document Node" ;
	        break ;
	        case Node.DOCUMENT_TYPE_NODE :
	            node = "Document Type Node" ;
	        break ;
	        case Node.ELEMENT_NODE :
	            node = "Element Node" ;
	        break ;
	        case Node.ENTITY_NODE :
	            node = "Entity Node" ;
	        break ;
	        case Node.ENTITY_REFERENCE_NODE :
	            node = "Entity Reference Node" ;
	        break ;
	        case Node.NOTATION_NODE :
	            node = "Notation Node" ;
	        break ;
	        case Node.PROCESSING_INSTRUCTION_NODE :
	            node = "Processing Intruction Node" ;
	        break ;
	        case Node.TEXT_NODE :
	            node = "Text Node" ;
	        break ;
	    }
	    
	    return node ;
	}
	
	public static String getNodeValue(final Node node) {
		if (node == null || !node.hasChildNodes())
			return "";
		return node.getChildNodes().item(0).getNodeValue().trim();
	}

	public Configuration getParent() {
		return this.parent;
	}
	
	public ConfigBlock getRootBlock() {
		return this.rootBlock;
	}
	
	public Element getRootElement() 
			throws ParserConfigurationException, SAXException, IOException {
		final Document document = getXMLDocument();
		if (document == null)
			return null;
		return getRootElement(document);
	}
	
	public Element getRootElement(final Document document) {
		if (document == null)
			return null;
		return document.getDocumentElement();
	}

	public String getSource() {
		return this.source;
	}	
	
	public String getSource (final boolean type) {
		if (!type)
			return getSource();
		return new File(getSource()).getName();
	}
	
	public Map<String, String> getVariables() {
		return getParent().getVariables();
	}
	
	public final Document getXMLDocument() 
			throws ParserConfigurationException, SAXException, IOException {
		final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance() ;
		// Generate an immutable File object for the config file
		final File config = new File(getSource()) ; 
		// create a DOcumentBuilder form the factory
		final DocumentBuilder builder = factory.newDocumentBuilder() ;
		// return the parsed file
		return builder.parse (config) ;
	}
	
    public boolean hasBlocks() {
		getLock().readLock().lock();
		try {
			return this.blocks.isEmpty();
		} finally {
			getLock().readLock().unlock();
		}
	}
    
    public static final boolean hasAttributes(final Node root) {
    	for (Node node = root.getFirstChild(); node != null;) {
			Node nextNode = node.getNextSibling() ;
			if (node.getNodeType() == Node.ATTRIBUTE_NODE) 
				return true;
			node = nextNode ;
		}
    	return false;
    }
    
    public static final boolean hasChildNodes(final Node root) {
    	for (Node node = root.getFirstChild(); node != null;) {
			Node nextNode = node.getNextSibling() ;
			if (node.getNodeType() == Node.ELEMENT_NODE) 
				return true;
			node = nextNode ;
		}
    	return false;
    }
	
	public static final boolean isEmptyNode(final Node node) {
		return hasChildNodes(node) && hasAttributes(node);
	}
	
	public void rehash()
		throws ConfigurationException, ParserConfigurationException, SAXException, IOException {
		// grab the write lock
		System.out.println("\t\tStage1.4.1 :: Obtaining writeLock");
		getLock().writeLock().lock();
		try {			
			// XML Document that represents this ConfigFile
			System.out.println("\t\tStage1.4.2 :: Creating XML Document");
			final Document document = getXMLDocument();
			// Root element representing this configFile
			// The name will always be "config" if it has 
			// reached this point
			System.out.println("\t\tStage1.4.3 :: Finding root element");
			final Element root = getRootElement(document);
			// check that the root element is not empty
			System.out.println("\t\tStage1.4.4 :: Searching for child nodes");
			if (getChildCount(root.getChildNodes()) == 0) 
				throw new ConfigurationException("REHASH :: Cannot parse "+getSource(true)+
					" Root XML node is empty");
			
			// we are re-parsing the file, so clear out
			// stale data
			System.out.println("\t\tStage1.4.5 :: Clearing block list");
			this.blocks.clear();
			System.out.println("\t\tStage1.4.6 :: Clearing variable list");
			this.variables.clear();
			System.out.println("\t\tStage1.4.7 :: Parsing ConfigFile");
			int lineNumber = 0;
			for (Node node = root.getFirstChild(); node != null;) {
				Node nextNode = node.getNextSibling() ;
				lineNumber++;
				try {
					if (node.getNodeType() == Node.ELEMENT_NODE) {
						if (isEmptyNode(node))
							continue ;
						final Map<String, ConfigAttribute> attributes = getAttributes(node, getSource());
					    if (node.getNodeName().equals("define")) {
					    	// a definition must contain a "variable" attribute which signifies the variable name
					    	if (!attributes.containsKey("variable"))
					    		throw new ConfigurationException("Definition missing variable attribute on line "+lineNumber+".");
					    	// a definition must contain a "reference" attribute which signifies the variable value
					    	if (!attributes.containsKey("reference"))
					    		throw new ConfigurationException("Definition missing reference attribute on line "+lineNumber+".");
					    	// Parse the value for any variable replacements that need to be made
					    	final String value = ConfigProperty.parse(attributes.get("reference").getValue(), getParent().getVariables());
					    	// each COnfigAttribute represents a pair of variable=reference related attributes
					    	addVariable(attributes.get("variable").getValue(), value);
					    } else {
					    	// if children == 1, ConfigProperty
					    	// if children > 1, ConfigBlock
					    	if (getChildCount(node.getChildNodes()) == 0) {
			                	this.properties.add(new ConfigProperty(node, this.rootBlock)) ;			                	
					    	} else {
			                	this.blocks.add(new ConfigBlock((Element) node, this.rootBlock, this)) ;
					    	}
					    }					    
					}
				} catch (final ConfigurationException e) {
					Logger.getLogger("net.phantomnet").log(Level.WARNING, e.getMessage(), e);
				} finally {
					node = nextNode ;
				}				
			}
		} finally {
			System.out.println("\t\tStage1.4.8 :: Releasing writeLock");
			getLock().writeLock().unlock();
		}		
	}
}
