/* Used to get all open SR's 
   Created By : Swapnil Gholap
*/
public with sharing class OpenSRutility {
    
    // to get all open cases against booking unit
    public static Map<ID,List<Case>> getOpenSR(List<String> lstBookingUnitIDs,string strCaseID){
        map<ID,List<Case>> mapOpenSR = new map<ID,List<Case>>();
        List<Case> lstCaseWithBookingID = new List<Case>();
        List<Case> lstCaseWithOutBookingID = new List<Case>();
        System.debug('--lstBookingUnitIDs--'+lstBookingUnitIDs);
        lstCaseWithBookingID = [Select Id,CaseNumber, SR_Type__c,RecordType.developerName, Booking_Unit__c From Case 
                  Where Booking_Unit__c != null AND Booking_Unit__c IN: lstBookingUnitIDs
                  AND ID !=: strCaseID
                  AND Status != 'Closed' And Status != 'Rejected'];         
        
        System.debug('--lstCaseWithBookingID 1--'+lstCaseWithBookingID.Size()+'--'+lstCaseWithBookingID);
        /*for(case objCase : lstCaseWithBookingID){
            List<Case> lstBookingUnitCase = new List<Case>();
            lstBookingUnitCase.add(objCase);
            mapOpenSR.put(objCase.Booking_Unit__c,lstBookingUnitCase);
        }*/
        
        for(case objCase : lstCaseWithBookingID){                        
            if(mapOpenSR.containsKey(objCase.Booking_Unit__c)){
                List<Case> lstBookingUnitCases = new List<Case>();
                lstBookingUnitCases = mapOpenSR.get(objCase.Booking_Unit__c);                        
                lstBookingUnitCases.add(objCase);
                mapOpenSR.put(objCase.Booking_Unit__c,lstBookingUnitCases);   
            }
            else{
                List<Case> lstBookingUnitCase = new List<Case>();
                lstBookingUnitCase.add(objCase);
                mapOpenSR.put(objCase.Booking_Unit__c,lstBookingUnitCase);                        
            }     
        }
        
        System.debug('--mapOpenSR utility 1--'+mapOpenSR.Size()+'---'+mapOpenSR);
        
        /*lstCaseWithOutBookingID = [Select Id,CaseNumber, SR_Type__c, Booking_Unit__c,RecordType.developerName,
                  (select id,Case__c,Booking_Unit__c from SR_Booking_Units__r where
                  Booking_Unit__c IN : lstBookingUnitIDs)
                  From Case 
                  Where Booking_Unit__c = null
                  AND ID !=: strCaseID
                  AND Status != 'Closed' AND Status != 'Rejected'];
        System.debug('--lstCaseWithOutBookingID 2--'+lstCaseWithOutBookingID.Size()+'--'+lstCaseWithOutBookingID);                  
        for(case objCase : lstCaseWithOutBookingID){
            
            if(objCase.SR_Booking_Units__r.Size()>0){
                System.debug('--objCase.SR_Booking_Units__r--'+objCase.SR_Booking_Units__r.Size()+'--objCase--'+objCase+'----'+objCase.SR_Booking_Units__r);
                for(SR_Booking_Unit__c objSRunit : objCase.SR_Booking_Units__r){
                    if(mapOpenSR.containsKey(objSRunit.Booking_Unit__c)){
                        List<Case> lstBookingUnitCases = new List<Case>();
                        lstBookingUnitCases = mapOpenSR.get(objSRunit.Booking_Unit__c);                        
                        lstBookingUnitCases.add(objCase);
                        mapOpenSR.put(objSRunit.Booking_Unit__c,lstBookingUnitCases);   
                    }
                    else{
                        List<Case> lstBookingUnitCase = new List<Case>();
                        lstBookingUnitCase.add(objCase);
                        mapOpenSR.put(objSRunit.Booking_Unit__c,lstBookingUnitCase);                        
                    }
                }
            }
        }*/
        
        List<SR_Booking_Unit__c> lstSRbookingUnit = new List<SR_Booking_Unit__c>();
        lstSRbookingUnit = [Select id,Case__c,Case__r.id,Case__r.SR_Type__c,Case__r.CaseNumber,
                           Case__r.RecordType.developerName,
                           Booking_Unit__c from SR_Booking_Unit__c where
                           Booking_Unit__c IN : lstBookingUnitIDs
                           AND Case__c != null
                           AND Case__r.id !=: strCaseID
                           AND Case__r.Status != 'Closed' AND Case__r.Status != 'Rejected'];
                           
        List<String> lstCaseID = new List<String>();
        for(SR_Booking_Unit__c objSRbookingUnit : lstSRbookingUnit){
            lstCaseID.add(objSRbookingUnit.Case__r.id);
        }
        
        List<Case> lstCases = new List<Case>();
        lstCases = [Select id,CaseNumber,Status,SR_Type__c,RecordType.developerName from Case where id IN : lstCaseID];
        
        map<ID,Case> mapCase = new map<ID,Case>();
        for(Case objCase : lstCases){
            mapCase.put(objCase.id,objCase);
        } 
            
        for(SR_Booking_Unit__c objSRbookingUnit : lstSRbookingUnit){
            //System.debug('--objSRbookingUnit.Booking_Unit__c---'+objSRbookingUnit.Booking_Unit__c);
            if(mapOpenSR.containsKey(objSRbookingUnit.Booking_Unit__c)){
                List<Case> lstBookingUnitCases = new List<Case>();
                lstBookingUnitCases = mapOpenSR.get(objSRbookingUnit.Booking_Unit__c);                        
                
                //Case objCase = new Case();
                //objCase.id = objSRbookingUnit.Case__r.id;
                //objCase.SR_Type__c = objSRbookingUnit.Case__r.SR_Type__c;                                        
                
                lstBookingUnitCases.add(mapCase.get(objSRbookingUnit.Case__r.id));
                
                mapOpenSR.put(objSRbookingUnit.Booking_Unit__c,lstBookingUnitCases);   
            }
            else{
                List<Case> lstBookingUnitNewCase = new List<Case>();
                //Case objCase = new Case();
                //objCase.id = objSRbookingUnit.Case__r.id;
                //objCase.SR_Type__c = objSRbookingUnit.Case__r.SR_Type__c;                                        
                
                lstBookingUnitNewCase.add(mapCase.get(objSRbookingUnit.Case__r.id));
                               
                mapOpenSR.put(objSRbookingUnit.Booking_Unit__c,lstBookingUnitNewCase); 
            }
        }
         
        System.debug('--mapOpenSR utility 2--'+mapOpenSR.Size()+'---'+mapOpenSR);
          
        return mapOpenSR;     
    }
    
    public static Map<ID,List<Case>> getClosedSR(List<String> lstBookingUnitIDs,string strCaseID){
        map<ID,List<Case>> mapClosedSR = new map<ID,List<Case>>();
        List<Case> lstCaseWithBookingID = new List<Case>();
        List<Case> lstCaseWithOutBookingID = new List<Case>();
        System.debug('-getClosedSR-lstBookingUnitIDs--'+lstBookingUnitIDs);
        lstCaseWithBookingID = [Select Id,CaseNumber, SR_Type__c,RecordType.developerName, Booking_Unit__c From Case 
                  Where Booking_Unit__c != null AND Booking_Unit__c IN: lstBookingUnitIDs
                  AND ID !=: strCaseID
                  AND (Status = 'Closed' OR Status = 'Rejected')];         
        
        System.debug('-getClosedSR-lstCaseWithBookingID 1--'+lstCaseWithBookingID.Size()+'--'+lstCaseWithBookingID);
        /*for(case objCase : lstCaseWithBookingID){
            List<Case> lstBookingUnitCase = new List<Case>();
            lstBookingUnitCase.add(objCase);
            mapClosedSR.put(objCase.Booking_Unit__c,lstBookingUnitCase);
        }*/
        
        for(case objCase : lstCaseWithBookingID){                        
            if(mapClosedSR.containsKey(objCase.Booking_Unit__c)){
                List<Case> lstBookingUnitCases = new List<Case>();
                lstBookingUnitCases = mapClosedSR.get(objCase.Booking_Unit__c);                        
                lstBookingUnitCases.add(objCase);
                mapClosedSR.put(objCase.Booking_Unit__c,lstBookingUnitCases);   
            }
            else{
                List<Case> lstBookingUnitCase = new List<Case>();
                lstBookingUnitCase.add(objCase);
                mapClosedSR.put(objCase.Booking_Unit__c,lstBookingUnitCase);                        
            }     
        }
        
        System.debug('--mapClosedSR utility 1--'+mapClosedSR.Size()+'---'+mapClosedSR);
        
        /*lstCaseWithOutBookingID = [Select Id,CaseNumber, SR_Type__c, Booking_Unit__c,RecordType.developerName,
                  (select id,Case__c,Booking_Unit__c from SR_Booking_Units__r where
                  Booking_Unit__c IN : lstBookingUnitIDs)
                  From Case 
                  Where Booking_Unit__c = null
                  AND ID !=: strCaseID
                  AND Status = 'Closed' AND Status = 'Rejected'];
        System.debug('--lstCaseWithOutBookingID 2--'+lstCaseWithOutBookingID.Size()+'--'+lstCaseWithOutBookingID);                  
        for(case objCase : lstCaseWithOutBookingID){
            
            if(objCase.SR_Booking_Units__r.Size()>0){
                System.debug('--objCase.SR_Booking_Units__r--'+objCase.SR_Booking_Units__r.Size()+'--objCase--'+objCase+'----'+objCase.SR_Booking_Units__r);
                for(SR_Booking_Unit__c objSRunit : objCase.SR_Booking_Units__r){
                    if(mapClosedSR.containsKey(objSRunit.Booking_Unit__c)){
                        List<Case> lstBookingUnitCases = new List<Case>();
                        lstBookingUnitCases = mapClosedSR.get(objSRunit.Booking_Unit__c);                        
                        lstBookingUnitCases.add(objCase);
                        mapClosedSR.put(objSRunit.Booking_Unit__c,lstBookingUnitCases);   
                    }
                    else{
                        List<Case> lstBookingUnitCase = new List<Case>();
                        lstBookingUnitCase.add(objCase);
                        mapClosedSR.put(objSRunit.Booking_Unit__c,lstBookingUnitCase);                        
                    }
                }
            }
        }*/
        
        List<SR_Booking_Unit__c> lstSRbookingUnit = new List<SR_Booking_Unit__c>();
        lstSRbookingUnit = [Select id,Case__c,Case__r.id,Case__r.SR_Type__c,Case__r.CaseNumber,
                           Case__r.RecordType.developerName,
                           Booking_Unit__c from SR_Booking_Unit__c where
                           Booking_Unit__c IN : lstBookingUnitIDs
                           AND Case__c != null
                           AND Case__r.id !=: strCaseID
                           AND (Case__r.Status = 'Closed' OR Case__r.Status = 'Rejected')];
        System.debug('--Close SR lstSRbookingUnit---'+lstSRbookingUnit.size()+'--'+lstSRbookingUnit);                   
        List<String> lstCaseID = new List<String>();
        for(SR_Booking_Unit__c objSRbookingUnit : lstSRbookingUnit){
            lstCaseID.add(objSRbookingUnit.Case__r.id);
        }
        
        List<Case> lstCases = new List<Case>();
        lstCases = [Select id,CaseNumber,Status,SR_Type__c,RecordType.developerName from Case where id IN : lstCaseID];
        
        map<ID,Case> mapCase = new map<ID,Case>();
        for(Case objCase : lstCases){
            mapCase.put(objCase.id,objCase);
        } 
            
        for(SR_Booking_Unit__c objSRbookingUnit : lstSRbookingUnit){
            //System.debug('--objSRbookingUnit.Booking_Unit__c---'+objSRbookingUnit.Booking_Unit__c);
            if(mapClosedSR.containsKey(objSRbookingUnit.Booking_Unit__c)){
                List<Case> lstBookingUnitCases = new List<Case>();
                lstBookingUnitCases = mapClosedSR.get(objSRbookingUnit.Booking_Unit__c);                        
                
                //Case objCase = new Case();
                //objCase.id = objSRbookingUnit.Case__r.id;
                //objCase.SR_Type__c = objSRbookingUnit.Case__r.SR_Type__c;                                        
                
                lstBookingUnitCases.add(mapCase.get(objSRbookingUnit.Case__r.id));
                
                mapClosedSR.put(objSRbookingUnit.Booking_Unit__c,lstBookingUnitCases);   
            }
            else{
                List<Case> lstBookingUnitNewCase = new List<Case>();
                //Case objCase = new Case();
                //objCase.id = objSRbookingUnit.Case__r.id;
                //objCase.SR_Type__c = objSRbookingUnit.Case__r.SR_Type__c;                                        
                
                lstBookingUnitNewCase.add(mapCase.get(objSRbookingUnit.Case__r.id));
                               
                mapClosedSR.put(objSRbookingUnit.Booking_Unit__c,lstBookingUnitNewCase); 
            }
        }
         
        System.debug('--mapClosedSR utility 2--'+mapClosedSR.Size()+'---'+mapClosedSR);
          
        return mapClosedSR;     
    }
    
     // To check SR Initiation is valid or not
     public static boolean validateSRInitiation(set<String> setSRInitiationRecordTypes,list<Case> lstCase,string strCaseID){
       Boolean blnIsValid = true;       
       
       for(Case objCase : lstCase){
           if(objCase.id != strCaseID && setSRInitiationRecordTypes.Contains(objCase.RecordType.developerName)){
               blnIsValid = false;
           }
       }
       
       return blnIsValid;
     }
}