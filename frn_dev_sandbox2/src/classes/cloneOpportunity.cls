global class cloneOpportunity{

    WebService static Id  cloneOpptyRecordType(string opptyid){
        String displayOpptyName = '';      
        String conName=''; 
        Opportunity newOppty = new Opportunity();               
        Opportunity opp = new Opportunity();        
        String localtimeinString = System.now().format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
        System.debug('localtimeinString__________________________________'+localtimeinString);      
        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();

            if(opptyid != null && opptyid != ''){
                opp = [Select Id, Name, Contact__c, Contact__r.Name, StageName, CloseDate, Probability,Origin__c, AC_Assigned__c, RAM_Assigned__c, VOB_Assigned__c, LeadSource, Lead_Source_is_FRN_Alumni__c, Online_Search_Term__c, Alumni_Referral_Source__c, Referral_Source_Unknown_Details__c, Brief_PPH__c, Scratchpad__c, FRN_Facility_of_Interest__c,Final_Quote_Selected__c, Call_in_Code__c from Opportunity WHERE id=: opptyid];
                
            /***Opportunity.name */         
                    System.debug('Contact__r.Name_____________________________'+opp.Contact__r.Name);               
                    if(opp.Contact__r.Name != null){                        
                        System.debug('Contact__r.Name_____________________________'+opp.Contact__r.Name);
                        if(opp.Contact__r.Name != null && opp.Contact__r.Name != ''){
                            conName = opp.Contact__r.Name + ' ';   
                        }
                        
                    }
                    displayOpptyName = conName + 'ROO' + ' ' + localtimeinString;  
            }

            if(displayOpptyName != null && displayOpptyName !='' && opp!= null){        
                newOppty.Name = displayOpptyName;
                newOppty.StageName = opp.StageName;
                newOppty.FRN_Facility_of_Interest__c = opp.FRN_Facility_of_Interest__c;
                newOppty.Call_in_Code__c = opp.Call_in_Code__c;
                newOppty.CloseDate = opp.CloseDate;
                newOppty.Probability = opp.Probability;
                newOppty.Origin__c = opp.Origin__c;                                          
                newOppty.AC_Assigned__c = opp.AC_Assigned__c;
                newOppty.RAM_Assigned__c = opp.RAM_Assigned__c;
                newOppty.VOB_Assigned__c = opp.VOB_Assigned__c;
                newOppty.LeadSource = opp.LeadSource;
                newOppty.Lead_Source_is_FRN_Alumni__c = opp.Lead_Source_is_FRN_Alumni__c;
                newOppty.Online_Search_Term__c = opp.Online_Search_Term__c;
                newOppty.Alumni_Referral_Source__c = opp.Alumni_Referral_Source__c;
                newOppty.Referral_Source_Unknown_Details__c = opp.Referral_Source_Unknown_Details__c;
                newOppty.Brief_PPH__c = opp.Brief_PPH__c;
                newOppty.Scratchpad__c = opp.Scratchpad__c;         
                newOppty.Cloned_from_Opportunity__c = opp.Id;
                newOppty.Final_Quote_Selected__c = opp.Final_Quote_Selected__c;
                newOppty.RecordTypeId = rtId;
            if(opp.Contact__c != null){ 
                newOppty.Contact__c = opp.Contact__c;               
            }   
                insert newOppty;   
            }
           
            return newOppty.Id;
        
    }
      
    /***Update_PatientInsurance related_Opportunity_StageName = 'Benefits Submitted'  */  
        WebService static id  UpdatePatientInOppty(string patInsId){
        Patient_Insurance__c patIns = new Patient_Insurance__c();
        if(patInsId != null && patInsId != ''){
            patIns = [Select Id, Name, Opportunity__c from Patient_Insurance__c WHERE id=: patInsId]; 
        } 
        if(patIns.Opportunity__c != null){
            Opportunity newOppty = new Opportunity();
            newOppty.id = patIns.Opportunity__c;
            newOppty.StageName ='Benefits Submitted';  
            update newOppty;  
            System.debug('Updated NewOppty________________________________'+newOppty);      
        }
        return patIns.Id;
        
      } 
       /***Update_PatientInsurance related_Opportunity_StageName = 'Benefits Submitted'  */  
    WebService static void UpdatePatientForOpp(string opptyId){
        List<Patient_Insurance__c> patInsList = new List<Patient_Insurance__c>();
        if(opptyId != null && opptyId != ''){
            
            for(Patient_Insurance__c patIns:[Select Id, Name,VOB_status__c, Opportunity__c from Patient_Insurance__c WHERE Opportunity__c =: opptyId]){
                if(patIns.VOB_status__c=='' || patIns.VOB_status__c==null || patIns.VOB_status__c == 'Benefits Submitted' || patIns.VOB_status__c == 'Benefits Additional Info Needed' ||patIns.VOB_status__c == 'Secondary Benefits Complete'||patIns.VOB_status__c == 'Benefits Check Completed' || patIns.VOB_status__c == 'Determination Complete' ||patIns.VOB_status__c == 'Denied'){
                   patIns.VOB_status__c  = 'Benefits Submitted';
                   patInsList.add(patIns);
                }
            }
           if(patInsList.size()>0){
               update patInsList;
           }    
        }   
    } 
      
      
    WebService static Id  cloneOutPatOppty(string opptyid){
        String displayOpptyName = '';      
        String conName='';              
        Opportunity opp = new Opportunity();        
        String localtimeinString = System.now().format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
        System.debug('localtimeinString__________________________________'+localtimeinString);      
        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId();

            if(opptyid != null && opptyid != ''){
                opp = [SELECT AccountId,
                              Account.Name,
                              Amount,
                              Are_You_Able_to_Travel_Alone__c,
                              Are_You_Able_to_Walk_a_Mile__c,
                              Are_You_Able_to_Walk_Up_Down_Stairs__c,
                              CampaignId,
                              Clinical_Collected_from__c,
                              CloseDate,
                              ConcurConnect__FinalExpense__c,
                              Contact__c,
                              Contributing_Factors__c,
                              Currently_Enrolled_at_FRN_IOP_Facility__c,
                              Online_Search_Term__c,
                              Current_FRN_IOP_Facility__c,
                              Current_Thoughts_of_Attempting_Suicide__c,
                              Customer_Note__c,
                              Call_in_Code__c,
                              Describe_Domestic_Violence_Situation__c,
                              Describe_Hit_Harm_Situation__c,
                              Describe_Suicide_Thoughts__c,
                              Description,
                              Description_of_Average_Day__c,
                              Description_of_Suicide_Attempt__c,
                              Description_of_Suicide_Plan__c,
                              Diagnosed_with_Psychiatric_Condition__c,
                              Did_Cut_Burn_Require_Medical_Attention__c,
                              Referral_Source_Unknown_Details__c,
                              Do_You_Have_a_Cutting_Burning_Plan__c,
                              Do_You_Have_a_Suicide_Plan__c,
                              Eating_Disorder_Treatment_Facility__c,
                              Family_Hx_of_Mental_Health__c,
                              Family_Hx_of_Substance_Abuse__c,
                              ForecastCategory,
                              ForecastCategoryName,
                              Frequency_of_Cutting_Burning__c,
                              geopointe__Geocode__c,
                              Have_You_Attended_Anger_Mgmt_Class__c,
                              Have_you_Been_Clean_Sober__c,
                              Have_You_Ever_Attempted_Suicide__c,
                              Have_You_Ever_Purged_or_Forced_Throw_Up__c,
                              Alumni_Referral_Source__c,
                              Have_You_Had_Thoughts_of_Harming_Others__c,
                              Have_You_Physically_Hit_Harmed_Anyone__c,
                              Have_You_Seen_a__c,
                              Have_You_Suffered_from_Binge_Eating__c,
                              Height_ft_in__c,
                              Id,
                              Impact_on_Relationships__c,
                              Intention_Fear_of_Suicide__c,
                              Involved_in_Domestic_Violence__c,
                              IOP_Staff_Referred_to_Admissions_Center__c,
                              IsClosed,
                              IsWon,
                              Last_Cut_Burn_Date__c,
                              Last_Purged_Date__c,
                              LeadSource,
                              Length_of_Time_Clean_Sober__c,
                              Length_of_Time_Purging__c,
                              Length_of_Time_Starving__c,
                              Length_of_Time_Using_Laxatives__c,
                              Level_of_Committment__c,
                              Most_Recent_Attempt_Date__c,
                              Name,
                              Needs_Assessment__c,
                              NextStep,
                              Non_Sober_Scary_Behavior__c,
                              Number_of_Suicide_Attempts__c,
                              Occupation__c,
                              Patient_Currently_Working__c,
                              Payment__c,
                              Pricebook2Id,
                              Prior_PT_at_FRN_Residential_Treatment__c,
                              Prior_Treatment__c,
                              Probability,
                              Origin__c,
                              Preferred_Contact_Method__c,
                              Professional_License__c,
                              Purge_Frequency__c,
                              Purposely_Cut_or_Burned_Yourself__c,
                              Purposely_Starved_or_Restricted_Food__c,
                              Readmit__c,
                              Ready_to_Make_Commitment__c,
                              Reason_for_No_Withdrawal_Symptom__c,
                              Reason_for_Seeking_Help__c,
                              Relapse_Date__c,
                              Relationship_to_Patient__c,
                              Sober_Support__c,
                              StageName,
                              Suicide_Attempt_Additional_Notes__c,
                              Timeframe_of_Impact__c,
                              Travel_Restrictions__c,
                              Trigger__c,
                              Type,
                              Type__c,
                              Under_Influence_at_Time_of_Attempt__c,
                              Under_Influence_while_Cutting_Burning__c,
                              Upcoming_Court_Dates__c,
                              Use_of_Laxatives_for_Weight_Loss__c,
                              Vision_of_Future_without_Treatment__c,
                              Weight_lbs__c,
                              Were_You_Under_the_Influence__c,
                              What_Prompted_Call__c,
                              When_Were_You_Clean_Sober__c,
                              Who_Were_You_Thinking_of_Hurting__c,
                              Withdrawal_Symptoms__c,
                              Work_or_School_Problems__c,
                              AC_Assigned__c,
                              RAM_Assigned__c,
                              VOB_Assigned__c,
                              Lead_Source_is_FRN_Alumni__c,
                              Original_Lead_Owner__c,
                              Referral_Source_is_RAM_Account__c,
                              FRN_Facility_of_Interest__c,
                              Happiness_Scale__c,
                              Patient_Willing_to_Receive_Treatment__c,
                              Important_Admission_Notes__c,
                              Chat_Email_Transcript__c,
                              Legal_Guardian_First_Name__c,
                              Legal_Guardian_Last_Name__c,
                              Pending_Admission_Date__c,
                              Admission_Date__c,
                              Final_Quote_Selected__c,
                              FRN_Facility_Selected__c,
                              Refer_Out_Reason__c,
                              Scratchpad__c,
                              Estimated_Date_and_Time_of_Arrival__c
                         FROM Opportunity
                        WHERE Id=:opptyid];
                
            /***Opportunity.name */     
                if(opp.Contact__c !=null){
                    for(Contact con : [Select name from Contact where id=: opp.Contact__c]){
                         conName = con.Name + ' ';  
                    }
                }                  
                    displayOpptyName = conName + 'IOP' + ' ' + localtimeinString; 
                if(opp != null){
                    opp.id = null;
                }
                    
            }

            if(displayOpptyName != null && displayOpptyName !='' && opp!= null){        
                opp.Name = displayOpptyName;
                opp.RecordTypeId = rtId;
            if(opp.Contact__c != null){ 
                opp.Contact__c = opp.Contact__c;               
            }   
                insert opp;   
            }
           
            return opp.Id;
    }
    WebService static Id  cloneOpptyResTreatType(String opptyid){
        String displayOpptyName = '';
        String conName='';              
        Opportunity opp = new Opportunity();        
        String localtimeinString = System.now().format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
        System.debug('localtimeinString__________________________________'+localtimeinString);      
        String rtId =   Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
                                                      .get('Residential Treatment')
                                                      .getRecordTypeId();
        if(opptyid != null && opptyid != ''){
            opp = [
                SELECT AccountId
                        , Account.Name
                        , Amount
                        , Are_You_Able_to_Travel_Alone__c
                        , Are_You_Able_to_Walk_a_Mile__c
                        , Are_You_Able_to_Walk_Up_Down_Stairs__c
                        , CampaignId,Clinical_Collected_from__c
                        , CloseDate,ConcurConnect__FinalExpense__c
                        , Contact__c,Contributing_Factors__c
                        , Currently_Enrolled_at_FRN_IOP_Facility__c
                        , Online_Search_Term__c,Current_FRN_IOP_Facility__c
                        , Current_Thoughts_of_Attempting_Suicide__c
                        , Customer_Note__c,Call_in_Code__c
                        , Describe_Domestic_Violence_Situation__c
                        , Describe_Hit_Harm_Situation__c
                        , Describe_Suicide_Thoughts__c
                        , Description
                        , Description_of_Average_Day__c
                        , Description_of_Suicide_Attempt__c
                        , Description_of_Suicide_Plan__c
                        , Diagnosed_with_Psychiatric_Condition__c
                        , Did_Cut_Burn_Require_Medical_Attention__c
                        , Referral_Source_Unknown_Details__c
                        , Do_You_Have_a_Cutting_Burning_Plan__c
                        , Do_You_Have_a_Suicide_Plan__c
                        , Eating_Disorder_Treatment_Facility__c
                        , Family_Hx_of_Mental_Health__c
                        , Family_Hx_of_Substance_Abuse__c
                        , ForecastCategory
                        , ForecastCategoryName
                        , Frequency_of_Cutting_Burning__c
                        , geopointe__Geocode__c
                        , Have_You_Attended_Anger_Mgmt_Class__c
                        , Have_you_Been_Clean_Sober__c
                        , Have_You_Ever_Attempted_Suicide__c
                        , Have_You_Ever_Purged_or_Forced_Throw_Up__c
                        , Alumni_Referral_Source__c
                        , Have_You_Had_Thoughts_of_Harming_Others__c
                        , Have_You_Physically_Hit_Harmed_Anyone__c
                        , Have_You_Seen_a__c
                        , Have_You_Suffered_from_Binge_Eating__c
                        , Height_ft_in__c
                        , Id
                        , Impact_on_Relationships__c
                        , Intention_Fear_of_Suicide__c
                        , Involved_in_Domestic_Violence__c
                        , IOP_Staff_Referred_to_Admissions_Center__c
                        , IsClosed
                        , IsWon
                        , Last_Cut_Burn_Date__c
                        , Last_Purged_Date__c
                        , LeadSource
                        , Length_of_Time_Clean_Sober__c
                        , Length_of_Time_Purging__c
                        , Length_of_Time_Starving__c
                        , Length_of_Time_Using_Laxatives__c
                        , Level_of_Committment__c
                        , Most_Recent_Attempt_Date__c
                        , Name
                        , Needs_Assessment__c
                        , NextStep
                        , Non_Sober_Scary_Behavior__c
                        , Number_of_Suicide_Attempts__c
                        , Occupation__c
                        , Patient_Currently_Working__c
                        , Payment__c
                        , Pricebook2Id
                        , Prior_PT_at_FRN_Residential_Treatment__c
                        , Prior_Treatment__c
                        , Probability
                        , Origin__c
                        , Professional_License__c
                        , Purge_Frequency__c
                        , Purposely_Cut_or_Burned_Yourself__c
                        , Purposely_Starved_or_Restricted_Food__c
                        , Readmit__c
                        , Ready_to_Make_Commitment__c
                        , Reason_for_No_Withdrawal_Symptom__c
                        , Reason_for_Seeking_Help__c
                        , Relapse_Date__c
                        , Relationship_to_Patient__c
                        , Sober_Support__c
                        , StageName
                        , Suicide_Attempt_Additional_Notes__c
                        , Timeframe_of_Impact__c
                        , Travel_Restrictions__c
                        , Trigger__c
                        , Type
                        , Type__c
                        , Under_Influence_at_Time_of_Attempt__c
                        , Under_Influence_while_Cutting_Burning__c
                        , Upcoming_Court_Dates__c
                        , Use_of_Laxatives_for_Weight_Loss__c
                        , Vision_of_Future_without_Treatment__c
                        , Weight_lbs__c
                        , Were_You_Under_the_Influence__c
                        , What_Prompted_Call__c
                        , When_Were_You_Clean_Sober__c
                        , Who_Were_You_Thinking_of_Hurting__c
                        , Withdrawal_Symptoms__c
                        , Work_or_School_Problems__c
                        , AC_Assigned__c
                        , RAM_Assigned__c
                        , VOB_Assigned__c
                        , Lead_Source_is_FRN_Alumni__c
                        , Original_Lead_Owner__c
                        , Referral_Source_is_RAM_Account__c
                        , FRN_Facility_of_Interest__c
                        , Happiness_Scale__c
                        , Patient_Willing_to_Receive_Treatment__c
                        , Preferred_Contact_Method__c
                        , Important_Admission_Notes__c
                        , Chat_Email_Transcript__c
                        , Legal_Guardian_First_Name__c
                        , Legal_Guardian_Last_Name__c
                        , Pending_Admission_Date__c
                        , Admission_Date__c
                        , Final_Quote_Selected__c
                        , FRN_Facility_Selected__c
                        , Refer_Out_Reason__c
                        , Scratchpad__c
                        , Attempted_Suicide_Methods__c
                        , Do_You_Have_a_Legal_Guardian__c
                        , Physical_Description_of_Patient__c
                        , Estimated_Date_and_Time_of_Arrival__c
                    FROM Opportunity WHERE Id=:opptyid
                ];

            
        /***Opportunity.name */     
            if(opp.Contact__c !=null){
                for(Contact con : [Select name from Contact where id=: opp.Contact__c]){
                    conName = con.Name + ' ';  
                }
            }                  
            
            displayOpptyName = conName + 'RTC' + ' ' + localtimeinString; 
            
            if(opp != null){
                opp.id = null;
            }
                
        }

        if(displayOpptyName != null && displayOpptyName !='' && opp!= null){       

            opp.Name = displayOpptyName;
            opp.RecordTypeId = rtId;

            if(opp.Contact__c != null){ 
                opp.Contact__c = opp.Contact__c;               
                opp.Preferred_Contact_Method__c = opp.Preferred_Contact_Method__c;               
                opp.Attempted_Suicide_Methods__c = opp.Attempted_Suicide_Methods__c;               
                opp.Do_You_Have_a_Legal_Guardian__c = opp.Do_You_Have_a_Legal_Guardian__c;               
                opp.Physical_Description_of_Patient__c = opp.Physical_Description_of_Patient__c;               
            }
            //set new opportunity as transitioned one
            opp.Transitioned__c = true;
            opp.StageName = OpportunityTransition.STATUS_INPROGRESS;
            insert opp;
        }
        
        return opp.Id;
    }

    
}