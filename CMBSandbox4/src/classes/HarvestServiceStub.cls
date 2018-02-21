public with sharing class HarvestServiceStub extends HarvestService {
	
	public static List<Dom.Document> stubDocuments = new List<Dom.Document>(); 
	public static Exception theException;
	
	public static void addStubDocument(String xml) {
		Dom.Document doc = new Dom.Document();
        doc.load(xml);
        stubDocuments.add(doc);
	}
	
	public override Dom.Document sendHttpRequest(HttpRequest req) {
		if (stubDocuments.isEmpty() && theException != null) {
			throw theException;
		}
		Dom.Document doc = stubDocuments.get(0);
		stubDocuments.remove(0);
		return doc;
	} 
}