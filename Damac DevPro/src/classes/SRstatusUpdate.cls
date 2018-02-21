/***********************************************************************************************************************************
* Name:              : SRstatusUpdate*
* Description        :          *
* Created Date       : 21/07/2017*
* Created By         : Naresh          *
* ---------------------------------------------------------------------------------------------------------------------*
* VERSION     AUTHORDATE            COMMENTS          *
* 1.0         Naresh       02/07/2017      Initial Draft.          *
* 
  *
**************************************************************************************************************************************/

public class SRstatusUpdate{


public static Set<Id> AccID =  new Set<Id>();
//public static List<Account> AccList =  new List<Account>();
public static List<Buyer__c> BuyerList =  new List<Buyer__c>();
public static List<sObject> AccList =  new List<sObject>();
//public static List<Buyer__c> BuyerList =  new List<Buyer__c>();


public static void SrStatus(Map<Id,Service_Request__c> NewSR , Map<Id,Service_Request__c> OldSR){
try{
  for(Service_Request__c Sr : NewSR.values()){
        AccID.add(Sr.Account__c);
    }

  for(Account Acc : [Select Id , Address_Line_1__pc ,Passport_Issue_Place_Arabic__pc ,First_Name_Arabic__pc,Last_Name_Arabic__pc,Nationality_Arabic__pc,Title_Arabic__pc,(Select Address_Line_1__c ,Primary_Buyer__c , Account__c From Buyers__r where Primary_Buyer__c  = true)  from Account where Id =: AccID ]){
        Service_Request__c Sr =  NewSR.values();
        
        Acc.Address_Line_1__pc = Sr.Address__c ;
        Acc.Address_Line_2__pc =  Sr.Address_2__c;
        Acc.Address_Line_3__pc = Sr.Address_3__c;
        Acc.Address_Line_4__pc  = Sr.Address_4__c ;
        Acc.Address_Line_1_Arabic__pc  =   Sr.Address_Arabic_1__c ; 
        Acc.Address_Line_2_Arabic__pc  =  Sr.Address_Arabic_2__c ;   
        Acc.Address_Line_3_Arabic__pc  = Sr.Address_Arabic_3__c;  
        Acc.Address_Line_4_Arabic__pc    = Sr.Address_Arabic_4__c ;
        Acc.City__pc = Sr.City__c ;
        Acc.Country__pc  = Sr.Country__c ;
        Acc.Country_Arabic__pc = Sr.Country_Arabic__c ;
        Acc.City_Arabic__pc = Sr.City_Arabic__c ;
        AccList.add(Acc);
   
    if(!Acc.Buyers__r.isEmpty()){ 
        for(Buyer__c Buyer : Acc.Buyers__r){
            Buyer.Address_Line_1__c = Sr.Address__c ;
            Buyer.Address_Line_2__c = Sr.Address_2__c ;
            Buyer.Address_Line_3__c = Sr.Address_3__c ;
            Buyer.Address_Line_4__c = Sr.Address_4__c  ;
            Buyer.Address_Line_1_Arabic__c = Sr.Address_Arabic_1__c  ;
            Buyer.Address_Line_2_Arabic__c = Sr.Address_Arabic_2__c  ;
            Buyer.Address_Line_3_Arabic__c = Sr.Address_Arabic_3__c ;
            Buyer.Address_Line_4_Arabic__c = Sr.Address_Arabic_4__c  ;
           // Buyer.City__c = Sr.City__c  ;
            Buyer.Country__c = Sr.Country__c  ;
            Buyer.First_Name_Arabic__c= Acc.First_Name_Arabic__pc ;
            Buyer.Last_Name_Arabic__c =Acc.Last_Name_Arabic__pc ;
            Buyer.Nationality_Arabic__c = Acc.Nationality_Arabic__pc ;
            Buyer.Title_Arabic__c =Acc.Title_Arabic__pc ;
            Buyer.Place_of_Issue_Arabic__c= Acc.Passport_Issue_Place_Arabic__pc;
            Buyer.City_Arabic__c  = Sr.City_Arabic__c ;
            Buyer.Country_Arabic__c  = Sr.Country_Arabic__c ;
            
            AccList.add(Buyer);
         }
       }
   
      
       
     }
   
   System.debug('Account AND Buyer Update-------------------- '+AccList);
   if(!AccList.isEmpty()){
     // update AccList;  
     Database.update(AccList , false);

       System.debug('Updated Account########--------- '+AccList);
   }
}
catch(Exception Ex){
    System.debug('Exception @Message' +Ex.getMessage());
    System.debug('Exception @Line' +Ex.getLineNumber());
    
}
}



}