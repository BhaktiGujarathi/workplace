public class PatientNameforOppObj {
    public Opportunity oppty {get; set;}
    public Abused_Substance__c abSubs {get; set;}
    public Treatment_History__c trtHstry {get; set;}
    public Medical_Problem_Symptom__c medProb {get; set;}
    public Prescription_Medication__c prescMed {get; set;}
    public Mental_Health_Symptom__c mHlthSymp {get; set;}
    public Psychiatric_Diagnosis__c psyDiag {get; set;}
    public Infectious_Disease__c InfDis{get; set;}
    public Legal_Offense__c LeOff{get; set;}
    public Medical_Equipment__c MedEqu{get; set;}
    public Substance_Abuse_History_and_Frequency__c SuAbFr{get; set;}
    public String recTypeName {get; set;}
    public String recTypeLocal;
    public String finalName {get;set;}
    
    public PatientNameforOppObj(ApexPages.StandardController controller) {
        recTypeLocal = '';
        recTypeName = '';
        String currentObjId = ApexPages.CurrentPage().getparameters().get('id');
            System.debug('currentObjId_________________________________'+currentObjId);
/***
Opp_vfpage
*/      String oppKeyPrif = Opportunity.sObjectType.getDescribe().getKeyPrefix();
            System.debug('oppKeyPrif__________________________'+oppKeyPrif);
        if(currentObjId.startsWith(oppKeyPrif)){
            oppty = new Opportunity();
            finalName='';
            oppty = [SELECT Id, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Birthdate, RecordType.Name FROM Opportunity WHERE Id =: currentObjId];
            recTypeLocal = oppty.RecordType.Name;
            system.debug('oppty__________________________'+oppty); 
            if(oppty.Contact__r.FirstName!=null && oppty.Contact__r.FirstName!='')
                finalName = oppty.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+oppty.Contact__r.LastName : oppty.Contact__r.LastName;
        }
        
/***
Abused_vfPage
*/      String abusedKeyPrif = Abused_Substance__c.sObjectType.getDescribe().getKeyPrefix();
            System.debug('abusedKeyPrif__________________________'+abusedKeyPrif);
        if(currentObjId.startsWith(abusedKeyPrif)){
            finalName = '';
            abSubs = new Abused_Substance__c();
            abSubs = [SELECT Id, Opportunity__r.Contact__r.FirstName, Opportunity__r.Contact__r.LastName, Opportunity__r.Contact__r.Birthdate, Opportunity__r.RecordType.Name FROM Abused_Substance__c WHERE Id =: currentObjId];
            system.debug('abSubs__________________________'+abSubs);
            recTypeLocal = abSubs.Opportunity__r.RecordType.Name;
            if(abSubs.Opportunity__r.Contact__r.FirstName!=null && abSubs.Opportunity__r.Contact__r.FirstName!='')
                finalName = abSubs.Opportunity__r.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+abSubs.Opportunity__r.Contact__r.LastName : abSubs.Opportunity__r.Contact__r.LastName;
        }
        
/***
Treatment_H_vfPage
*/      String tHstKeyPrif = Treatment_History__c.sObjectType.getDescribe().getKeyPrefix();
            System.debug('tHstKeyPrif__________________________'+tHstKeyPrif);
        if(currentObjId.startsWith(tHstKeyPrif)){
            finalName='';
            trtHstry = new Treatment_History__c();
            trtHstry = [SELECT Id, Opportunity__r.Contact__r.FirstName, Opportunity__r.Contact__r.LastName, Opportunity__r.Contact__r.Birthdate, Opportunity__r.RecordType.Name FROM Treatment_History__c WHERE Id =: currentObjId];
            system.debug('trtHstry__________________________'+trtHstry);
            recTypeLocal = trtHstry.Opportunity__r.RecordType.Name;
            if(trtHstry.Opportunity__r.Contact__r.FirstName!=null && trtHstry.Opportunity__r.Contact__r.FirstName!='')
                finalName = trtHstry.Opportunity__r.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+trtHstry.Opportunity__r.Contact__r.LastName : trtHstry.Opportunity__r.Contact__r.LastName;
        }
        
/***
Medical_prob_vfpage
*/      String medPSKeyPrif = Medical_Problem_Symptom__c.sObjectType.getDescribe().getKeyPrefix();
            System.debug('medPSKeyPrif__________________________'+medPSKeyPrif);
        if(currentObjId.startsWith(medPSKeyPrif)){
            finalName='';
            medProb = new Medical_Problem_Symptom__c();
            medProb = [SELECT Id, Opportunity__r.Contact__r.FirstName, Opportunity__r.Contact__r.LastName, Opportunity__r.Contact__r.Birthdate, Opportunity__r.RecordType.Name FROM Medical_Problem_Symptom__c WHERE Id =: currentObjId];
            system.debug('medProb__________________________'+medProb);
            recTypeLocal = medProb.Opportunity__r.RecordType.Name;
            if(medProb.Opportunity__r.Contact__r.FirstName!=null && medProb.Opportunity__r.Contact__r.FirstName!='')
                finalName = medProb.Opportunity__r.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+medProb.Opportunity__r.Contact__r.LastName : medProb.Opportunity__r.Contact__r.LastName;
        }
        
/***
Prescription_vfpage
*/      String pMedKeyPrif = Prescription_Medication__c.sObjectType.getDescribe().getKeyPrefix();
            System.debug('pMedKeyPrif__________________________'+pMedKeyPrif);
        if(currentObjId.startsWith(pMedKeyPrif)){
            finalName='';
            prescMed = new Prescription_Medication__c();
            prescMed = [SELECT Id, Opportunity__r.Contact__r.FirstName, Opportunity__r.Contact__r.LastName, Opportunity__r.Contact__r.Birthdate, Opportunity__r.RecordType.Name FROM Prescription_Medication__c WHERE Id =: currentObjId];
            system.debug('prescMed__________________________'+prescMed);
            recTypeLocal = prescMed.Opportunity__r.RecordType.Name;
            if(prescMed.Opportunity__r.Contact__r.FirstName!=null && prescMed.Opportunity__r.Contact__r.FirstName!='')
                finalName = prescMed.Opportunity__r.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+prescMed.Opportunity__r.Contact__r.LastName : prescMed.Opportunity__r.Contact__r.LastName;
        }
        
/***
Mental_health_vfpage
*/      String HSymKeyPrif = Mental_Health_Symptom__c.sObjectType.getDescribe().getKeyPrefix();
            System.debug('HSymKeyPrif__________________________'+HSymKeyPrif);
        if(currentObjId.startsWith(HSymKeyPrif)){
            finalName='';
            mHlthSymp = new Mental_Health_Symptom__c();
            mHlthSymp = [SELECT Id, Opportunity__r.Contact__r.FirstName, Opportunity__r.Contact__r.LastName, Opportunity__r.Contact__r.Birthdate, Opportunity__r.RecordType.Name FROM Mental_Health_Symptom__c WHERE Id =: currentObjId];
            system.debug('abSubs__________________________'+mHlthSymp);
            recTypeLocal = mHlthSymp.Opportunity__r.RecordType.Name;
            if(mHlthSymp.Opportunity__r.Contact__r.FirstName!=null && mHlthSymp.Opportunity__r.Contact__r.FirstName!='')
                finalName = mHlthSymp.Opportunity__r.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+mHlthSymp.Opportunity__r.Contact__r.LastName : mHlthSymp.Opportunity__r.Contact__r.LastName;
        }

/***
Psychiatric_vfpage
*/      String psDiKeyPrif = Psychiatric_Diagnosis__c.sObjectType.getDescribe().getKeyPrefix();
            System.debug('psDiKeyPrif__________________________'+psDiKeyPrif);
        if(currentObjId.startsWith(psDiKeyPrif)){
            finalName='';
            psyDiag = new Psychiatric_Diagnosis__c();
            psyDiag = [SELECT Id, Opportunity__r.Contact__r.FirstName, Opportunity__r.Contact__r.LastName, Opportunity__r.Contact__r.Birthdate, Opportunity__r.RecordType.Name FROM Psychiatric_Diagnosis__c WHERE Id =: currentObjId];
            system.debug('psyDiag__________________________'+psyDiag);
            recTypeLocal = psyDiag.Opportunity__r.RecordType.Name;
            if(psyDiag.Opportunity__r.Contact__r.FirstName!=null && psyDiag.Opportunity__r.Contact__r.FirstName!='')
                finalName = psyDiag.Opportunity__r.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+psyDiag.Opportunity__r.Contact__r.LastName : psyDiag.Opportunity__r.Contact__r.LastName;
        }

/***
Infectious_Diseasevfpage
*/      String InDiseaseKeyPrif = Infectious_Disease__c.sObjectType.getDescribe().getKeyPrefix();
            System.debug('InDiseaseKeyPrif__________________________'+InDiseaseKeyPrif);
        if(currentObjId.startsWith(InDiseaseKeyPrif)){
            finalName='';
            InfDis = new Infectious_Disease__c();
            InfDis = [SELECT Id, Opportunity__r.Contact__r.FirstName, Opportunity__r.Contact__r.LastName, Opportunity__r.Contact__r.Birthdate, Opportunity__r.RecordType.Name FROM Infectious_Disease__c WHERE Id =: currentObjId];
            system.debug('InfDis__________________________'+InfDis);
            recTypeLocal = InfDis.Opportunity__r.RecordType.Name;
            if(InfDis.Opportunity__r.Contact__r.FirstName!=null && InfDis.Opportunity__r.Contact__r.FirstName!='')
                finalName = InfDis.Opportunity__r.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+InfDis.Opportunity__r.Contact__r.LastName : InfDis.Opportunity__r.Contact__r.LastName;
        }

/***
Medical_Equipmentvfpage
*/      String MeEqKeyPrif = Medical_Equipment__c.sObjectType.getDescribe().getKeyPrefix();
            System.debug('MeEqKeyPrif__________________________'+MeEqKeyPrif);
        if(currentObjId.startsWith(MeEqKeyPrif)){
            finalName='';
            MedEqu = new Medical_Equipment__c();
            MedEqu = [SELECT Id, Opportunity__r.Contact__r.FirstName, Opportunity__r.Contact__r.LastName, Opportunity__r.Contact__r.Birthdate, Opportunity__r.RecordType.Name FROM Medical_Equipment__c WHERE Id =: currentObjId];
            system.debug('MedEqu__________________________'+MedEqu);
            recTypeLocal = MedEqu.Opportunity__r.RecordType.Name;
            if(MedEqu.Opportunity__r.Contact__r.FirstName!=null && MedEqu.Opportunity__r.Contact__r.FirstName!='')
                finalName = MedEqu.Opportunity__r.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+MedEqu.Opportunity__r.Contact__r.LastName : MedEqu.Opportunity__r.Contact__r.LastName;
        }
        
		/***
Legal_offensevfpage
*/      String LeOffKeyPrif = Legal_Offense__c.sObjectType.getDescribe().getKeyPrefix();
            System.debug('LeOffKeyPrif__________________________'+LeOffKeyPrif);
        if(currentObjId.startsWith(LeOffKeyPrif)){
            finalName='';
            LeOff = new Legal_Offense__c();
            LeOff = [SELECT Id, Opportunity__r.Contact__r.FirstName, Opportunity__r.Contact__r.LastName, Opportunity__r.Contact__r.Birthdate, Opportunity__r.RecordType.Name FROM Legal_Offense__c WHERE Id =: currentObjId];
            system.debug('LeOff__________________________'+LeOff);
            recTypeLocal = LeOff.Opportunity__r.RecordType.Name;
            if(LeOff.Opportunity__r.Contact__r.FirstName!=null && LeOff.Opportunity__r.Contact__r.FirstName!='')
                finalName = LeOff.Opportunity__r.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+LeOff.Opportunity__r.Contact__r.LastName : LeOff.Opportunity__r.Contact__r.LastName;
        }
        
				/***
Substance_Abuse_H_and_Fvfpage
*/      String SubAbHFKeyPrif = Substance_Abuse_History_and_Frequency__c.sObjectType.getDescribe().getKeyPrefix();
            System.debug('SubAbHFKeyPrif__________________________'+SubAbHFKeyPrif);
        if(currentObjId.startsWith(SubAbHFKeyPrif)){
            finalName='';
            SuAbFr = new Substance_Abuse_History_and_Frequency__c();
            SuAbFr = [SELECT Id, Opportunity__r.Contact__r.FirstName, Opportunity__r.Contact__r.LastName, Opportunity__r.Contact__r.Birthdate, Opportunity__r.RecordType.Name FROM Substance_Abuse_History_and_Frequency__c WHERE Id =: currentObjId];
            system.debug('SuAbFr__________________________'+SuAbFr);
            recTypeLocal = SuAbFr.Opportunity__r.RecordType.Name;
            if(SuAbFr.Opportunity__r.Contact__r.FirstName!=null && SuAbFr.Opportunity__r.Contact__r.FirstName!='')
                finalName = SuAbFr.Opportunity__r.Contact__r.FirstName;
            finalName = (finalName!=null) ? finalName+' '+SuAbFr.Opportunity__r.Contact__r.LastName : SuAbFr.Opportunity__r.Contact__r.LastName;
        }
        
		
/***
Opportunity.RecordType_Name
*/           if (recTypeLocal == 'Residential Treatment') {
                recTypeName = 'RTC';
            } else if (recTypeLocal == 'Outpatient Treatment') {
                recTypeName = 'IOP';
            } else if (recTypeLocal == 'Refer Out Only'){
                recTypeName = 'RAM';
            }   system.debug('recTypeName_____________________'+recTypeName);
                    
    }

}