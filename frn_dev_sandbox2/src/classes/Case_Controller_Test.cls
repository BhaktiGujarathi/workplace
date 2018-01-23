@isTest
public class Case_Controller_Test
{
    static testmethod void Case_ControllerTest() 
    {
        RecordType rc1 = [select id from  RecordType where SobjectType='case' AND Name='Facility Approval'];
        Account acc = new Account(Name = 'Acount 1');
        insert acc;
        Case cs = new case(Status='On Hold',Origin='Email', Accountid=acc.Id);
        insert cs;
         ApexPages.StandardController sc = new ApexPages.StandardController (cs);
          Case_Controller coe = new Case_Controller(sc);
    }
}