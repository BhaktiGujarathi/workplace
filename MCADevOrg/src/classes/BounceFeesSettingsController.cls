public class BounceFeesSettingsController
    {
         public List<Bounce_Fees_Settings__c> lstBounceFees {get;set;}
         public List<Bounce_Fees_Settings__c> lstAddBounceFees {get;set;}
         public Bounce_Fees_Settings__c objBounceFees{get;set;}
         public Integer totalCount {get;set;}
         public Integer rowIndex {get;set;}
         public BounceFeesSettingsController(ApexPages.StandardController controller)
         {
            lstBounceFees = [select Response_Code__c,Description__c,Fees__c from Bounce_Fees_Settings__c];
             totalCount = lstBounceFees.size();
             objBounceFees = new Bounce_Fees_Settings__c();
         }
         public void save()
         {
             upsert lstBounceFees;
         } 
         public void addRow()
         {
             lstAddBounceFees = new List<Bounce_Fees_Settings__c>();
             lstBounceFees.add(new Bounce_Fees_Settings__c());
         }
        public void deleteRow()
        {
            rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));            
            system.debug('$$'+rowIndex);            
            system.debug('$$'+lstBounceFees.size());
            if(lstBounceFees[rowIndex].id!=null)
                delete lstBounceFees[rowIndex];
            lstBounceFees.remove(rowIndex);         
        }
    }