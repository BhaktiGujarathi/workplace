@isTest
    private class testTaskHandler{
        static testMethod void tesTaskHandler1(){
            Account acc =new Account();
            acc.name='Test';
            Insert acc;
        
            opportunity opp=new opportunity();
            opp.name ='Test';
            opp.stageName ='Denied';
            opp.accountId =acc.id;
            opp.CloseDate =date.today();
            opp.Activities_in_Current_Stage__c =0;
            Test.StartTest();
                Insert opp;   // insert a Opportunity record
                system.AssertEquals(opp.stageName,'Denied');
                system.AssertEquals(opp.Activities_in_Current_Stage__c,0);
                
                Task t = new Task();
                t.Activity_Type__c = 'DRB Fundings On Hold';
                t.Priority ='Normal';
                t.whatId =opp.id;
                t.Subject ='Call';
                t.Status ='Not Started';
                t.ActivityDate = Date.Today()+2;
                insert t;
                opp.name ='Test Opp';
                update opp;
                system.AssertEquals(t.Status,'Not Started');
                system.AssertEquals(t.whatId,opp.id);
                
                Task t1 = new Task();
                t1.Activity_Type__c = 'DRB Fundings On Hold';
                t1.Priority ='Normal';
                t1.whatId =opp.id;
                t1.Subject ='Call';
                t1.Status ='Not Started';
                t1.ActivityDate = Date.Today()+2;
                insert t1;
                system.AssertEquals(t1.Status,'Not Started');
                system.AssertEquals(t1.whatId,opp.id);
                update opp;
                opp.name ='Test Opp';
                opp.Next_Activity_Type__c = t.Activity_Type__c;
                opp.Next_Activity_Assigned_To__c = t.OwnerId;
                opp.Next_Activity_Date__c = t.ActivityDate;
                update opp;
                
                Task t2 = new Task();
                t2.Activity_Type__c = 'DRB Fundings On Hold';
                t2.Priority ='Normal';
                t2.whatId =opp.id;
                t2.Subject ='Call';
                t2.Status ='Not Started';
                t2.ActivityDate = Date.Today()+2;
                insert t2;
                update t2;
                opp.Next_Activity_Type__c = t1.Activity_Type__c;
                opp.Next_Activity_Assigned_To__c = t1.OwnerId;
                opp.Next_Activity_Date__c = t1.ActivityDate;
                
                update opp;
            Test.StopTest();
        }
        
        static testMethod void tesTaskHandler2(){
            Account acc =new Account();
            acc.name='Test';
            Insert acc;
        
            opportunity opp=new opportunity();
            opp.name ='Test';
            opp.stageName ='Denied';
            opp.accountId =acc.id;
            opp.CloseDate =date.today();
            opp.Activities_in_Current_Stage__c =0;
            Insert opp;   // insert a Opportunity record
            System.AssertEquals(opp.accountId,acc.id);
            System.AssertEquals(opp.stageName,'Denied');
            
            Task t = new Task();
            t.Activity_Type__c = 'DRB Fundings On Hold';
            t.Priority ='Normal';
            t.whatId =opp.id;
            t.Subject ='Call';
            t.Status ='Completed';
            t.ActivityDate = Date.Today()+2;
            try{
                 Test.StartTest();
                     insert t;
                 Test.StopTest();
            }
            catch(Exception e) {
                System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
                System.Assert(e.getMessage().contains('Status can not be completed at the time of creation'));
            }
        }
        
        static testMethod void tesTaskHandler3(){
            Account acc =new Account();
            acc.name='Test';
            Insert acc;
        
            opportunity opp=new opportunity();
            opp.name ='Test';
            opp.stageName ='Denied';
            opp.accountId =acc.id;
            opp.CloseDate =date.today();
            opp.OwnerId = UserInfo.getUserId();
            Test.StartTest();
                Insert opp;   // insert an Opportunity record
                Task t = new Task();
                t.Activity_Type__c = 'DRB Fundings On Hold';
                t.Priority ='Normal';
                t.whatId =opp.id;
                t.Subject ='Call';
                t.Status ='Not Started';
                t.OwnerId = UserInfo.getUserId();
                t.ActivityDate = Date.Today();
                insert t;
                
                
                
                Task t2 = t.clone();
                insert t2;
                
                update t2;
                t2.Status ='Completed';
                update t2;
                
                Task t3 = t.clone();
                t3.Status = 'Completed';
                insert t3;
                
                
                
               
                
                //t.Status ='Completed';
               // update t;
                opp.name ='Test Opp';
                opp.Next_Activity_Type__c = t.Activity_Type__c;
                opp.Next_Activity_Assigned_To__c = t.OwnerId;
                opp.Next_Activity_Date__c = t.ActivityDate;
                opp.Last_Activity_Type__c = t.Activity_Type__c;
                opp.Last_Activity_User__c = t.OwnerId;
                
                
                t2.ActivityDate =Date.Today().adddays(-2);
                t2.Status ='Completed';
                
                
                update t2;
                update t3;
                
                Task t4= t.clone();
                t4.activityDate = date.today().addDays(-5);
                insert t4;
                
                t.Status ='Completed';
                update t;
                
                update opp;
                System.AssertEquals(opp.Next_Activity_Type__c,'DRB Fundings On Hold');
                System.AssertEquals(opp.Next_Activity_Assigned_To__c,UserInfo.getUserId());
            Test.StopTest();
        }
}