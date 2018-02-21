/*
Description : This class will checks the users to has edit / delete access to the Contact based on the profile
Created By : Sivasankar K
		On : 07-05-2017
Test Class : Describe_Sobject_Access_Test
Change History : 
*/
public with sharing class Contact_Edit_Delete_Override_Controller extends Describe_Sobject_Access{

    public Contact_Edit_Delete_Override_Controller(ApexPages.StandardController controller){
    	sObjectName = 'con';
    	getAccess();
    }
}