@isTest 
public class CountActivitiesOnLeadsTest {
    static testmethod void testmetho1() {

    Lead l = new Lead();
    l.LastName = 'Smith';
    l.company = 'Acme';
    l.Status = 'Open';
    insert l;
           
    Test.startTest();
        Task tk1 = new Task();
        tk1.Priority = 'Normal';
        tk1.Status = 'Not Started';
        tk1.Subject = 'Call';
        tk1.whoID = l.id; 
        insert tk1;
        
        Task tk2 = new Task();
        tk2.Priority = 'Normal';
        tk2.Status = 'Not Started';
        tk2.Subject = 'Call';
        tk2.whoID=l.id; 
        insert tk2;
        
        tk1.Priority = 'High';
        update tk1;
        
        delete tk1;
        
        
    Test.stopTest();
    }
}