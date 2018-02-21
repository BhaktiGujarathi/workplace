public abstract class HarvestService {
	
	protected String username;
	protected String password;
	protected  String baseUrl;
	private static final Integer MAX_TIMECARD_QUERIES = 5;
	private static final Integer NUM_YEARS_OF_TIME_ENTRIES = 5;
	private Map<Integer, String> tasks;
	private Map<Integer, String> people;
	private Map<String, String> projectIdMap; 
	
	
	private Dom.Document makeHttpRequest(String path, String httpMethod) {
		HttpRequest req = new HttpRequest();
		req.setEndpoint(baseUrl + path);
		req.setMethod(httpMethod);
		Blob headerValue = Blob.valueOf(username + ':' + password); 
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
		req.setHeader('Authorization', authorizationHeader);
		req.setHeader('Content-Type', 'application/xml');
		req.setHeader('Accept', 'application/xml');
		if (httpMethod == 'PUT') {
			req.setBody('');
		}
		Dom.Document doc = sendHttpRequest(req);
		return doc;	
	}
	
	protected abstract Dom.Document sendHttpRequest(HttpRequest req);
	
	public void populateTasks() {
		if (tasks == null) {
			tasks = new Map<Integer, String>();
			HttpRequest req = new HttpRequest();
			String path = '/tasks';
			Dom.Document doc = makeHttpRequest(path, 'GET');
			Dom.XMLNode nodes = doc.getRootElement();
			for (Dom.Xmlnode node : nodes.getChildElements()) {
				tasks.put(Integer.valueOf(node.getChildElement('id', null).getText()),
					node.getChildElement('name', null).getText());
			}
		}
	}
	
	public void populatePeople() {
		if (people == null) {
			people = new Map<Integer, String>();
			HttpRequest req = new HttpRequest();
			String path = '/people';
			Dom.Document doc = makeHttpRequest(path, 'GET');
			Dom.XMLNode nodes = doc.getRootElement();
			for (Dom.Xmlnode node : nodes.getChildElements()) {
				String name = node.getChildElement('first-name', null).getText();
				name += ' ' + node.getChildElement('last-name', null).getText();
				people.put(Integer.valueOf(node.getChildElement('id', null).getText()),
					name);
			}
		}
	} 
	
	public void populateProjectIdMap() {
		projectIdMap = new Map<String, String>();
		String path = '/projects/';
		Dom.Document doc = makeHttpRequest(path, 'GET');
		Dom.XMLNode nodes = doc.getRootElement();
		for (Dom.Xmlnode node : nodes.getChildElements()) {
			String code = node.getChildElement('code', null).getText();
			if (code != null && code.length() > 0) {
				projectIdMap.put(code, node.getChildElement('id', null).getText());
			}
		}
	}
	
	public List<HarvestEntry> getEntriesForProject(String projectCode) {
		List<HarvestEntry> entries = new List<HarvestEntry>();
		String harvestProjectId = projectIdMap.get(projectCode);
		if (harvestProjectId == null) {
			throw new HarvestException(HarvestException.EXCEPTION_HARVEST_PROJECT_NOT_FOUND 
				+ ' - No project found in Harvest with code: ' 
				+ projectCode);
		}
		String path = '/projects/' + harvestProjectId + '/entries?from=' 
			+ formatDate(Date.today().addYears(-1 * NUM_YEARS_OF_TIME_ENTRIES)) + '&to=' 
			+ formatDate(Date.today());
		Dom.Document doc = makeHttpRequest(path, 'GET');
		entries = getEntriesFromDocument(doc, tasks, people);
		return entries;
	}
	
	private List<HarvestEntry> getEntriesFromDocument(Dom.Document doc, Map<Integer, String> tasks,
			Map<Integer, String> people) {
		List<HarvestEntry> entries = new List<HarvestEntry>();
		Dom.XMLNode dayEntries = doc.getRootElement();
		for (Dom.XMLNode node : dayEntries.getChildElements()) {
			HarvestEntry entry = new HarvestEntry();
			entry.Id = Integer.valueOf(node.getChildElement('id', null).getText());
			Integer projectId = Integer.valueOf(node.getChildElement('project-id', null).getText());
			//entry.ProjectCode = project.Name;
			Integer taskId = Integer.valueOf(node.getChildElement('task-id', null).getText());
			entry.Task = tasks.get(taskId); 
			Integer personId = Integer.valueOf(node.getChildElement('user-id', null).getText());
			entry.Person = people.get(personId);
			entry.Hours = Double.valueOf(node.getChildElement('hours', null).getText());
			entry.SpentAt = Date.valueOf(node.getChildElement('spent-at', null).getText());
			entry.Notes = node.getChildElement('notes', null).getText();
			entry.IsClosed = node.getChildElement('is-closed', null).getText() == 'true';
			entry.IsBilled = node.getChildElement('is-billed', null).getText() == 'true';
			entries.add(entry);
		}
		return entries;
	}

	public String getHarvestProjectId(String projectCode) {
		String projectId = null;
		String path = '/projects/';
		Dom.Document doc = makeHttpRequest(path, 'GET');
		Dom.XMLNode nodes = doc.getRootElement();
		for (Dom.Xmlnode node : nodes.getChildElements()) {
			if (node.getChildElement('code', null).getText() == projectCode) {
				projectId = node.getChildElement('id', null).getText();
				break;
			}
		}
		return projectId;
	}
	
	public void activateProject(String id) {
		HarvestProject project = getProject(id);
		System.debug(project);
		if (!project.Active) {
			makeHttpRequest('/projects/' + id + '/toggle', 'PUT');
		}
	}
	
	public void deactivateProject(String id) {
		HarvestProject project = getProject(id);
		if (project.Active) {
			makeHttpRequest('/projects/' + id + '/toggle', 'PUT');
		}
	}
	
	public HarvestProject getProject(String id) {
		String projectId = null;
		String path = '/projects/' + id;
		Dom.Document doc = makeHttpRequest(path, 'GET');
		Dom.XMLNode root = doc.getRootElement();
		HarvestProject project = projectFromXmlNode(root);
		return project;		
	}
	
	private HarvestProject projectFromXmlNode(Dom.XMLNode node) {
		HarvestProject project = new HarvestProject();
		project.Active = getChildElementTextLowerCase(node, 'active') == 'true';
		project.Code = getChildElementTextLowerCase(node, 'code');
		project.Id = Integer.valueOf(getChildElementTextLowerCase(node, 'id'));
		project.Name = getChildElementTextLowerCase(node, 'name');
		return project;
	}
	
	private String getChildElementTextLowerCase(Dom.XMLNode node, String name) {
		String text = '';
		Dom.XMLNode element = node.getChildElement(name, null);
		if (element != null) {
			if (element.getText() != null) {
				text = element.getText().toLowerCase();
			}
		}
		return text;
	}

	private String formatDate(Date d) {
		String formatted = '' + d.year();
		String month = '0' + d.month();
		month = month.substring(month.length() - 2);
		formatted += month;
		String day = '0' + d.day();
		day = day.substring(day.length() - 2);
		formatted += day;
		return formatted;
	}
}