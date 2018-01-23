@isTest
public class QuotePDFGenController_Test{
        static testMethod void test1(){
           /* RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Refer Out Only'];
        
         Opportunity o = new Opportunity (Name = 'TestOpp',Probability = 10,CloseDate = System.today(),StageName = '1. Prospecting',
         RecordTypeId = rc1.id);
         insert o; 
        Quote q = new Quote(name= 'test', opportunityid = o.id);
        insert q;
        PageReference pRef = Page.QuotePdf;
        pRef.getParameters().put('Id', q.id);
        Test.setCurrentPage(pRef);*/
            QuotePDFGenController QPC = new QuotePDFGenController();
            //QPC.getQuoteDetail();
            QPC.finalString= 'test';
        }
   }