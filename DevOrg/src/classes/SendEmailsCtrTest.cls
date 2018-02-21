@isTest()
    private class SendEmailsCtrTest {
        static testMethod void SendEmailsCtrTest1(){
        
            RecordType rt = [Select Id From RecordType where sobjecttype = 'Account' LIMIT 1];    
            Account acc =new Account();
            acc.RecordtypeId = rt.Id;
            acc.Name='Testing';
            Insert acc;
            system.assertNotEquals(acc.id,null);
            
            contact con=new contact();
            con.LastName='test';
            con.Email='test@mail.com';
            insert con;
            system.assertNotEquals(con.id,null);
            
            list<opportunity> OppList=new list<opportunity>();
            opportunity opp=new opportunity();
            opp.name ='Test';
            opp.stageName ='Denied';
            opp.accountId =acc.id;
            opp.CloseDate =date.today();
            opp.Owner_1__c =con.Id;
            insert opp;
            system.assertNotEquals(opp.id,null);
            OppList.add(opp);
                       
            // name='EFT No Docs Received'
           
            EmailTemplate Temp = [SELECT id,name,Subject FROM EmailTemplate where name='Test2' or name='EFT No Docs Received' limit 1];
           
            PageReference pageRef = Page.SendEmails;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ids',opp.id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(opp);
            
            SendEmailsCtr sendEmail=new SendEmailsCtr(sc);
            sendEmail.selectedTemplate='--None--';               
            sendEmail.SendEmails();   
            
            SendEmailsCtr sendEmail1=new SendEmailsCtr(sc);
            sendEmail1.selectedTemplate=temp.name;               
            sendEmail1.SendEmails();
     
        }    
    }