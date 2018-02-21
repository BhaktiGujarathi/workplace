@isTest(SeeAllData=false)
private class VehicleSubmittedNotificationBatchTest {

    // method to verify bulk vehicle Record Creation for Account
    public static testMethod void test_CreateBulkVehicles() {
        // Create a user to own each of these accounts.
        User parentUser = (User)new SObjectBuilder(User.sObjectType)
           .create().getRecord();
        List<Vehicle__c> vehicleList;
        Test.startTest();
            System.runas( parentUser ) {
                List<Account> accountList = new SObjectBuilder(Account.sObjectType)
                   .put(Account.Name, new SObjectFieldProviders.UniqueStringProvider()) // Each account will get a different name
                   .count(5).create().getRecords();

                vehicleList = new SObjectBuilder(Vehicle__c.sObjectType)
                    .put(Vehicle__c.Account__c, accountList) // Each opportunity will be assigned a different account.
                    .put(Vehicle__c.License_Plate__c, accountList)
                    .count(accountList.size()).create().getrecords();
            }
        Test.stopTest();

        System.assertEquals( vehicleList.size() , [Select Id From Vehicle__c ].size() );
    }   

    // method to verify bulk vehicle Record Creation for Account
    public static testMethod void test_ExceuteMethodBatch() {
        // Create a user to own each of these accounts.
        User parentUser = (User)new SObjectBuilder(User.sObjectType)
           .create().getRecord();
        List<Vehicle__c> vehicleList;
        List<Vehicle__c> assertVehicleList = new List<Vehicle__c>();
        VehicleSubmittedNotificationBatch batchCls= new VehicleSubmittedNotificationBatch();
        Integer invocations;
        Test.startTest();
            System.runas( parentUser ) {
                List<Account> accountList = new SObjectBuilder(Account.sObjectType)
                   .put(Account.Name, new SObjectFieldProviders.UniqueStringProvider()) // Each account will get a different name
                   .count(5).create().getRecords();

                vehicleList = new SObjectBuilder(Vehicle__c.sObjectType)
                    .put(Vehicle__c.Account__c, accountList) // Each opportunity will be assigned a different account.
                    .put(Vehicle__c.License_Plate__c, accountList)
                    .count(accountList.size()).create().getrecords();

                for(Vehicle__c vehicleObj : [SELECT Id,
                                                    Name,
                                                    Status__c
                                               FROM Vehicle__c
                                            ]) {
                    vehicleObj.Status__c = 'Submitted - Pending Approval';
                    assertVehicleList.add(vehicleObj);
                }
                update assertVehicleList;                
                Database.executeBatch(batchCls);
            }
        Test.stopTest();      
        //system.assertEquals(batchCls.emailIsSendOrNot, 'Success');
    }

}