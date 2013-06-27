package org.vectra.loggers;

import java.util.logging.Level;

public class Levels {
	public static String toString(final Level level) {
		return Levels.toString(level, false) ;
	}
	
	public static String toString(final Level level, final boolean format) {
		switch (level.intValue()) {
		case 300: /* Level.FINEST */
			return "Finest trace:";
		case 400: /* Level.FINER */
			return "Finer trace:";
		case 500: /* Level.FINE */
			return "Fine trace:";
		case 700: /* Level.CONFIG */
			if (format)
				return "\u0002Configuration:\u0002";
			return "Configuration: ";
		case 800: /* Level.INFO */
			if (format)
				return "\u00033\u0002Notice:\u0002\u0003";
			return "Notice: ";
		case 900: /* Level.WARNING */
			if (format)
				return "\u00038\u0002Warning:\u0002\u0003";
			return "Warning: ";
		case 1000: /* Level.SEVERE */
			if (format)
				return "\u00034\u0002Severe:\u0002\u0003";
			return "Severe: ";
		default:
			return "Log level \u0002" + level.intValue() + "\u0002:";
		}
	}
}
