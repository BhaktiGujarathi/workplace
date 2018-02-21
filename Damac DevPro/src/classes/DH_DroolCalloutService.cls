/**************************************************************************************************
* Name               : DH_DroolCalloutService                                                      *
* Description        : This is a controller class Drool Web Service Callout.                      *
* Created Date       :                                                               *
* Created By         : UnKnow                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE          COMMENTS                                              *

  1.1         Naresh(Accely)    20/06/2017    Add  New EndPoint To Custom Label 
                                              and Insert Log Records in Catch Block  *
**************************************************************************************************/

public class DH_DroolCalloutService{
    
    public static final string EndPoint= System.Label.DroolWebService;
    
    public static void generateRequest(){
        DH_RequestWrapper.cls_demo_project1_InOutObject reqEle=new  DH_RequestWrapper.cls_demo_project1_InOutObject();
    }
    
    
    /***********************************************************************************************
    * @Description : Method for Drool Web Services.                                            *
    * @Params      :  List<DH_ResponseWrapper>                                                                          *
    * @Return      :  List<DH_ResponseWrapper>                                                                          *
    ************************************************************************************************/
    
    public static List<DH_ResponseWrapper> getResponse(string body){
        
        System.debug('Drool Body Response'+' '+body);
        
        HttpRequest req=new  HttpRequest();
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('content-type','application/json');
        req.setEndpoint(EndPoint);
        req.setBody(body);
        Http http=new  Http();
        
       try{
           //Execute web service call here    
            HTTPResponse res=http.send(req);
           //Helpful debug messages
           //System.debug(res.getBody());
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
            system.debug('Drool Response::::'+res.getBody());
            
            if(res.getStatusCode()==200){
                System.debug('@@@@@@@@::::'+(((String)res.getBody()).contains('Exception At Drool Side:')));
                if(!(((String)res.getBody()).contains('Exception At Drool Side:'))){
                    Map<string,object> m=(Map<string,object>)JSON.deserializeUntyped(res.getBody());
                    System.debug('######');
                    
                    List<object> data=(List<object>)m.get('data');
                    List<object> respMapList=(List<object>)data;
                    List<Map<string,object>> respMapList1=new  List<Map<string,object>>();
                    for(object o:respMapList)respMapList1.add((Map<string,object>)o);
                    List<Map<string,object>> eleMapList=new  List<Map<string,object>>();
                    for(Map<string,object> s:respMapList1){
                        Map<string,string> m3=new  Map<string,string>();
                        for(string s1:s.keyset()){
                            Map<string,object> obj=(Map<string,object>)s.get(s1);
                            eleMapList.add(obj);
                        }
                    }
                    system.debug(eleMapList);
                    List<DH_ResponseWrapper> respList=new  List<DH_ResponseWrapper>();
                    for(Map<string,object> s:eleMapList){
                        system.debug(s);
                        DH_ResponseWrapper d=(DH_ResponseWrapper)System.JSON.deserialize(JSON.serialize(s,true),DH_ResponseWrapper.class);
                        respList.add(d);
                        system.debug(d);
                    }
                    return respList;
                }else{
                  Log__c objLog = new Log__c();
                  objLog.Type__c = 'Drool Web Service Callout is failed';
                  insert objLog;
                }
            }
            else{
                  Log__c objLog = new Log__c();
                  objLog.Type__c = 'Drool Web Service Callout is failed';
                  insert objLog;
            }
       }
       
        catch(System.Exception ex){
           //Exception handling goes here....
            System.debug('Callout error: '+ex);
            Log__c objLog=new  Log__c();
            objLog.Description__c='-Line No===>'+ex.getLineNumber()+'---Message==>'+ex.getMessage();
            objLog.Type__c='Drool Webservice Callout';
            Insert objLog;
            return null;
        }
        
        return null;
    }
}