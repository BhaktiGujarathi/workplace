@isTest
public class CMB_TestUtility {
    
    
    @testSetup 
    static void testdata(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        UserRole uRole = [Select id from UserRole where developerName='Opener'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId=uRole.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser49@testorg.com');
        insert u;    
        
        User u1;
        System.runAs(u) {
            USerRole uRole1 = new USerRole(Name ='GM1',developerName='GM1');
            insert uRole1;
            
            USerRole uRole2 = new USerRole(Name='GM2',developerName='GM2',parentRoleId=uRole1.Id);
            insert uRole2;
            
            USerRole uRole3 = new USerRole(Name='GM3',developerName='GM3',parentRoleId=uRole2.Id);
            insert uRole3;
            
            USerRole uRole4 = new USerRole(Name='GM4',developerName='GM4',parentRoleId=uRole3.Id);
            insert uRole4;
            
            Profile p1 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            
            u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p1.Id, UserRoleId=uRole4.id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser48@testorg.com');
            
            insert u1;
        
            Account acc = new Account(name='Test Account',McaApp__User__c=u1.Id);
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            opp.AccountId = acc.Id;
            opp.stageName='Application In';
            opp.CloseDate = System.Today().addDays(15);
            opp.Amt_Monthly_Bank_Deposits__c = 100;
            insert opp;
            
            McaApp__Payable__c pay = new McaApp__Payable__c();
            pay.McaApp__Account__c=acc.id;
            pay.McaApp__Amount_Due__c = 5000;
            pay.McaApp__Due_date__c= System.Today();
            pay.McaApp__Date_Paid__c= System.Today();
            pay.McaApp__Account__c = acc.Id;
            pay.McaApp__Opportunity__c = opp.Id;
            pay.McaApp__Payable_Date__c = System.Today();
            insert pay;
            
            Sales_Rep_Report_Card__c repCard = new Sales_Rep_Report_Card__c();
            repCard.Sales_Rep__c=u.Id;
            insert repCard;
                    
            McaApp__Receivable__c rec = new McaApp__Receivable__c();
            rec.McaApp__Opportunity__c = opp.Id;
            rec.McaApp__Date_Sent__c = System.today();
            rec.McaApp__Due_Date__c = System.Today();
            rec.McaApp__Date_Paid__c = System.Today();
            insert rec;
        }     
        
    }
    
    //Locking All records - Opportunities/Pyables/Receivables
/*    static testmethod void insertAccountCalendar(){
        
        Account acc = [Select id from Account where name='Test Account' limit 1];
        
        Opportunity opp = [Select id, Amt_Monthly_Bank_Deposits__c from Opportunity where AccountId =: acc.id];
        opp.stageName='Funded';
        opp.McaApp__Date_Funded__c=System.today();

        update opp;
        
        Map<Integer,String> mpMonths = new Map<Integer,string>();
        mpMonths.put(1,'January');
        mpMonths.put(2,'February');
        mpMonths.put(3,'March');
        mpMonths.put(4,'April');
        mpMonths.put(5,'May');
        mpMonths.put(6,'June');
        mpMonths.put(7,'July');
        mpMonths.put(8,'August');
        mpMonths.put(9,'September');
        mpMonths.put(10,'October');
        mpMonths.put(11,'November');
        mpMonths.put(12,'December');
        
        Accounting_Calendar_Month__c acm = new Accounting_Calendar_Month__c();
        acm.Month__c = mpMonths.get(System.today().month());
        acm.Year__c = string.valueOf(System.Today().year());
        insert acm;
        
        acm.Locked__c = true;
        update acm;
        
        McaApp__Payable__c pay1 = new McaApp__Payable__c();
        pay1.McaApp__Opportunity__c = opp.Id;
        pay1.McaApp__Payable_Date__c = System.today();
        try{
            insert pay1;
        }
        catch(Exception e){}
        
        McaApp__Payable__c pay2 = new McaApp__Payable__c();
        pay2.McaApp__Opportunity__c = opp.Id;
        pay2.McaApp__Payable_Date__c = System.today().addMonths(-1);
        insert pay2;
        
        try{
            pay2.McaApp__Payable_Date__c = System.Today();
            update pay2;
        }
        catch(Exception e){
        
        }
        
        try{
            pay2.McaApp__Date_Paid__c= System.Today();
            update pay2;
        }
        catch(Exception e){
        
        }
        
        try{
            pay2.McaApp__Due_Date__c= System.Today();
            update pay2;
        }
        catch(Exception e){
        
        }
        
        RecordType recPayable = [Select id from RecordType where sobjectType='McaApp__Payable__c' and developerName='Read_Only'];
        McaApp__Payable__c pay3 = new McaApp__Payable__c();
        pay3.McaApp__Opportunity__c = opp.Id;
        pay3.McaApp__Payable_Date__c = System.today().addMonths(-1);
        //pay3.recordtypeId=recPayable.id;
        insert pay3;
        
        pay3.recordtypeId=recPayable.id;
        update pay3;
        try{
            pay3.McaApp__Payable_Date__c = System.Today();
            update pay3;
        }
        catch(Exception e){
        
        }
        
        try{
            pay3.McaApp__Date_Paid__c= System.Today();
            update pay3;
        }
        catch(Exception e){
        
        }
        
        try{
            pay3.McaApp__Due_Date__c= System.Today();
            update pay3;
        }
        catch(Exception e){
        
        }
        
        McaApp__Receivable__c rec = new McaApp__Receivable__c ();
        rec.McaApp__Opportunity__c = opp.Id;
        rec.McaApp__Date_Sent__c = System.Today();
        try{insert rec;}catch(Exception e){}
        
        
        McaApp__Receivable__c rec1 = new McaApp__Receivable__c ();
        rec1.McaApp__Opportunity__c = opp.Id;
        rec1.McaApp__Date_Sent__c = System.Today().addMOnths(-1);
        insert rec1;
        
        try{
            rec1.McaApp__Date_Sent__c = System.Today();
            update rec1;
        }
        catch(Exception e){
        
        }
        
        try{
            rec1.McaApp__Due_Date__c= System.Today();
            update rec1;
        }
        catch(Exception e){
        
        }
        
        try{
            rec1.McaApp__Date_Paid__c = System.Today();
            update rec1;
        }
        catch(Exception e){
        
        }
        
        RecordType recReceivable = [Select id from RecordType where sobjectType='McaApp__Receivable__c' and developerName='Read_Only'];
        
        McaApp__Receivable__c rec2 = new McaApp__Receivable__c ();
        rec2.McaApp__Opportunity__c = opp.Id;
        rec2.McaApp__Date_Sent__c = System.Today().addMOnths(-1);
        insert rec2;
        
        rec2.recordtypeId = recReceivable.Id;
        update rec2;
        
        try{
            rec2.McaApp__Date_Sent__c = System.Today();
            update rec2;
        }
        catch(Exception e){
        
        }
        
        try{
            rec2.McaApp__Due_Date__c= System.Today();
            update rec2;
        }
        catch(Exception e){
        
        }
        
        try{
            rec2.McaApp__Date_Paid__c = System.Today();
            update rec2;
        }
        catch(Exception e){
        
        }
        
        try{
        opp.McaApp__Date_Funded__c=System.today();
        update opp;
        }
        Catch(Exception e){}
    } 
    
    
    
    //unlocking All records - Opportunities/Pyables/Receivables
    static testmethod void deleteAccountCalendar(){
        
        Account acc = [Select id from Account where name='Test Account' limit 1];
        
        Opportunity opp = [Select id from Opportunity where AccountId =: acc.id];
        opp.stageName='Funded';
        opp.McaApp__Date_Funded__c=System.today();

        update opp;
        
        Map<Integer,String> mpMonths = new Map<Integer,string>();
        mpMonths.put(1,'January');
        mpMonths.put(2,'February');
        mpMonths.put(3,'March');
        mpMonths.put(4,'April');
        mpMonths.put(5,'May');
        mpMonths.put(6,'June');
        mpMonths.put(7,'July');
        mpMonths.put(8,'August');
        mpMonths.put(9,'September');
        mpMonths.put(10,'October');
        mpMonths.put(11,'November');
        mpMonths.put(12,'December');
        
        Accounting_Calendar_Month__c acm = new Accounting_Calendar_Month__c();
        acm.Month__c = mpMonths.get(System.today().month());
        acm.Year__c = string.valueOf(System.Today().year());
        insert acm;
        
        acm.Locked__c = true;
        update acm;
        
        delete acm;
    }
    
    static testmethod void createPayables(){
        Account acc = [Select id from Account where name='Test Account' limit 1];
        Opportunity opp = [Select id from Opportunity where AccountId =: acc.id];
        User u1 = [Select id,name from User where username='standarduser49@testorg.com'];
        User u2 = [Select id,name from User where username='standarduser48@testorg.com'];
        
        RecordType rec = [Select id from RecordType where developerName='ISO'];
        
        Account acc1 = new Account(McaApp__User__c=u1.Id,recordtypeId=rec.Id,name=u1.name);
        Account acc2 = new Account(McaApp__User__c=u2.Id,recordtypeId=rec.Id,name=u2.name);
        insert acc1;
        insert acc2;
        
        OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opp.Id,UserId = u2.Id, TeamMemberRole='Opener Manager');
        insert otm;
        
        Sales_Rep_Report_Card__c repCard1 = new Sales_Rep_Report_Card__c();
        repCard1.Sales_Rep__c=u1.Id;
        insert repCard1;
        
        Sales_Rep_Report_Card__c repCard2 = new Sales_Rep_Report_Card__c();
        repCard2.Sales_Rep__c=u2.Id;
        insert repCard2;
        
        opp.Submission_Approved__c = true;
        update opp;
    }*/
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void resetScorecards(){
        ResetSubmissionScheduler obj = new ResetSubmissionScheduler();
        database.executeBatch(obj,100);
        
        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP, new ResetSubmissionScheduler());
        Test.stopTest(); 
     

   
    }
}