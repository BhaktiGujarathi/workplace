@isTest
public class DocumenthandlerTest{
    
    public static TestMethod void Documenthandler_UnitTest(){   
        Contact con = new Contact();
        con.lastName ='test';
        insert con;
        //update con;

        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        opp.Contact__c=con.id;
        insert opp;
		//update opp;
       
        Document__c doc= new Document__c();
        doc.Opportunity__c = opp.Id;
        doc.Patient__c =con.id;
        insert doc;
        //update doc;
        delete doc;
		
    }
public static TestMethod void Documenthandler_UnitTest1(){   
        Contact con = new Contact();
        con.lastName ='test';
        insert con;
        //update con;

        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.StageName='Prospecting';
        opp.Contact__c=con.id;
        insert opp;
		//update opp;
       
        Document__c doc= new Document__c();
        doc.Opportunity__c = opp.Id;
        doc.Patient__c =con.id;
        insert doc;
        update doc;
        delete doc;
		
    }
}