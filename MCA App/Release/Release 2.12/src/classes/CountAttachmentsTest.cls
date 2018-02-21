/*
 * Test Class for CountAttachmentTrigger
 *  Created by - Sneha p.
 */
@isTest
private class CountAttachmentsTest {
	
	static testmethod void testCountAttachment() {
		
		Account acc = new Account(Name = 'Test Acc');
		insert acc;
		
		// Create Opportunity
		Opportunity opp = new Opportunity(Name = 'Test Opportunity' , AccountId = acc.Id, StageName= 'Prospecting',
									      CloseDate = system.today() ,CountAttachment__c = 0);
		insert opp;
		
		list<Attachment> lstAttachment = createAttachment(14,opp.Id);
		insert lstAttachment;
		
		test.startTest();
			
			opp = [Select Id,Name,CountAttachment__c from Opportunity where Id =: opp.Id];
			//Check if all the attachment count is reflected on Opportunity
			system.assert(opp.CountAttachment__c == 14);
			
			//Delete 1 attachment and check the count
			delete  lstAttachment[0];
			opp = [Select Id,Name,CountAttachment__c from Opportunity where Id =: opp.Id];
			system.assert(opp.CountAttachment__c == 13);
			
		test.stopTest();
	}
	
	public static list<Attachment> createAttachment(Integer pCount, Id pOppId){
        list<Attachment> lstAttachment = new list<Attachment>();
        
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        
        for(Integer index = 1; index <= pCount; index++){
            lstAttachment.add(new Attachment( Name='Unit Test Attachment'+ index,
		    								  body = bodyBlob,
        									  parentId = pOppId));
        }//End for.
        return lstAttachment;
    }//End createAttachment
}