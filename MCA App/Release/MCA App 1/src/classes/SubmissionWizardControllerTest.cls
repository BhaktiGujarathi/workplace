/**
 * This class contains unit tests for validating the behavior of SubmissionWizardController
 * 
 *	Date - 12-02-2014
 *
 *	Created By - Sneha P.
 */
@isTest
private class SubmissionWizardControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        //Create Acc
        Account acc = createAccount('TestAcc',0);
        Account Bank1 = createAccount('Bank 1',1);
        Account Bank2 = createAccount('Bank 2',2);
        
        Attachment att = new Attachment(Name = 'Test Doc1', ParentId = acc.Id, Body = Blob.valueOf('Test Attachment') );
        insert att;
        
        Attachment att2 = new Attachment(Name = 'Test Doc2', ParentId = acc.Id, Body = Blob.valueOf('Test Attachment2') );
        insert att2;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName ='Application Missing Info' ,
        								 CloseDate = System.today());
        insert opp;
        
		//Create Prgms
		Program__c pgm1 = new Program__c(Name= 'Test Program',Preffered_Programs__c = true,Credit_Score__c = 20,
										 Years_in_Business__c = 5,Industry__c = 'Government');
		insert pgm1;
		
		Program__c pgm2 = new Program__c(Name= 'Test Program2',Preffered_Programs__c = true,Credit_Score__c = 30,
										 Years_in_Business__c = 3,Industry__c = 'Government');
		insert pgm2;
		
		Program__c pgm3 = new Program__c(Name= 'Test Program3',Preffered_Programs__c = false,Credit_Score__c = 70,
										 Years_in_Business__c = 3,Industry__c = 'Government');
		insert pgm3;
		
		Required_Documents__c reqdDoc = new Required_Documents__c(Name = 'Doc 1',Program__c = pgm1.Id);
		insert reqdDoc;
		
		PageReference pageRef = Page.SubmissionWizard;
        pageRef.getParameters().put('Id', opp.Id);
        pageRef.getParameters().put('accId', acc.Id);
        test.setCurrentPage(pageRef);
		     
		SubmissionWizardController cntl = new SubmissionWizardController();
		
		//Check if 2 programs are displayed
		system.assert(cntl.programWrapperList.size() == 2);
		
		cntl.program.Industry__c = 'Government';
		cntl.program.Credit_Score__c = 20;
		cntl.program.Years_in_Business__c = 5;
		cntl.getPrograms();
		system.assert(cntl.programWrapperList.size() == 1);
		
		//Give the filter as Government, and check if 3 programs are displayed
		cntl.program.Industry__c = 'Government';
		cntl.program.Credit_Score__c = null;
		cntl.program.Years_in_Business__c = null;
		cntl.getPrograms();
		system.assert(cntl.programWrapperList.size() == 3);
		
		//Check if the required documents are shown in popup on click of button
		cntl.checkReqdDocument();
		system.assert(cntl.displayPopup == true);
		// && cntl.prgmDocMap.size() == 1);
        cntl.closePopup();
        
        cntl.getMapSize();
        cntl.resetAttachments();
        cntl.sendAllAttachments();
        
        cntl.AttachmentWrapperList[0].selectedPrograms.add(att.id);
        cntl.AttachmentWrapperList[0].selectedPrograms.add(att2.id);
        
        cntl.sendSelectedAttachments();
        
        cntl.cancel();
    }
    
    public static Account createAccount(String pName,Integer cnt){
    	Account acc = new Account(Name = pName,Email__c = 'test@test.com'+cnt);
        insert acc;
        return acc;
    }
}