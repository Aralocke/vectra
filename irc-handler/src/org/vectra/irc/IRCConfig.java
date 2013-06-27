package org.vectra.irc;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import org.vectra.Connection;
import org.vectra.StrUtils;
import org.vectra.interfaces.Source;
import org.vectra.interfaces.Named;

/**
 * The IRCConfig class contains all runtime data about the current
 * connected network as parsed by the 005 raw numeric on connect.
 * Values contained in this class do not change except when connecting
 * and therefore will contain no direct setter methods. Only way to 
 * update this class is by using the parse(str) method with a string.
 * 
 * @author Danny
 *
 */
public class IRCConfig 
	implements Source, Named
{
	
	/**
	 * Unique serialized ID
	 */
	private static final long serialVersionUID = -1911985531760333321L;
	
	/**
	 * The parent IRCBotConfig that contains the reference to this
	 * IRCConfig.
	 */
	private final IRCConnection parent ;
	
	public static final String CASE_MAPPING = "rfc1459" ;
	public String caseMapping = CASE_MAPPING;

	public static final String CHANNEL_MODES = "b,k,l,psmnti" ;
	public String channelModeCategories = CHANNEL_MODES;

	public static final String CHANNEL_PREFIXES = "#" ;
	public String channelPrefixes = CHANNEL_PREFIXES;

	public static final String MODE_PREFIXES = "@+" ;
	public String modePrefixes = MODE_PREFIXES;

	public String network = null;

	public String serverName = null ;
	
	public String serverVersion = null ;
	
	public static final String SUPPORTED_USERMODES = "iow" ;
	public String supportedUserModes = SUPPORTED_USERMODES;
	
	public static final String SUPPORTED_CHANNELMODES = "vokpsmntilb" ;
	public String supportedChannelModes = SUPPORTED_CHANNELMODES;
	
	public static final short CHANNEL_LIMIT = 0;
	public short channelLimit = CHANNEL_LIMIT;
	
	public static final short MAX_NICK_LENGTH = 9;
	public short maxNicknameLength = MAX_NICK_LENGTH;
	
	public static final short MAX_CHANNEL_LENGTH = 15;
	public short maxChannelLength = MAX_CHANNEL_LENGTH;
	
	public static final short MAX_TOPIC_LENGTH = 80 ;
	public short maxTopicLength = MAX_TOPIC_LENGTH;
	
	public static final short MAX_KICK_LENGTH = 80 ;
	public short maxKickLength = MAX_KICK_LENGTH;
	
	public static final short MAX_AWAY_LENGTH = 80;
	public short maxAwayLength = MAX_AWAY_LENGTH;
	
	public static final short MAX_TARGETS = 20;
	public short maxTargets = MAX_TARGETS;
	
	public static final short BAN_LIST_LENGTH = 20;
	public short banListLength = BAN_LIST_LENGTH;
	
	public static final short EXCEPTION_LIST_LENGTH = 20;
	public short banExemptionListLength = 20;
	
	public static final short INVITE_LIST_LENGTH = 20;
	public short inviteListLength = INVITE_LIST_LENGTH;
	
	public static final byte MODES_PER_LINE = 3; 
	public byte modesPerLine = MODES_PER_LINE;
	
	public static final boolean UNAMES = false;
	public boolean uNamesSupported = UNAMES;
	
	public static final Pattern statusPrefixRemover = Pattern.compile("^.*\\(|\\).*$");

	public static final Pattern statusModeRemover = Pattern.compile("^.*\\)");
	
	public IRCConfig (final IRCConnection parent) {
		this.parent = parent ;
	}
	
	/**
	 * @return Limit imposed on the number of entries maintained by a channel's
	 *         ban list (<tt>mode #</tt><i>channel</i><tt> +b</tt>), as
	 *         indicated by the server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>MAXLIST=b:</tt><i>number</i>
	 */
	public short getBanListLength() 
	{
		return this.banListLength;
	}

	/**
	 * @return Limit imposed on the number of entries maintained by a channel's
	 *         ban exemption list (<tt>mode #</tt><i>channel</i><tt> +e</tt>),
	 *         as indicated by the server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>MAXLIST=e:</tt><i>number</i>
	 */
	public short getBanExemptionListLength() 
	{
		return this.banExemptionListLength;
	}

	/**
	 * @return Character set used by the server to determine the equality of two
	 *         nicks case-insensitively, as indicated by the server in a
	 *         <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>CASEMAPPING=</tt>
	 *         <b>ascii</b>/<b>rfc1459</b>/<b>strict-rfc1459</b>
	 */
	public String getCaseMapping() {
		return this.caseMapping;
	}

	public Connection getConnection() {
		return this.parent;
	}

	/**
	 * @return Limit imposed on the number of channels joined, as indicated by
	 *         the server in a <tt>005</tt> reply. The limit preserved is the
	 *         one imposed on # channels, not any other channel type.
	 *         <p>
	 *         Token parsed: <tt>MAXCHANNELS=</tt><i>number</i>
	 */
	public short getChannelLimit() {
		return this.channelLimit;
	}

	/**
	 * @return Classes of channel modes, depending upon their need (or not) for
	 *         parameters, as indicated by the server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>CHANMODES=</tt><i>modesA</i><tt>,</tt>
	 *         <i>modesB</i><tt>,</tt><i>modesC</i><tt>,</tt><i>modesD</i>
	 *         <p>
	 *         The mode categories are as follows:
	 *         <ul>
	 *         <li>A: Modes that define a list (<tt>+beI</tt>) and require a
	 *         parameter;
	 *         <li>B: Modes that require a parameter both when setting them and
	 *         unsetting them (<tt>+k</tt>);
	 *         <li>C: Modes that require a parameter only when setting them (
	 *         <tt>+l</tt>);
	 *         <li>D: Modes that do not take a parameter (<tt>+psmnti</tt>).
	 *         </ul>
	 */
	public String getChannelModeCategories() {
		return this.channelModeCategories;
	}

	/**
	 * @return Prefixes used to specify channel modes for users in NAMES
	 *         replies.
	 *         <p>
	 *         The format of return value is
	 *         <blockquote><i>prefix</i>[<i>prefix</i> ...]</blockquote> For
	 *         example, <b>&#64;+</b>.
	 * @see #getModePrefixes()
	 */
	public String getChannelStatusPrefixes() 
	{
		return statusModeRemover.matcher(modePrefixes).replaceAll("");
	}

	/**
	 * @return Modes used to affect users in channels.
	 *         <p>
	 *         The format of the return value is
	 *         <blockquote><i>modeletter</i>[<i>modeletter</i> ...]</blockquote>
	 *         For example, <b>ov</b>.
	 * @see #getModePrefixes()
	 */
	public String getChannelStatusModes() 
	{
		return statusPrefixRemover.matcher(modePrefixes).replaceAll("");
	}

	/**
	 * @return Limit imposed on the number of entries maintained by a channel's
	 *         invite override list (<tt>mode #</tt><i>channel</i><tt> +I</tt>),
	 *         as indicated by the server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>MAXLIST=I:</tt><i>number</i>
	 */
	public short getInviteListLength() 
	{
		return inviteListLength;
	}

	/**
	 * @return Limit imposed on the length of away messages used by users, as
	 *         indicated by the server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>AWAYLEN=</tt><i>number</i>
	 */
	public short getMaxAwayLength() 
	{
		return maxAwayLength;
	}

	/**
	 * @return Limit imposed on the length of kick messages, as indicated by the
	 *         server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>KICKLEN=</tt><i>number</i>
	 */
	public short getMaxKickLength() 
	{
		return maxKickLength;
	}
	
	/**
	 * @return Limit imposed on the maximum number of targets that may be affected
	 *         by any given command
	 *         <p>
	 *         Token parsed: <tt>MAXTARGETS=</tt><i>number</i>
	 */
	public short getMaxTargets() {
		return maxTargets;
	}

	/**
	 * @return Limit imposed on the length of nicks used, as indicated by the
	 *         server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>NICKLEN=</tt><i>number</i>
	 */
	public short getMaxNicknameLength() 
	{
		return maxNicknameLength;
	}

	/**
	 * @return Limit imposed on the length of channel names joined, as indicated
	 *         by the server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>CHANNELLEN=</tt><i>number</i>
	 */
	public short getMaxChannelLength() 
	{
		return maxChannelLength;
	}

	/**
	 * @return Limit imposed on the length of channel topics set, as indicated
	 *         by the server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>TOPICLEN=</tt><i>number</i>
	 */
	public short getMaxTopicLength() 
	{
		return maxTopicLength;
	}

	/**
	 * @return Number of channel mode sets allowed in a single command, as
	 *         indicated by the server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>MODES=</tt><i>number</i>
	 */
	public byte getModesPerLine() 
	{
		return this.modesPerLine;
	}

	public String getModePrefixes() 
	{
		return this.modePrefixes;
	}

	public String getName() 
	{
		return getConnection().getConfig().getConnID();
	}

	/**
	 * @return Name of the network to which the server belongs, as indicated by
	 *         the server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>NETWORK=</tt><i>token</i>
	 */
	public String getNetwork() 
	{
		return this.network;
	}

	/**
	 * @return Server name, as indicated by the server itself. This may differ
	 *         from the hostname used to connect to it.
	 */
	public String getServerName() 
	{
		return this.serverName;
	}

	/**
	 * @return Server version, as indicated by the server in a <tt>004</tt>
	 *         reply.
	 */
	public String getServerVersion() 
	{
		return this.serverVersion;
	}
	
	/**
	 * @return Channel modes supported by the server, as indicated by the server
	 *         in a <tt>004</tt> reply.
	 */
	public String getSupportedChannelModes() 
	{
		return this.supportedChannelModes;
	}

	/**
	 * @return User modes supported by the server, as indicated by the server in
	 *         a <tt>004</tt> reply.
	 */
	public String getSupportedUserModes() 
	{
		return this.supportedUserModes;
	}

	/**
	 * @return Characters allowed to prefix channel names, as indicated by the
	 *         server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>CHANTYPES=</tt><i>characters</i>
	 */
	public String getChannelPrefixes() 
	{
		return this.channelPrefixes;
	}

	/**
	 * @return <code>true</code> if the UHNAMES (<u>u</u>ser<u>h</u>osts in
	 *         /<u>names</u>) protocol extension is supported on the server, as
	 *         indicated by the server in a <tt>005</tt> reply.
	 *         <p>
	 *         Token parsed: <tt>UHNAMES</tt>
	 */
	public boolean isUHNamesSupported() 
	{
		return this.uNamesSupported;
	}

	/**
	 * Determines if a certain label is a valid channel name on this IRC server.
	 * 
	 * @param label
	 *            The IRC label to check.
	 * @return <code>true</code> if the label is a channel label per the
	 *         <tt>005</tt> reply's <tt>CHANTYPES</tt> token (and
	 *         <tt>getChannelPrefixes()</tt>); <code>false</code> if not.
	 */
	public boolean isChannel (final String label) 
	{
		//final Pair<String, String> channelStatus = parseChannelStatus(label);
		//return channelStatus.getKey().length() == 0;
		return (getChannelPrefixes().indexOf((int)label.charAt(0)) > 0) && 
				(label.length() > 1);
	}
	
	public List<String> processChannelModes(final List<String> modeTokens) {
		if (modeTokens.size() == 0)
			return new ArrayList<String>(0);
		int nextParam = 1;
		boolean isPlus = true;
		final List<String> categories = StrUtils.split(getChannelModeCategories(), ',');
		final String minusParam = categories.get(0) + categories.get(1) + getChannelStatusModes();
		final String plusParam = categories.get(0) + categories.get(1) + categories.get(2) + getChannelStatusModes();
		final ArrayList<String> result = new ArrayList<String>();
		for (int i = 0; i < modeTokens.get(0).length(); i++) {
			final char cur = modeTokens.get(0).charAt(i);
			if (cur == '+')
				isPlus = true;
			else if (cur == '-')
				isPlus = false;
			else {
				if ((isPlus && plusParam.indexOf(cur) != -1) || (!isPlus && minusParam.indexOf(cur) != -1))
					result.add((isPlus ? "+" : "-") + cur + " " + modeTokens.get(nextParam++));
				else
					result.add((isPlus ? "+" : "-") + cur);
			}
		}
		return result;
	}

	public String parseChannelStatusModes(final String parseModes) {
		final String modes = getChannelStatusModes(); //getModePrefixes().substring(1, getModePrefixes().indexOf(')')).trim();
		final String prefixes = getChannelStatusPrefixes(); //getModePrefixes().substring(getModePrefixes().indexOf(')') + 1).trim(); 
		
		final StringBuilder channelModes = new StringBuilder();
		
		for (int i = 0; i < parseModes.length(); i++) {
			final char mode = parseModes.charAt(i);
			if (prefixes.indexOf(mode) != -1) 
				channelModes.append(modes.charAt(prefixes.indexOf(mode)));
		}
		return channelModes.toString();
	}
	
	public String parseChannelStatusPrefixes(final String parsePrefixes) {
		final String modes = getChannelStatusModes(); //getModePrefixes().substring(1, getModePrefixes().indexOf(')')).trim();
		final String prefixes = getChannelStatusPrefixes(); //getModePrefixes().substring(getModePrefixes().indexOf(')') + 1).trim(); 
		
		for (int i = 0; i < parsePrefixes.length(); i++) {
			final char mode = parsePrefixes.charAt(i);
			if (modes.indexOf(mode) != -1) 
				return ""+prefixes.charAt(modes.indexOf(mode));
		}
		return "";
	}
}
