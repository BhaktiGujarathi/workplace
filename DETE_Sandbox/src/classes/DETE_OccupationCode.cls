global with sharing class DETE_OccupationCode implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public static final Integer STATUS_CODE = 200;
    public static final String CODE = 'code';
    public static final String TITLE = 'title';
    public static final String DESCRIPTION = 'description';
    public static final String REQUESTRANGE = 'occupations/?sort=name&amp;start=1&amp;end=10000';
    public List<Occupation__c> occupationUpdateLst = new List<Occupation__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, 
                                                Name,
                                                Title__c
                                         FROM Occupation__c
                                         Order BY Title__c Nulls Last
                                         Limit 1110]);
    }
    
    global void execute(Database.BatchableContext batchContext, List<Occupation__c> pOccupationList) {
        // map to hold occupation records from DB
        Map<String, Occupation__c> occupationDBMap = new Map<String, Occupation__c>();
        // list of Occupations from Onet 
        List<Occupation__c> onetOccupationList = new List<Occupation__c>();
        // new instace of http
        HTTP http = new HTTP();
        
        // prepare a map of occupation title and code from scopelist
        for(Occupation__c occupationInstance : pOccupationList){
            if(!occupationDBMap.containsKey(occupationInstance.Title__c)){
                occupationDBMap.put(occupationInstance.Title__c, occupationInstance);
            }
        }
        
        //get http request prepared from Onet service class
        HttpRequest rqstObj = DETE_OnetService.formOnetRequestFormat(REQUESTRANGE);
        if(null <> rqstObj) {
            // send http request
            HttpResponse httpResponse = http.send(rqstObj);
            
            if (httpResponse.getStatusCode() == STATUS_CODE) {
                Dom.Document domObj = new Dom.Document();
                domObj.load(httpResponse.getBody());
                //Retrieve the root element for this document 
                Dom.XMLNode nodeObj = domObj.getRootElement();
                onetOccupationList = parseXMLResponse(nodeObj);
                occupationUpdateLst = verifyForOccupationCodeChange(onetOccupationList, occupationDBMap);
                
                try{
                   Database.upsert(occupationUpdateLst, Occupation__c.Title__c, false);
                }
                catch(exception exObj) {
                    system.debug('>>> exobj : '+exObj.getMessage());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext batchContext) {
        
    }
    public static List<Occupation__c> parseXMLResponse(DOM.XMLNode nodeObj) {
        List<Occupation__c> onetOccupationObjLst = new List<Occupation__c>();
        
        dom.XmlNode [] childNodes = nodeObj.getchildelements() ;
        for(Dom.XMLNode child : childNodes) { //Loop Through Records
            Occupation__c onetOccupationObj = new Occupation__c();
            for (dom.XmlNode childNodeRecords : child.getchildren() ) {
	             if (childNodeRecords.getname() == CODE) {
	                 onetOccupationObj.Name = childNodeRecords.gettext();
	             }
	             if (childNodeRecords.getname() == TITLE) {
	                   onetOccupationObj.Title__c = childNodeRecords.gettext();
	             }
             }
             onetOccupationObjLst.add(onetOccupationObj);
        }
        return onetOccupationObjLst;
    }
    
    public List<Occupation__c> verifyForOccupationCodeChange(List<Occupation__c> pOnetOccupationList, Map<String, Occupation__c> pOccupationDBMap) {
        for(Occupation__c occupationInstance : pOnetOccupationList) {
            if(pOccupationDBMap.containsKey(occupationInstance.Title__c)){
                if(occupationInstance.Name != pOccupationDBMap.get(occupationInstance.Title__c).Name){
                    occupationUpdateLst.add(occupationInstance);
                }
            }
        }
        return occupationUpdateLst;
    }
}