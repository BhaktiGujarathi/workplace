public with sharing class CallEarlyHandoverToGetHandoverDetails {
    public static JSON2Apex  CallEarlyHandoverMQService1GetHandoverDetails() {
        EarlyHandoverMQService1.HandoverHttpSoap11Endpoint objEligibleForHandover = new EarlyHandoverMQService1.HandoverHttpSoap11Endpoint();
        objEligibleForHandover.timeout_x = 120000 ;
        
        string strHand = objEligibleForHandover.GetHandoverDetails('57942','GET_HANDOVER_DETAILS','SFDC','91929');
        system.debug('strHand '+strHand );
        JSON2Apex  objEligibleForHandoverResponse = new JSON2Apex ();
        objEligibleForHandoverResponse = (CallEarlyHandoverToGetHandoverDetails.JSON2Apex)JSON.deserialize(strHand, CallEarlyHandoverToGetHandoverDetails.JSON2Apex.class);
        system.debug('objEligibleForHandoverResponse'+objEligibleForHandoverResponse);
        system.debug('t'+(CallEarlyHandoverToGetHandoverDetails.JSON2Apex) System.JSON.deserialize(strHand, JSON2Apex.class));
        //resObj = (EarlyHandoverMQService1Response)JSON.deserialize(strHand, CallEarlyHandoverToGetHandoverDetails.EarlyHandoverMQService1Response.class);

        String strResponse = strHand.removeStart('[').removeEnd(']');
        Map<String, Object> objUnitDetails = (Map<String, Object>)JSON.deserializeUntyped( strResponse.replace('\\','').removeStart('"').removeEnd('"') );
        system.debug('>>>>'+objUnitDetails.keyset());
        system.debug('****'+objUnitDetails.get('data'));
        
        return objEligibleForHandoverResponse;      
    }
    public class JSON2Apex {
        public List<EarlyHandoverMQService1Response> data;
        public String message;
        public String status;
    }
    public class EarlyHandoverMQService1Response {
        public String P_REQUEST_NUMBER {get;set;}
        public String P_REQUEST_NAME{get;set;}
        public String P_SOURCE_SYSTEM{get;set;}
        public String Registrationid{get;set;}
        public String JOPD_Suite_Area{get;set;}
        public String JOPD_Balcony_Area{get;set;}
        public String JOPD_Total_Area{get;set;}
        public String JOPD_Entitlement{get;set;}
        public String Litigation_Flag{get;set;}
        public String Mortgage_Flag{get;set;}
        public String Status{get;set;}
        public String Billable_Amount{get;set;}
        public String Payment_Received{get;set;}
        public String Deposit_Received{get;set;}
        public String Legal_Flag{get;set;}
        public String Default_Flag{get;set;}
        public String Under_Termination{get;set;}
        public String Area_Variation{get;set;}
        public String ACD{get;set;}

    }
}