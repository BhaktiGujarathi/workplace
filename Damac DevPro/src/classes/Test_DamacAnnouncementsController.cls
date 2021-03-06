/**************************************************************************************************
* Name               : DamacAnnouncementsController                                                
* Description        : An apex page controller for DamacAnnouncementsController                                          
* Created Date       : NSI - Diana                                                                        
* Created By         : 02/21/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          02/21/2017                                                           
**************************************************************************************************/
@isTest
public class Test_DamacAnnouncementsController {
    
    public static Contact adminContact;
    public static Announcement__c futureannouncement;
    public static User portalUser;
    public static Account adminAccount;
    
    static void init(){

        adminAccount = InitialiseTestData.getAdminAccount(50000000,'Test agency');
        insert adminAccount;
        
        adminContact = InitialiseTestData.getAdminContact('Test Contact',adminAccount.Id);
        insert adminContact;
        
        portalUser = InitialiseTestData.getPortalUser('test@test.com', adminContact.Id, 'Admin');
        
        system.debug('***'+adminAccount.Agency_Tier__c);
        futureannouncement = InitialiseTestData.createAnnouncement(System.now().Date(),System.now().Date().addDays(30),true,
                                                                  'SILVER','All');
        insert futureannouncement;

    }
    
    @isTest static void showAllAnnouncements(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
        	DamacAnnouncementsController announcements = new DamacAnnouncementsController();
        }
        Test.stopTest();
    }

}