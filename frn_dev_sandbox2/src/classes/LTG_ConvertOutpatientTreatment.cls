/**
* Class LTG_ConvertOutpatientTreatment
*
* Class LTG_ConvertOutpatientTreatment for the LTG_ConvertOutpatientTreatment VF page. This class implements the functionality
* to Convert Outpatient Treatment of lead.
*/
public without sharing class LTG_ConvertOutpatientTreatment
{
    public LTG_ConvertOutpatientTreatment(ApexPages.StandardController controller) {

    }

    String queryStr;
    Id opportunityId;
    public lead newLead;
    
    public LTG_ConvertOutpatientTreatment() {
    }
    
    public PageReference ConvertOutpatientTreatment() {
        PageReference pageRef;
        string currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        newLead = [select id,name,phone,Work_Phone__c,MobilePhone,Caller_First_Name__c, Calling_for__c, FirstName, LastName, Caller_Phone__c, StateCode, City, Caller_Last_Name__c, Relationship_to_Patient__c from Lead where id =: currentRecordId];
        queryStr = 'SELECT name FROM contact WHERE '; 
        if(newLead.Name != null ) { 
            queryStr += 'name =\''+ newLead.Name+'\''; 
        } 
        if(newLead.Phone != null && newLead.Phone != '') { 
            if(newLead.name != null ) { 
                queryStr += ' OR '; 
            } 
            queryStr += ' phone =\''+ newLead.Phone+ '\' OR HomePhone =\''+ newLead.Phone+'\' OR MobilePhone =\'' + newLead.Phone+'\' OR OtherPhone =\''+newLead.Phone+'\' OR Work_Phone__c =\''+ newLead.Phone+'\''; 
        } 
        
        if(newLead.MobilePhone != null && newLead.MobilePhone != '') { 
            if(newLead.Phone != null || newLead.Name != null ) { 
                queryStr += 'OR '; 
            } 
            queryStr += ' phone =\''+newLead.MobilePhone+'\' OR HomePhone =\''+newLead.MobilePhone+'\' OR MobilePhone =\''+newLead.MobilePhone+'\' OR OtherPhone =\''+newLead.MobilePhone+'\' OR Work_Phone__c =\''+newLead.MobilePhone+'\''; 
        } 
        
        if(newLead.Work_Phone__c != null && newLead.Work_Phone__c!= '') { 
            if(newLead.MobilePhone!= null || newLead.Phone!= null || newLead.Name!= null) { 
                queryStr += 'OR '; 
            } 
            queryStr += ' phone =\''+newLead.Work_Phone__c+'\' OR HomePhone =\''+newLead.Work_Phone__c+'\' OR MobilePhone =\''+newLead.Work_Phone__c+'\' OR OtherPhone =\''+newLead.Work_Phone__c+'\' OR Work_Phone__c =\''+newLead.Work_Phone__c+'\''; 
        } 
        
        system.debug('queryStr'+queryStr);
        list<contact> lstContact = new list<contact>();
        lstContact = Database.query(queryStr);       
        system.debug('lstContact '+lstContact );
        
            system.debug('newLead.id'+newLead.id);
            lead objLead = new lead();
            objLead.id = newLead.Id;
            objLead.Opportunity_RecordType__c = 'Outpatient Treatment';
            try{
                update objLead;
                system.debug('objLead'+objLead);
            } catch (Exception e) {
                system.debug('DML failed --- Error'+e);
                return null;
            }
            
            string opportunityId;
            //convertLead objConvertLead = new convertLead();            
            opportunityId = convertLead.convertLeadtoAcc(newLead.Id);
            system.debug('opportunityId'+opportunityId);
            if(opportunityId.startsWith('006')) {
                string str =opportunityId+'';
                system.debug('str '+str);
                if(str.length() == 15 || str.length() == 18)
                
                pageRef= new PageReference('/'+opportunityId);
                system.debug('pageRef'+pageRef);
                pageRef.setRedirect(true);
                return pageRef;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+opportunityId));
                return null;
            }
            
    }
}