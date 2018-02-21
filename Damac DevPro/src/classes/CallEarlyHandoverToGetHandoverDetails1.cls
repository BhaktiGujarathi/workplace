public with sharing class CallEarlyHandoverToGetHandoverDetails1 {
    public static void CallEarlyHandoverMQService1GetHandoverDetails1() {
        CallEarlyHandoverToGetHandoverDetails1.EarlyHandoverMQService1Response objDetailsWrapper ;

            EarlyHandoverMQService1.HandoverHttpSoap11Endpoint objTemp = new EarlyHandoverMQService1.HandoverHttpSoap11Endpoint();
            String strResponse ;
            
              strResponse = objTemp.GetHandoverDetails('57942','GET_HANDOVER_DETAILS','SFDC','91929');
            
            system.debug('response'+ strResponse );
                 
                Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(strResponse);
                system.debug('m'+m);
                Map<String,Object> posts = (Map<String,Object>)m.get('posts');
                
                  //Assign values to the wrapper object.
         /*       objDetailsWrapper = new CallEarlyHandoverToGetHandoverDetails1.EarlyHandoverMQService1Response();
                objDetailsWrapper.P_REQUEST_NUMBER= String.valueOf( posts.get('P_REQUEST_NUMBER') );
                objDetailsWrapper.P_REQUEST_NAME= String.valueOf( posts.get('P_REQUEST_NAME') );
                objDetailsWrapper.P_SOURCE_SYSTEM= String.valueOf( posts.get('P_SOURCE_SYSTEM') );
                objDetailsWrapper.Registrationid = String.valueOf( posts.get('ATTRIBUTE1') );
                objDetailsWrapper.JOPD_Suite_Area= String.valueOf( posts.get('ATTRIBUTE2') );
                objDetailsWrapper.JOPD_Balcony_Area= String.valueOf( posts.get('ATTRIBUTE3') );
                objDetailsWrapper.JOPD_Total_Area= String.valueOf( posts.get('ATTRIBUTE4') );
                objDetailsWrapper.JOPD_Entitlement= String.valueOf( posts.get('ATTRIBUTE5') );
                objDetailsWrapper.Litigation_Flag= String.valueOf( posts.get('ATTRIBUTE6') );
                objDetailsWrapper.Mortgage_Flag= String.valueOf( posts.get('ATTRIBUTE7') );
                objDetailsWrapper.Status= String.valueOf( posts.get('ATTRIBUTE8') );
                objDetailsWrapper.Billable_Amount= String.valueOf( posts.get('ATTRIBUTE9') );
                objDetailsWrapper.Payment_Received= String.valueOf( posts.get('ATTRIBUTE10') );
                objDetailsWrapper.Deposit_Received= String.valueOf( posts.get('ATTRIBUTE11') );
                objDetailsWrapper.Legal_Flag= String.valueOf( posts.get('ATTRIBUTE12') );
                objDetailsWrapper.Default_Flag= String.valueOf( posts.get('ATTRIBUTE13') );
                objDetailsWrapper.Under_Termination= String.valueOf( posts.get('ATTRIBUTE14') );
                objDetailsWrapper.Area_Variation= String.valueOf( posts.get('ATTRIBUTE15') );
                objDetailsWrapper.ACD= String.valueOf( posts.get('ATTRIBUTE16') ); 
        system.debug(objDetailsWrapper);
        return objDetailsWrapper ;*/
    }
    
    public class EarlyHandoverMQService1Response {
        public String P_REQUEST_NUMBER{get;set;}
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