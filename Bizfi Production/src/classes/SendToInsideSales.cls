public with sharing class SendToInsideSales {
    
    private static final String IS_URL = 'https://nextlevelfundingllc.insidesales.com/do=noauth/immediate_response';
    private static final String IS_BODY = 'method=responsepop&inbound_initiative_id=CALL_PATH_ID&ids=LEAD_IDS';


    private Lead[] leads;


    public SendToInsideSales(Lead[] leads) {
        //this.leads = leads;

        this.leads = [select Call_Path_Id__c, 
                             First_Sent_to_InsideSales_Date_Time__c
                        from Lead 
                       where Id in :leads];
    }

    
    public SendToInsideSales(Lead lead) {
        this(new Lead[]{ lead });   
    }


    public void send(Boolean isFuture) {

        Map<String, Id[]> callPathLeads = new Map<String, Id[]>();
        Lead[] leadsToUpdate = new Lead[]{};

        for (Lead lead : leads) {

            if (isValidLead(lead)) {

                if (!callPathLeads.containsKey(lead.Call_Path_Id__c)) {

                    callPathLeads.put(lead.Call_Path_Id__c, new Id[]{});                
                }

                callPathLeads.get(lead.Call_Path_Id__c).add(lead.Id);                   
            }

            leadsToUpdate.add(lead);
        }

        System.debug('\n\n###: ' + leads);
        System.debug('\n\n###: ' + callPathLeads);
        System.debug('\n\n###: ' + callPathLeads);


        for (String callPathId : callPathLeads.keySet()) {

            if (callPathId != null) {

                String leadIds = EncodingUtil.urlEncode(JSON.serialize(callPathLeads.get(callPathId)), 'ISO-8859-1');           

                if (isFuture) {
                    
                    sendHTTPRequestFuture(IS_URL, IS_BODY.replace('CALL_PATH_ID', callPathId).replace('LEAD_IDS', leadIds));
                }
                else {

                    sendHTTPRequest(IS_URL, IS_BODY.replace('CALL_PATH_ID', callPathId).replace('LEAD_IDS', leadIds));
                }
            }

        }

        if (!leadsToUpdate.isEmpty()) {

            update leadsToUpdate;
        }
    
    }


    private Boolean isValidLead(Lead lead) {

        if (lead.First_Sent_to_InsideSales_Date_Time__c == null) {
            lead.First_Sent_to_InsideSales_Date_Time__c = Datetime.now();
            
            return true;
        }
        else if (lead.First_Sent_to_InsideSales_Date_Time__c != null) {

            Integer minutesSince = Integer.valueOf(((Datetime.now().getTime() - lead.First_Sent_to_InsideSales_Date_Time__c.getTime()) / 1000 / 60 ));

            if (minutesSince > 60) {
                
                lead.cmblre__Reassign_Lead__c = true;
                lead.Inside_Sales_Unanswered__c = true;
            }
            else if (minutesSince >= 5) {

                lead.Most_Recent_Sent_To_InsideSales_DateTime__c = DateTime.now();
                return true;
            }
        }   

        return false;
    }





    @future(callout=true)
    public static void sendHTTPRequestFuture(String url, String body) {

        sendHTTPRequest(url, body);
    }   


    public static void sendHTTPRequest(String url, String body) {
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setBody(body);
        request.setMethod('POST');

        HttpResponse response = new Http().send(request);

        System.debug('\n\n###: ' + url);
        System.debug('\n\n###: ' + body);
    }
}