@isTest
public class SalesRep_RecordDisplay_Controller_Test{
static testMethod void myUnitTest(){
//Sales_Rep_Report_Card__c s = [select id from Sales_Rep_Report_Card__c where name='test name'];

//Sales_Rep_Report_Card__c obj1 = new Sales_Rep_Report_Card__c();
//ApexPages.StandardController sc = new ApexPages.StandardController(obj1);
//SalesRep_RecordDisplay_Controller sph = new SalesRep_RecordDisplay_Controller (sc);
//PageReference pageRef = Page.SalesRepReportCard_RecordDisplay;
//pageRef.getParameters().put('id', String.valueOf(obj1.Id));
//Test.setCurrentPage(pageRef);     
Sales_Rep_Report_Card__c obj = new Sales_Rep_Report_Card__c();
obj.Name = 'test Name';
insert obj;

PageReference pageRef = Page.SalesRepReportCard_RecordDisplay;
        pageRef.getParameters().put('Id', obj.Id);
        system.debug('***pageRef***'+pageRef);
        Test.setCurrentPageReference(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.standardController(obj);
        SalesRep_RecordDisplay_Controller obj1 = new SalesRep_RecordDisplay_Controller (sc);
        

   }
}