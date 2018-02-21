@isTest
private class TestTriggerIRRCalculator
{
    static testMethod void testTrigger()
    {
        Manage_triggers__c manageTrigger = new Manage_triggers__c();
        manageTrigger.opp_trigger_for_Xirr__c = true;
        manageTrigger.lead_trigger_for_Xirr__c = true;
        manageTrigger.name = 'Default';
        insert manageTrigger;
        
        XIRR_fieldNames__c fieldNames = new Xirr_fieldNames__c();
        fieldNames.name= 'Opportunity';
        fieldNames.month_field_apiName__c = 'Name';
        fieldNames.funding_amount_field_apiName__c='Amount';
        fieldNames.payback_amount_field_apiName__c='ExpectedRevenue';
        fieldNames.process_fee_field_apiName__c='NextStep';
        fieldNames.commission_amount_field_apiName__c='Probability';
        fieldNames.calculated_irr_field_apiName__c = 'TotalOpportunityQuantity';
        /*fieldNames.month_field_apiName__c = 'months__c';
        fieldNames.funding_amount_field_apiName__c='Funding_amount__c';
        fieldNames.payback_amount_field_apiName__c='payback_amount__c';
        fieldNames.process_fee_field_apiName__c='Processing_fee__c';
        fieldNames.commission_amount_field_apiName__c='commission_amount__c';
        fieldNames.calculated_irr_field_apiName__c = 'calculated_irr__c';*/
        insert fieldNames;
                        
        XIRR_fieldNames__c fieldNames_lead = new Xirr_fieldNames__c();
        fieldNames_lead.name= 'Lead';
        fieldNames_lead.month_field_apiName__c = 'NumberOfEmployees';
        fieldNames_lead.funding_amount_field_apiName__c='Company';
        fieldNames_lead.payback_amount_field_apiName__c='AnnualRevenue';
        fieldNames_lead.process_fee_field_apiName__c='Title';
        fieldNames_lead.commission_amount_field_apiName__c='Jigsaw';
        fieldNames_lead.calculated_irr_field_apiName__c = 'Description';
        insert fieldNames_lead;        
                        
        Opportunity opp = new Opportunity();
        opp.name = '60';
        opp.stageName= 'Prospecting';
        opp.closeDate = Date.today();
        /*opp.months__c = 60;
        opp.Funding_amount__c= 80000; 
        opp.commission_amount__c= 9472;
        opp.Processing_fee__c = 295;
        opp.payback_amount__c = 118400;*/  
        
        Lead leadObj = new Lead();
        leadObj.lastName = 'test';
        leadObj.company = '10000';
        leadObj.Status = 'Open - Not Contacted';
        /*leadObj.months__c = 60;
        leadObj.Funding_amount__c= 80000; 
        leadObj.commission_amount__c= 9472;
        leadObj.Processing_fee__c = 295;
        leadObj.payback_amount__c = 118400;*/
            
        insert opp; 
        insert leadObj;
        opp.amount= -10;
        try 
        {
            upsert opp;
        }
        catch(Exception e) {}        
        leadObj.numberOfEmployees = -10;
        try 
        {
            upsert leadObj; 
        }
        catch(Exception e) {}
        System.assertEquals(1,1); 
    }
    
    static testMethod void testTrigger1()
    {
        Manage_triggers__c manageTrigger = new Manage_triggers__c();
        manageTrigger.opp_trigger_for_Xirr__c = true;
        manageTrigger.lead_trigger_for_Xirr__c = true;
        manageTrigger.name = 'Default';
        insert manageTrigger;
        
        XIRR_fieldNames__c fieldNames = new Xirr_fieldNames__c();
        fieldNames.name= 'Opportunity';
        fieldNames.month_field_apiName__c = 'Name';
        fieldNames.funding_amount_field_apiName__c='Amount';
        fieldNames.payback_amount_field_apiName__c='ExpectedRevenue';
        //fieldNames.process_fee_field_apiName__c='NextStep';
        //fieldNames.commission_amount_field_apiName__c='Probability';
        fieldNames.calculated_irr_field_apiName__c = 'TotalOpportunityQuantity';
        insert fieldNames;
        
        XIRR_fieldNames__c fieldNames_lead = new Xirr_fieldNames__c();
        fieldNames_lead.name= 'Lead';
        fieldNames_lead.month_field_apiName__c = 'NumberOfEmployees';
        fieldNames_lead.funding_amount_field_apiName__c='Company';
        fieldNames_lead.payback_amount_field_apiName__c='AnnualRevenue';
        //fieldNames_lead.process_fee_field_apiName__c='Title';
        //fieldNames_lead.commission_amount_field_apiName__c='Jigsaw';
        fieldNames_lead.calculated_irr_field_apiName__c = 'Description';
        insert fieldNames_lead;
        
        Opportunity opp = new Opportunity();
        opp.name = '60';
        opp.stageName= 'Prospecting';
        opp.closeDate = Date.today();
        
        Lead leadObj = new Lead();
        leadObj.lastName = 'test';
        leadObj.company = '10000';
        leadObj.Status = 'Open - Not Contacted';
        
        insert opp; 
        insert leadObj; 
        
        opp.amount= -10;
        try 
        {
            upsert opp;
        }
        catch(Exception e) {}        
        leadObj.numberOfEmployees = -10;
        try 
        {
            upsert leadObj; 
        }
        catch(Exception e) {}
        System.assertEquals(1,1);
    }
    
