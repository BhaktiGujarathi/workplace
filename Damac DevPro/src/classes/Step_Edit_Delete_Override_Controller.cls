/*
Description : This class will checks the users to has edit / delete access to the Step based on the profile
Created By : Sivasankar K
		On : 08-05-2017
Test Class : Describe_Sobject_Access_Test
Change History : 
*/
public with sharing class Step_Edit_Delete_Override_Controller extends Describe_Sobject_Access{
	
    public Step_Edit_Delete_Override_Controller(ApexPages.StandardController controller){
    	sObjectName = 'stp';
    	getAccess();
    }
}