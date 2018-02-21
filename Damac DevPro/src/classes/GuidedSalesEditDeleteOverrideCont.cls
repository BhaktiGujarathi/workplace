/*
Description : This class will checks the users to has edit / delete access to the Guided Sales based on the profile
Created By : Sivasankar K
		On : 07-05-2017
Test Class : Describe_Sobject_Access_Test
Change History : 
*/
public with sharing class GuidedSalesEditDeleteOverrideCont extends Describe_Sobject_Access {
    public GuidedSalesEditDeleteOverrideCont(ApexPages.StandardController controller){
    	sObjectName = 'gsp';
    	getAccess();
    }
}