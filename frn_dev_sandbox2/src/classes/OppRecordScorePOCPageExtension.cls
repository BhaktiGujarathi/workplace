public with sharing class OppRecordScorePOCPageExtension {

    public Opportunity opp {get;set;}
    public static string oppId    {get;set;}

    public OppRecordScorePOCPageExtension() {
      //oppId = ApexPages.currentPage().getParameters().get('Id'); 
      system.debug('>>> oppId : '+oppId);
    }

    static {
      system.debug('>>> oppId : '+oppId);
    }

    /*static {
        //sectionScoreFieldToFieldsMap = ScoreMetadataService.fetchJsonMetadata();
        system.debug('>>> oppId : '+oppId);
    }*/

    /*public OppRecordScorePOCPageExtension(ApexPages.StandardController stdController) {
        oppId = ((Opportunity)stdController.getRecord()).id;
        opp = new Opportunity();
        opp = [
                SELECT AccountId
                     , RAM_Status__c
                     , Benefits_Status__c
                     , Close_Reason__c
                     , Account.Name
                     , Ongoing_Medical_Issues_or_Conditions__c
                     , Scratchpad__c
                     , Amount
                     , Opportunity_Age__c
                     , Are_You_Able_to_Travel_Alone__c
                     , Are_You_Able_to_Walk_a_Mile__c
                     , Are_You_Able_to_Walk_Up_Down_Stairs__c
                     , Are_You_Able_to_Walk_on_Rugged_Terrain__c
                     , CampaignId,Clinical_Collected_from__c
                     , CloseDate,ConcurConnect__AccruedUnApprovedExpenses__c
                     , Ready_to_Make_Commitment__c
                     , ConcurConnect__AccruedUnApprovedExpenseTotal__c
                     , ConcurConnect__FinalExpenseTotal__c
                     , ConcurConnect__FinalExpense__c
                     , Contact__c
                     , Contact__r.Name
                     , Contact__r.FirstName
                     , Contact__r.LastName
                     , Contact__r.Social_Security_Number__c
                     , Contact__r.Preferred_Method_of_Contact__c
                     , Contact__r.Birthdate
                     , Contact__r.MailingCity
                     , Contact__r.MailingState
                     , Contributing_Factors__c
                     , CreatedById
                     , CreatedDate
                     , Currently_Enrolled_at_FRN_IOP_Facility__c
                     , Online_Search_Term__c
                     , Current_FRN_IOP_Facility__c
                     , Current_Thoughts_of_Attempting_Suicide__c
                     , Customer_Note__c,Call_in_Code__c
                     , Describe_Domestic_Violence_Situation__c
                     , Describe_Hit_Harm_Situation__c
                     , Describe_Suicide_Thoughts__c
                     , Description,Description_of_Suicide_Attempt__c
                     , Description_of_Suicide_Plan__c
                     , Did_Cut_Burn_Require_Medical_Attention__c
                     , Referral_Source_Unknown_Details__c
                     , Do_You_Have_a_Cutting_Burning_Plan__c
                     , Do_You_Have_a_Suicide_Plan__c
                     , Eating_Disorder_Treatment_Facility__c
                     , Family_Hx_of_Mental_Health__c
                     , Family_Hx_of_Substance_Abuse__c
                     , Fiscal
                     , FiscalQuarter
                     , FiscalYear
                     , ForecastCategory
                     , ForecastCategoryName
                     , Frequency_of_Cutting_Burning__c
                     , Have_You_Attended_Anger_Mgmt_Class__c
                     , Have_you_Been_Clean_Sober__c
                     , Have_You_Ever_Attempted_Suicide__c
                     , Have_You_Ever_Purged_or_Forced_Throw_Up__c
                     , Alumni_Referral_Source__c
                     , Have_You_Had_Thoughts_of_Harming_Others__c
                     , Have_You_Physically_Hit_Harmed_Anyone__c
                     , Have_You_Seen_a__c
                     , Have_You_Suffered_from_Binge_Eating__c
                     , Height_ft_in__c,Id,Impact_on_Relationships__c
                     , Intention_Fear_of_Suicide__c
                     , Involved_in_Domestic_Violence__c
                     , IOP_Staff_Referred_to_Admissions_Center__c
                     , IsClosed
                     , IsDeleted
                     , IsExcludedFromTerritory2Filter
                     , IsWon
                     , LastActivityDate
                     , LastModifiedById
                     , LastModifiedDate
                     , LastReferencedDate
                     , LastViewedDate
                     , Last_Cut_Burn_Date__c
                     , Last_Purged_Date__c
                     , LeadSource,Length_of_Time_Clean_Sober__c
                     , Length_of_Time_Purging__c
                     , Length_of_Time_Starving__c
                     , Chat_Email_Transcript__c
                     , Length_of_Time_Using_Laxatives__c
                     , Level_of_Committment__c
                     , Most_Recent_Attempt_Date__c
                     , Name
                     , Needs_Assessment__c
                     , NextStep
                     , Non_Sober_Scary_Behavior__c
                     , Number_of_Suicide_Attempts__c
                     , Occupation__c
                     , OwnerId
                     , Owner.Name
                     , Patient_Currently_Working__c
                     , Payment__c,Pricebook2Id
                     , Prior_PT_at_FRN_Residential_Treatment__c
                     , Prior_Treatment__c
                     , Probability
                     , Professional_License__c
                     , Purge_Frequency__c
                     , Purposely_Cut_or_Burned_Yourself__c
                     , Purposely_Starved_or_Restricted_Food__c
                     , Readmit__c
                     , Reason_for_No_Withdrawal_Symptom__c
                     , Reason_for_Seeking_Help__c
                     , RecordTypeId
                     , RecordType.Name
                     , RecordType.DeveloperName
                     , Relapse_Date__c
                     , Relationship_to_Patient__c
                     , Sober_Support__c
                     , StageName
                     , Suicide_Attempt_Additional_Notes__c
                     , SyncedQuoteId
                     , SystemModstamp
                     , Territory2Id
                     , Timeframe_of_Impact__c
                     , Travel_Restrictions__c
                     , Trigger__c
                     , Type
                     , Type__c
                     , Under_Influence_at_Time_of_Attempt__c
                     , Under_Influence_while_Cutting_Burning__c
                     , Upcoming_Court_Dates__c,Use_of_Laxatives_for_Weight_Loss__c
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
                     , Important_Admission_Notes__c
                     , Do_You_Have_a_Legal_Guardian__c
                     , Legal_Guardian_First_Name__c
                     , Legal_Guardian_Last_Name__c
                     , Attempted_Suicide_Methods__c
                     , Pending_Admission_Date__c
                     , Admission_Date__c
                     , Final_Quote_Selected__c
                     , FRN_Facility_Selected__c
                     , Refer_Out_Reason__c
                     , Cutting_Burning_Plan_Details__c
                     , Binge_Eating_Comments__c
                     , Caller_Id__c
                     , Alumni_Name__c
                     , Frequency_of_Blackouts__c
                     , Alumni_FRN_Facility__c
                     , Most_Recent_FRN_Facility__c
                     , Description_of_Average_Day__c
                     , Diagnosed_with_Psychiatric_Condition__c
                     , Impact_on_Job__c
                     , Estimated_Date_and_Time_of_Arrival__c
                     , Sober_Living_Selected__c
                     , Sober_Living_Facility__c
                     , Step_Down__c
                     , Transferring_Facility__c
                     , (select id from Documents__r)
                  FROM Opportunity
                 WHERE Id=:oppId
                 LIMIT 1 
            ];
    }

   // @RemoteAction
    public void getUpdatedScore() {
        //system.debug('>>> pOpportunity : '+pOpportunity);
        system.debug('>>> close reason : '+opp.Close_Reason__c);
    }*/
    
}