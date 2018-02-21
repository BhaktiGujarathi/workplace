/*
Description : This class will checks the users to has edit / delete access to the Payment Plan based on the profile
Created By : Sivasankar K
		On : 09-05-2017
Test Class : Describe_Sobject_Access_Test
Change History : 
*/
public with sharing class PaymentPlans_Edit_Delete_OverrideControl extends Describe_Sobject_Access{
	
    public PaymentPlans_Edit_Delete_OverrideControl(ApexPages.StandardController controller){
    	sObjectName = 'payp';
    	getAccess();
    }
}