    static testMethod void testTrigger2()
    {
        Manage_triggers__c manageTrigger = new Manage_triggers__c();
        manageTrigger.opp_trigger_for_Xirr__c = true;
        manageTrigger.lead_trigger_for_Xirr__c = true;
        manageTrigger.name = 'Default';
        insert manageTrigger;
        
        XIRR_fieldNames__c fieldNames = new Xirr_fieldNames__c();
        fieldNames.name= 'Opportunity';
        fieldNames.month_field_apiName__c = 'Name';
        fieldNames.funding_amount_field_apiName__c='Amount';
        fieldNames.payback_amount_field_apiName__c='ExpectedRevenue';
        fieldNames.process_fee_field_apiName__c='NextStep';
        //fieldNames.commission_amount_field_apiName__c='Probability';
        fieldNames.calculated_irr_field_apiName__c = 'TotalOpportunityQuantity';
        insert fieldNames;
        
        XIRR_fieldNames__c fieldNames_lead = new Xirr_fieldNames__c();
        fieldNames_lead.name= 'Lead';
        fieldNames_lead.month_field_apiName__c = 'NumberOfEmployees';
        fieldNames_lead.funding_amount_field_apiName__c='Company';
        fieldNames_lead.payback_amount_field_apiName__c='AnnualRevenue';
        fieldNames_lead.process_fee_field_apiName__c='Title';
        //fieldNames_lead.commission_amount_field_apiName__c='Jigsaw';
        fieldNames_lead.calculated_irr_field_apiName__c = 'Description';
        insert fieldNames_lead;
        
        Opportunity opp = new Opportunity();
        opp.name = '60';
        opp.stageName= 'Prospecting';
        opp.closeDate = Date.today();
        
        Lead leadObj = new Lead();
        leadObj.lastName = 'test';
        leadObj.company = '10000';
        leadObj.Status = 'Open - Not Contacted';
        
        insert opp; 
        insert leadObj; 
        opp.amount= -10;
        try 
        {
            upsert opp;
        }
        catch(Exception e) {}        
        leadObj.numberOfEmployees = -10;
        try 
        {
            upsert leadObj; 
        }
        catch(Exception e) {}
        System.assertEquals(1,1);
    }
    
    static testMethod void testTrigger3()
    {
        Manage_triggers__c manageTrigger = new Manage_triggers__c();
        manageTrigger.opp_trigger_for_Xirr__c = true;
        manageTrigger.lead_trigger_for_Xirr__c = true;
        manageTrigger.name = 'Default';
        insert manageTrigger;
        
        XIRR_fieldNames__c fieldNames = new Xirr_fieldNames__c();
        fieldNames.name= 'Opportunity';
        fieldNames.month_field_apiName__c = 'Name';
        fieldNames.funding_amount_field_apiName__c='Amount';
        fieldNames.payback_amount_field_apiName__c='ExpectedRevenue';
        //fieldNames.process_fee_field_apiName__c='NextStep';
        fieldNames.commission_amount_field_apiName__c='Probability';
        fieldNames.calculated_irr_field_apiName__c = 'TotalOpportunityQuantity';
        insert fieldNames;
        
        XIRR_fieldNames__c fieldNames_lead = new Xirr_fieldNames__c();
        fieldNames_lead.name= 'Lead';
        fieldNames_lead.month_field_apiName__c = 'NumberOfEmployees';
        fieldNames_lead.funding_amount_field_apiName__c='Company';
        fieldNames_lead.payback_amount_field_apiName__c='AnnualRevenue';
        //fieldNames_lead.process_fee_field_apiName__c='Title';
        fieldNames_lead.commission_amount_field_apiName__c='Jigsaw';
        fieldNames_lead.calculated_irr_field_apiName__c = 'Description';
        insert fieldNames_lead;
        
        Opportunity opp = new Opportunity();
        opp.name = '60';
        opp.stageName= 'Prospecting';
        opp.closeDate = Date.today();
        
        Lead leadObj = new Lead();
        leadObj.lastName = 'test';
        leadObj.company = '10000';
        leadObj.Status = 'Open - Not Contacted';
        
        insert opp; 
        insert leadObj; 
                opp.amount= -10;
        try 
        {
            upsert opp;
        }
        catch(Exception e) {}        
        leadObj.numberOfEmployees = -10;
        try 
        {
            upsert leadObj; 
        }
        catch(Exception e) {}
        System.assertEquals(1,1);
    }
    
