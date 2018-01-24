public class TriggerStaicVariableHelper
 {  
  // public static boolean firstRun = true;
  
   private static boolean run = true;
    public static boolean runOnce(){
    if(run){
     run=false;
     return true;
    }else{
        return run;
    }
    }

 }