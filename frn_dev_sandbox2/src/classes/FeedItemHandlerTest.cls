@isTest
public class FeedItemHandlerTest{
    private static testMethod void FeedItemHandler_Test(){
        RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Outpatient Treatment'];
        Opportunity opp = new Opportunity(Name = 'Test1',StageName = 'Qualification',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id);
        insert opp;
        
        CollaborationGroup clg = new CollaborationGroup();
        clg.Name = 'Test1';
        clg.CollaborationType = 'Public';
        insert clg;
        
        FeedItem fdi = new FeedItem();
        fdi.Body = 'testtestetetse';
        fdi.parentId = opp.id;
        insert fdi;
        update fdi;
		
    }
	 private static testMethod void FeedItemHandler_Test1(){
        RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Outpatient Treatment'];
        Opportunity opp = new Opportunity(Name = 'Test1',StageName = 'Qualification',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id);
        insert opp;
        
        CollaborationGroup clg = new CollaborationGroup();
        clg.Name = 'Test1';
        clg.CollaborationType = 'Public';
        insert clg;
        
		
		FeedItem fdi1 = new FeedItem();
        fdi1.Body = 'testtestetetse';
        fdi1.parentId = opp.id;
        insert fdi1;
        update fdi1;
		
		FeedItem fdi2 = new FeedItem();
		fdi2.Body = 'testtestetetse';
		fdi2.parentId = clg.id;
		insert fdi2;
		update fdi2;
    }
     private static testMethod void FeedItemHandler_Test2(){  
		RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Outpatient Treatment'];
		Opportunity opp = new Opportunity(Name = 'test12345678912345678912345678912345678900000',StageName = 'Qualification',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id);
		insert opp;
		
		Opportunity opp1 = new Opportunity(Name = 'test1',StageName = 'Qualification',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id);
		insert opp1;
		
		CollaborationGroup clg = new CollaborationGroup();
		clg.Name = 'test1';
		clg.CollaborationType = 'Public';
		insert clg;

		FeedItem fdi = new FeedItem();
		fdi.Body = 'testtestetetse';
		fdi.parentId = opp.id;
		insert fdi;

		FeedItem fdi1 = new FeedItem();
		fdi1.Body = 'testtestetetse';
		fdi1.parentId = opp1.id;
		insert fdi1;

		FeedItem fdi2 = new FeedItem();
		fdi2.Body = 'testtestetetse';
		fdi2.parentId = clg.id;
		insert fdi2;

		/* FeedAttachment fA = new FeedAttachment();
		fA.Type = 'Content';
		fA.RecordId = attach.id;
		fA.FeedEntityId = fdi1.id;
		insert fA; */
		
		/* FeedAttachment feedAttachment = new FeedAttachment();
		feedAttachment.FeedEntityId = fdi1.Id;
		feedAttachment.RecordId = document.Id;
		feedAttachment.Title = 'FileName';
		feedAttachment.Type = 'CONTENT'; 
		insert feedAttachment; */
		
		FeedItemHandler fIH = new FeedItemHandler();
		fIH.bulkBefore();
		fIH.beforeInsert(fdi1);
		fIH.beforeUpdate(fdi1, fdi1);
		fIH.beforeDelete(fdi1);
		fIH.afterUpdate(fdi1, fdi1);
		fIH.afterDelete(fdi1);
		fIH.afterUndelete(fdi1);

		 
     }
 }