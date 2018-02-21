public class DependencyManager {
	
	public static Boolean TestMode = false;
	
	public static HarvestService getHarvestService(String username, String password, String baseUrl) {
		HarvestService svc = null;
		if (!TestMode) {
			svc = new HarvestServiceRest(username, password, baseUrl);
		}
		else {
			svc = new HarvestServiceStub();
		}
		return svc;
	}
	
	public static HarvestIntegration getHarvestIntegration(Boolean deferPrefetch) {
		HarvestIntegration integration = null;
		if (!TestMode) {
			integration = new HarvestIntegrationImpl(deferPrefetch);
		}
		else {
			integration = new HarvestIntegrationStub();
		}
		return integration;
	}

	public static Logger getLogger() {
		return new LoggerImpl();
	}
}