@isTest
private class HttpCallForOppTier_Test
{
  
  
  static testMethod void testMyWebSvc()
  {
	  id recopp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();
	  Contact con = new Contact(Lastname = 'Test', Legacy_TIER_ID__c ='1234');
	  insert con;
	  Opportunity opt = new Opportunity(Contact__c = con.id,CloseDate =system.today(), stagename = 'Prospecting', Probability = 10.0, name ='opp1',RecordTypeId = recopp);
      insert opt;
	  Patient_Contact__c pc = new Patient_Contact__c(First_Name__c = 'Test', Last_Name__c = 'Test', Opportunity__c = opt.id);
	  
	  insert pc;
	  
	  Patient_Insurance__c pi = new Patient_Insurance__c(Opportunity__c = opt.id, Patient__c = con.id);
	  
	  insert pi;
	  
	  Sent_to_TIER__c stt = new Sent_to_TIER__c(Name = 'Sent to TIER', Endpoint__c = 'http://204.251.184.27:8161/api/message/opportunity.stg?type=queue', Password__c = 'Password__c', Username__c = 'svc_salesforce');
	  insert stt;
	  
	  Task ta = new Task(WhatId = opt.ID, Subject = 'test', status = 'Not Started');
	  insert ta;
	  
      HttpCallForOppTier.callPost( opt.id );
      
      
  }
}