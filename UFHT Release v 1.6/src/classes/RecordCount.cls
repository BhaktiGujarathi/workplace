public class RecordCount
{
    public Integer NumberOfRecords ;
   
    public void calculateRecordCount()
    {
        
        List<UFHT__Ultra_Track_Container__c> UFHTList = [Select Id,UFHT__No_of_Records__c from UFHT__Ultra_Track_Container__c FOR UPDATE];
        for(UFHT__Ultra_Track_Container__c UFHT : UFHTList ) 
        {
            UFHT.UFHT__No_of_Records__c = UFHTList.size();
        } 
        update UFHTList ;  
        system.debug('UFHTList ==='+UFHTList  );

    }
}