public Class checkRecursiveOppToAudTrail{
    public static boolean runBeforeOppToAudTrail = true;
    public static boolean runAfterOppToAudTrail = true;
    public static boolean runOnceForBeforeOppToAudTrail(){
        if(runBeforeOppToAudTrail){
         runBeforeOppToAudTrail = false;
         return true;
        }else{
            return runBeforeOppToAudTrail ;
        }
    }
    public static boolean runOnceForAfterOppToAudTrail(){
        if(runAfterOppToAudTrail){
         runAfterOppToAudTrail = false;
         return true;
        }else{
            return runAfterOppToAudTrail ;
        }
    }
}