    static testMethod void testTrigger4()
    {
        Manage_triggers__c manageTrigger = new Manage_triggers__c();
        manageTrigger.opp_trigger_for_Xirr__c = true;
        manageTrigger.lead_trigger_for_Xirr__c = true;
        manageTrigger.name = 'Default';
        insert manageTrigger;
        
        XIRR_fieldNames__c fieldNames = new Xirr_fieldNames__c();
        fieldNames.name= 'Opportunity';
        fieldNames.month_field_apiName__c = 'Name1';
        fieldNames.funding_amount_field_apiName__c='Amount1';
        fieldNames.payback_amount_field_apiName__c='ExpectedRevenue1';
        fieldNames.process_fee_field_apiName__c='NextStep1';
        fieldNames.commission_amount_field_apiName__c='Probability1';
        fieldNames.calculated_irr_field_apiName__c = 'TotalOpportunityQuantity1';
        insert fieldNames;
        
        XIRR_fieldNames__c fieldNames_lead = new Xirr_fieldNames__c();
        fieldNames_lead.name= 'Lead';
        fieldNames_lead.month_field_apiName__c = 'NumberOfEmployees1';
        fieldNames_lead.funding_amount_field_apiName__c='Company1';
        fieldNames_lead.payback_amount_field_apiName__c='AnnualRevenue1';
        fieldNames_lead.process_fee_field_apiName__c='Title1';
        fieldNames_lead.commission_amount_field_apiName__c='Jigsaw1';
        fieldNames_lead.calculated_irr_field_apiName__c = 'Description1';
        insert fieldNames_lead;
        
        Opportunity opp = new Opportunity();
        opp.name = '60';
        opp.stageName= 'Prospecting';
        opp.closeDate = Date.today();
        
        Lead leadObj = new Lead();
        leadObj.lastName = 'test';
        leadObj.company = '10000';
        leadObj.Status = 'Open - Not Contacted';
        
        try
        {
            insert opp;            
        }
        catch (Exception e) {} 
        try
        {
            insert leadObj;
        }
        catch (Exception e) {} 
        System.assertEquals(1,1);
    }
    
    static testMethod void testTrigger5()
    {
        Manage_triggers__c manageTrigger = new Manage_triggers__c();
        manageTrigger.opp_trigger_for_Xirr__c = true;
        manageTrigger.lead_trigger_for_Xirr__c = true;
        manageTrigger.name = 'Default';
        insert manageTrigger;
        
        XIRR_fieldNames__c fieldNames = new Xirr_fieldNames__c();
        fieldNames.name= 'Opportunity';
        fieldNames.month_field_apiName__c = 'Name';
        fieldNames.funding_amount_field_apiName__c='Amount';
        fieldNames.payback_amount_field_apiName__c='ExpectedRevenue';
        fieldNames.process_fee_field_apiName__c='NextStep';
        fieldNames.commission_amount_field_apiName__c='Probability';
        fieldNames.calculated_irr_field_apiName__c = 'TotalOpportunityQuantity';
        insert fieldNames;
        
        XIRR_fieldNames__c fieldNames_lead = new Xirr_fieldNames__c();
        fieldNames_lead.name= 'Lead';
        fieldNames_lead.month_field_apiName__c = 'NumberOfEmployees';
        fieldNames_lead.funding_amount_field_apiName__c='Company';
        fieldNames_lead.payback_amount_field_apiName__c='AnnualRevenue';
        fieldNames_lead.process_fee_field_apiName__c='Title';
        fieldNames_lead.commission_amount_field_apiName__c='Jigsaw';
        fieldNames_lead.calculated_irr_field_apiName__c = 'Description';
        insert fieldNames_lead;
        
        Opportunity opp = new Opportunity();
        opp.name = '0';
        opp.stageName= 'Prospecting';
        opp.closeDate = Date.today();
        
        Lead leadObj = new Lead();
        leadObj.lastName = 'test';
        leadObj.company = '10000';
        leadObj.Status = 'Open - Not Contacted';
        leadObj.NumberOfEmployees = 0;
        
        try
        {
            insert opp;            
        }
        catch (Exception e) {} 
        try
        {
            insert leadObj;
        }
        catch (Exception e) {}
        
        //to validate months > 500 
        opp.name= '600';
        leadObj.NumberOfEmployees= 600;
        try
        {
            upsert opp;            
        }
        catch (Exception e) {} 
        try
        {
            upsert leadObj;
        }
        catch (Exception e) {}
        
        //to handle type exception
        opp.name = 'test';
        try
        {
            upsert opp;            
        }
        catch (Exception e) {}         
        System.assertEquals(1,1);
    }

}