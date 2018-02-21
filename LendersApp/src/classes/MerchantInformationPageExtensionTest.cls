/*
*  Test class for MerchantInformationPage Page
*
*  Revision History:
*  Version        Author                       Date                Description
*  1.0            Ashwini Singh                Jan/2016             Initial Draft       
*/

@isTest
public class MerchantInformationPageExtensionTest {

    @isTest
    public static void testParse() {
        
        DataMerchAPIDetail__c configVar = DataMerchAPIDetail__c.getInstance('Data Merch Detail');
        DataMerchAPIDetail__c  custSetting = new DataMerchAPIDetail__c();
        custSetting.Name = 'Data Merch Detail';
        custSetting.UserName__c = '_yCxMqPDzNxMRurN1M8Z';
        custSetting.Password__c = 'PN3QxCoEzg';
        insert custSetting;
       
        Account aObj = new Account();
        aObj.Name = 'Test';
        Insert aObj;

        Opportunity oppObj = new Opportunity ();
        oppObj.Name = 'Test Opportunity';
        oppObj.StageName = 'Prospecting';
        oppObj.Accountid = aObj.Id;
        oppObj.CloseDate = System.today(); 
        insert oppObj;
        
        Test.setCurrentPageReference(new PageReference('Page.MerchantInformationPage'));
        System.currentPageReference().getParameters().put('feinid', '3456789');
        System.currentPageReference().getParameters().put('source', oppObj.Id);
        System.currentPageReference().getParameters().put('RelatedAccount', aObj.Id);
        
        
        test.startTest(); 

        ApexPages.StandardController sc = new ApexPages.StandardController(oppObj);
        MerchantInformationPageExtension mipObj = new MerchantInformationPageExtension(sc);
        Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator());
        mipObj.callFromPage();
        mipObj.returnToOpportunity(); 
        
        test.stopTest(); 
    }
    
        @isTest
    public static void testWrongCreditials() {
        
        DataMerchAPIDetail__c configVar = DataMerchAPIDetail__c.getInstance('Data Merch Detail');
        DataMerchAPIDetail__c  custSetting = new DataMerchAPIDetail__c();
        custSetting.Name = 'Data Merch Detail';
        custSetting.UserName__c = '_yCxMqPDzNxMRurN1M8Z';
        custSetting.Password__c = 'PN3QxCoEzg1';
        insert custSetting;
       
        Account aObj = new Account();
        aObj.Name = 'Test';
        Insert aObj;

        Opportunity oppObj = new Opportunity ();
        oppObj.Name = 'Test Opportunity';
        oppObj.StageName = 'Prospecting';
        oppObj.Accountid = aObj.Id;
        oppObj.CloseDate = System.today(); 
        insert oppObj;
        
        Test.setCurrentPageReference(new PageReference('Page.MerchantInformationPage'));
        System.currentPageReference().getParameters().put('feinid', '3456789');
        System.currentPageReference().getParameters().put('source', oppObj.Id);
        System.currentPageReference().getParameters().put('RelatedAccount', aObj.Id);
        
        
        test.startTest(); 

        ApexPages.StandardController sc = new ApexPages.StandardController(oppObj);
        MerchantInformationPageExtension mipObj = new MerchantInformationPageExtension(sc);
        Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator());
        mipObj.callFromPage();
        mipObj.returnToOpportunity(); 
        
        test.stopTest(); 
    }
    
    @isTest
    public static void testWrapper() {
        
        Account aObj = new Account();
        aObj.Name = 'Test';
        Insert aObj;
        
        Opportunity oppObj = new Opportunity ();
        oppObj.Name = 'Test Opportunity';
        oppObj.StageName = 'Prospecting';
        oppObj.Accountid = aObj.Id;
        oppObj.CloseDate = System.today(); 
        insert oppObj;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppObj);
        MerchantInformationPageExtension mipObj = new MerchantInformationPageExtension(sc);
        MerchantInformationPageExtension.Note2 note2Instance = new MerchantInformationPageExtension.Note2();
        
        note2Instance.category = 'Slow Pay';
        note2Instance.note = 'he pays in small';
        note2Instance.created_at = 'testCreation';
        
        MerchantInformationPageExtension.Note noteInstance = new MerchantInformationPageExtension.Note();
        noteInstance.note  = note2Instance;
        
        MerchantInformationPageExtension.Merchant merchantInstance = new MerchantInformationPageExtension.Merchant();
        merchantInstance.fein = '12-3456789';
        merchantInstance.legal_name = '';
        merchantInstance.dba = 'test Lagal Name';
        merchantInstance.address = 'test address';
        merchantInstance.street1 = 'test Street1';
        merchantInstance.street2 = 'test street2';
        merchantInstance.city = 'test city';
        merchantInstance.state = 'test state';
        merchantInstance.business_phone = '9876543210';
        merchantInstance.business_startdate = '01/01/2015';
        merchantInstance.industry = 'test Industry';
        merchantInstance.notes = new List<MerchantInformationPageExtension.Note>();
        
        MerchantInformationPageExtension.outerWrapper outerWrapperInstance = new MerchantInformationPageExtension.outerWrapper();
        outerWrapperInstance.Merchant = merchantInstance;
    }
    
}