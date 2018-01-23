@isTest
public class mentalHealthSymptomHandler_test {
    
    private static testMethod  void mentalHealthSymptomHandler_UNITest(){

		Contact con = new Contact();                
			con.LastName = 'test_LNAME';
			insert con;
        	update con;
       
        Opportunity oppty = new Opportunity();
			oppty.Name = 'test_NAME';
			oppty.CloseDate = system.today();
			oppty.Probability = 100;
			oppty.StageName = 'Prospecting';
			oppty.Contact__c = con.Id;
			insert oppty;
			update oppty;
            delete oppty;
        	undelete oppty;
			
        Mental_Health_Symptom__c mentHSympt = new Mental_Health_Symptom__c();		
			mentHSympt.Patient__c = con.Id;
			mentHSympt.Opportunity__c = oppty.Id;
			insert mentHSympt;
			delete mentHSympt;
        	undelete mentHSympt;
			update mentHSympt;

			
    } 

}