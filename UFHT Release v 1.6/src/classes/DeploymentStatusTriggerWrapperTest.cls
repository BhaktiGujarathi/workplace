@isTest
private class DeploymentStatusTriggerWrapperTest {

    static testMethod void FieldsWithPicklistWrapperCase1() {
    	Boolean isEnablePollar = true;
        Integer progCounter = 25;
        Id asyncId = null;
        String message = 'Not Deployment';
        String messageType = 'Error';
        Boolean isRemoteSitePresent = true;
        list<PageMessageWrapper> lstPageMessagesWrapper = new list<PageMessageWrapper>();
        lstPageMessagesWrapper.add(new PageMessageWrapper(message,messageType));
        
        test.startTest();
        DeploymentStatusTriggerWrapper objStatus = new DeploymentStatusTriggerWrapper(isEnablePollar,progCounter,asyncId,isRemoteSitePresent,lstPageMessagesWrapper);
        test.stopTest();
    }
}