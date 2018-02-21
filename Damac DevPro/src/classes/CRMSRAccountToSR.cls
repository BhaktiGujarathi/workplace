/*
* Created Date       : 26/07/2017*
* Created By         : Pratiksha Narvekar
*/
public class CRMSRAccountToSR{

public static Set<Id> AccountId = new Set<Id>();
public static List< Account> AccList = new List<Account>();

@InvocableMethod public static void SrInsert(List<Service_Request__c> NewSR){
	System.debug('...NewSR...'+NewSR);
try{
  List<Service_Request__c> listSR = new List<Service_Request__c>();
  for(Service_Request__c Sr  : NewSR){
        AccountId.add(Sr.Account__c);
   }
   System.debug('Account Id--------------- '+AccountId);
   
   AccList  = [Select Id ,
               Address_Line_1__pc ,
               Address_Line_2__pc ,
               Address_Line_3__pc ,
               Address_Line_4__pc ,
               Address_Line_1_Arabic__pc ,
               Address_Line_2_Arabic__pc ,
               Mobile_Country_Code__c,
                Phone_Country_Code__c,
                Passport_Expiry_Date__pc,
                Passport_Issue_Place__pc,
                PersonEmail,
               Address_Line_3_Arabic__pc ,Address_Line_4_Arabic__pc,
               City__pc ,Country__pc ,Country_Arabic__pc ,City_Arabic__pc 
               from Account Where Id =: AccountId] ;
   
   for(Account Acc :  AccList ){
      
       for(Service_Request__c objSr  : NewSR){
       	   Service_Request__c Sr = new Service_Request__c();
           Sr.Address__c  = Acc.Address_Line_1__pc ;
           Sr.ID = objSr.ID;
           Sr.Address_2__c= Acc.Address_Line_2__pc ;
           Sr.Address_3__c= Acc.Address_Line_3__pc ;
           Sr.Address_4__c= Acc.Address_Line_4__pc ;
           Sr.Address_Arabic_1__c= Acc.Address_Line_1_Arabic__pc ;
           Sr.Address_Arabic_2__c= Acc.Address_Line_2_Arabic__pc ;
           Sr.Address_Arabic_3__c= Acc.Address_Line_3_Arabic__pc ;
           Sr.Address_Arabic_4__c= Acc.Address_Line_4_Arabic__pc ;
           Sr.City__c  = Acc.City__pc ;
           Sr.Country__c= Acc.Country__pc ;
           Sr.Country_Arabic__c= Acc.Country_Arabic__pc ;
           Sr.City_Arabic__c= Acc.City_Arabic__pc ;
           Sr.Contact_Mobile__c= Acc.Mobile_Country_Code__c;
           Sr.Phone_Country_Code__c= Acc.Phone_Country_Code__c;
           Sr.Passport_Issue_DateCR_Valid_Upto__c= Acc.Passport_Expiry_Date__pc;
           Sr.New_CRPassport_No__c= Acc.Passport_Issue_Place__pc;
           Sr.Contact_Email__c= Acc.PersonEmail;
           listSR.add(Sr);
   }
 }
 	   if(!listSR.isEmpty()){
            List<Database.saveResult> results = Database.Update(listSR,false);
            System.debug('.....results.....'+results);
	   }
}
 catch(Exception e){
 	System.debug('...Exception...'+e);
 }
 }
}