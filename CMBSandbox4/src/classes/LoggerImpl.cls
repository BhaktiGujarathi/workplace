public class LoggerImpl implements Logger {
	
	private static final String SEVERITY_DEBUG = 'Debug';
	private static final String SEVERITY_INFO = 'Info';
	private static final String SEVERITY_WARN = 'Warn';
	private static final String SEVERITY_ERROR = 'Error';
	private static final String SEVERITY_FATAL = 'Fatal';
	
	public void debug(String message) {
		log(SEVERITY_DEBUG, message);
	}
	
	public void info(String message) {
		log(SEVERITY_INFO, message);
	}

	public void warn(String message) {
		log(SEVERITY_WARN, message);
	}

	public void error(String message) {
		log(SEVERITY_ERROR, message);
	}

	public void fatal(String message) {
		log(SEVERITY_FATAL, message);
	}

	private void log(String severity, String message) {
		ApexLog__c log = new ApexLog__c(
			Severity__c = severity,
			Message__c = message
		);
		insert log;
	} 
}