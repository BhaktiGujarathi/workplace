/**************************************************************************************************
* Name               : AsyncOptionWebservice 
* Description        : 
                        
                               
* Created Date       : 05/07/2017                                                                 
* Created By         : Naresh Kaneriya                                                      
**************************************************************************************************/

public class AsyncOptionWebservice{
  
    public static final String Endurl  = System.Label.AsyOptionUpdateSoap ;
    public static final String POST  = 'POST';
    public static Boolean isOnce= true;
    
    
     @future(Callout=true)
     public static void  prepareOptionUpdate(Set<Id>  newMapOption){
        isOnce =  false ;
        String   Body = '' ;
        Set<Id> BUId = new Set<Id>();
      
       List<Option__c> OpnList = [Select id ,
                                     Booking_Unit__c ,
                                     PromotionName__c,
                                     CampaignName__c,
                                     OptionsName__c,
                                     SchemeName__c,
                                     TemplateIdPN__c,
                                     TemplateIdCN__c,
                                     TemplateIdOP__c,
                                     TemplateIdSN__c,
                                     Net_Price__c from Option__c  where Id =: newMapOption limit 1];
        

               
        if(OpnList!=null && !OpnList.isEmpty()) {
            
            for(Option__c B :  OpnList){
              BUId.add(B.Booking_Unit__c);
            }
    
            List<Booking_Unit__c> BUList = [Select id ,Registration_ID__c from Booking_Unit__c  where Id =: BUId];                             
             
            Body   +='<?xml version="1.0" encoding="UTF-8"?> ';
            Body   +='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xxdc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/" xmlns:proc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/process/"> ';
            Body   +='  <soapenv:Header> ';
            Body   +='      <xxdc:SOAHeader> ';
            Body   +='         <xxdc:Responsibility>ONT_ICP_SUPER_USER</xxdc:Responsibility> ';
            Body   +='         <xxdc:RespApplication>ONT</xxdc:RespApplication> ';
            Body   +='         <xxdc:SecurityGroup>standard</xxdc:SecurityGroup> ';
            Body   +='         <xxdc:NLSLanguage>american</xxdc:NLSLanguage> ';
            Body   +='         <xxdc:Org_Id/> ';
            Body   +='      </xxdc:SOAHeader> ';
            Body   +='      <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"> ';
            Body   +='         <wsse:UsernameToken> ';
            Body   +='            <wsse:Username>oracle_user</wsse:Username> ';
            Body   +='            <wsse:Password>crp1user</wsse:Password> ';
            Body   +='         </wsse:UsernameToken> ';
            Body   +='      </wsse:Security> ';
            Body   +='   </soapenv:Header> ';
            Body   +='   <soapenv:Body> ';
            Body   +='      <proc:InputParameters> ';
            Body   +='         <proc:P_REQUEST_NUMBER>122</proc:P_REQUEST_NUMBER> ';
            Body   +='         <proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM> ';
            Body   +='         <proc:P_REQUEST_NAME>UPDATE_REGISTRATION</proc:P_REQUEST_NAME> ';
            Body   +='         <proc:P_REQUEST_MESSAGE> ';
            Body   +='            <proc:P_REQUEST_MESSAGE_ITEM> ';
            Body   +='               <proc:PARAM_ID>1211</proc:PARAM_ID> ';
            if(BUList!=null && !BUList.isEmpty()) {
                Body   +=' <proc:ATTRIBUTE1>'+BUList[0].Registration_ID__c+'</proc:ATTRIBUTE1> ';
            }else{
                Body   +=' <proc:ATTRIBUTE1></proc:ATTRIBUTE1> ';
            }
            Body   +=' <proc:ATTRIBUTE2>UPDATE_PR_SC_OP_CM_RP</proc:ATTRIBUTE2> ';
    
            if(!String.isBlank(OpnList[0].PromotionName__c)){
                Body   +=' <proc:ATTRIBUTE12>'+OpnList[0].TemplateIdPN__c+'</proc:ATTRIBUTE12> ';
            }
            else{
               Body   +=' <proc:ATTRIBUTE12></proc:ATTRIBUTE12> ';
            }
 
            if(!String.isBlank(OpnList[0].CampaignName__c)){
            Body   +=' <proc:ATTRIBUTE13>'+OpnList[0].TemplateIdCN__c+'</proc:ATTRIBUTE13> ';
            }
           else{
           Body   +=' <proc:ATTRIBUTE13></proc:ATTRIBUTE13> ';
           }

              if(!String.isBlank(OpnList[0].OptionsName__c)){
            Body   +=' <proc:ATTRIBUTE14>'+OpnList[0].TemplateIdOP__c+'</proc:ATTRIBUTE14> ';
           }
          else{
          Body   +=' <proc:ATTRIBUTE14></proc:ATTRIBUTE14> ';
          }

         if(!String.isBlank(OpnList[0].SchemeName__c)){
         Body   +=' <proc:ATTRIBUTE15>'+OpnList[0].TemplateIdSN__c+'</proc:ATTRIBUTE15> ';
         }

         else{
         Body   +=' <proc:ATTRIBUTE15></proc:ATTRIBUTE15> ';
         }


        Body   +=' <proc:ATTRIBUTE16>'+OpnList[0].Net_Price__c +'</proc:ATTRIBUTE16> ';


        Body   +='            </proc:P_REQUEST_MESSAGE_ITEM> ';
        Body   +='         </proc:P_REQUEST_MESSAGE> ';
        Body   +='      </proc:InputParameters> ';
        Body   +='   </soapenv:Body> ';
        Body   +='</soapenv:Envelope> ';
        
        HTTPRequest req = new HTTPRequest();
        req.setMethod(POST);
        String reqXML = Body ;
        
        reqXML = reqXML.replaceAll('null', '');
        reqXML = reqXML.trim();
        System.debug('@@@Body-----   '+reqXML);
        req.setbody(reqXML);
        req.setEndpoint(Endurl);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
      
         try{
                HTTPResponse res = http.send(req);
                
                if(res.getStatus().equalsignorecase('OK') && String.valueof(res.getStatusCode()).equalsignorecase('200')){
                 parseSOAResponse(res.getBody());
                 OpnList[0].IPMS_Status__c = 'SUCCESS';
                 }
                else{
                      OpnList[0].IPMS_Status__c = 'STATUS CODE '+res.getStatusCode()+' STATUS IS '+res.getStatus();
                   }
                   
                update OpnList[0] ;
               
            }
            catch(Exception Ex){
              System.debug('Error Message Is IMPS Update Webservice Call '+Ex.getMessage());
              System.debug('Error Message Is @Line  '+Ex.getLineNumber());
              Log__c objLog = new Log__c();
              objLog.Description__c ='-Line No===>'+Ex.getLineNumber()+'---Message==>'+Ex.getMessage();
              objLog.Type__c = 'IMPS Update Webservice Callout is failed';
              insert objLog;     
             }
        }
   
    }

