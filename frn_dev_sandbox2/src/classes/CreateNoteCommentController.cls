public class CreateNoteCommentController {

    public Opportunity opp;
    public Case caseObj;
    public Quote QuoteObj;
    public Lead LeadObj;
    public Insurance_Benefit__c InsuranceBenefitsObj;
    public Pay_Agreement_Worksheet__c PayAgreWorksheetObj;
    public String patientNAME {get;set;}
    public Date patientDOB {get;set;}

    public list<SelectOption> selectedGroup { get; set; }
    public list<SelectOption> selecteduser { get; set; }
    public list<SelectOption> allGroup { get; set; }
    public list<SelectOption> allUser { get; set; }
    public list<SelectOption> allTypes { get; set; }
    public String selectedType {get;set;}   
    public List<String> AlphaList {get; set;}
    public String searchUser {get;set;}
    public String searchGroup {get;set;}
    public Note_Comment__c noteComment {get;set;}
    public List<User> userLst;
    public List<Group> groupLst;
    public Map<String,string> userEmailMap; 
    public List<RecordType> rcList;
    public String currentObjId = ''; 
    public String opptyPfx = ''; 
    public String casePfx = ''; 
    public String QuotePfx = ''; 
    public String LeadPfx = ''; 
    public String InsuranceBenefitsPfx = ''; 
    public String PayAgreWorksheetPfx = ''; 
    public Id patientId {get;set;}
	   
    public CreateNoteCommentController(){
        patientId = null;
        patientDOB = null;
        patientNAME = '';
        currentObjId = ApexPages.currentPage().getParameters().get('Id');
        opptyPfx = Opportunity.sObjectType.getDescribe().getKeyPrefix();        
        casePfx = Case.sObjectType.getDescribe().getKeyPrefix();        
        QuotePfx = Quote.sObjectType.getDescribe().getKeyPrefix();      
        LeadPfx = Lead.sObjectType.getDescribe().getKeyPrefix();        
        InsuranceBenefitsPfx = Insurance_Benefit__c.sObjectType.getDescribe().getKeyPrefix();        
        PayAgreWorksheetPfx = Pay_Agreement_Worksheet__c.sObjectType.getDescribe().getKeyPrefix();
        
        System.debug('currentObjId... '+currentObjId);
        AlphaList = new list<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'ALL'};
        noteComment = new Note_Comment__c();
        userEmailMap = new Map<String,string>();
        allGroup = new List<SelectOption>();
        allUser = new List<SelectOption>();
        selecteduser = new List<SelectOption>();
        selectedGroup = new List<SelectOption>();
        allTypes = new List<SelectOption>();

		/*** CurrentObj = Opportunity */        
        if(currentObjId.startsWith(opptyPfx)){
            opp = [SELECT Id,Name,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Birthdate,Contact__c FROM Opportunity WHERE Id =: currentObjId];
                if(opp.Contact__c != null){
                    patientId = opp.Contact__c;
                    patientNAME = '';
                    if(opp.Contact__r.FirstName != null){
                        patientNAME =   opp.Contact__r.FirstName+' '+opp.Contact__r.LastName.substring(0,1);
                    }else{
                         patientNAME = opp.Contact__r.LastName.substring(0,1); 
                    }
                   
                    patientDOB = opp.Contact__r.Birthdate;              
                }
                
		/*** CurrentObj = Case */               
        } else if(currentObjId.startsWith(casePfx)){
			caseObj = [SELECT Id, Contact.Name, Contact.LastName,Contact.FirstName,Contact.Birthdate, ContactId FROM Case WHERE Id =: currentObjId];
			if(caseObj.ContactId != null){
				patientId = caseObj.ContactId; 
				patientNAME = '';
					if(caseObj.Contact.FirstName != null){
						patientNAME =   caseObj.Contact.FirstName+' '+caseObj.Contact.LastName.substring(0,1);
					}else{
						 patientNAME = caseObj.Contact.LastName.substring(0,1); 
					} 
				patientDOB = caseObj.Contact.Birthdate;                         
			}
                    
		/*** CurrentObj = Quote */              
        } else if(currentObjId.startsWith(QuotePfx)){
			QuoteObj = [SELECT Id, Opportunity.Contact__r.Name,Opportunity.Contact__r.FirstName,Opportunity.Contact__r.LastName, Opportunity.Contact__r.Birthdate, Opportunity.Contact__c FROM Quote WHERE Id =: currentObjId];
			if(QuoteObj.Opportunity.Contact__c != null){
				patientId = QuoteObj.Opportunity.Contact__c;   
				patientNAME = '';
					if(QuoteObj.Opportunity.Contact__r.FirstName != null){
						patientNAME =   QuoteObj.Opportunity.Contact__r.FirstName+' '+QuoteObj.Opportunity.Contact__r.LastName.substring(0,1);
					}else{
						 patientNAME = QuoteObj.Opportunity.Contact__r.LastName.substring(0,1); 
					} 
				
				patientDOB = QuoteObj.Opportunity.Contact__r.Birthdate;                         
			}
                    
		/*** CurrentObj = Lead */                       
        } else if(currentObjId.startsWith(LeadPfx)){
                    LeadObj = [SELECT Id, Birthdate__c, FirstName, LastName, Name,IsConverted FROM Lead WHERE Id =: currentObjId]; 
                         
                        patientNAME = '';
                            if(LeadObj.FirstName != null && LeadObj.IsConverted == false){
                                patientNAME =   LeadObj.FirstName+' '+LeadObj.LastName.substring(0,1);
                            }else{
                                 patientNAME = LeadObj.LastName.substring(0,1); 
                            }                       
                        if(LeadObj.Birthdate__c != null && LeadObj.IsConverted == false)
                            patientDOB = LeadObj.Birthdate__c;  
		
		/*** CurrentObj = Insurance_Benefit */
        }  else if(currentObjId.startsWith(InsuranceBenefitsPfx)){
                    InsuranceBenefitsObj = [SELECT Id, Patient_Insurance__r.Opportunity__r.Contact__r.FirstName, Patient_Insurance__r.Opportunity__r.Contact__r.LastName, Patient_Insurance__r.Opportunity__r.Contact__r.Birthdate, Patient_Insurance__r.Opportunity__r.Contact__c FROM Insurance_Benefit__c WHERE Id =: currentObjId]; 
                        patientId = InsuranceBenefitsObj.Patient_Insurance__r.Opportunity__r.Contact__c; 
                        patientNAME = '';
                            if(InsuranceBenefitsObj.Patient_Insurance__r.Opportunity__r.Contact__r.FirstName != null){
                                patientNAME =   InsuranceBenefitsObj.Patient_Insurance__r.Opportunity__r.Contact__r.FirstName+' '+InsuranceBenefitsObj.Patient_Insurance__r.Opportunity__r.Contact__r.LastName.substring(0,1);
                            }else{
                                 patientNAME = InsuranceBenefitsObj.Patient_Insurance__r.Opportunity__r.Contact__r.LastName.substring(0,1); 
                            }                       
                        if(InsuranceBenefitsObj.Patient_Insurance__r.Opportunity__r.Contact__r.Birthdate != null)
                            patientDOB = InsuranceBenefitsObj.Patient_Insurance__r.Opportunity__r.Contact__r.Birthdate;      

		/*** CurrentObj = Pay_Agreement_Worksheet */						
        } else if(currentObjId.startsWith(PayAgreWorksheetPfx)){
                    PayAgreWorksheetObj = [SELECT Id, Patient_Insurance__r.Opportunity__r.Contact__r.FirstName, Patient_Insurance__r.Opportunity__r.Contact__r.LastName, Patient_Insurance__r.Opportunity__r.Contact__r.Birthdate,Patient_Insurance__r.Opportunity__r.Contact__c FROM Pay_Agreement_Worksheet__c WHERE Id =: currentObjId]; 
                        patientId = PayAgreWorksheetObj.Patient_Insurance__r.Opportunity__r.Contact__c; 
                        patientNAME = '';
                            if(PayAgreWorksheetObj.Patient_Insurance__r.Opportunity__r.Contact__r.FirstName != null){
                                patientNAME =   PayAgreWorksheetObj.Patient_Insurance__r.Opportunity__r.Contact__r.FirstName+' '+PayAgreWorksheetObj.Patient_Insurance__r.Opportunity__r.Contact__r.LastName.substring(0,1);
                            }else{
                                 patientNAME = PayAgreWorksheetObj.Patient_Insurance__r.Opportunity__r.Contact__r.LastName.substring(0,1); 
                            }                       
                        if(PayAgreWorksheetObj.Patient_Insurance__r.Opportunity__r.Contact__r.Birthdate != null)
                            patientDOB = PayAgreWorksheetObj.Patient_Insurance__r.Opportunity__r.Contact__r.Birthdate;          
        }   
		SET<Id> prId = new Set<Id>();
		for (profile pr : [SELECT id,Name ,UserType FROM profile WHERE UserType = 'Standard']) {
				 System.debug('pr>>>>>>>>>>>>>>>>>>>>>>> '+pr);
                prId.add(pr.Id);
        }
        userLst = [SELECT id,Name,Email FROM User WHERE isActive =: true  and ProfileId in: prId ORDER BY Name ASC];
        if(userLst.size()>0){
            for (User eachUser : userLst) {
                allUser.add(new SelectOption(eachUser.Email, eachUser.Name));
            }
        }

        for(User u : userLst){
            userEmailMap.put(u.Id, u.Email); 
        }

        groupLst = [SELECT Id,Name FROM Group]; 
        if(groupLst.size()>0){
            for (Group eachGroup : groupLst) {
                if(eachGroup.Id!=null && eachGroup.Name!=null){
                    allGroup.add(new SelectOption(eachGroup.Id, eachGroup.Name));
                }
            }
        }

        rcList = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Note_Comment__c'];
        for(RecordType eachRecordType : rcList){
            allTypes.add(new SelectOption(eachRecordType.Id , eachRecordType.Name));    
        }        
    }
        
    
    public void sortGroup(){
        allGroup.clear();
        String searchLetter = searchGroup+'%';
        if(searchGroup != 'ALL'){
            for (Group eachGroup : [SELECT Id,Name FROM Group WHERE Name LIKE : searchLetter]) {
                if(eachGroup.Id!=null && eachGroup.Name!=null){
                    allGroup.add(new SelectOption(eachGroup.Id, eachGroup.Name));
                }
            } 
        } else {
            for (Group eachGroup : [SELECT Id,Name FROM Group]) {
                if(eachGroup.Id!=null && eachGroup.Name!=null){
                    allGroup.add(new SelectOption(eachGroup.Id, eachGroup.Name));
                }
            }   
        } 
    }

    public void sortUser(){
		SET<Id> pId = new Set<Id>();
		for (profile pr : [SELECT id,Name ,UserType FROM profile WHERE UserType = 'Standard']) {
				 System.debug('pr>>>>>>>>>>>>>>>>>>>>>>> '+pr);
                pId.add(pr.Id);
        }
		System.debug('pId>>>>>>>>>>>>>>>>>>>>>>> '+pId);
        allUser.clear();
        String searchLetter = searchUser+'%';
        if(searchUser != 'ALL'){
            for (User eachUser : [SELECT id,Name,Email FROM User WHERE isActive =: true and ProfileId in: pId and Name LIKE : searchLetter ORDER BY Name ASC]) {
				 System.debug('eachUser>>>>>>>>>>>>>>>>>>>>>>> '+eachUser);
                allUser.add(new SelectOption(eachUser.Email, eachUser.Name));
            }
        } else {
            for (User eachUser : [SELECT id,Name,Email FROM User WHERE isActive =: true and ProfileId in: pId ORDER BY Name ASC]) {
                allUser.add(new SelectOption(eachUser.Email, eachUser.Name));
            }
        }
    }

    public PageReference save() {
        System.debug('patientNAME________ '+patientNAME+'patientDOB________ '+patientDOB+'patientId________ '+patientId);     
		/***Selected RecordtypeId of Note/Comment */
        String rcName = '';
        for(RecordType eachRC : rcList){
            if(eachRC.Id == selectedType){
                rcName = eachRC.Name;
            }
        }
        noteComment.recordtypeid =  selectedType;
        
		/***CurrentObj = Opportunity */
        if(currentObjId.startsWith(opptyPfx)){
            noteComment.opportunity__c = opp.Id;                
        }       
		/***CurrentObj = Case */        
        if(currentObjId.startsWith(casePfx)){
            noteComment.Case__c = caseObj.Id;               
        }        
		/***CurrentObj = Quote */       
        if(currentObjId.startsWith(QuotePfx)){
            noteComment.Estimates_of_Treatment_Costs__c = QuoteObj.Id;  
        }
		/*** CurrentObj = Lead */                       
        if(currentObjId.startsWith(LeadPfx)){
            if(LeadObj.IsConverted == false){
            noteComment.Lead__c = LeadObj.Id;
			if(patientDOB != null)
				noteComment.Patient_Birthdate__c = patientDOB;
            } else {
                noteComment.addError('Lead is converted hence can not be referenced.');
            } 
        }
		/*** CurrentObj = Insurance_Benefit */		
		if(currentObjId.startsWith(InsuranceBenefitsPfx)){
            noteComment.Insurance_Benefit__c = InsuranceBenefitsObj.Id;
        } 
		/*** CurrentObj = Pay_Agreement_Worksheet */			
		if(currentObjId.startsWith(PayAgreWorksheetPfx)){
            noteComment.Pay_Agreement_Worksheet__c = PayAgreWorksheetObj.Id;
        } 
        if(patientId != null){
            noteComment.Patient__c = patientId;
			noteComment.Patient_Birthdate__c = patientDOB;  				        
        }      
        

        SET<String> listOfEmailRecievers = new Set<String>();
        List<String> selectedGroupList = new List<String>();
		String emailTo = '';
		
		for (SelectOption so1 : selectedGroup) {
            selectedGroupList.add(so1.getValue());
			if(emailTo=='')
				emailTo = so1.getLabel();
			else
				emailTo = emailTo+'; '+so1.getLabel();
			System.debug('emailTo ::>'+emailTo);
			
        }
		
        for (SelectOption so : selecteduser) {
            listOfEmailRecievers.add(so.getValue());
			if(emailTo=='')
				emailTo = so.getLabel();
			else
				emailTo = emailTo+'; '+so.getLabel();
			System.debug('emailTo ::>'+emailTo);
        }
        
		noteComment.Email_To__c = emailTo;
		
		List<GroupMember> gmList = [SELECT GroupId,UserOrGroupId FROM GroupMember WHERE GroupId IN : selectedGroupList];
        for(GroupMember eachMember : gmList){
            if(String.valueof(eachMember.UserOrGroupId).substring(0,3) == User.sobjecttype.getDescribe().getKeyPrefix()){
                listOfEmailRecievers.add(userEmailMap.get(eachMember.UserOrGroupId));
            }
        } 

        List<String> toAddress = new List<String>();
		for(String s : listOfEmailRecievers){
			toAddress.add(s);
		}
		
		if(toAddress.size()==0){
            noteComment = new Note_Comment__c();
            listOfEmailRecievers = new Set<String>();
            toAddress = new List<String>();
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select a User.');
            ApexPages.addMessage(errMsg);  
            return null;     
        } 
		insert noteComment;	
		
		System.debug('noteComment___________________________ '+noteComment);
		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        String urlLink = baseUrl+'/'+noteComment.Id;	
                  
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        
        if(patientNAME != '' && patientNAME != null){
            mail.setSubject('New ' + rcName + ' for '+ patientNAME);          
        }
        if(noteComment.Note_Comment__c==null)
			noteComment.Note_Comment__c = '';
		
        mail.setHtmlBody('<p>'+noteComment.Note_Comment__c+'</p><p>Click here to see note in Salesforce or to reply <a href="'+urlLink+'">'+urlLink+'</a></p>');
		
		  
			
         System.debug('toAddress___________________________ '+toAddress.size());     
        if(toAddress.size()>0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            PageReference pr = new PageReference('/'+currentObjId);
            return pr;          
        } else{
            noteComment = new Note_Comment__c();
            listOfEmailRecievers = new Set<String>();
            toAddress = new List<String>();
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select a User.');
            ApexPages.addMessage(errMsg);  
            return null;     
        } 
    
    }

    public PageReference cancel() {
        PageReference pr = new PageReference('/'+currentObjId);
        return pr;       
    }

}