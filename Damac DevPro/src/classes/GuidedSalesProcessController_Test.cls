/**************************************************************************************************
* Covered Class      : GuidedSalesProcessController  
* Test class         : GuidedSalesProcessController_Test                                  
* Created Date       : NSI - Sivasankar                                                                        
* Created By         : 26/Feb/2017                                                                 
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Sivasankar          26/Feb/2017                                                               
***************************************************************************************************/
@isTest
public class GuidedSalesProcessController_Test {
    
    testmethod static void testGuidedSales(){
        
        Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        Id CorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();
        ID ProfileID = [ Select id,UserType from Profile where name = 'Customer Community - Admin'].id;
        ID consultantId = [ Select id,UserType from Profile where name = 'Property Consultant'].id;
        ID adminProfileID = [ Select id,UserType from Profile where name = 'System Administrator'].id;
        ID adminRoleId = [ Select id from userRole where name = 'Chairman'].id;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Property Consultant']; 
        Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', isActive = true,
            LocaleSidKey='en_US', ProfileId = p1.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser5@testorg.com');
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', userRoleId=adminRoleId, isActive = true,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='admin6@testorg.com');
        
        System.runAs(u2) {
            PageReference gspPage = Page.GuidedSalesProcess;
            Test.setCurrentPage(gspPage);
            Id InquiryRecordTypeId = Schema.SObjectType.Inquiry__c.getRecordTypeInfosByName().get('Inquiry').getRecordTypeId();
            Inquiry__c inquiryRec = InitialiseTestData.getInquiryDetails('Inquiry',1234);
            insert inquiryRec;
            //Assigning test Page
            ApexPages.currentPage().getParameters().put('id', inquiryRec.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(inquiryRec);
            GuidedSalesProcessController guidedSales = new GuidedSalesProcessController(sc);
            
            Campaign__c camp = new Campaign__c();
            camp.RecordTypeId = RSRecordTypeId;
            camp.Campaign_Name__c='Test Campaign';
            camp.start_date__c = System.today();
            camp.end_date__c = System.Today().addDays(30);
            camp.Marketing_start_date__c = System.today();
            camp.Marketing_end_date__c = System.Today().addDays(30);
            insert camp;
            
            Address__c addressobj1 = new Address__c();
            addressobj1.Address_ID__c = 987654;
            addressobj1.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj1.ADDRESS_LINE2__c='Cluster E';
            addressobj1.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj1.City__c = 'Dubai';
            addressobj1.Country__c = 'AE';
            insert addressobj1;
            
            Address__c addressobj2 = new Address__c();
            addressobj2.Address_ID__c = 12345;
            addressobj2.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj2.ADDRESS_LINE2__c='Cluster E';
            addressobj2.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj2.City__c = 'Dubai';
            addressobj2.Country__c = 'LB';
            insert addressobj2;
            
            Address__c addressobj3 = new Address__c();
            addressobj3.Address_ID__c = 12346;
            addressobj3.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj3.ADDRESS_LINE2__c='Cluster E';
            addressobj3.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj3.City__c = 'Dubai';
            addressObj3.State__c = 'Dubai';
            addressobj3.Country__c = 'QA';
            insert addressobj3;
            
            addressobj3.Latitude__c = '';
            update addressobj3;
            
            Address__c addressobj4 = new Address__c();
            addressobj4.Address_ID__c = 12347;
            addressobj4.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj4.ADDRESS_LINE2__c='Cluster E';
            addressobj4.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj4.City__c = 'Dubai';
            addressobj4.Country__c = 'JO';
            insert addressobj4;
            
            Address__c addressobj5 = new Address__c();
            addressobj5.Address_ID__c = 12348;
            addressobj5.ADDRESS_LINE1__c='Saba Tower 1';
            addressobj5.ADDRESS_LINE2__c='Cluster E';
            addressobj5.ADDRESS_LINE3__c='Jumeirah Lake Towers';
            addressobj5.City__c = 'Riyadh';
            addressobj5.Country__c = 'SA';
            insert addressobj5;
            
            Property__c prop = new Property__c();
            prop.Property_Name__c='Discovery gardens';
            prop.Property_ID__c = 12345;
            prop.Active_Property__c = true;
            insert prop;
            
            Location__c loc1 = new Location__c();
            loc1.Name = 'DGB56';
            loc1.Building_Name__c = 'Discovery Gardens';
            loc1.Address_ID__c = '987654';
            loc1.Location_ID__c = '0001';
            loc1.Property_ID__c = '12345';
            loc1.location_type__c = 'Building';
            loc1.Property_Name__c = prop.id;
            insert loc1;
            
            Location__c loc2 = new Location__c();
            loc2.Name = 'DGB562';
            loc2.Building_Name__c = 'Discovery Gardens';
            loc2.Address_ID__c = '987654';
            loc2.Location_ID__c = '0002';
            loc2.Property_ID__c = '12345';
            loc2.location_type__c = 'Floor';
            loc1.Property_Name__c = prop.id;
            loc2.Parent_id__c = loc1.Location_ID__c;
            insert loc2;
            
            Location__c loc3 = new Location__c();
            loc3.Name = 'DGB562214';
            loc3.Building_Name__c = 'Discovery Gardens';
            loc3.Address_ID__c = '987654';
            loc3.Location_ID__c = '0003';
            loc3.Property_ID__c = '12345';
            loc1.Property_Name__c = prop.id;
            loc3.location_type__c = 'Unit';
            loc3.Parent_id__c = loc2.Location_ID__c;
            insert loc3;
            
            Inventory_Release__c ir = new Inventory_Release__c();
            ir.Property_ID__c = '12345';
            ir.Floor_ID__c = '0002';
            ir.Building_ID__c = '0001';
            ir.Unit_ID__c = '0003';
            ir.Release_ID__c = '12345';
            insert ir;
            
            Inventory__c inv = new Inventory__c();
            inv.Inventory_ID__c = '0003';
            inv.Address_Id__c = '987654';
            inv.Building_ID__c = '0001';
            inv.Floor_ID__c = '0002';
            inv.Unit_ID__c = '0003';
            inv.Property_ID__c = '12345';
            inv.Release_ID__c='12345';
            inv.Unit_Location__c = loc3.id;
            inv.Marketing_Name__c = 'Discovery Garden';
            inv.IPMS_Bedrooms__c='RELEASED';
            inv.Space_Type_Lookup_Code__c = 'beack view';
            inv.Brand__c = 'Damac';
            inv.IPMS_Bedrooms__c = '1 BHK';
            inv.Unit_Type__c = 'Residence';
            inv.Building_Location__c = loc1.id;
            inv.Project_Category__c = 'Hotel';
            inv.Property_Status__c = 'off plan';
            inv.Status__c = 'Released';
            DAMAC_Constants.skip_InventoryTrigger = true;
            insert inv;
            
            Campaign_Inventory__c camInv = InitialiseTestData.createCampaignInvnetory(camp.id,inv.id);
            insert camInv;
            
            Promotion__c promotion = InitialiseTestData.createPromotion(camp.id,'Damac Promotion');
            insert promotion;
            
            Guided_Sales__c guided = InitialiseTestData.createGuidedSales(inquiryRec.id);
            
            
            Payment_Plan__c paymentPlan = InitialiseTestData.getPaymentPlan(loc1.id);
            insert paymentPlan;
            
            Payment_Terms__c paymentTerm = InitialiseTestData.getPaymentTerm(paymentPlan.id);
            insert paymentTerm;
            
            guidedSales.selectedInventory = inv.id;
            guidedSales.newGuidedSales = guided;
            guidedSales.regularReturn = true;
            guidedSales.selectedProjectName = 'Discovery Garden';
            guidedSales.selectedProjectID = prop.id;
            //cover the NavigationPage
            guidedSales.nextPage = 1;
            guidedSales.navigatePages();
            guidedSales.nextPage = 2;
            guidedSales.currentPage = 1;
            guidedSales.navigatePages();
            guidedSales.nextPage = 3;
            guidedSales.currentPage = 2;
            guidedSales.navigatePages();
            guidedSales.nextPage = 4;
            guidedSales.currentPage = 3;
            guidedSales.navigatePages();
            guidedSales.nextPage = 5;
            guidedSales.currentPage = 4;
            guidedSales.navigatePages();
            guidedSales.selectedInventory=inv.id;
            guidedSales.inventoryDetailPage();
            
            //Cover the variables
            System.debug('== > '+guidedSales.allMasterDevelopers);
            System.debug('== > '+guidedSales.errorMessages);
            System.debug('== > '+guidedSales.inquiryId);
            guidedSales.splitRangeString('400K - 1M',false);
            guidedSales.splitRangeString('400K - 1M',false);
            guidedSales.newGuidedSales.Project__c = 'Discovery Garden';
            guidedSales.getProperyFetures();
            guidedSales.backtoProjectInventories();
            guidedSales.doDone();
            //guidedSales.getAllInventoryDistrict();
            //guidedSales.getAllInventoryProjects();
            guidedSales.getAllPicklistValues();
            
        }
        
    }
    
}