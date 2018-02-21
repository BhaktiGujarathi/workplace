@isTest
private class MCAAttachmentTabControllerTest {
  
    static testMethod void MCAAttachmentTabControllerTest(){
        Opportunity opp = new Opportunity();            
        opp.Name = 'Test Name';  
        opp.CloseDate = date.today();
        opp.StageName = 'Application In';
        insert opp;
                
        Test.startTest();
        PageReference pageRef = Page.MCATabPage;
        Test.setCurrentPage(pageRef);        
        pageRef.getParameters().put('Id',opp.Id);        
        MCAAttachmentTabController controller = new MCAAttachmentTabController();
        controller.opportunityId = opp.Id;
        controller.opportunity = [select Id, Name, AccountId from Opportunity where Id =: opp.Id];
        system.assertEquals(controller.opportunity.Id , opp.Id);
        Test.stopTest();
        
        //Asserttion for MCAAttachmentTabControllerTest
        list<Opportunity> oppAssertList = [select Id,Name
                                           from Opportunity
                                           limit 1];
        system.assertEquals(oppAssertList[0].Id , opp.Id);
    }
    
    static testMethod void getContainersTest(){
        Opportunity opp = new Opportunity(); 
        Attachment attachment = new Attachment();           
        opp.Name = 'Test Name';
        opp.CloseDate = date.today();
        opp.StageName = 'Application In';   
        insert opp;
        
        Test.startTest();        
        PageReference pageRef = Page.MCATabPage;
        Test.setCurrentPage(pageRef);        
        pageRef.getParameters().put('Id',opp.Id);
        transient Blob b = EncodingUtil.base64Decode('Hi');
        System.debug('%%%%%%%%%Blob: ' + b);        
        List <Attachment> attachmentList = new list<Attachment>();
        attachmentList.add(new Attachment (Name ='TestName',
                                           ParentId = opp.Id,
                                           IsPrivate = false,   
                                           Body = b,                                   
                                           Description = 'Test Description'));
        System.debug('$$$$$$$$$$$$$$attachmentList' + attachmentList);
        insert attachmentList;        
        System.debug('$$$$$$$$$$$$attachmentList[0].ParentId:- '+attachmentList[0].ParentId);        
        MCAAttachmentTabController controller = new MCAAttachmentTabController();
        controller.getContainers();     
        Test.stopTest();  
        
        //Assretion for getContainersTest
        list<Attachment> attachAsertList = [select Name,Id,ParentId 
                                            from Attachment
                                            where ParentId =: opp.Id]; 
        
        System.assertEquals(attachAsertList[0].Name , 'TestName');          
    }
    
    static testMethod void deleteAttachment(){
        Opportunity opp = new Opportunity(); 
        Attachment attachment = new Attachment();           
        opp.Name = 'Test Name';
        opp.CloseDate = date.today();
        opp.StageName = 'Application In';   
        insert opp;
        
        Test.startTest();        
        PageReference pageRef = Page.MCATabPage;
        Test.setCurrentPage(pageRef);        
        pageRef.getParameters().put('Id',opp.Id);       
        transient Blob b = EncodingUtil.base64Decode('Hi');         
        List <Attachment> attachmentList = new list<Attachment>();
        attachmentList.add(new Attachment (Name ='TestName',
                                           ParentId = opp.Id,
                                           IsPrivate = false,   
                                           Body = b,                                   
                                           Description = 'Test Description'));
        System.debug('$$$$$$$$$$$$$$attachmentList' + attachmentList);
        insert attachmentList;
        
        MCAAttachmentTabController controller = new MCAAttachmentTabController();
        controller.recordToDelete = attachmentList[0].Id;
        controller.deleteAttachment();        
        Test.stopTest(); 
        
        //Assretion for deleteAttachment
        list<Attachment> attachAsertList = [select Name,Id
                                            from Attachment]; 
        system.debug('%%%%%%%%%%%%%%attachAsertList for delete :'+attachAsertList);
        System.assertEquals(attachAsertList.size() , 0); 
    }
    
    static testMethod void saveAllAttachments(){
        Opportunity opp = new Opportunity(); 
        Attachment attachment = new Attachment();           
        opp.Name = 'Test Name';
        opp.CloseDate = date.today();
        opp.StageName = 'Application In';   
        insert opp;
        
        Test.startTest();        
        PageReference pageRef = Page.MCATabPage;
        Test.setCurrentPage(pageRef);        
        pageRef.getParameters().put('Id',opp.Id);
        transient Blob b = EncodingUtil.base64Decode('Hi');
        List <Attachment> attachmentList = new list<Attachment>();
        attachmentList.add(new Attachment (Name ='TestName',
                                           ParentId = opp.Id,
                                           IsPrivate = false,   
                                           Body = b,                                   
                                           Description = 'Test Description'));        
        insert attachmentList;
        
        MCAAttachmentTabController controller = new MCAAttachmentTabController();
        controller.attachments = attachmentList;                
        controller.saveAllAttachments();
        Test.stopTest();
        
        //Assretion for saveAllAttachments
        list<Attachment> attachAsertList = [select Name,Id
                                            from Attachment];         
        System.assertEquals(attachAsertList[0].Name , 'TestName');    
    }
    
    static testMethod void editAll(){
        Opportunity opp = new Opportunity(); 
        Attachment attachment = new Attachment();           
        opp.Name = 'Test Name';
        opp.CloseDate = date.today();
        opp.StageName = 'Application In';   
        insert opp;
        
        Test.startTest();        
        PageReference pageRef = Page.MCATabPage;
        Test.setCurrentPage(pageRef);        
        pageRef.getParameters().put('Id',opp.Id);
        transient Blob b = EncodingUtil.base64Decode('Hi');
        System.debug('%%%%%%%%%Blob: ' + b);
        
        List <Attachment> attachmentList = new list<Attachment>();
        attachmentList.add(new Attachment (Name ='TestName',
                                           ParentId = opp.Id,
                                           IsPrivate = false,   
                                           Body = b,                                   
                                           Description = 'Test Description'));
        System.debug('$$$$$$$$$$$$$$attachmentList' + attachmentList);
        insert attachmentList;
        MCAAttachmentTabController controller = new MCAAttachmentTabController();
        controller.attachments = attachmentList;                
        controller.editAll();
        Test.stopTest();    
    }
    
}