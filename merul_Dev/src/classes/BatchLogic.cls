public class BatchLogic
{

 public static void updateAccount( List<Account> scope)
 {
 
     for(Account a : scope)
         {
            // a.Name = a.Name + 'Updated';   
           //a.name.replaceAll('Updated','');      
            a.name='test14';   
         }
         update scope;
 
 }

}