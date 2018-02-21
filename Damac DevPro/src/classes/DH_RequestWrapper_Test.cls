/**************************************************************************************************
* Name               : DH_RequestWrapper_Test*
* Description        : Test Class For  DH_RequestWrapper                  *
* Created Date       : 9/07/2017                                                           *
==================================================================================================
* VERSION     AUTHOR              DATE          COMMENTS 
  1.0         Naresh(Accely)      09-07-2017    Initial draft
  1.1         Pratiksha(Accely)   10-07-2017    Added new code for code coverage
                                                                                            *
**************************************************************************************************/
@isTest
public class DH_RequestWrapper_Test{
static testMethod void DH_DH_RequestWrapperTestMethod(){
    test.startTest();
    DH_RequestWrapper objDH_RequestWrapper = new DH_RequestWrapper();
 
    List<DH_RequestWrapper.cls_demo_project1_InOutObject> obj1 = new  List<DH_RequestWrapper.cls_demo_project1_InOutObject>();
    DH_RequestWrapper.cls_demo_project1_InOutObject  varDH_RequestWrapper = new  DH_RequestWrapper.cls_demo_project1_InOutObject();
    
    varDH_RequestWrapper.dateofBooking = 'test';
    varDH_RequestWrapper.marketingProject = 'test';
    varDH_RequestWrapper.projectName = 'test';
    varDH_RequestWrapper.buildingName = 'test';
    varDH_RequestWrapper.bedroomType = 'test';
    varDH_RequestWrapper.numberofBedrooms = 'test';
    varDH_RequestWrapper.floor = 'test'; 
    varDH_RequestWrapper.category = 'test'; 
    varDH_RequestWrapper.subCategory = 'test';
    varDH_RequestWrapper.cunstructionStatus = 'test'; 
    varDH_RequestWrapper.productType = 'test';
    varDH_RequestWrapper.campaignNameInput = 'test';
    varDH_RequestWrapper.residence = 'test'; 
    varDH_RequestWrapper.region = 'test'; 
    varDH_RequestWrapper.agent = 'test';
    varDH_RequestWrapper.pcId = 'test';
    varDH_RequestWrapper.unitIdCN = 'test'; 
    varDH_RequestWrapper.area = 11 ; 
    varDH_RequestWrapper.inventoryThreshold = 11 ;
    varDH_RequestWrapper.customerthresholdValue = 11 ; 
    varDH_RequestWrapper.price = 11 ; 
    varDH_RequestWrapper.noofUnits = 11 ;
    varDH_RequestWrapper.totalArea = 11 ;
    varDH_RequestWrapper.noofUnitsInput = 11 ; 
    varDH_RequestWrapper.totalDealValue = 11 ;
    varDH_RequestWrapper.schemeId = 11 ;
    varDH_RequestWrapper.noofunitsinputPN = 11 ;
    varDH_RequestWrapper.totalAreaPN = 11 ;
    varDH_RequestWrapper.totalDealValuePN = 11 ;
    varDH_RequestWrapper.promoIdPN = 11 ;
    obj1.add(varDH_RequestWrapper);
   
    DH_RequestWrapper.cls_object objclsobject = new DH_RequestWrapper.cls_object();
    objclsobject.demo_project1_InOutObject = obj1;
    
    DH_RequestWrapper.cls_insert objcls_insert = new DH_RequestWrapper.cls_insert();
    objcls_insert.out_identifier ='test';
    objcls_insert.object_1 = objclsobject;
    
    DH_RequestWrapper.cls_commands objcls_commands  = new DH_RequestWrapper.cls_commands();
    objcls_commands.insert_1 = objcls_insert;
    
    List<DH_RequestWrapper.cls_commands> listTest = new List<DH_RequestWrapper.cls_commands>();
    listTest.add(objcls_commands);
    objDH_RequestWrapper.commands = listTest;
    test.stopTest();
}

}