@isTest 
private class AsyncAgentWebServiceTest{

    @isTest static void Test1() {
    
    
    Account acc= new Account();
    acc.name='Agency1';
    insert acc;
    
    List<id> accids= new List<id>();
    accids.add(acc.id);
    
    Agent_Site__c site= new Agent_Site__c();
    site.Agency__c=acc.id;
    site.name='UAE';
    insert site;
    
    List<id> siteids= new List<id>();
    siteids.add(site.id);
    string body = '';
    
    
    
    AsyncAgentWebservice cls = new AsyncAgentWebservice (accids,'Agent creation');
    
    AsyncAgentWebservice.getIPMSsetting();
    
    AsyncAgentWebservice.preparesoapHeader('test');
    AsyncAgentWebservice.prepareAgentCreate(accids);
    AsyncAgentWebservice.sendAgentCreate(accids);
    body= SetResponse(acc.id);
    AsyncAgentWebservice.parseAgentCreateResponse(body); 
    
    AsyncAgentWebservice.prepareAgentUpdate(accids);
    AsyncAgentWebservice.sendAgentUpdate(accids);
    AsyncAgentWebservice.parseAgentUpdateResponse(body);
    
    AsyncAgentWebservice.prepareBankUpdate(accids);
    AsyncAgentWebservice.sendBankUpdate(accids);
    AsyncAgentWebservice.parseBankUpdateResponse(body);
    
    body= SetResponse(site.id);
    AsyncAgentWebservice.prepareAgentSiteCreate(siteids);
    AsyncAgentWebservice.sendAgentSiteCreate(siteids);
    AsyncAgentWebservice.parseAgentSiteCreateResponse(body);
    
    AsyncAgentWebservice.prepareAgentSiteUpdate(siteids);
    AsyncAgentWebservice.sendAgentSiteUpdate(siteids);
    AsyncAgentWebservice.parseAgentSiteUpdateResponse(body);
    
    
    
    Date d = Date.newinstance(25,12,2017);
    AsyncAgentWebservice.GetDatetext(d);
    }
    
    private static string SetResponse(String idval){
        string body = '';
        body+='<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
        body+='<env:Header/>';
        body+='<env:Body>';
          body+='<OutputParameters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/process/">';
             body+='<X_RESPONSE_MESSAGE>';
                body+='<X_RESPONSE_MESSAGE_ITEM>';
                   body+='<PARAM_ID>'+idval+'</PARAM_ID>';
                   body+='<PROC_STATUS>S</PROC_STATUS>';
                   body+='<PROC_MESSAGE>Bank :SFDC Test Bank One Created for Vendor with Id:810117</PROC_MESSAGE>';
                   body+='<ATTRIBUTE1>810117</ATTRIBUTE1>';
                   body+='<ATTRIBUTE2>1274778</ATTRIBUTE2>';
                   body+='<ATTRIBUTE3>1274779</ATTRIBUTE3>';
                   body+='<ATTRIBUTE4 xsi:nil="true"/>';
                body+='</X_RESPONSE_MESSAGE_ITEM>';
             body+='</X_RESPONSE_MESSAGE>';
             body+='<X_RETURN_STATUS>S</X_RETURN_STATUS>';
             body+='<X_RETURN_MESSAGE>Process Completed successfully...</X_RETURN_MESSAGE>';
          body+='</OutputParameters>';
        body+='</env:Body>';
        body+='</env:Envelope>';
        body=body.trim();
        body= body.replaceAll('null', '');
        body=body.trim();
        
        return body;
    }

}