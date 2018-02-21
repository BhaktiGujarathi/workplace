/*********************************************************************************
* Name               : DH_DroolcalloutServiceTest
* Description        :Test class for wrpper class DH_DroolcalloutService.
*----------------------------------------------------------------------------------
* VERSION     AUTHOR            DATE          COMMENTS 
  1.0         Pratiksha(Accely) 11-07-2017
  1.1         Naresh (Accely)   11-07-2017    Code Coverage Increase
  **********************************************************************************/

@isTest(SeeAllData = false)
public class DH_DroolCalloutServiceTest {
    static testMethod void DH_DroolCalloutServiceTestMethod() {
      Test.startTest();
      DH_DroolCalloutService objDH_Drool = new DH_DroolCalloutService();
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
     
     
      Test.setMock(HttpCalloutMock.class, new DH_DroolCalloutServiceMock());
      DH_DroolCalloutService.getResponse(body);
      DH_DroolCalloutService.generateRequest();
      Test.stopTest();
     
    }
    
    
     static testMethod void DH_DroolCalloutServiceErrorTest() {
      Test.startTest();
      DH_DroolCalloutService objDH_Drool = new DH_DroolCalloutService();
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
     
     
      Test.setMock(HttpCalloutMock.class, new DH_DroolCalloutServiceErrorMock());
      DH_DroolCalloutService.getResponse(body);
      DH_DroolCalloutService.generateRequest();
      Test.stopTest();
     
    }
    
}