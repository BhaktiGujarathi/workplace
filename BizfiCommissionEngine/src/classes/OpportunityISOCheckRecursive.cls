public with sharing class OpportunityISOCheckRecursive 
{

 public static boolean runBeforeUpdate = true;
 public static boolean runAfterUpdate = true;
 
    public static boolean runOnceForBefore()
    {
        if(runBeforeUpdate ){
         runBeforeUpdate = false;
         return true;
        }
        else
        {
            return runBeforeUpdate ;
        }
    }
    public static boolean runOnceForAfter()
    {
        if(runAfterUpdate )
        {
         runAfterUpdate = false;
         return true;
        }
        else
        {
            return runAfterUpdate ;
        }
    }
}