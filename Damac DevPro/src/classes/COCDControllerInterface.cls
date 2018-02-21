public class COCDControllerInterface{

/*public static boolean IsOnce = True ;

@future(Callout = true)
public static void COCDWebService(Set<Id> taskId){
  IsOnce = False ;
  String Status ;
  Service_Request__c Sr ;
  Account Acc ;
  Task  task = [select id ,
               Subject,
               OwnerId,
               Status,
               Owner.Name,
               WhatId  from Task where Id =: taskId];
               
            
        
    Status =    task.Status == 'Completed' ? 'C' : 'O' ;
    
     System.debug('COCD Task Records Insert--------------- '+task );  
  
  if(task.WhatId != null){
  Sr = [select id ,Account__c , Name from Service_Request__c where Id =: task.WhatId];
  }
   System.debug('COCD SR Records Insert ------------------------ '+Sr );  
 
if(Sr.Account__c != null){ 
   Acc = [select id ,
                   Party_ID__c,
                   Address_Line_1_Arabic__pc,
                   Address_Line_2_Arabic__pc,
                   Address_Line_3_Arabic__pc,
                   Address_Line_4_Arabic__pc,
                   Country_Arabic__pc,
                   City_Arabic__pc,
                   Address_Line_1__pc,
                   Address_Line_2__pc,
                   Address_Line_3__pc,
                   Address_Line_4__pc,
                   Country__pc,
                   City__pc,
                   Passport_Number__pc,
                   Phone_Country_Code__c,
                   PersonEmail,
                   PersonOtherPhone,
                   PersonMobilePhone
                   from Account where Id =: Sr.Account__c ];
}       
    
  COCDController.COCD_REQUEST_MESSAGE  COCD =  new COCDController.COCD_REQUEST_MESSAGE();
  if(task.Status != 'Completed' &&  task.Subject  == 'Verify Payment Received'){
 if(Acc != null){
  System.debug('COCD When SOAP Task is Created Insert----------------------- ');
  COCD.PARAM_ID=Sr.Name ;
    COCD.ATTRIBUTE1='Change of Contact Details';
    COCD.ATTRIBUTE2=task.Id ;   
    COCD.ATTRIBUTE3= String.isBlank(task.Subject) ? '' : task.Subject ;  
    COCD.ATTRIBUTE4=task.Owner.Name ;
    COCD.ATTRIBUTE5=!String.isBlank(Acc.Party_ID__c) ? Acc.Party_ID__c  : '' ;
    COCD.ATTRIBUTE6=Status ;
    COCD.ATTRIBUTE7=!String.isBlank(Acc.Address_Line_1__pc) ? Acc.Address_Line_1__pc : '' ;
    COCD.ATTRIBUTE8=!String.isBlank(Acc.Address_Line_2__pc) ? Acc.Address_Line_2__pc :  '' ;
    COCD.ATTRIBUTE9=!String.isBlank(Acc.Address_Line_3__pc) ? Acc.Address_Line_3__pc  : '';
    COCD.ATTRIBUTE10=!String.isBlank(Acc.Address_Line_4__pc) ? Acc.Address_Line_4__pc : ''  ;
    COCD.ATTRIBUTE11=!String.isBlank(Acc.City__pc) ? Acc.City__pc : '' ;
    COCD.ATTRIBUTE12='';
    COCD.ATTRIBUTE13='';
    COCD.ATTRIBUTE14=!String.isBlank(Acc.Country__pc) ?  Acc.Country__pc  : '';
    COCD.ATTRIBUTE15=!String.isBlank(Acc.Passport_Number__pc) ? Acc.Passport_Number__pc : ''  ;
    COCD.ATTRIBUTE16='';
    COCD.ATTRIBUTE17=!String.isBlank(Acc.Phone_Country_Code__c) ? Acc.Phone_Country_Code__c : '' ;
    COCD.ATTRIBUTE18='';
    COCD.ATTRIBUTE19=!String.isBlank(Acc.PersonOtherPhone) ? Acc.PersonOtherPhone : '' ;
    
    COCD.ATTRIBUTE20='';
    COCD.ATTRIBUTE21='';
    COCD.ATTRIBUTE22=!String.isBlank(Acc.PersonMobilePhone) ? Acc.PersonMobilePhone : '' ;
    COCD.ATTRIBUTE23='';
    COCD.ATTRIBUTE24='';
    COCD.ATTRIBUTE25='';
    COCD.ATTRIBUTE26=!String.isBlank(Acc.PersonEmail) ? Acc.PersonEmail : '' ;
    COCD.ATTRIBUTE27=!String.isBlank(Acc.Address_Line_1_Arabic__pc) ? Acc.Address_Line_1_Arabic__pc : '' ;
    COCD.ATTRIBUTE28= !String.isBlank(Acc.Address_Line_2_Arabic__pc) ? Acc.Address_Line_2_Arabic__pc : '' ;
    COCD.ATTRIBUTE29= !String.isBlank(Acc.Address_Line_3_Arabic__pc) ? Acc.Address_Line_3_Arabic__pc  : '' ;
   
    COCD.ATTRIBUTE30=String.isBlank(Acc.Address_Line_4_Arabic__pc) ? '' : Acc.Address_Line_4_Arabic__pc ;
    COCD.ATTRIBUTE31=String.isBlank(Acc.City_Arabic__pc) ? '' : Acc.City_Arabic__pc ;
    COCD.ATTRIBUTE32= String.isBlank(Acc.Country_Arabic__pc) ? '' : Acc.Country_Arabic__pc ;
    COCD.ATTRIBUTE33='';
    COCD.ATTRIBUTE34='';
    COCD.ATTRIBUTE35='';
    COCD.ATTRIBUTE36='';
    COCD.ATTRIBUTE37='';
    COCD.ATTRIBUTE38='';
    COCD.ATTRIBUTE39='';
  
    COCD.ATTRIBUTE40='';
    COCD.ATTRIBUTE41='';
    COCD.ATTRIBUTE42='';
    COCD.ATTRIBUTE43='';
    COCD.ATTRIBUTE44='';
    COCD.ATTRIBUTE45='';
    COCD.ATTRIBUTE46='';
    COCD.ATTRIBUTE47='';
    COCD.ATTRIBUTE48='';
    COCD.ATTRIBUTE49='';
    
    COCD.ATTRIBUTE50='';
    
    
     
   System.debug('COCD When Records Is Inserted---------------------' +COCD);
   System.debug('COCD When Records Is SR Name-------------------' +Sr.Name);
   COCDController.COCD obj = new  COCDController.COCD();
   obj.createCOCDTaskInIPMS(Sr.Name,COCD);
  }

}
}  
 
 
 @future(Callout = true)
public static void COCDWebServiceUpdate(Set<Id> taskId){
  IsOnce = False ;
  String Status ;
  Service_Request__c Sr ;
  Account Acc ;
  
  System.debug('Task Id-------------------'+taskId);
  Task  task = [select id ,
               Subject,
               OwnerId,
               Status,
               WhatId  from Task where Id =: taskId];
               
            
        
    Status =    task.Status == 'Completed' ? 'C' : 'O' ;
    
     System.debug('COCD Task Records Update--------------- '+task );  
  
  if(task.WhatId != null){
  Sr = [select id ,Account__c , 
                  Country_Code__c,
                  Phone_Country_Code__c,
                  Fax_Country_Code__c,
                  Contact_Fax__c,
                  Postal_Code__c,
                  Postal_Code_Arabic__c,
                  Contact_Mobile__c,
                  Address_Arabic_1__c,
                  Address_Arabic_2__c,
                  Address_Arabic_3__c,
                  Address_Arabic_4__c,
                  City__c,
                  City_Arabic__c,
                  Country__c,
                  Country_Arabic__c,
                  New_Contact_Email__c,
                  Address__c,
                  Address_2__c,
                  Address_3__c,
                  Address_4__c,
                  New_CRPassport_No__c,               
                  Name from Service_Request__c where Id =: task.WhatId];
  }
   System.debug('COCD SR Records Update------------------------ '+Sr );  
 
if(Sr.Account__c != null){ 
   Acc = [select id ,
                   Party_ID__c,
                   Address_Line_1_Arabic__pc,
                   Address_Line_2_Arabic__pc,
                   Address_Line_3_Arabic__pc,
                   Address_Line_4_Arabic__pc,
                   Country_Arabic__pc,
                   City_Arabic__pc,
                   Address_Line_1__pc,
                   Address_Line_2__pc,
                   Address_Line_3__pc,
                   Address_Line_4__pc,
                   Country__pc,
                   City__pc,
                   Passport_Number__pc,
                   Phone_Country_Code__c,
                   PersonEmail,
                   PersonOtherPhone,
                   PersonMobilePhone
                   from Account where Id =: Sr.Account__c ];
  } 



// if(task.Status == 'Completed' &&  task.Subject  == 'Verify Payment Received'){
     
     if(Acc != null){
     COCDController.Address  ObjAddress  =  new COCDController.Address();
 

  
  
  System.debug('COCD When Records Is Update---------------------' +ObjAddress  );
  
 
  ObjAddress.addressLine1 = !String.isBlank(Sr.Address__c) ? Sr.Address__c : '' ;
  ObjAddress.addressLine2= !String.isBlank(Sr.Address_2__c) ? Sr.Address_2__c: '' ;
  ObjAddress.addressLine3= !String.isBlank(Sr.Address_3__c) ? Sr.Address_3__c: '' ;
  ObjAddress.addressLine4= !String.isBlank(Sr.Address_4__c) ? Sr.Address_4__c: '' ;
  ObjAddress.addressLineArabic1= !String.isBlank(Sr.Address_Arabic_1__c) ? Sr.Address_Arabic_1__c : '' ;
  ObjAddress.addressLineArabic2= !String.isBlank(Sr.Address_Arabic_2__c) ? Sr.Address_Arabic_2__c : '' ;
  ObjAddress.addressLineArabic3= !String.isBlank(Sr.Address_Arabic_3__c) ? Sr.Address_Arabic_3__c : '' ;
  ObjAddress.addressLineArabic4= !String.isBlank(Sr.Address_Arabic_4__c) ? Sr.Address_Arabic_4__c : '' ;
  ObjAddress.city= !String.isBlank(Sr.City__c) ? Sr.City__c : '' ;
  ObjAddress.cityArabic= !String.isBlank(Sr.City_Arabic__c) ? Sr.City_Arabic__c: '' ;
  ObjAddress.country= !String.isBlank(Sr.Country__c) ? Sr.Country__c: '' ;
  ObjAddress.countryArabic= !String.isBlank(Sr.Country_Arabic__c) ? Sr.Country_Arabic__c: '' ;
  
   ObjAddress.crRegDate= '';
   ObjAddress.crRegPlace='';
   ObjAddress.cr_Number= '';
    ObjAddress.email = !String.isBlank(Sr.New_Contact_Email__c) ? Sr.New_Contact_Email__c : '' ;
    ObjAddress.fax= !String.isBlank(Sr.Contact_Fax__c) ? Sr.Contact_Fax__c : '' ;
    ObjAddress.faxAreaCode= !String.isBlank(Sr.Country_Code__c) ? Sr.Country_Code__c : '' ;
    ObjAddress.faxCountryCode=!String.isBlank(Sr.Fax_Country_Code__c) ? Sr.Fax_Country_Code__c : '' ;
    ObjAddress.mobile = !String.isBlank(Sr.Contact_Mobile__c) ? Sr.Contact_Mobile__c : '' ;
  
  ObjAddress.mobileAreaCode=  '' ;
  ObjAddress.mobileCountryCode=  '' ;
  ObjAddress.nationality= '' ;
  
  ObjAddress.passportIssueDate =  '' ;
  ObjAddress.passportNumber= !String.isBlank(Sr.New_CRPassport_No__c) ? Sr.New_CRPassport_No__c  : ''  ;
  
  ObjAddress.passprotIssuePlace= !String.isBlank(Acc.Address_Line_1__pc) ? Acc.Address_Line_1__pc : '' ;
  ObjAddress.phone= !String.isBlank(Sr.Contact_Mobile__c) ? Sr.Contact_Mobile__c : '' ;
  ObjAddress.postalCode= !String.isBlank(Sr.Postal_Code__c) ? Sr.Postal_Code__c : '' ;
  ObjAddress.postalCodeArabic= !String.isBlank(Sr.Postal_Code_Arabic__c) ? Sr.Postal_Code_Arabic__c : '' ;
  ObjAddress.primaryFlag= 'True';
  ObjAddress.passprotIssuePlace='' ;
  ObjAddress.state=  '' ;
  ObjAddress.workAreaCode=  '' ;
  ObjAddress.workCountryCode=  '' ;
  ObjAddress.workNumber=  '' ;
  
  
  COCDController.COCD  objUpdate   =  new COCDController.COCD ();
 // objUpdate.timeout_x = 20000 ;
  objUpdate.updateCOCDRecordInIPMS(Acc.Party_ID__c,Sr.Name,ObjAddress, '' , ''); 
  System.debug('Update COCD-----------------------------');
 
         }   
     
    //  }  
  
   }
*/
}