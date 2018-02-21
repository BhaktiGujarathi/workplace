public Class CheckRecursiveDeDupBeforeUpdate
{
    public static boolean runDeDupBeforeUpdate = true;
    
    
    public static boolean runOnceDeDupBeforeUpdate()
    {
        if(runDeDupBeforeUpdate ){
         runDeDupBeforeUpdate = false;
         return true;
        }else{
            return runDeDupBeforeUpdate;
        }
    }
    
   
}