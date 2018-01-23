global class convertLead{
    WebService static string  convertLeadtoAcc(string id){
         boolean isError = false;
         
        Lead leadBefore = [Select Id,
                                  Caller_First_Name__c,
                                  Calling_for__c,
                                  FirstName, 
                                  LastName, 
                                  Caller_Phone__c, 
                                  StateCode, 
                                  City, 
                                  Caller_Last_Name__c, 
                                  Relationship_to_Patient__c
                             from Lead 
                            where Id=:id];
        string errormessage ='';
        
        System.debug('in convertedLeadtoAcc method...>>');
        
        if (leadBefore.Calling_for__c == 'Self' || (leadBefore.Calling_for__c != 'Self' && leadBefore.Relationship_to_Patient__c == 'Self')){
            
            if((leadBefore.LastName == null || leadBefore.LastName == '') || (leadBefore.FirstName == null || leadBefore.FirstName == '') || (leadBefore.StateCode == null || leadBefore.StateCode == '') || (leadBefore.City == null || leadBefore.City == '')){
                errormessage = 'Following field(s) is/are required for Lead Conversion';    
            }
            
            if(leadBefore.LastName == null  || leadBefore.LastName == ''){
                errormessage += '\n Last Name';
                isError = true;
            } if(leadBefore.FirstName == null || leadBefore.FirstName == ''){
                    errormessage += '\n Patient First Name';
                    isError = true;
                } if(leadBefore.StateCode == null || leadBefore.StateCode == ''){
                        errormessage += '\n State';
                        isError = true;
                    } if(leadBefore.City == null || leadBefore.City == '') {  
                        errormessage += '\n City';
                        isError = true;
                        }                   
                        if(isError == false){
                            return leadCustomCovert(leadBefore);
                        } 
                            return errormessage;
                            
        }else if(leadBefore.Relationship_to_Patient__c != 'Self'){
            
            if((leadBefore.LastName == null || leadBefore.LastName == '') || (leadBefore.FirstName == null || leadBefore.FirstName == '') || (leadBefore.StateCode == null || leadBefore.StateCode == '') || (leadBefore.City == null || leadBefore.City == '') || (leadBefore.Caller_First_Name__c == null || leadBefore.Caller_First_Name__c == '') || (leadBefore.Caller_Last_Name__c == null || leadBefore.Caller_Last_Name__c == '') || (leadBefore.Caller_Phone__c == null || leadBefore.Caller_Phone__c == '') || (leadBefore.Relationship_to_Patient__c == null || leadBefore.Relationship_to_Patient__c == '')){
                errormessage = 'Following field(s) is/are required for Lead Conversion';    
            }           
                        
            if (leadBefore.LastName == null || leadBefore.LastName == ''){
                errormessage += '\n Patient Last Name';
                isError = true;
            } if(leadBefore.FirstName == null || leadBefore.FirstName == ''){
                    errormessage += '\n Patient First Name';
                    isError = true;
                } if(leadBefore.Caller_First_Name__c == null || leadBefore.Caller_First_Name__c == ''){
                        errormessage += '\n Caller First Name';
                        isError = true;
                    } if(leadBefore.Caller_Last_Name__c == null || leadBefore.Caller_Last_Name__c == ''){
                            errormessage += '\n Caller Last Name';
                            isError = true;
                        } if(leadBefore.Caller_Phone__c == null || leadBefore.Caller_Phone__c == ''){
                                errormessage += '\n Caller Phone';
                                isError = true;
                            } if(leadBefore.StateCode == null || leadBefore.StateCode == ''){
                                    errormessage += '\n State';
                                    isError = true;
                                } if(leadBefore.City == null || leadBefore.City == ''){
                                        errormessage += '\n City';
                                        isError = true;
                                    } if(leadBefore.Relationship_to_Patient__c == null || leadBefore.Relationship_to_Patient__c == '') {
                                            errormessage += '\n Relationship to Patient';
                                            isError = true;
                                    } 
                                    if(isError == false){
                                        return leadCustomCovert(leadBefore);
                                    }
                                    return errormessage;
        } 
        return '';
    }
    
    public static string leadCustomCovert(Lead leadBefore){
        List<Medical_Equipment__c> medEquipmentToInsert = new List<Medical_Equipment__c>();
        List<Infectious_Disease__c> infctsDsiseaseToInsert = new List<Infectious_Disease__c>();
        List<Major_Medical_Issue__c> medIssueToInsert = new List<Major_Medical_Issue__c>();
        Set<Id> referralAcountIds = new Set<Id>();
        List<Account> highPriorityReferralList = new List<Account>();

                System.debug('leadBefore_____________ '+leadBefore);
                
                User usrObj = new User();
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(leadBefore.id);
                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                                            FROM LeadStatus 
                                            WHERE IsConverted=true LIMIT 1];                
                lc.setConvertedStatus(convertStatus.MasterLabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                
                Lead convertedLead=[select ConvertedOpportunityId,
                                           ConvertedContactId,
                                           ConvertedAccountId,
                                           Caller_First_Name__c,
                                           Caller_Last_Name__c,
                                           Relationship_to_Patient__c,
                                           Caller_Phone__c,
                                           Caller_Mobile__c,
                                           Caller_Work_Phone__c,
                                           Caller_Email__c,
                                           Birthdate__c,
                                           OwnerId,
                                           Identified_Gender__c,
                                           Gender__c,
                                           High_Priority__c,
                                           Referral_Instruction__c,
                                           (SELECT id, Account__c FROM Referrals__r)
                                      from Lead 
                                     where id=: leadBefore.id];
                if(!convertedLead.Referrals__r.isEmpty()) {
                    for(Referral__c referObj : convertedLead.Referrals__r) {
                        referralAcountIds.add(referObj.Account__c);
                    }
                }
                system.debug('>>> referralAcountIds : '+referralAcountIds);
                highPriorityReferralList = [SELECT id,
                                                   High_Priority__c
                                              FROM Account
                                             WHERE Id IN :referralAcountIds
                                               AND High_Priority__c = true];
                system.debug('>>> highPriorityReferralList : '+highPriorityReferralList);
                usrObj = [SELECT Id,
                                 Update_AC_Assigned_on_Opportunity__c,
                                 Update_RAM_Assigned_on_Opportunity__c,
                                 Username 
                            FROM User 
                           WHERE Id =: convertedLead.OwnerId];
                
                
                
                System.debug('convertedLead....>>'+convertedLead);
                System.debug('Update_RAM_Assigned_on_Opportunity__c____________ '+usrObj.Update_RAM_Assigned_on_Opportunity__c);
                System.debug('convertedLead.Caller_First_Name__c ....>>'+convertedLead.Caller_First_Name__c );
                System.debug('convertedLead.Caller_Last_Name__c ....>>'+convertedLead.Caller_Last_Name__c );
                if(convertedLead.Caller_First_Name__c != null || convertedLead.Caller_Last_Name__c !=null){
                                      /* Contact newContact = new Contact();
                                      newContact.FirstName = convertedLead.Caller_First_Name__c;
                                      newContact.LastName = convertedLead.Caller_Last_Name__c;
                                      newContact.AccountId = convertedLead.ConvertedAccountId;
                                      newContact.Birthdate = convertedLead.Birthdate__c;
                                      insert newContact;
                                      System.debug('newContact..>>'+newContact);
                                      pc.Contact__c = newContact.Id;
                                       */        
                Patient_Contact__c pc = new Patient_Contact__c();
                    pc.Relationship__c = convertedLead.Relationship_to_Patient__c;
                    pc.Opportunity__c = convertedLead.ConvertedOpportunityId;
                    pc.First_Name__c = convertedLead.Caller_First_Name__c;
                    pc.Last_Name__c = convertedLead.Caller_Last_Name__c;
                    pc.Phone__c = convertedLead.Caller_Phone__c;
                    pc.Mobile_Phone__c = convertedLead.Caller_Mobile__c;
                    pc.Work_Phone__c = convertedLead.Caller_Work_Phone__c;
                    pc.Email__c  = convertedLead.Caller_Email__c;
                    insert pc;
                System.debug('PatientContact________________________________ '+pc);
                    
                }
                    List<Note_Comment__c> leNoteCo = new list<Note_Comment__c>();
                    for(Note_Comment__c nc:[select id,
                                                   Lead__c 
                                              from Note_Comment__c 
                                             where Lead__c=:leadBefore.id]){
                    Note_Comment__c Note = new Note_Comment__c();
                    Note.id = nc.id;
                    Note.opportunity__c = convertedLead.ConvertedOpportunityId;
                    leNoteCo.add(Note);
                }
            if(leNoteCo.size()>0){
              update leNoteCo;
                }
                
                
                   if(convertedLead.ConvertedOpportunityId != null){
                    Opportunity opp = [
                        select id
                             , Contact__c
                             , Contact__r.Name,Contact__r.FirstName
                             , Contact__r.LastName
                             , CreatedDate
                             , RecordType.Name
                             , RecordType.DeveloperName
                             , AC_Assigned__c
                             , RAM_Assigned__c 
                          from Opportunity 
                         where id = :convertedLead.ConvertedOpportunityId
                    ];
                    
                    opp.AccountId = null;

                    if ( usrObj.Update_AC_Assigned_on_Opportunity__c && !Utils.isIOP(opp) ) {
                        opp.AC_Assigned__c = convertedLead.OwnerId;             
                    }
                    
                    if(usrObj.Update_RAM_Assigned_on_Opportunity__c && !Utils.isIOP(opp) ){
                        opp.RAM_Assigned__c = convertedLead.OwnerId;
                        
                    }

                    if(convertedLead.High_Priority__c == true) {
                        system.debug('>>> high referral : ');
                        UpdateHighPriorityReferralService.getReferralDocsOnOpportunity(
                                                        highPriorityReferralList[0].Id,
                                                        convertedLead.ConvertedOpportunityId);                
                    }
                    update opp;
                    medEquipmentToInsert = createEquipmntRecordlist(opp.Id, medEquipmentToInsert);
                    infctsDsiseaseToInsert = createDiseaseRecordlist(opp.Id, infctsDsiseaseToInsert);
                    medIssueToInsert = createMedIssueRecordlist(opp.Id, medIssueToInsert);
                    insert medEquipmentToInsert;
                    insert infctsDsiseaseToInsert;
                    insert medIssueToInsert;
                    System.debug('opp  ::>'+opp);
            }
            /***Patient RecTypeForContact
            */
            String rectypePatient = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            System.Debug('rectypePatient___________________ '+rectypePatient);
            if(convertedLead.ConvertedContactId != null){
              Contact Conta = [select id, Name from Contact where id=:convertedLead.ConvertedContactId];
              Conta.RecordTypeId = rectypePatient;
              Conta.AccountId = null;
              Conta.Gender__c = convertedLead.Gender__c;
              Conta.Identified_Gender__c = convertedLead.Identified_Gender__c;
              update Conta;
            }
            if(convertedLead.ConvertedAccountId != null){
              Account Acc = [select id from Account where id =:convertedLead.ConvertedAccountId];
              delete Acc;
            }
            return  convertedLead.ConvertedOpportunityId + '';
    }
    
    // method to create list of Medical equipment prior to creation of Opportunity
    public static List<Medical_Equipment__c> createEquipmntRecordlist(Id pOpportunityId, List<Medical_Equipment__c> pMedEquipmntList) {
        List<Schema.PicklistEntry> equipmntTypeList = new List<Schema.PicklistEntry>();
        equipmntTypeList = Medical_Equipment__c.Equipment_Type__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry f : equipmntTypeList){
            Medical_Equipment__c medEqipmnt = new Medical_Equipment__c();
            medEqipmnt.Equipment_Type__c = string.valueof(f.getLabel());
            medEqipmnt.Opportunity__c = pOpportunityId;
            pMedEquipmntList.add(medEqipmnt);
        }
        return pMedEquipmntList;
    }
    
    // method to create list of infectious diseases prior to creation of Opportunity
    public static List<Infectious_Disease__c> createDiseaseRecordlist(Id pOpportunityId, List<Infectious_Disease__c> pInfctsDsiseaseToInsert) {
        List<Schema.PicklistEntry> diseasestypeList = new List<Schema.PicklistEntry>();
        diseasestypeList = Infectious_Disease__c.Infectious_Disease__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry f : diseasestypeList){
            Infectious_Disease__c InD = new Infectious_Disease__c();
            InD.Infectious_Disease__c= string.valueof(f.getLabel());
            InD.Diagnosed__c= '';
            InD.Opportunity__c  = pOpportunityId;
            pInfctsDsiseaseToInsert.add(InD);
        }
        return pInfctsDsiseaseToInsert;
    }
    
    // method to create list of major medical issues prior to creation of Opportunity
    public static List<Major_Medical_Issue__c> createMedIssueRecordlist(Id pOpportunityId, List<Major_Medical_Issue__c> pMedIssueToInsert) {
        List<Schema.PicklistEntry> medIssuestypeList = new List<Schema.PicklistEntry>();
        medIssuestypeList = Major_Medical_Issue__c.Major_Medical_Issue__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry f : medIssuestypeList){
            Major_Medical_Issue__c issue = new Major_Medical_Issue__c();
            issue.Major_Medical_Issue__c = string.valueof(f.getLabel());
            issue.Opportunity__c  = pOpportunityId;
            pMedIssueToInsert.add(issue);
        }
        return pMedIssueToInsert;
    }

}