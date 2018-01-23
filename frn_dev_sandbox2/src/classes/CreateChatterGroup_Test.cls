@isTest
public class CreateChatterGroup_Test{
	//93%
	 static testMethod void Test1(){
		String coName = 'tesst5434';  
		String oppName = 'tesst4568765';  
		
		CreateChatterGroup ccg = new CreateChatterGroup();
		CreateChatterGroup.chatter(coName);
		CreateChatterGroup.chatter1(coName);
	 } 
	 static testMethod void Test(){
		String coName = 'tesst5434';  
		String oppName = 'tesst4568765'; 
		CreateChatterGroup ccg = new CreateChatterGroup();		
		CreateChatterGroup.chatter1(oppName);
		CreateChatterGroup.chatter(coName);
        
	 }
}