@isTest
private class Describe_Sobject_Access_Test {

    static testMethod void myUnitTest() {
        Test.startTest();
        
        Profile[] pcProfile = [ Select id,UserType from Profile where name = 'Property Consultant' LIMIT 1];
        User u1 = new User(Alias = 'standt3', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,LocaleSidKey='en_US', ProfileId = pcProfile[0].Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduserpc@testorg.com');
        
        List<Eidt_Delete_Restrictions_on_sObjects__c> accesslst = new List<Eidt_Delete_Restrictions_on_sObjects__c>();
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#acc',Profile_Name__c='Property Consultant',sObject_Name__c='Account',Edit_Access__c = false,Delete_Access__c = false,Record_Types__c='Corporate Agency'));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#con',Profile_Name__c='Property Consultant',sObject_Name__c='Contact',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#att',Profile_Name__c='Property Consultant',sObject_Name__c='Attachment',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#not',Profile_Name__c='Property Consultant',sObject_Name__c='Note',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#bkg',Profile_Name__c='Property Consultant',sObject_Name__c='booking__c',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#bku',Profile_Name__c='Property Consultant',sObject_Name__c='booking_unit__c',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#buy',Profile_Name__c='Property Consultant',sObject_Name__c='buyer__c',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#gsp',Profile_Name__c='Property Consultant',sObject_Name__c='guided_sales__c',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#srd',Profile_Name__c='Property Consultant',sObject_Name__c='nsibpm__srdoc__c',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#stp',Profile_Name__c='Property Consultant',sObject_Name__c='nsibpm__step__c',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#payp',Profile_Name__c='Property Consultant',sObject_Name__c='payment_plan__c',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#payt',Profile_Name__c='Property Consultant',sObject_Name__c='payment_terms__c',Edit_Access__c = false,Delete_Access__c = false));
        accesslst.add(new Eidt_Delete_Restrictions_on_sObjects__c(Name='property consultant#srq',Profile_Name__c='Property Consultant',sObject_Name__c='servicerequest',Edit_Access__c = false,Delete_Access__c = false));
        insert accesslst;
        
        System.runAs(u1){
            Account acc = InitialiseTestData.getCorporateAccount('testPC');
            insert acc;
            ApexPages.StandardController controller = new ApexPages.StandardController(acc);
            Account_Edit_Delete_Override_Controller accAccess = new Account_Edit_Delete_Override_Controller(controller);
            
            Contact con = InitialiseTestData.getCorporateAgencyContact('contactPortal');
            insert con;
            ApexPages.StandardController cont = new ApexPages.StandardController(con);
            Contact_Edit_Delete_Override_Controller conAccess = new Contact_Edit_Delete_Override_Controller(cont);
            
            ApexPages.StandardController booking = new ApexPages.StandardController(new Booking__c());
            Booking_Edit_Delete_Override_Controller bookingAccess = new Booking_Edit_Delete_Override_Controller(booking);
            
            ApexPages.StandardController bookingUnit = new ApexPages.StandardController(new Booking_Unit__c());
            Booking_unit_Edit_Delete_Override bookingUnitAccess = new Booking_unit_Edit_Delete_Override(bookingUnit);
            
            ApexPages.StandardController buyer = new ApexPages.StandardController(new Buyer__c());
            Buyer_Edit_Delete_Override_Controller buyerAccess = new Buyer_Edit_Delete_Override_Controller(buyer);
            
            ApexPages.StandardController guidedsales = new ApexPages.StandardController(new Guided_Sales__c());
            GuidedSalesEditDeleteOverrideCont guidedsalesAccess = new GuidedSalesEditDeleteOverrideCont(guidedsales);
            
            ApexPages.StandardController srdoc = new ApexPages.StandardController(new nsibpm__sr_doc__c());
            SR_Docs_Edit_Delete_Override_Controller srdocAccess = new SR_Docs_Edit_Delete_Override_Controller(srdoc);
            
            ApexPages.StandardController srstep = new ApexPages.StandardController(new nsibpm__step__c());
            Step_Edit_Delete_Override_Controller srstepAccess = new Step_Edit_Delete_Override_Controller(srstep);
            
            ApexPages.StandardController plan = new ApexPages.StandardController(new payment_plan__c());
            PaymentPlans_Edit_Delete_OverrideControl planAccess = new PaymentPlans_Edit_Delete_OverrideControl(plan);
            
            ApexPages.StandardController term = new ApexPages.StandardController(new payment_terms__c());
            PaymentTerms_Edit_Delete_OverrideControl termAccess = new PaymentTerms_Edit_Delete_OverrideControl(term);
            
            ApexPages.StandardController src = new ApexPages.StandardController(new NSIBPM__Service_Request__c());
            ServiceRequestEditDeleteOverrideControl sr = new ServiceRequestEditDeleteOverrideControl(src);
            Describe_Sobject_Access de = new Describe_Sobject_Access('test','');
            
            Note noterecord = new Note(Title='test',body='test',parentID=acc.id);
            insert noteRecord;
            try{
            update noteRecord;
            delete noteRecord;
            }Catch(exception e){}
        }
        
        Test.stopTest();
    }
}