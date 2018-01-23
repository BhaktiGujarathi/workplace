public class FacilityApprovalcontroller{
    public List<WrpFacility> WrapFacilitylist {get; set;}
    public String oppId ='';
    public String rawRecType ='';
    public Integer rowToRemove {get;set;}
    public Map<String,Red_Flag_Details_Setting__c> redFlagMap;
    public sObject oppRecord;
   
    public List<sObject> cmrnList; 
    public List<sObject> abSList;
    public List<sObject> LglOfncList; 
    public List<sObject> medEquiptList; 
    public List<sObject> medlProbSympList; 
    public List<sObject> MntlHlthSymptList; 
    public List<sObject> patInsList;
    public List<sObject> presMediList;
    public List<sObject> psyDiagList; 
    public List<sObject> riskAssList; 
    public List<sObject> sahafList; 
    public List<sObject> treatHIstList;  
    public List<sObject> mejorMedicalList;  
    public List<sObject> illnessList;  
    
    public Map<String, Schema.SObjectField> allOppFields;
    public Map<String, Schema.SObjectField> allCMRFields;
    public Map<String, Schema.SObjectField> allAbsFields;
    public Map<String, Schema.SObjectField> allLOFields;
    public Map<String, Schema.SObjectField> allMEFields;
    public Map<String, Schema.SObjectField> allMPSFields;
    public Map<String, Schema.SObjectField> allMHSFields;
    public Map<String, Schema.SObjectField> allPIFields;
    public Map<String, Schema.SObjectField> allPMFields;
    public Map<String, Schema.SObjectField> allPsyDFields;
    public Map<String, Schema.SObjectField> allRAFields;
    public Map<String, Schema.SObjectField> allSAHaFFields;
    public Map<String, Schema.SObjectField> allTHFields;
    public Map<String, Schema.SObjectField> allMMFields;
    public Map<String, Schema.SObjectField> allILLFields;
    
    public String cmaRecordType = 'Clinical / Medical Approval';
    public String cmaRecordTypeId;
    
    public FacilityApprovalcontroller(ApexPages.StandardController controller){
        oppId = ((Opportunity)controller.getRecord()).id;
         
        redFlagMap = new Map<String,Red_Flag_Details_Setting__c>();
        for(Red_Flag_Details_Setting__c rfd: [select Id, Opportunity_Fields__c, Name from Red_Flag_Details_Setting__c]){
            redFlagMap.put(rfd.Name,rfd);
        }
        
        rawRecType = ApexPages.currentPage().getParameters().get('recType');
        System.debug('rawRecType___________________________'+rawRecType);
            
        WrapFacilitylist = new List<WrpFacility>();     
        if(WrapFacilitylist.size()==0){
            addNewAccObj();
        }
        if(oppId!=null && oppId != ''){
            //Opportunity Query
            List<String> fieldAPIName = new List<String>( Schema.getGlobalDescribe().get( 'Opportunity' ).getDescribe().fields.getMap().keySet());
            allOppFields = Schema.SObjectType.Opportunity.fields.getMap();
            String queryString = generateString(allOppFields,fieldAPIName); 
            String finalQueryString = 'Select '+queryString+' from opportunity where id =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            oppRecord = Database.Query(finalQueryString);
            System.debug('queryOpp intance.... '+oppRecord);
            
            //Clinical Medical Review Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Clinical_Medical_Review_Note__c' ).getDescribe().fields.getMap().keySet());
            allCMRFields = Schema.SObjectType.Clinical_Medical_Review_Note__c.fields.getMap();
            queryString = generateString(allCMRFields,fieldAPIName);            
            finalQueryString = 'Select '+queryString+' from Clinical_Medical_Review_Note__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            cmrnList = Database.Query(finalQueryString);
            
            //Abused_Substance Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Abused_Substance__c').getDescribe().fields.getMap().keySet());
            allAbsFields = Schema.SObjectType.Abused_Substance__c.fields.getMap();
            queryString = generateString(allAbsFields,fieldAPIName);            
            finalQueryString = 'Select '+queryString+' from Abused_Substance__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            abSList = Database.Query(finalQueryString); 
            
            //Legal_Offense Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Legal_Offense__c').getDescribe().fields.getMap().keySet());
            allLOFields = Schema.SObjectType.Legal_Offense__c.fields.getMap();
            queryString = generateString(allLOFields,fieldAPIName);         
            finalQueryString = 'Select '+queryString+' from Legal_Offense__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            LglOfncList = Database.Query(finalQueryString);
            
            //Medical_Equipment Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Medical_Equipment__c').getDescribe().fields.getMap().keySet());
            allMEFields = Schema.SObjectType.Medical_Equipment__c.fields.getMap();
            queryString = generateString(allMEFields,fieldAPIName);         
            finalQueryString = 'Select '+queryString+' from Medical_Equipment__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            medEquiptList = Database.Query(finalQueryString);
                
            //Medical_Problem_Symptom Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Medical_Problem_Symptom__c').getDescribe().fields.getMap().keySet());
            allMPSFields = Schema.SObjectType.Medical_Problem_Symptom__c.fields.getMap();
            queryString = generateString(allMPSFields,fieldAPIName);            
            finalQueryString = 'Select '+queryString+' from Medical_Problem_Symptom__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            medlProbSympList = Database.Query(finalQueryString);
                
            //Mental_Health_Symptom Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Mental_Health_Symptom__c').getDescribe().fields.getMap().keySet());
            allMHSFields = Schema.SObjectType.Mental_Health_Symptom__c.fields.getMap();
            queryString = generateString(allMHSFields,fieldAPIName);            
            finalQueryString = 'Select '+queryString+' from Mental_Health_Symptom__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            MntlHlthSymptList = Database.Query(finalQueryString);
            
            //Patient_Insurance Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Patient_Insurance__c').getDescribe().fields.getMap().keySet());
            allPIFields = Schema.SObjectType.Patient_Insurance__c.fields.getMap();
            queryString = generateString(allPIFields,fieldAPIName);         
            finalQueryString = 'Select '+queryString+' from Patient_Insurance__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            patInsList = Database.Query(finalQueryString);
            
            //Prescription_Medication Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Prescription_Medication__c').getDescribe().fields.getMap().keySet());
            allPMFields = Schema.SObjectType.Prescription_Medication__c.fields.getMap();
            queryString = generateString(allPMFields,fieldAPIName);         
            finalQueryString = 'Select '+queryString+' from Prescription_Medication__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            presMediList = Database.Query(finalQueryString);
            
            //Psychiatric_Diagnosis Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Psychiatric_Diagnosis__c').getDescribe().fields.getMap().keySet());
            allPsyDFields = Schema.SObjectType.Psychiatric_Diagnosis__c.fields.getMap();
            queryString = generateString(allPsyDFields,fieldAPIName);           
            finalQueryString = 'Select '+queryString+' from Psychiatric_Diagnosis__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            psyDiagList = Database.Query(finalQueryString); 
            
            //Risk_Assessment Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Risk_Assessment__c').getDescribe().fields.getMap().keySet());
            allRAFields = Schema.SObjectType.Risk_Assessment__c.fields.getMap();
            queryString = generateString(allRAFields,fieldAPIName);         
            finalQueryString = 'Select '+queryString+' from Risk_Assessment__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            riskAssList = Database.Query(finalQueryString); 
            
            //Substance_Abuse_History_and_Frequency Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Substance_Abuse_History_and_Frequency__c').getDescribe().fields.getMap().keySet());
            allSAHaFFields = Schema.SObjectType.Substance_Abuse_History_and_Frequency__c.fields.getMap();
            queryString = generateString(allSAHaFFields,fieldAPIName);          
            finalQueryString = 'Select '+queryString+' from Substance_Abuse_History_and_Frequency__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            sahafList = Database.Query(finalQueryString);
            
            //Treatment_History Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Treatment_History__c').getDescribe().fields.getMap().keySet());
            allTHFields = Schema.SObjectType.Treatment_History__c.fields.getMap();
            queryString = generateString(allTHFields,fieldAPIName);         
            finalQueryString = 'Select '+queryString+' from Treatment_History__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            treatHIstList = Database.Query(finalQueryString);
            
            //Illness / Injury Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Illness_Injury__c').getDescribe().fields.getMap().keySet());
            allILLFields = Schema.SObjectType.Illness_Injury__c.fields.getMap();
            queryString = generateString(allILLFields,fieldAPIName);            
            finalQueryString = 'Select '+queryString+' from Illness_Injury__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            illnessList = Database.Query(finalQueryString);
            
            //Major Medical Issue Query
            fieldAPIName = new List<String>(Schema.getGlobalDescribe().get('Major_Medical_Issue__c').getDescribe().fields.getMap().keySet());
            allMMFields = Schema.SObjectType.Major_Medical_Issue__c.fields.getMap();
            queryString = generateString(allMMFields,fieldAPIName);         
            finalQueryString = 'Select '+queryString+' from Major_Medical_Issue__c where Opportunity__c =: oppID';
            System.debug('finalQueryString.... '+finalQueryString);
            mejorMedicalList = Database.Query(finalQueryString);
        }
    }
    
    public String generateString(Map<String, Schema.SObjectField> allFields,List<String> oppfieldAPIName){
        String oppQueryString ='';
        for(String fieldAPI: oppfieldAPIName){                
            Schema.DisplayType fielddataType = allFields.get(fieldAPI).getDescribe().getType();
            
            if(String.valueOf(fielddataType) == 'REFERENCE'){
                string fieldAPIReletion='';
                if(fieldAPI.endsWith('__c')){
                    fieldAPIReletion= fieldAPI.replace('__c','__r.name');
                }else{
                    fieldAPIReletion= fieldAPI.replace('id','.name');
                }
                if(oppQueryString != '' && oppQueryString != null){
                    oppQueryString = oppQueryString+','+fieldAPIReletion;
                }else{
                    oppQueryString= fieldAPIReletion;
                }
            }else{
                if(oppQueryString != '' && oppQueryString != null){
                    oppQueryString = oppQueryString+','+fieldAPI;
                }else{
                    oppQueryString= fieldAPI;
                }   
            }           
        }
        return oppQueryString;
    }
    
    public list<selectoption> getFacilitylist(){
        list<selectoption> options =new list<selectoption>();
        options.add(new SelectOption('','-None-'));
        List<Account> accts = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'FRN Facility' ORDER BY Name ASC];
        for(Account acc : accts){
            options.add(new selectoption(acc.id,acc.Name)); 
        }
        return options;
    }
    
    public PageReference save(){
        List<Case> caselist= new List<Case>();
        String rtId;
        Id returnToId = oppId;
        system.debug('>>> rawRecType : '+rawRecType);
        if(rawRecType!=null && rawRecType!=''){
            rtId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get(rawRecType).getRecordTypeId(); 
        }
        system.debug('>>> WrapFacilitylist : '+WrapFacilitylist);
        for(WrpFacility wrp: WrapFacilitylist) {
        system.debug('>>> wrp : '+wrp);
            string RedFlagDetVal= '';
            System.debug('wrp.cs ::>'+wrp.cs);
            System.debug('wrp.cs.AccountId.............. '+wrp.cs.AccountId);
            if(wrp.cs.AccountId == null){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select FRN Facility'));
              return null;
            }
            if(wrp.rightRelatedRF != null && (wrp.rightRelatedRF).size()>0){
                wrp.cs.Red_Flag_Information__c = '';
                for(SelectOption so:wrp.rightRelatedRF){
                    wrp.cs.Red_Flag_Information__c = wrp.cs.Red_Flag_Information__c+';'+so.getValue();              
                } 
                RedFlagDetVal = RedFlagDetailsFormate(wrp.cs.Red_Flag_Information__c);
                System.debug('RedFlagDetVal_________________________ '+RedFlagDetVal);
            }
            if(wrp.cs.RecordTypeId != null){
                caselist.add(new Case(Opportunity__c = oppId, AccountId = wrp.cs.AccountId, Red_Flag_Information__c =  wrp.cs.Red_Flag_Information__c, Description = wrp.cs.Description, Status = 'New', Origin ='Email', Red_Flag_Details__c = RedFlagDetVal, RecordTypeId =wrp.cs.RecordTypeId)); 
            } else if(rtId!=null){
                caselist.add(new Case(Opportunity__c = oppId, AccountId = wrp.cs.AccountId, Red_Flag_Information__c =  wrp.cs.Red_Flag_Information__c, Description = wrp.cs.Description, Status = 'New', Origin ='Email', Red_Flag_Details__c = RedFlagDetVal, RecordTypeId =rtId)); 
            } else {
                caselist.add(new Case(Opportunity__c = oppId, AccountId = wrp.cs.AccountId, Red_Flag_Information__c =  wrp.cs.Red_Flag_Information__c, Description = wrp.cs.Description, Status = 'New', Origin ='Email', Red_Flag_Details__c = RedFlagDetVal));
            }       
        }
        insert caselist;
        System.debug('caselist ::>'+caselist);
        cmaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(cmaRecordType).getRecordTypeId();
        /*** Create an approval request for the acse ***/
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        Approval.ProcessResult result;
        for(Case css: caselist){
            system.debug('>>> css : '+css.RecordType.Name);
            if(cmaRecordTypeId != css.RecordTypeId) {
                req1.setObjectId(css.id);
                req1.setSkipEntryCriteria(true);
                if(!Approval.isLocked(css.id)){
                     result = Approval.process(req1);   
                }
            }
            else {
                returnToId = redirectToCaseId(oppId, css.RecordTypeId);
            }
        }
        system.debug('>>> returnToId : '+returnToId);
        return (new PageReference('/'+returnToId));
    }
    
    public PageReference cancel(){
        return (new PageReference('/'+oppId));
    }     

    public void addNewAccObj(){
        WrpFacility newRecord = new WrpFacility();
        Account newAccRecord = new Account();        
        Case newCsRecord = new Case();        
        //newRecord.acct = newAccRecord;
        newRecord.cs = newCsRecord;
        newRecord.index = WrapFacilitylist.size();
        if(newRecord.index>0){
            Account oldAccRecord = WrapFacilitylist[newRecord.index-1].acct;            
            Case oldcsRecord = WrapFacilitylist[newRecord.index-1].cs;        
            if(oldcsRecord.AccountId == null){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Please Select FRN Facility')); 
                return;
            }
            //newRecord.cs.AccountId = oldcsRecord.cs.AccountId;            
            newRecord.cs.Red_Flag_Information__c = oldcsRecord.Red_Flag_Information__c;
            newRecord.cs.Description = oldcsRecord.Description;            
            newRecord.cs.RecordTypeId = oldcsRecord.RecordTypeId;            
        }
       
        WrapFacilitylist.add(newRecord);    
        
       
        System.debug('WrapFacilitylist ::>'+WrapFacilitylist);
    } 
 
    public void removeRowToAccList(){
        System.debug('WrapFacilitylist.size() ::>'+WrapFacilitylist.size());
        System.debug('rowToRemove ::>'+rowToRemove);
        if(WrapFacilitylist.size() == 1){   
            Account objAccDel = WrapFacilitylist[rowToRemove].acct;
            Case objCsDel = WrapFacilitylist[rowToRemove].cs;
            objAccDel = new Account(); 
            objCsDel = new Case();           
            WrpFacility newRecord = new WrpFacility(); 
            newRecord.acct = objAccDel; 
            newRecord.cs = objCsDel; 
            WrapFacilitylist[rowToRemove] = newRecord;
        }else{
            WrapFacilitylist.remove(rowToRemove);                             
        } 
    }
    
    public List<SelectOption> getRecorordtypes(){
        List<SelectOption> rectype = new List<SelectOption>();
        rectype.add(new selectoption('','--None--'));
        for(RecordType rt:[Select id,Name from RecordType where SobjectType =: 'Case' and IsActive=true]){
            rectype.add(new selectoption(rt.id,rt.Name));
        }
        return rectype;
    }
    
    public class WrpFacility {
        public Integer index {get;set;}
        public String Facilitylistinfow {get; set;}
        public Account acct {get; set;}
        public Case cs{get; set;}       
        public List<SelectOption> rightRelatedRF {get; set;}
        public List<SelectOption> leftRelatedRF {get; set;}
        public WrpFacility() {
            acct = new Account();
            cs = new Case();            
            rightRelatedRF = new List<SelectOption>();
            leftRelatedRF = getPickLstValue();
        }
        
        public List<SelectOption> getPickLstValue(){
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Case.Red_Flag_Information__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                if(f.getValue() != 'Substances Abused' && f.getValue() != 'Behavioral/Social Histories'){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            } 
            return options;           
        }
    }          
    
    public String createRTData(Map<String, Schema.SObjectField> allFields,sObject oppRecord,Red_Flag_Details_Setting__c f){
        String Tempfinalstring='<table width="100%">';
        Integer fieldCount = 0;
        Tempfinalstring+= '<tr><td><u><b>'+f.Name+'</b></u><br><td></tr>';
        String[] fieldNames = (f.Opportunity_Fields__c).split(',');     
        
        for(String fieldAPIName:fieldNames){
            if(allFields.containsKey(fieldAPIName)){
                fieldCount++;
                if(math.mod(fieldCount,2) != 0){
                    Tempfinalstring+= '<tr>';
                }
                if(fieldCount == fieldNames.size() && math.mod(fieldCount,2) != 0){
                    Tempfinalstring+= '<td>';
                } else{
                    Tempfinalstring+= '<td>';
                }
                
                String fieldLabel = allFields.get(fieldAPIName).getDescribe().getLabel();
                Schema.DisplayType fielddataType = allFields.get(fieldAPIName).getDescribe().getType();
                String value = String.valueOf(oppRecord.get(fieldAPIName));
                
                if(value!=null && value!='' && String.valueOf(fielddataType) != 'DATE' && String.valueOf(fielddataType) != 'REFERENCE'){ 
                                        
                    Tempfinalstring+= fieldLabel + ': '+value; 
                    
                }else if(value!=null && value!='' && String.valueOf(fielddataType) == 'DATE'){
                    
                    String[] DateValue = value.split(' ');
                    String[] Datesplit = DateValue[0].split('-');
                    String formatedDate = Datesplit[1]+'/'+Datesplit[2]+'/'+Datesplit[0];
                    Tempfinalstring+= fieldLabel + ': '+formatedDate; 
                    
                }else if(value!=null && value!='' && String.valueOf(fielddataType) == 'REFERENCE'){
                    if(fieldAPIName.endsWith('__c')){
                        fieldAPIName= fieldAPIName.replace('__c','__r');
                    }else{  
                        fieldAPIName= fieldAPIName.replace('ID','');
                    }
                    String Name = (String) oppRecord.getSobject(fieldAPIName).get('Name');
                    Tempfinalstring+= fieldLabel + ': '+Name; 
                        
                }else{
                    Tempfinalstring+= fieldLabel + ': '; 
                }
                Tempfinalstring+= '</td>';
                if(math.mod(fieldCount,2) == 0){
                    Tempfinalstring+= '</tr>';
                }
            }
        }
        
        Tempfinalstring+= '</table>';
        return Tempfinalstring;
    }
    
    public String createRTDataChild(Map<String, Schema.SObjectField> allFields,List<sObject> sObjectList,Red_Flag_Details_Setting__c f){
        String Tempfinalstring='';
        Integer fieldCount = 0;
        Tempfinalstring+= '<u><b>'+f.Name+'</b></u><br><br>';
         Tempfinalstring +='<table width="100%" border="1" cellpadding="0" cellspacing="0" >';
        String[] fieldNames = (f.Opportunity_Fields__c).split(',');
        if(fieldNames!=null && fieldNames.size()>0)
            Tempfinalstring += '<tr>';
        
        String fieldLabel;
        for(String fieldAPIName:fieldNames){
            fieldLabel = allFields.get(fieldAPIName).getDescribe().getLabel();
            Tempfinalstring += '<td><b>'+fieldLabel+'</b></td>';
        }
        Tempfinalstring += '</tr>';
        
        for(sObject record:sObjectList){
            Tempfinalstring+= '<tr>';
            for(String fieldAPIName:fieldNames){
                Tempfinalstring+= '<td>';           
                
                Schema.DisplayType fielddataType = allFields.get(fieldAPIName).getDescribe().getType();
                String value = String.valueOf(record.get(fieldAPIName));
                
                if(value!=null && value!='' && String.valueOf(fielddataType) != 'DATE' && String.valueOf(fielddataType) != 'REFERENCE'){ 
                                        
                    Tempfinalstring+= value; 
                    
                }else if(value!=null && value!='' && String.valueOf(fielddataType) == 'DATE'){
                    
                    String[] DateValue = value.split(' ');
                    String[] Datesplit = DateValue[0].split('-');
                    String formatedDate = Datesplit[1]+'/'+Datesplit[2]+'/'+Datesplit[0];
                    Tempfinalstring+= formatedDate; 
                    
                }else if(value!=null && value!='' && String.valueOf(fielddataType) == 'REFERENCE'){
                    if(fieldAPIName.endsWith('__c')){
                        fieldAPIName= fieldAPIName.replace('__c','__r');
                    }else{  
                        fieldAPIName= fieldAPIName.replace('ID','');
                    }
                    String Name = (String) record.getSobject(fieldAPIName).get('Name');
                    Tempfinalstring+= Name; 
                        
                }else{
                    Tempfinalstring+= ' '; 
                }
                Tempfinalstring+= '</td>';              
            }
            Tempfinalstring+= '</tr>';              
        }
        Tempfinalstring+= '</table><br><br>';
        return Tempfinalstring;
    }
    
    public String RedFlagDetailsFormate(String RedFlagDetails){
        System.debug('RedFlagDetails.... '+RedFlagDetails);
        System.debug('oppRecord.... '+oppRecord);
        String finalstring = '';
        String Tempfinalstring='';
        
        String[] selectedValues = RedFlagDetails.split(';');
        for(String key: selectedValues){ 
            
            if(redFlagMap.containsKey(key)){
                Red_Flag_Details_Setting__c f = redFlagMap.get(key);
                if(f.Name =='Medical / Clinical Review Notes'){
                    if(cmrnList!=null && cmrnList.size()>0){
                        Tempfinalstring += createRTDataChild(allCMRFields,cmrnList,f);
                    }
                } else if (f.Name =='Abused Substances'){
                    if(abSList!=null && abSList.size()>0)
                        Tempfinalstring += createRTDataChild(allAbsFields,abSList,f);
                } else if (f.Name =='Legal Offenses'){
                    if(LglOfncList!=null && LglOfncList.size()>0)
                        Tempfinalstring += createRTDataChild(allLOFields,LglOfncList,f);
                } else if (f.Name =='Medical Equipment'){
                    if(medEquiptList!=null && medEquiptList.size()>0)
                        Tempfinalstring += createRTDataChild(allMEFields,medEquiptList,f);
                } else if (f.Name =='Medical Problems / Symptoms'){
                    if(medlProbSympList!=null && medlProbSympList.size()>0)
                        Tempfinalstring += createRTDataChild(allMPSFields,medlProbSympList,f);
                } else if (f.Name =='Mental Health Symptoms'){
                    if(MntlHlthSymptList!=null && MntlHlthSymptList.size()>0)
                        Tempfinalstring += createRTDataChild(allMHSFields,MntlHlthSymptList,f);
                } else if (f.Name =='Patient Insurances'){
                    if(patInsList!=null && patInsList.size()>0)
                        Tempfinalstring += createRTDataChild(allPIFields,patInsList,f);
                } else if (f.Name =='Prescription Medications'){
                    if(presMediList!=null && presMediList.size()>0)
                        Tempfinalstring += createRTDataChild(allPMFields,presMediList,f);
                } else if (f.Name =='Psychiatric Diagnoses'){
                    if(psyDiagList!=null && psyDiagList.size()>0)
                        Tempfinalstring += createRTDataChild(allPsyDFields,psyDiagList,f);
                } else if (f.Name =='Risk Assessments'){
                    if(riskAssList!=null && riskAssList.size()>0)
                        Tempfinalstring += createRTDataChild(allRAFields,riskAssList,f);
                } else if (f.Name =='Substance Abuse History and Frequency'){
                    if(sahafList!=null && sahafList.size()>0)
                        Tempfinalstring += createRTDataChild(allSAHaFFields,sahafList,f);
                } else if (f.Name =='Treatment History'){
                    if(treatHIstList!=null && treatHIstList.size()>0)
                        Tempfinalstring += createRTDataChild(allTHFields,treatHIstList,f);
                } else if (f.Name =='Major Medical Issue'){
                    if(mejorMedicalList !=null && mejorMedicalList.size()>0)
                        Tempfinalstring += createRTDataChild(allMMFields ,mejorMedicalList,f);
                } else if (f.Name =='Illness/Injury'){
                    if(illnessList !=null && illnessList.size()>0)
                        Tempfinalstring += createRTDataChild(allILLFields,illnessList,f);
                } else {
                    Tempfinalstring += createRTData(allOppFields,oppRecord,f);
                }
            }   
        }
        if(Tempfinalstring.endsWith('<tr><td></td></tr>')){
            Tempfinalstring = Tempfinalstring.removeEnd('<tr><td></td></tr>');
        }
        
        //Tempfinalstring+= '</table>';
        System.debug('Tempfinalstring ::>'+Tempfinalstring);
        finalstring = Tempfinalstring;
        finalstring= finalstring.replaceAll('; <br>','<br>');
        System.debug('finalstring.............'+finalstring);
        return finalstring;
    }
    
    // method to return the id of case for redirection.
    public Id redirectToCaseId(Id pParentOppId, Id pRecordTypeId) {
        List<Case> caseList = [SELECT id
                               FROM Case
                               WHERE Opportunity__c =:pParentOppId
                               AND RecordTypeId =: pRecordTypeId
                               ORDER BY CreatedDate DESC
                               ];
                               
        if(!caseList.isEmpty() && caseList.size() > 0) {
            return caseList[0].Id;
        }else 
           return null;
    }
}