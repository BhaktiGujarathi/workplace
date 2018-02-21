public with sharing class CallEarlyHandoverMQService1 {
    @InvocableMethod 
    public static void CallEarlyHandoverMQService1Name(List<String> regId) {
        EarlyHandoverMQService1.HandoverHttpSoap11Endpoint objEligibleForHandover = new EarlyHandoverMQService1.HandoverHttpSoap11Endpoint();
        objEligibleForHandover.timeout_x = 120000 ;
        list<EarlyHandoverMQService2.APPSXXDC_PROCESS_SERX1794747X1X5> lstReg = new list<EarlyHandoverMQService2.APPSXXDC_PROCESS_SERX1794747X1X5>();
        EarlyHandoverMQService2.APPSXXDC_PROCESS_SERX1794747X1X5 reg = new EarlyHandoverMQService2.APPSXXDC_PROCESS_SERX1794747X1X5();
        reg.ATTRIBUTE1 = 'No';
        reg.ATTRIBUTE10 = '';
        reg.ATTRIBUTE11 = '';
        reg.ATTRIBUTE12 = '';
        reg.ATTRIBUTE13 = '';
        reg.ATTRIBUTE14 = '';
        reg.ATTRIBUTE15 = '';
        reg.ATTRIBUTE16 = '';
        reg.ATTRIBUTE17 = '';
        reg.ATTRIBUTE18 = '';
        reg.ATTRIBUTE19 = '';
        reg.ATTRIBUTE2 = 'Yes';
        reg.ATTRIBUTE20 = '';
        reg.ATTRIBUTE21 = '';
        reg.ATTRIBUTE22 = '';
        reg.ATTRIBUTE23 = '';
        reg.ATTRIBUTE24 = '';
        reg.ATTRIBUTE25 = '';
        reg.ATTRIBUTE26 = '';
        reg.ATTRIBUTE27 = '';
        reg.ATTRIBUTE28 = '';
        reg.ATTRIBUTE29 = '';
        reg.ATTRIBUTE3 = '';
        reg.ATTRIBUTE30 = '';
        reg.ATTRIBUTE31 = '';
        reg.ATTRIBUTE32 = '';
        reg.ATTRIBUTE33 = '';
        reg.ATTRIBUTE34 = '';
        reg.ATTRIBUTE35 = '';
        reg.ATTRIBUTE36 = '';
        reg.ATTRIBUTE37 = '';
        reg.ATTRIBUTE38 = '';
        reg.ATTRIBUTE39 = '';
        reg.ATTRIBUTE4 = '';
        reg.ATTRIBUTE41 = '';
        reg.ATTRIBUTE42 = '';
        reg.ATTRIBUTE43 = '';
        reg.ATTRIBUTE44 = '';
        reg.ATTRIBUTE45 = '';
        reg.ATTRIBUTE46 = '';
        reg.ATTRIBUTE47 = '';
        reg.ATTRIBUTE48 = '';
        reg.ATTRIBUTE49 = '';
        reg.ATTRIBUTE5 = '';
        reg.ATTRIBUTE50 = '';
        reg.ATTRIBUTE6 = '';
        reg.ATTRIBUTE7 = '';
        reg.ATTRIBUTE8 = '';
        reg.ATTRIBUTE9 = '';
        reg.PARAM_ID = regId.get(0);
        lstReg.add(reg);
        system.debug('lstReg'+lstReg);
        string strHand = objEligibleForHandover.UPDATE_EARLY_HO_FLAG('78534637','UPDATE_EARLY_HO_FLAG','SFDC',lstReg);
        system.debug('strHand '+strHand );
        EarlyHandoverMQService1Response objEligibleForHandoverResponse = new EarlyHandoverMQService1Response();
        objEligibleForHandoverResponse = (EarlyHandoverMQService1Response)JSON.deserialize(strHand, CallEarlyHandoverMQService1.EarlyHandoverMQService1Response.class);
        system.debug('objEligibleForHandoverResponse'+objEligibleForHandoverResponse);       
    }
    
    public class EarlyHandoverMQService1Response {
        public String P_REQUEST_NUMBER {get;set;}
        public String P_REQUEST_NAME{get;set;}
        public String P_SOURCE_SYSTEM{get;set;}
        public list<EarlyHandoverMQService2.APPSXXDC_PROCESS_SERX1794747X1X5> lstReg;
    }
}