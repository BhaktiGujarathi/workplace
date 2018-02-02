/**
 * Class QuoteHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class QuoteDeterminationScriptService implements TriggerInterface {
    public Map<Id, String> InsMap;
    public Set<Id> productIds = new Set<Id>();
    public List<Product2> productList;
    public Map<String,String> pbMap = new Map<String,String>();
    public Map<String,String> ReservationCAR ;
    public Map<String,String> ACAScriptMap ;
    public Map<String,Double> TotalRateMap;
    public Map<String,String> ReservationAIR;
    public Map<String,String> pbMapAutoAdd = new Map<String,String>();
    public List<QuoteLineItem> qiList = new List<QuoteLineItem>();
    public Map<String, String> ScriptCompMap;
    public Map<String, String> ScriptCompMap1;
    public Map<Id, String> PayAgreeMap;
    public Map<Id, String> PayAgreeMap1;
    public Map<Id, boolean> PayAgreementMap;
    public Map<Id, Opportunity> OppMap;
    public list<Facility_Program_Determination_Script__c> ScriptList;
    public Map<String,String> Mapdsc;
    
    public Map<String,String> ibMap = new Map<String,String>();
    public Map<String,String> ibDispMap = new Map<String,String>();
    public Map<String,String> pawMap = new Map<String,String>();
    public Map<String,Patient_Insurance__c> piMap = new Map<String,Patient_Insurance__c>();
    public Map<String,Facility_Program_Determination_Script__c> fpDerMap = new Map<String,Facility_Program_Determination_Script__c>();
    public Id FRN_PriceBookId ;
    public Map<String,List<Reservation__c>> oppReservationMap;  
    public Map<Id,Pay_Agreement_Worksheet__c> pawIbMap;
    public String DeterminationScript='';
    public String medicalRecordScript = '';
    public String highAcuityScript = '';
    public String professionCoverageScript = '';
    public String physicianFeesScript = '';
    public Boolean yearEndMode = PAW_YearEnd_Config.fetch().Year_End_Mode_Enabled__c;
    public static Map<String, String> secondaryPAWrelatedFieldMap = new Map<String, String>
                        {
                          'Detox_Benefit_Rate__c'              =>'Secondary_Detox_Benefit_Rate__c',
                          'Deductible__c'                      =>'Secondary_Deductible__c',
                          'Deductible_Met__c'                  =>'Secondary_Deductible_Met__c',
                          'Out_of_Pocket_Max__c'               =>'Secondary_Out_of_Pocket_Max__c',
                          'Out_of_Pocket_Max_Met__c'           =>'Secondary_Out_of_Pocket_Max_Met__c',
                          'Co_Pay__c'                          =>'Secondary_Co_Pay__c',
                          'Room_and_Board_Fee_s__c'            =>'Secondary_Room_and_Board_Fee_s__c',
                          'Ancillary_Fee_s__c'                 =>'Secondary_Ancillary_Fee_s__c',
                          'Miscellaneous_Fee_s__c'             =>'Secondary_Miscellaneous_Fee_s__c',
                          'Total_Patient_Contribution__c'      =>'Secondary_Total_Patient_Contribution__c',
                          'Deductible_Amount_Requested__c'     =>'Secondary_Deductible_Amount_Requested__c',
                          'Co_Insurance_Amount_Requested__c'   =>'Secondary_Co_Insurance_Amount_Requested__c',
                          'Professional_OP_Additional_Info__c' =>'Secondary_Professional_OP_Additional_Inf__c',
                          'Physician_Fees_Additional_Info__c'  =>'Secondary_Physician_Fees_Additional_Info__c'

                        };
    
    // Constructor
    public QuoteDeterminationScriptService(){
        system.debug('>>> in custom service');
        TotalRateMap = new Map<String,Double>();
        InsMap = new Map<Id, String>();
        ScriptCompMap = new Map<String, String>();
        ScriptCompMap1 = new Map<String, String>();
        ReservationCAR = new Map<String, String>();
        ACAScriptMap = new Map<String, String>();
        ReservationAIR = new Map<String, String>();
        PayAgreeMap = new Map<Id, String>();
        productList = new List<Product2>();
        PayAgreeMap1 = new Map<Id, String>();
        PayAgreementMap = new Map<Id, boolean>();
        OppMap = new Map<Id, Opportunity>();
        oppReservationMap = new Map<String,List<Reservation__c>>();
        ScriptList = new list<Facility_Program_Determination_Script__c>();
        Mapdsc = new Map<String,String>();
        Default_Pricebook__c pricebookName = Default_Pricebook__c.getValues('FRN Price Book');
        pawIbMap = new Map<Id,Pay_Agreement_Worksheet__c>();
        if(pricebookName!=null)
            FRN_PriceBookId = [SELECT Id 
                                 FROM Pricebook2 
                                WHERE Name =:pricebookName.Default_Pricebook_Name__c].Id;
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){  
      Set<Id> pawIds = new Set<Id>();
      Set<Id> FrnId = new Set<Id>();
      Set<Id> FrnInsId = new Set<Id>();
      Set<Id> QuoteProgramId = new Set<Id>();
      Set<Id> QuoteFacilityId = new Set<Id>();
      Set<Id> QuotePayAgreeId = new Set<Id>();
      Set<Id> OppId = new Set<Id>();
      Set<Id> piId = new Set<Id>();
    
        if(!Trigger.isDelete){
      for(Quote quot : (List<Quote>)trigger.new){
            if(quot.Pay_Agreement_Worksheet__c!=null) {
                pawIds.add(quot.Pay_Agreement_Worksheet__c);
                pawIds.add(quot.Secondary_Pay_Agreement_Worksheet__c); 
            }           
      }
        }
        
        if(pawIds.size()>0){
            pawIbMap = new Map<Id,Pay_Agreement_Worksheet__c>([
                                            Select Id,
                                                   Patient_Insurance__r.Name,
                                                   Patient_Insurance__r.Insurance_Company__r.Name,
                                                   Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c,
                                                   Insurance_Benefit__r.Patient_Insurance__r.ACA_Policy__c,
                                                   Insurance_Benefit__r.Patient_Insurance__r.Accepts_Assignment_of_Benefits__c,
                                                   Insurance_Benefit__r.Disposition__c 
                                              FROM Pay_Agreement_Worksheet__c 
                                             WHERE Id IN:pawIds 
                                             AND Insurance_Benefit__c!=null]);
        }
        
        for(Pay_Agreement_Worksheet__c paws : pawIbMap.values()){
            piId.add(paws.Patient_Insurance__c);
        }
        
      //quoteMap = new Map<Id,Quote>([SELECT Id,Pay_Agreement_Worksheet__r.Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c FROM Quote WHERE Id IN : quoteIdSet]);

        if(!Trigger.isDelete){
            for(Quote Quo : (List<Quote>)trigger.new){
                FrnId.add(Quo.FRN_Facility__c);
                FrnInsId.add(Quo.Insurance_Company__c);
                QuoteProgramId.add(Quo.Facility_Program__c);
                QuoteFacilityId.add(Quo.FRN_Facility__c);
                QuotePayAgreeId.add(Quo.Pay_Agreement_Worksheet__c);
                OppId.add(Quo.OpportunityId);
            }
        }
        Set<String> accName = new Set<String>();
        if(QuoteFacilityId.size() > 0){
            for(Account acc : [Select id,
                                      Name 
                                 from Account 
                                where Id IN: QuoteFacilityId]){
                accName.add(acc.Name);
            }
        }
        
        List<Insurance_Company_Rate_Adjustment__c> Inslist = [Select Id, 
                                                                     FRN_Facility__c,
                                                                     Insurance_Company__c,
                                                                     Contract_Type__c
                                                                from Insurance_Company_Rate_Adjustment__c
                                                               where Insurance_Company__c IN: FrnInsId 
                                                                 AND FRN_Facility__c IN:FrnId limit 1];
        
        for(Insurance_Company_Rate_Adjustment__c Ins : Inslist){
            InsMap.put(Ins.FRN_Facility__c, Ins.Contract_Type__c);
            
        }     
        
        list<Determination_Script_Component__c> dsc = [Select Id, 
                                                              Script__c,
                                                              Type__c
                                                         from Determination_Script_Component__c];
        for(Determination_Script_Component__c dac:dsc){
            if(dac.Type__c != null){
                Mapdsc.put(dac.Type__c,dac.Script__c);
            }
            if(dac.Type__c == 'Weekend/Weeknight Determination' && dac.Script__c != null){
                DeterminationScript = dac.Script__c;
            }
            if(dac.Type__c == 'Medical records' && dac.Script__c != null) {
                medicalRecordScript = dac.Script__c;
            }
            if(dac.Type__c == 'High acuity' && dac.Script__c != null) {
                highAcuityScript = dac.Script__c;
            }
            if(dac.Type__c == 'Professional Coverage' && dac.Script__c != null) {
                professionCoverageScript = dac.Script__c;
            }
            if(dac.Type__c == 'Physician Fees' && dac.Script__c != null) {
                physicianFeesScript = dac.Script__c;
            }
        }

        if(OppId.size() > 0){
            for(Opportunity opp : [Select Id, 
                                          Have_You_Attended_Anger_Mgmt_Class__c,
                                          Involved_in_Domestic_Violence__c,
                                          Have_You_Physically_Hit_Harmed_Anyone__c,
                                          Have_You_Had_Thoughts_of_Harming_Others__c 
                                     from opportunity 
                                    where Id IN:OppId]){
                OppMap.put(opp.Id, opp);
            }
        }
        
        List<Pay_Agreement_Worksheet__c> PayWorksheetList = [Select Id,
                                                                    Insurance_Benefit__r.RecordType.name, 
                                                                    Insurance_Benefit__c, 
                                                                    Insurance_Benefit__r.Disposition__c 
                                                               from Pay_Agreement_Worksheet__c 
                                                              where Id IN:QuotePayAgreeId];
        list<string> RecordTypeName= new list<string>();
        for(Pay_Agreement_Worksheet__c Pay : PayWorksheetList){
            RecordTypeName.add(pay.Insurance_Benefit__r.RecordType.name);
            PayAgreeMap.put(Pay.Id, Pay.Insurance_Benefit__r.Disposition__c);
            pawMap.put(pay.Id,pay.Insurance_Benefit__c);
        }
        
        
        ScriptList = [Select Id, 
                             Determination_Script__c,
                             Facility_Program__c,
                             Contract_Type__c,
                             Assignment_of_Benefits_Script__c,
                             ACA_Policy_Script__c,
                             COBRA_Policy_Script__c,
                             Year_End_Determination_Script__c
                        from Facility_Program_Determination_Script__c 
                       where Facility_Program__c =:QuoteProgramId 
                         AND FRN_Facility__c =:accName 
                         AND (Contract_Type__c IN: RecordTypeName) ];
                                 
        for(Facility_Program_Determination_Script__c fp:ScriptList){ 
            if(!fpDerMap.containsKey(fp.Facility_Program__c))
                fpDerMap.put(fp.Facility_Program__c,fp);
        }
        
        if(pawMap.size() > 0){
            for(Insurance_Benefit__c ib : [Select id,
                                                  Patient_Insurance__c,
                                                  Disposition__c 
                                             from Insurance_Benefit__c 
                                            where Id IN: pawMap.values()]){
                ibMap.put(ib.Id,ib.Patient_Insurance__c);
                ibDispMap.put(ib.Id,ib.Disposition__c);
            }
            if(ibMap.size() > 0){
                for(Patient_Insurance__c pi : [Select id, 
                                                      COB_Needed__c,
                                                      Benefits_Check__c,
                                                      Approving_Without_Medical_Records__c,
                                                      Patient_is_High_Acuity__c
                                                 from Patient_Insurance__c 
                                                where Id IN: ibMap.values()]){
                    piMap.put(pi.Id,pi);
                }
            }
        }        
    }

    public void bulkAfter(){
         Set<Id> pawIds = new Set<Id>();
        Set<Id> pId = new Set<Id>();
        Set<Id> oppId = new Set<Id>();
        if(!Trigger.isDelete){
            for(Quote Quo : (List<Quote>)trigger.new){
                pId.add(Quo.Pricebook2Id);
                oppId.add(Quo.OpportunityId);
                 if(Quo.Pay_Agreement_Worksheet__c!=null) pawIds.add(Quo.Pay_Agreement_Worksheet__c);
            }
        }
        if(pawIds.size()>0){
            pawIbMap = new Map<Id,Pay_Agreement_Worksheet__c>([Select Id,
                                                                      Uncovered_Charges__c,
                                                                      Days_60_90_Fees__c,
                                                                      Uncovered_Days_Rate__c,
                                                                      Uncovered_Days_Override__c,
                                                                      Num_Days_Uncovered__c,
                                                                      Room_and_Board_Days_Rate__c,
                                                                      Ancillary_Fees__c,
                                                                      FRN_Facility__r.Ownership
                                                                 FROM Pay_Agreement_Worksheet__c 
                                                                WHERE Id IN:pawIds]);
        }
        
        Double totalAmount = 0.00;
        if(oppId!=null){
            
            List<Reservation__c> resLsit;           
            for(Reservation__c res: [SELECT Id, 
                                            RecordType.name, 
                                            Trip__r.opportunity__r.name,
                                            Rate__c,
                                            Name, 
                                            Total_Amount_Charged__c 
                                       FROM Reservation__c 
                                      WHERE Trip__r.Opportunity__c IN : oppId 
                                       AND (RecordType.name = 'Car Service' 
                                         OR RecordType.name = 'Airfare')]){
                if(oppReservationMap.containsKey(res.Trip__r.Opportunity__c)){
                    (oppReservationMap.get(res.Trip__r.Opportunity__c)).add(res);
                } else {
                    resLsit = new List<Reservation__c>();
                    resLsit.add(res);
                    oppReservationMap.put(res.Trip__r.Opportunity__c,resLsit);
                }
            }
        }        
        
        for(Product2 pd : [SELECT Auto_Add_to_Quote_Line_Items__c,
                                  Family,
                                  Id,
                                  IsActive,
                                  Name,
                                  Payment_Application_Order__c,
                                  Sort_Order__c
                             FROM Product2
                            WHERE Auto_Add_to_Quote_Line_Items__c = true]){
            productIds.add(pd.id);
            productList.add(pd);            
        }
        if(pId.size() > 0){
            for(PricebookEntry pbe : [Select id,
                                             Pricebook2Id,
                                             Product2Id,
                                             UnitPrice 
                                        from PricebookEntry
                                      where  Product2Id IN: productIds 
                                         and Pricebook2Id =: FRN_PriceBookId]){
                pbMapAutoAdd.put(pbe.Product2Id,pbe.Id);
            }
        }
        
        //IN :pId
        if(pId.size() > 0){
            for(PricebookEntry pbe : [Select id,
                                             Pricebook2Id,
                                             Product2Id,
                                             UnitPrice
                                        from PricebookEntry
                                      where  Pricebook2Id IN: pId]){
                pbMap.put(pbe.Pricebook2Id,pbe.id);
            }
        }
    }
 
    public void beforeInsert(SObject so){        
      
        Quote Quot = (Quote)so;
        if(Quot.Insurance_Company__c!=null){
            Quot.Insurance_Company_Contract_Type__c = InsMap.get(Quot.FRN_Facility__c);
        }
        if(Quot.Secondary_Insurance_Company__c!=null){
            Quot.Secondary_Insurance_Company_Name__c = pawIbMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c)
                                                                        .Patient_Insurance__r
                                                                        .Insurance_Company__r
                                                                        .Name;
        }

        if( Quot.FRN_Facility__c!=null 
         && Quot.Facility_Program__c!=null
         && fpDerMap.containsKey(Quot.Facility_Program__c)) 
        {
            Facility_Program_Determination_Script__c fcltyPrgrmScriptInstance = fpDerMap.get(Quot.Facility_Program__c);
            
            if( true == yearEndMode ){
              Quot.Determination_Script__c = quoteFields(fcltyPrgrmScriptInstance.Year_End_Determination_Script__c,Quot, false);
              Quot.Secondary_Determination_Script__c = quoteFields(fcltyPrgrmScriptInstance.Year_End_Determination_Script__c,Quot, true);
            } else {
              Quot.Determination_Script__c = quoteFields(fcltyPrgrmScriptInstance.Determination_Script__c,Quot, false);
              Quot.Secondary_Determination_Script__c = quoteFields(fcltyPrgrmScriptInstance.Determination_Script__c,Quot, true);
            }

            if(pawMap.containsKey(Quot.Pay_Agreement_Worksheet__c)) {
                if(piMap.get(ibMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c))).Approving_Without_Medical_Records__c){
                    Quot.Medical_Records_Text__c = medicalRecordScript.stripHtmlTags();
                }
                if(piMap.get(ibMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c))).Patient_is_High_Acuity__c){
                    Quot.High_Acuity_Text__c = highAcuityScript.stripHtmlTags();
                }
                if(pawIbMap.containsKey(Quot.Pay_Agreement_Worksheet__c)) {
                    if(pawIbMap.get(Quot.Pay_Agreement_Worksheet__c).Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c == 'Yes') {
                        Quot.COBRA_Policy_Script__c = quoteFields(fcltyPrgrmScriptInstance.COBRA_Policy_Script__c,Quot,false);
                    }
                    if(pawIbMap.get(Quot.Pay_Agreement_Worksheet__c).Insurance_Benefit__r.Patient_Insurance__r.Accepts_Assignment_of_Benefits__c == 'No'){
                        Quot.Assignment_of_Benefits_Script__c = quoteFields(fcltyPrgrmScriptInstance.Assignment_of_Benefits_Script__c,Quot, false);
                    }
                    if(pawIbMap.get(Quot.Pay_Agreement_Worksheet__c).Insurance_Benefit__r.Patient_Insurance__r.ACA_Policy__c == 'Yes'){
                        Quot.ACA_Policy_Script__c = quoteFields(fcltyPrgrmScriptInstance.ACA_Policy_Script__c,Quot, false);
                    }
                    if(DeterminationScript != null 
                    && DeterminationScript != '' 
                    && pawIbMap.get(Quot.Pay_Agreement_Worksheet__c).Insurance_Benefit__r.Disposition__c == 'Weekend / Weeknight / Holiday')
                    {
                        Quot.Determination_Script__c = quoteFields(DeterminationScript, Quot, false);
                    }
                }
                if(ibDispMap.containsKey(pawMap.get(Quot.Pay_Agreement_Worksheet__c))){
                    if(ibDispMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c)) == 'Policy Termed'){
                        Quot.Policy_Termed__c = Mapdsc.get('Policy Termed');
                    }
                    if(ibDispMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c)) == 'Unable to Verify Benefits'){
                        Quot.Unable_to_Verify_Benefits__c = Mapdsc.get('Unable to Verify Benefits');
                    }
                }           
            
                if(ibMap.containsKey(pawMap.get(Quot.Pay_Agreement_Worksheet__c))){
                    if(piMap.containsKey(ibMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c)))){
                        if(piMap.get(ibMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c))).COB_Needed__c == 'Yes'){
                            system.debug('Mapdsc' +Mapdsc);
                            Quot.Coordination_of_Benefits__c = Mapdsc.get('Coordination of Benefits') ;
                        }                        
                        if(piMap.get(ibMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c))).Benefits_Check__c == true){
                            Quot.Benefits_Check__c = Mapdsc.get('Benefits Check');
                        }
                        
                    }
                }
            }

            if(pawMap.containsKey(Quot.Secondary_Pay_Agreement_Worksheet__c)) {
                if(piMap.get(ibMap.get(pawMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c))).Approving_Without_Medical_Records__c) {
                    Quot.Secondary_Medical_Records_Text__c = medicalRecordScript.stripHtmlTags();
                }
                if(piMap.get(ibMap.get(pawMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c))).Patient_is_High_Acuity__c) {
                    Quot.Secondary_High_Acuity_Text__c = highAcuityScript.stripHtmlTags();
                }
                if(pawIbMap.containsKey(Quot.Secondary_Pay_Agreement_Worksheet__c)) {
                    if(pawIbMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c).Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c == 'Yes'){
                        Quot.Secondary_COBRA_Policy_Script__c = quoteFields(fcltyPrgrmScriptInstance.COBRA_Policy_Script__c,Quot, true);
                    }
                    if(pawIbMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c).Insurance_Benefit__r.Patient_Insurance__r.Accepts_Assignment_of_Benefits__c == 'No') {
                        Quot.Secondary_Assignment_of_Benefits_Script__c = quoteFields(fcltyPrgrmScriptInstance.Assignment_of_Benefits_Script__c,Quot, true);
                    }
                    if(pawIbMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c).Insurance_Benefit__r.Patient_Insurance__r.ACA_Policy__c == 'Yes'){
                        Quot.Secondary_ACA_Policy_Script__c = quoteFields(fcltyPrgrmScriptInstance.ACA_Policy_Script__c,Quot, true);
                    }
                    if(DeterminationScript != null 
                    && DeterminationScript != '' 
                    && pawIbMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c).Insurance_Benefit__r.Disposition__c == 'Weekend / Weeknight / Holiday')
                    {
                        Quot.Secondary_Determination_Script__c = quoteFields(DeterminationScript, Quot, true);
                    }
                }
                if(ibDispMap.containsKey(pawMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c))){
                    if(ibDispMap.get(pawMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c)) == 'Policy Termed'){
                        Quot.Secondary_Policy_Termed__c = Mapdsc.get('Policy Termed');
                    }
                    if(ibDispMap.get(pawMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c)) == 'Unable to Verify Benefits'){
                        Quot.Secondary_Unable_to_Verify_Benefits__c = Mapdsc.get('Unable to Verify Benefits');
                    }
                }           
            
                if(ibMap.containsKey(pawMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c))){
                    if(piMap.containsKey(ibMap.get(pawMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c)))){
                        if(piMap.get(ibMap.get(pawMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c))).COB_Needed__c == 'Yes'){
                            system.debug('Mapdsc' +Mapdsc);
                            Quot.Secondary_Coordination_of_Benefits__c = Mapdsc.get('Coordination of Benefits') ;
                        }                        
                        if(piMap.get(ibMap.get(pawMap.get(Quot.Secondary_Pay_Agreement_Worksheet__c))).Benefits_Check__c == true){
                            Quot.Secondary_Benefits_Check__c = Mapdsc.get('Benefits Check');
                        }
                        
                    }
                }
            }
        }

        if(physicianFeesScript != null && physicianFeesScript != '') {
            if(Quot.get('Physician_Fees_Additional_Info__c') != null 
            && Quot.get('Physician_Fees_Additional_Info__c') != '' ) {
                if(!String.valueOf(Quot.get('Physician_Fees_Additional_Info__c')).equalsIgnoreCase('Are Same'))
                {
                    Quot.Physician_Fees__c = quoteFields(physicianFeesScript,Quot, false);
                }
                if(String.valueOf(Quot.get('Physician_Fees_Additional_Info__c')).equalsIgnoreCase('Are Same'))
                {
                    Quot.Physician_Fees__c = 'Physician fees are covered the same.';
                }
            }
            if(Quot.get('Secondary_Physician_Fees_Additional_Info__c') != null 
            && Quot.get('Secondary_Physician_Fees_Additional_Info__c') != '' ) {
                if(!String.valueOf(Quot.get('Secondary_Physician_Fees_Additional_Info__c')).equalsIgnoreCase('Are Same'))
                {
                    Quot.Secondary_Physician_Fees__c = quoteFields(physicianFeesScript,Quot, true);
                }
                if(String.valueOf(Quot.get('Secondary_Physician_Fees_Additional_Info__c')).equalsIgnoreCase('Are Same')){
                    Quot.Secondary_Physician_Fees__c= 'Physician fees are covered the same.';
                }
            }            
        }
        if(professionCoverageScript != null && professionCoverageScript != '') {
            if(Quot.get('Professional_OP_Additional_Info__c') != null 
            && Quot.get('Professional_OP_Additional_Info__c')!= '') {
                if(!String.valueOf(Quot.get('Professional_OP_Additional_Info__c')).equalsIgnoreCase('Are Same')) {
                    Quot.Professional_Coverage__c = quoteFields(professionCoverageScript,Quot, false);
                }
                if(String.valueOf(Quot.get('Professional_OP_Additional_Info__c')).equalsIgnoreCase('Are Same')) {
                    Quot.Professional_Coverage__c = 'Professional Outpatient is covered the same.';
                }
            }
            if(Quot.get('Secondary_Professional_OP_Additional_Inf__c') != null 
            && Quot.get('Secondary_Professional_OP_Additional_Inf__c')!= '') {
                if(!String.valueOf(Quot.get('Secondary_Professional_OP_Additional_Inf__c')).equalsIgnoreCase('Are Same')) {
                    Quot.Secondary_Professional_Coverage__c = quoteFields(professionCoverageScript,Quot, true);
                }
                if(String.valueOf(Quot.get('Secondary_Professional_OP_Additional_Inf__c')).equalsIgnoreCase('Are Same')) {
                    Quot.Secondary_Professional_Coverage__c = 'Professional Outpatient is covered the same.';
                }
            }
        }
        
        if(OppMap.containsKey(Quot.opportunityId)){
            if(OppMap.get(Quot.opportunityId).Have_You_Attended_Anger_Mgmt_Class__c == 'Yes' 
            || OppMap.get(Quot.opportunityId).Involved_in_Domestic_Violence__c == 'Yes' 
            || OppMap.get(Quot.opportunityId).Have_You_Physically_Hit_Harmed_Anyone__c == 'Yes' 
            || OppMap.get(Quot.opportunityId).Have_You_Had_Thoughts_of_Harming_Others__c == 'Yes')
            {
                Quot.Aggression__c = Mapdsc.get('Aggression');
            }
        }
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
        
        Quote Quot = (Quote)so;
        if(Quot.Insurance_Company__c!=null){
            Quot.Insurance_Company_Contract_Type__c = InsMap.get(Quot.FRN_Facility__c);
        } 
        
        if(pawMap.containsKey(Quot.Pay_Agreement_Worksheet__c)){
            
            if(ibDispMap.containsKey(pawMap.get(Quot.Pay_Agreement_Worksheet__c))){
                if(ibDispMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c)) == 'Policy Termed'){
                    Quot.Policy_Termed__c = Mapdsc.get('Policy Termed');
                }
                if(ibDispMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c)) == 'Unable to Verify Benefits'){
                    Quot.Unable_to_Verify_Benefits__c = Mapdsc.get('Unable to Verify Benefits');
                }
            }    
            
            if(ibMap.containsKey(pawMap.get(Quot.Pay_Agreement_Worksheet__c))){
                if(piMap.containsKey(ibMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c)))){
                    if(piMap.get(ibMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c))).COB_Needed__c == 'Yes'){
                        Quot.Coordination_of_Benefits__c = Mapdsc.get('Coordination of Benefits') ;
                    }                    
                    if(piMap.get(ibMap.get(pawMap.get(Quot.Pay_Agreement_Worksheet__c))).Benefits_Check__c == true){
                        Quot.Benefits_Check__c = Mapdsc.get('Benefits Check');
                    }                    
                }
            }
        }
    }
    
    public void afterInsert(SObject so){ 
        Quote Quot = (Quote)so;
        for(Product2 p : productList){
            if(pbMapAutoAdd.containsKey(p.id)){
            //if(pbMapAutoAdd.containsKey(p.id)){
                QuoteLineItem qli = new QuoteLineItem();
                qli.QuoteId = Quot.Id;
                qli.PriceBookentryId = pbMapAutoAdd.get(p.id);
                qli.Product2Id = p.id;
                //qli.UnitPrice = 1;
                qli.Quantity = 1;
                qli.Auto_Added__c = true;
                if(p.Name == 'Deductible'){
                    qli.UnitPrice = Quot.Deductible_Remaining__c;                    
                } else if(p.Name == 'Co-Insurance'){
                    qli.UnitPrice = Quot.Co_Insurance_Remaining__c;
                } else if(p.Name == 'Ancillary Cost'){
                    qli.UnitPrice = Quot.Ancillary_Fee_s__c;
                } else if(p.Name == 'Airfare' || p.Name == 'Car Service'){
                    decimal tempFeeCS = 0.00;
                    decimal tempFeeAF = 0.00;
                    if (oppReservationMap.containsKey(Quot.OpportunityId)){
                        for(Reservation__c rv : oppReservationMap.get(Quot.OpportunityId)){
                            if(rv.RecordType.Name == 'Car Service' && p.Name == 'Car Service'){
                                tempFeeCS = tempFeeCS + ((rv.Rate__c!=null) ? rv.Rate__c : 0.00);
                            }
                            if(rv.RecordType.Name == 'Airfare' && p.Name == 'Airfare'){
                                tempFeeAF = tempFeeAF + ((rv.Total_Amount_Charged__c!=null) ? rv.Total_Amount_Charged__c : 0.00);
                            }                            
                        }
                    }
                    if(p.Name == 'Car Service'){
                        qli.UnitPrice = tempFeeCS;
                    }
                    if(p.Name == 'Airfare'){
                        qli.UnitPrice = tempFeeAF;
                    }
                } else if(p.Name == 'Amount Requested'){
                    qli.UnitPrice = 0;
                    if(Quot.Co_Insurance_Amount_Requested__c!=null) qli.UnitPrice = qli.UnitPrice+Quot.Co_Insurance_Amount_Requested__c;
                    if(Quot.Deductible_Amount_Requested__c!=null)  qli.UnitPrice = qli.UnitPrice+Quot.Deductible_Amount_Requested__c;
                    if(Quot.Private_Pay__c!=null)  qli.UnitPrice = qli.UnitPrice+Quot.Private_Pay__c;
                    if(Quot.Co_Pay_Amount_Requested__c!=null)  qli.UnitPrice = qli.UnitPrice+Quot.Co_Pay_Amount_Requested__c;
                    if(Quot.Secondary_Pay_Agreement_Worksheet__c != null) {
                        if(Quot.Secondary_Co_Insurance_Amount_Requested__c!=null) qli.UnitPrice = qli.UnitPrice+Quot.Secondary_Co_Insurance_Amount_Requested__c;
                        if(Quot.Secondary_Deductible_Amount_Requested__c!=null)  qli.UnitPrice = qli.UnitPrice+Quot.Secondary_Deductible_Amount_Requested__c;
                        if(Quot.Secondary_Co_Pay_Amount_Requested__c!=null)  qli.UnitPrice = qli.UnitPrice+Quot.Secondary_Co_Pay_Amount_Requested__c;
                    }
                } else if(p.Name == 'Room and Board'){
                    qli.UnitPrice = Quot.Room_and_Board_Fee_s__c;
                } else if(p.Name == 'Miscellaneous Expense'){
                    qli.UnitPrice = Quot.Miscellaneous_Fee_s__c;
                } else if((pawIbMap.Keyset()).Contains(quot.Pay_Agreement_Worksheet__c)){
                    if((pawIbMap.get(quot.Pay_Agreement_Worksheet__c)).FRN_Facility__r.Ownership == 'Talbott'){
                        if(p.Name == 'Uncovered Charges'){
                             qli.UnitPrice = pawIbMap.get(quot.Pay_Agreement_Worksheet__c).Uncovered_Charges__c;
                        }else if(p.Name == 'Days 60-90 Fees'){
                            qli.UnitPrice = pawIbMap.get(quot.Pay_Agreement_Worksheet__c).Days_60_90_Fees__c;
                        }else if(p.Name == 'Uncovered Days Charges'){
                            qli.UnitPrice = (pawIbMap.get(quot.Pay_Agreement_Worksheet__c).Num_Days_Uncovered__c )*(pawIbMap.get(quot.Pay_Agreement_Worksheet__c).Uncovered_Days_Rate__c );
                        }else if(p.Name == 'Room and Board Days Rate'){
                            qli.UnitPrice = pawIbMap.get(quot.Pay_Agreement_Worksheet__c).Room_and_Board_Days_Rate__c;
                        }/*else if(p.Name == 'Ancillary Fee'){
                            qli.UnitPrice = pawIbMap.get(quot.Pay_Agreement_Worksheet__c).Ancillary_Fees__c;
                        }*/
                    }
                } else {
                    qli.UnitPrice = 1;
                }
                if(qli.UnitPrice!=null && qli.UnitPrice>0){
                    qiList.add(qli);  
                }
            }
            
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        
    }
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){
       
    }
    

    public void afterDelete(SObject so){
        
    }
 
    public void afterUndelete(SObject so){
        
    }
 
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally(){
        if(qiList.size() > 0){
            insert qiList;
        } 
    }
    
    
    
     //To get Quote Object Field Values
    public String quoteFields(String determinationScript, Quote recordId, Boolean pYearEndMode){     
        return replace(pYearEndMode, determinationScript, 'Quote', recordId);
    }
    
    public String replace(Boolean pYearEndMode, String determinationScript, String objectName, Quote recordId){
        try{
            String qry = '';
            Pattern regex = Pattern.compile('\\{([^}]*)\\}');
            Matcher regexMatcher = regex.matcher(determinationScript);
            Set<String> tokens = new Set<String>();
            Map<String,String> strWithSpecialChar = new Map<String,String>();
            String originalAPIName;
            while (regexMatcher.find()){
                String dirtyVariable = regexMatcher.group();
                /* Extract curly braces and exclamation marks*/
                String variable = dirtyVariable.substring(1,dirtyVariable.length()-1);
                if(variable.contains('__c')){
                    originalAPIName = variable.substringBefore('__c');
                    originalAPIName = originalAPIName+'__c';
                    strWithSpecialChar.put(variable,originalAPIName.trim());
                }                 
                tokens.add(variable);
            }             
            //Replace values
            for(String s : tokens){ 
                determinationScript = determinationScript.replace('{'+ s +'}', getValue(objectName,recordID, (strWithSpecialChar.containsKey(s)) ? (strWithSpecialChar.get(s)) : s.trim(), pYearEndMode));
            }                 
            return determinationScript;             
        }catch(Exception e){
            System.debug('Exception e '+e);
            return determinationScript;
        }          
    }
    
    //Return field Value
    private String getValue(String objectName, SObject o, String fieldName, Boolean pYearEndMode){
        system.debug('>>> before fieldName : '+fieldName);
        /*if( pYearEndMode && secondaryPAWrelatedFieldMap.containsKey(fieldName)){
            fieldName = secondaryPAWrelatedFieldMap.get(fieldName);
        }*/
        system.debug('>>>after fieldName : '+fieldName);

        if(fieldName.contains('__r.')){
            String otherObjName = fieldName.split('\\.')[0];
            String otherObjFldName = fieldName.split('\\.')[1]; 
            return (o.getSObject(otherObjName)!= null && o.getSObject(otherObjName).get(otherObjFldName)!=null) ? ''+o.getSObject(otherObjName).get(otherObjFldName) : '';
        }           
        return (o.get(fieldName) != null) ? String.valueOf(o.get(fieldName)) : '';
    }

}