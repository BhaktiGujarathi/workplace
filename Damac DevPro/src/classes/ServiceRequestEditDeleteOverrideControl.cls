/*
Description : This class will checks the users to has edit / delete access to the Service Request based on the profile
Created By : Sivasankar K
		On : 09-05-2017
Test Class : Describe_Sobject_Access_Test
Change History : 
*/
public with sharing class ServiceRequestEditDeleteOverrideControl extends Describe_Sobject_Access{
    
    public ServiceRequestEditDeleteOverrideControl(ApexPages.StandardController controller){
    	sObjectName = 'srq';
    	getAccess();
    }
}