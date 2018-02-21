/**************************************************************************************************
* Name               : AsynAgentWebServiceUtils 
* Description        : This is the queuable webservice class for Agent create/update webservice           
* Created Date       : 08/03/2017                                                                 
* Created By         : NSI - Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE                                                              
* 1.0         NSI - Kaavya    08/03/2017                                                        
**************************************************************************************************/
global class AsyncAgentWebservice implements Queueable, Database.AllowsCallouts {

    public List<id> recordids = new List<id>();
    public string servicetype;
    
    //Defining the constructor
    public AsyncAgentWebservice (List<Id> rids, string svctype){
        recordids=rids;
        servicetype=svctype;   
           
    
    }
    
    //The execute method for the queuable class which contains the callout
    public void execute(QueueableContext context) {
        if(servicetype=='Agent Creation')
        sendAgentCreate(recordids);
        if(servicetype=='Agent Updation')
        sendAgentUpdate(recordids);
        if(servicetype=='Agent Site Creation')
        sendAgentSiteCreate(recordids);
        if(servicetype=='Agent Site Updation')
        sendAgentSiteUpdate(recordids);
        if(servicetype=='Bank Updation')
        sendBankUpdate(recordids);
        //your code including the callout    

    }
    global static string endurl;
    global static string usrname;
    global static string pwd;  
    /**********************Getting the IPMS integration setting*********************************/ 
    
    public static void getIPMSsetting(){
      IPMS_Integration_Settings__mdt ipms= [select id,Endpoint_URL__c,Password__c,  Username__c from IPMS_Integration_Settings__mdt where DeveloperName = 'IPMS_webservice'];
      endurl=ipms.Endpoint_URL__c;
      usrname=ipms.Username__c;      
      pwd=PasswordCryptoGraphy.DecryptPassword(ipms.Password__c);
      system.debug('***IPMS***'+ipms);
      
      system.debug('***PWD***'+pwd);
      
    }
    /**********************Preparing the general header for the http request*********************************/
     
    public static string preparesoapHeader(string body){
   
     body+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xxdc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/" xmlns:proc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/process/">';
       body+='<soapenv:Header>';
          body+='<xxdc:SOAHeader>';
             //body+='<!--Optional:-->';
             body+='<xxdc:Responsibility>ONT_ICP_SUPER_USER</xxdc:Responsibility>';
             //body+='<!--Optional:-->';
             body+='<xxdc:RespApplication>ONT</xxdc:RespApplication>';
             //body+='<!--Optional:-->';
             body+='<xxdc:SecurityGroup>standard</xxdc:SecurityGroup>';
             //body+='<!--Optional:-->';
             body+='<xxdc:NLSLanguage>american</xxdc:NLSLanguage>';
             //body+='<!--Optional:-->';
             body+='<xxdc:Org_Id/>';
          body+='</xxdc:SOAHeader>';
          body+='<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
             body+='<wsse:UsernameToken>';
                body+='<wsse:Username>'+usrname+'</wsse:Username>';
                body+='<wsse:Password>'+pwd+'</wsse:Password>';
             body+='</wsse:UsernameToken>';
          body+='</wsse:Security>';
       body+='</soapenv:Header>';
       return body;
    }
    
    /**********************Preparing the request body for the agent create request*********************************/
    public static string prepareAgentCreate(List<id> agentids){
       
       string accQuery = getCreatableFieldsSOQL('Account');
       accQuery+=' where Id in :agentids';
       List<Account> agentlist= database.query(accQuery);
       
       string body = '';
       body+= preparesoapHeader(body); 
       body+='<soapenv:Body>';
          body+='<proc:InputParameters>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_NUMBER>10001</proc:P_REQUEST_NUMBER>';
             //body+='<!--Optional:-->';
             body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_NAME>REGISTER_SUPPLIER</proc:P_REQUEST_NAME>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_MESSAGE>';
                body+='<!--Zero or more repetitions:-->';
                for(Account agent : agentlist){
                    body+='<proc:P_REQUEST_MESSAGE_ITEM>';
                       //body+='<!--Optional:SFDC ID-->';
                       body+='<proc:PARAM_ID>' + agent.id +'</proc:PARAM_ID>';
                       //body+='<!--Optional:Supplier Name-->';
                       body+='<proc:ATTRIBUTE1>' + agent.name +'</proc:ATTRIBUTE1>';
                       //body+='<!--Optional: P_SUPPLIER_TYPE-->';
                       body+='<proc:ATTRIBUTE2>BROKERS</proc:ATTRIBUTE2>'; //always to be passed as Brokers
                       //body+='<!--Optional:B – bank, C - Check-->';
                       body+='<proc:ATTRIBUTE3>B</proc:ATTRIBUTE3>';// always to be passed as B
                       //body+='<!--Optional:Currency-->';
                       body+='<proc:ATTRIBUTE4>'+agent.Bank_Account_Currency__c+'</proc:ATTRIBUTE4>';
                       //body+='<!--Optional: P_BANK_NAME for B type of Cases in ATTRIBUTE3 -->';
                       body+='<proc:ATTRIBUTE5>'+agent.Bank_Name__c+'</proc:ATTRIBUTE5>';
                       //body+='<!--Optional: P_BANK_NO-->';
                       body+='<proc:ATTRIBUTE6></proc:ATTRIBUTE6>';
                       //body+='<!--Optional: P_BANK_BRANCH-->';
                       body+='<proc:ATTRIBUTE7>'+agent.Bank_Branch__c+'</proc:ATTRIBUTE7>';
                       //body+='<!--Optional: P_BRANCH_NO-->';
                       body+='<proc:ATTRIBUTE8></proc:ATTRIBUTE8>';
                       //body+='<!--Optional: P_BRANCH_CITY-->';
                       body+='<proc:ATTRIBUTE9>'+agent.Bank_City__c+'</proc:ATTRIBUTE9>';
                       //body+='<!--Optional: P_BANK_ACCOUNT_NO-->';
                       body+='<proc:ATTRIBUTE10>'+agent.Bank_Account_Number__c+'</proc:ATTRIBUTE10>';
                       //body+='<!--Optional: P_BANK_ACCT_COUNTRY_CODE (2 Digit ISO Country Code)-->';
                       //body+='<proc:ATTRIBUTE11>'+agent.Bank_Country__c+'</proc:ATTRIBUTE11>';
                       body+='<proc:ATTRIBUTE11>'+DAMACUtility.getCountryCode(agent.Bank_Country__c)+'</proc:ATTRIBUTE11>';
                       //body+='<!--Optional: IBAN-->';
                       body+='<proc:ATTRIBUTE12>'+agent.IBAN_Number__c+'</proc:ATTRIBUTE12>';
                       //body+='<!--Optional: Swift Code-->';
                       body+='<proc:ATTRIBUTE13>'+agent.Swift_Code__c+'</proc:ATTRIBUTE13>';
                       //body+='<!--Optional: SORT code-->';
                       body+='<proc:ATTRIBUTE14>'+agent.Sort_Code__c+'</proc:ATTRIBUTE14>';
                       //body+='<!--Optional: IFSC Code -->';
                       body+='<proc:ATTRIBUTE15>'+agent.IFSC_Code__c+'</proc:ATTRIBUTE15>';
                       //body+='<!--Optional:-->';
                    body+='</proc:P_REQUEST_MESSAGE_ITEM>';
                }
             body+='</proc:P_REQUEST_MESSAGE>';
          body+='</proc:InputParameters>';
       body+='</soapenv:Body>';
     body+='</soapenv:Envelope>';
     
     return body.trim();
    }
    
    /**********************Callout for the agent creation*********************************/
    
    
    webservice static void sendAgentCreate(List<id> agentids){
        
        getIPMSsetting();
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareAgentCreate(agentids);
        System.debug('>>>>>Request Body>>>>>>'+ reqXML);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(60 * 1000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
        	try{
            HTTPResponse res = http.send(req);
            
            System.debug('>>>>>Response>>>>>>'+res.getbody());
            
            parseAgentCreateResponse(res.getBody());
            }
	        catch(Exception ex) {
	            System.debug('Callout error: '+ ex);
	            Log__c objLog = new Log__c();
	            objLog.Description__c ='Ids=='+agentids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
	            objLog.Type__c = 'Webservice Callout For Agent Creation';
	            insert objLog;             
	        }    
        }
    }
    
    /**********************Parsing the response received for agent create request*********************************/
    public static void parseAgentCreateResponse(string body){
        
        string vendorId,partyid,status,statusmsg,agentId = '';
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        Map<Id, String> AgentMap = new Map<Id, String>();
        Map<Id, String> PartyMap = new Map<Id, String>();
        Map<Id, String> AgentStatusMap = new Map<Id, String>();
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        System.debug('>>>>Child4>>>>>>>>'+child4.getName());
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>Child5>>>>>>>>'+child5.getName());
                            System.debug('>>>>Child5 Text>>>>>>>>'+child5.getText());
                            if(child5.getName()=='PROC_STATUS') 
                            status = child5.getText();
                            if(child5.getName()=='PROC_MESSAGE') 
                            statusmsg = child5.getText();
                            if(child5.getName()=='PARAM_ID') 
                            agentId= child5.getText();
                            if(child5.getName()=='ATTRIBUTE1') 
                            vendorId = child5.getText();
                            if(child5.getName()=='ATTRIBUTE2') 
                            partyId = child5.getText();
                        }
                        AgentMap.put(agentId,vendorId);
                        PartyMap.put(agentId,partyId);
                        AgentStatusMap.put(agentId,statusmsg);
                    }
                }
            }
        }
        List<Account> agentlist= [select id,Country_of_Sale__c,Vendor_ID__c,Party_ID__c,IPMS_Status__c from Account where id in :AgentMap.keyset()];
        try{
	        if(agentlist.size()>0){
		        for(Account agent :agentlist){
		            agent.vendor_ID__c=Agentmap.get(agent.id);
		            agent.Party_ID__c=Partymap.get(agent.id);
		            agent.IPMS_Status__c=AgentStatusmap.get(agent.id);
		            
		        }
		        update agentlist;	        
		        Account ag =agentlist[0];
		        if(ag.Vendor_ID__c!=null)
		            	ManageAgencySites.insertAgencySites(ag.Country_of_Sale__c,ag.id); 
		        
	        }
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+AgentMap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response for Agent Creation';
            insert objLog;             
        }    
        
    }
        
    /**********************Preparing the request body for the agent site create request*********************************/
    public static string prepareAgentSiteCreate(List<id> siteids){
       
       string siteQuery = getCreatableFieldsSOQL('Agent_Site__c');
       siteQuery=siteQuery.remove('FROM Agent_Site__c');
       siteQuery+=',Agency__r.Firstname,Agency__r.Lastname,Agency__r.Street__c,Agency__r.City__c FROM Agent_Site__c where Id in:siteids';
       List<Agent_Site__c> agentsites = database.query(siteQuery);
       
       List<id> accids= new List<id>();
       for(Agent_Site__c site :agentsites){
       		accids.add(site.Agency__c);
       }
       string conQuery = getCreatableFieldsSOQL('Contact');
       //siteQuery=siteQuery.remove('FROM Agent_Site__c');
       conQuery+=' where Authorised_Signatory__c=true and AccountId in:accids';
       List<Contact> auths = database.query(conQuery);
       
       Map<Id,String> FnameMap= new Map<Id,String>();
       Map<Id,String> LnameMap= new Map<Id,String>();
       for(Contact c:auths){
       	  FnameMap.put(c.AccountId,c.FirstName);
       	  LnameMap.put(c.AccountId,c.LastName);	
       }
       string body = '';
       body+= preparesoapHeader(body); 
       body+='<soapenv:Body>';
          body+='<proc:InputParameters>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_NUMBER>12345</proc:P_REQUEST_NUMBER>';
             //body+='<!--Optional:-->';
             body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_NAME>REGISTER_SUPPLIER_SITE</proc:P_REQUEST_NAME>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_MESSAGE>';
                //body+='<!--Zero or more repetitions:-->';
                for(Agent_Site__c site :agentsites ){
                    body+='<proc:P_REQUEST_MESSAGE_ITEM>';
                       //body+='<!--Optional:SFDC ID-->';
                       body+='<proc:PARAM_ID>'+site.id+'</proc:PARAM_ID>';
                       //body+='<!--Mandatory:Vendor Id-->';
                       body+='<proc:ATTRIBUTE1>'+site.Vendor_Id__c+'</proc:ATTRIBUTE1>';
                       //body+='<!--Optional:ORG_ID-->';
                       body+='<proc:ATTRIBUTE2>'+site.Org_ID_formula__c+'</proc:ATTRIBUTE2>';                       
                       
                       string fname='';
                       if(site.Agency__r.Firstname !=null)
                       	  fname=site.Agency__r.Firstname;
                       else
                       	  fname=FnameMap.get(site.Agency__c);
                       //body+='<!--Optional:Site Contact first Name-->';
                       body+='<proc:ATTRIBUTE3>'+fname+'</proc:ATTRIBUTE3>';
                       
                       string lname='';
                       if(site.Agency__r.Lastname !=null)
                       	  lname=site.Agency__r.Lastname;
                       else
                       	  lname=LnameMap.get(site.Agency__c);
                       //body+='<!--Optional: Site Contact Last Name-->';
                       body+='<proc:ATTRIBUTE4>'+lname+'</proc:ATTRIBUTE4>';                       
                       //body+='<!--Optional:ADDRESS Line 1-->';
                       body+='<proc:ATTRIBUTE5>'+site.Agency__r.Street__c+'</proc:ATTRIBUTE5>';                       
                       //body+='<!--Optional:ADDRESS Line 2-->';
                       body+='<proc:ATTRIBUTE6></proc:ATTRIBUTE6>';
                       //body+='<!--Optional:ADDRESS Line 3 -->';
                       body+='<proc:ATTRIBUTE7></proc:ATTRIBUTE7>';
                       //body+='<!--Optional:ADDRESS Line 4-->';
                       body+='<proc:ATTRIBUTE8></proc:ATTRIBUTE8>';
                       //body+='<!--Optional:City -->';
                       body+='<proc:ATTRIBUTE9>'+site.Agency__r.City__c+'</proc:ATTRIBUTE9>';
                       //body+='<!--Optional:POSTAL_CODE -->';
                       body+='<proc:ATTRIBUTE10></proc:ATTRIBUTE10>';
                       //body+='<!--Optional: STATE-->';
                       body+='<proc:ATTRIBUTE11></proc:ATTRIBUTE11>'; 
                       //body+='<!--Optional:country_code (AE-81,LB-,JO-172,SA-192,-->';
                       body+='<proc:ATTRIBUTE12>'+site.country_code__c+'</proc:ATTRIBUTE12>';
                       //body+='<!--Optional:currency-->';
                       body+='<proc:ATTRIBUTE13>AED</proc:ATTRIBUTE13>';
                       /* not to be passed
                       body+='<!--Optional:B - Bank. C - Check, No Value if copy from Header-->';
                       body+='<proc:ATTRIBUTE14></proc:ATTRIBUTE14>';
                       body+='<!--Optional:email address-->';
                       body+='<proc:ATTRIBUTE15></proc:ATTRIBUTE15>';
                       body+='<!--Optional:PHONE_AREA_CODE-->';
                       body+='<proc:ATTRIBUTE16>971</proc:ATTRIBUTE16>';
                       body+='<!--Optional:PHONE-->';
                       body+='<proc:ATTRIBUTE17>043732262</proc:ATTRIBUTE17>';
                       body+='<!--Optional:FAX_AREA_CODE-->';
                       body+='<proc:ATTRIBUTE18>971</proc:ATTRIBUTE18>';           
                       body+='<!--Optional:FAX-->';
                       body+='<proc:ATTRIBUTE19>04334546</proc:ATTRIBUTE19>';              
                       body+='<!--Optional:-->';
                       */
                    body+='</proc:P_REQUEST_MESSAGE_ITEM>';
                }
             body+='</proc:P_REQUEST_MESSAGE>';
          body+='</proc:InputParameters>';
       body+='</soapenv:Body>';
    body+='</soapenv:Envelope>';
    
    return body.trim();

    }
    
    /**********************Callout for the agent site creation*********************************/
   
    webservice static void sendAgentSiteCreate(List<Id> siteids){
        
        getIPMSsetting();
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareAgentSiteCreate(siteids);
        System.debug('>>>>>Request Body>>>>>>'+ reqXML);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(60 * 1000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
        	try{
	            HTTPResponse res = http.send(req);
	            
	            System.debug('>>>>>Response>>>>>>'+res.getbody());
	            
	            parseAgentSiteCreateResponse(res.getBody());
            }
	        catch(Exception ex) {
	            System.debug('Callout error: '+ ex);
	            Log__c objLog = new Log__c();
	            objLog.Description__c ='Ids=='+siteids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
	            objLog.Type__c = 'Webservice Callout For Agent Site Creation';
	            insert objLog;             
	        }    
            
        }
    }
    
    /**********************Parsing the response received for agent site create request*********************************/
    public static void parseAgentSiteCreateResponse(string body){
        
        string siteId,status,statusmsg,agencyId = '';
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        Map<Id,String> SiteMap = new Map<Id,String>();
        Map<Id,String> SiteStatusMap = new Map<Id,String>();
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        System.debug('>>>>Child4>>>>>>>>'+child4.getName());
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>Child5>>>>>>>>'+child5.getName());
                            System.debug('>>>>Child5 Text>>>>>>>>'+child5.getText());
                            if(child5.getName()=='PROC_STATUS') 
                            status = child5.getText();
                            if(child5.getName()=='PROC_MESSAGE') 
                            statusmsg = child5.getText();
                            if(child5.getName()=='PARAM_ID') 
                            siteId= child5.getText();
                            if(child5.getName()=='ATTRIBUTE1') 
                            agencyId = child5.getText();
                        }
                        Sitemap.put(siteId,agencyId);
                        SiteStatusmap.put(siteId,statusmsg);
                    }
                }
            }
        }
        
        List<Agent_Site__c> sitelist= [select id,Agency_ID__c,IPMS_Status__c from Agent_Site__c where id in :SiteMap.keyset()];
        try{
        	if(sitelist.size()>0){
		        for(Agent_Site__c site :sitelist){
		            site.Agency_ID__c=Sitemap.get(site.id);
		            site.IPMS_Status__c=SiteStatusmap.get(site.id);
		        }
		        update sitelist;
        	}
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+SiteMap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response For Agent Site Creation';
            insert objLog;             
        }    
        
    }
    
    /**********************Preparing the request body for the agent update request*********************************/
    public static string prepareAgentUpdate(List<Id> agentids){
        string accQuery = getCreatableFieldsSOQL('Account');
        accQuery+=' where Id in:agentids';
        List<Account> agentlist= database.query(accQuery);
        
        string body = '';
        body+= preparesoapHeader(body);     
        body+='<soapenv:Body>';
          body+='<proc:InputParameters>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_NUMBER>12345</proc:P_REQUEST_NUMBER>';
             //body+='<!--Optional:-->';
             body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_NAME>UPDATE_SUPPLIER</proc:P_REQUEST_NAME>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_MESSAGE>';
                //body+='<!--Zero or more repetitions:-->';
                for(Account agent : agentlist){
                    body+='<proc:P_REQUEST_MESSAGE_ITEM>';
                       //body+='<!--Optional:SFDC ID-->';
                       body+='<proc:PARAM_ID>'+agent.id+'</proc:PARAM_ID>';
                       //body+='<!--Mandatory:Vendor Id-->';
                       body+='<proc:ATTRIBUTE1>'+agent.vendor_ID__c+'</proc:ATTRIBUTE1>';
                       
                       String terdate=null;
                       if(agent.Termination_Date__c!=null){
                       terdate=GetDatetext(agent.Termination_Date__c);
                       }
                       //body+='<!--Optional:Termination Date (DD-MON-YYYY); Pass Null to Re-instate -->';                   
                       body+='<proc:ATTRIBUTE2>'+terdate+'</proc:ATTRIBUTE2>';
                       
                    body+='</proc:P_REQUEST_MESSAGE_ITEM>';
                }
             body+='</proc:P_REQUEST_MESSAGE>';
          body+='</proc:InputParameters>';
         body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
    
    }
    
    /**********************Callout for the agent updation*********************************/
    
    
    webservice static void sendAgentUpdate(List<Id> agentids){
        
        getIPMSsetting();
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareAgentUpdate(agentids);
        System.debug('>>>>>Request Body>>>>>>'+ reqXML);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(60 * 1000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
        	try{
	            HTTPResponse res = http.send(req);
	            
	            System.debug('>>>>>Response>>>>>>'+res.getbody());
	            
	            parseAgentUpdateResponse(res.getBody());
            }
	        catch(Exception ex) {
	            System.debug('Callout error: '+ ex);
	            Log__c objLog = new Log__c();
	            objLog.Description__c ='Ids=='+agentids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
	            objLog.Type__c = 'Webservice Callout For Agent Updation';
	            insert objLog;             
	        }   
        }
    }
    
    /**********************Parsing the response received for agent update request*********************************/
    public static void parseAgentUpdateResponse(string body){
        
        string vendorId,status,statusmsg,agentId = '';
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        Map<Id, String> AgentStatusMap = new Map<Id, String>();
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        System.debug('>>>>Child4>>>>>>>>'+child4.getName());
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>Child5>>>>>>>>'+child5.getName());
                            System.debug('>>>>Child5 Text>>>>>>>>'+child5.getText());
                            if(child5.getName()=='PROC_STATUS') 
                            status = child5.getText();
                            if(child5.getName()=='PROC_MESSAGE') 
                            statusmsg = child5.getText();
                            if(child5.getName()=='PARAM_ID') 
                            agentId= child5.getText();
                            if(child5.getName()=='ATTRIBUTE1') 
                            vendorId = child5.getText();
                        }
                        AgentStatusMap.put(agentId,statusmsg);
                    }
                }
            }
        }
        
        List<Account> agentlist= [select id,Vendor_ID__c,Party_ID__c,IPMS_Status__c from Account where id in :AgentStatusMap.keyset()];
        try{
        	if(agentlist.size()>0){
		        for(Account agent :agentlist){
		            agent.IPMS_Status__c=AgentStatusmap.get(agent.id);
		        }
		        update agentlist;
        	}
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+AgentStatusmap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response for agent update';
            insert objLog;             
        } 
        
    }
    
    /**********************Preparing the request body for the agent site update request*********************************/
    public static string prepareAgentSiteUpdate(List<id> siteids){
       
       string siteQuery = getCreatableFieldsSOQL('Agent_Site__c');
       siteQuery+=' where Id in:siteids';
       List<Agent_Site__c> agentsites = database.query(siteQuery);
       
       string body = '';
       body+= preparesoapHeader(body); 
       body+='<soapenv:Body>';
          body+='<proc:InputParameters>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_NUMBER>12345</proc:P_REQUEST_NUMBER>';
             //body+='<!--Optional:-->';
             body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_NAME>UPDATE_SUPPLIER_SITE</proc:P_REQUEST_NAME>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_MESSAGE>';
                //body+='<!--Zero or more repetitions:-->';
                for(Agent_Site__c site :agentsites ){
                    body+='<proc:P_REQUEST_MESSAGE_ITEM>';
                       //body+='<!--Optional:SFDC ID-->';
                       body+='<proc:PARAM_ID>'+site.id+'</proc:PARAM_ID>';
                       //body+='<!--Mandatory:Vendor Site Id-->';
                       body+='<proc:ATTRIBUTE1>'+site.agency_ID__c+'</proc:ATTRIBUTE1>';
                       String terdate=null;
                       if(site.End_Date__c!=null){
                       terdate=GetDatetext(site.End_Date__c);
                       }
                       //body+='<!--Optional:Termination Date (DD-MON-YYYY); Pass Null to Re-instate -->';
                       body+='<proc:ATTRIBUTE2>'+terdate+'</proc:ATTRIBUTE2>';
                    body+='</proc:P_REQUEST_MESSAGE_ITEM>';
                }
             body+='</proc:P_REQUEST_MESSAGE>';
          body+='</proc:InputParameters>';
       body+='</soapenv:Body>';
      body+='</soapenv:Envelope>';

    
    return body.trim();

    }
    
    /**********************Callout for the agent site updation*********************************/
    
    webservice static void sendAgentSiteUpdate(List<Id> siteids){
        
        getIPMSsetting();
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareAgentSiteUpdate(siteids);
        System.debug('>>>>>Request Body>>>>>>'+ reqXML);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(60 * 1000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
        	try{
	            HTTPResponse res = http.send(req);
	            
	            System.debug('>>>>>Response>>>>>>'+res.getbody());
	            
	            parseAgentSiteUpdateResponse(res.getBody());
            }
	        catch(Exception ex) {
	            System.debug('Callout error: '+ ex);
	            Log__c objLog = new Log__c();
	            objLog.Description__c ='Ids=='+siteids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
	            objLog.Type__c = 'Webservice Callout For Agent Site Updation';
	            insert objLog;             
	        }   
        }
    }
    
    /**********************Parsing the response received for agent site update request*********************************/
    public static void parseAgentSiteUpdateResponse(string body){
        
        string siteId,status,statusmsg,agencyId = '';
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        Map<Id,String> SiteMap = new Map<Id,String>();
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>Child5>>>>>>>>'+child5.getName());
                            System.debug('>>>>Child5 Text>>>>>>>>'+child5.getText());
                            if(child5.getName()=='PROC_STATUS') 
                            status = child5.getText();
                            if(child5.getName()=='PROC_MESSAGE') 
                            statusmsg = child5.getText();
                            if(child5.getName()=='PARAM_ID') 
                            siteId= child5.getText();
                            if(child5.getName()=='ATTRIBUTE1') 
                            agencyId = child5.getText();
                        }
                        Sitemap.put(siteId,statusmsg );
                    }
                }
            }
        }
        List<Agent_Site__c> sitelist= [select id,Agency_ID__c,IPMS_Status__c from Agent_Site__c where id in :SiteMap.keyset()];
        try{
        	if(sitelist.size()>0){
		        for(Agent_Site__c site :sitelist){
		            site.IPMS_Status__c=Sitemap.get(site.id);
		        }
		        update sitelist;
        	}
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+SiteMap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response for site update';
            insert objLog;             
        } 
        
    }
    
    /**********************Preparing the request body for the bank update request*********************************/
    public static string prepareBankUpdate(List<Id> agentids){
        string accQuery = getCreatableFieldsSOQL('Account');
        accQuery+=' where Id in:agentids';
        List<Account> agentlist= database.query(accQuery);
        
        string body = '';
        body+= preparesoapHeader(body);     
        body+='<soapenv:Body>';
          body+='<proc:InputParameters>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_NUMBER>123456</proc:P_REQUEST_NUMBER>';
             //body+='<!--Optional:-->';
             body+='<proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_NAME>UPDATE_SUPPLIER_BANK</proc:P_REQUEST_NAME>';
             //body+='<!--Optional:-->';
             body+='<proc:P_REQUEST_MESSAGE>';
                //body+='<!--Zero or more repetitions:-->';
                for(Account agent : agentlist){
                    body+='<proc:P_REQUEST_MESSAGE_ITEM>';
                       //body+='<!--Optional:-->';
                       body+='<proc:PARAM_ID>'+agent.id+'</proc:PARAM_ID>';
                       //body+='<!--Optional:p_supp_id-->';
                       body+='<proc:ATTRIBUTE1>'+agent.Vendor_ID__c+'</proc:ATTRIBUTE1>';
                       //body+='<!--Optional:p_bank_name-->';
                       body+='<proc:ATTRIBUTE2>'+agent.Bank_Name__c+'</proc:ATTRIBUTE2>';
                       //body+='<!--Optional:p_bank_number-->';
                       body+='<proc:ATTRIBUTE3></proc:ATTRIBUTE3>'; 
                       //body+='<!--Optional:p_country_code-->';
                       body+='<proc:ATTRIBUTE4>'+agent.Bank_Country__c+'</proc:ATTRIBUTE4>'; //******************
                       //body+='<!--Optional:p_branch_name-->';
                       body+='<proc:ATTRIBUTE5>'+agent.Bank_Branch__c+'</proc:ATTRIBUTE5>';
                       //body+='<!--Optional:p_branch_number-->';
                       body+='<proc:ATTRIBUTE6>?</proc:ATTRIBUTE6>';
                       //body+='<!--Optional:p_branch_city-->';
                       body+='<proc:ATTRIBUTE7>'+agent.Bank_City__c+'</proc:ATTRIBUTE7>';
                       //body+='<!--Optional:p_bank_acct_country_code-->';
                       body+='<proc:ATTRIBUTE8>'+agent.Bank_Country__c+'</proc:ATTRIBUTE8>'; //******************
                       //body+='<!--Optional:p_currency-->';
                       body+='<proc:ATTRIBUTE9>'+agent.Bank_Account_Currency__c+'</proc:ATTRIBUTE9>';
                       //body+='<!--Optional:p_bank_account_name (Same as Supplier Name)-->';
                       body+='<proc:ATTRIBUTE10>'+agent.name+'</proc:ATTRIBUTE10>';
                       //body+='<!--Optional:p_bank_account_no-->';
                       body+='<proc:ATTRIBUTE11>'+agent.Bank_Account_Number__c+'</proc:ATTRIBUTE11>';
                       //body+='<!--Optional:p_iban-->';
                       body+='<proc:ATTRIBUTE12>'+agent.IBAN_Number__c+'</proc:ATTRIBUTE12>';
                       //body+='<!--Optional:p_swift_code-->';
                       body+='<proc:ATTRIBUTE13>'+agent.Swift_Code__c+'</proc:ATTRIBUTE13>';
                       //body+='<!--Optional:p_sort_code-->';
                       body+='<proc:ATTRIBUTE14>'+agent.Sort_Code__c+'</proc:ATTRIBUTE14>';
                       //body+='<!--Optional:p_ifsc_code-->';
                       body+='<proc:ATTRIBUTE15>'+agent.IFSC_Code__c+'</proc:ATTRIBUTE15>';
                    body+='</proc:P_REQUEST_MESSAGE_ITEM>';

                }
             body+='</proc:P_REQUEST_MESSAGE>';
          body+='</proc:InputParameters>';
         body+='</soapenv:Body>';
        body+='</soapenv:Envelope>';
        
        return body.trim();
    
    }
    
    /**********************Callout for the bank updation*********************************/
    
   
    webservice static void sendBankUpdate(List<Id> agentids){
        
        getIPMSsetting();
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        String reqXML = prepareBankUpdate(agentids);
        System.debug('>>>>>Request Body>>>>>>'+ reqXML);
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        req.setbody(reqXML);
        req.setEndpoint(endurl);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(60 * 1000);
        HTTP http = new HTTP();
        if(!Test.isrunningTest()){
        	try{
	            HTTPResponse res = http.send(req);
	            
	            System.debug('>>>>>Response>>>>>>'+res.getbody());
	            
	            parseBankUpdateResponse(res.getBody());
            }
	        catch(Exception ex) {
	            System.debug('Callout error: '+ ex);
	            Log__c objLog = new Log__c();
	            objLog.Description__c ='Ids=='+agentids+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
	            objLog.Type__c = 'Webservice Callout For Bank Updation';
	            insert objLog;             
	        }   
        }
    }
    
    /**********************Parsing the response received for agent update request*********************************/
    public static void parseBankUpdateResponse(string body){
        
        string vendorId,status,statusmsg,agentId = '';
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        Map<Id, String> AgentStatusMap = new Map<Id, String>();
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                        System.debug('>>>>Child4>>>>>>>>'+child4.getName());
                        for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>Child5>>>>>>>>'+child5.getName());
                            System.debug('>>>>Child5 Text>>>>>>>>'+child5.getText());
                            if(child5.getName()=='PROC_STATUS') 
                            status = child5.getText();
                            if(child5.getName()=='PROC_MESSAGE') 
                            statusmsg = child5.getText();
                            if(child5.getName()=='PARAM_ID') 
                            agentId= child5.getText();
                            if(child5.getName()=='ATTRIBUTE1') 
                            vendorId = child5.getText();
                        }
                        AgentStatusMap.put(agentId,statusmsg);
                    }
                }
            }
        }
        
        List<Account> agentlist= [select id,Vendor_ID__c,Party_ID__c,IPMS_Status__c from Account where id in :AgentStatusMap.keyset()];
        try{
        	if(agentlist.size()>0){
		        for(Account agent :agentlist){
		            agent.IPMS_Status__c=AgentStatusmap.get(agent.id);
		        }
		        update agentlist;
        	}
        }
        catch(Exception ex) {
            System.debug('Callout error: '+ ex);
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+AgentStatusMap.keyset()+'-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c = 'Error updating response For Bank Updation';
            insert objLog;             
        }   
        
    }
    //Method to Get formatted date
    public static string GetDatetext(Date d){
        String dd,mm,mon,yy,dtext='';
        dd=string.valueof(d.day());
        mm=string.valueof(d.month());
        if(mm=='1')
        mon='JAN';
        else if(mm=='2')
        mon='FEB';
        else if(mm=='3')
        mon='MAR';
        else if(mm=='4')
        mon='APR';
        else if(mm=='5')
        mon='MAY';
        else if(mm=='6')
        mon='JUN';
        else if(mm=='7')
        mon='JUL';
        else if(mm=='8')
        mon='AUG';
        else if(mm=='9')
        mon='SEP';
        else if(mm=='10')
        mon='OCT';
        else if(mm=='11')
        mon='NOV';
        else if(mm=='12')
        mon='DEC';
        
        yy=string.valueof(d.year());
        dtext= dd+'-'+mon+'-'+yy;
        return dtext;
    
    }
    //Generic method for fields for SOQL query
    public static string getCreatableFieldsSOQL(string objectName){
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
               // if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
              //  }
            }
        }
        // contruction of SOQL
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        // return constrcucted query
        return 'SELECT ' + selects + ' FROM ' + objectName ;
         
    }

}