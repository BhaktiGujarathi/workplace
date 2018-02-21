/****************************************************************************************************************
* Name                  : ContactTriggerHandler_Test                                                            *
* Trigger               : ContactTrigger                                                                        *
* Class Covered         : ContactTriggerHandler                                                                 *
* Created By            : NSI - Sivasankar K                                                                    *               
* Created Date          : 20/Feb/2017                                                                           *   
* Last Modified Date    :                                                                                       *
* Last Modified By      :                                                                                       *
* ------------------------------------------------------------------------------------------------------------  *
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                         *                                        
* CH00              1.0         NSI - Sivasankar K         20/Feb/2017      Initial developmen                  *
*****************************************************************************************************************/
@isTest
public class ContactTriggerHandler_Test {
    
    testmethod static void testData() {
        
        List<Account> insertAccounts = new List<Account>();
        Account blacklistAcc = InitialiseTestData.getBlacklistedAccount('Blacklist Account');
        insertAccounts.add(blacklistAcc);
        Account corporateAcc = InitialiseTestData.getCorporateAccount('Damac Test Account');
        insertAccounts.add(corporateAcc);
        Account terminateAcc = InitialiseTestData.getTerminatedAccount('Damac Test Termination');
        
        insertAccounts.add(terminateAcc);
        
        List<Contact> contactList = new List<Contact>();
        Contact corporateContactDamac = InitialiseTestData.getCorporateAgencyContact('Damac');
        contactList.add(corporateContactDamac);
        Contact corporateContactDamactest = InitialiseTestData.getCorporateAgencyContact('Damactest');
        contactList.add(corporateContactDamactest);
        Contact testcorporateContactDamac = InitialiseTestData.getCorporateAgencyContact('Damac');
        contactList.add(testcorporateContactDamac);
        
        insert contactList;
        
        List<User> portalUsersList = new List<User>();
        
        User portalUser = InitialiseTestData.getPortalUser('testUser@damac.com',corporateContactDamac.Id);
        portalUser.isActive = true;
        portalUsersList.add(portalUser);
        
        User portalUser1 = InitialiseTestData.getPortalUser('testUser1@damac.com',corporateContactDamactest.Id);
        portalUser1.isActive = true;
        portalUsersList.add(portalUser1);

        insert portalUsersList;
        
        delete testcorporateContactDamac;
        
        try{
            portalUser1.isActive = false;
            update portalUser1;
        }Catch(Exception ex){
            
        }
        
    } 
}