/**

 *  Description -  Test Class for MovingRenewalController
 *
 * Version     Author                      Date                 Description
 * 1.0         Ajay Singh Solanki          03/31/2014           Initial Draft
 *                                                          
 */
 	
@isTest(SeeAlldata=True)
private class MovingRenewalControllerTest {

    //method for testing MovingRenewalController class for save method.
    static testMethod void ManageRenewalSaveTest() {
       //created a single record of account
       Account accRecord = MovingRenewalControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       
       //created list of opportunity record 
       List<Opportunity> oppList = MovingRenewalControllerTest.createOpportunityRecord(10);
       insert oppList; //opportunity list inserted
       
       //created list of contract record
       List<Contract> conList = MovingRenewalControllerTest.createContractRecords(accRecord.Id, oppList);
       insert conList; //contract list inserted
       
       Test.startTest();
        
       //Set ManageRenewal as Current Page
       test.setCurrentPageReference(Page.ManageRenewal);
      
       //created intence of MovingRenewalController class
       MovingRenewalController movingRenewal =   
                 new MovingRenewalController();
                 movingRenewal.RenewalWrapperLst[0].isSelected = true;
                 conlist[0].Current_Balance_Amt__c = 3000;
                 update conlist;
                 movingRenewal.save();
                 system.assertEquals(conList[0].Current_Balance_Amt__c,3000); 
        Test.stopTest();
       
    }
    
    //method for testing MovingRenewalController class for delayFunctionality method.
    static testMethod void ManageRenewalDelayEligibilityTest() {
       //created a single record of account
       Account accRecord = MovingRenewalControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       
       //created list of opportunity record 
       List<Opportunity> oppList = MovingRenewalControllerTest.createOpportunityRecord(10);
       insert oppList; //opportunity list inserted
       
       //created list of contract record
       List<Contract> conList = MovingRenewalControllerTest.createContractRecords(accRecord.Id, oppList);
       for(Contract Con : conList){
           con.Anticipated_Renewal_Date__c = Date.today();
       }
       insert conList; //contract list inserted
       
       Test.startTest();
        
       //Set ManageRenewal as Current Page
       test.setCurrentPageReference(Page.ManageRenewal);
      
       //created instance of MovingRenewalController class
       MovingRenewalController movingRenewal =   
                 new MovingRenewalController();
                 movingRenewal.RenewalWrapperLst[0].isSelected = true;
                 movingRenewal.displayDelayEligibility();
                 movingRenewal.DelayTime = '1';
                 movingRenewal.delayTime();
                 Contract con = [select Id,Anticipated_Renewal_Date__c 
                 				 from Contract 
                 				 where Id =: conList[0].Id];
                 system.assertEquals(conList[0].Anticipated_Renewal_Date__c,con.Anticipated_Renewal_Date__c); 
                 
        movingRenewal.createOpportunities();
        Test.stopTest();
       
    }
    
    //method for testing filter Functionality MovingRenewalController class
    static testMethod void ManageRenewalFilterFunctionalityTest() {
    	 //created a single record of account
       Account accRecord = MovingRenewalControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       
       //created list of opportunity record 
       List<Opportunity> oppList = MovingRenewalControllerTest.createOpportunityRecord(10);
       for(Opportunity opp :oppList){
           opp.AccountId = accRecord.Id;
       }
       insert oppList; //opportunity list inserted
       
       //created list of contract record
       List<Contract> conList = MovingRenewalControllerTest.createContractRecords(accRecord.Id, oppList);
       for(Contract Con : conList){
           con.Renewal_Eligibility_Percent__c = 20;
           con.Current_Balance_Amt__c = 2000;
           con.Current_Balance_Date__c = Date.today();
           con.Anticipated_Renewal_Date__c = Date.today();
       }
       insert conList; //contract list inserted
       
       Test.startTest();
        
       //Set ManageRenewal as Current Page
       test.setCurrentPageReference(Page.ManageRenewal);
      
       //created intence of MovingRenewalController class
       MovingRenewalController movingRenewal =   
                 new MovingRenewalController();
                 movingRenewal.init();
                 movingRenewal.RenewalWrapperLst[0].isSelected = true;
                 movingRenewal.createFollowupTask() ;
                 movingRenewal.getContractsAfterFilter();
        
        movingRenewal.setSortDirection('Desc');
        movingRenewal.sortExpression = 'Name';
        movingRenewal.ViewSortedData_Contract();
        Test.stopTest();
    }//End filterFunctionalityTest method.
    
    //Method will create dummy records of Account
    public static Account createAccountRecords(){
    	
       Account account = new Account(Name = 'Test Account2',
                                          Email__c='testacc@gmail.com',
                                          Phone = '02234557');   
      
        return account;
    }
    
    
    //Method will create dummy records of Contract
    public static List<Contract> createContractRecords(string pAccountId, list<Opportunity> lstOpp){
    	
    	list<Contract> conRecordList = new List<Contract>();
    	for(Integer oppCount = 1; oppCount <=10; oppCount++){
            
            conRecordList.add(new Contract(Name = 'Test Contract1'+ oppCount,Bank__c=pAccountId,
                                          Status='Draft',AccountId=pAccountId, Opportunity__c = lstOpp[oppCount-1].Id
                                           ));
        }//for
        return conRecordList;
    } 
    
    
    //Method will create dummy records of Opportunity 
    public static list<Opportunity> createOpportunityRecord(Integer pCountOfOpportunity){
    
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer intIndex = 0; intIndex < pCountOfOpportunity; intIndex ++){
            
            Opportunity objOpp = new Opportunity();
            objOpp.Name = 'testOpp' + intIndex;
            objOpp.StageName = 'Application Sent';
            objOpp.CloseDate = Date.today();
            objOpp.Funding_Amount__c = 5000;
            objOpp.Payback_Amount__c = 8000;
            
            objOpp.ForecastCategoryName = 'Pipeline';
            oppList.add(objOpp);                       
        }//End for
        return oppList;
    }    
    
    
    //Method will return Record Type Id.
    public Id getBankRecordTypeId(Id pRecordTypeName){
    	Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
		Schema.RecordTypeInfo rtByName =  rtMapByName.get(pRecordTypeName);
		return rtByName.getRecordTypeId();
    }//End returnBankRecordTypeId method.
}