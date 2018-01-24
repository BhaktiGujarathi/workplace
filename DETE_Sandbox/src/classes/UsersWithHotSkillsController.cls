public with sharing class UsersWithHotSkillsController {

    //public SelectOption[] selectedContacts { get; set; }
    public list<String> selectedContacts { get; set; }
    public SelectOption[] allOptions { get; set; }
    public list<contactWrapper> contactWrapperLst {get; set;}
    Map<String, Id> recordTypeMap = new Map<String, Id>();
    Map<String, Technology__c> technologyMap = new Map<String, Technology__c>();
    public String message { get; set; }
    Map<String, Knowledges__c> knowlwdgeMap = new Map<String, Knowledges__c>();
    set<Id> activeContactId = new set<Id>();
    public boolean run{get; set;}
    public UsersWithHotSkillsController() {
    	contactWrapperLst = new list<contactWrapper>();
    	allOptions = new List<SelectOption>();
    	list<RecordType> recordTypelst = [Select r.Name, r.Id From RecordType r];
    	//map of record type name, Id
    	
    	for(RecordType rt: recordTypelst) {
    		recordTypeMap.put(rt.Name, rt.Id);
    	}
    	list<Technology__c> technologyLst = [SELECT Name, Id, RecordTypeId FROM Technology__c order by Name];
    	for(Technology__c tech: technologyLst){
    		allOptions.add(new SelectOption(tech.Name, tech.Name));
    		technologyMap.put(tech.Name, tech);
    	}
    	
    	list<Knowledges__c> knowledgeLst = [Select k.Name, k.Id, k.Element_Name__c From Knowledges__c k order by Name];
    	for(Knowledges__c know: knowledgeLst){
    		allOptions.add(new SelectOption(know.Element_Name__c, know.Element_Name__c));
    		knowlwdgeMap.put(know.Element_Name__c, know);
    	}
    	
        selectedContacts = new list<String>();
        
        list<User> listUser = new list<User>();
        
        listUser = [SELECT Id,
                           ContactId,
                           Username,
                           LastName,
                           FirstName,
                           CommunityNickname
                    FROM User
                    WHERE IsActive =: true
                   ];
        for(User u: listUser) {
        	activeContactId.add(u.ContactId);
        }
    }

    public PageReference save() {
    	contactWrapperLst.clear();
    	system.debug('111111111save'+selectedContacts);
        for ( String so : selectedContacts ) { //.getValue()
        	system.debug('123'+technologyMap.containsKey(so));
        	system.debug('123'+knowlwdgeMap.containsKey(so));
        	if(technologyMap.containsKey(so)){
        		system.debug('123'+technologyMap.get(so).RecordTypeId+'456'+recordTypeMap.get('Hot Skill'));
        		if(technologyMap.get(so).RecordTypeId == recordTypeMap.get('Hot Skill')) {
        			getHotSkills(so);
        		}
        		if(technologyMap.get(so).RecordTypeId == recordTypeMap.get('General Technology')) {
        			getGeneralTechnology(so);
        		}
        		
        	}
        	if(knowlwdgeMap.containsKey(so) ){
        			getKnowledge(so);
        		}
        	system.debug('22222'+contactWrapperLst);
            //message += so.getLabel() + ' (' + so.getValue() + ')';
        }
        run = true;
        return null;       
    }
    public void getHotSkills(String so){
    	list<Contact> contactlst = [select Id, Name, Specific_Technologies__c, Position_Title__c from Contact WHERE id IN: activeContactId];// where Specific_Technologies__c LIKE :so];
    	list<Contact> contactSet = new list<Contact>();
    	for(Contact c: contactlst){
    		if(c.Specific_Technologies__c!= null && c.Specific_Technologies__c.contains(so)) {
    			contactSet.add(c);
    		}
    		
    	}
    	contactWrapperLst.add(new ContactWrapper(contactSet.size(),contactSet, so));
    }
     public void getGeneralTechnology(String so){
    	list<Contact> contactlst1 = [select Id, Name, General_Technologies__c, Position_Title__c from Contact WHERE id IN: activeContactId]; //where Specific_Technologies__c LIKE :so];
    	list<Contact> contactSet1 = new list<Contact>();
    	for(Contact c: contactlst1){
    		if(c.General_Technologies__c!= null && c.General_Technologies__c.contains(so))
    			contactSet1.add(c);
    	}
    	contactWrapperLst.add(new ContactWrapper(contactSet1.size(),contactSet1, so));
    }
    public void getKnowledge(String so){
    	list<Contact> contactlst2 = [select Id, Name, Knowledge__c, Position_Title__c from Contact WHERE id IN: activeContactId]; //where Specific_Technologies__c LIKE :so];
    	list<Contact> contactSet2 = new list<Contact>();
    	for(Contact c: contactlst2){
    		if(c.Knowledge__c!= null && c.Knowledge__c.contains(so))
    			contactSet2.add(c);
    	}
    	contactWrapperLst.add(new ContactWrapper(contactSet2.size(),contactSet2, so));
    }
    
    public class contactWrapper {
    	public Integer uCount {get; set;}
    	public list<Contact> contactList {get; set;}
    	public String selectedStr {get; set;}
    	public contactWrapper(Integer pCount, list<Contact> pContactList, String pSelectedStr){
    		this.uCount = pCount;
    		this.contactList = pContactList;
    		this.selectedStr = pSelectedStr;
    	}
    }
}