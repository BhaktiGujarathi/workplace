/*********************************************************************************
* Name               : DH_DroolcalloutServiceTest
* Description        :Test class for wrpper class DH_DroolcalloutService.
*----------------------------------------------------------------------------------
* VERSION     AUTHOR            DATE          COMMENTS 
  1.0         Pratiksha(Accely) 11-07-2017
  1.1         Naresh (Accely)   11-07-2017   Set Response Output in Body
**********************************************************************************/

global class DH_DroolCalloutServiceMock  implements HTTPCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
      
        String Body =        '{'+
        '    "data": ['+
        '        {'+
        '            "0": {'+
        '                "option2Price": 10000,'+
        '                "discountPSF_CN": 40,'+
        '                "subCategory": "null",'+
        '                "dateofBooking": 1499731200000,'+
        '                "waiverIdCN": null,'+
        '                "campId": "4",'+
        '                "waiverCN": "DLD 50%",'+
        '                "campName": "Delhi Roadshow",'+
        '                "option1Name": "Option 1 dummy",'+
        '                "price": 1590000,'+
        '                "templateIdOP5": null,'+
        '                "templateIdOP4": null,'+
        '                "templateIdOP3": null,'+
        '                "templateIdOP2": "Zero Community Charge for 15 Yrs Promo",'+
        '                "templateIdOP1": "OXYGEN Serviced and Furnished promo",'+
        '                "giftCN": "Maserati Car",'+
        '                "discountFlatCN": 50000,'+
        '                "customerThresholdOld": 10000,'+
        '                "noofUnitsInput": 0,'+
        '                "noofunitsinputPN": 0,'+
        '                "option4Id": null,'+
        '                "templateIdOP6": null,'+
        '                "option3Price": 0,'+
        '                "option3Name": null,'+
        '                "giftSN": "Audi A4",'+
        '                "buildingName": "DT",'+
        '                "noofUnits": 1,'+
        '                "templateIdPN": null,'+
        '                "discountPercentPN": 0,'+
        '                "promoIdPN": 0,'+
        '                "waiveridSN": null,'+
        '                "facing": null,'+
        '                "option5Name": null,'+
        '                "customerThresOutPN": null,'+
        '                "discountFlatSN": 10000,'+
        '                "inventoryThresholdOld": 10000,'+
        '                "customerId": null,'+
        '                "pcId": "POC User1",'+
        '                "inventoryThreshold": 0,'+
        '                "option5Id": null,'+
        '                "totalDealValue": 1590000,'+
        '                "option1Id": "1",'+
        '                "priceChangePSF": 0,'+
        '                "discountPSF_OP1": -999999,'+
        '                "unitIdPN": null,'+
        '                "discountPSF_OP3": 0,'+
        '                "marketingProject": "DAMAC TOWER WITH INTERIORS BY VERSACE - LEBANON",'+
        '                "discountPSF_OP2": -999999,'+
        '                "unitIdPP": null,'+
        '                "discountPSF_OP5": 0,'+
        '                "inLeuPN": null,'+
        '                "discountPSF_OP4": 0,'+
        '                "inventoryId": null,'+
        '                "discountPSF_OP6": 0,'+
        '                "option1Price": 0,'+
        '                "option4Price": 0,'+
        '                "waiverSN": "DLD 4%",'+
        '                "promoIdOutputPN": null,'+
        '                "promoNamePN": null,'+
        '                "totalArea": 187,'+
        '                "agent": "null",'+
        '                "campaignNameInput": "null",'+
        '                "numberofBedrooms": "2",'+
        '                "discountPSF_PN": 0,'+
        '                "waiverIdPN": null,'+
        '                "schemeIdIn": "8",'+
        '                "giftPN": null,'+
        '                "residence": "Minsk",'+
        '                "discountPercentSN": 2,'+
        '                "option2Name": "Option 2 Dummy",'+
        '                "templateIdSN": "Ramadan Ready Home Promo",'+
        '                "area": 187,'+
        '                "waiverPN": null,'+
        '                "option6Id": null,'+
        '                "option2Id": "2",'+
        '                "option6Price": 0,'+
        '                "discountPercentCN": 2,'+
        '                "customerthresholdValue": 0,'+
        '                "templateIdCN": "Rebate of AED150,000 in lieu of Car Offer",'+
        '                "option4Name": null,'+
        '                "projectName": "Damac Tower",'+
        '                "region": "Belarus",'+
        '                "discountFlatPN": 0,'+
        '                "paymentAtMilestone": null,'+
        '                "totalDealValuePN": 0,'+
        '                "option5Price": 0,'+
        '                "option6Name": null,'+
        '                "discountPercentOP4": 0,'+
        '                "discountPercentOP3": 0,'+
        '                "campaignIdInput": null,'+
        '                "discountPercentOP2": -999999,'+
        '                "discountPercentOP1": -999999,'+
        '                "cunstructionStatus": "Off Plan",'+
        '                "priceChangePN": 0,'+
        '                "schemeId": 8,'+
        '                "inLeuSN": "150,000 rebate",'+
        '                "promoNameSN": "Test Discount",'+
        '                "discountPercentOP6": 0,'+
        '                "bedroomType": "2 BR",'+
        '                "discountPercentOP5": 0,'+
        '                "floor": "DT/13A",'+
        '                "priceChangePer": 0,'+
        '                "productType": "USD",'+
        '                "views": "null",'+
        '                "inLeuCN": "100000 rebate",'+
        '                "totalAreaPN": 0,'+
        '                "unitIdCN": "DT/13A/1304",'+
        '                "discountFlatOP1": -999999,'+
        '                "discountFlatOP2": -999999,'+
        '                "option3Id": null,'+
        '                "inventoryThreshOutPN": null,'+
        '                "discountFlatOP5": 0,'+
        '                "discountFlatOP6": 0,'+
        '                "discountFlatOP3": 0,'+
        '                "discountFlatOP4": 0,'+
        '                "discountPSF_SN": 100,'+
        '                "category": "Residential"'+
        '            }'+
        '        }'+
        '    ]'+
        '}';
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(Body);
        res.setStatusCode(200);
        return res;
    }
}