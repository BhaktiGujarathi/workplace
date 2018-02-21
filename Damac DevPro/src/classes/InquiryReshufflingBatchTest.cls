/*
* Name : Pavithra Gajendra
* Date : 02/12/2017
* Purpose : Test class for Inquiry Reshuffling batch which runs to shuffle the assigned PC of the Inquiry For N no reassignment pass
* Company : NSI Gulf
* 
*/
@isTest
private class InquiryReshufflingBatchTest {
    static Inquiry__c inquiryToReshuffle ;   
    static Database.QueryLocator queryLoc;
    static Database.BatchableContext BC; 
    static List<Inquiry__c> inquiryList ; 
    
    /*
    * Scenario 1 : Inquiry older by 1 month & in Active Status
    */
    @isTest static void createOldInquiry() {
         User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc1@damactest.com');
         insert pcUser ;
         inquiryToReshuffle = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,135);
         inquiryToReshuffle.Re_Assignment_Pass_No__c = 4 ; 
         insert inquiryToReshuffle ;
         Test.setCreatedDate(inquiryToReshuffle.Id, DateTime.newInstance(2017,01,12));
         Inquiry__c newInq = [Select Id,OwnerId,Owner.Name,Name,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,LastActivityDate,First_Name__c,Last_Name__c,Preferred_Language__c,Inquiry_Status__c,Inquiry_Source__c,Inquiry_Channel__c,Inquiry_Score__c,Re_Assignment_Pass_No__c,Campaign__c,Property__c FROM Inquiry__c Where Id=:inquiryToReshuffle.Id];
         System.debug('InquiryToReshuffle '+newInq);
         Test.startTest();
         inquiryList = new  List<Inquiry__c>();
         inquiryList.add(newInq);
         invokeBatch(inquiryList);       
         Test.stopTest();
    }
     
     
    /*
    * Scenario 2 : Inquiry older 
     */
    @isTest static void oldInquiriesForTest() {
         Test.startTest();
         //---- HOS users 
         
         //---- DOS users 
        
         //---- PC users 
         Profile p1 = [SELECT Id FROM Profile WHERE Name='Property Consultant'];
         User pcUser1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
            LocaleSidKey='en_US', ProfileId = p1.Id, Languages_Known__c='English;Arabic;Hindi;French',Date_of_Joining__c=Date.today().addDays(-2),
            TimeZoneSidKey='America/Los_Angeles', UserName='pc1@damactest.com');
         insert pcUser1 ;
         
         User pcUser2 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
            LocaleSidKey='en_US', ProfileId = p1.Id, Languages_Known__c='English;Arabic;Hindi;French',Date_of_Joining__c=Date.today().addDays(-2),
            TimeZoneSidKey='America/Los_Angeles', UserName='pc2@damactest.com');         
         insert pcUser2 ;
         User pcUser3 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
            LocaleSidKey='en_US', ProfileId = p1.Id, Languages_Known__c='English;Arabic;Hindi;French;Russian;Chinese',Date_of_Joining__c=Date.today().addDays(-2),
            TimeZoneSidKey='America/Los_Angeles', UserName='pc3@damactest.com');
         insert pcUser3 ;
         try{
         inquiryList = new List<Inquiry__c>();
         for(Integer i=0;i<10;i++){
         	Inquiry__c inq = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,i);
         	inq.Preferred_Language__c = (Math.mod(i,2) ==  0) ? 'English' : 'French';
         	if(i == 4 || i == 6)
         	inq.Preferred_Language__c = 'Russian';
         	inquiryList.add(inq);
         }
         insert inquiryList;
         
         List<Inquiry__c> updateInq = new  List<Inquiry__c>();
         
         for(Inquiry__c eachInquiry : inquiryList){
             if(eachInquiry.Preferred_Language__c == 'English' || eachInquiry.Preferred_Language__c == 'Hindi'){
                 eachInquiry.Re_Assignment_Pass_No__c = 1 ; 
                 eachInquiry.OwnerId = pcUser1.Id ;
             }else if(eachInquiry.Preferred_Language__c == 'French' || eachInquiry.Preferred_Language__c == 'Arabic'){
                 eachInquiry.OwnerId = pcUser2.Id ;
             }else if(eachInquiry.Preferred_Language__c == 'Russian' || eachInquiry.Preferred_Language__c == 'Chinese'){
                 eachInquiry.OwnerId = pcUser3.Id ;
             }else{
                eachInquiry.Re_Assignment_Pass_No__c = 3 ; 
                eachInquiry.OwnerId = pcUser1.Id ; 
                eachInquiry.Inquiry_Status__c = 'Active' ; 
             }
             updateInq.add(eachInquiry);
         }
         update updateInq ;
         System.debug('InquiryToReshuffle '+inquiryList);
         invokeBatch(inquiryList); 
         }catch(exception e){}       
         Test.stopTest();
    }
    
     
     /*
     * Scenario 3 : Inquiry which is Active & has to be reshuffled 
     */
      @isTest static void createActiveInquiry() {
         User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc7@damactest.com');
         insert pcUser ;
         inquiryToReshuffle = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,140);
         inquiryToReshuffle.Re_Assignment_Pass_No__c = 3 ;
         inquiryToReshuffle.Inquiry_Status__c = 'Active' ;
         insert inquiryToReshuffle ;
         Test.setCreatedDate(inquiryToReshuffle.Id, DateTime.newInstance(2017,01,12));
         Inquiry__c newInq = [Select Id,OwnerId,Owner.Name,Name,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,LastActivityDate,First_Name__c,Last_Name__c,Preferred_Language__c,Inquiry_Status__c,Inquiry_Source__c,Inquiry_Channel__c,Inquiry_Score__c,Re_Assignment_Pass_No__c,Campaign__c,Property__c FROM Inquiry__c Where Id=:inquiryToReshuffle.Id];
         System.debug('InquiryToReshuffle '+newInq);
         Test.startTest();
         inquiryList = new  List<Inquiry__c>();
         inquiryList.add(newInq);
         invokeBatch(inquiryList);       
         Test.stopTest();
      }
      
    /*
     * Scenario 4 : Inquiry which is not a lead has to be assigned to DAMAC Queue 
     */
      @isTest static void createNotALeadInquiry() {
         User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc17@damactest.com');
         insert pcUser ;
         inquiryToReshuffle = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,1401);
         inquiryToReshuffle.Re_Assignment_Pass_No__c = 2 ;
         inquiryToReshuffle.Inquiry_Status__c = 'Not a Lead' ;
         insert inquiryToReshuffle ;
         Test.setCreatedDate(inquiryToReshuffle.Id, DateTime.newInstance(2017,01,12));
         Inquiry__c newInq = [Select Id,OwnerId,Owner.Name,Name,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,LastActivityDate,First_Name__c,Last_Name__c,Preferred_Language__c,Inquiry_Status__c,Inquiry_Source__c,Inquiry_Channel__c,Inquiry_Score__c,Re_Assignment_Pass_No__c,Campaign__c,Property__c FROM Inquiry__c Where Id=:inquiryToReshuffle.Id];
         System.debug('InquiryToReshuffle '+newInq);
         Test.startTest();
         inquiryList = new  List<Inquiry__c>();
         inquiryList.add(newInq);
         invokeBatch(inquiryList);       
         Test.stopTest();
      }
     
    /*
     * Scenario 4 : Method to execute Batch 
     */
    static void invokeBatch(List<Inquiry__c> allInquiryList){
         InquiryReshufflingBatch reshuffleBatch = new InquiryReshufflingBatch();
         queryLoc = reshuffleBatch.start(BC);
         reshuffleBatch.execute(BC,allInquiryList);
         reshuffleBatch.finish(BC);
    }
    
    static testmethod void misc_methods(){
        InquiryReshufflingBatch reshuffleBatch = new InquiryReshufflingBatch();
        inquiryToReshuffle = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,140);
        inquiryToReshuffle.Re_Assignment_Pass_No__c = 3 ;
        inquiryToReshuffle.Inquiry_Status__c = 'Active' ;
        insert inquiryToReshuffle ;
        
        task t = new task();
        t.whatid = inquiryToReshuffle.id;
        insert t;
        
        reshuffleBatch.canAddthisInquiry(inquiryToReshuffle,t);
        list<inquiry__c> inqLst = new list<inquiry__c>();
        inqLst.add(inquiryToReshuffle);        
        reshuffleBatch.filterInquiriesforStatus(inqLst);
    }
   
	static testmethod void nurturing_methods(){
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Property Consultant'];
         User pcUser1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
            LocaleSidKey='en_US', ProfileId = p1.Id, Languages_Known__c='English;Arabic;Hindi;French',Date_of_Joining__c=Date.today().addDays(-2),
            TimeZoneSidKey='America/Los_Angeles', UserName='pc1@damactest.com');
         insert pcUser1 ;
         
         User pcUser2 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
            LocaleSidKey='en_US', ProfileId = p1.Id, Languages_Known__c='English;Arabic;Hindi;French',Date_of_Joining__c=Date.today().addDays(-2),
            TimeZoneSidKey='America/Los_Angeles', UserName='pc2@damactest.com');         
         insert pcUser2 ;
         User pcUser3 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
            LocaleSidKey='en_US', ProfileId = p1.Id, Languages_Known__c='English;Arabic;Hindi;French;Russian;Chinese',Date_of_Joining__c=Date.today().addDays(-2),
            TimeZoneSidKey='America/Los_Angeles', UserName='pc3@damactest.com');
         insert pcUser3 ;
         try{
     	Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
     	Campaign__c camp = new Campaign__c();
        camp.RecordTypeId = RSRecordTypeId;
        camp.Campaign_Name__c='Test Campaign';
        camp.start_date__c = System.today();
        camp.end_date__c = System.Today().addDays(30);
        camp.Marketing_start_date__c = System.today();
        camp.Marketing_end_date__c = System.Today().addDays(30);
        insert camp;
         List<Inquiry__c> sinquiryList = new List<Inquiry__c>();
         for(Integer i=0;i<10;i++){
         	Inquiry__c inq = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,i);
         	inq.Preferred_Language__c = (Math.mod(i,2) ==  0) ? 'English' : 'French';
         	if(i == 4 || i == 6)
         	inq.Preferred_Language__c = 'Russian';
         	if( i > 5)
         	inq.campaign__c = camp.id;
         	sinquiryList.add(inq);
         }
         insert sinquiryList;
         
         set<Inquiry__c> updateInq = new  set<Inquiry__c>();
         
         for(Inquiry__c eachInquiry : sinquiryList){
             if(eachInquiry.Preferred_Language__c == 'English' || eachInquiry.Preferred_Language__c == 'Hindi'){
                 eachInquiry.Re_Assignment_Pass_No__c = 1 ; 
                 eachInquiry.OwnerId = pcUser1.Id ;
             }else if(eachInquiry.Preferred_Language__c == 'French' || eachInquiry.Preferred_Language__c == 'Arabic'){
                 eachInquiry.OwnerId = pcUser2.Id ;
             }else if(eachInquiry.Preferred_Language__c == 'Russian' || eachInquiry.Preferred_Language__c == 'Chinese'){
                 eachInquiry.OwnerId = pcUser3.Id ;
             }else{
                eachInquiry.Re_Assignment_Pass_No__c = 3 ; 
                eachInquiry.OwnerId = pcUser1.Id ; 
                eachInquiry.Inquiry_Status__c = 'Active' ; 
             }
             updateInq.add(eachInquiry);
         }
         //update updateInq ;
         InquiryReshufflingBatch obj = new InquiryReshufflingBatch();
         System.debug(InquiryReshufflingBatch.USER_TYPE_OWNER);
         System.debug(InquiryReshufflingBatch.INQUIRY_ACTIVE_STATUS);
         System.debug(InquiryReshufflingBatch.INQUIRY_NEW_STATUS);
         System.debug(InquiryReshufflingBatch.AGENT_REFERAL_SOURCE);
         System.debug(InquiryReshufflingBatch.PROSPECTING_BY_PC_SOURCE);
         System.debug(InquiryReshufflingBatch.BUDGET_CONSTRAINT_STATUS);
         System.debug(InquiryReshufflingBatch.PRODUCT_CONSTRAINT_STATUS);
         System.debug(InquiryReshufflingBatch.NOT_LEAD_STATUS);
         System.debug(InquiryReshufflingBatch.POTENTIAL_AGENT_STATUS);
         System.debug(InquiryReshufflingBatch.UNREACHABLE_NOTRESPONDING_STATUS);
         System.debug(InquiryReshufflingBatch.DAMAC_BUSINESS_HOURS);
         System.debug(InquiryReshufflingBatch.CHATTER_SOURCE);
         obj.reassignInquiriesToPCOrQueue(updateInq,updateInq,updateInq,updateInq,new Map<ID,Inquiry__c>());
         }catch(exception e){}
    }
}