    public static void parseSOAResponse(string body){
        
        string reqId,BUid,status,statusmsg,stageId,doclist = '';
        
        System.debug('The Tast parseSOAResponse:::::::');
        List<NSIBPM__SR_Doc__c> SRDocList = new List<NSIBPM__SR_Doc__c>();
        Map<string,String> DocMap = new Map<string,string>();
        
        Map<string,String> StageMap = new Map<string,string>();
    
        Map<string,String> ReqMap = new Map<string,string>();
        
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(body);
        DOM.XMLNode rootElement = xmlDOC.getRootElement();
        
        
        for(Dom.XMLNode child1: rootElement.getChildElements()){
            for(Dom.XMLNode child2: child1.getChildElements()){
                for(Dom.XMLNode child3: child2.getChildElements()){
                    for(Dom.XMLNode child4: child3.getChildElements()){
                       for(Dom.XMLNode child5: child4.getChildElements()){
                            System.debug('>>>>>>>>child5>>>>>>'+child5.getName());
                            if(child5.getName()=='PARAM_ID') 
                            BUid=child5.getText();
                                                     
                            if(child5.getName()=='ATTRIBUTE1') 
                            doclist= child5.getText();
                            if(child5.getName()=='ATTRIBUTE2') 
                            reqId= child5.getText();
                            if(child5.getName()=='ATTRIBUTE3') 
                            stageId= child5.getText();
                            if(child5.getName()=='PROC_STATUS')
                            status=child5.getText(); 
                            if(child5.getName()=='PROC_MESSAGE')
                            statusmsg=child5.getText();                            
                            
                       }  
                       
                       if(status=='S'){
                          
                       
                       }
                    }
                }
            }
        }
        
     
    }
    
}