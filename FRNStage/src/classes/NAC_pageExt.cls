public class NAC_pageExt {
    public Opportunity opp {get; set;}
    public Quote qte {get; set;}
    public list<Patient_Insurance__c> patInsurance {get; set;}
    public list<Referral__c> referList {get; set;}
    public list<NAC_PDF_Setting__c> NACPDFCS {get; set;}
    public list<Note_Comment__c> NoteCommentList {get; set;}
    private List<QuoteLineItem> lstQuotelineItem;
    public Map<String,double> totalMap{get; set;}
    private Map<String, QuoteLineItem> qLineItemMap;
    private Map<string, string> pro2IdPeIdMap;
    public Map<Id,List<Reservation__c>> TripReservationMap{get; set;}
    public Map<Id,Trip__c> TripMap{get; set;}
    public Map<Id,boolean> ResFlagMap{get; set;}
    public List<Id> tripId {get; set;}
    public String INSRSubscriber {get; set;}
    public String RelationshiptoPatient {get; set;}
    public String INSRPhone {get; set;}

    
    public NAC_pageExt(ApexPages.StandardController controller) {
                INSRSubscriber = '';
                RelationshiptoPatient = '';
                INSRPhone = '';
        tripId = new List<Id>();
        TripMap = new Map<Id,Trip__c>();
        ResFlagMap = new Map<Id,boolean>();
        TripReservationMap = new Map<Id,List<Reservation__c>>();
                System.debug('TripReservationMap>>>>>>>>>>>>'+TripReservationMap);  
        NoteCommentList = new list<Note_Comment__c> ();
                System.debug('NoteCommentList_________________>>>>>>>>>>>>'+NoteCommentList);  
        String opId = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('opId_________________________________'+opId);     
        opp = new Opportunity();
        
        opp = [SELECT Id
                    , Contact__r.Salutation
                    , LeadSource
                    , Contact__r.FirstName
                    , Contact__r.Identified_Gender__c
                    , Contact__r.LastName
                    , Contact__r.TIER_ID__c
                    , Contact__r.Phone
                    , Contact__r.Gender__c
                    , Owner.Name
                    , CloseDate
                    , Account.Facility_Type__c
                    , Relationship_to_Patient__c
                    , Physical_Description_of_Patient__c
                    , Additional_Trip_Details__c
                    , Travel_Companion_Information__c
                    , Prior_Pending_Financial_Issues__c
                    , Account.Referrals_Score__c
                    , Contact__r.MobilePhone
                    , Contact__r.Birthdate
                    , FRN_Facility_Selected__r.Name
                    , Final_Quote_Selected__c
                    , Guarantor__c
                    , Guarantor__r.First_Name__c
                    , Guarantor__r.Last_Name__c
                    , Guarantor__r.Relationship__c
                    , Guarantor__r.Phone__c
                    , Secondary_Travel_Contact__r.Name
                    , Secondary_Travel_Contact__r.Mobile_Phone__c
                    , FRN_Facility_Selected__c
                    , Most_Recent_FRN_Facility__r.Name
                    , Secondary_Travel_Contact__r.First_Name__c
                    , Secondary_Travel_Contact__r.Last_Name__c
                    , Secondary_Travel_Contact__r.Relationship__c
                    , Guarantor_is_Self__c
                    , Estimated_Date_and_Time_of_Arrival__c
                    , High_Priority__c
                    , Referral_Instruction__c
                 FROM Opportunity 
                WHERE Id =: opId];
        system.debug('opp__________________________'+opp);
        
                
        referList = new list<Referral__c>();
        referList = [SELECT Id, RAM_Lookup__c, Account__r.name, Account__r.owner.Name, Opportunity__c, RecordType.name,Referral_Rank__c,Account__r.Business_Development_Lookup__r.Name FROM Referral__c WHERE Opportunity__c =: opId AND RecordType.name = 'Inbound Referral'  ORDER by CreatedDate DESC];
        system.debug('Referral__________________________'+referList);
        
        NACPDFCS = NAC_PDF_Setting__c.getall().values(); 
                system.debug('NAC_PDF_Setting__c>>>>>>>>>>>>>'+NACPDFCS);
    /***Note_Comment */
        NoteCommentList = [SELECT Id, Patient__r.Name, Note_Comment__c, createddate,CreatedBy.Name from Note_Comment__c where Opportunity__c =: opId];
        system.debug('NoteCommentList>>>>>>>>>>>>>'+NoteCommentList);      
    /********Quote*/    
       
        List<Quote> lqte = [Select id, Pay_Agreement_Worksheet__r.Patient_Insurance__c,Insurance_Company__r.name FROM Quote WHERE Opportunity.id =: opId AND select_as_Final_Quote__c = true LIMIT 1];
        qte = new Quote();
        if(lqte != null && lqte.size() > 0)
        {
          qte =  lqte[0];
        }
        String patInsWithQtSelectedFinal = qte.Pay_Agreement_Worksheet__r.Patient_Insurance__c;
        patInsurance = new list<Patient_Insurance__c>();
      //patInsurance = [SELECT Id, Name, Opportunity__c,Opportunity__r.Contact__r.Phone, Subscriber__c, Subscriber_is_Patient__c, Subscriber__r.First_Name__c, Subscriber__r.Last_Name__c, Insurance_Company__r.Name, State_of_Origination__c, COB_Needed__c, Subscriber__r.Relationship__c, Subscriber__r.Phone__c, Provider_Services_Phone__c FROM Patient_Insurance__c WHERE Opportunity__c =: opId ORDER by CreatedDate DESC LIMIT 1];
        patInsurance = [SELECT Id, Name, Opportunity__c,Opportunity__r.Contact__r.Phone, Subscriber__c, Subscriber_is_Patient__c, Subscriber__r.First_Name__c, Subscriber__r.Last_Name__c, Insurance_Company__r.Name, State_of_Origination__c, COB_Needed__c, Subscriber__r.Relationship__c, Subscriber__r.Phone__c, Provider_Services_Phone__c FROM Patient_Insurance__c WHERE id =: patInsWithQtSelectedFinal ORDER by CreatedDate DESC LIMIT 1];
        
        for(Patient_Insurance__c patI : patInsurance)
        {
                        if (patI.Subscriber_is_Patient__c == true){
                                
                                if(patI.Name != null) INSRSubscriber = patI.Name;
                                RelationshiptoPatient = 'Self';
                                if(patI.Opportunity__r.Contact__r.Phone != null) INSRPhone = patI.Opportunity__r.Contact__r.Phone;
                                system.debug('opp.Contact__r.Phone___'+patI.Opportunity__r.Contact__r.Phone+ '>>> '+INSRPhone);
                        
                        }else{
                                
                                IF(patI.Subscriber__r.First_Name__c != null && patI.Subscriber__r.First_Name__c != '') INSRSubscriber += patI.Subscriber__r.First_Name__c;
                                IF(patI.Subscriber__r.Last_Name__c != null && patI.Subscriber__r.Last_Name__c != '') INSRSubscriber += ' '+patI.Subscriber__r.Last_Name__c;
                                
                                RelationshiptoPatient = patI.Subscriber__r.Relationship__c;
                                INSRPhone = patI.Subscriber__r.Phone__c;
                                
                        }
          }
                
    /***Trip    */      
        TripMap = new Map<Id,Trip__c>([SELECT Id, Name, Trip_Name__c, Modified_Date_Time__c, Start_Date__c, End_Date__c, Description__c from Trip__c where Opportunity__c =: opId]);
        System.debug('TripMap____________________________ '+TripMap);   
    /***Set of Trip Ids  */
        for(Trip__c t:TripMap.values()){
            ResFlagMap.put(t.Id,false);
            tripId.add(t.Id);
        }
        
        System.debug('tripId____________________________ '+tripId);     
        
    /***Reservations   */
        //String rtId =   Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Airfare').getRecordTypeId();  
        //String rtId =   [SELECT Name FROM RecordType WHERE SobjectType = 'Reservation__c'].id;  
        List<Reservation__c> ReservList = [SELECT Id, Trip__c, RecordType.Name, Ticket_Number__c, Arrival_Date_Time__c, Departure_Date_Time__c,Airline__c   ,confirmation_Number__c,Flight_Number__c,Cabin__c,Status__c,Info_Warnings__c,Total_Amount_Charged__c,Departure_Airport__c,Arrival_Airport__c,Car_Service_Company_Name__c,Car_Service_Company_Phone__c,Pickup_Date_Time__c,Drop_Off_Date_Time__c,Pickup_Location_Type__c,Drop_off_at_same_location_as_Pickup__c,Pickup_Airport__c,Drop_off_Location_Type__c,Pickup_FRN_Facility__r.Name,Drop_off_Airport__c,Rate__c,Drop_off_FRN_Facility__r.name,Pickup_Address__c,Pickup_City__c,Pickup_State_Province_Region__c,Pickup_Zip_Postal_Code__c,Pickup_Country__c,Drop_off_Address__c,Drop_off_City__c,Drop_off_State_Province_Region__c,Drop_off_Zip_Postal_Code__c,Drop_off_Country__c from Reservation__c WHERE Trip__c IN: TripMap.keySet() ORDER By Arrival_Date_Time__c ASC NULLS FIRST];
        System.debug('ReservationList____________________________ '+ReservList);     
        List<Reservation__c> rsvList;   
        for(Reservation__c res: ReservList){
            if(TripReservationMap.containsKey(res.Trip__c)){
                 TripReservationMap.get(res.Trip__c).add(res);
                 
            } else {
                rsvList = new List<Reservation__c>();
                rsvList.add(res);
                TripReservationMap.put(res.Trip__c,rsvList);
                ResFlagMap.put(res.Trip__c,true);
            }
            System.debug('res'+ res);
        }       
        System.debug('TripReservationMap__________________ '+TripReservationMap);       
        
    }
    public PageReference generateNAC(){
        
         update opp;
        /*PageReference page = new PageReference('/apex/Generate_NAC_page?id='+opp.Id);
        page.setRedirect(true);*/
        return null; 
    }


    public PageReference cancel(){
        PageReference page = new PageReference('/'+opp.Id);
        page.setRedirect(true);
        return page;
    }
}