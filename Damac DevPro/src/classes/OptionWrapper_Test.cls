/*
================================================================================
*    Description:  Test Class for  OptionWrapper 
     Version    Date          Author                 Description
*    1.0        26/06/2017    Naresh kaneriya        Initial Draft
*    
================================================================================
*/

@isTest(SeeAllData = false)
public class OptionWrapper_Test{
static testmethod void addPricebookEntries() {

    String json=        '{  '+
        '   "items":[  '+
        '      {  '+
        '         "currencyCode":"USD",'+
        '         "dealSR":"SR-56634",'+
        '         "TokenAmountApprovalStatus":"",'+
        '         "unitIDRef":"DT/13A/1304",'+
        '         "promotionName":" ",'+
        '         "promotionValue":" ",'+
        '         "campaignName":" ",'+
        '         "campaignValue":" ",'+
        '         "optionsName":" ",'+
        '         "optionsValue":" ",'+
        '         "schemeName":" ",'+
        '         "schemeValue":" ",'+
        '         "templateIdSN":"Ramadan Ready Home Promo",'+
        '         "templateIdCN":"Rebate of AED150,000 in lieu of Car Offer",'+
        '         "templateIdPN":"",'+
        '         "templateIdOP":"",'+
        '         "templateIdOP1":"OXYGEN Serviced and Furnished promo",'+
        '         "templateIdOP2":"Zero Community Charge for 15 Yrs Promo",'+
        '         "templateIdOP3":"",'+
        '         "templateIdOP4":"",'+
        '         "templateIdOP5":"",'+
        '         "netPriceVal":"1590000.00",'+
        '         "CMPricePerSqftAfter":"1590323.7732000002"'+
        '      }'+
        '   ]'+
        '}';
        OptionWrapper obj = OptionWrapper.parse(json);
        System.assert(obj != null);




}


}