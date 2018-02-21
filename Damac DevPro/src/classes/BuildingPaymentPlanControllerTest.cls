@isTest 
private class BuildingPaymentPlanControllerTest {

@isTest static void Test1() {
    
    /*
    Location__c bld = InitialiseTestData.getLocationDetails('2','building');    
    bld.Location_Id__c='2';
    insert bld;
    Location__c flr = new Location__c();
    flr.Location_Type__c='Floor';
    flr.Location_ID__c='21';
    insert flr;
    Location__c unit= InitialiseTestData.getLocationDetails('10','Unit');
    unit.Location_Type__c='Unit';
    insert unit;
    */
    //Payment_Plan__c pp= InitialiseTestData.getPaymentPlan('2');
    Payment_Plan__c pp = new Payment_Plan__c();
    pp.Building_ID__c = '2';
    pp.Effective_From__c=system.today();
    insert pp;
    //Payment_Terms__c pt = InitialiseTestData.getPaymentTerm(pp.id);
    Payment_Terms__c pt = new Payment_Terms__c();
    pt.Payment_Plan__c=pp.id;
    insert pt;
    //inv = InitialiseTestData.getInventoryDetails('1','2','3',4,5);
    
    Inventory__c inv = new Inventory__c();
    
    inv.Inventory_ID__c = '1';
    inv.Building_ID__c = '2';
    inv.Floor_ID__c = '3';
    inv.Address_Id__c = '4' ;
    inv.Property_ID__c = '5' ;
    inv.Status__c='Released';
    inv.Unit_ID__c= '6';
    
    insert inv;
    
    /*ContentVersion cv= new ContentVersion();
    cv.title='test';
    cv.PathonClient='/d07/layouts/PRVB111104.pdf';
    cv.versionData=blob.valueof('124');
    insert cv;
    ContentDistribution cd = new ContentDistribution();
    cd.name='test_P';
    cd.ContentversionId=cv.id;
    cd.RelatedRecordId=unit.id;
    insert cd;
    
    ContentVersion cv1= new ContentVersion();
    cv1.title='test1';
    cv1.PathonClient='/d07/layouts/PRVB111104.pdf';
    cv1.versionData=blob.valueof('124');
    insert cv1;
    ContentDistribution cd1 = new ContentDistribution();
    cd1.name='test1';
    cd1.ContentversionId=cv1.id;
    cd1.RelatedRecordId=flr.id;
    insert cd1;*/
    
    
    PageReference pageRef = Page.Building_Payment_Plan;
    Test.setCurrentPage(pageRef);
    
     ApexPages.StandardController sc = new ApexPages.StandardController(inv);
     ApexPages.currentPage().getParameters().put('Id',inv.id);
     BuildingPaymentPlanController cls = new BuildingPaymentPlanController (sc);
                
        
    //Test.startTest();
    
    BuildingPaymentPlanController.getCreatableFieldsSOQL('Inventory__c');
    BuildingPaymentPlanController.planwrapper p= new BuildingPaymentPlanController.planwrapper();
    p.FileName='test';
    p.FileURL='222';
    cls.prepareData();
    
    cls.getPlans();
    cls.getAllPlans();
    //Test.stopTest();
    }

}