public class TestInlineEditingExt {

public boolean showOP{get;set;}
public boolean showIP{get;set;}
public List<account> ListofAccounts{get;set;}

   public TestInlineEditingExt (ApexPages.standardController sc)  
   {  
      ListofAccounts= new List<account>([select id,Name,Industry from      Account order by LastModifiedDate ASC limit 1  ]);  
        showOP=true;
        showIP=false;
   }  
   
   public PageReference save()
   {
    //system.debug('$$$$$$$ Hi this is called');
   return null;
   }
   
   public PageReference cancel()
   {
    showOP=true;
        showIP=false;
   return null;
   }
   
   public void sampleSupport()
   {
   if(showOP)
   {
        showOP=false;
        showIP=true;
   
   }
   else if(showIP)
   {
   
        showOP=true;
        showIP=false;
   
   
   }
   
    system.debug('$$$$$$$ Hi this is called');
   
   }
}