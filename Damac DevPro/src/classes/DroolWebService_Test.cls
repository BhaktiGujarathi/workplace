/**************************************************************************************************
* Name               : DroolWebService                                                   *
* Description        : The Test Class for DroolWebService            *
* Created Date       : 11/07/2017                                                                 *
* Created By         : Naresh Kaneriya                                                                        *
                                    *
**************************************************************************************************/
@isTest(SeeAllData = false)
public class DroolWebService_Test{

   static testmethod void PaymentPlanController_methods(){
        Trg_Ctrl_Var__c active = new Trg_Ctrl_Var__c();
        active.name = 'trg_Campaign';
        active.Activate__c = true;
        insert active;
        
        
        Id RecTypeid = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Standalone').getRecordTypeId();
        Campaign__c c = new Campaign__c();
        c.Campaign_Name__c = 'Standalone';
        C.End_Date__c = system.today();
        C.Marketing_End_Date__c = system.today();
        C.Marketing_Start_Date__c = system.today();
        C.Start_Date__c = system.today();
        insert c;
            
        Promotion__c pro = new Promotion__c();
        pro.Start_Date__c= system.today().adddays(-10);
        pro.end_date__c = system.today().adddays(10);
        pro.Promotion_Title__c = 'abc';
        pro.campaign__c = c.id;
        insert pro;
        
        Location__c objLoc = InitializeSRDataTest.createLocation('123','Building');
        objLoc.Name = 'DEB/7/703' ;
        insert objLoc;   
        
        
        Inventory__c lstInv = new Inventory__c();
        lstInv.Property_Country__c = 'United Arab Emirates';
        lstInv.Property_City__c = 'Dubai';
        lstInv.Inventory_ID__c = '345wer';
        lstInv.Unit_Location__c= objLoc.Id;
        lstInv.Special_Price__c = 2212;
        insert lstInv;  
        
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Deal',true,null);
        insert sr;
        
        Booking__c book = new booking__c();
        book.Deal_SR__c = sr.id;
        book.Booking_Channel__c = 'Web';
        insert book;
        
        Booking_Unit__c bu = new Booking_Unit__c();
        bu.Booking__c = book.id;
        bu.Payment_Method__c = 'Cash';
        bu.Primary_Buyer_s_Email__c = 'raviteja@nsiglobal.com';
        bu.Primary_Buyer_s_Name__c = 'testNSI';
        bu.Primary_Buyer_s_Nationality__c = 'test';
        bu.Inventory__c = lstInv.id;
        insert bu;
        
        Set<Id> BUid =  new Set<Id>();
        BUid.add(bu.Id);
       
        Option__c OpList = new Option__c();
        OpList.Booking_Unit__c = bu.Id ;
        OpList.PromotionName__c  = 'Test' ;
        insert OpList ;
        
        buyer__c b = new buyer__c();
        b.Buyer_Type__c =  'Individual';
        b.Address_Line_1__c =  'Ad1';
        b.Country__c =  'United Arab Emirates';
        b.City__c = 'Dubai' ;
        b.Date_of_Birth__c = string.valueof(system.today().addyears(-30)) ;
        b.Email__c = 'test@test.com';
        b.First_Name__c = 'firstname' ;
        b.Last_Name__c =  'lastname';
        b.Nationality__c = 'Indian' ;
        b.Passport_Expiry_Date__c = string.valueof(system.today().addyears(20)) ;
        b.Passport_Number__c = 'J0565556' ;
        b.Phone__c = '569098767' ;
        b.Phone_Country_Code__c = 'United Arab Emirates: 00971' ;
        b.Place_of_Issue__c =  'India';
        b.Title__c = 'Mr';
        b.booking__c = book.id;
        insert b;
        
        
        buyer__c b1 = new buyer__c();
        b1.Buyer_Type__c =  'Individual';
        b1.Address_Line_1__c =  'Ad1';
        b1.Country__c =  'United Arab Emirates';
        b1.City__c = 'Dubai' ;
        b1.Date_of_Birth__c = string.valueof(system.today().addyears(-30)) ;
        b1.Email__c = 'test@test.com';
        b1.First_Name__c = 'firstname' ;
        b1.Last_Name__c =  'lastname';
        b1.Nationality__c = 'Indian' ;
        b1.Passport_Expiry_Date__c = string.valueof(system.today().addyears(20)) ;
        b1.Passport_Number__c = 'J0565556' ;
        b1.Phone__c = '569098767' ;
        b1.Phone_Country_Code__c = 'United Arab Emirates: 00971' ;
        b1.Place_of_Issue__c =  'India';
        b1.Title__c = 'Mr';
        b1.booking__c = book.id;
        insert b1;
           
        list<buyer__c> buyerLst = new list<buyer__c>();
        buyerlst.add(b);
        buyerlst.add(b1);
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Booking_Unit__c = bu.id;
        pp.Effective_From__c = system.today().adddays(-4);
        pp.Effective_To__c = system.today().adddays(7); 
        pp.Building_Location__c =  objLoc.id;      
        insert pp;
        
        Payment_Terms__c pt = new Payment_Terms__c();
        pt.Payment_Plan__c = pp.id;
        pt.Booking_Unit__c = bu.id;
        pt.Percent_Value__c = '5';
        insert pt;
           
           
           
        list<Payment_Plan__c> pplist = new list<Payment_Plan__c>();
        pplist.add(pp);
        
        map<string,payment_plan__c> payMap = new map<string,payment_plan__c>();
        paymap.put(string.valueof(lstInv.id),pp);  
        
        
        String json=        '{  '+
        '   "items":[  '+
        '      {  '+
        '         "currencyCode":"SAR",'+
        '         "dealSR":"SR-56661",'+
        '         "TokenAmountApprovalStatus":"test",'+
        '         "unitIDRef":"DEB/7/703",'+
        '         "promotionName":" ",'+
        '         "promotionValue":" ",'+
        '         "campaignName":" ",'+
        '         "campaignValue":" ",'+
        '         "optionsName":" ",'+
        '         "optionsValue":" ",'+
        '         "schemeName":" ",'+
        '         "schemeValue":" ",'+
        '         "templateIdSN":"",'+
        '         "templateIdCN":"",'+
        '         "templateIdPN":"",'+
        '         "templateIdOP":"",'+
        '         "templateIdOP1":"",'+
        '         "templateIdOP2":"",'+
        '         "templateIdOP3":"",'+
        '         "templateIdOP4":"",'+
        '         "templateIdOP5":"",'+
        '         "netPriceVal":"4573000.00",'+
        '         "CMPricePerSqftAfter":"4132746.45"'+
        '      }'+
        '   ]'+
        '}';
        
        List<DH_PromotionsWrapper> PromotionW = new List<DH_PromotionsWrapper>();
        
        DH_PromotionsWrapper PromWrap = new DH_PromotionsWrapper();
        
        DH_PromotionsWrapper.optionWrapper obj = new DH_PromotionsWrapper.optionWrapper();
        
        List<SelectOption> Promo = new List<SelectOption>();
        List<SelectOption> Camp= new List<SelectOption>();
        List<SelectOption> Scheme= new List<SelectOption>();
        List<SelectOption> Opn = new List<SelectOption>();
        
        
          Promo.add(new selectOption('Test' , 'Test-Test'));
          Promo.add(new selectOption('Tes' , 'Test-Tes'));
          Camp.add(new selectOption('Test' , 'Test-Test'));
          Camp.add(new selectOption('Tes' , 'Test-Tes'));
          
          Scheme.add(new selectOption('Test' , 'Test-Test'));
          Scheme.add(new selectOption('Tes' , 'Test-Tes'));
          PromWrap.TokenAmountApprovalStatus  = 'Approved' ;
          
          obj.Name = 'Test' ;
          obj.Id= 'Test' ;
          obj.Price = 'Test' ;
          
          List<DH_PromotionsWrapper.optionWrapper> objoptionWrapper = new List<DH_PromotionsWrapper.optionWrapper>();
          objoptionWrapper.add(obj);
         
        PromWrap.optionOptions= objoptionWrapper;
        PromWrap.promotionOptions = Promo ;
        PromWrap.campaignOptions= Camp;
        PromWrap.schemeOptions= Scheme;
        PromotionW.add(PromWrap);
        
        DroolWebService.SaveOption(json);
        Map<Id,List<System.SelectOption>>  OPtMap = DroolWebService.optMap;
        List<DH_PromotionsWrapper>  FinalW=  DroolWebService.finalWrap;
        DroolWebService.getOptionDetails(BUid);
        DroolWebService.createOptionsMapforInventories(PromotionW);
        DroolWebService.createOptionsForOptMap(PromotionW);
        DroolWebService.loadOptionData('Test' , '1202020202' , '123'); 
        
            
   }
            
            
  public static testMethod void ElsePartofcreateOptionsMapforInventories(){
      
       List<DH_PromotionsWrapper> PromotionW = new List<DH_PromotionsWrapper>();
        
        DH_PromotionsWrapper PromWrap = new DH_PromotionsWrapper();
        
        DH_PromotionsWrapper.optionWrapper obj = new DH_PromotionsWrapper.optionWrapper();
        
        List<SelectOption> Promo = new List<SelectOption>();
        List<SelectOption> Camp= new List<SelectOption>();
        List<SelectOption> Scheme= new List<SelectOption>();
        List<SelectOption> Opn = new List<SelectOption>();
        
        
          Promo.add(new selectOption('Test' , 'Test-Test'));
          Promo.add(new selectOption('Tes' , 'Test-Tes'));
          Camp.add(new selectOption('Test' , 'Test-Test'));
          Camp.add(new selectOption('Tes' , 'Test-Tes'));
          
          Scheme.add(new selectOption('Test' , 'Test-Test'));
          Scheme.add(new selectOption('Tes' , 'Test-Tes'));
          PromWrap.TokenAmountApprovalStatus  = 'Test' ;
          
          obj.Name = 'Test' ;
          obj.Id= 'Test' ;
          obj.Price = 'Test' ;
          
          List<DH_PromotionsWrapper.optionWrapper> objoptionWrapper = new List<DH_PromotionsWrapper.optionWrapper>();
          objoptionWrapper.add(obj);
         
        PromWrap.optionOptions= objoptionWrapper;
        PromWrap.promotionOptions = Promo ;
        PromWrap.campaignOptions= Camp;
        PromWrap.schemeOptions= Scheme;
        PromotionW.add(PromWrap);
        
        DroolWebService.createOptionsMapforInventories(PromotionW);
        DroolWebService.createOptionsForOptMap(PromotionW);
      
      
  }     

 
public static testMethod void UtilityWrapperManagerTest(){
     
        Id RecTypeid = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Standalone').getRecordTypeId();
        Campaign__c c = new Campaign__c();
        c.Campaign_Name__c = 'Standalone';
        C.End_Date__c = system.today();
        C.Marketing_End_Date__c = system.today();
        C.Marketing_Start_Date__c = system.today();
        C.Start_Date__c = system.today();
        insert c;
 
        List<buyer__c> BuyerList = new List<buyer__c>();
        Location__c objLoc = InitializeSRDataTest.createLocation('123','Building');
        objLoc.Name = 'DEB/7/703' ;
        insert objLoc;   
        
        
        NSIBPM__Service_Request__c sr = InitializeSRDataTest.getSerReq('Deal',true,null);
        insert sr;
        
    
        
        Booking__c book = new booking__c();
        book.Deal_SR__c = sr.id;
        book.Booking_Channel__c = 'Web';
        insert book;
        
        buyer__c b = new buyer__c();
        b.Buyer_Type__c =  'Individual';
        b.Address_Line_1__c =  'Ad1';
        b.Country__c =  'United Arab Emirates';
        b.City__c = 'Dubai' ;
        b.Date_of_Birth__c = string.valueof(system.today().addyears(-30)) ;
        b.Email__c = 'test@test.com';
        b.First_Name__c = 'firstname' ;
        b.Last_Name__c =  'lastname';
        b.Nationality__c = 'Indian' ;
        b.Passport_Expiry_Date__c = string.valueof(system.today().addyears(20)) ;
        b.Passport_Number__c = 'J0565556' ;
        b.Phone__c = '569098767' ;
        b.Phone_Country_Code__c = 'United Arab Emirates: 00971' ;
        b.Place_of_Issue__c =  'India';
        b.Title__c = 'Mr';
        b.booking__c = book.id;
        insert b;
        BuyerList.add(b);
        
        Inventory__c lstInv = new Inventory__c();
        lstInv.Property_Country__c = 'United Arab Emirates';
        lstInv.Property_City__c = 'Dubai';
        lstInv.Inventory_ID__c = '345wer';
        lstInv.Unit_Location__c= objLoc.Id;
        lstInv.Special_Price__c = 2212;
        insert lstInv;  
        
        
        Campaign_Inventory__c CamInv  =  new Campaign_Inventory__c();
        CamInv.Campaign__c = c.Id ;
        CamInv.Inventory__c = lstInv.Id ;
        insert CamInv ;
        
        UtilityWrapperManager UWM = new UtilityWrapperManager();
        
        List<UtilityWrapperManager> UWMList = new List<UtilityWrapperManager>();
        
        UtilityWrapperManager.SharingWrapper ser = new UtilityWrapperManager.SharingWrapper('test', 'test', 'test', 'test', 'test');
    
        
        UtilityWrapperManager.CampaignWrapper cam = new UtilityWrapperManager.CampaignWrapper(false, new Campaign__c (), new List<Promotion__c> ());
        
     
        
        List<DH_ResponseWrapper> respWrapList=new  List<DH_ResponseWrapper>();

        
        
        UtilityWrapperManager.BookingWrapper BW = new UtilityWrapperManager.BookingWrapper('Damac','Start');
        UtilityWrapperManager.BuildingInorWrapper BInfo = new UtilityWrapperManager.BuildingInorWrapper('1',1,Double.valueOf('10.2'),12.1,15.3,13.3,43.2,'ABC');
        UtilityWrapperManager.PriceRageWrapper pt = new UtilityWrapperManager.PriceRageWrapper(12.3, 23.2);
        UtilityWrapperManager.InventoryDetailsWrapper idw = new UtilityWrapperManager.InventoryDetailsWrapper( '1233245324','1231','test','123432423','Damac','dsfw','test','one','2','2','marketing',12.1,23.2,21.2);
        List<UtilityWrapperManager.InventoryBuyerWrapper> ibw = new List<UtilityWrapperManager.InventoryBuyerWrapper>();
        UtilityWrapperManager.InventoryBuyerWrapper ibwn = new UtilityWrapperManager.InventoryBuyerWrapper(true,false, false, 32.2,3432432.234,'test','test','test','test',3,lstInv,new Booking_Unit__c(),new Map<String, Payment_Plan__c>(),BuyerList);
        
        ibw.add(ibwn);
        UWM.ibwList   = ibw ;
      
        DH_PromotionsWrapper cls= new DH_PromotionsWrapper();
        cls.id ='test';
        cls.templateIdSN ='test';
        cls.templateIdCN ='test';
        cls.templateIdPN ='test';
        cls.templateIdOP ='test';
        cls.templateIdOP1 ='test';
        cls.templateIdOP2 ='test';
        cls.templateIdOP3 ='test';
        cls.templateIdOP4 ='test';
        cls.templateIdOP5 ='test';
        cls.TokenAmountApprovalStatus ='test';
        cls.NetPrice = 10.00;
        cls.productType = 'test';
        List<SelectOption> promotionOptions = cls.promotionOptions;
        List<SelectOption> campaignOptions = cls.campaignOptions;
        List<SelectOption> schemeOptions = cls.schemeOptions;       
        DH_PromotionsWrapper.optionWrapper obj = new DH_PromotionsWrapper.optionWrapper();
        obj.Name = 'test';
        obj.Id = 'test';
        obj.Price = 'test';
        List<DH_PromotionsWrapper.optionWrapper> optOptions=new  List<DH_PromotionsWrapper.optionWrapper>();
        optOptions.add(obj);
                Booking_Unit__c bu = new Booking_Unit__c();
        bu.Booking__c = book.id;
        bu.Payment_Method__c = 'Cash';
        bu.Primary_Buyer_s_Email__c = 'raviteja@nsiglobal.com';
        bu.Primary_Buyer_s_Name__c = 'testNSI';
        bu.Primary_Buyer_s_Nationality__c = 'test';
        bu.Inventory__c = lstInv.id;
        insert bu;
        List<option__c> listOption = new List<option__c>();
        option__c objOpt = new option__c();
         objOpt.PromotionName__c='test';
         objOpt.OptionsName__c='test';
         objOpt.CampaignName__c='test';
         objOpt.SchemeName__c='test';
         objOpt.Booking_Unit__c=bu.ID;
         objOpt.Net_Price__c=1234;
         objOpt.UnitID__c='1234';
         listOption.add(objOpt);
         
         insert listOption;
        //List<DH_PromotionsWrapper.optionWrapper> optionOptions = objoptionWrapper;
        
        
         String body = '{  '+
        '   "commands":[  '+
        '      {  '+
        '         "insert":{  '+
        '            "out_identifier":"InOutObject",'+
        '            "object":{  '+
        '               "demo.project1.InOutObject":[  '+
        '                  {  '+
        '                     "views":"null",'+
        '                     "unitIdCN":"DT/13A/1304",'+
        '                     "totalDealValuePN":0,'+
        '                     "totalDealValue":0,'+
        '                     "totalAreaPN":0,'+
        '                     "totalArea":0,'+
        '                     "subCategory":"null",'+
        '                     "schemeId":6,'+
        '                     "residence":"Minsk",'+
        '                     "region":"Belarus",'+
        '                     "promoIdPN":4,'+
        '                     "projectName":"Damac Tower",'+
        '                     "productType":"USD",'+
        '                     "price":1590000,'+
        '                     "pcId":"POC User1",'+
        '                     "numberofBedrooms":"2",'+
        '                     "noofunitsinputPN":2,'+
        '                     "noofUnitsInput":0,'+
        '                     "noofUnits":0,'+
        '                     "marketingProject":"DAMAC TOWER WITH INTERIORS BY VERSACE - LEBANON",'+
        '                     "inventoryThreshold":0,'+
        '                     "floor":"DT/13A",'+
        '                     "dateofBooking":"2017-07-11",'+
        '                     "customerthresholdValue":0,'+
        '                     "cunstructionStatus":"Off Plan",'+
        '                     "category":"Residential",'+
        '                     "campaignNameInput":"null",'+
        '                     "buildingName":"DT",'+
        '                     "bedroomType":"2 BR",'+
        '                     "area":187,'+
        '                     "agent":"null"'+
        '                  }'+
        '               ]'+
        '            }'+
        '         }'+
        '      }'+
        '   ]'+
        '}';
     
     Test.startTest();
      Test.setMock(HttpCalloutMock.class, new DH_DroolCalloutServiceMock());
     respWrapList = DH_DroolCalloutService.getResponse(body);
     Test.StopTest();
       
       DroolWebService.createRequestData(UWM);
       DroolWebService.createRequestDataApproved(UWM ,listOption);
       
 }

}