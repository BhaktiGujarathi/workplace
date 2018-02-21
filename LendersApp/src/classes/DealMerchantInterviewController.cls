public class DealMerchantInterviewController {
    
    public Opportunity opp{get;set;}
    public List<MerchantInterviewQuestion__c> lstQuestion{get;set;}
    public List<MerchantInterviewQuestion__c> lstVerQuestion{get;set;}
    public List<UWQuestion> lstUWQuestion{get;set;}
    public String oppOwnerContact;
    

    public DealMerchantInterviewController(ApexPages.StandardSetController controller) {
        
        opp = new Opportunity();
        lstQuestion = new List<MerchantInterviewQuestion__c>();
        lstVerQuestion = new List<MerchantInterviewQuestion__c>();
        lstUWQuestion = new List<UWQuestion>();

        String dealId = ApexPages.currentpage().getParameters().keyset().contains('id') 
                            ? ApexPages.currentpage().getParameters().get('id') 
                            : ApexPages.currentpage().getParameters().get('dealid');

        List<Opportunity> lstDeal = new List<Opportunity>();
            
        lstDeal = [SELECT Id, 
                          AccountId, 
                          McaApp__Funded_Notes__c, 
                          Completed__c, 
                          Date_Applied__c, 
                          McaApp__Owner_1__c, 
                          McaApp__Owner_1__r.Name, 
                          ProgramType__c, 
                          Date_Interview__c,
                          Interview_Score__c, 
                          Interviewee__c, 
                          Interview_Status__c, 
                          Underwriting_Stage__c, 
                          Account.McaApp__Years_in_Business__c, 
                          Account.Name, 
                          Underwriting_Notes__c,
                          McaApp__App_Received_Date__c 
                     FROM Opportunity WHERE Id =:dealId];

        if ( lstDeal.size() > 0 ) {

            opp = lstDeal[0];
        }


        Map<Id,UWVerification__c> mapVer = new Map<Id,UWVerification__c>();
        Map<Id,McaApp__Stips__c> mapStip = new Map<Id,McaApp__Stips__c>();
        Set<Id> setVerId = new Set<Id>();
        Set<Id> setStipId = new Set<Id>();

         //Get all Interview questions with current deal type
        for ( MerchantInterviewQuestion__c objQue: [SELECT Id, 
                                                          Category__c, 
                                                          Opportunity__c, 
                                                          Question__c, 
                                                          Stips__c, 
                                                          Verification__c,
                                                          InterviewNotes__c, 
                                                          Completed__c,
                                                          Sort_Order__c
                                                     FROM MerchantInterviewQuestion__c 
                                                    WHERE Opportunity__c = :opp.Id 
                                                       OR (Opportunity__c = :opp.Id AND (Stips__c != null OR Verification__c != null)) ORDER BY Sort_Order__c]) {
            if (objQue.Stips__c != null) {
                
                setStipId.add(objQue.Stips__c);
                lstVerQuestion.add(objQue);
            }
            else if (objQue.Verification__c != null) {
                
                setVerId.add(objQue.Verification__c);
                lstVerQuestion.add(objQue);
            }
            else if (objQue.Opportunity__c != null) {
                
                lstQuestion.add(objQue);
            }
        }

        //get respective verification of questions
        mapVer = new Map<Id,UWVerification__c>( [SELECT Id, Name, Completed__c FROM UWVerification__c WHERE Id IN :setVerId] );
        mapStip = new Map<Id,McaApp__Stips__c>( [SELECT Id, Name, Completed__c FROM McaApp__Stips__c WHERE Id IN :setStipId] );

        for ( MerchantInterviewQuestion__c objQue: lstVerQuestion ) {
            
            if ( objQue.Stips__c != null && mapStip.keyset().contains(objQue.Stips__c) ) {
                
                lstUWQuestion.add( new UWQuestion( 'stip', mapStip.get( objQue.Stips__c ), objQue ) );
            }
            
            if ( objQue.Verification__c != null && mapVer.keyset().contains( objQue.Verification__c ) ) {
                
                lstUWQuestion.add( new UWQuestion( 'verification', mapVer.get( objQue.Verification__c ), objQue ) );
            }
        }
    }


    public DealMerchantInterviewController(ApexPages.StandardController controller) {

        opp = new Opportunity();
        lstQuestion = new List<MerchantInterviewQuestion__c>();
        lstVerQuestion = new List<MerchantInterviewQuestion__c>();
        lstUWQuestion = new List<UWQuestion>();

        String dealId = ApexPages.currentpage().getParameters().get('id');

        List<Opportunity> lstDeal = new List<Opportunity>();
        lstDeal = [SELECT Id FROM Opportunity WHERE Id =:dealId];

        if ( lstDeal.size() > 0 ) {

            opp = lstDeal[0];
        }

        Map<Id,UWVerification__c> mapVer=new Map<Id,UWVerification__c>();
        Map<Id,McaApp__Stips__c> mapStip=new Map<Id,McaApp__Stips__c>();
        Set<Id> setVerId = new Set<Id>();
        Set<Id> setStipId = new Set<Id>();

         //Get all Interview questions with current deal type
        for (MerchantInterviewQuestion__c objQue: [SELECT Id, 
                                                          Category__c, 
                                                          Opportunity__c, 
                                                          Question__c, 
                                                          Stips__c, 
                                                          Verification__c,
                                                          InterviewNotes__c, 
                                                          Sort_Order__c,
                                                          Completed__c 
                                                    FROM MerchantInterviewQuestion__c 
                                                   WHERE Opportunity__c = :opp.Id OR (Opportunity__c = :opp.Id AND (Stips__c != null OR Verification__c != null)) ORDER BY Sort_Order__c]) {
            if ( objQue.Stips__c != null ) {
                
                setStipId.add( objQue.Stips__c );
                lstVerQuestion.add( objQue );
            }
            else if ( objQue.Verification__c != null ) {
                
                setVerId.add( objQue.Verification__c );
                lstVerQuestion.add( objQue );
            }
            else if ( objQue.Opportunity__c != null ) {
                
                lstQuestion.add(objQue);
            }
        }

        
        //get respective verification of questions
        mapVer = new Map<Id,UWVerification__c>( [SELECT Id, Name, Completed__c FROM UWVerification__c WHERE Id IN :setVerId] );
        mapStip = new Map<Id,McaApp__Stips__c>( [SELECT Id, Name, Completed__c FROM McaApp__Stips__c WHERE Id IN :setStipId] );

        for ( MerchantInterviewQuestion__c objQue : lstVerQuestion ) {

            if ( objQue.Stips__c != null && mapStip.keyset().contains( objQue.Stips__c )) {

                lstUWQuestion.add( new UWQuestion( 'stip', mapStip.get( objQue.Stips__c ), objQue ) );
            }

            if ( objQue.Verification__c != null && mapVer.keyset().contains( objQue.Verification__c )) {

                lstUWQuestion.add( new UWQuestion( 'verification', mapVer.get( objQue.Verification__c ), objQue));
            }
        }
    }

    public pagereference quickSave() {
        
        saveQuestions();
        return null;
    }

    public pagereference saveQuestions() {

        update opp;

        if (opp.AccountId != null) {

            update opp.Account;
        }

        //insert questions
        if (lstQuestion.size() > 0) {
            
            update lstQuestion;
        }

        List<MerchantInterviewQuestion__c> lstQuestionsToUpdate = new List<MerchantInterviewQuestion__c>();

        //update verification/stip flaged questions
        for( UWQuestion uw : lstUWQuestion) {
        
            if ( uw.objQues.InterviewNotes__c != null && uw.objQues.InterviewNotes__c != '' ) {
        
                uw.objQues.Completed__c = true;
            }
            else {
                uw.objQues.Completed__c = false;
            }
            
            lstQuestionsToUpdate.add( uw.objQues );
        }

        //insert flaged questions
        if ( lstQuestionsToUpdate.size() > 0 ) {
            
            update lstQuestionsToUpdate;
        }

        return new pagereference( '/' + opp.Id );
    }

    public Pagereference cancel() {
        
        return new pagereference( '/' + opp.Id );   
    }

  
    public class UWQuestion {
        
        public UWVerification__c objVer { get; set; }
        public McaApp__Stips__c objStip { get; set; }
        public MerchantInterviewQuestion__c objQues { get; set; }
        public string type { get; set; }

        public UWQuestion(string t, UWVerification__c v, MerchantInterviewQuestion__c q) {

            type = t;
            objVer = v;
            objQues = q;
        }

        public UWQuestion(string t, McaApp__Stips__c s, MerchantInterviewQuestion__c q) {
            
            type = t;
            objStip = s;
            objQues = q;
        }
    }
}